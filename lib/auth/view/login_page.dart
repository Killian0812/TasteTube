import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/oauth/oauth_cubit.dart';
import 'package:taste_tube/auth/view/register_page.ext.dart';
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
      body: BlocListener<OAuthCubit, OAuthState>(
        listener: (context, state) {
          if (state is OAuthSuccess) {
            ToastService.showToast(context, state.message, ToastType.success,
                duration: const Duration(seconds: 3));
            final response = state.response;
            if (response.role.isNotEmpty) {
              if (response.role == 'RESTAURANT') {
                context.go('/store');
              } else {
                context.go('/home');
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AccountTypeSelectionPage.provider(response.userId)),
              );
            }
          }
          if (state is OAuthError) {
            ToastService.showToast(context, state.message, ToastType.warning,
                duration: const Duration(seconds: 4));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const AuthTitle(title: "Login to "),
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
                      onTap: () async {
                        await context
                            .read<OAuthCubit>()
                            .continueWithFacebook(context);
                      },
                    ),
                    AuthButton(
                      icon: FontAwesomeIcons.google,
                      title: "Login with Google",
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
              CommonTextWidget.loginPageMessage,
              const SizedBox(height: 60),
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
