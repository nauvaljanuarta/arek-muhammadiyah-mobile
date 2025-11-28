import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Perlu untuk Colors, ScaffoldMessenger, dll jika dipakai
import '../../config/theme/theme.dart';
import '../home/home_page.dart';
import '../../services/user_service.dart';
// Import halaman tujuan logic
import 'complete_profile_page.dart';
import 'register_page.dart';

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
      _showError('Mohon isi semua kolom');
      return;
    }

    setState(() => _loading = true);

    try {
      // 1. Lakukan Login
      final success = await UserService.login(
        telp: _usernameController.text,
        password: _passwordController.text,
      );

      if (success) {
        if (!mounted) return;

        // 2. Cek Status Akun (Lengkap/Belum, Ganti Password/Tidak)
        final status = UserService.checkAuthStatus();

        switch (status) {
          case AuthStatus.authenticated:
            // Profil Aman -> Masuk Home
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (_) => const HomePage()),
            );
            break;

          case AuthStatus.profileIncomplete:
            // Profil Belum Lengkap (User HP) -> Paksa lengkapi data
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (_) => const CompleteProfilePage()),
            );
            _showDialogInfo('Mohon lengkapi data diri Anda terlebih dahulu.');
            break;

          case AuthStatus.passwordChangeRequired:
            // Password Ganti (User Admin) -> Logic ini sementara
            // Jika page ganti password belum ada, tampilkan info saja atau redirect ke page ganti pass
            _showError('Anda wajib mengganti password default (Fitur segera hadir).');
            // Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => const ChangePasswordPage()));
            break;

          case AuthStatus.unauthenticated:
            _showError('Sesi tidak valid, silakan login ulang.');
            break;
        }
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Gagal Masuk'),
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

  void _showDialogInfo(String message) {
    // Helper untuk info non-error (seperti redirect profil)
    // Sebaiknya menggunakan SnackBar tapi di CupertinoPageScaffold agak tricky,
    // jadi pakai dialog sebentar atau biarkan user melihat judul halaman berikutnya.
    // Di sini kita skip UI blocking agar user langsung masuk halaman tujuan.
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: Stack(
        children: [
          // Carousel Background
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
                  height: screenHeight * 0.35, // Sedikit lebih tinggi agar estetik
                );
              },
            ),
          ),
          // Page indicator overlay
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
          
          // Login Form Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.70, // Proporsi area putih
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
                      
                      // Logo & Title
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
                        'Welcome Back',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masuk ke akun Anda',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // Input Fields
                      CupertinoTextField(
                        controller: _usernameController,
                        placeholder: 'No. Telp',
                        keyboardType: TextInputType.phone,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.textSecondary.withOpacity(0.1),
                          ),
                        ),
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Icon(CupertinoIcons.phone, color: AppTheme.textSecondary, size: 20),
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
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Icon(CupertinoIcons.lock, color: AppTheme.textSecondary, size: 20),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Button Login
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: CupertinoButton(
                          color: AppTheme.primaryDark,
                          borderRadius: BorderRadius.circular(12),
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const CupertinoActivityIndicator(color: Colors.white)
                              : const Text(
                                  'Masuk',
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
                      
                      // Lupa Password
                      CupertinoButton(
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
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
                            child: Text(
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}