import 'package:hr_app/model/expense/expense_model.dart';

abstract class ExpenseApiRepository {
  Future<List<ExpenseModel>> getExpenses();
  Future<ExpenseModel> applyExpense(Map<String, dynamic> data);
}
