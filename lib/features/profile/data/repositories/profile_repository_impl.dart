import 'dart:io';
import 'package:quizflow_frontend/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:quizflow_frontend/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> getProfile() => remoteDataSource.getProfile();

  @override
  Future<void> updateProfileImage(File image) => remoteDataSource.updateProfileImage(image);

  @override
  Future<void> updateNickname(String newNickname) => remoteDataSource.updateNickname(newNickname);

  @override
  Future<void> deleteAccount() => remoteDataSource.deleteAccount();
}
