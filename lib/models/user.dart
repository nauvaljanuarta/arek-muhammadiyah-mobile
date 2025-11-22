import 'role.dart';
import 'enums.dart';

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
  final DateTime createdAt;
  final DateTime updatedAt;

  final Role? role;
  final String? villageName;
  final String? districtId;
  final String? districtName;
  final String? cityId;
  final String? cityName;

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
    required this.createdAt,
    required this.updatedAt,
    this.role,
    this.villageName,
    this.districtId,
    this.districtName,
    this.cityId,
    this.cityName,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        birthDate: json['birth_date'] != null
            ? DateTime.parse(json['birth_date'])
            : null,
        telp: json['telp'],
        gender: genderFromString(json['gender']),
        job: json['job'],
        roleId: json['role_id'],
        villageId: json['village_id'],
        nik: json['nik'],
        address: json['address'],
        isMobile: json['is_mobile'] ?? false,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        role: json['role'] != null ? Role.fromJson(json['role']) : null,
        villageName: json['village_name'],
        districtId: json['district_id'],
        districtName: json['district_name'],
        cityId: json['city_id'],
        cityName: json['city_name'],
      );

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
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'role': role?.toJson(),
        'village_name': villageName,
        'district_id': districtId,
        'district_name': districtName,
        'city_id': cityId,
        'city_name': cityName,
      };

    String get locationInfo {
    final parts = <String>[];
    if (villageName != null && villageName!.isNotEmpty) parts.add(villageName!);
    if (districtName != null && districtName!.isNotEmpty) parts.add('Kec. $districtName');
    if (cityName != null && cityName!.isNotEmpty) parts.add(cityName!);
    return parts.isNotEmpty ? parts.join(', ') : '-';

  }

  // Format NIK dengan pemisah
  String get formattedNik {
    if (nik == null || nik!.isEmpty) return '-';
    if (nik!.length <= 4) return nik!;
    
    // Format: XXXXX-XXXX-XXXX-XXXX
    final chunks = <String>[];
    for (int i = 0; i < nik!.length; i += 4) {
      final end = i + 4 > nik!.length ? nik!.length : i + 4;
      chunks.add(nik!.substring(i, end));
    }
    return chunks.join('-');
  }

}
