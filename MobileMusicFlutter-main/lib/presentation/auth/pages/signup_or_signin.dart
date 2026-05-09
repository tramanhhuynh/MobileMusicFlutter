import 'package:flutter/material.dart';
import 'package:music_player/common/widgets/appbar/app_bar.dart';
import 'package:music_player/common/widgets/button/basic_app_button.dart';
import 'package:music_player/common/helpers/is_dark_mode.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/presentation/auth/pages/signin.dart';
import 'package:music_player/presentation/auth/pages/signup.dart';

class SignupOrSignin extends StatelessWidget {
  const SignupOrSignin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset('assets/vectors/or.png'),
          ),

          BasicAppbar(),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 120),
                  Image.asset('assets/vectors/logoMelofyText.png', width: 150),
                  SizedBox(height: 20),
                  Text(
                    'Tận hưởng âm nhạc',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26,color: Colors.white),
                  ),
                  SizedBox(height: 21),
                  Text(
                    'Nghe nhạc chất lượng cao, tạo playlist yêu thích và tận hưởng trải nghiệm mượt mà mọi lúc, mọi nơi.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: BasicAppButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (BuildContext context) =>
                                         SignupPage(),
                              ),
                            );
                          },
                          title: 'Đăng ký',
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (BuildContext context) =>
                                         SigninPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color:
                                  context.IsDarkMode
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
