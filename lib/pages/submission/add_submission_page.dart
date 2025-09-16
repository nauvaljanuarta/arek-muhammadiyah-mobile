import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../../widgets/submission_form_widget.dart';

class AddSubmissionPage extends StatelessWidget {
  const AddSubmissionPage({super.key});

  void _handleSubmission(BuildContext context, Map<String, dynamic> submissionData) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Berhasil'),
        content: const Text('Pengajuan Anda telah berhasil dikirim dan sedang dalam proses review'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to submission page
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.primaryDark,
        middle: const Text(
          'Buat Pengajuan',
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.white,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryMedium, AppTheme.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      CupertinoIcons.add_circled_solid,
                      color: CupertinoColors.white,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengajuan Baru',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: CupertinoColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Isi form di bawah untuk membuat pengajuan',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: CupertinoColors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SubmissionFormWidget(
                onSubmit: (data) => _handleSubmission(context, data),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
