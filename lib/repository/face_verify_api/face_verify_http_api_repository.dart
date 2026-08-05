import 'package:hr_app/data/network/base_api_services.dart';
import 'package:hr_app/data/network/network_api_services.dart';
import 'package:hr_app/utils/app_url.dart';
import 'face_verify_api_repository.dart';

class FaceVerifyHttpApiRepository implements FaceVerifyApiRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  @override
  Future<bool> isFaceRegistered() async {
    final response = await _apiServices.getApi(AppUrl.faceStatusEndPoint);
    if (response is Map && response['data'] is Map) {
      return response['data']['registered'] == true;
    }
    return false;
  }

  @override
  Future<void> registerFace(String imagePath) async {
    await _apiServices.multipartPostApi(
      AppUrl.faceRegisterEndPoint,
      filePath: imagePath,
      fileField: 'image',
    );
  }
}