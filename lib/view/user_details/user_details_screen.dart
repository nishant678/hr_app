import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';
import 'package:hr_app/model/user/user_profile_model.dart';

class UserDetailsScreen extends StatelessWidget {
  final UserProfileModel profile;

  const UserDetailsScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.paddingXXL),
                  _buildSection('Contact', [
                    _infoRow('Email', profile.email),
                    if (profile.phone != null) _infoRow('Phone', profile.phone!),
                    if (profile.emergencyContactName != null) _infoRow('Emergency Contact', profile.emergencyContactName!),
                    if (profile.emergencyContactPhone != null) _infoRow('Emergency Phone', profile.emergencyContactPhone!),
                  ]),
                  SizedBox(height: AppDimensions.paddingXL),
                  _buildSection('Employment', [
                    if (profile.employeeId != null) _infoRow('Employee ID', profile.employeeId!),
                    if (profile.designationName != null) _infoRow('Designation', profile.designationName!),
                    if (profile.departmentName != null) _infoRow('Department', profile.departmentName!),
                    if (profile.dateOfJoining != null) _infoRow('Date of Joining', profile.dateOfJoining!),
                    if (profile.employmentType != null) _infoRow('Employment Type', profile.employmentType!),
                    if (profile.workLocation != null) _infoRow('Work Location', profile.workLocation!),
                    if (profile.reportingManager != null) _infoRow('Reporting Manager', profile.reportingManager!),
                    if (profile.shift != null) _infoRow('Shift', profile.shift!),
                  ]),
                  SizedBox(height: AppDimensions.paddingXL),
                  if (profile.bankName != null || profile.bankAccountNumber != null)
                    _buildSection('Bank Details', [
                      if (profile.bankName != null) _infoRow('Bank Name', profile.bankName!),
                      if (profile.bankAccountNumber != null) _infoRow('Account Number', profile.bankAccountNumber!),
                      if (profile.ifscCode != null) _infoRow('IFSC Code', profile.ifscCode!),
                      if (profile.panNumber != null) _infoRow('PAN', profile.panNumber!),
                      if (profile.uanNumber != null) _infoRow('UAN', profile.uanNumber!),
                    ]),
                  if (profile.bankName != null || profile.bankAccountNumber != null)
                    SizedBox(height: AppDimensions.paddingXL),
                  if (profile.currentAddress != null || profile.education != null)
                    _buildSection('Personal', [
                      if (profile.currentAddress != null) _infoRow('Current Address', profile.currentAddress!),
                      if (profile.permanentAddress != null) _infoRow('Permanent Address', profile.permanentAddress!),
                      if (profile.education != null) _infoRow('Education', profile.education!),
                      if (profile.experienceYears != null) _infoRow('Experience', '${profile.experienceYears} years'),
                      if (profile.skills != null) _infoRow('Skills', profile.skills!),
                    ]),
                  SizedBox(height: AppDimensions.paddingXXL * 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingL,
        40.h,
        AppDimensions.paddingL,
        AppDimensions.paddingXXL,
      ),
      decoration: const BoxDecoration(
        color: AppColors.dashboardHeaderBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44.r,
            backgroundImage: profile.profilePhoto != null && profile.profilePhoto!.isNotEmpty
                ? NetworkImage(profile.profilePhoto!)
                : const AssetImage('assets/profile_icon.png') as ImageProvider,
          ),
          SizedBox(height: AppDimensions.paddingM),
          Text(
            profile.fullName,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (profile.designationName != null)
            Text(
              profile.designationName!,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
          if (profile.employeeId != null)
            Text(
              profile.employeeId!,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.white.withValues(alpha: 0.65),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelL.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.dashboardHeaderBlue,
            ),
          ),
          SizedBox(height: AppDimensions.paddingM),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: AppTextStyles.labelS.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelS.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
