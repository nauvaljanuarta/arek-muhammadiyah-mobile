import 'package:flutter/cupertino.dart';
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
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.primaryDark,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightAccent,
              AppTheme.accent,
              AppTheme.primaryLight,
              AppTheme.primaryDark,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.star_circle_fill,
                size: 120,
                color: CupertinoColors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Muhammadiyah App',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Selamat Datang',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  color: CupertinoColors.white,
                ),
              ),
              SizedBox(height: 40),
              CupertinoActivityIndicator(
                color: CupertinoColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}