import 'package:hr_app/model/user/user_profile_model.dart';

abstract class ProfileApiRepository {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfilePhoto(String imagePath);
}
