import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String? error;
  final bool loading;

  const ChatTextField({
    super.key,
    this.error,
    this.loading = false,
    required this.onSend,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // 좌우 여백 추가
      child: TextField(
        keyboardType: TextInputType.text,
        controller: controller,
        cursorColor: const Color(0xFF69A88D), // 테마 컬러 적용
        textAlignVertical: TextAlignVertical.center,
        minLines: 1,
        maxLines: 4,
        style: GoogleFonts.bebasNeue(fontSize: 18, color: Colors.black87),
        decoration: InputDecoration(
          errorText: error,
          suffixIcon: IconButton(
            onPressed: loading ? null : onSend,
            icon: Icon(
              Icons.send_outlined,
              color: loading ? Colors.grey : const Color(0xFF69A88D),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: const BorderSide(
              color: Color(0xFF69A88D),
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // 내부 여백 추가
          hintText: '메세지를 입력해주세요!',
          hintStyle: GoogleFonts.bebasNeue(fontSize: 16, color: Colors.grey[600]),
        ),
      ),
    );
  }
}