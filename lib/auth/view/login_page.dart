import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/widget/auth_title.dart';
import 'package:taste_tube/auth/view/widget/auth_button.dart';
import 'package:taste_tube/common/text.dart';

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AuthTitle(title: "Sign in to "),
              AuthButton(
                icon: FontAwesomeIcons.user,
                title: "Login with phone or email",
                onTap: () {
                  context.push('/login/phone_or_email');
                },
              ),
              AuthButton(
                icon: FontAwesomeIcons.facebook,
                title: "Login with Facebook",
                onTap: () {},
              ),
              AuthButton(
                icon: FontAwesomeIcons.google,
                title: "Login with Google",
                onTap: () {},
              ),
              const SizedBox(height: 200),
              CustomTextWidget.loginPageMessage,
            ],
          ),
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
              style: CustomTextStyle.regular,
            ),
            GestureDetector(
              onTap: () {
                context.push('/register');
              },
              child: Text("  Register",
                  style: CustomTextStyle.bold.copyWith(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
