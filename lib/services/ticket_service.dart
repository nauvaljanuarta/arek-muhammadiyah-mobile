import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import 'user_service.dart';
import '../config/connection/db.dart';

class TicketService {
  final String baseUrl;

  /// Konstruktor default menggunakan baseUrl dari Connection
  TicketService({String? baseUrl})
      : baseUrl = baseUrl ?? Connection.baseUrl;

  /// Ambil semua ticket user
  Future<List<Ticket>> getUserTickets({
    int page = 1,
    int limit = 20,
  }) async {
    final currentUser = UserService.currentUser;
    if (currentUser == null) return [];

    final userId = currentUser.id;

    final url = Uri.parse('$baseUrl/tickets?user_id=$userId&page=$page&limit=$limit');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List ticketsJson = data['tickets'] ?? [];
      return ticketsJson.map((json) => Ticket.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  /// Ambil detail ticket
  Future<Ticket> getTicketById(String id) async {
    final url = Uri.parse('$baseUrl/tickets/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Ticket.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load ticket');
    }
  }

  /// Buat ticket baru
  Future<Ticket> createTicket({
    required String title,
    required String description,
    String? categoryId,
  }) async {
    final currentUser = UserService.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    final url = Uri.parse('$baseUrl/tickets');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': currentUser.id,
        'title': title,
        'description': description,
        'category_id': categoryId,
      }),
    );

    if (response.statusCode == 201) {
      return Ticket.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create ticket');
    }
  }

  /// Update ticket
  Future<Ticket> updateTicket({
  required String id,
  String? title,
  String? description,
  String? categoryId,
  String? status,
  String? resolution,
}) async {
  final url = Uri.parse('$baseUrl/tickets/$id');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (status != null) 'status': status,
      if (resolution != null) 'resolution': resolution,
    }),
  );

  if (response.statusCode == 200) {
    return Ticket.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update ticket');
  }
}


  /// Hapus ticket
  Future<void> deleteTicket(String id) async {
    final url = Uri.parse('$baseUrl/tickets/$id');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete ticket');
    }
  }
}
