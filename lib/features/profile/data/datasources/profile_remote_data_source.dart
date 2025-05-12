// API 요청

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRemoteDataSource {
  final http.Client client;

  ProfileRemoteDataSource({required this.client});

  Future<Map<String, dynamic>> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userPk = prefs.getInt('user_pk');
    String? token = prefs.getString('token');

    if (userPk == null || token == null) {
      throw Exception("로그인이 필요합니다.");
    }

    final url = Uri.parse("http://10.0.2.2:8000/users/profile/$userPk/");
    final response = await client.get(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("프로필 조회 실패: ${response.statusCode}");
    }
  }

  Future<void> updateProfileImage(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userPk = prefs.getInt('user_pk');
    String? token = prefs.getString('token');

    if (userPk == null || token == null) {
      throw Exception("사용자 인증 정보 없음");
    }

    final url = Uri.parse("http://10.0.2.2:8000/users/profile/$userPk/");
    final request = http.MultipartRequest("PUT", url)
      ..headers["Authorization"] = "Token $token"
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception("프로필 이미지 업데이트 실패");
    }
  }

  Future<void> updateNickname(String newNickname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userPk = prefs.getInt('user_pk');
    String? token = prefs.getString('token');

    if (userPk == null || token == null) {
      throw Exception("사용자 인증 정보 없음");
    }

    final url = Uri.parse("http://10.0.2.2:8000/users/profile/$userPk/");
    final response = await client.put(
      url,
      headers: {"Authorization": "Token $token", "Content-Type": "application/json"},
      body: jsonEncode({"nickname": newNickname}),
    );

    if (response.statusCode != 200) {
      throw Exception("닉네임 업데이트 실패");
    }
  }

  Future<void> deleteAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("사용자 인증 정보 없음");
    }

    final url = Uri.parse("http://10.0.2.2:8000/users/account/delete/");
    final response = await client.delete(
      url,
      headers: {"Authorization": "Token $token", "Content-Type": "application/json"},
    );

    if (response.statusCode != 204) {
      throw Exception("계정 삭제 실패");
    }
  }
}
