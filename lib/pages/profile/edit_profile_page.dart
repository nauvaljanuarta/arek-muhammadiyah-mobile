import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme/theme.dart';
import '../../models/user.dart';
import '../../models/enums.dart';
import '../../services/user_service.dart';
import '../../models/region.dart';

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

  // State Profile Data
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedJob;

  // State Wilayah
  List<Regency> _regencies = [];
  List<District> _districts = [];
  List<Village> _villages = [];

  Regency? _selectedRegency;
  District? _selectedDistrict;
  Village? _selectedVillage;

  bool _isSaving = false;

  // Opsi Pekerjaan
  final List<Map<String, String>> _jobOptions = const [
    { 'value': 'Belum / Tidak Bekerja', 'label': 'Belum / Tidak Bekerja' },
    { 'value': 'Mengurus Rumah Tangga', 'label': 'Mengurus Rumah Tangga' },
    { 'value': 'Pelajar / Mahasiswa', 'label': 'Pelajar / Mahasiswa' },
    { 'value': 'Pensiunan', 'label': 'Pensiunan' },
    { 'value': 'Pegawai Negeri Sipil (PNS)', 'label': 'Pegawai Negeri Sipil (PNS)' },
    { 'value': 'TNI / POLRI', 'label': 'TNI / POLRI' },
    { 'value': 'Karyawan Swasta', 'label': 'Karyawan Swasta' },
    { 'value': 'Karyawan BUMN / BUMD', 'label': 'Karyawan BUMN / BUMD' },
    { 'value': 'Wiraswasta', 'label': 'Wiraswasta' },
    { 'value': 'Lainnya', 'label': 'Lainnya' }
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
      if (mounted) {
        setState(() => _regencies = cities);
      }
    } catch (e) {
      debugPrint("Error loading cities: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- HELPERS & PICKERS ---

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

  void _showPicker<T>({
    required String title,
    required List<T> items,
    required Function(T) onSelectedItemChanged,
    required String Function(T) itemLabelBuilder,
  }) {
    FocusScope.of(context).unfocus();
    if (items.isEmpty) {
      _showError("Data tidak tersedia. Pastikan koneksi internet lancar atau pilih wilayah induk terlebih dahulu.");
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.separator, width: 0.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Selesai'),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) => onSelectedItemChanged(items[index]),
                children: items.map((item) => Center(
                  child: Text(
                    itemLabelBuilder(item),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRegencyTap() {
    _showPicker<Regency>(
      title: "Pilih Kabupaten/Kota",
      items: _regencies,
      itemLabelBuilder: (item) => item.name,
      onSelectedItemChanged: (val) async {
        if (_selectedRegency != val) {
          setState(() {
            _selectedRegency = val;
            _selectedDistrict = null;
            _selectedVillage = null;
            _districts = [];
            _villages = [];
          });
          try {
            final districts = await UserService.getDistricts(val.id);
            if (mounted) setState(() => _districts = districts);
          } catch (e) {
            _showError("Gagal memuat kecamatan");
          }
        }
      },
    );
  }

  void _onDistrictTap() {
    if (_selectedRegency == null) return _showError("Pilih Kabupaten/Kota dulu");
    _showPicker<District>(
      title: "Pilih Kecamatan",
      items: _districts,
      itemLabelBuilder: (item) => item.name,
      onSelectedItemChanged: (val) async {
        if (_selectedDistrict != val) {
          setState(() {
            _selectedDistrict = val;
            _selectedVillage = null;
            _villages = [];
          });
          try {
            final villages = await UserService.getVillages(_selectedRegency!.id, val.id);
            if (mounted) setState(() => _villages = villages);
          } catch (e) {
            _showError("Gagal memuat kelurahan");
          }
        }
      },
    );
  }

  void _onVillageTap() {
    if (_selectedDistrict == null) return _showError("Pilih Kecamatan dulu");
    _showPicker<Village>(
      title: "Pilih Kelurahan/Desa",
      items: _villages,
      itemLabelBuilder: (item) => item.name,
      onSelectedItemChanged: (val) => setState(() => _selectedVillage = val),
    );
  }

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

      if (_selectedDate != null) {
        data['birth_date'] = _selectedDate!.toUtc().toIso8601String();
      }

      if (_selectedVillage != null) {
        data['village_id'] = _selectedVillage!.id;
      }

      await UserService.updateUser(widget.user.id.toString(), data);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError("Gagal menyimpan: ${e.toString().replaceAll('Exception: ', '')}");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _formatDateDisplay(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd MMMM yyyy').format(date);
  }

  Widget _buildDisabledTextField({
    required String label, 
    required String textValue, 
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label di atas
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
              Expanded(
                child: Text(
                  textValue,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey, 
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(CupertinoIcons.lock_fill, size: 14, color: CupertinoColors.systemGrey), // Icon Gembok
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 2. WIDGET LAMA: Dimodifikasi tambah parameter 'enabled'
  Widget _buildSelectableInput({
    required String label, 
    required String? value, 
    required VoidCallback onTap,
    required IconData icon,
    bool enabled = true, // Tambah parameter ini
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ),
        GestureDetector(
          onTap: enabled ? onTap : null, // Matikan onTap jika disabled
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              // Jika disabled: Background Abu. Jika enabled: Putih.
              color: enabled ? CupertinoColors.white : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled 
                    ? AppTheme.textSecondary.withOpacity(0.2) 
                    : CupertinoColors.systemGrey4
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon, 
                  size: 20, 
                  color: enabled ? AppTheme.primaryDark : CupertinoColors.systemGrey
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? "Pilih $label",
                    style: TextStyle(
                      color: enabled 
                          ? (value != null ? AppTheme.textPrimary : AppTheme.textSecondary.withOpacity(0.5))
                          : CupertinoColors.systemGrey, // Teks jadi abu jika disabled
                      fontSize: 16,
                    ),
                  ),
                ),
                // Ganti panah dengan gembok jika disabled
                Icon(
                  enabled ? CupertinoIcons.chevron_down : CupertinoIcons.lock_fill, 
                  size: 16, 
                  color: enabled ? AppTheme.textSecondary : CupertinoColors.systemGrey
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

              _buildDisabledTextField(
                label: 'Nama Lengkap',
                textValue: widget.user.name,
                icon: CupertinoIcons.person_solid,
              ),

              _buildDisabledTextField(
                label: 'NIK',
                textValue: widget.user.nik ?? '-',
                icon: CupertinoIcons.doc_text_fill,
              ),

              _buildSelectableInput(
                label: "Tanggal Lahir", 
                value: _formatDateDisplay(_selectedDate), 
                onTap: () {}, 
                icon: CupertinoIcons.calendar,
                enabled: false, // Matikan interaksi
              ),

              _buildSelectableInput(
                label: "Jenis Kelamin",
                value: _genderOptions.firstWhere((e) => e['value'] == _selectedGender, orElse: () => {'label': _selectedGender ?? '-'})['label'],
                onTap: () {},
                icon: CupertinoIcons.person_2_fill,
                enabled: false, 
              ),

              const Divider(height: 32),
              
              const Align(alignment: Alignment.centerLeft, child: Text("Ubah Pekerjaan & Alamat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              const SizedBox(height: 16),

              _buildSelectableInput(
                label: "Pekerjaan",
                value: _selectedJob,
                onTap: () {
                  _showPicker(
                    title: "Pekerjaan",
                    items: _jobOptions,
                    itemLabelBuilder: (i) => i['label']!,
                    onSelectedItemChanged: (val) => setState(() => _selectedJob = val['value'])
                  );
                },
                icon: CupertinoIcons.briefcase,
                enabled: true, 
              ),

              const SizedBox(height: 8),
              
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Alamat Saat Ini: ${widget.user.cityName}, ${widget.user.districtName}, ${widget.user.villageName}",
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 16),

              _buildSelectableInput(
                label: "Kabupaten/Kota Baru",
                value: _selectedRegency?.name,
                onTap: _onRegencyTap,
                icon: CupertinoIcons.building_2_fill,
                enabled: true,
              ),
              if (_selectedRegency != null)
                _buildSelectableInput(
                  label: "Kecamatan Baru",
                  value: _selectedDistrict?.name,
                  onTap: _onDistrictTap,
                  icon: CupertinoIcons.map_pin_ellipse,
                  enabled: true,
                ),
              if (_selectedDistrict != null)
                _buildSelectableInput(
                  label: "Kelurahan Baru",
                  value: _selectedVillage?.name,
                  onTap: _onVillageTap,
                  icon: CupertinoIcons.flag_fill,
                  enabled: true,
                ),

              const SizedBox(height: 12),
              
              // Input Alamat Detail (Aktif)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text("Alamat Detail", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  ),
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
                  child: _isSaving
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
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