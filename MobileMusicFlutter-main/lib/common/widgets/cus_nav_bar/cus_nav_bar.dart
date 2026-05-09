import 'package:flutter/material.dart';
import 'cus_nav_icon.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: const Color(0xFF343434),
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        height: 60,
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: [
          NavigationDestination(
            icon: CustomNavIcon(
              icon: Icons.home_rounded,
              isSelected: currentIndex == 0,
            ),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: CustomNavIcon(
              icon: Icons.search,
              isSelected: currentIndex == 1,
            ),
            label: 'Tìm kiếm',
          ),
          NavigationDestination(
            icon: CustomNavIcon(
              icon: Icons.library_add,
              isSelected: currentIndex == 2,
            ),
            label: 'Thư viện',
          ),
          NavigationDestination(
            icon: CustomNavIcon(
              icon: Icons.account_box_rounded,
              isSelected: currentIndex == 3,
            ),
            label: 'Thông tin',
          ),
        ],
      ),
    );
  }
}
