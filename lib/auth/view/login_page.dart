import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/widget/auth_title.dart';
import 'package:taste_tube/auth/view/widget/auth_button.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const AuthTitle(title: "Sign in to "),
                  AuthButton(
                    icon: FontAwesomeIcons.user,
                    title: "Continue with phone or email",
                    onTap: () {
                      context.push('/login/phone_or_email', extra: 1);
                    },
                  ),
                  AuthButton(
                    icon: FontAwesomeIcons.facebook,
                    title: "Login with Facebook",
                    onTap: () {
                      ToastService.showToast(
                          context, "Facebook", ToastType.info);
                    },
                  ),
                  AuthButton(
                    icon: FontAwesomeIcons.google,
                    title: "Login with Google",
                    onTap: () {
                      ToastService.showToast(
                          context, "Google", ToastType.success);
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            CommonTextWidget.loginPageMessage,
            const SizedBox(height: 60),
          ],
        ),
      ),
      bottomSheet: SizedBox(
        height: 60,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account?",
              style: CommonTextStyle.regular,
            ),
            GestureDetector(
              onTap: () {
                context.push('/register');
              },
              child: Text("  Register",
                  style: CommonTextStyle.bold
                      .copyWith(color: CommonColor.activeBgColor)),
            ),
          ],
        ),
      ),
    );
  }
}
