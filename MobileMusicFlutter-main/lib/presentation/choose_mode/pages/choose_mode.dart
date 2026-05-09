import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/common/widgets/button/basic_app_button.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/presentation/auth/pages/signup_or_signin.dart';
import 'package:music_player/presentation/choose_mode/bloc/theme_cubit.dart';

class ChooseModePage extends StatelessWidget {
  const ChooseModePage({super.key});

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
                  'Chọn giao diện',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 19,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.read<ThemeCubit>().updateTheme(
                              ThemeMode.light,
                            );
                          },
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Color(0xff30393C).withAlpha(150),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.light_mode_outlined,
                                  size: 40,
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Sáng',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 100),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.read<ThemeCubit>().updateTheme(
                              ThemeMode.dark,
                            );
                          },
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Color(0xff30393C).withAlpha(150),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.dark_mode_outlined,
                                  size: 40,
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Tối',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 50),
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
                  title: 'Tiếp tục',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
