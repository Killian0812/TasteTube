import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:taste_tube/auth/view/phone_or_email/login_phone/login_phone_cubit.dart';
import 'package:taste_tube/auth/view/register_page.ext.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';

class LoginPhoneTab extends StatefulWidget {
  const LoginPhoneTab({super.key});

  @override
  State<LoginPhoneTab> createState() => _LoginPhoneTabState();
}

class _LoginPhoneTabState extends State<LoginPhoneTab> {
  String otpCode = '';
  bool otpSentOnce = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginPhoneCubit(),
      child: BlocConsumer<LoginPhoneCubit, LoginPhoneState>(
        listener: (context, state) {
          if (state is OtpSentState) {
            if (!otpSentOnce) {
              ToastService.showToast(
                context,
                "OTP sent to ${state.phone}",
                ToastType.success,
                duration: const Duration(seconds: 2),
              );
              setState(() {
                otpSentOnce = true;
              });
            }
          }
          if (state is ErrorState) {
            ToastService.showToast(
              context,
              state.errorMessage,
              ToastType.warning,
              duration: const Duration(seconds: 3),
            );
          }
          if (state is OtpVerifiedState) {
            ToastService.showToast(
              context,
              "OTP Verified",
              ToastType.success,
              duration: const Duration(seconds: 2),
            );

            final authData = state.authData;
            if (authData.role.isNotEmpty) {
              if (authData.role == 'ADMIN') {
                context.go('/dashboard');
              } else if (authData.role == 'RESTAURANT') {
                context.go('/store');
              } else {
                context.go('/home');
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AccountTypeSelectionPage.provider(authData.userId)),
              );
            }
          }
        },
        builder: (context, state) {
          final cubit = context.read<LoginPhoneCubit>();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IntlPhoneField(
                    initialCountryCode: "VN",
                    autofocus: true,
                    disableLengthCheck: true,
                    dropdownTextStyle: CommonTextStyle.regular,
                    style: CommonTextStyle.regular,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(top: 12),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (phone) {
                      cubit.editPhone(phone.completeNumber);
                    },
                    enabled: state is! SendingOtpState &&
                        state is! VerifyingOtpState,
                  ),
                  CommonButton(
                    text: state is OtpSentState && state.cooldownSeconds > 0
                        ? 'Resend in ${state.cooldownSeconds}s'
                        : 'Send OTP',
                    isDisabled: !state.canSendOtp,
                    isLoading: state is SendingOtpState,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      cubit.sendOtp();
                    },
                  ),
                  if (otpSentOnce)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: OtpTextField(
                        numberOfFields: 6,
                        borderColor: Theme.of(context).primaryColor,
                        showFieldAsBox: true,
                        textStyle: CommonTextStyle.regular,
                        enabled: state is! VerifyingOtpState,
                        keyboardType: TextInputType.number,
                        onSubmit: (String verificationCode) {
                          setState(() {
                            otpCode = verificationCode;
                          });
                        },
                        handleControllers: (controllers) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            for (int i = 0; i < controllers.length; i++) {
                              if (controllers[i]?.text.isEmpty ?? true) {
                                setState(() {
                                  otpCode = '';
                                });
                                return;
                              }
                            }
                          });
                        },
                      ),
                    ),
                  if (otpSentOnce)
                    CommonButton(
                      text: 'Verify phone number',
                      isDisabled:
                          state is VerifyingOtpState || otpCode.length < 6,
                      isLoading: state is VerifyingOtpState,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        cubit.verifyOtp(otpCode);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
