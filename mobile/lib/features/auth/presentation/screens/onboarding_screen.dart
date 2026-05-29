import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    const _OnboardingPage(
      icon: Icons.health_and_safety,
      color: AppColors.primary,
      title: 'Deteksi Dini TBC',
      description:
          'Jawab 15 pertanyaan sederhana untuk mengetahui tingkat risiko TBC kamu dengan Sistem Pakar Forward Chaining.',
    ),
    const _OnboardingPage(
      icon: Icons.smart_toy,
      color: Color(0xFF00838F),
      title: 'Chatbot AI TBC',
      description:
          'Tanyakan apa saja tentang TBC kepada asisten AI kami yang siap membantu menjawab pertanyaan kamu 24/7.',
    ),
    const _OnboardingPage(
      icon: Icons.menu_book,
      color: Color(0xFF2E7D32),
      title: 'Edukasi Lengkap',
      description:
          'Akses artikel edukasi terstruktur tentang TBC — dari gejala, penularan, pencegahan, hingga pengobatan.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _goToLogin,
                child: Text(
                  'Lewati',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140.r,
                          height: 140.r,
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            page.icon,
                            size: 64.r,
                            color: page.color,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          page.description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentPage == index ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _goToLogin();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Mulai'
                            : 'Selanjutnya',
                      ),
                    ),
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

class _OnboardingPage {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
