class ForgotPasswordRequest {
  final String name;
  final String birthDate; 
  final String nik;
  final String? telp;

  ForgotPasswordRequest({
    required this.name,
    required this.birthDate,
    required this.nik,
    required this.telp,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'birth_date': birthDate,
    'nik': nik,
    'telp': telp,
  };
}