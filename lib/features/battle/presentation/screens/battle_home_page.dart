import 'package:flutter/material.dart';
import 'package:quizflow_frontend/features/battle/data/datasources/battle_remote_data_source.dart';
import 'package:quizflow_frontend/features/battle/data/repositories/battle_repository_impl.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_record.dart';
import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/cancel_battle_match_usecase.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/fetch_match_result_usecase.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/fetch_new_battle_room_usecase.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/get_battle_room_usecase.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/join_battle_queue_usecase.dart';
import 'package:http/http.dart' as http;
import 'package:quizflow_frontend/features/battle/presentation/widgets/battle_history_card.dart';

class BattleHomePage extends StatefulWidget {
  const BattleHomePage({super.key});

  @override
  State<BattleHomePage> createState() => _BattleHomePageState();
}

class _BattleHomePageState extends State<BattleHomePage> {
  List<BattleRecord> battleRooms = [];

  late final BattleRepository battleRepository;

  late final GetBattleRoomUsecase getBattleRoomUsecase;
  late final JoinBattleQueueUsecase joinBattleQueueUsecase;
  late final FetchMatchResultUsecase fetchMatchResultUsecase;
  late final FetchNewBattleRoomUsecase fetchNewBattleRoomUsecase;
  late final CancelBattleMatchUsecase cancelBattleMatchUsecase;

  bool _isDisposed = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isMatchingCancelled = false;

  @override
  void initState() {
    super.initState();
    _setupDependencies();
    _fetchBattleRooms();
  }

  @override
  void dispose() {
    _isDisposed = true; // ✅ 위젯이 제거될 때 `_isDisposed`를 true로 설정
    super.dispose();
  }

  void _setupDependencies(){
    final httpClient = http.Client();
    final battleRemoteDataSource = BattleRemoteDataSource(client: httpClient);

    battleRepository = BattleRepositoryImpl(
        battleRemoteDataSource,
    );

    getBattleRoomUsecase = GetBattleRoomUsecase(battleRepository);
    joinBattleQueueUsecase = JoinBattleQueueUsecase(battleRepository);
    fetchMatchResultUsecase = FetchMatchResultUsecase(battleRepository);
    fetchNewBattleRoomUsecase = FetchNewBattleRoomUsecase(battleRepository);
    cancelBattleMatchUsecase = CancelBattleMatchUsecase(battleRepository);
  }

  /// 배틀룸 리스트 조회
  Future<void> _fetchBattleRooms() async {
    if (_isDisposed) {
      print("❌[ERROR] BattleHomePage가 이미 제거됨! setState() 실행 안 함.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<BattleRecord> data = await getBattleRoomUsecase.execute();
      if (!mounted) return; // ✅ mounted 체크 추가

      setState(() {
        battleRooms = data;
        _isLoading = false;
      });

      print("📥[DEBUG] 배틀 기록 불러오기 완료! ${battleRooms.length}개"); // ✅ 몇 개 불러왔는지 확인
    } catch (error) {
      if (!mounted) return; // ✅ mounted 체크 추가

      setState(() {
        _errorMessage = "배틀 기록 불러오기 실패: $error";
        _isLoading = false;
      });

      print("❌[ERROR] 배틀 기록 불러오기 실패: $error"); // ✅ 오류 로그 추가
    }
  }

  /// 매칭 대기열 등록 후 확인
  Future<void> _joinBattleQueue() async {
    try {
      print("🚀 배틀 매칭 대기열 참가 요청...");
      await joinBattleQueueUsecase.execute(); // ✅ 서버에 매칭 대기열 참가 요청
      print("✅ 배틀 매칭 대기열 참가 성공!");

      showBattleMatchingDialog(context); // ✅ 대기열 참가 후 다이얼로그 실행 (checkBattleMatching() 실행됨)
    } catch (error) {
      print("❌ 배틀 매칭 대기열 참가 실패: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("배틀 매칭 대기열 참가 실패: $error")),
      );
    }
  }

  /// 배틀룸 조회 자동화(매칭 결과 조회 + new배틀룸 확인)
  Future<void> checkBattleMatching(BuildContext context) async {
    bool isMatching = false;
    int? roomId;
    int maxRetries = 15;
    int retryCount = 0;

    _isMatchingCancelled = false; // ✅ 새 매칭 시작 시 취소 상태 초기화

    while (!isMatching && retryCount < maxRetries) {
      if (_isMatchingCancelled) {
        print("🛑 매칭이 취소되었습니다. 루프 종료!");
        return;
      }

      try {
        await fetchMatchResultUsecase.execute();

        if (_isMatchingCancelled) {
          print("🛑 매칭 취소됨! 배틀룸 조회 중단.");
          return;
        }

        // ✅ 새로운 배틀룸 확인 (배틀룸이 아직 생성되지 않은 경우 예외 발생 방지)
        roomId = await fetchNewBattleRoomUsecase.execute();

        if (roomId != null) {
          print("🚀 내가 포함된 배틀룸 입장: roomID = $roomId");
          _enterBattleRoom(context, roomId);
          isMatching = true; // ✅ 배틀룸 입장 후 매칭 중단
        } else {
          print("⏳ 매칭 대기 중... (${retryCount + 1}/$maxRetries)");
          await Future.delayed(const Duration(seconds: 2));
          retryCount++;
        }
      } catch (e) {
        print("⚠️ 매칭 중 오류 발생 (무시하고 재시도): $e"); // ✅ 오류가 발생해도 루프를 계속 돌림
      }
    }

    if (!isMatching) {
      print("⚠️ 매칭 시간 초과: 배틀룸을 찾지 못했습니다.");
      if (!_isMatchingCancelled) {
        Navigator.pop(context);
      }
    }
  }

  /// 배틀 매칭 중 다이얼로그 -> join시 실행, 조인usecase+취소usecase 포함, check 호출
  void showBattleMatchingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // ✅ 다이얼로그 바깥 클릭 방지
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("배틀 매칭 중..."),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("상대방을 찾는 중입니다..."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!_isMatchingCancelled) {
                  _isMatchingCancelled = true;
                  cancelBattleMatchUsecase.execute().then((_) { // ✅ API 요청을 기다리지 않음
                    print("🛑 배틀 매칭 취소 요청 완료!");
                  }).catchError((error) {
                    print("❌ 배틀 매칭 취소 중 오류 발생: $error");
                  });
                }
                Navigator.pop(dialogContext); // ✅ 즉시 다이얼로그 닫기
              },
              child: const Text("취소"),
            ),
          ],
        );
      },
    );

    // ✅ checkBattleMatching 실행 (비동기)
    checkBattleMatching(context);
  }

  /// 배틀룸 입장
  void _enterBattleRoom(BuildContext context, int roomId) {
    Navigator.pop(context); // ✅ 기존 매칭 다이얼로그 닫기

    // ✅ 배틀룸 입장 대기 다이얼로그 표시 (취소 불가)
    showDialog(
      context: context,
      barrierDismissible: false, // ✅ 다이얼로그 바깥 클릭 방지
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("배틀룸 입장 중..."),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("배틀룸에 입장할 준비 중입니다..."),
            ],
          ),
        );
      },
    );

    // ✅ 배틀룸이 준비될 때까지 대기 후 이동 (여기에 실제 입장 로직 추가 필요)
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // ✅ 배틀룸 대기 다이얼로그 닫기
      print("🚀 배틀룸에 입장: roomID = $roomId");
      // TODO: 배틀룸 페이지로 이동하는 코드 추가 필요
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16), // 패딩을 넉넉하게 조정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 버튼이 전체 너비를 차지하도록 설정
          children: [
            ElevatedButton(
              onPressed: _joinBattleQueue, // ✅ 배틀 시작 버튼 동작 연결
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF176560), // 직접 색상 지정
                foregroundColor: Colors.white, // 버튼 텍스트 색상
                padding: const EdgeInsets.symmetric(vertical: 14), // 버튼 높이 조정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // 둥근 모서리 적용
                ),
                elevation: 3, // 버튼 그림자 추가
              ),
              child: const Text(
                "배틀 시작하기",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12), // 버튼과 리스트 사이 간격 조정
            Expanded( // ✅ ListView가 Column 안에서 정상 작동하도록 감싸기
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red, // 에러 메시지는 빨간색 강조
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                itemCount: battleRooms.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6), // 카드 간격 추가
                    child: BattleHistoryCard(record: battleRooms[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
