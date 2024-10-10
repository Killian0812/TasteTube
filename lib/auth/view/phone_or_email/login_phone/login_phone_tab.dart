import 'package:flutter/material.dart';  
import 'package:flutter_bloc/flutter_bloc.dart';  
import 'package:intl_phone_field/intl_phone_field.dart';  
import 'package:taste_tube/auth/view/phone_or_email/login_phone/login_phone_cubit.dart';  
import 'package:taste_tube/common/button.dart';  
import 'package:taste_tube/common/text.dart';  

class LoginPhoneTab extends StatelessWidget {  
  const LoginPhoneTab({super.key});  

  @override  
  Widget build(BuildContext context) {  
    return BlocProvider(  
      create: (_) => LoginPhoneCubit(),  
      child: BlocBuilder<LoginPhoneCubit, LoginPhoneState>(  
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
                    dropdownTextStyle: CustomTextStyle.regular,  
                    style: CustomTextStyle.regular,  
                    onChanged: (phone) {  
                      cubit.editPhone(phone.completeNumber);  
                    },  
                  ),  
                  CustomButton(  
                    text: "Send code",  
                    isDisabled: !state.canSendOtp,  
                    isLoading: state.isLoading,  
                    onPressed: () {  
                      FocusScope.of(context).unfocus();  
                      cubit.sendOtp();  
                    },  
                  )  
                ],  
              ),  
            ),  
          );  
        },  
      ),  
    );  
  }  
}