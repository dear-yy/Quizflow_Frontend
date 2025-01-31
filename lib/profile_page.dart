import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _nickname;
  String? _image;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // 프로필 정보 가져오기
  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(token);

    if (token == null) {
      setState(() {
        _errorMessage = "로그인이 필요합니다.";
      });
      return;
    }

    final url = Uri.parse("http://10.0.2.2:8000/users/profile/3/");  // URL에 token 값 추가

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
        });
      } else if (response.statusCode == 404) {
        final errorResponse = json.decode(response.body);
        setState(() {
          _errorMessage = errorResponse['detail'] ?? "알 수 없는 오류 발생";
        });
      } else {
        setState(() {
          _errorMessage = "서버 오류: ${response.statusCode}";
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "네트워크 오류가 발생했습니다.";
        print('Error: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: SafeArea(
        child: Center(
          child: _errorMessage != null
              ? Text(_errorMessage!)  // 오류 메시지 출력
              : _nickname != null && _image != null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(_image!),
              SizedBox(height: 10),
              Text(
                _nickname!,
                style: TextStyle(fontSize: 24),
              ),
            ],
          )
              : CircularProgressIndicator(), // 프로필 정보 로딩 중
        ),
      ),
    );
  }
}
