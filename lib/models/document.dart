import 'package:flutter_dotenv/flutter_dotenv.dart';

class Document {
  final String id;
  final String ticketId;
  final String? articleId;
  final String title;
  final String description;
  final String filePath; // Path file di server
  final String fileName; // Nama asli file
  final int fileSize;
  final String mimeType;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    required this.id,
    required this.ticketId,
    this.articleId,
    required this.title,
    required this.description,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      ticketId: json['ticket_id'].toString(),
      articleId: json['article_id']?.toString(),
      title: json['title'],
      description: json['description'],
      filePath: json['file_path'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      mimeType: json['mime_type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'article_id': articleId,
      'title': title,
      'description': description,
      'file_path': filePath,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get downloadUrl {
    final baseUrl = dotenv.env['BASE_URL']!;
    
    return '$baseUrl/files/$id';
  }

  @override
  String toString() {
    return 'Document(id: $id, fileName: $fileName, downloadUrl: $downloadUrl)';
  }
}