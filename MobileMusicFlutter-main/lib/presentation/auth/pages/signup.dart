import 'package:flutter/material.dart';
import 'package:music_player/common/widgets/appbar/app_bar.dart';
import 'package:music_player/common/widgets/button/basic_app_button.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/data/models/auth/create_user_req.dart';
import 'package:music_player/domain/usecases/auth/signup.dart';
import 'package:music_player/presentation/auth/pages/signin.dart';
import 'package:music_player/presentation/home/pages/home.dart';
import 'package:music_player/service_locator.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController(); // Thêm controller mới

  bool _obscureText = true;
  bool _obscureConfirmText = true; // Thêm trạng thái ẩn/hiện cho mật khẩu xác nhận

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signinText(context),
      appBar: BasicAppbar(
        title: Image.asset('assets/vectors/logoMelofyFull.png', width: 125),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _registerText(),
            const SizedBox(height: 50),
            _fullNameField(context),
            const SizedBox(height: 20),
            _emailField(context),
            const SizedBox(height: 20),
            _passwordField(context),
            const SizedBox(height: 20),
            _confirmPasswordField(context), // Thêm trường xác nhận mật khẩu
            const SizedBox(height: 20),
            BasicAppButton(
              onPressed: () async {
                if (_password.text != _confirmPassword.text) {
                  // Hiển thị Snackbar nếu mật khẩu không khớp
                  var snackbar = const SnackBar(
                      content: Text('Mật khẩu và xác nhận mật khẩu không khớp!'));
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  return; // Ngừng thực hiện đăng ký nếu mật khẩu không khớp
                }

                var result = await sl<SignupUseCase>().call(
                  params: CreateUserReq(
                    fullName: _fullName.text.trim(),
                    email: _email.text.trim(),
                    password: _password.text.trim(),
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
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                );
              },
              title: 'Tạo tài khoản',
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerText() {
    return const Text(
      'Đăng ký',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _fullNameField(BuildContext context) {
    return TextField(
      controller: _fullName,
      decoration: InputDecoration(
        hintText: 'Tên',
        contentPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
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

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
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

  // Thêm Widget mới cho trường xác nhận mật khẩu
  Widget _confirmPasswordField(BuildContext context) {
    return TextField(
      controller: _confirmPassword,
      obscureText: _obscureConfirmText, // Sử dụng trạng thái ẩn/hiện riêng
      decoration: InputDecoration(
        hintText: 'Xác nhận mật khẩu',
        contentPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
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
            _obscureConfirmText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmText = !_obscureConfirmText; // Thay đổi trạng thái ẩn/hiện
            });
          },
        ),
      ),
    );
  }

  Widget _signinText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Bạn đã có tài khoản?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SigninPage()),
              );
            },
            child: Text(
              'Đăng nhập',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}