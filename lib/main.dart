import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'config/theme/theme.dart';
import 'pages/splash/splash_page.dart';
import 'services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); 
  
  await UserService.loadUserFromStorage();

  runApp(const MuhammadiyahApp());
}

class MuhammadiyahApp extends StatelessWidget {
  const MuhammadiyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      title: 'Muhammadiyah App',
      theme: AppTheme.cupertinoTheme.copyWith(
        brightness: Brightness.light, 
      ),
      home: const SplashPage(),
    );
  }
}