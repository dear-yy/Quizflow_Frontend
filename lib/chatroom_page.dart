import 'package:flutter/material.dart';
import 'package:quizflow_frontend/component/chat_text_field.dart';
import 'package:quizflow_frontend/component/date_divider.dart';
import 'package:quizflow_frontend/component/message.dart';
import 'package:quizflow_frontend/model/message_model.dart';

final sampleData = [
  MessageModel(
    id: 1,
    isMine: true,
    message: '오늘 저녁으로 먹을 만한 메뉴 추천해줘!',
    point: 1,
    date: DateTime(2024, 11, 23),
  ),
  MessageModel(
    id: 2,
    isMine: false,
    message: '칼칼한 김치찜은 어때요!?',
    point: null,
    date: DateTime(2024, 11, 23),
  ),
];

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();
  bool isRunning = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(getStringDate(sampleData.first.date!)),
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
              onSend: handleSendMessage,
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }

  handleSendMessage() {}

  void scrollToBottom() {
    if (scrollController.position.pixels != scrollController.position.maxScrollExtent) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget buildMessageList() {
    return ListView.separated(
      controller: scrollController,
      itemCount: sampleData.length,
      itemBuilder: (context, index) => buildMessageItem(
        message: sampleData[index],
        prevMessage: index > 0 ? sampleData[index - 1] : null,
        index: index,
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
    );
  }

  Widget buildMessageItem({
    MessageModel? prevMessage,
    required MessageModel message,
    required int index,
  }) {
    final isMine = message.isMine!;
    final shouldDrawDateDivider = prevMessage == null || shouldDrawDate(prevMessage.date!, message.date!);

    return Column(
      children: [
        if (shouldDrawDateDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: DateDivider(date: message.date!),
          ),
        Padding(
          padding: EdgeInsets.only(left: isMine ? 64.0 : 16.0, right: isMine ? 16.0 : 64.0),
          child: Message(
            alignLeft: !isMine,
            message: message.message!.trim(),
            point: message.point,
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