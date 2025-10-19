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
  bool _hasNavigated = false; // FLAG supaya navigasi hanya sekali

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/intro/Montserrat.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (!_hasNavigated && // cek flag
          _controller.value.position >= _controller.value.duration &&
          !_controller.value.isPlaying) {
        _hasNavigated = true; // set flag supaya tidak dipanggil lagi
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
        child: _controller.value.isInitialized
            ? SizedBox(
                width: 360,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            : const CupertinoActivityIndicator(),
      ),
    );
  }
}
