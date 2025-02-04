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
    _fetchMessages(); // ✅ 기존 메시지 불러오기
    _initializeWebSocket();
  }

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
        final dynamic decodedData = jsonDecode(response.body);

        // ✅ 응답이 Map인지 확인 후 'messages' 키에서 리스트 추출
        if (decodedData is Map<String, dynamic> && decodedData.containsKey('messages')) {
          final List<dynamic> messageList = decodedData['messages']; // ✅ 메시지 리스트 추출

          setState(() {
            messages = parseMessages(messageList);
            messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          });
        } else {
          setState(() {
            error = "서버 응답이 올바르지 않습니다.";
          });
        }
      } else if (response.statusCode == 404) {
        print("❌ [404] 메시지 리스트 API를 찾을 수 없습니다.");
        setState(() {
          error = "존재하지 않는 채팅방입니다.";
        });
      } else {
        print("❌ 메시지 불러오기 실패: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}");
        setState(() {
          error = "메시지를 불러오는 중 오류가 발생했습니다. (${response.statusCode})";
        });
      }
    } catch (e) {
      print("❌ 메시지 불러오는 중 예외 발생: $e");
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

      // ✅ 웹소켓 메시지 수신
      webSocketService!.stream.listen(
            (event) {
          final data = jsonDecode(event);
          if (data.containsKey('message')) {
            setState(() {
              messages.add(MessageModel.fromJson(data));
              messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            });
            scrollToBottom();
          }
        },
        onError: (error) {
          print("웹소켓 오류 발생: $error");
          setState(() {
            this.error = "서버에 연결할 수 없습니다.";
          });
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("웹소켓 초기화 오류: $e");
      setState(() {
        error = "서버에 연결할 수 없습니다.";
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
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });

    controller.clear();
    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
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
            Expanded(
              child: buildMessageList(),
            ),
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
        index: index,
      ),
      separatorBuilder: (_, __) => SizedBox(height: 16.0),
    );
  }

  Widget buildMessageItem({
    MessageModel? prevMessage,
    required MessageModel message,
    required int index,
  }) {
    final isGpt = message.isGpt;
    final shouldDrawDateDivider =
        prevMessage == null || shouldDrawDate(prevMessage.timestamp, message.timestamp);

    return Column(
      children: [
        if (shouldDrawDateDivider)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: DateDivider(date: message.timestamp),
          ),
        Padding(
          padding: EdgeInsets.only(left: isGpt ? 64.0 : 16.0, right: isGpt ? 16.0 : 64.0),
          child: Message(
            alignLeft: isGpt,
            message: message.message.trim(), // ❌ JSON 전체가 출력될 가능성 있음
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
