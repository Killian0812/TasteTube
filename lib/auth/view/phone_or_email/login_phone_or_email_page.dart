import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taste_tube/auth/view/phone_or_email/login_email/login_email_tab.dart';
import 'package:taste_tube/auth/view/phone_or_email/login_phone/login_phone_tab.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/providers.dart';

class LoginWithPhoneOrEmailPage extends StatefulWidget {
  final int initialIndex;
  const LoginWithPhoneOrEmailPage({this.initialIndex = 0, super.key});

  @override
  State<LoginWithPhoneOrEmailPage> createState() =>
      _LoginWithPhoneOrEmailPageState();
}

class _LoginWithPhoneOrEmailPageState extends State<LoginWithPhoneOrEmailPage> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = getIt<AppSettings>().getTheme;
    final isDarkMode = themeMode == ThemeMode.dark;

    final textColor = isDarkMode ? Colors.white : Colors.black;
    final tabIndicatorColor = isDarkMode ? Colors.white : Colors.black;
    final unselectedTabColor =
        isDarkMode ? Colors.grey[400] : CommonColor.greyOutTextColor;

    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Sign in",
            style: CommonTextStyle.bold.copyWith(color: textColor),
          ),
          bottom: TabBar(
            onTap: (value) {
              FocusScope.of(context).unfocus(); // Close keyboard
              setState(() {
                selectedIndex = value;
              });
            },
            indicatorColor: tabIndicatorColor,
            labelColor: textColor,
            unselectedLabelColor: unselectedTabColor,
            tabs: [
              Tab(
                icon: Icon(
                  FontAwesomeIcons.phone,
                  color: selectedIndex == 0 ? textColor : unselectedTabColor,
                ),
                text: "Phone",
              ),
              Tab(
                icon: Icon(
                  CupertinoIcons.mail,
                  color: selectedIndex == 1 ? textColor : unselectedTabColor,
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
