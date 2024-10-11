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
              _confirmPasswordField(context),
              const SizedBox(height: 16),
              _registerButton(context),
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
        final passwordValidation =
            context.read<LoginEmailCubit>().validatePassword(state.password);

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
            const SizedBox(height: 8),
            if (state.password.isNotEmpty) ...[
              _passwordRequirements(passwordValidation),
              _passwordStrengthIndicator(passwordValidation),
            ]
          ],
        );
      },
    );
  }

  Widget _passwordRequirements(PasswordValidation validation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _passwordRequirement("8 characters (20 max)", validation.hasMinLength),
        _passwordRequirement(
            "1 letter and 1 number", validation.hasLetterAndNumber),
        _passwordRequirement(
            "1 special character (e.g., #, ?, !)", validation.hasSpecialChar),
      ],
    );
  }

  Widget _passwordRequirement(String text, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.cancel,
          color: met ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _passwordStrengthIndicator(PasswordValidation validation) {
    Color color;
    switch (validation.strength) {
      case PasswordStrength.strong:
        color = Colors.green;
        break;
      case PasswordStrength.medium:
        color = Colors.orange;
        break;
      case PasswordStrength.weak:
      default:
        color = Colors.red;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: validation.strength == PasswordStrength.strong
              ? 1
              : validation.strength == PasswordStrength.medium
                  ? 0.66
                  : 0.33,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          "Password strength: ${validation.strength.toString().split('.').last}",
          style: TextStyle(color: color),
        ),
      ],
    );
  }

  Widget _confirmPasswordField(BuildContext context) {
    return BlocBuilder<LoginEmailCubit, LoginEmailState>(
      builder: (context, state) {
        return TextField(
          obscureText: true,
          onChanged: (value) =>
              context.read<LoginEmailCubit>().editConfirmPassword(value),
          decoration: const InputDecoration(labelText: "Confirm Password"),
        );
      },
    );
  }

  Widget _registerButton(BuildContext context) {
    return BlocBuilder<LoginEmailCubit, LoginEmailState>(
        builder: (context, state) {
      final cubit = context.read<LoginEmailCubit>();

      return CommonButton(
        text: "Register",
        isDisabled: (state.confirmPassword != state.password) ||
            state.email.isEmpty ||
            state.password.isEmpty,
        onPressed: () async {
          FocusScope.of(context).unfocus();
          await cubit.send();
        },
      );
    });
  }
}
