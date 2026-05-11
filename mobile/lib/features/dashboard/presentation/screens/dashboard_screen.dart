import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/features/dashboard/presentation/widgets/greeting_header.dart';
import 'package:tirta/features/dashboard/presentation/widgets/last_examination_card.dart';
import 'package:tirta/features/dashboard/presentation/widgets/feature_shortcut_grid.dart';
import 'package:tirta/features/dashboard/presentation/widgets/featured_articles_section.dart';
import 'package:tirta/features/expert_system/data/datasources/examination_remote_datasource.dart';
import 'package:tirta/features/expert_system/data/models/examination_model.dart';
import 'package:tirta/shared/widgets/tirta_button.dart';

final _lastExaminationProvider = FutureProvider<ExaminationModel?>((ref) async {
  final datasource = ExaminationRemoteDatasource();
  final history = await datasource.getExaminationHistory();
  return history.isNotEmpty ? history.first : null;
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastExamAsync = ref.watch(_lastExaminationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(_lastExaminationProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting header
                const GreetingHeader(),
                SizedBox(height: 20.h),

                // Last examination card
                lastExamAsync.when(
                  data: (exam) => LastExaminationCard(
                    lastExamination: exam,
                  ),
                  loading: () => Container(
                    width: double.infinity,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.divider),
                    ),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  error: (_, __) => const LastExaminationCard(
                    lastExamination: null,
                  ),
                ),
                SizedBox(height: 20.h),

                // CTA Button
                TirtaButton(
                  text: 'Periksa Sekarang',
                  onPressed: () {
                    context.push(AppRoutes.expertSystemIntro);
                  },
                ),
                SizedBox(height: 24.h),

                // Feature shortcuts
                const FeatureShortcutGrid(),
                SizedBox(height: 24.h),

                // Featured articles
                const FeaturedArticlesSection(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
