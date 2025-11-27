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
    // ❌ HAPUS parameter ini
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Parse documents
    List<Document> documents = [];
    if (json['documents'] != null && json['documents'] is List) {
      documents = (json['documents'] as List)
          .map((doc) => Document.fromJson(doc))
          .toList();
    }

    // Parse category
    Category? category;
    if (json['category'] != null && json['category'] is Map<String, dynamic>) {
      category = Category.fromJson(json['category']);
    }

    // Extract category name
    final categoryName = category?.name ?? 
                        json['category_name']?.toString() ?? 
                        (json['category'] is Map ? json['category']['name']?.toString() : null);

    // Parse ticket ID
    int ticketId = 0;
    if (json['id'] is int) {
      ticketId = json['id'];
    } else if (json['id'] is String) {
      ticketId = int.tryParse(json['id']) ?? 0;
    }

    // Parse user ID
    String userId = '';
    if (json['user_id'] is String) {
      userId = json['user_id'];
    } else if (json['user_id'] != null) {
      userId = json['user_id'].toString();
    }

    // Parse category ID
    int? categoryId;
    if (json['category_id'] is int) {
      categoryId = json['category_id'];
    } else if (json['category_id'] is String) {
      categoryId = int.tryParse(json['category_id']);
    }

    return Ticket(
      id: ticketId,
      userId: userId,
      categoryId: categoryId,
      categoryName: categoryName,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: ticketStatusFromString(json['status']?.toString() ?? 'unread'),
      resolution: json['resolution']?.toString(), 
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()), 
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'].toString())
          : null,
      documents: documents,
      category: category,
      // ❌ HAPUS field yang tidak ada di database
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
        // ❌ HAPUS field yang tidak ada di database
      };

  // Copy with method untuk update data
  Ticket copyWith({
    int? id,
    String? userId,
    int? categoryId,
    String? categoryName,
    String? title,
    String? description,
    TicketStatus? status,
    String? resolution,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    List<Document>? documents,
    Category? category,
  }) {
    return Ticket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      resolution: resolution ?? this.resolution,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      documents: documents ?? this.documents,
      category: category ?? this.category,
    );
  }

  bool get hasUpdates {
    return status != TicketStatus.unread || 
           (resolution != null && resolution!.isNotEmpty);
  }

  bool get isRead {
    return status != TicketStatus.unread || 
           (resolution != null && resolution!.isNotEmpty);
  }

  @override
  String toString() {
    return 'Ticket(id: $id, title: $title, status: $status, hasUpdates: $hasUpdates)';
  }
}