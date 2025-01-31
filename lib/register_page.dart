import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  String _errorMessage = "";

  Future<void> _register() async {
    final url = Uri.parse("http://10.0.2.2:8000/users/register/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": _usernameController.text,
        "password": _passwordController.text,
        "password2": _password2Controller.text,
        "email": _emailController.text,
      }),
    );

    if (response.statusCode == 201) {
      // 회원가입 성공
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("User registered successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // 로그인 페이지로 이동
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      // 오류 처리
      setState(() {
        _errorMessage = jsonDecode(response.body)["error"] ?? "Registration failed.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF69A88D), // 로그인 페이지와 같은 배경색
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 이미지
              Image.asset(
                'assets/images/logos/transparent_white.png',
                width: 300,
              ),
              SizedBox(height: 20),

              // 타이틀
              Text(
                'Create Account',
                style: GoogleFonts.bebasNeue(
                  fontSize: 52,
                  color: Color(0xFFf3eee6),
                ),
              ),
              SizedBox(height: 20),

              // 입력 필드
              _buildTextField(_usernameController, "Username"),
              _buildTextField(_emailController, "Email"),
              _buildTextField(_passwordController, "Password", obscureText: true),
              _buildTextField(_password2Controller, "Confirm Password", obscureText: true),
              SizedBox(height: 20),

              // 회원가입 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: _register,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF176560),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Register',
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
              SizedBox(height: 20),

              // 오류 메시지
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 스타일 적용된 입력 필드 위젯
  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
        ),
      ),
    );
  }
}