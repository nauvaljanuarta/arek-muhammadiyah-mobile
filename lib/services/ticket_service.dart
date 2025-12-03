import 'dart:convert';
import 'dart:io';
import '../models/ticket.dart';
import '../models/document.dart';
import '../services/api_client.dart';
import '../services/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'ticket_read_service.dart';

class TicketService {
  static final ApiClient _client = ApiClient();
  static const int maxFileSize = 10 * 1024 * 1024;

  static Future<List<Ticket>> getUserTickets({
    int page = 1,
    int limit = 20,
  }) async {
    final user = UserService.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await _client.get(
      '/tickets/my?page=$page&limit=$limit',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final List tickets = data['data'] ?? [];
      return tickets.map((e) => Ticket.fromJson(e)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch tickets');
    }
  }

  static Future<Ticket> getTicketById(String id) async {
    final response = await _client.get('/tickets/$id');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return Ticket.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Failed to load ticket');
    }
  }

  static Future<Ticket> createTicket({
    required String title,
    required String description,
    String? categoryId,
    List<File> files = const [],
  }) async {
    final user = UserService.currentUser;
    if (user == null) throw Exception('User not logged in');

    _validateFileSizes(files);

    return _createTicketMultipart(
      title: title,
      description: description,
      categoryId: categoryId,
      files: files,
      userId: user.id.toString(),
    );
  }

  static Future<Ticket> _createTicketMultipart({
    required String title,
    required String description,
    required String userId,
    String? categoryId,
    required List<File> files,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${_client.baseUrl}/tickets'),
    );

    final headers = await _client.getHeaders();
    request.headers.addAll(headers);

    request.fields['title'] = title;
    request.fields['description'] = description;
    if (categoryId != null) {
      request.fields['category_id'] = categoryId;
    }

    for (var file in files) {
      var multipartFile = await http.MultipartFile.fromPath(
        'documents',
        file.path,
        contentType: _getMediaType(file.path),
      );
      request.files.add(multipartFile);
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return Ticket.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Failed to create ticket');
    }
  }

  static void _validateFileSizes(List<File> files) {
    for (var file in files) {
      if (!file.existsSync()) {
        throw Exception('File not found: ${file.path.split('/').last}');
      }

      final fileSize = file.lengthSync();
      final sizeInMB = (fileSize / 1024 / 1024);

      if (fileSize > maxFileSize) {
        throw Exception(
            'File ${file.path.split('/').last} is too large (${sizeInMB.toStringAsFixed(1)}MB). Maximum 10MB allowed');
      }

      if (fileSize == 0) {
        throw Exception('File ${file.path.split('/').last} is empty');
      }
    }
  }

  static Future<List<Document>> uploadFilesToTicket({
    required String ticketId,
    required List<File> files,
  }) async {
    _validateFileSizes(files);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${_client.baseUrl}/tickets/$ticketId/upload-files'),
    );

    final headers = await _client.getHeaders();
    request.headers.addAll(headers);

    for (var file in files) {
      var multipartFile = await http.MultipartFile.fromPath(
        'documents',
        file.path,
        contentType: _getMediaType(file.path),
      );
      request.files.add(multipartFile);
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List documents = data['data'] ?? [];
      return documents.map((e) => Document.fromJson(e)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to upload files');
    }
  }

  static Future<List<Document>> getTicketFiles(String ticketId) async {
    final response = await _client.get('/tickets/$ticketId/files');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List documents = data['data'] ?? [];
      return documents.map((e) => Document.fromJson(e)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch ticket files');
    }
  }

  static Future<bool> deleteFile(String ticketId, String fileId) async {
    final response = await _client.delete('/tickets/$ticketId/files/$fileId');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to delete file');
    }
  }

  static Future<Ticket> updateTicket(
    String id, {
    String? title,
    String? description,
    String? categoryId,
    String? status,
    String? resolution,
  }) async {
    final body = {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (status != null) 'status': status,
      if (resolution != null) 'resolution': resolution,
    };

    final response = await _client.put('/tickets/$id', body: body);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return Ticket.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Failed to update ticket');
    }
  }

  static Future<bool> deleteTicket(String id) async {
    final response = await _client.delete('/tickets/$id');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to delete ticket');
    }
  }

  static MediaType? _getMediaType(String filePath) {
    final mimeType = lookupMimeType(filePath);
    if (mimeType != null) {
      return MediaType.parse(mimeType);
    }
    return null;
  }

  // --- LOGIKA BADGE DIPERBARUI DI SINI ---
  static Future<int> getUpdatedTicketsCount() async {
    try {
      // 1. Ambil tiket terbaru dari backend
      final response = await _client.get('/tickets/my?limit=100');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List ticketsData = data['data'] ?? [];
        final tickets = ticketsData.map((e) => Ticket.fromJson(e)).toList();

        int unreadCount = 0;

        for (final ticket in tickets) {
          final isUnread = await TicketReadService.isTicketUnread(ticket);
          
          if (isUnread) {
            unreadCount++;
          }
        }
        
        return unreadCount;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}