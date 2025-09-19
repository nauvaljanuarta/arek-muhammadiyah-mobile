class Ticket {
  final String id;
  final String userId;
  final String categoryId;
  final String title;
  final String description;
  final String? photo;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminNote;

  Ticket({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    this.photo,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.adminNote,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      title: json['title'],
      description: json['description'],
      photo: json['photo'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      adminNote: json['admin_note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'photo': photo,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'admin_note': adminNote,
    };
  }
}