import 'package:hr_app/model/salary_slip/salary_slip_model.dart';

abstract class SalarySlipApiRepository {
  Future<SalarySlipModel> getPayslip({required int year, required int month});
}
