import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/core/utils/date_formatter.dart';
import 'package:tirta/features/expert_system/data/datasources/examination_remote_datasource.dart';
import 'package:tirta/features/expert_system/data/models/examination_model.dart';
import 'package:tirta/features/history/data/repositories/history_repository_impl.dart';
import 'package:tirta/shared/widgets/tirta_button.dart';
import 'package:tirta/shared/widgets/error_widget.dart' as custom;

class HistoryDetailScreen extends StatefulWidget {
  final String examinationId;

  const HistoryDetailScreen({super.key, required this.examinationId});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  ExaminationModel? _examination;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExamination();
  }

  Future<void> _loadExamination() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = HistoryRepositoryImpl(
        ExaminationRemoteDatasource(),
      );
      final exam = await repository.getExaminationById(widget.examinationId);
      if (mounted) {
        setState(() {
          _examination = exam;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          AppStrings.examinationResult,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
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

    if (_error != null) {
      return custom.TirtaErrorWidget(
        message: _error!,
        onRetry: _loadExamination,
      );
    }

    if (_examination == null) {
      return custom.TirtaErrorWidget(
        message: 'Data pemeriksaan tidak ditemukan',
        onRetry: _loadExamination,
      );
    }

    final exam = _examination!;
    final riskColor = AppColors.getRiskColor(exam.riskLevel);
    final riskLabel = _getRiskLabel(exam.riskLevel);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          // Percentage gauge card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              children: [
                // Percentage circle gauge
                SizedBox(
                  width: 140.r,
                  height: 140.r,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: exam.percentage / 100,
                        strokeWidth: 10.r,
                        backgroundColor: riskColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${exam.percentage.toInt()}%',
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w700,
                                color: riskColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Risk level badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    riskLabel,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: riskColor,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Valid / Tidak Valid
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      exam.isValid
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      size: 18.r,
                      color: exam.isValid ? AppColors.success : AppColors.warning,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      exam.isValid ? 'Hasil Valid' : 'Hasil Tidak Valid',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: exam.isValid ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Conclusion card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 20.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Kesimpulan',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  exam.conclusion,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Detected symptoms card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.coronavirus_outlined,
                      size: 20.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppStrings.detectedSymptoms,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                if (exam.detectedSymptoms.isEmpty)
                  Text(
                    'Tidak ada gejala terdeteksi',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: exam.detectedSymptoms.map((symptom) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          symptom,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Date card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 20.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Pemeriksaan',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      DateFormatter.formatDateTime(exam.createdAt),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Medical disclaimer
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20.r,
                  color: AppColors.warning,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    AppStrings.medicalDisclaimer,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 90.h), // Space for bottom bar
        ],
      ),
    );
  }

  Widget? _buildBottomActions() {
    if (_isLoading || _error != null || _examination == null) return null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TirtaButton(
                text: 'Kembali',
                isOutlined: true,
                onPressed: () => context.pop(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TirtaButton(
                text: AppStrings.retest,
                onPressed: () {
                  context.push(AppRoutes.expertSystemIntro);
                },
              ),
            ),
          ],
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
