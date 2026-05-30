import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/features/education/data/datasources/article_remote_datasource.dart';
import 'package:tirta/features/education/data/models/article_model.dart';

final _featuredArticlesProvider = FutureProvider.autoDispose<List<ArticleModel>>((ref) async {
  final datasource = ArticleRemoteDatasource();
  return await datasource.getFeaturedArticles();
});

class FeaturedArticlesSection extends ConsumerWidget {
  const FeaturedArticlesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(_featuredArticlesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.featuredArticles,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => context.push(AppRoutes.education),
              child: Text(
                AppStrings.viewAll,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        articlesAsync.when(
          data: (articles) {
            if (articles.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 185.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: articles.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return _FeaturedArticleCard(
                    article: article,
                    onTap: () => context.push(
                      AppRoutes.articleDetail,
                      extra: article.id,
                    ),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 185.h,
            child: Row(
              children: [
                _buildShimmerCard(),
                SizedBox(width: 12.w),
                _buildShimmerCard(),
              ],
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: 260.w,
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.divider),
      ),
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;

  const _FeaturedArticleCard({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _parseColor(article.category?.color);
    final hasImage = article.imageUrl != null && article.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260.w,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(13.r)),
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrl!,
                      width: double.infinity,
                      height: 90.h,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildImagePlaceholder(categoryColor),
                      errorWidget: (_, __, ___) => _buildImagePlaceholder(categoryColor),
                    )
                  : _buildImagePlaceholder(categoryColor),
            ),

            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),

                  // Category + read time
                  Row(
                    children: [
                      if (article.category != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            article.category!.name,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: categoryColor,
                            ),
                          ),
                        ),
                      SizedBox(width: 8.w),
                      Text(
                        '${article.readTimeMinutes} ${AppStrings.readTime}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(Color color) {
    return Container(
      width: double.infinity,
      height: 90.h,
      color: color.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(
        Icons.article_outlined,
        size: 28.r,
        color: color.withValues(alpha: 0.4),
      ),
    );
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return AppColors.primary;
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}
