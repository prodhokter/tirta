import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/features/education/domain/entities/article.dart';

class ArticleCardFeatured extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCardFeatured({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: article.imageUrl != null && article.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrl!,
                      width: double.infinity,
                      height: 180.h,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: double.infinity,
                        height: 180.h,
                        color: AppColors.bgLight,
                        child: Icon(
                          Icons.article_outlined,
                          color: AppColors.textHint,
                          size: 48.r,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 180.h,
                        color: AppColors.bgLight,
                        child: Icon(
                          Icons.article_outlined,
                          color: AppColors.textHint,
                          size: 48.r,
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 180.h,
                      color: AppColors.bgLight,
                      child: Icon(
                        Icons.article_outlined,
                        color: AppColors.textHint,
                        size: 48.r,
                      ),
                    ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & read time row
                  Row(
                    children: [
                      if (article.category != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            article.category!.name,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Icon(
                        Icons.schedule,
                        size: 14.r,
                        color: AppColors.textHint,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${article.readTimeMinutes} ${AppStrings.readTime}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  // Excerpt
                  if (article.excerpt != null && article.excerpt!.isNotEmpty)
                    Text(
                      article.excerpt!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
