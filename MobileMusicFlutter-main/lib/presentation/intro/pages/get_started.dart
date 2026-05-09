import 'package:flutter/material.dart';
import 'package:music_player/common/widgets/button/basic_app_button.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/presentation/auth/pages/signup_or_signin.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/vectors/bgVMH.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withAlpha(100)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'assets/vectors/logoMelofyFull.png',
                    width: 250,
                  ),
                ),
                const Spacer(),
                Text(
                  'Khám phá âm nhạc theo cách của bạn',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 19,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  'Nghe nhạc chất lượng cao, tạo playlist yêu thích và tận hưởng trải nghiệm mượt mà mọi lúc, mọi nơi.',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                BasicAppButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (BuildContext context) => const SignupOrSignin(),
                      ),
                    );
                  },
                  title: 'Bắt đầu',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
