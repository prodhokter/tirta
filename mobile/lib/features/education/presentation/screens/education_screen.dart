import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/features/education/presentation/providers/education_provider.dart';
import 'package:tirta/features/education/presentation/widgets/article_card.dart';
import 'package:tirta/features/education/presentation/widgets/article_card_featured.dart';
import 'package:tirta/features/education/presentation/widgets/category_chip.dart';
import 'package:tirta/features/education/presentation/widgets/search_bar_widget.dart';
import 'package:tirta/shared/widgets/empty_state_widget.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final notifier = ref.read(educationProvider.notifier);
    await Future.wait([
      notifier.loadCategories(),
      notifier.loadFeaturedArticles(),
      notifier.loadArticles(),
    ]);
  }

  Future<void> _onRefresh() async {
    final notifier = ref.read(educationProvider.notifier);
    await Future.wait([
      notifier.loadCategories(),
      notifier.loadFeaturedArticles(),
      notifier.loadArticles(),
    ]);
  }

  void _navigateToDetail(String articleId) {
    context.push(AppRoutes.articleDetail, extra: articleId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(educationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                children: [
                  Text(
                    'Edukasi TBC',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primary,
                    size: 28.r,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SearchBarWidget(
                onChanged: (query) {
                  ref.read(educationProvider.notifier).searchArticles(query);
                },
              ),
            ),
            SizedBox(height: 16.h),

            // Category chips
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: state.categories.length + 1,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return CategoryChip(
                      label: AppStrings.allCategories,
                      isSelected: state.selectedCategory == null,
                      onTap: () {
                        ref
                            .read(educationProvider.notifier)
                            .selectCategory(null);
                      },
                    );
                  }
                  final category = state.categories[index - 1];
                  return CategoryChip(
                    label: category.name,
                    colorHex: category.color,
                    icon: category.icon,
                    isSelected: state.selectedCategory == category.slug,
                    onTap: () {
                      ref
                          .read(educationProvider.notifier)
                          .selectCategory(category.slug);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),

            // Content
            Expanded(
              child: state.isLoading
                  ? _buildShimmer()
                  : state.error != null
                      ? _buildError(state.error!)
                      : state.articles.isEmpty
                          ? const EmptyStateWidget(
                              message: AppStrings.emptyArticles,
                              icon: Icons.article_outlined,
                            )
                          : RefreshIndicator(
                              onRefresh: _onRefresh,
                              color: AppColors.primary,
                              child: ListView(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                children: [
                                  // Featured articles section
                                  if (state.featuredArticles.isNotEmpty &&
                                      state.selectedCategory == null &&
                                      state.searchQuery.isEmpty) ...[
                                    Text(
                                      AppStrings.featuredArticles,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    ...state.featuredArticles.map(
                                      (article) => ArticleCardFeatured(
                                        article: article,
                                        onTap: () =>
                                            _navigateToDetail(article.id),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    const Divider(color: AppColors.divider),
                                    SizedBox(height: 12.h),
                                  ],

                                  // All articles
                                  ...state.articles
                                      .where((a) => !state.featuredArticles
                                          .any((f) => f.id == a.id))
                                      .map(
                                        (article) => ArticleCard(
                                          article: article,
                                          onTap: () =>
                                              _navigateToDetail(article.id),
                                        ),
                                      ),

                                  SizedBox(height: 20.h),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: [
        // Featured shimmer
        _shimmerBlock(width: double.infinity, height: 200.h),
        SizedBox(height: 16.h),
        _shimmerBlock(width: double.infinity, height: 90.h),
        SizedBox(height: 12.h),
        _shimmerBlock(width: double.infinity, height: 90.h),
        SizedBox(height: 12.h),
        _shimmerBlock(width: double.infinity, height: 90.h),
      ],
    );
  }

  Widget _shimmerBlock({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
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
            SizedBox(
              width: 200.w,
              child: ElevatedButton(
                onPressed: _onRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
