import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 10.sp,
      unselectedFontSize: 10.sp,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/expert-system');
            break;
          case 2:
            context.go('/chat');
            break;
          case 3:
            context.go('/education');
            break;
          case 4:
            context.go('/history');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 22.r),
          activeIcon: Icon(Icons.home, size: 22.r),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services_outlined, size: 22.r),
          activeIcon: Icon(Icons.medical_services, size: 22.r),
          label: 'Periksa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_outlined, size: 22.r),
          activeIcon: Icon(Icons.chat, size: 22.r),
          label: 'Chatbot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined, size: 22.r),
          activeIcon: Icon(Icons.menu_book, size: 22.r),
          label: 'Edukasi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined, size: 22.r),
          activeIcon: Icon(Icons.history, size: 22.r),
          label: 'Riwayat',
        ),
      ],
    );
  }
}

class ScaffoldWithNavbar extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const ScaffoldWithNavbar({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavbar(currentIndex: currentIndex),
    );
  }
}
