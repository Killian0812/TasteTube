import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/splash/splash_page.dart';

class AdminInitialPage extends StatefulWidget {
  final String? redirect;
  const AdminInitialPage({super.key, this.redirect});

  @override
  State<AdminInitialPage> createState() => _AdminInitialPageState();
}

class _AdminInitialPageState extends State<AdminInitialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            if (state.data.role != 'ADMIN') {
              throw GoException("Not system admin");
            }
            if (widget.redirect != null && widget.redirect!.isNotEmpty) {
              context.go(widget.redirect!);
              return;
            }
            context.go('/dashboard');
          } else if (state is Unauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          return SplashPage(isAdmin: true);
        },
      ),
    );
  }
}
