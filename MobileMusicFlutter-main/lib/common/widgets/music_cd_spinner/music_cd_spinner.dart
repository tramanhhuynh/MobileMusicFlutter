import 'package:flutter/material.dart';

class MusicCDSpinner extends StatefulWidget {
  const MusicCDSpinner({super.key});

  @override
  State<MusicCDSpinner> createState() => _MusicCDSpinnerState();
}

class _MusicCDSpinnerState extends State<MusicCDSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(); // liên tục xoay
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/vectors/logoMelofyIcon.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
