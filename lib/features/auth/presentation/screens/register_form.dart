import 'package:flutter/material.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/register_usecase.dart';

class RegisterForm extends StatefulWidget {
  final RegisterUseCase registerUseCase;

  const RegisterForm({super.key, required this.registerUseCase});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  String _errorMessage = "";

  // 회원가입 기능 실행
  Future<void> _register() async {
    try {
      bool success = await widget.registerUseCase.execute(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        password2: _password2Controller.text,
      );

      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Success"),
            content: const Text("User registered successfully!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // 로그인 페이지로 이동
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Registration failed.";
      });
    }
  }

  // 스타일 적용된 입력 필드
  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(_usernameController, "Username"),
        _buildTextField(_emailController, "Email"),
        _buildTextField(_passwordController, "Password", obscureText: true),
        _buildTextField(_password2Controller, "Confirm Password", obscureText: true),

        // 회원가입 버튼
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: GestureDetector(
            onTap: _register,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF176560),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
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

        // 오류 메시지
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
