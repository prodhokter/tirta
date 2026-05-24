import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/core/utils/date_formatter.dart';
import 'package:tirta/features/expert_system/data/models/examination_model.dart';

class LastExaminationCard extends StatelessWidget {
  final ExaminationModel? lastExamination;

  const LastExaminationCard({super.key, this.lastExamination});

  @override
  Widget build(BuildContext context) {
    if (lastExamination == null) {
      return _buildEmptyCard(context);
    }

    final exam = lastExamination!;
    final riskColor = AppColors.getRiskColor(exam.riskLevel);
    final riskLabel = _getRiskLabel(exam.riskLevel);

    return GestureDetector(
      onTap: () {
        if (exam.id != null) {
          context.push(AppRoutes.historyDetail, extra: exam.id);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02), // Very soft shadow
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pemeriksaan Terakhir',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20.r,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                // Percentage circle
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: riskColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: riskColor,
                      width: 2.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${exam.percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: riskColor,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Risk level badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          riskLabel,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: riskColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        DateFormatter.formatDateTime(exam.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pemeriksaan Terakhir',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 32.r,
                color: AppColors.textHint,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Belum ada pemeriksaan. Mulai periksa sekarang untuk mengetahui tingkat risiko TBC kamu.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRiskLabel(String riskLevel) {
    switch (riskLevel) {
      case 'sangat_rendah':
        return AppStrings.riskVeryLow;
      case 'rendah':
        return AppStrings.riskLow;
      case 'sedang':
        return AppStrings.riskMedium;
      case 'tinggi':
        return AppStrings.riskHigh;
      case 'sangat_tinggi':
        return AppStrings.riskVeryHigh;
      default:
        return riskLevel;
    }
  }
}
