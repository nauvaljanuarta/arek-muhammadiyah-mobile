
class Village {
  final String id;
  final String name;

  Village({required this.id, required this.name});

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class District {
  final String id;
  final String name;
  final List<Village> villages;

  District({required this.id, required this.name, required this.villages});

  factory District.fromJson(Map<String, dynamic> json) {
    var list = json['villages'] != null ? json['villages'] as List : [];
    List<Village> villageList = list.map((i) => Village.fromJson(i)).toList();
    return District(
      id: json['id'] as String,
      name: json['name'] as String,
      villages: villageList,
    );
  }
}

class Regency {
  final String id;
  final String name;
  final List<District> districts;

  Regency({required this.id, required this.name, required this.districts});

  factory Regency.fromJson(Map<String, dynamic> json) {
    var list = json['districts'] != null ? json['districts'] as List : [];
    List<District> districtList = list.map((i) => District.fromJson(i)).toList();
    return Regency(
      id: json['id'] as String,
      name: json['name'] as String,
      districts: districtList,
    );
  }
}