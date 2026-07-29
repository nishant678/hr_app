class SalarySlipModel {
  final String employeeName;
  final String employeeId;
  final String designation;
  final String department;
  final int year;
  final int month;
  final String monthName;

  final double basicSalary;
  final double hra;
  final double conveyance;
  final double medical;
  final double specialAllowance;
  final double grossEarnings;

  final double pf;
  final double esi;
  final double professionalTax;
  final double tds;
  final double totalDeductions;

  final double netPay;
  final String netPayInWords;

  final String bankName;
  final String bankAccountNumber;
  final String ifscCode;
  final String panNumber;
  final String uanNumber;

  const SalarySlipModel({
    required this.employeeName,
    required this.employeeId,
    required this.designation,
    required this.department,
    required this.year,
    required this.month,
    required this.monthName,
    required this.basicSalary,
    required this.hra,
    required this.conveyance,
    required this.medical,
    required this.specialAllowance,
    required this.grossEarnings,
    required this.pf,
    required this.esi,
    required this.professionalTax,
    required this.tds,
    required this.totalDeductions,
    required this.netPay,
    required this.netPayInWords,
    required this.bankName,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.panNumber,
    required this.uanNumber,
  });

  factory SalarySlipModel.fromJson(Map<String, dynamic> json) {
    return SalarySlipModel(
      employeeName: json['employeeName']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      year: json['year'] is int ? json['year'] : int.tryParse(json['year'].toString()) ?? 0,
      month: json['month'] is int ? json['month'] : int.tryParse(json['month'].toString()) ?? 0,
      monthName: json['monthName']?.toString() ?? '',
      basicSalary: _toDouble(json['basicSalary']),
      hra: _toDouble(json['hra']),
      conveyance: _toDouble(json['conveyance']),
      medical: _toDouble(json['medical']),
      specialAllowance: _toDouble(json['specialAllowance']),
      grossEarnings: _toDouble(json['grossEarnings']),
      pf: _toDouble(json['pf']),
      esi: _toDouble(json['esi']),
      professionalTax: _toDouble(json['professionalTax']),
      tds: _toDouble(json['tds']),
      totalDeductions: _toDouble(json['totalDeductions']),
      netPay: _toDouble(json['netPay']),
      netPayInWords: json['netPayInWords']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      bankAccountNumber: json['bankAccountNumber']?.toString() ?? '',
      ifscCode: json['ifscCode']?.toString() ?? '',
      panNumber: json['panNumber']?.toString() ?? '',
      uanNumber: json['uanNumber']?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v != null) return double.tryParse(v.toString()) ?? 0.0;
    return 0.0;
  }
}
