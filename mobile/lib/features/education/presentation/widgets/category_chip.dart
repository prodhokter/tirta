import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tirta/core/constants/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final String? colorHex;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.colorHex,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  Color _parseColor() {
    if (colorHex == null || colorHex!.isEmpty) return AppColors.primary;
    try {
      final hex = colorHex!.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _parseColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && icon!.isNotEmpty) ...[
              if (int.tryParse(icon!) != null)
                Icon(
                  IconData(
                    int.parse(icon!),
                    fontFamily: 'MaterialIcons',
                  ),
                  size: 16.r,
                  color: isSelected ? Colors.white : chipColor,
                )
              else
                Text(
                  icon!,
                  style: TextStyle(fontSize: 16.sp),
                ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
