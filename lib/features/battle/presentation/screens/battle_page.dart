import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quizflow_frontend/features/battle/domain/entities/battle_message_model.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/connect_websocket_usecase.dart';
import 'package:quizflow_frontend/features/battle/data/datasources/battle_remote_data_source.dart';
import 'package:quizflow_frontend/features/battle/data/datasources/battle_websocket_data_source.dart';
import 'package:quizflow_frontend/features/battle/data/repositories/battle_repository_impl.dart';
import 'package:quizflow_frontend/features/battle/presentation/widgets/widgets.dart';

class BattlePage extends StatefulWidget {
  final int battleRoomId;

  const BattlePage({
    Key? key,
    required this.battleRoomId,

  }) : super(key: key);

  @override
  State<BattlePage> createState() => _ChatPageState();
}

class _ChatPageState extends State<BattlePage> with WidgetsBindingObserver {
  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();

  late final ConnectWebSocketUseCase connectWebSocketUseCase;

  bool isRunning = false;
  String? error;
  List<BattleMessageModel> messages = [];
  bool _isWebSocketConnected = false;

  String? myRole;
  bool isOpponentFinished = false;
  bool isWaiting = false;
  bool isBattleStarting = true; // 시작 중 다이얼로그용
  bool hasArticleArrived = false; // 아티클 도착 여부(도착하면 배틀 타이머 시작)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final httpClient = http.Client();
    final remote = BattleRemoteDataSource(client: httpClient);
    final ws = BattleWebSocketDataSource();
    final repo = BattleRepositoryImpl(remote, ws);
    connectWebSocketUseCase = ConnectWebSocketUseCase(repo);

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
      _disconnectWebSocket();
    } else if (state == AppLifecycleState.resumed) {
      _reconnectWebSocket();
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

          if (!hasArticleArrived && message.url != null && message.title != null) {
            hasArticleArrived = true;
            isBattleStarting = false;

            // 다이얼로그 닫기
            Navigator.of(context, rootNavigator: true).pop();

            // 타이머 시작 가능 (필요 시 콜백으로 처리)
          }
        });
        scrollToBottom();
      },
      onBattleReady: () => print("배틀 시작 준비 완료"),
      onOpponentFinished: (msg) {
        showTemporaryPopup(context, msg);
      },
      onWaitForOtherPlayer: () {
        showWaitingDialog(context);
      },
      onBothPlayersFinished: () {
        connectWebSocketUseCase.disconnect();
        showResultDialog(context);
      },
      onReceiveRole: (role) {
        myRole = role;
      },
    );

    _isWebSocketConnected = true;
  }

  void _disconnectWebSocket() {
    if (!_isWebSocketConnected) return;
    connectWebSocketUseCase.disconnect();
    _isWebSocketConnected = false;
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
                : message.feedback != null
                ? FeedbackCard(feedback: message.feedback!)
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
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 80,
        left: 30,
        right: 30,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.amber[100],
            child: Text(message, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }

  void showWaitingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("잠시만요!"),
        content: const Text("상대방이 아직 문제를 풀고 있어요.\n조금만 기다려 주세요."),
      ),
    );
  }

  void showResultDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("배틀 종료!"),
        content: const Text("두 플레이어가 모두 문제를 완료했어요.\n결과를 확인해보세요!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("확인"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("채팅방 ${widget.battleRoomId}", style: GoogleFonts.bebasNeue(fontSize: 22, color: Colors.white)),
        backgroundColor: const Color(0xFF69A88D),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            hasArticleArrived
                ? BattleTimerProgressBar(
              onTimerEnd: () {
                print('타이머 종료!');
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
    );
  }
}