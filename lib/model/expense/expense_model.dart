class ExpenseModel {
  final int id;
  final String expenseType;
  final double amount;
  final String expenseDate;
  final String? description;
  final String? attachmentUrl;
  final String status;
  final String? rejectionReason;
  final int userId;
  final String userEmail;
  final String userName;

  const ExpenseModel({
    required this.id,
    required this.expenseType,
    required this.amount,
    required this.expenseDate,
    this.description,
    this.attachmentUrl,
    required this.status,
    this.rejectionReason,
    required this.userId,
    required this.userEmail,
    required this.userName,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      expenseType: json['expenseType']?.toString() ?? '',
      amount: (json['amount'] is double ? json['amount'] : double.tryParse(json['amount'].toString())) ?? 0.0,
      expenseDate: json['expenseDate']?.toString() ?? '',
      description: json['description']?.toString(),
      attachmentUrl: json['attachmentUrl']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      rejectionReason: json['rejectionReason']?.toString(),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId'].toString()) ?? 0,
      userEmail: json['userEmail']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
    );
  }
}
