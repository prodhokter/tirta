import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/features/expert_system/presentation/providers/expert_system_provider.dart';
import 'package:tirta/features/expert_system/presentation/widgets/medical_disclaimer_widget.dart';
import 'package:tirta/shared/widgets/tirta_button.dart';

class ExpertSystemIntroScreen extends ConsumerWidget {
  const ExpertSystemIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(AppStrings.expertSystem),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 24.h),
                      // Icon
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.health_and_safety_rounded,
                          size: 60.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      // Title
                      Text(
                        'Skrining Dini TBC',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      // Description
                      Text(
                        AppStrings.startExaminationDesc,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32.h),
                      // Info cards
                      _buildInfoCard(
                        icon: Icons.assignment_outlined,
                        title: '15 Pertanyaan',
                        description:
                            'Pertanyaan terkait gejala utama, gejala pendukung, faktor risiko, dan gejala tambahan TBC',
                      ),
                      SizedBox(height: 12.h),
                      _buildInfoCard(
                        icon: Icons.speed_outlined,
                        title: 'Waktu ~3 Menit',
                        description:
                            'Jawab dengan Ya atau Tidak berdasarkan kondisi yang kamu alami',
                      ),
                      SizedBox(height: 12.h),
                      _buildInfoCard(
                        icon: Icons.analytics_outlined,
                        title: 'Hasil Segera',
                        description:
                            'Sistem akan menganalisis jawaban menggunakan metode forward chaining',
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              // Medical disclaimer
              const MedicalDisclaimerWidget(),
              SizedBox(height: 16.h),
              // Start button
              TirtaButton(
                text: AppStrings.startExamination,
                onPressed: () {
                  ref
                      .read(expertSystemProvider.notifier)
                      .startExamination();
                  context.push(AppRoutes.question);
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
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
    );
  }
}
