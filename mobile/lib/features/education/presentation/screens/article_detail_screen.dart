import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/features/education/domain/entities/article.dart';
import 'package:tirta/features/education/presentation/providers/education_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: CustomScrollView(
        slivers: [
          // Sliver AppBar
          SliverAppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 22.r,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: AppColors.cardBg,
            elevation: 0,
            pinned: true,
          ),

          // Content
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
              style: TextStyle(
                fontSize: 14.sp,
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
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Article article) {
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    article.category!.name,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              // Title
              Text(
                article.title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 12.h),

              // Meta row: author, read time, date
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
              SizedBox(height: 20.h),

              // Divider
              const Divider(color: AppColors.divider, thickness: 1),
              SizedBox(height: 20.h),

              // Content
              _buildRichContent(article.content),
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
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRichContent(String content) {
    final paragraphs = content.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        final trimmed = paragraph.trim();
        if (trimmed.isEmpty) return const SizedBox.shrink();

        // Check for markdown-like heading (lines starting with #)
        if (trimmed.startsWith('### ')) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h, top: 16.h),
            child: Text(
              trimmed.substring(4),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          );
        } else if (trimmed.startsWith('## ')) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h, top: 20.h),
            child: Text(
              trimmed.substring(3),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          );
        } else if (trimmed.startsWith('# ')) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h, top: 24.h),
            child: Text(
              trimmed.substring(2),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }

        // Check for bullet points (lines starting with - or *)
        final lines = trimmed.split('\n');
        if (lines.every(
          (line) => line.trim().startsWith('- ') || line.trim().startsWith('* '),
        )) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines.map((line) {
                final bulletText = line.trim().substring(2);
                return Padding(
                  padding: EdgeInsets.only(bottom: 4.h, left: 8.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          bulletText,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }

        // Regular paragraph
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(
            trimmed,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
              height: 1.7,
            ),
            textAlign: TextAlign.justify,
          ),
        );
      }).toList(),
    );
  }
}
