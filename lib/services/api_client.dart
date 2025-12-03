import 'dart:convert';
import 'package:MuhammadiyahApp/config/connection/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart'; 
import '../pages/auth/login_page.dart'; 
import '../../main.dart'; // Import navigatorKey

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Ganti sesuai IP Laptop/Server kamu
  final String baseUrl = Connection.baseUrl; 

  Future<Map<String, String>> getHeaders({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      
      final requestUrl = response.request?.url.toString().toLowerCase() ?? '';
      
      if (requestUrl.contains('/auth/login')) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? "Nomor Telepon atau Password salah.");
      }

      
      await UserService.logout(); 
      
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
      
      throw Exception("Sesi login telah habis. Silakan login kembali.");
    }

    if (response.statusCode >= 400) {
       final body = jsonDecode(response.body);
       throw Exception(body['message'] ?? "Terjadi kesalahan pada server (${response.statusCode})");
    }

    return response;
  }

  Future<http.Response> get(String endpoint, {bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    final response = await http.get(url, headers: headers);
    return _handleResponse(response);
  }

  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    final response = await http.post(url, headers: headers, body: jsonEncode(body ?? {}));
    return _handleResponse(response);
  }

  Future<http.Response> put(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    final response = await http.put(url, headers: headers, body: jsonEncode(body ?? {}));
    return _handleResponse(response);
  }

  Future<http.Response> delete(String endpoint, {bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    final response = await http.delete(url, headers: headers);
    return _handleResponse(response);
  }
}