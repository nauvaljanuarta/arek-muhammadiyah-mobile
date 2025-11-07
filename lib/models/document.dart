// models/document.dart
class Document {
  final String id;
  final String ticketId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final DateTime createdAt;

  Document({
    required this.id,
    required this.ticketId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.createdAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        id: json['id'].toString(),
        ticketId: json['ticket_id'].toString(),
        fileName: json['file_name'],
        fileUrl: json['file_url'],
        fileType: json['file_type'],
        fileSize: json['file_size'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticket_id': ticketId,
        'file_name': fileName,
        'file_url': fileUrl,
        'file_type': fileType,
        'file_size': fileSize,
        'created_at': createdAt.toIso8601String(),
      };
}