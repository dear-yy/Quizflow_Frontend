import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quizflow_frontend/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:quizflow_frontend/features/chat/data/datasources/chat_websocket_data_source.dart';
import 'package:quizflow_frontend/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:quizflow_frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:quizflow_frontend/features/chat/domain/usecases/get_chat_rooms_usecase.dart';
import 'package:quizflow_frontend/features/chat/domain/usecases/create_chat_room_usecase.dart';
import 'package:quizflow_frontend/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:quizflow_frontend/features/chat/domain/usecases/connect_websocket_usecase.dart';
import 'package:quizflow_frontend/features/chat/presentation/screens/chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Map<String, dynamic>> chats = [];
  bool _isLoading = false;

  late final GetChatRoomsUseCase getChatRoomsUseCase;
  late final CreateChatRoomUseCase createChatRoomUseCase;
  late final ChatRepository chatRepository;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _setupDependencies();
    _fetchChatRooms();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _setupDependencies() {
    final httpClient = http.Client();
    final chatRemoteDataSource = ChatRemoteDataSource(client: httpClient);
    final chatWebSocketDataSource = ChatWebSocketDataSource();

    chatRepository = ChatRepositoryImpl(
      chatRemoteDataSource,
      chatWebSocketDataSource,
    );

    getChatRoomsUseCase = GetChatRoomsUseCase(chatRepository);
    createChatRoomUseCase = CreateChatRoomUseCase(chatRepository);
  }

  Future<void> _fetchChatRooms() async {
    if (_isDisposed) return;

    setState(() => _isLoading = true);

    try {
      final data = await getChatRoomsUseCase.execute();
      if (!mounted) return;

      setState(() {
        chats = data;
        chats.sort((a, b) =>
            DateTime.parse(b["start_date"]).compareTo(DateTime.parse(a["start_date"])));
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("채팅방 불러오기 실패", error.toString());
    }
  }

  void _enterChatRoom(int quizroomId) {
    if (_isDisposed) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          quizroomId: quizroomId,
          getMessagesUseCase: GetMessagesUseCase(chatRepository),
          connectWebSocketUseCase: ConnectWebSocketUseCase(chatRepository),
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      _fetchChatRooms();
    });
  }

  void _showCreatingChatDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text("채팅방 생성 중..."),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("잠시만 기다려 주세요."),
          ],
        ),
      ),
    );

    _handleCreateChatRoom(context);
  }

  Future<void> _handleCreateChatRoom(BuildContext context) async {
    try {
      int newQuizroomId = await createChatRoomUseCase.execute();
      if (!mounted) return;
      Navigator.pop(context); // 로딩 다이얼로그 닫기

      await _fetchChatRooms();
      _enterChatRoom(newQuizroomId);
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context); // 로딩 다이얼로그 닫기

      final errorMessage = error.toString().replaceFirst("Exception: ", "");

      if (errorMessage.contains("일일 제한 초과")) {
        _showErrorDialog("참가 제한", "오늘은 더 이상 채팅방을 생성할 수 없습니다.\n내일 다시 시도해 주세요.");
      } else {
        _showErrorDialog("채팅방 생성 실패", errorMessage);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return GestureDetector(
            onTap: () => _enterChatRoom(chat["id"]),
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                title: Text(
                  "${chat["start_date"].split('T')[0]}",
                  style: GoogleFonts.bebasNeue(fontSize: 20, color: Colors.black87),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: chat["cnt"] / 3,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF176560)),
                      minHeight: 8,
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatingChatDialog(context),
        backgroundColor: const Color(0xFF176560),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );

  }
}
