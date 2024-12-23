import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/oauth/oauth_cubit.dart';
import 'package:taste_tube/auth/view/widget/auth_title.dart';
import 'package:taste_tube/auth/view/widget/auth_button.dart';
import 'package:taste_tube/common/color.dart';
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
        child: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const AuthTitle(title: "Register for "),
                  AuthButton(
                    icon: FontAwesomeIcons.user,
                    title: "Continue with phone or email",
                    onTap: () {
                      context.push('/register/phone_or_email');
                    },
                  ),
                  AuthButton(
                    icon: FontAwesomeIcons.facebook,
                    title: "Continue with Facebook",
                    onTap: () async {
                      await context
                          .read<OAuthCubit>()
                          .continueWithFacebook(context);
                    },
                  ),
                  AuthButton(
                    icon: FontAwesomeIcons.google,
                    title: "Continue with Google",
                    onTap: () async {
                      await context
                          .read<OAuthCubit>()
                          .continueWithGoogle(context);
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            CommonTextWidget.registerPageMessage,
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
              "Already have an account?",
              style: CommonTextStyle.regular,
            ),
            GestureDetector(
              onTap: () {
                context.go('/login');
              },
              child: Text("  Login",
                  style: CommonTextStyle.bold
                      .copyWith(color: CommonColor.activeBgColor)),
            ),
          ],
        ),
      ),
    );
  }
}
