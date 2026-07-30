class UserProfileModel {
  final int id;
  final int? companyId;
  final String firstName;
  final String? middleName;
  final String? lastName;
  final String? employeeId;
  final String email;
  final String? phone;
  final String? role;
  final String? designationName;
  final String? departmentName;
  final String? profilePhoto;
  final String? dateOfJoining;
  final String? employmentType;
  final String? workLocation;
  final String? reportingManager;
  final String? shift;
  final String? bankName;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? panNumber;
  final String? uanNumber;
  final String? currentAddress;
  final String? permanentAddress;
  final String? education;
  final int? experienceYears;
  final String? skills;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  const UserProfileModel({
    required this.id,
    this.companyId,
    required this.firstName,
    this.middleName,
    this.lastName,
    this.employeeId,
    required this.email,
    this.phone,
    this.role,
    this.designationName,
    this.departmentName,
    this.profilePhoto,
    this.dateOfJoining,
    this.employmentType,
    this.workLocation,
    this.reportingManager,
    this.shift,
    this.bankName,
    this.bankAccountNumber,
    this.ifscCode,
    this.panNumber,
    this.uanNumber,
    this.currentAddress,
    this.permanentAddress,
    this.education,
    this.experienceYears,
    this.skills,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  String get fullName =>
      '$firstName${middleName != null && middleName!.isNotEmpty ? " $middleName" : ""}${lastName != null && lastName!.isNotEmpty ? " $lastName" : ""}'
          .trim();

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      companyId: json['companyId'] is int
          ? json['companyId']
          : int.tryParse(json['companyId']?.toString() ?? ''),
      firstName: json['firstName']?.toString() ?? '',
      middleName: json['middleName']?.toString(),
      lastName: json['lastName']?.toString(),
      employeeId: json['employeeId']?.toString(),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      designationName: json['designationName']?.toString(),
      departmentName: json['departmentName']?.toString(),
      profilePhoto: json['profilePhoto']?.toString(),
      dateOfJoining: json['dateOfJoining']?.toString(),
      employmentType: json['employmentType']?.toString(),
      workLocation: json['workLocation']?.toString(),
      reportingManager: json['reportingManager']?.toString(),
      shift: json['shift']?.toString(),
      bankName: json['bankName']?.toString(),
      bankAccountNumber: json['bankAccountNumber']?.toString(),
      ifscCode: json['ifscCode']?.toString(),
      panNumber: json['panNumber']?.toString(),
      uanNumber: json['uanNumber']?.toString(),
      currentAddress: json['currentAddress']?.toString(),
      permanentAddress: json['permanentAddress']?.toString(),
      education: json['education']?.toString(),
      experienceYears: json['experienceYears'] is int
          ? json['experienceYears'] as int
          : int.tryParse(json['experienceYears']?.toString() ?? ''),
      skills: json['skills']?.toString(),
      emergencyContactName: json['emergencyContactName']?.toString(),
      emergencyContactPhone: json['emergencyContactPhone']?.toString(),
    );
  }
}
