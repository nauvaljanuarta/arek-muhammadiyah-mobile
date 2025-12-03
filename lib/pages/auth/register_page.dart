import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Butuh untuk Colors/Icons
import '../../config/theme/theme.dart';
import '../../services/user_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Notice'),
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

  void _handleRegister() async {
    // 1. Tutup Keyboard seketika agar UI tidak terasa berat
    FocusScope.of(context).unfocus();

    // Validasi
    if (_nameController.text.isEmpty) {
      _showError("Name is required");
      return;
    }
    if (_phoneController.text.isEmpty) {
      _showError("Phone number is required");
      return;
    }
    if (_phoneController.text.length < 10) {
      _showError("Invalid phone number");
      return;
    }
    if (_passController.text.isEmpty) {
      _showError("Password is required");
      return;
    }
    if (_passController.text.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }
    if (_confirmPassController.text != _passController.text) {
      _showError("Passwords do not match");
      return;
    }

    // 2. Nyalakan Loading Indicator SEGERA
    setState(() => _isLoading = true);

    try {
      await UserService.register({
        'name': _nameController.text,
        'telp': _phoneController.text,
        'password': _passController.text,
        'password_confirmation': _confirmPassController.text, 
      });

      if (!mounted) return;

      // Dialog Sukses
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Registration successful. Please login to complete your profile.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Login'),
              onPressed: () {
                Navigator.pop(ctx); // Tutup dialog
                Navigator.pop(context); // Kembali ke Login Page
              },
            ),
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      // 3. Matikan Loading (Apapun yang terjadi)
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  CupertinoIcons.person_add_solid,
                  size: 64,
                  color: AppTheme.primaryDark,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Montserrat',
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign up to get started with Muhammadiyah App",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Input Nama
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: "Full Name",
                  padding: const EdgeInsets.all(16),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(CupertinoIcons.person, color: AppTheme.textSecondary, size: 20),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Telepon
                CupertinoTextField(
                  controller: _phoneController,
                  placeholder: "Phone Number",
                  keyboardType: TextInputType.phone,
                  padding: const EdgeInsets.all(16),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(CupertinoIcons.phone, color: AppTheme.textSecondary, size: 20),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Input Password
                CupertinoTextField(
                  controller: _passController,
                  placeholder: "Password",
                  obscureText: _obscurePass,
                  padding: const EdgeInsets.all(16),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(CupertinoIcons.lock, color: AppTheme.textSecondary, size: 20),
                  ),
                  suffix: CupertinoButton(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      _obscurePass ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
                  ),
                ),
                const SizedBox(height: 16),

                // Konfirmasi Password
                CupertinoTextField(
                  controller: _confirmPassController,
                  placeholder: "Confirm Password",
                  obscureText: _obscureConfirmPass,
                  padding: const EdgeInsets.all(16),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(CupertinoIcons.lock, color: AppTheme.textSecondary, size: 20),
                  ),
                  suffix: CupertinoButton(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      _obscureConfirmPass ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Register dengan Animasi Loading
                SizedBox(
                  height: 50,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: AppTheme.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _isLoading ? null : _handleRegister, 
                    child: _isLoading 
                      ? const CupertinoActivityIndicator(color: AppTheme.primaryDark) 
                      : const Text(
                          "Register", 
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // Link ke Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ", 
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Login here",
                        style: TextStyle(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}