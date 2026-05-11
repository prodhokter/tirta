import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';

class FeatureShortcutGrid extends StatelessWidget {
  const FeatureShortcutGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      _ShortcutItem(
        icon: Icons.medical_services_outlined,
        label: 'Sistem Pakar',
        description: 'Skirining TBC',
        color: AppColors.primary,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        onTap: () => context.go(AppRoutes.expertSystemIntro),
      ),
      _ShortcutItem(
        icon: Icons.chat_outlined,
        label: 'Chatbot AI',
        description: 'Tanya jawab',
        color: const Color(0xFF009688),
        backgroundColor: const Color(0xFF009688).withValues(alpha: 0.1),
        onTap: () => context.go(AppRoutes.chat),
      ),
      _ShortcutItem(
        icon: Icons.menu_book_outlined,
        label: 'Edukasi',
        description: 'Artikel TBC',
        color: const Color(0xFF388E3C),
        backgroundColor: const Color(0xFF388E3C).withValues(alpha: 0.1),
        onTap: () => context.go(AppRoutes.education),
      ),
      _ShortcutItem(
        icon: Icons.history_outlined,
        label: 'Riwayat',
        description: 'Hasil periksa',
        color: const Color(0xFFF57C00),
        backgroundColor: const Color(0xFFF57C00).withValues(alpha: 0.1),
        onTap: () => context.go(AppRoutes.history),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.5,
      ),
      itemCount: shortcuts.length,
      itemBuilder: (context, index) {
        final item = shortcuts[index];
        return _ShortcutCard(item: item);
      },
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final _ShortcutItem item;

  const _ShortcutCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: item.backgroundColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                size: 20.r,
                color: item.color,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutItem {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ShortcutItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });
}
