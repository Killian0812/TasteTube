import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/register_page.ext.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/splash/splash_page.dart';

class InitialPage extends StatefulWidget {
  final String? redirect;
  const InitialPage({super.key, this.redirect});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            if (state.data.role.isEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AccountTypeSelectionPage.provider(state.data.userId)),
              );
              return;
            }
            if (widget.redirect != null && widget.redirect!.isNotEmpty) {
              context.go(widget.redirect!);
              return;
            }
            String redirect =
                state.data.role == 'RESTAURANT' ? '/store' : '/home';
            context.go(redirect);
          } else if (state is Unauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          return SplashPage();
        },
      ),
    );
  }
}
