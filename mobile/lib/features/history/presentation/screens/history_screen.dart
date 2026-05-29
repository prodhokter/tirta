import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/core/utils/date_formatter.dart';
import 'package:tirta/features/expert_system/data/models/examination_model.dart';
import 'package:tirta/features/history/presentation/providers/history_provider.dart';
import 'package:tirta/shared/widgets/empty_state_widget.dart';
import 'package:tirta/shared/widgets/error_widget.dart' as custom;

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          AppStrings.examinationHistory,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(context, ref, historyState),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    HistoryState state,
  ) {
    // Loading state
    if (state.isLoading && state.examinations.isEmpty) {
      return Center(
        child: SizedBox(
          width: 28.r,
          height: 28.r,
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      );
    }

    // Error state
    if (state.error != null && state.examinations.isEmpty) {
      return custom.TirtaErrorWidget(
        message: state.error!,
        onRetry: () {
          ref.read(historyNotifierProvider.notifier).loadHistory();
        },
      );
    }

    // Empty state
    if (state.isEmpty) {
      return EmptyStateWidget(
        message: AppStrings.emptyHistory,
        icon: Icons.assignment_outlined,
        onAction: () => context.push(AppRoutes.expertSystemIntro),
        actionLabel: AppStrings.startExamination,
      );
    }

    // Loaded state
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.read(historyNotifierProvider.notifier).loadHistory();
      },
      child: ListView.separated(
        padding: EdgeInsets.all(20.r),
        itemCount: state.examinations.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final exam = state.examinations[index];
          return _ExaminationCard(
            examination: exam,
            onTap: () {
              if (exam.id != null) {
                context.push(AppRoutes.historyDetail, extra: exam.id);
              }
            },
            onDismissed: () {
              _showDeleteConfirmation(context, ref, exam);
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    ExaminationModel exam,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.deleteHistory,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppStrings.deleteHistoryConfirm,
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (exam.id != null) {
                ref
                    .read(historyNotifierProvider.notifier)
                    .deleteExamination(exam.id!);
              }
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExaminationCard extends StatelessWidget {
  final ExaminationModel examination;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _ExaminationCard({
    required this.examination,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = AppColors.getRiskColor(examination.riskLevel);
    final riskLabel = _getRiskLabel(examination.riskLevel);

    return Dismissible(
      key: ValueKey(examination.id ?? examination.createdAt.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        onDismissed();
        return false; // We handle deletion in the dialog
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(
          Icons.delete_outline,
          color: AppColors.error,
          size: 24.r,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            children: [
              // Percentage circle
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: riskColor.withValues(alpha: 0.1),
                  border: Border.all(color: riskColor, width: 2.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${examination.percentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 13.sp,
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
                    Row(
                      children: [
                        // Risk level badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            riskLabel,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: riskColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Valid / Tidak Valid badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: examination.isValid
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            examination.isValid ? 'Valid' : 'Tidak Valid',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: examination.isValid
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      DateFormatter.formatDateTime(examination.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20.r,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
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
