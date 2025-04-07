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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_image != null ? NetworkImage(_image!) : null) as ImageProvider?,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF176560)),
                    child: const Text("프로필 사진 변경", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("닉네임: $_nickname", style: GoogleFonts.bebasNeue(fontSize: 18)),
            Text("이메일: $_email", style: GoogleFonts.bebasNeue(fontSize: 18)),
            Text("점수: $_score", style: GoogleFonts.bebasNeue(fontSize: 18)),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      String newNickname = "새 닉네임";
                      await _editNickname(newNickname);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF176560)),
                    child: const Text("닉네임 변경", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFe57373)), // 붉은색 로그아웃 버튼
                    child: const Text("로그아웃", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFe5bdb5)),
                    child: const Text("계정 삭제", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Color(0xFFe5bdb5), fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}