import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../home/home_page.dart';
import '/services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _carouselImages = [
    'assets/images/carrousel1.jpg',
    'assets/images/carrousel2.jpg',
    'assets/images/carrousel3.jpg',
  ];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _carouselImages.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0; 
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

    Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _loading = true);

    try {
      final success = await UserService.login(
        id: _usernameController.text,
        password: _passwordController.text,
      );

      if (success) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Ok'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: Stack(
        children: [
          // Carousel
          SizedBox(
            height: screenHeight,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _carouselImages.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  _carouselImages[index],
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: screenHeight * 0.25,
                );
              },
            ),
          ),
          // Page indicator
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _carouselImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? CupertinoColors.white
                        : CupertinoColors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          // Login Form
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.75,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          'assets/images/muhammadiyahlogo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masuk ke akun Anda',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      CupertinoTextField(
                        controller: _usernameController,
                        placeholder: 'NIK',
                        keyboardType: TextInputType.text,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.textSecondary.withOpacity(0.1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoTextField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        obscureText: true,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.textSecondary.withOpacity(0.1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: CupertinoButton(
                          color: AppTheme.primaryDark,
                          borderRadius: BorderRadius.circular(12),
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const CupertinoActivityIndicator()
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton(
                        onPressed: () {},
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
