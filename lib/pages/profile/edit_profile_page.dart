import 'package:flutter/cupertino.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _addressController = TextEditingController(text: widget.user.address);
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      await UserService.updateUser(widget.user.id.toString(), {
        'name': _nameController.text,
        'address': _addressController.text,
      });
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error update: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Edit Profil'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CupertinoTextField(
                controller: _nameController,
                placeholder: 'Nama',
                padding: const EdgeInsets.all(14),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _addressController,
                placeholder: 'Alamat',
                padding: const EdgeInsets.all(14),
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? const CupertinoActivityIndicator()
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
