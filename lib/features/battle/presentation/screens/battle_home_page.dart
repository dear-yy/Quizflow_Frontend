import 'package:flutter/material.dart';
import 'package:quizflow_frontend/features/battle/data/datasources/battle_remote_data_source.dart';
import 'package:quizflow_frontend/features/battle/data/datasources/battle_websocket_data_source.dart';
import 'package:quizflow_frontend/features/battle/data/repositories/battle_repository_impl.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_record.dart';
import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/cancel_battle_match_usecase.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/fetch_match_result_usecase.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/fetch_new_battle_room_usecase.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/get_battle_room_usecase.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/join_battle_queue_usecase.dart';
import 'package:http/http.dart' as http;
import 'package:quizflow_frontend/features/battle/presentation/screens/battle_page.dart';
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
    _isDisposed = true;
    super.dispose();
  }

  void _setupDependencies() {
    final httpClient = http.Client();
    final battleRemoteDataSource = BattleRemoteDataSource(client: httpClient);
    final battleWebSocketDataSource = BattleWebSocketDataSource();

    battleRepository = BattleRepositoryImpl(
      battleRemoteDataSource,
      battleWebSocketDataSource,
    );

    getBattleRoomUsecase = GetBattleRoomUsecase(battleRepository);
    joinBattleQueueUsecase = JoinBattleQueueUsecase(battleRepository);
    fetchMatchResultUsecase = FetchMatchResultUsecase(battleRepository);
    fetchNewBattleRoomUsecase = FetchNewBattleRoomUsecase(battleRepository);
    cancelBattleMatchUsecase = CancelBattleMatchUsecase(battleRepository);
  }

  Future<void> _fetchBattleRooms() async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<BattleRecord> data = await getBattleRoomUsecase.execute();
      if (!mounted) return;

      setState(() {
        battleRooms = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = "배틀 기록 불러오기 실패: $error";
        _isLoading = false;
      });
    }
  }

  Future<void> _joinBattleQueue() async {
    try {
      await joinBattleQueueUsecase.execute();
      showBattleMatchingDialog(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("배틀 매칭 대기열 참가 실패: $error")),
      );
    }
  }

  Future<void> checkBattleMatching(BuildContext context) async {
    bool isMatching = false;
    int? roomId;
    int maxRetries = 15;
    int retryCount = 0;

    _isMatchingCancelled = false;

    while (!isMatching && retryCount < maxRetries) {
      if (_isMatchingCancelled) return;

      try {
        await fetchMatchResultUsecase.execute();

        if (_isMatchingCancelled) return;

        roomId = await fetchNewBattleRoomUsecase.execute();

        if (roomId != null) {
          _enterBattleRoom(context, roomId);
          isMatching = true;
        } else {
          await Future.delayed(const Duration(seconds: 2));
          retryCount++;
        }
      } catch (_) {}
    }

    if (!isMatching && !_isMatchingCancelled) {
      Navigator.pop(context);
    }
  }

  void showBattleMatchingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                  cancelBattleMatchUsecase.execute();
                }
                Navigator.pop(dialogContext);
              },
              child: const Text("취소"),
            ),
          ],
        );
      },
    );

    checkBattleMatching(context);
  }

  Future<void> _enterBattleRoom(BuildContext context, int roomId) async {
    Navigator.pop(context); // 매칭 다이얼로그 닫기

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BattlePage(
          battleRoomId: roomId,
        ),
      ),
    ).then((_) {
      // BattlePage에서 돌아오면 배틀 기록을 다시 불러옴
      if (mounted) {
        _fetchBattleRooms();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _joinBattleQueue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176560),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: const Text(
                "배틀 시작하기",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                itemCount: battleRooms.length,
                itemBuilder: (context, index) {
                  final reversedList = battleRooms.reversed.toList();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: BattleHistoryCard(record: reversedList[index]),
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