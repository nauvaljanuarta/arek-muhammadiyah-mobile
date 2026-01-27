import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
import '../../config/theme/theme.dart';
import '../../services/user_service.dart';
import 'login_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
  }


  void _handleChangePassword() async {
    FocusScope.of(context).unfocus();

    if (_newPassController.text.isEmpty || _confirmPassController.text.isEmpty) {
      _showError("Mohon isi semua kolom");
      return;
    }
    if (_newPassController.text != _confirmPassController.text) {
      _showError("Password konfirmasi tidak sama");
      return;
    }
    if (_newPassController.text.length < 6) {
      _showError("Password minimal 6 karakter");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = UserService.currentUser;
      if (user == null) throw Exception("Sesi habis");

      await UserService.updateUser(user.id.toString(), {
        'password': _newPassController.text,
        'force_change_password': false, 
      });
      
      await UserService.logout();

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Sukses'),
            content: const Text('Password berhasil diubah. Silakan login kembali dengan password baru.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Login Ulang'),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Gagal'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Ok'),
            onPressed: () => Navigator.pop(ctx),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text("Ganti Password"),
        leading: CupertinoNavigationBarBackButton(
          color: AppTheme.textPrimary,
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (_) => const LoginPage()), (route) => false,
            );
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CupertinoColors.systemRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_triangle, color: CupertinoColors.systemRed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Demi keamanan, Anda wajib mengganti password default sebelum melanjutkan.",
                        style: TextStyle(
                          fontSize: 13, 
                          color: CupertinoColors.black.withOpacity(0.8),
                          height: 1.4
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              CupertinoTextField(
                controller: _newPassController,
                placeholder: "Password Baru",
                obscureText: _obscureNew,
                padding: const EdgeInsets.all(16),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(CupertinoIcons.lock, color: AppTheme.textSecondary, size: 20),
                ),
                suffix: CupertinoButton(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    _obscureNew ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
                ),
              ),
              const SizedBox(height: 16),

              CupertinoTextField(
                controller: _confirmPassController,
                placeholder: "Konfirmasi Password Baru",
                obscureText: _obscureConfirm,
                padding: const EdgeInsets.all(16),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(CupertinoIcons.lock_shield, color: AppTheme.textSecondary, size: 20),
                ),
                suffix: CupertinoButton(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    _obscureConfirm ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(16),
                  onPressed: _isLoading ? null : _handleChangePassword,
                  child: _isLoading
                      ? const CupertinoActivityIndicator(color: AppTheme.primaryDark)
                      : const Text("Simpan Password Baru", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}