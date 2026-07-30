import 'package:hr_app/model/asset/asset_model.dart';

abstract class AssetApiRepository {
  Future<List<AssetModel>> getMyAssets();
}
