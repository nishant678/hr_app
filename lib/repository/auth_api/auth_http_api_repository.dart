import 'package:hr_app/data/network/base_api_services.dart';
import 'package:hr_app/data/network/network_api_services.dart';
import 'package:hr_app/model/user/user_model.dart';
import 'package:hr_app/utils/app_url.dart';
import 'auth_api_repository.dart';

/// Implementation of [AuthApiRepository] for making HTTP requests to the authentication API.
class AuthHttpApiRepository implements AuthApiRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  /// Sends a login request to the authentication API with the provided [data].
  ///
  /// Returns a [UserModel] representing the user data if the login is successful.
  @override
  Future<UserModel> loginApi(dynamic data) async {
    final dynamic response =
        await _apiServices.postApi(AppUrl.loginEndPoint, data);
    if (response is Map<String, dynamic>) {
      return UserModel.fromJson(response);
    }
    if (response is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(response));
    }
    return const UserModel(error: 'Unexpected login response');
  }
}
