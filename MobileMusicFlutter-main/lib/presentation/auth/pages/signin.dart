import 'package:flutter/material.dart';
import 'package:music_player/common/widgets/appbar/app_bar.dart';
import 'package:music_player/common/widgets/button/basic_app_button.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/data/models/auth/signin_user_req.dart';
import 'package:music_player/domain/usecases/auth/signin.dart';
import 'package:music_player/presentation/auth/pages/signup.dart';
import 'package:music_player/presentation/home/pages/home.dart';
import 'package:music_player/service_locator.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signupText(context),
      appBar: BasicAppbar(
        title: Image.asset('assets/vectors/logoMelofyFull.png', width: 125),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _registerText(),
              const SizedBox(height: 150),
              _emailField(context),
              const SizedBox(height: 20),
              _passwordField(context),
              const SizedBox(height: 20),
              BasicAppButton(
                onPressed: () async {
                  var result = await sl<SigninUseCase>().call(
                    params: SigninUserReq(
                      email: _email.text.toString(),
                      password: _password.text.toString(),
                    ),
                  );
                  result.fold(
                    (l) {
                      var snackbar = SnackBar(content: Text(l));
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    },
                    (r) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage()),
                        (route) => false,
                      );
                    },
                  );
                },
                title: 'Đăng nhập',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _registerText() {
    return const Text(
      'Đăng nhập',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: 'Mật khẩu',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }

  Widget _signupText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Chưa có tài khoản?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) =>  SignupPage()),
              );
            },
            child: Text(
              'Đăng ký',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
