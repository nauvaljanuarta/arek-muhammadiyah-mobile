import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/user_service.dart';
import '../../config/theme/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _telpController = TextEditingController(); // Tambah controller untuk telp

  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _birthDateController.dispose();
    _telpController.dispose(); // Dispose telp controller
    super.dispose();
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Perhatian'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    FocusScope.of(context).unfocus();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _submitForgotPassword() async {
    // Validasi
    if (_nameController.text.isEmpty) {
      _showError("Nama wajib diisi");
      return;
    }
    
    if (_selectedDate == null) {
      _showError("Tanggal lahir wajib diisi");
      return;
    }
    
    if (_telpController.text.isEmpty) { // Validasi telepon
      _showError("Nomor telepon wajib diisi");
      return;
    }
    
    if (_nikController.text.length != 16) {
      _showError("NIK harus 16 digit");
      return;
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(_nikController.text)) {
      _showError("NIK harus berupa angka");
      return;
    }

    // Validasi format telepon (minimal 10 digit, maksimal 15 digit)
    if (_telpController.text.length < 10 || _telpController.text.length > 15) {
      _showError("Nomor telepon harus 10-15 digit");
      return;
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(_telpController.text)) {
      _showError("Nomor telepon harus berupa angka");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Panggil method yang sudah diupdate dengan telp
      await UserService.forgotPassword(
        name: _nameController.text.trim(),
        birthDate: _selectedDate!,
        nik: _nikController.text.trim(),
        telp: _telpController.text.trim(), // Kirim telp
      );

      setState(() {
        _successMessage = 'Password berhasil direset ke default.\n'
            'Silakan login dengan password default yang telah dikirim.';
      });

      // Clear form setelah sukses
      _nameController.clear();
      _nikController.clear();
      _telpController.clear();
      _birthDateController.clear();
      setState(() => _selectedDate = null);
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _formatDateDisplay(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd MMMM yyyy').format(date);
  }

  Widget _buildSelectableInput({
    required String label,
    required String? value,
    required VoidCallback onTap,
    required IconData icon,
    String placeholder = "Pilih",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppTheme.primaryDark.withOpacity(0.8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: TextStyle(
                      color: value != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary.withOpacity(0.5),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.background,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.back,
            size: 24,
            color: AppTheme.textPrimary,
          ),
        ),
        middle: const Text(
          "Lupa Password",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.lock_rotation,
                    size: 40,
                    color: CupertinoColors.systemOrange,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              const Center(
                child: Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              Center(
                child: Text(
                  "Masukkan data diri Anda untuk mereset password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Nama Field
              const Text(
                "Nama Lengkap",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _nameController,
                padding: const EdgeInsets.all(16),
                placeholder: "Masukkan nama lengkap",
                placeholderStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.textSecondary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Telepon Field (BARU)
              const Text(
                "Nomor Telepon",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _telpController,
                keyboardType: TextInputType.phone,
                padding: const EdgeInsets.all(16),
                maxLength: 15,
                placeholder: "Contoh: 081234567890",
                placeholderStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.textSecondary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Tanggal Lahir Field
              _buildSelectableInput(
                label: "Tanggal Lahir",
                value: _formatDateDisplay(_selectedDate),
                onTap: _showDatePicker,
                icon: CupertinoIcons.calendar,
                placeholder: "Pilih tanggal lahir",
              ),

              // NIK Field
              const Text(
                "NIK (Nomor Induk Kependudukan)",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _nikController,
                keyboardType: TextInputType.number,
                padding: const EdgeInsets.all(16),
                maxLength: 16,
                placeholder: "Masukkan 16 digit NIK",
                placeholderStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.textSecondary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                "Masukkan 16 digit NIK tanpa tanda baca",
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.systemOrange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.info_circle_fill,
                      size: 20,
                      color: CupertinoColors.systemOrange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Password akan direset ke default. "
                        "Anda diwajibkan mengubah password setelah login.",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.systemRed.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        size: 20,
                        color: CupertinoColors.systemRed,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemRed,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Success Message
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.systemGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 20,
                        color: CupertinoColors.systemGreen,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGreen,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_errorMessage != null || _successMessage != null)
                const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _isLoading ? null : _submitForgotPassword,
                  child: _isLoading
                      ? const CupertinoActivityIndicator(
                          radius: 12,
                          color: Colors.white,
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.lock_fill,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Reset Password",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Back to Login
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.back,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Kembali ke Login",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}