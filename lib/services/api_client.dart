import 'dart:convert';
import 'package:MuhammadiyahApp/config/connection/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart'; 
import '../pages/auth/login_page.dart'; 
import '../../main.dart'; 

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

  bool _isHandling401 = false;

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      if (_isHandling401) {
        throw Exception("Unauthorized");
      }

      _isHandling401 = true;
      await UserService.logout();

      final context = navigatorKey.currentContext;
      if (context != null) {
        await showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CupertinoAlertDialog(
            title: const Text("Sesi Berakhir"),
            content: const Text(
              "Sesi login kamu telah habis. Silakan login kembali.",
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute(builder: (_) => const LoginPage()),
                    (_) => false,
                  );
                },
              ),
            ],
          ),
        );
      }

      _isHandling401 = false;
      throw Exception("Unauthorized");
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