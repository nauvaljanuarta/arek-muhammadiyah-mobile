import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/connection/db.dart'; 
import '../services/user_service.dart'; 
import '../pages/auth/login_page.dart'; 
import '../../main.dart'; 

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Ganti dengan URL aslimu
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

  // Fungsi helper untuk handle response error 401
  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Token Expired atau Invalid
      await UserService.logout(); // Hapus data di HP
      
      // Paksa pindah ke Login Page menggunakan Global Key
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
      throw Exception("Sesi habis, silakan login kembali.");
    }
    return response;
  }

  Future<http.Response> get(String endpoint, {bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    final response = await http.get(url, headers: headers);
    return _handleResponse(response); // Cek 401
  }

  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    final response = await http.post(url, headers: headers, body: jsonEncode(body ?? {}));
    return _handleResponse(response); // Cek 401
  }

  Future<http.Response> put(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    final response = await http.put(url, headers: headers, body: jsonEncode(body ?? {}));
    return _handleResponse(response); // Cek 401
  }

  Future<http.Response> delete(String endpoint, {bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    final response = await http.delete(url, headers: headers);
    return _handleResponse(response); // Cek 401
  }
}