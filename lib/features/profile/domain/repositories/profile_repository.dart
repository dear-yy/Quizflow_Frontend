import 'dart:io'; // ✅ dart:io 패키지 import!

abstract class ProfileRepository {
  Future<Map<String, dynamic>> getProfile();
  Future<void> updateProfileImage(File image);
  Future<void> updateNickname(String newNickname);
  Future<void> deleteAccount();
}