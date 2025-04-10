import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quizflow_frontend/features/battle/domain/entities/battle_message_model.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/connect_websocket_usecase.dart';
import 'package:quizflow_frontend/features/battle/data/datasources/battle_remote_data_source.dart';
import 'package:quizflow_frontend/features/battle/data/datasources/battle_websocket_data_source.dart';
import 'package:quizflow_frontend/features/battle/data/repositories/battle_repository_impl.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/fetch_battle_result_usecase..dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/send_disconnect_usecase.dart';
import 'package:quizflow_frontend/features/battle/presentation/screens/battle_home_page.dart';
import 'package:quizflow_frontend/features/battle/presentation/widgets/widgets.dart';

class BattlePage extends StatefulWidget {
  final int battleRoomId;

  const BattlePage({
    Key? key,
    required this.battleRoomId,

  }) : super(key: key);

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> with WidgetsBindingObserver {
  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();

  late final ConnectWebSocketUseCase connectWebSocketUseCase;
  late final SendDisconnectUseCase sendDisconnectUseCase;
  late final FetchBattleResultUseCase fetchBattleResultUseCase;

  bool isRunning = false;
  String? error;
  List<BattleMessageModel> messages = [];
  bool _isWebSocketConnected = false;
  String? myRole;
  bool isOpponentFinished = false;
  bool isWaiting = false;
  bool isBattleStarting = true; // 시작 중 다이얼로그용
  bool hasArticleArrived = false; // 아티클 도착 여부(도착하면 배틀 타이머 시작)
  bool hasDisconnectedAfterFeedback = false;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final httpClient = http.Client();
    final remote = BattleRemoteDataSource(client: httpClient);
    final ws = BattleWebSocketDataSource();
    final repo = BattleRepositoryImpl(remote, ws);
    connectWebSocketUseCase = ConnectWebSocketUseCase(repo);
    sendDisconnectUseCase = SendDisconnectUseCase(repo);
    fetchBattleResultUseCase = FetchBattleResultUseCase(repo);
    _initializeWebSocket();

    // 시작중... 다이얼로그 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showStartingDialog(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    connectWebSocketUseCase.disconnect();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      //_disconnectWebSocket();
    } else if (state == AppLifecycleState.resumed) {
      _reconnectWebSocket();
    }
  }

  Future<void> _handleDisconnect(int battleRoomID) async {
    try {
      await sendDisconnectUseCase(widget.battleRoomId); // ✅ 전달
      print("📤 disconnect API 전송 성공");
    } catch (e) {
      print("❌ disconnect 전송 실패: $e");
    }
  }

  void showStartingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("배틀 시작 중"),
        content: const Text("배틀을 시작 중입니다...\n잠시만 기다려주세요!"),
      ),
    );
  }

  void _initializeWebSocket() {
    connectWebSocketUseCase.disconnect();

    connectWebSocketUseCase.execute(
      battleroomId: widget.battleRoomId,
      onNewMessage: (message) {
        setState(() {
          messages.add(message);

          // ✅ 아티클 도착 시 처리
          if (!hasArticleArrived && message.url != null && message.title != null) {
            hasArticleArrived = true;
            isBattleStarting = false;
            Navigator.of(context, rootNavigator: true).pop(); // 다이얼로그 닫기
          }
        });
        scrollToBottom();
      },

      onBattleReady: () => print("배틀 시작 준비 완료"),
      onOpponentFinished: (msg) => showTemporaryPopup(context, msg),
      onWaitForOtherPlayer: (msg) {
      showTemporaryPopup(context, msg);
      },
      onBothPlayersFinished: (msg) async {
        connectWebSocketUseCase.disconnect();
        _isWebSocketConnected = false;

        final result = await fetchBattleResultUseCase(widget.battleRoomId);

        if (result != null) {
          showResultDialog(context, result);
        } else {
          showErrorDialog(context, "결과를 불러오는 데 실패했습니다.");
        }
        },
      onReceiveRole: (role) => myRole = role,
    );

    _isWebSocketConnected = true;
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("⚠️ 오류 발생"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text("돌아가기"),
          )
        ],
      ),
    );
  }

  void _reconnectWebSocket() {
    if (_isWebSocketConnected) return;
    _initializeWebSocket();
  }

  void handleSendMessage(String message) {
    if (message.trim().isEmpty) return;
    setState(() {
      messages.add(BattleMessageModel(
        battleroomId: widget.battleRoomId,
        message: message,
        isGpt: false,
        timestamp: DateTime.now(),
      ));
    });
    connectWebSocketUseCase.sendMessage(message);
    controller.clear();
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget buildMessageList() {
    return ListView.separated(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) => buildMessageItem(
        message: messages[index],
        prevMessage: index > 0 ? messages[index - 1] : null,
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
    );
  }

  Widget buildMessageItem({
    BattleMessageModel? prevMessage,
    required BattleMessageModel message,
  }) {
    final isGpt = message.isGpt;
    final shouldDrawDateDivider =
        prevMessage == null || shouldDrawDate(prevMessage.timestamp, message.timestamp);

    // ⛳️ disconnect == true이면, disconnect 요청 (단 한 번만)
    if (message.disconnect == true && !hasDisconnectedAfterFeedback) {
      Future.microtask(() async {
        print("🔌 disconnect == true 감지. disconnect API 전송 시도");
        await sendDisconnectUseCase(widget.battleRoomId);
        print("📤 disconnect 전송 완료");
        hasDisconnectedAfterFeedback = true;
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (shouldDrawDateDivider)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DateDivider(date: message.timestamp),
            ),
          ),
        Align(
          alignment: isGpt ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: message.url != null && message.title != null
                ? ArticleCard(title: message.title!, url: message.url!)
                : Message(alignLeft: isGpt, message: message.message.trim(), timestamp: message.timestamp),
          ),
        ),
      ],
    );
  }

  bool shouldDrawDate(DateTime date1, DateTime date2) {
    return getStringDate(date1) != getStringDate(date2);
  }

  String getStringDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  void showTemporaryPopup(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    bool removed = false;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 80,
        left: 30,
        right: 30,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.amber[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (!removed) {
                      entry.remove();
                      removed = true;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 8), () {
      if (!removed) {
        entry.remove();
        removed = true;
      }
    });
  }

  void showWaitingDialog(BuildContext context) {
    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false, // 🔒 뒤로가기 및 터치로 닫히지 않게
      builder: (_) => AlertDialog(
        title: const Text("배틀 퀴즈에서 나가시겠습니까?"),
        content: const Text("상대방이 배틀 퀴즈를 완료 한 후 결과를 확인해 보실 수 있어요."),
        actions: [
          TextButton(
            onPressed: () {
              _isDialogOpen = false;
              connectWebSocketUseCase.disconnect();
              _isWebSocketConnected = false;

              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.popUntil(context, (route) => route.isFirst); // 홈으로 복귀
            },
            child: const Text("닫기"),
          ),
        ],
      ),
    ).then((_) {
      _isDialogOpen = false; // 다이얼로그가 닫히면 상태 리셋
    });
  }

  void showExitConfirmationDialog(BuildContext context) {
    _isDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("배틀 퀴즈를 나가시겠습니까?"),
        content: const Text("결과는 상대방이 완료된 후 확인해보실 수 있습니다."),
        actions: [
          TextButton(
            onPressed: () {
              _isDialogOpen = false;
              Navigator.of(context).pop(); // 취소
            },
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () async {
              _isDialogOpen = false;
              await _handleDisconnect(widget.battleRoomId);
              Navigator.of(context).pop(); // 팝업 닫기
              connectWebSocketUseCase.disconnect();
              _isWebSocketConnected = false;
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text("확인"),
          ),
        ],
      ),
    ).then((_) {_isDialogOpen = false;
    });
  }

  Future<void> fetchBattleResultWithRetry(int battleRoomId) async {
    const int maxAttempts = 5;
    const Duration retryDelay = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      print("🔁 결과 재시도: $attempt/$maxAttempts");

      final result = await fetchBattleResultUseCase(battleRoomId);

      if (result != null) {
        Navigator.of(context, rootNavigator: true).maybePop(); // 로딩 다이얼로그 닫기
        showResultDialog(context, result);
        return;
      }

      await Future.delayed(retryDelay);
    }

    Navigator.of(context, rootNavigator: true).maybePop(); // 로딩 다이얼로그 닫기
    showErrorDialog(context, "결과를 불러오는 데 실패했습니다. 잠시 후 다시 시도해주세요.");
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 우리가 직접 제어할 거니까 false
      onPopInvoked: (didPop) {
        if (didPop || _isDialogOpen) {
          // 이미 팝업 중이거나 시스템에서 처리했으면 아무것도 안 함
          return;
        }
        // 우리가 직접 다이얼로그 띄움
        if (hasDisconnectedAfterFeedback) {
          showWaitingDialog(context);
        } else {
          showExitConfirmationDialog(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (hasDisconnectedAfterFeedback) {
                showWaitingDialog(context);
              } else {
                showExitConfirmationDialog(context);
              }
            },
          ),
          title: Text("채팅방 ${widget.battleRoomId}", style: GoogleFonts.bebasNeue(fontSize: 22, color: Colors.white)),
          backgroundColor: const Color(0xFF69A88D),
        ),
        body: SafeArea(
          child: Column(
            children: [
              hasArticleArrived
                  ? BattleTimerProgressBar(
                onTimerEnd: () async {
                  print('타이머 종료!');
                  await sendDisconnectUseCase(widget.battleRoomId);

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const AlertDialog(
                      title: Text("결과를 불러오는 중..."),
                      content: SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  );

                  await fetchBattleResultWithRetry(widget.battleRoomId);
                },
              )
                  : const SizedBox.shrink(),
              Expanded(child: buildMessageList()),
              ChatTextField(
                error: error,
                loading: isRunning,
                onSend: () => handleSendMessage(controller.text),
                controller: controller,
              ),
            ],
          ),
        ),
      ),
    );
  }
}