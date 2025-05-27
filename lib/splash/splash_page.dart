import 'package:flutter/material.dart';
import 'package:taste_tube/common/constant.dart';

class SplashPage extends StatefulWidget {
  final bool isAdmin;
  const SplashPage({super.key, this.isAdmin = false});

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AssetPath.tastetubeInverted),
            if (widget.isAdmin)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text('TasteTube Admin'),
              ),
          ],
        ),
      ),
    );
  }
}
