import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../services/user_service.dart';
import '../../config/theme/theme.dart';
import '../home/home_page.dart';
import '../../models/region.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController(); 
  final TextEditingController _nameController = TextEditingController();

  // Data Source List
  List<Regency> _regencies = [];
  List<District> _districts = [];
  List<Village> _villages = [];

  // Selected Items (Region)
  Regency? _selectedRegency;
  District? _selectedDistrict;
  Village? _selectedVillage;

  // Selected Items (Profile Data)
  DateTime? _selectedDate;
  String? _selectedGender; 
  String? _selectedJob;

  bool _isLoading = false;
  bool _isCitiesLoading = true;

  // Job Options
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
    { 'value': 'male', 'label': 'Laki - Laki' },
    { 'value': 'female', 'label': 'Perempuan' },
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    if (UserService.currentUser != null) {
      _nameController.text = UserService.currentUser!.name;
    }
    
    try {
      final cities = await UserService.getCities();
      if (mounted) {
        setState(() {
          _regencies = cities;
          _isCitiesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCitiesLoading = false);
    }
  }

  @override
  void dispose() {
    _nikController.dispose();
    _detailAddressController.dispose();
    _nameController.dispose();
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


  void _showPicker<T>({
    required String title,
    required List<T> items,
    required Function(T) onSelectedItemChanged,
    required String Function(T) itemLabelBuilder,
  }) {
    FocusScope.of(context).unfocus();
    if (items.isEmpty) {
      _showError("Data tidak ditemukan.");
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

  // Date Picker Helper
  Future<void> _showDatePicker() async {
  FocusScope.of(context).unfocus();

  final pickedDate = await showDatePicker(
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
      });
    }
  }


  void _onGenderTap() {
    _showPicker<Map<String, String>>(
      title: "Pilih Jenis Kelamin",
      items: _genderOptions,
      itemLabelBuilder: (item) => item['label']!,
      onSelectedItemChanged: (val) {
        setState(() => _selectedGender = val['value']);
      },
    );
    if (_selectedGender == null) {
      setState(() => _selectedGender = _genderOptions[0]['value']);
    }
  }

void _onJobTap() {
  FocusScope.of(context).unfocus();

  showCupertinoModalPopup(
    context: context,
    builder: (_) => Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, 
        height: 360,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Pilih Pekerjaan",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _jobOptions.length,
                separatorBuilder: (_, _) => const Divider(height: 0.4),
                itemBuilder: (context, index) {
                  final job = _jobOptions[index];
                  final isSelected = _selectedJob == job['value'];

                  return CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    onPressed: () {
                      setState(() {
                        _selectedJob = job['value'];
                      });
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            job['label']!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppTheme.primaryDark
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            CupertinoIcons.check_mark,
                            size: 18,
                            color: AppTheme.primaryDark,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              onPressed: () => Navigator.pop(context),
              child: SizedBox(
                width: double.infinity,
                child : const Center(child : Text("Tutup")))
                 ,
            ),
          ],
        ),
      ),
    ),
  );

  if (_selectedJob == null) {
    setState(() => _selectedJob = _jobOptions[0]['value']);
  }
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
          
          _showLoadingIndicator();
          try {
            final districts = await UserService.getDistricts(val.id);
            if (mounted) {
              Navigator.pop(context);
              setState(() => _districts = districts);
            }
          } catch (e) {
            Navigator.pop(context);
            _showError("Gagal memuat kecamatan");
          }
        }
      },
    );
  }

  void _onDistrictTap() {
    if (_selectedRegency == null) return _showError("Silakan pilih Kabupaten/Kota terlebih dahulu");
    
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

          _showLoadingIndicator();
          try {
            final villages = await UserService.getVillages(_selectedRegency!.id, val.id);
            if (mounted) {
              Navigator.pop(context);
              setState(() => _villages = villages);
            }
          } catch (e) {
            Navigator.pop(context);
            _showError("Gagal memuat desa/kelurahan");
          }
        }
      },
    );
  }

  void _onVillageTap() {
    if (_selectedDistrict == null) return _showError("Silakan pilih Kecamatan terlebih dahulu");
    
    _showPicker<Village>(
      title: "Pilih Desa/Kelurahan",
      items: _villages,
      itemLabelBuilder: (item) => item.name,
      onSelectedItemChanged: (val) {
        setState(() => _selectedVillage = val);
      },
    );
  }

  void _showLoadingIndicator() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CupertinoActivityIndicator(radius: 15)),
    );
  }

  void _submitData() async {
    // Validation
    if (_nameController.text.isEmpty) return _showError("Nama wajib diisi");
    if (_nikController.text.length != 16) return _showError("NIK harus 16 digit");
    if (_selectedDate == null) return _showError("Tanggal lahir wajib diisi");
    if (_selectedGender == null) return _showError("Jenis kelamin wajib dipilih");
    if (_selectedJob == null) return _showError("Pekerjaan wajib dipilih");
    if (_selectedVillage == null) return _showError("Silakan lengkapi data wilayah");
    if (_detailAddressController.text.isEmpty) return _showError("Alamat detail wajib diisi");

    setState(() => _isLoading = true);

    try {
      final currentUser = UserService.currentUser;
      if (currentUser == null) throw Exception("Sesi telah berakhir");

      final fullAddress = "${_detailAddressController.text}, ${_selectedVillage!.name}, ${_selectedDistrict!.name}, ${_selectedRegency!.name}";

      await UserService.updateUser(
        currentUser.id.toString(),
        {
          'name': _nameController.text,
          'nik': _nikController.text,
          'birth_date': _selectedDate!.toUtc().toIso8601String(),
          'gender': _selectedGender,
          'job': _selectedJob,
          'address': fullAddress,
          'village_id': _selectedVillage!.id,
          'is_profile_completed': true,
        },
      );

      setState(() => _isLoading = false);

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Profil berhasil dilengkapi!'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Lanjutkan'),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context, 
                    CupertinoPageRoute(builder: (_) => const HomePage())
                  );
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showError(e.toString());
    }
  }

  void _logout() {
    UserService.logout();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Readonly Input Widget
  Widget _buildSelectableInput({
    required String label, 
    required String? value, 
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primaryDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? "Pilih $label",
                    style: TextStyle(
                      color: value != null ? AppTheme.textPrimary : AppTheme.textSecondary.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(CupertinoIcons.chevron_down, size: 16, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Helper to format date for UI display
  String? _formatDateDisplay(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd MMMM yyyy').format(date);
  }

  // Helper to get gender label from value
  String? _getGenderLabel(String? value) {
    if (value == null) return null;
    final option = _genderOptions.firstWhere((e) => e['value'] == value, orElse: () => {});
    return option.isNotEmpty ? option['label'] : value;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Lengkapi Profil"),
        backgroundColor: AppTheme.background,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _logout,
          child: const Icon(CupertinoIcons.square_arrow_right, size: 24),
        ),
      ),
      child: SafeArea(
        child: _isCitiesLoading 
          ? const Center(child: CupertinoActivityIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CupertinoColors.systemOrange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.info, color: CupertinoColors.systemOrange),
                        const SizedBox(width: 12),
                        const Expanded(child: Text("Silakan lengkapi data pribadi Anda.", style: TextStyle(fontSize: 13))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text("Nama Lengkap", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _nameController,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text("NIK (Nomor Identitas Kependudukan)", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _nikController,
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.all(16),
                    maxLength: 16,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSelectableInput(
                    label: "Tanggal Lahir",
                    value: _formatDateDisplay(_selectedDate),
                    onTap: _showDatePicker,
                    icon: CupertinoIcons.calendar,
                  ),

                  _buildSelectableInput(
                    label: "Jenis Kelamin",
                    value: _getGenderLabel(_selectedGender),
                    onTap: _onGenderTap,
                    icon: CupertinoIcons.person_2_fill,
                  ),

                  _buildSelectableInput(
                    label: "Pekerjaan",
                    value: _selectedJob,
                    onTap: _onJobTap,
                    icon: CupertinoIcons.briefcase_fill,
                  ),

                  const Divider(height: 32),
                  const Text("Data Wilayah", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),

                  _buildSelectableInput(
                    label: "Kabupaten/Kota",
                    value: _selectedRegency?.name,
                    onTap: _onRegencyTap,
                    icon: CupertinoIcons.building_2_fill,
                  ),
                  _buildSelectableInput(
                    label: "Kecamatan",
                    value: _selectedDistrict?.name,
                    onTap: _onDistrictTap,
                    icon: CupertinoIcons.map_pin_ellipse,
                  ),
                  _buildSelectableInput(
                    label: "Desa/Kelurahan",
                    value: _selectedVillage?.name,
                    onTap: _onVillageTap,
                    icon: CupertinoIcons.flag_fill,
                  ),

                  const Text("Alamat Detail", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _detailAddressController,
                    placeholder: "Jalan, RT/RW",
                    maxLines: 2,
                    padding: const EdgeInsets.all(16),
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
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isLoading ? null : _submitData,
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: AppTheme.primaryDark)
                          : const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}