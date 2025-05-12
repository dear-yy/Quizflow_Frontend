import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:quizflow_frontend/features/auth/presentation/screens/register_page.dart';
import 'package:quizflow_frontend/features/home/presentation/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  const LoginPage({super.key, required this.loginUseCase, required this.registerUseCase});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _passwordError = "";

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    setState(() {
      _passwordError = ""; // 에러 초기화
    });

    if (username.isEmpty || password.isEmpty) {
      _setPasswordErrorMessage('아이디와 비밀번호를 입력하세요.');
      return;
    }

    try {
      final responseData = await widget.loginUseCase.execute(username, password);

      if (_isDisposed) return;

      final token = responseData['token'];
      final userPk = responseData['user_pk'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setInt('user_pk', userPk);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (error) {
      _setPasswordErrorMessage(error.toString());
      print(error);
    }
  }

  void _setPasswordErrorMessage(String message) {
    if (!mounted) return;
    setState(() {
      _passwordError = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF69A88D),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logos/transparent_white.png',
                width: 300,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome!',
                style: GoogleFonts.bebasNeue(
                  fontSize: 52,
                  color: const Color(0xFFf3eee6),
                ),
              ),
              Text(
                'Ready to test your knowledge?',
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  color: const Color(0xFFf3eee6),
                ),
              ),
              const SizedBox(height: 50),

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
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Username',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 패스워드 입력
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
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
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                          ),
                        ),
                      ),
                    ),
                    if (_passwordError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 5.0),
                        child: Text(
                          _passwordError,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 로그인 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: _loginUser,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF176560),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
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
              const SizedBox(height: 25),

              // 회원가입 페이지로 이동
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
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
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(registerUseCase: widget.registerUseCase, loginUseCase: widget.loginUseCase),
                        ),
                      );
                    },
                    child: const Text(
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
      ),
    );
  }
}