import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/components/app_app_bar.dart';
import 'package:hr_app/configs/components/shimmer_loading.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';
import 'package:hr_app/model/asset/asset_model.dart';
import 'package:hr_app/repository/asset_api/asset_http_api_repository.dart';

class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  final _assetRepo = AssetHttpApiRepository();
  List<AssetModel> _assets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    setState(() => _loading = true);
    try {
      final data = await _assetRepo.getMyAssets();
      if (mounted) setState(() => _assets = data);
    } catch (e) {
      debugPrint('Failed to load assets: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ASSIGNED':
        return AppColors.success;
      case 'AVAILABLE':
        return AppColors.warning;
      case 'DAMAGED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _assetIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'laptop':
        return Icons.computer;
      case 'mobile':
      case 'phone':
        return Icons.phone_android;
      case 'tablet':
        return Icons.tablet;
      case 'vehicle':
      case 'car':
        return Icons.directions_car;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_loading) {
      bodyContent = const AppShimmer(child: ListShimmer(itemCount: 5, withBadge: true));
    } else if (_assets.isEmpty) {
      bodyContent = ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 64.sp, color: AppColors.textSecondary),
                SizedBox(height: 16.h),
                Text('No assets assigned',
                    style: AppTextStyles.bodyL
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      );
    } else {
      bodyContent = RefreshIndicator(
        onRefresh: _fetchAssets,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          itemCount: _assets.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final asset = _assets[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            _assetIcon(asset.type),
                            color: AppColors.primary,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(asset.name,
                                  style: AppTextStyles.labelL
                                      .copyWith(fontWeight: FontWeight.w600)),
                              if (asset.model != null || asset.brand != null)
                                Text(
                                  '${asset.brand ?? ""} ${asset.model ?? ""}'
                                      .trim(),
                                  style: AppTextStyles.bodyS.copyWith(
                                      color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _statusColor(asset.status)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            asset.status,
                            style: AppTextStyles.labelS.copyWith(
                              color: _statusColor(asset.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Divider(height: 1, color: AppColors.divider),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        if (asset.assetTag != null)
                          _infoChip('Tag', asset.assetTag!),
                        if (asset.serialNumber != null)
                          _infoChip('S/N', asset.serialNumber!),
                        if (asset.assignedDate != null)
                          _infoChip('Since', asset.assignedDate!),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppAppBar(title: 'My Assets', showBackButton: true),
      body: bodyContent,
    );
  }

  Widget _infoChip(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelS
                  .copyWith(color: AppColors.textSecondary)),
          SizedBox(height: 2.h),
          Text(value,
              style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
