import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tirta/core/constants/app_colors.dart';

class TirtaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final double? width;
  final double? height;

  const TirtaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 20.h,
            width: 20.h,
            child: const CircularProgressIndicator(
              color: AppColors.textPrimary, // Dark spinner
              strokeWidth: 2,
            ),
          )
        : Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          );

      final style = isOutlined
          ? OutlinedButton.styleFrom(
              foregroundColor: color ?? AppColors.primaryDark, // Darker color for outline
              side: BorderSide(color: color ?? AppColors.primary),
              minimumSize: Size(width ?? double.infinity, height ?? 52.h), // Slightly taller
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r), // Very rounded
              ),
            )
          : ElevatedButton.styleFrom(
              backgroundColor: color ?? AppColors.primary,
              foregroundColor: AppColors.textPrimary, // Dark slate on pastel
              disabledBackgroundColor: AppColors.textHint,
              elevation: 0, // Flat style
              minimumSize: Size(width ?? double.infinity, height ?? 52.h), // Slightly taller
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r), // Very rounded
              ),
            );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: child,
    );
  }
}
