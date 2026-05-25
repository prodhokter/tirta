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
        description: 'Skrining awal',
        color: const Color(0xFF1E293B), // Dark icon
        backgroundColor: AppColors.cardBlue,
        onTap: () => context.go(AppRoutes.expertSystemIntro),
      ),
      _ShortcutItem(
        icon: Icons.chat_bubble_outline,
        label: 'Chatbot AI',
        description: 'Tanya jawab',
        color: const Color(0xFF1E293B), // Dark icon
        backgroundColor: AppColors.cardYellow,
        onTap: () => context.go(AppRoutes.chat),
      ),
      _ShortcutItem(
        icon: Icons.menu_book_rounded,
        label: 'Edukasi',
        description: 'Artikel kesehatan',
        color: const Color(0xFF1E293B), // Dark icon
        backgroundColor: AppColors.primaryLight,
        onTap: () => context.go(AppRoutes.education),
      ),
      _ShortcutItem(
        icon: Icons.history_rounded,
        label: 'Riwayat',
        description: 'Hasil periksa',
        color: const Color(0xFF1E293B), // Dark icon
        backgroundColor: AppColors.cardPink,
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
        childAspectRatio: 1.15,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: item.backgroundColor, // Use solid pastel background
          borderRadius: BorderRadius.circular(24.r), // Very soft rounded corners
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 26.r,
                color: item.color,
              ),
              SizedBox(height: 8.h),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: item.color,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: item.color.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
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
