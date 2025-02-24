import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:quizflow_frontend/features/auth/presentation/screens/register_form.dart';

class RegisterPage extends StatelessWidget {
  final RegisterUseCase registerUseCase;

  const RegisterPage({super.key, required this.registerUseCase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF69A88D), // 기존 배경색 유지
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 이미지
                Image.asset(
                  'assets/images/logos/transparent_white.png', // 로고
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

                // 입력 폼 위젯 (RegisterForm 사용)
                RegisterForm(registerUseCase: registerUseCase),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
