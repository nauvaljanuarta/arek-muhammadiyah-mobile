import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme/theme.dart';
import '../auth/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginPage(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0); // Start from bottom
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;
              var tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: Center(
        child: const _SplashContent(),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 140,
          width: 140,
          child: Image.asset(
            'assets/images/muhammadiyahlogo.png',
            fit: BoxFit.contain,
          ),
        )
            .animate()
            .fadeIn(
              duration: 1000.ms,
              curve: Curves.easeOut,
            )
            .slideX(
              begin: 0.3,
              end: 0,
              duration: 700.ms,
              curve: Curves.easeOutCubic,
            )
            .then()
            .slideX(
              begin: 0,
              end: -0.10,
              duration: 500.ms,
              delay: 400.ms,
              curve: Curves.easeInOut,
            ),
        Expanded(
          child: Text(
            'Muhammadiyah App',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
            overflow: TextOverflow.ellipsis,
          )
              .animate()
              .fadeIn(
                duration: 600.ms,
                delay: 800.ms,
                curve: Curves.easeOut,
              )
              .slideX(
                begin: 0.5,
                end: 0,
                duration: 700.ms,
                delay: 800.ms,
                curve: Curves.easeOutCubic,
              ),
        ),
      ],
    );
    return SizedBox(
      width: 360,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          content,
        ],
      ),
    );
  }
}
