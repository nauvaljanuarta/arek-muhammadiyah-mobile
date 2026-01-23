import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../auth/login_page.dart';
import '../home/home_page.dart';
import '../../services/user_service.dart';
import '../auth/complete_profile_page.dart'; 
import '../auth/change_password_page.dart';  

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideo;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/intro/Montserrat.mp4')
      ..setLooping(false)
      ..setVolume(0);

    _initializeVideo = _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });

    _controller.addListener(_checkVideoEnd);
  }

  void _checkVideoEnd() async {
    if (!_hasNavigated &&
        _controller.value.isInitialized &&
        !_controller.value.isPlaying &&
        _controller.value.position >= _controller.value.duration) {
      
      _hasNavigated = true;
      await _navigateNext();
    }
  }

Future<void> _navigateNext() async {
  if (!mounted) return;

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  Widget nextPage = const LoginPage();

  if (token != null && token.isNotEmpty) {
    await UserService.loadUserFromStorage();

    if (UserService.currentUser != null) {
      try {
        final status = await UserService.checkAuthStatus();

        switch (status) {
          case AuthStatus.authenticated:
            nextPage = const HomePage();
            break;

          case AuthStatus.profileIncomplete:
            nextPage = const CompleteProfilePage();
            break;

          case AuthStatus.passwordChangeRequired:
            nextPage = const ChangePasswordPage();
            break;

          case AuthStatus.unauthenticated:
            await UserService.logout();
            nextPage = const LoginPage();
            break;
        }
      } catch (e) {
        debugPrint("Splash Error: $e");
        await UserService.logout();
        nextPage = const LoginPage();
      }
    }
  }

  if (!mounted) return;

  Navigator.of(context).pushReplacement(
    CupertinoPageRoute(builder: (_) => nextPage),
  );
}

  @override
  void dispose() {
    _controller.removeListener(_checkVideoEnd);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: Center(
        child: FutureBuilder(
          future: _initializeVideo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SizedBox(
                width: 360,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              );
            } else {
              // Loading indicator saat video buffering/init
              return const CupertinoActivityIndicator(radius: 20);
            }
          },
        ),
      ),
    );
  }
}