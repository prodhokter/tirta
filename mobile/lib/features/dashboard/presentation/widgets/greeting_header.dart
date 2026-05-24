import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/utils/date_formatter.dart';
import 'package:tirta/shared/services/supabase_service.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final greeting = DateFormatter.getGreeting();
    final today = DateFormatter.formatDate(DateTime.now());
    final userName = SupabaseService.currentUser?.userMetadata?['full_name']
            as String? ??
        'Pengguna';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primary, // Solid soft pastel green
        borderRadius: BorderRadius.circular(28.r), // Very rounded
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting,',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary.withValues(alpha: 0.8), // Dark slate instead of white
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            userName,
            style: TextStyle(
              fontSize: 24.sp, // Slightly larger
              color: AppColors.textPrimary, // Dark slate
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16.r,
                color: AppColors.textPrimary.withValues(alpha: 0.7),
              ),
              SizedBox(width: 6.w),
              Text(
                today,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
