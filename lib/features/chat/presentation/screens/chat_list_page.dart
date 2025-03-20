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
  String? _errorMessage;

  late final GetChatRoomsUseCase getChatRoomsUseCase;
  late final CreateChatRoomUseCase createChatRoomUseCase;
  late final ChatRepository chatRepository;

  bool _isDisposed = false; // ✅ dispose 상태 추적

  @override
  void initState() {
    super.initState();
    _setupDependencies();
    _fetchChatRooms();
  }

  @override
  void dispose() {
    _isDisposed = true; // ✅ 위젯이 제거될 때 `_isDisposed`를 true로 설정
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
    if (_isDisposed) {
      print("❌[ERROR] ChatListPage가 이미 제거됨! setState() 실행 안 함.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await getChatRoomsUseCase.execute();
      if (!mounted) return; // ✅ mounted 체크 추가

      setState(() {
        chats = data;
        _isLoading = false;
      });

      print("📥[DEBUG] 채팅방 불러오기 완료! ${chats.length}개"); // ✅ 몇 개 불러왔는지 확인
    } catch (error) {
      if (!mounted) return; // ✅ mounted 체크 추가

      setState(() {
        _errorMessage = "채팅방 불러오기 실패: $error";
        _isLoading = false;
      });

      print("❌[ERROR] 채팅방 불러오기 실패: $error"); // ✅ 오류 로그 추가
    }
  }

  Future<void> _createChatRoom() async {
    if (_isDisposed) {
      print("❌[ERROR] ChatListPage가 이미 제거됨! 채팅방 생성 요청 중단.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int newQuizroomId = await createChatRoomUseCase.execute();
      if (!mounted) return; // ✅ mounted 체크 추가

      await _fetchChatRooms();
      _enterChatRoom(newQuizroomId);
    } catch (error) {
      if (!mounted) return; // ✅ mounted 체크 추가

      setState(() {
        _errorMessage = "채팅방 생성 실패: $error";
        _isLoading = false;
      });
    }
  }

  void _enterChatRoom(int quizroomId) {
    if (_isDisposed) {
      print("❌[ERROR] ChatListPage가 제거됨! 채팅방 입장 중단.");
      return;
    }

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
      if (!mounted) return; // ✅ mounted 체크 추가
      _fetchChatRooms();
    });
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5), // 텍스트와 진행 바 간격
                    LinearProgressIndicator(
                      value: chat["cnt"] / 3, // 진행률 (0.0 ~ 1.0)
                      backgroundColor: Colors.grey[300], // 진행 바 배경색
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF176560)), // 진행 바 색상
                      minHeight: 8, // 진행 바 높이
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
        onPressed: _createChatRoom,
        backgroundColor: const Color(0xFF176560),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }
}
