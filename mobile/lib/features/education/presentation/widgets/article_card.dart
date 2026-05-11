import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/features/education/domain/entities/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 90.w,
                    height: 90.w,
                    color: AppColors.bgLight,
                    child: Icon(
                      Icons.article_outlined,
                      color: AppColors.textHint,
                      size: 32.r,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 90.w,
                    height: 90.w,
                    color: AppColors.bgLight,
                    child: Icon(
                      Icons.article_outlined,
                      color: AppColors.textHint,
                      size: 32.r,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.article_outlined,
                  color: AppColors.textHint,
                  size: 32.r,
                ),
              ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  if (article.category != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        article.category!.name,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  SizedBox(height: 6.h),
                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // Excerpt
                  if (article.excerpt != null && article.excerpt!.isNotEmpty)
                    Text(
                      article.excerpt!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 6.h),
                  // Read time
                  Row(
                    children: [
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
