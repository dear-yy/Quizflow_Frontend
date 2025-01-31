import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizflow_frontend/login_success.dart';
import 'package:quizflow_frontend/register_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      // 필수 입력값이 비어있으면 에러 메시지 출력
      _showError('이메일과 패스워드를 입력하세요');
      return;
    }

    final url = Uri.parse("http://10.0.2.2:8000/users/login/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        // 로그인 성공: 토큰 받기
        final responseData = json.decode(response.body);
        final token = responseData['token'];

        // 토큰을 받았다면 성공 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginSuccessPage()),
        );
      } else {
        // 로그인 실패: 에러 메시지
        final errorResponse = json.decode(response.body);
        String errorMessage = '로그인 실패';
        if (errorResponse.containsKey('detail')) {
          errorMessage = errorResponse['detail'];
        }
        _showError(errorMessage);
      }
    } catch (error) {
  // 에러의 세부 정보를 출력
  print('Error: $error');
  _showError('네트워크 오류가 발생했습니다');
  }
}

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('오류'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF69A88D),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logos/transparent_white.png',
                width: 300,
              ),
              SizedBox(height: 20),
              Text(
                  'Welcome!',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 52,
                    color: Color(0xFFf3eee6),
                  )
              ),

              Text(
                  'Ready to test your knowledge?',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    color: Color(0xFFf3eee6),
                  )
              ),
              SizedBox(height: 50),

              // 사용자 이름 입력
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Username',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // 패스워드 입력
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // 로그인 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: _loginUser,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF176560),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),

              // 회원가입 페이지로 이동
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      ' Register now',
                      style: TextStyle(
                        color: Color(0xFFe5bdb5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}