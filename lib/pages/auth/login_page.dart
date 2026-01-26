// ... (Imports sama seperti file sebelumnya) ...
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
import '../../config/theme/theme.dart';
import '../home/home_page.dart';
import '../../services/user_service.dart';
import 'complete_profile_page.dart';
import 'register_page.dart';
import 'change_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final PageController _pageController = PageController();
  
  Timer? _timer;
  int _currentPage = 0;
  bool _obscureText = true;
  bool _loading = false;

  final List<String> _carouselImages = [
    'assets/images/carrousel1.jpg',
    'assets/images/carrousel2.jpg',
    'assets/images/carrousel3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCarouselTimer() {
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
    FocusScope.of(context).unfocus();

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Silakan isi semua kolom');
      return;
    }

    setState(() => _loading = true);

    try {
      await UserService.login(
        telp: _usernameController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      final status = await UserService.checkAuthStatus();
      _handleNavigation(status);

    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showError(msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleNavigation(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case AuthStatus.profileIncomplete:
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const CompleteProfilePage()),
        );
        break;
      case AuthStatus.passwordChangeRequired:
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const ChangePasswordPage()),
        );
        break;
      case AuthStatus.unauthenticated:
        _showError('Sesi berakhir, silakan login kembali.');
        break;
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Login Gagal'),
        content: Text('Email atau Password salah.\n$message'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Ok'),
            onPressed: () => Navigator.of(ctx).pop(), 
          ),
        ],
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: isPassword ? _obscureText : false,
      keyboardType: keyboardType,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
      ),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
      suffix: isPassword
          ? CupertinoButton(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                _obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: Stack(
        children: [
          SizedBox(
            height: screenHeight,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _carouselImages.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  _carouselImages[index],
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: screenHeight * 0.35, 
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.70,
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Image.asset(
                          'assets/images/muhammadiyahlogo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Selamat Datang Kembali',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Login ke akun Anda',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildTextField(
                        controller: _usernameController,
                        placeholder: 'Nomor Telepon',
                        icon: CupertinoIcons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        icon: CupertinoIcons.lock,
                        isPassword: true,
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
                              ? const CupertinoActivityIndicator(color: AppTheme.primaryDark)
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
                        padding: EdgeInsets.zero,
                        child: const Text(
                          'Lupa Password?',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
}