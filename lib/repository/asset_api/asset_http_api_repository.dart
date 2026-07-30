import 'package:hr_app/data/network/base_api_services.dart';
import 'package:hr_app/data/network/network_api_services.dart';
import 'package:hr_app/model/asset/asset_model.dart';
import 'package:hr_app/utils/app_url.dart';
import 'asset_api_repository.dart';

class AssetHttpApiRepository implements AssetApiRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  @override
  Future<List<AssetModel>> getMyAssets() async {
    final response = await _apiServices.getApi(AppUrl.myAssetsEndPoint);
    if (response is Map && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => AssetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch assets');
  }
}
