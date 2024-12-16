import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/register_page.ext.dart';
import 'package:taste_tube/global_bloc/auth/bloc.dart';

class SplashPage extends StatefulWidget {
  final bool shouldAutoRedirect;
  const SplashPage({super.key, this.shouldAutoRedirect = true});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    context.read<AuthBloc>().add(CheckAuthEvent());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (!widget.shouldAutoRedirect) return;
          if (state is Authenticated) {
            if (state.data.role == 'RESTAURANT') {
              context.goNamed('profile',
                  pathParameters: {'userId': state.data.userId});
            } else if (state.data.role == 'CUSTOMER') {
              context.go('/home');
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AccountTypeSelectionPage.provider(state.data.userId)),
              );
            }
          } else if (state is Unauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          return Center(
            child: ScaleTransition(
              scale: _animation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/tastetube_inverted.png',
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
