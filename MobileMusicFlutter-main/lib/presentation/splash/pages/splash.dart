import 'package:flutter/material.dart';
import 'package:music_player/presentation/intro/pages/get_started.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_player/presentation/home/pages/home.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/vectors/logoMelofyFull.png',width: 300,),
      ),
    );
  }

  Future<void> redirect() async {
    await Future.delayed(const Duration(seconds: 2));
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Đã đăng nhập, vào thẳng HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const HomePage(),
        ),
      );
    } else {
      // Chưa đăng nhập, vào GetStartedPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const GetStartedPage(),
        ),
      );
    }
  }
}