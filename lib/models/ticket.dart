import 'enums.dart';
import 'document.dart';
import 'category.dart';

class Ticket {
  final int id; 
  final String userId;
  final int? categoryId; 
  final String? categoryName;
  final String title;
  final String description;
  final TicketStatus status;
  final String? resolution;
  final DateTime createdAt;
  final DateTime updatedAt; 
  final DateTime? resolvedAt;
  final List<Document> documents;
  final Category? category; 
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
    required this.updatedAt,
    this.resolvedAt,
    this.documents = const [],
    this.category,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Extract category name from nested category object
    final categoryName = json['category'] != null 
        ? json['category']['name']?.toString()
        : json['category_name']; // Fallback to direct field
    
    return Ticket(
      id: json['id'] as int? ?? 0, 
      userId: json['user_id']?.toString() ?? '',
      categoryId: json['category_id'] as int?, 
      categoryName: categoryName,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: ticketStatusFromString(json['status']?.toString() ?? 'unread'),
      resolution: json['resolution']?.toString() ?? ' ', 
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()), // ✅ Always exists in API
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'].toString())
          : null,
      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((doc) => Document.fromJson(doc))
              .toList()
          : [],
      category: json['category'] != null 
          ? Category.fromJson(json['category'])
          : null, 
    );
  }

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
        'updated_at': updatedAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
        'documents': documents.map((doc) => doc.toJson()).toList(),
        'category': category?.toJson(),
      };
}
