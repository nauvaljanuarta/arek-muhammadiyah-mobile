import 'enums.dart'; 

class Role {
  final int id;
  final String name;
  final String description;

  Role({required this.id, required this.name, required this.description});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };
}

class User {
  final int id;
  final String name;
  final DateTime? birthDate;
  final String? telp;
  final Gender? gender;
  final String? job;
  final int? roleId;
  final String? villageId;
  final String? nik;
  final String? address;
  final bool isMobile;
  final DateTime? createdAt; 
  final DateTime? updatedAt; 

  final Role? role;
  final String? villageName;
  final String? districtId;
  final String? districtName;
  final String? cityId;
  final String? cityName;
  
  // Private field untuk data dari DB
  final bool _forceChangePassword;

  User({
    required this.id,
    required this.name,
    this.birthDate,
    this.telp,
    this.gender,
    this.job,
    this.roleId,
    this.villageId,
    this.nik,
    this.address,
    this.isMobile = false,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.villageName,
    this.districtId,
    this.districtName,
    this.cityId,
    this.cityName,
    bool forceChangePassword = false,
  }) : _forceChangePassword = forceChangePassword;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'].toString())
          : null,
      telp: json['telp']?.toString(),
      gender: genderFromString(json['gender']?.toString()),
      job: json['job']?.toString(),
      roleId: json['role_id'] is int ? json['role_id'] : int.tryParse(json['role_id']?.toString() ?? ''),
      villageId: json['village_id']?.toString(),
      nik: json['nik']?.toString(),
      address: json['address']?.toString(),
      isMobile: json['is_mobile'] == true || json['is_mobile'] == 1,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      villageName: json['village_name']?.toString(),
      districtId: json['district_id']?.toString(),
      districtName: json['district_name']?.toString(),
      cityId: json['city_id']?.toString(),
      cityName: json['city_name']?.toString(),
      forceChangePassword: json['force_change_password'] == true || 
                          json['force_change_password'] == 1 || 
                          json['force_change_password'] == "1",
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birth_date': birthDate?.toIso8601String(),
        'telp': telp,
        'gender': genderToString(gender),
        'job': job,
        'role_id': roleId,
        'village_id': villageId,
        'nik': nik,
        'address': address,
        'is_mobile': isMobile,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'role': role?.toJson(),
        'force_change_password': _forceChangePassword,
      };

  String get locationInfo {
    final parts = <String>[];
    if (villageName != null && villageName!.isNotEmpty) parts.add(villageName!);
    if (districtName != null && districtName!.isNotEmpty) parts.add('Kec. $districtName');
    if (cityName != null && cityName!.isNotEmpty) parts.add(cityName!);
    return parts.isNotEmpty ? parts.join(', ') : '-';
  }

  String get formattedNik {
    if (nik == null || nik!.isEmpty) return '-';
    if (nik!.length <= 4) return nik!;
    final chunks = <String>[];
    for (int i = 0; i < nik!.length; i += 4) {
      final end = i + 4 > nik!.length ? nik!.length : i + 4;
      chunks.add(nik!.substring(i, end));
    }
    return chunks.join('-');
  }

  bool get isProfileComplete {
    return (nik != null && nik!.isNotEmpty) &&
           (address != null && address!.isNotEmpty);
  }

  bool get forceChangePassword => _forceChangePassword;
}