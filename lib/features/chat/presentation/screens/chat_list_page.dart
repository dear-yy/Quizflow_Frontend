import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _errorMessage;

  late final GetChatRoomsUseCase getChatRoomsUseCase;
  late final CreateChatRoomUseCase createChatRoomUseCase;
  late final ChatRepository chatRepository;

  @override
  void initState() {
    super.initState();
    _setupDependencies();
    _fetchChatRooms();
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await getChatRoomsUseCase.execute();
      setState(() {
        chats = data;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = "채팅방 불러오기 실패: $error";
        _isLoading = false;
      });
    }
  }

  Future<void> _createChatRoom() async {
    setState(() {
      _isLoading = true;
    });

    try {
      int newQuizroomId = await createChatRoomUseCase.execute();
      await _fetchChatRooms();
      _enterChatRoom(newQuizroomId);
    } catch (error) {
      setState(() {
        _errorMessage = "채팅방 생성 실패: $error";
        _isLoading = false;
      });
    }
  }

  void _enterChatRoom(int quizroomId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          quizroomId: quizroomId,
          getMessagesUseCase: GetMessagesUseCase(chatRepository),
          connectWebSocketUseCase: ConnectWebSocketUseCase(chatRepository),
        ),
      ),
    ).then((_) => _fetchChatRooms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      )
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
                  "${chat["start_date"].split('T')[0]} - 채팅방 ${chat["id"]}",
                  style: GoogleFonts.bebasNeue(fontSize: 20, color: Colors.black87),
                ),
                subtitle: Text(
                  "퀴즈 진행률: ${chat["cnt"]}/3",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChatRoom,
        backgroundColor: const Color(0xFF176560),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }
}
