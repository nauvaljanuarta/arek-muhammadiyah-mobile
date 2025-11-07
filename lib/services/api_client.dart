import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/connection/db.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

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

  Future<http.Response> get(String endpoint, {bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    return http.post(url, headers: headers, body: jsonEncode(body ?? {}));
  }

  Future<http.Response> put(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    return http.put(url, headers: headers, body: jsonEncode(body ?? {}));
  }

  Future<http.Response> delete(String endpoint, {bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);
    return http.delete(url, headers: headers);
  }
}
