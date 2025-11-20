import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme/theme.dart';
import 'pages/splash/splash_page.dart';
import 'services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  await UserService.loadUserFromStorage();

  runApp(MuhammadiyahApp(isLoggedIn: isLoggedIn));
}

class MuhammadiyahApp extends StatelessWidget {
  final bool isLoggedIn;
  const MuhammadiyahApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Muhammadiyah App',
      theme: AppTheme.cupertinoTheme,
      home:  const SplashPage(),
    );
  }
}
