import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizflow_frontend/component/chat_text_field.dart';
import 'package:quizflow_frontend/component/date_divider.dart';
import 'package:quizflow_frontend/component/message.dart';
import 'package:quizflow_frontend/model/message_model.dart';
import 'package:quizflow_frontend/services/web_socket_service.dart';

class ChatPage extends StatefulWidget {
  final int quizroomId;
  const ChatPage({super.key, required this.quizroomId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  WebSocketService? webSocketService;
  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();
  bool isRunning = false;
  String? error;
  List<MessageModel> messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _initializeWebSocket();
  }

  /// ✅ 기존 메시지 불러오기
  /// ✅ 기존 메시지 불러오기
  Future<void> _fetchMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          error = "로그인이 필요합니다.";
        });
        return;
      }

      final url = Uri.parse("http://10.0.2.2:8000/quizroom/${widget.quizroomId}/message_list/");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        final String decodedString = utf8.decode(response.bodyBytes);
        final dynamic decodedData = jsonDecode(decodedString);

        if (decodedData is Map<String, dynamic> && decodedData.containsKey('messages')) {
          final List<dynamic> messageList = decodedData['messages'];

          setState(() {
            messages = messageList.map((message) => MessageModel(
              quizroomId: message['quizroom'],
              message: message['message'],
              isGpt: message['is_gpt'] ?? false, // ✅ is_gpt 반영
              timestamp: DateTime.parse(message['timestamp']),
            )).toList()
              ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // 정렬

            scrollToBottom();
          });
        } else {
          setState(() {
            error = "서버 응답이 올바르지 않습니다.";
          });
        }
      } else {
        setState(() {
          error = "메시지를 불러오는 중 오류 발생: (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        error = "서버에 연결할 수 없습니다.";
      });
    }
  }


  /// ✅ 웹소켓 연결 설정
  Future<void> _initializeWebSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          error = "로그인이 필요합니다.";
        });
        return;
      }

      webSocketService = WebSocketService(
        quizroomId: widget.quizroomId,
        token: token,
      );

      webSocketService!.stream.listen(
            (event) {
          print("📥 [DEBUG] WebSocket 원본 데이터: $event");

          if (event == null || event.toString().trim().isEmpty) {
            print("⚠️ WebSocket에서 받은 데이터가 null 또는 빈 문자열입니다!");
            return;
          }

          try {
            final data = jsonDecode(event);

            // 데이터 구조 확인
            if (data is! Map<String, dynamic>) {
              print("⚠️ 예상치 못한 데이터 형식: $data");
              return;
            }

            if (!data.containsKey('message') || data['message'] == null) {
              print("⚠️ WebSocket 데이터 오류: 'message' 필드가 없습니다.");
              return;
            }

            print("📥 [DEBUG] 파싱된 데이터: $data");

            final newMessage = MessageModel.fromJson(data);

            setState(() {
              messages.add(newMessage);
            });

            scrollToBottom();
          } catch (e, stacktrace) {
            print("❌ WebSocket 데이터 파싱 오류: $e");
            print("🔍 스택 트레이스: $stacktrace");
          }
        },
        onError: (error) {
          print("❌ WebSocket 오류 발생: $error");
          setState(() {
            this.error = "서버 연결 오류";
          });
        },
        cancelOnError: true,
      );

    } catch (e) {
      setState(() {
        error = "서버 연결 실패";
      });
    }
  }

  @override
  void dispose() {
    webSocketService?.disconnect();
    super.dispose();
  }

  void handleSendMessage(String message) {
    if (message.trim().isEmpty) return;

    final msg = MessageModel(
      quizroomId: widget.quizroomId,
      message: message,
      isGpt: false,
      timestamp: DateTime.now(),
    );

    webSocketService?.sendMessage(msg.message);

    setState(() {
      messages.add(msg);
    });

    controller.clear();
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("채팅방 ${widget.quizroomId}"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
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

  Widget buildMessageList() {
    return ListView.separated(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) => buildMessageItem(
        message: messages[index],
        prevMessage: index > 0 ? messages[index - 1] : null,
      ),
      separatorBuilder: (_, __) => SizedBox(height: 16.0),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shouldDrawDateDivider)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: DateDivider(date: message.timestamp),
          ),
        Padding(
          padding: EdgeInsets.only(left: isGpt ? 64.0 : 16.0, right: isGpt ? 16.0 : 64.0),
          child: Message(
            alignLeft: isGpt,
            message: message.message.trim(),
            timestamp: message.timestamp, // ✅ 시간 추가
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
}