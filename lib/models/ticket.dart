import 'enums.dart';
import 'document.dart';

class Ticket {
  final String id;
  final String userId;
  final String? categoryId;
  final String? categoryName;
  final String title;
  final String description;
  final TicketStatus status;
  final String? resolution;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final List<Document> documents; 

  Ticket({
    required this.id,
    required this.userId,
    this.categoryId,
    this.categoryName,
    required this.title,
    required this.description,
    required this.status,
    this.resolution,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.documents = const [],
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json['id'].toString(),
        userId: json['user_id'].toString(),
        categoryId: json['category_id']?.toString(),
        categoryName: json['category_name'],
        title: json['title'],
        description: json['description'],
        status: ticketStatusFromString(json['status']),
        resolution: json['resolution'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        resolvedAt: json['resolved_at'] != null
            ? DateTime.parse(json['resolved_at'])
            : null,
        documents: json['documents'] != null
            ? (json['documents'] as List)
                .map((doc) => Document.fromJson(doc))
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'category_id': categoryId,
        'category_name': categoryName,
        'title': title,
        'description': description,
        'status': ticketStatusToString(status),
        'resolution': resolution,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
        'documents': documents.map((doc) => doc.toJson()).toList(),
      };
}