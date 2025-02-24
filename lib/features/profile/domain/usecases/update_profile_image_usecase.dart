import 'dart:io';
import 'package:quizflow_frontend/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileImageUseCase {
  final ProfileRepository repository;

  UpdateProfileImageUseCase(this.repository);

  Future<void> execute(File image) {
    return repository.updateProfileImage(image);
  }
}
