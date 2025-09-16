import 'package:flutter/cupertino.dart';
import 'config/theme/theme.dart';
import 'pages/splash/splash_page.dart';

void main() {
  runApp(const MuhammadiyahApp());
}

class MuhammadiyahApp extends StatelessWidget {
  const MuhammadiyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Muhammadiyah App',
      theme: AppTheme.cupertinoTheme,
      home: SplashPage(), 
    );
  }
}