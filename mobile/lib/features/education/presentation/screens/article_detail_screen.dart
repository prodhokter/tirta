import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/core/theme/text_styles.dart';
import 'package:tirta/features/education/domain/entities/article.dart';
import 'package:tirta/features/education/presentation/providers/education_provider.dart';
import 'package:tirta/shared/widgets/markdown_renderer.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final String articleId;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  Article? _article;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadArticle();
    });
  }

  Future<void> _loadArticle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final article = await ref
          .read(educationProvider.notifier)
          .getArticleDetail(widget.articleId);
      if (mounted) {
        setState(() {
          _article = article;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  Color _parseCategoryColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return AppColors.primary;
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: AppColors.cardBg.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: AppColors.cardBg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
          ),

          SliverToBoxAdapter(
            child: _isLoading
                ? _buildLoading()
                : _error != null
                    ? _buildError()
                    : _article != null
                        ? _buildContent(_article!)
                        : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: 400.h,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 400.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.r,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              AppStrings.errorGeneric,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadArticle,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Article article) {
    final categoryColor = _parseCategoryColor(article.category?.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero image
        if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: article.imageUrl!,
            width: double.infinity,
            height: 240.h,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: double.infinity,
              height: 240.h,
              color: AppColors.bgLight,
            ),
            errorWidget: (_, __, ___) => Container(
              width: double.infinity,
              height: 240.h,
              color: AppColors.bgLight,
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.textHint,
                size: 48.r,
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 120.h,
            color: categoryColor.withValues(alpha: 0.1),
            alignment: Alignment.center,
            child: Icon(
              Icons.article_outlined,
              size: 40.r,
              color: categoryColor.withValues(alpha: 0.4),
            ),
          ),

        Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              if (article.category != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    article.category!.name,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: categoryColor,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
              ],

              // Title
              Text(
                article.title,
                style: TextStyles.headlineMedium.copyWith(
                  height: 1.3,
                ),
              ),
              SizedBox(height: 14.h),

              // Meta row
              Wrap(
                spacing: 16.w,
                runSpacing: 8.h,
                children: [
                  _buildMetaItem(Icons.person_outline, article.author),
                  _buildMetaItem(
                    Icons.schedule,
                    '${article.readTimeMinutes} ${AppStrings.readTime}',
                  ),
                  if (article.publishedAt != null)
                    _buildMetaItem(
                      Icons.calendar_today_outlined,
                      _formatDate(article.publishedAt),
                    ),
                ],
              ),
              SizedBox(height: 24.h),

              // Divider
              Container(
                height: 1,
                color: AppColors.divider,
              ),
              SizedBox(height: 24.h),

              // Content — uses shared MarkdownRenderer
              MarkdownRenderer(
                text: article.content,
                baseFontSize: 14,
                lineHeight: 1.7,
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.r, color: AppColors.textHint),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyles.caption.copyWith(
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
