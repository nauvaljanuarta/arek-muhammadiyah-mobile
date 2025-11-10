import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import '../auth/login_page.dart';

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
      _controller.play();
    });

    _controller.addListener(() {
      if (!_hasNavigated &&
          _controller.value.isInitialized &&
          !_controller.value.isPlaying &&
          _controller.value.position >= _controller.value.duration) {
        _hasNavigated = true;
        if (mounted) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
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
              // Show a placeholder until video is ready
              return const CupertinoActivityIndicator();
            }
          },
        ),
      ),
    );
  }
}
