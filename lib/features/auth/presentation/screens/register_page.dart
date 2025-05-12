import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:quizflow_frontend/features/auth/presentation/screens/login_page.dart';
import 'package:quizflow_frontend/features/auth/presentation/screens/register_form.dart';

class RegisterPage extends StatelessWidget {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;

  const RegisterPage({
    super.key,
    required this.registerUseCase,
    required this.loginUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로가기 막기
      onPopInvoked: (didPop) {
        debugPrint('뒤로가기 시도됨: 차단됨');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF69A88D),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고
                    Image.asset(
                      'assets/images/logos/transparent_white.png',
                      width: 300,
                    ),
                    const SizedBox(height: 20),

                    // 타이틀
                    Text(
                      'Create Account',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 52,
                        color: const Color(0xFFf3eee6),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 회원가입 폼
                    RegisterForm(
                      registerUseCase: registerUseCase,
                      loginUseCase: loginUseCase,
                    ),

                    const SizedBox(height: 20),

                    // 로그인 페이지로 돌아가기 버튼
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(
                              loginUseCase: loginUseCase,
                              registerUseCase: registerUseCase,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'log in',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
