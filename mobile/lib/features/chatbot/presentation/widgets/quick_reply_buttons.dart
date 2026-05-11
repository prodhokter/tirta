import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_strings.dart';

class QuickReplyButtons extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<String> onTap;

  const QuickReplyButtons({
    super.key,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final quickReplies = [
      AppStrings.quickReplyTBC,
      AppStrings.quickReplySymptoms,
      AppStrings.quickReplyTransmission,
    ];

    return Container(
      height: 40.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: quickReplies.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final reply = quickReplies[index];
          return ActionChip(
            label: Text(
              reply,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            backgroundColor: AppColors.primary.withValues(alpha: 0.05),
            onPressed: isEnabled ? () => onTap(reply) : null,
          );
        },
      ),
    );
  }
}
