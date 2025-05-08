import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizflow_frontend/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:quizflow_frontend/features/chat/domain/usecases/connect_websocket_usecase.dart';
import 'package:quizflow_frontend/features/chat/domain/entities/message_model.dart';
import 'package:quizflow_frontend/features/chat/presentation/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final int quizroomId;
  final GetMessagesUseCase getMessagesUseCase;
  final ConnectWebSocketUseCase connectWebSocketUseCase;

  const ChatPage({
    Key? key,
    required this.quizroomId,
    required this.getMessagesUseCase,
    required this.connectWebSocketUseCase,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();
  bool isRunning = false;
  String? error;
  List<MessageModel> messages = [];
  bool _isWebSocketConnected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchMessages();
    _initializeWebSocket();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.connectWebSocketUseCase.disconnect();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  /// ✅ 앱의 라이프사이클 감지하여 웹소켓 연결 제어
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _disconnectWebSocket(); // 앱이 백그라운드로 가면 웹소켓 종료
    } else if (state == AppLifecycleState.resumed) {
      _reconnectWebSocket(); // 앱이 다시 활성화되면 재연결
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final fetchedMessages = await widget.getMessagesUseCase.execute(widget.quizroomId);
      setState(() {
        messages = fetchedMessages;
        scrollToBottom();
      });
    } catch (e) {
      setState(() {
        error = "서버에 연결할 수 없습니다.";
      });
    }
  }

  void _initializeWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        error = "로그인이 필요합니다.";
      });
      return;
    }

    widget.connectWebSocketUseCase.disconnect();
    widget.connectWebSocketUseCase.execute(widget.quizroomId, token, (MessageModel message) {
      setState(() {
        messages.add(message);
      });
      scrollToBottom();
    });

    _isWebSocketConnected = true; // ✅ 웹소켓 연결 상태 업데이트
  }

  /// ✅ 중복 종료 방지: 이미 종료된 상태라면 disconnect() 실행 안 함
  void _disconnectWebSocket() {
    if (!_isWebSocketConnected) return; // 이미 종료된 상태라면 실행 X
    widget.connectWebSocketUseCase.disconnect();
    _isWebSocketConnected = false;
  }

  /// ✅ 재연결 로직: 이미 연결된 상태라면 실행 안 함
  void _reconnectWebSocket() {
    if (_isWebSocketConnected) return; // 이미 연결된 상태라면 실행 X
    _initializeWebSocket();
  }

  void handleSendMessage(String message) {
    if (message.trim().isEmpty) return;
    setState(() {
      messages.add(MessageModel(
        quizroomId: widget.quizroomId,
        message: message,
        isGpt: false,
        timestamp: DateTime.now(),
      ));
    });
    widget.connectWebSocketUseCase.sendMessage(message);
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
    MessageModel? prevMessage,
    required MessageModel message,
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
                ? ArticleCard(title: message.title!, url: message.url!, reason: message.reason)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // 아이콘 색상을 흰색으로 변경
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("채팅방 ${widget.quizroomId}", style: GoogleFonts.bebasNeue(fontSize: 22, color: Colors.white)),
        backgroundColor: const Color(0xFF69A88D),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
