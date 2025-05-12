import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:quizflow_frontend/features/auth/presentation/screens/login_page.dart';

class RegisterForm extends StatefulWidget {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  
  const RegisterForm({
    super.key, 
    required this.registerUseCase,
    required this.loginUseCase,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();

  String _usernameError = "";
  String _emailError = "";
  String _passwordError = "";
  String _password2Error = "";

  Future<void> _register() async {
    setState(() {
      // 오류 메시지 초기화
      _usernameError = "";
      _emailError = "";
      _passwordError = "";
      _password2Error = "";
    });

    try {
      final success = await widget.registerUseCase.execute(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        password2: _password2Controller.text,
      );

      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("회원가입 성공"),
            content: const Text("계정이 성공적으로 생성되었습니다."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        loginUseCase: widget.loginUseCase,
                        registerUseCase: widget.registerUseCase,
                      ),
                    ),
                        (route) => false,
                  );
                },
                child: const Text("확인"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      try {
        final errorBody = json.decode(e.toString().replaceAll("Exception: ", ""));
        setState(() {
          _usernameError = (errorBody["username"] ?? []).join(", ");
          _emailError = (errorBody["email"] ?? []).join(", ");
          _passwordError = (errorBody["password"] ?? []).join(", ");
          _password2Error = (errorBody["password2"] ?? []).join(", ");
        });
      } catch (_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("회원가입 실패"),
            content: Text(e.toString().replaceAll("Exception: ", "")),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("확인"),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                ),
              ),
            ),
          ),
          if (errorText != null && errorText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 5.0),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _usernameController,
            hintText: "Username",
            errorText: _usernameError,
          ),
          _buildTextField(
            controller: _emailController,
            hintText: "Email",
            errorText: _emailError,
          ),
          _buildTextField(
            controller: _passwordController,
            hintText: "Password",
            obscureText: true,
            errorText: _passwordError,
          ),
          _buildTextField(
            controller: _password2Controller,
            hintText: "Confirm Password",
            obscureText: true,
            errorText: _password2Error,
          ),

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
        ],
      ),
    );
  }
}