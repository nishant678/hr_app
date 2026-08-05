import 'package:hr_app/data/network/base_api_services.dart';
import 'package:hr_app/data/network/network_api_services.dart';
import 'package:hr_app/model/user/user_profile_model.dart';
import 'package:hr_app/utils/app_url.dart';
import 'profile_api_repository.dart';

class ProfileHttpApiRepository implements ProfileApiRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await _apiServices.getApi(AppUrl.profileEndPoint);
    if (response is Map && response['data'] is Map) {
      return UserProfileModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to fetch profile');
  }

  @override
  Future<UserProfileModel> updateProfilePhoto(String imagePath) async {
    final response = await _apiServices.multipartPostApi(
      AppUrl.profilePhotoUpdateEndPoint,
      filePath: imagePath,
      fileField: 'image',
    );
    if (response is Map && response['data'] is Map) {
      return UserProfileModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to update profile photo');
  }
}
