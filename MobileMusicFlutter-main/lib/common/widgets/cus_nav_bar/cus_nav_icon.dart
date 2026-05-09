import 'package:flutter/material.dart';

class CustomNavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;

  const CustomNavIcon({
    Key? key,
    required this.icon,
    required this.isSelected,
    this.activeColor = const Color(0xFF0075FF),
    this.inactiveColor = Colors.white70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              width: 24,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            top: 20,
            child: Icon(
              icon,
              size: 30,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
