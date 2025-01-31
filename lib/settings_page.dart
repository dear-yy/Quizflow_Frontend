import 'package:flutter/material.dart';
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
  int? _userPk; // user_pk 저장 변수

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // 프로필 정보 가져오기
  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userPk = prefs.getInt('user_pk'); // SharedPreferences에서 user_pk 가져오기

    if (userPk == null) {
      setState(() {
        _errorMessage = "로그인이 필요합니다.";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _userPk = userPk; // 상태에 userPk 저장
    });

    final url = Uri.parse("http://10.0.2.2:8000/users/profile/$userPk/"); // user_pk 적용

    try {
      final response = await http.get(
        url,
        headers: {
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
      } else if (response.statusCode == 404) {
        final errorResponse = json.decode(response.body);
        setState(() {
          _errorMessage = errorResponse['detail'] ?? "알 수 없는 오류 발생";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 화면
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text("로그인 페이지로 이동"),
            ),
          ],
        ),
      )
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
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _image != null
                          ? NetworkImage(_image!)
                          : null,
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nickname: $_nickname",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Score: $_score",
                          style: const TextStyle(fontSize: 16),
                        ),
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
          ],
        ),
      ),
    );
  }
}
