import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider;
import 'package:intl/intl.dart';
import '../../config/theme/theme.dart';
import '../../models/user.dart';
import '../../models/enums.dart';
import '../../services/user_service.dart';
import '../../models/region.dart';
import '../../widgets/profile/searchable_modal.dart'; // Pastikan path ini benar

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _nikController;
  late TextEditingController _addressController;

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedJob;

  List<Regency> _regencies = [];
  List<District> _districts = [];
  List<Village> _villages = [];

  Regency? _selectedRegency;
  District? _selectedDistrict;
  Village? _selectedVillage;

  bool _isSaving = false;

  final List<Map<String, String>> _jobOptions = const [
    { 'value': 'Belum / Tidak Bekerja', 'label': 'Belum / Tidak Bekerja' },
    { 'value': 'Mengurus Rumah Tangga', 'label': 'Mengurus Rumah Tangga' },
    { 'value': 'Pelajar / Mahasiswa', 'label': 'Pelajar / Mahasiswa' },
    { 'value': 'Pensiunan', 'label': 'Pensiunan' },
    { 'value': 'Pegawai Negeri Sipil (PNS) / ASN', 'label': 'Pegawai Negeri Sipil (PNS) / ASN' },
    { 'value': 'TNI / POLRI', 'label': 'TNI / POLRI' },
    { 'value': 'Karyawan Swasta', 'label': 'Karyawan Swasta' },
    { 'value': 'Karyawan BUMN / BUMD', 'label': 'Karyawan BUMN / BUMD' },
    { 'value': 'Wiraswasta', 'label': 'Wiraswasta' },
    { 'value': 'Lainnya', 'label': 'Profesi Lainnya' }
  ];

  final List<Map<String, String>> _genderOptions = const [
    { 'value': 'male', 'label': 'Laki-laki' },
    { 'value': 'female', 'label': 'Perempuan' },
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadRegencies();
  }

  void _initializeData() {
    _nameController = TextEditingController(text: widget.user.name);
    _nikController = TextEditingController(text: widget.user.nik);
    _addressController = TextEditingController(text: widget.user.address);
    _selectedDate = widget.user.birthDate;
    _selectedJob = widget.user.job;
    if (widget.user.gender != null) {
      _selectedGender = widget.user.gender == Gender.male ? 'male' : 'female';
    }
  }

  Future<void> _loadRegencies() async {
    try {
      final cities = await UserService.getCities();
      if (mounted) setState(() => _regencies = cities);
    } catch (e) {
      debugPrint("Error load kota: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- HELPERS ---

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Perhatian'),
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

  void _showLoadingIndicator() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CupertinoActivityIndicator(radius: 15)),
    );
  }

  // --- REGION TAPS WITH SEARCHABLE MODAL ---

  void _onRegencyTap() {
    showSearchableModal<Regency>(
      context: context,
      title: "Pilih Kabupaten/Kota",
      items: _regencies,
      itemLabel: (e) => e.name,
      onSelected: (val) async {
        if (_selectedRegency?.id == val.id) return;

        setState(() {
          _selectedRegency = val;
          _selectedDistrict = null;
          _selectedVillage = null;
          _districts = [];
          _villages = [];
        });

        _showLoadingIndicator();
        try {
          final districts = await UserService.getDistricts(val.id);
          if (mounted) {
            Navigator.pop(context); // Tutup Loading
            setState(() => _districts = districts);
          }
        } catch (_) {
          Navigator.pop(context);
          _showError("Gagal memuat kecamatan");
        }
      },
    );
  }

  void _onDistrictTap() {
    if (_selectedRegency == null) return _showError("Pilih Kabupaten/Kota dulu");
    
    showSearchableModal<District>(
      context: context,
      title: "Pilih Kecamatan",
      items: _districts,
      itemLabel: (e) => e.name,
      onSelected: (val) async {
        if (_selectedDistrict?.id == val.id) return;

        setState(() {
          _selectedDistrict = val;
          _selectedVillage = null;
          _villages = [];
        });

        _showLoadingIndicator();
        try {
          final villages = await UserService.getVillages(_selectedRegency!.id, val.id);
          if (mounted) {
            Navigator.pop(context); // Tutup Loading
            setState(() => _villages = villages);
          }
        } catch (_) {
          Navigator.pop(context);
          _showError("Gagal memuat kelurahan");
        }
      },
    );
  }

  void _onVillageTap() {
    if (_selectedDistrict == null) return _showError("Pilih Kecamatan dulu");
    
    showSearchableModal<Village>(
      context: context,
      title: "Pilih Kelurahan/Desa",
      items: _villages,
      itemLabel: (e) => e.name,
      onSelected: (val) => setState(() => _selectedVillage = val),
    );
  }

  // --- SAVE LOGIC ---

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> data = {
        'name': _nameController.text,
        'nik': _nikController.text,
        'address': _addressController.text,
        'job': _selectedJob,
        'gender': _selectedGender,
      };

      if (_selectedDate != null) data['birth_date'] = _selectedDate!.toUtc().toIso8601String();
      if (_selectedVillage != null) data['village_id'] = _selectedVillage!.id;

      await UserService.updateUser(widget.user.id.toString(), data);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showError("Gagal menyimpan: ${e.toString().replaceAll('Exception: ', '')}");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- UI COMPONENTS ---

  Widget _buildDisabledTextField({required String label, required String textValue, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CupertinoColors.systemGrey4),
          ),
          child: Row(
            children: [
              Icon(icon, color: CupertinoColors.systemGrey),
              const SizedBox(width: 12),
              Expanded(child: Text(textValue, style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 16))),
              const Icon(CupertinoIcons.lock_fill, size: 14, color: CupertinoColors.systemGrey),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSelectableInput({required String label, required String? value, required VoidCallback onTap, required IconData icon, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: enabled ? CupertinoColors.white : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: enabled ? AppTheme.textSecondary.withOpacity(0.2) : CupertinoColors.systemGrey4),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: enabled ? AppTheme.primaryDark : CupertinoColors.systemGrey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? "Pilih $label",
                    style: TextStyle(
                      color: enabled ? (value != null ? AppTheme.textPrimary : AppTheme.textSecondary.withOpacity(0.5)) : CupertinoColors.systemGrey,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(enabled ? CupertinoIcons.chevron_down : CupertinoIcons.lock_fill, size: 16, color: enabled ? AppTheme.textSecondary : CupertinoColors.systemGrey),
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
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Edit Profil'),
        backgroundColor: AppTheme.background,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Align(alignment: Alignment.centerLeft, child: Text("Data Pribadi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              const SizedBox(height: 16),
              _buildDisabledTextField(label: 'Nama Lengkap', textValue: widget.user.name, icon: CupertinoIcons.person_solid),
              _buildDisabledTextField(label: 'NIK', textValue: widget.user.nik ?? '-', icon: CupertinoIcons.doc_text_fill),
              _buildSelectableInput(label: "Tanggal Lahir", value: DateFormat('dd MMMM yyyy').format(_selectedDate ?? DateTime.now()), onTap: () {}, icon: CupertinoIcons.calendar, enabled: false),
              _buildSelectableInput(label: "Jenis Kelamin", value: _genderOptions.firstWhere((e) => e['value'] == _selectedGender, orElse: () => {'label': '-'})['label'], onTap: () {}, icon: CupertinoIcons.person_2_fill, enabled: false),
              
              const Divider(height: 32),
              const Align(alignment: Alignment.centerLeft, child: Text("Ubah Pekerjaan & Alamat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              const SizedBox(height: 16),
              
              _buildSelectableInput(
                label: "Pekerjaan",
                value: _selectedJob,
                onTap: () {
                  showSearchableModal<Map<String, String>>(
                    context: context,
                    title: "Pilih Pekerjaan",
                    items: _jobOptions,
                    itemLabel: (i) => i['label']!,
                    onSelected: (val) => setState(() => _selectedJob = val['value']),
                  );
                },
                icon: CupertinoIcons.briefcase,
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Alamat Saat Ini: ${widget.user.cityName}, ${widget.user.districtName}, ${widget.user.villageName}",
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 16),

              _buildSelectableInput(label: "Kabupaten/Kota Baru", value: _selectedRegency?.name, onTap: _onRegencyTap, icon: CupertinoIcons.building_2_fill),
              if (_selectedRegency != null) _buildSelectableInput(label: "Kecamatan Baru", value: _selectedDistrict?.name, onTap: _onDistrictTap, icon: CupertinoIcons.map_pin_ellipse),
              if (_selectedDistrict != null) _buildSelectableInput(label: "Kelurahan Baru", value: _selectedVillage?.name, onTap: _onVillageTap, icon: CupertinoIcons.flag_fill),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.only(left: 4, bottom: 8), child: Text("Alamat Detail", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14))),
                  CupertinoTextField(
                    controller: _addressController,
                    placeholder: 'Jalan, RT/RW',
                    maxLines: 3,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving ? const CupertinoActivityIndicator(color: Colors.white) : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}