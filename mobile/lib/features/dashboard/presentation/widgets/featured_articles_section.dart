import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/core/constants/app_strings.dart';

class FeaturedArticlesSection extends StatelessWidget {
  const FeaturedArticlesSection({super.key});

  @override
  Widget build(BuildContext context) {
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
              onTap: () => context.go(AppRoutes.education),
              child: Text(
                'Lihat Semua',
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
        SizedBox(
          height: 170.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              return _FeaturedArticleCard(index: index);
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {
  final int index;

  const _FeaturedArticleCard({required this.index});

  static final List<_ArticleData> _articles = [
    _ArticleData(
      title: 'Mengenal TBC: Gejala, Penyebab, dan Cara Pencegahan',
      category: 'Pengantar',
      readTime: '5 menit baca',
      color: AppColors.primary,
    ),
    _ArticleData(
      title: 'Pentingnya Deteksi Dini TBC untuk Pengobatan Efektif',
      category: 'Edukasi',
      readTime: '4 menit baca',
      color: const Color(0xFF009688),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final article = _articles[index];

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.education);
      },
      child: Container(
        width: 260.w,
        padding: EdgeInsets.all(14.r),
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
            // Placeholder image area
            Container(
              width: double.infinity,
              height: 70.h,
              decoration: BoxDecoration(
                color: article.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.article_outlined,
                size: 30.r,
                color: article.color,
              ),
            ),
            SizedBox(height: 10.h),
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
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: article.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    article.category,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: article.color,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  article.readTime,
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
    );
  }
}

class _ArticleData {
  final String title;
  final String category;
  final String readTime;
  final Color color;

  const _ArticleData({
    required this.title,
    required this.category,
    required this.readTime,
    required this.color,
  });
}
