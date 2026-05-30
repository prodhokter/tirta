import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tirta/core/constants/app_colors.dart';

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
      ('Apa itu TBC?', Icons.help_outline),
      ('Gejala TBC', Icons.healing_outlined),
      ('Cara penularan TBC', Icons.air),
      ('Pengobatan TBC', Icons.medical_services_outlined),
      ('Pencegahan TBC', Icons.shield_outlined),
      ('Nutrisi penderita TBC', Icons.restaurant),
      ('TBC MDR / kebal obat', Icons.warning_amber_outlined),
      ('TBC pada anak', Icons.child_care_outlined),
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Padding(
            padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
            child: Text(
              'Saran pertanyaan:',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textHint,
              ),
            ),
          ),
          SizedBox(
            height: 34.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: quickReplies.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final reply = quickReplies[index];
                return _QuickReplyChip(
                  label: reply.$1,
                  icon: reply.$2,
                  isEnabled: isEnabled,
                  onTap: () => onTap(reply.$1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _QuickReplyChip({
    required this.label,
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(17.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.bgLight,
            borderRadius: BorderRadius.circular(17.r),
            border: Border.all(
              color: isEnabled
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.divider,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color: isEnabled ? AppColors.primary : AppColors.textHint,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isEnabled ? AppColors.primaryDark : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
