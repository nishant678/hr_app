import 'package:hr_app/data/network/base_api_services.dart';
import 'package:hr_app/data/network/network_api_services.dart';
import 'package:hr_app/model/salary_slip/salary_slip_model.dart';
import 'package:hr_app/utils/app_url.dart';
import 'salary_slip_api_repository.dart';

class SalarySlipHttpApiRepository implements SalarySlipApiRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  @override
  Future<SalarySlipModel> getPayslip({required int year, required int month}) async {
    final url = '${AppUrl.payslipEndPoint}?year=$year&month=$month';
    final response = await _apiServices.getApi(url);
    if (response is Map && response['data'] is Map) {
      return SalarySlipModel.fromJson(response['data']);
    }
    throw Exception('Failed to fetch payslip');
  }
}
