import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizflow_frontend/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _nickname;
  String? _image;
  String? _email;
  String? _id;
  int? _score;
  String? _errorMessage;
  bool _isLoading = true;
  int? _userPk;
  File? _selectedImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // ✅ 프로필 정보 가져오기
  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userPk = prefs.getInt('user_pk');
    String? token = prefs.getString('token');

    if (userPk == null || token == null) {
      setState(() {
        _errorMessage = "로그인이 필요합니다.";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _userPk = userPk;
    });

    final url = Uri.parse("http://10.0.2.2:8000/users/profile/$userPk/");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Token $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _nickname = responseData['nickname'];
          _image = responseData['image'];
          _email = responseData['email'] ?? "이메일 없음";
          _id = responseData['id']?.toString() ?? "ID 없음";
          _score = responseData['score'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "서버 오류: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "네트워크 오류가 발생했습니다.";
        _isLoading = false;
      });
    }
  }

  // ✅ 이미지 선택 및 업로드
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print("✅ 선택한 이미지 경로: ${pickedFile.path}"); // 경로 출력
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      await _updateProfileImage();
    } else {
      print("❌ 이미지 선택이 취소됨");
    }
  }


  // ✅ 닉네임 변경 다이얼로그
  Future<void> _editNickname() async {
    TextEditingController nicknameController = TextEditingController(text: _nickname);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("닉네임 변경"),
          content: TextField(
            controller: nicknameController,
            decoration: const InputDecoration(hintText: "새 닉네임 입력"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                await _updateProfileNickname(nicknameController.text);
                Navigator.pop(context);
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

  // ✅ 닉네임 변경 API 호출
  Future<void> _updateProfileNickname(String newNickname) async {
    if (_userPk == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("❌ 토큰 없음");
      return;
    }

    var url = Uri.parse("http://10.0.2.2:8000/users/profile/$_userPk/");
    var request = http.MultipartRequest("PUT", url);
    request.headers["Authorization"] = "Token $token";
    request.fields["nickname"] = newNickname;

    var response = await request.send();

    if (response.statusCode == 200) {
      print("✅ 닉네임 업데이트 성공!");
      _fetchProfile(); // UI 업데이트
    } else {
      print("❌ 오류 발생: ${response.statusCode}");
    }
  }

  // ✅ 프로필 이미지 변경 API 호출
  Future<void> _updateProfileImage() async {
    if (_selectedImage == null || _userPk == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("❌ 토큰 없음");
      return;
    }

    var url = Uri.parse("http://10.0.2.2:8000/users/profile/$_userPk/");
    var request = http.MultipartRequest("PUT", url);
    request.headers["Authorization"] = "Token $token";

    // ✅ 필드 이름을 서버와 일치시키기
    request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString(); // 응답 내용을 문자열로 변환

    if (response.statusCode == 200) {
      print("✅ 프로필 이미지 업데이트 성공!");
      _fetchProfile(); // UI 업데이트
    } else {
      print("❌ 오류 발생: ${response.statusCode}");
      print("🔹 서버 응답: $responseBody"); // 서버가 반환한 메시지 출력
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (_image != null ? NetworkImage(_image!) : null) as ImageProvider?,
                          backgroundColor: Colors.grey[300],
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 15,
                              child: Icon(Icons.edit, size: 18, color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Nickname: $_nickname",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: _editNickname,
                              child: const Icon(Icons.edit, size: 18, color: Colors.blue),
                            ),
                          ],
                        ),
                        Text("Score: $_score", style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text("Email: $_email"),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text("ID: $_id"),
            ),


            const SizedBox(height: 20),
            ElevatedButton(
            onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('token'); // 토큰 삭제 (로그아웃)
            await prefs.remove('user_pk'); // user_pk 삭제

            if (mounted) {
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            );
            }
            },
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text("Logout"),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('token'); // 토큰 삭제 (로그아웃)
                await prefs.remove('user_pk'); // user_pk 삭제

                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text("delete ID"),
            ),
          ],
        ),
      ),
    );
  }
}
