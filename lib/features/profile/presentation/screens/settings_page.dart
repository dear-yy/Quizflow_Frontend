import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:quizflow_frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:quizflow_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:quizflow_frontend/features/auth/presentation/screens/login_page.dart';
import 'package:quizflow_frontend/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:quizflow_frontend/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:quizflow_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:quizflow_frontend/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:quizflow_frontend/features/profile/domain/usecases/update_profile_image_usecase.dart';
import 'package:quizflow_frontend/features/profile/domain/usecases/update_nickname_usecase.dart';
import 'package:quizflow_frontend/features/profile/domain/usecases/delete_account_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _nickname;
  String? _email;
  String? _image;
  int? _score;
  File? _selectedImage;
  bool _isLoading = true;
  String? _errorMessage;
  final picker = ImagePicker();

  late final GetProfileUseCase getProfileUseCase;
  late final UpdateProfileImageUseCase updateProfileImageUseCase;
  late final UpdateNicknameUseCase updateNicknameUseCase;
  late final DeleteAccountUseCase deleteAccountUseCase;

  @override
  void initState() {
    super.initState();
    _setupDependencies();
    _fetchProfile();
  }

  void _setupDependencies() {
    final httpClient = http.Client();
    final profileRemoteDataSource = ProfileRemoteDataSource(client: httpClient);
    final ProfileRepository profileRepository = ProfileRepositoryImpl(profileRemoteDataSource);

    getProfileUseCase = GetProfileUseCase(profileRepository);
    updateProfileImageUseCase = UpdateProfileImageUseCase(profileRepository);
    updateNicknameUseCase = UpdateNicknameUseCase(profileRepository);
    deleteAccountUseCase = DeleteAccountUseCase(profileRepository);
  }

  Future<void> _fetchProfile() async {
    try {
      final responseData = await getProfileUseCase.execute();
      setState(() {
        _nickname = responseData['nickname'];
        _email = responseData['user']['email'];
        _score = responseData['ranking_score'];
        _isLoading = false;
        _image = responseData['image'];
      });

    } catch (error) {
      setState(() {
        _errorMessage = "프로필 불러오기 실패: $error";
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await updateProfileImageUseCase.execute(_selectedImage!);
      _fetchProfile();
    }
  }

  Future<void> _editNickname(String newNickname) async {
    try {
      await updateNicknameUseCase.execute(newNickname);
      _fetchProfile();
    } catch (error) {
      setState(() {
        _errorMessage = "닉네임 변경 실패: $error";
      });
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await deleteAccountUseCase.execute();
      Navigator.pop(context);
    } catch (error) {
      setState(() {
        _errorMessage = "계정 삭제 실패: $error";
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_pk');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          loginUseCase: LoginUseCase(
            AuthRepositoryImpl(
              AuthRemoteDataSource(client: http.Client()),
            ),
          ),
          registerUseCase: RegisterUseCase(
            AuthRepositoryImpl(
              AuthRemoteDataSource(client: http.Client()),
            ),
          ),
        ),
      ),
          (route) => false,
    );
  }

  Widget _buildProfileRow(String title, String value, {VoidCallback? onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$title: $value", style: GoogleFonts.notoSans(fontSize: 16)),
        if (onEdit != null)
          TextButton(
            onPressed: onEdit,
            child: const Text("변경", style: TextStyle(color: Color(0xFF176560))),
          ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<String?> _showNicknameEditDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("닉네임 변경"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "새 닉네임 입력"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
            TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("변경")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("설정", style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔷 프로필 사진 + 이름
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (_image != null ? NetworkImage(_image!) : null) as ImageProvider?,
                  backgroundColor: Colors.grey[300],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(20),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF176560),
                      child: Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔷 유저 정보 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileRow("닉네임", _nickname ?? "-", onEdit: () async {
                    // 예시 입력창
                    final newNickname = await _showNicknameEditDialog(context);
                    if (newNickname != null && newNickname.trim().isNotEmpty) {
                      await _editNickname(newNickname.trim());
                    }
                  }),
                  const Divider(),
                  _buildProfileRow("이메일", _email ?? "-"),
                  const Divider(),
                  _buildProfileRow("점수", _score?.toString() ?? "0"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔴 액션 버튼들
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildActionButton("로그아웃", Icons.logout, _logout, const Color(0xFFe57373)),
                const SizedBox(height: 12),
                _buildActionButton("계정 삭제", Icons.delete_forever, _deleteAccount, const Color(0xFFe5bdb5)),
              ],
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Color(0xFFe57373), fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
