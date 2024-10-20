import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/button.dart';

import 'login_email_cubit.dart';

class LoginEmailTab extends StatelessWidget {
  const LoginEmailTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginEmailCubit(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _emailField(context),
              const SizedBox(height: 16),
              _passwordField(context),
              const SizedBox(height: 16),
              _loginButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return BlocBuilder<LoginEmailCubit, LoginEmailState>(
      builder: (context, state) {
        return TextField(
          autofocus: true,
          onChanged: (value) =>
              context.read<LoginEmailCubit>().editEmail(value),
          decoration: const InputDecoration(labelText: "Email"),
        );
      },
    );
  }

  Widget _passwordField(BuildContext context) {
    return BlocBuilder<LoginEmailCubit, LoginEmailState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              obscureText: !state.isPasswordVisible,
              onChanged: (value) =>
                  context.read<LoginEmailCubit>().editPassword(value),
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    state.isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    context.read<LoginEmailCubit>().togglePasswordVisibility();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _loginButton(BuildContext context) {
    return BlocBuilder<LoginEmailCubit, LoginEmailState>(
        builder: (context, state) {
      final cubit = context.read<LoginEmailCubit>();

      return CommonButton(
        text: "Login",
        isDisabled: state.email.isEmpty || state.password.isEmpty,
        isLoading: state.isLoading,
        onPressed: () async {
          FocusScope.of(context).unfocus();
          await cubit.send(context);
        },
      );
    });
  }
}
