import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/features/expert_system/presentation/providers/expert_system_provider.dart';
import 'package:tirta/features/expert_system/presentation/widgets/medical_disclaimer_widget.dart';
import 'package:tirta/features/expert_system/presentation/widgets/result_gauge.dart';
import 'package:tirta/features/expert_system/presentation/widgets/symptom_list.dart';
import 'package:tirta/shared/widgets/tirta_button.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expertSystemProvider);
    final result = state.result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.examinationResult),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Tidak ada hasil pemeriksaan'),
        ),
      );
    }

    final riskColor = AppColors.getRiskColor(result.riskLevel);
    final riskLabel = _getRiskLabel(result.riskLevel);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(AppStrings.examinationResult),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    // Gauge
                    ResultGauge(
                      percentage: result.percentage,
                      riskColor: riskColor,
                    ),
                    SizedBox(height: 16.h),
                    // Risk level label
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: riskColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        riskLabel,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: riskColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Valid / Tidak Valid badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: result.isValid
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.textHint.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            result.isValid
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            size: 18.sp,
                            color: result.isValid
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            result.isValid ? 'Valid' : 'Tidak Valid',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: result.isValid
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Score info
                    Text(
                      '${result.score} dari 15 gejala terdeteksi',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Conclusion card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: riskColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: riskColor,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                AppStrings.recommendation,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: riskColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            result.conclusion,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Detected symptoms
                    if (result.detectedSymptoms.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppStrings.detectedSymptoms,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SymptomList(symptoms: result.detectedSymptoms),
                    ],
                    SizedBox(height: 20.h),
                    // Medical disclaimer
                    const MedicalDisclaimerWidget(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            // Bottom buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                children: [
                  TirtaButton(
                    text: AppStrings.retest,
                    onPressed: () {
                      ref
                          .read(expertSystemProvider.notifier)
                          .startExamination();
                      context.pushReplacement(AppRoutes.question);
                    },
                  ),
                  SizedBox(height: 12.h),
                  TirtaButton(
                    text: 'Kembali ke Beranda',
                    isOutlined: true,
                    onPressed: () {
                      context.go(AppRoutes.dashboard);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRiskLabel(String riskLevel) {
    switch (riskLevel) {
      case 'rendah':
        return AppStrings.riskLow;
      case 'sedang':
        return AppStrings.riskMedium;
      case 'tinggi':
        return AppStrings.riskHigh;
      default:
        return AppStrings.riskLow;
    }
  }
}
