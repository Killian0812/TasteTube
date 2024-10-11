import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taste_tube/auth/view/phone_or_email/login_email/login_email_tab.dart';
import 'package:taste_tube/auth/view/phone_or_email/login_phone/login_phone_tab.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/text.dart';

class LoginWithPhoneOrEmailPage extends StatefulWidget {
  const LoginWithPhoneOrEmailPage({super.key});

  @override
  State<LoginWithPhoneOrEmailPage> createState() =>
      _LoginWithPhoneOrEmailPageState();
}

class _LoginWithPhoneOrEmailPageState extends State<LoginWithPhoneOrEmailPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Sign up",
            style: CommonTextStyle.bold,
          ),
          bottom: TabBar(
            onTap: (value) {
              FocusScope.of(context).unfocus(); // close keyboard
              setState(() {
                selectedIndex = value;
              });
            },
            indicatorColor: Colors.black,
            tabs: [
              Tab(
                icon: Icon(
                  FontAwesomeIcons.phone,
                  color: selectedIndex == 0
                      ? Colors.black
                      : CommonColor.greyOutTextColor,
                ),
                text: "Phone",
              ),
              Tab(
                icon: Icon(
                  CupertinoIcons.mail,
                  color: selectedIndex == 1
                      ? Colors.black
                      : CommonColor.greyOutTextColor,
                ),
                text: "Email",
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [
          LoginPhoneTab(),
          LoginEmailTab(),
        ]),
      ),
    );
  }
}
