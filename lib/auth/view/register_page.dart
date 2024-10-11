import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/widget/auth_title.dart';
import 'package:taste_tube/auth/view/widget/auth_button.dart';
import 'package:taste_tube/common/text.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AuthTitle(title: "Sign up to "),
              AuthButton(
                icon: FontAwesomeIcons.user,
                title: "Continue with phone or email",
                onTap: () {},
              ),
              AuthButton(
                icon: FontAwesomeIcons.facebook,
                title: "Continue with Facebook",
                onTap: () {},
              ),
              AuthButton(
                icon: FontAwesomeIcons.google,
                title: "Continue with Google",
                onTap: () {},
              ),
              const SizedBox(height: 200),
              CommonTextWidget.registerPageMessage,
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
              "Already have an account?",
              style: CommonTextStyle.regular,
            ),
            GestureDetector(
              onTap: () {
                context.go('/');
              },
              child: Text("  Login",
                  style: CommonTextStyle.bold.copyWith(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
