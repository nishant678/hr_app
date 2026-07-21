import 'package:hr_app/data/network/base_api_services.dart';
import 'package:hr_app/data/network/network_api_services.dart';
import 'package:hr_app/model/expense/expense_model.dart';
import 'package:hr_app/utils/app_url.dart';
import 'expense_api_repository.dart';

class ExpenseHttpApiRepository implements ExpenseApiRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final response = await _apiServices.getApi(AppUrl.myExpensesEndPoint);
    if (response is Map && response['data'] is List) {
      return (response['data'] as List).map((e) => ExpenseModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<ExpenseModel> applyExpense(Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(AppUrl.expensesEndPoint, data);
    if (response is Map && response['data'] is Map) {
      return ExpenseModel.fromJson(response['data']);
    }
    throw Exception('Failed to apply expense');
  }
}
