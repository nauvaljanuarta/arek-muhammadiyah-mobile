import 'dart:convert';
import '../models/user.dart';
import 'api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final ApiClient _client = ApiClient();
  static User? currentUser;

  static Future<bool> login({
    required String telp,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      body: {'telp': telp, 'password': password},
      withAuth: false,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      final token = data['data']?['token'];
      final userData = data['data']?['user'];

      if (token != null && userData != null) {
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(userData));
        currentUser = User.fromJson(userData);
      }

      return true;
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

  static Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      currentUser = User.fromJson(jsonDecode(userJson));
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    currentUser = null;
  }

  static Future<User> register(Map<String, dynamic> body) async {
    final response = await _client.post('/users', body: {
      ...body,
      'is_mobile': true,
    }, withAuth: false);

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 && data['success'] == true) {
      return User.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Failed to register');
    }
  }

  static Future<List<User>> getUsers({int page = 1, int limit = 10}) async {
    final response = await _client.get('/users?page=$page&limit=$limit');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List).map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch users');
    }
  }

  static Future<User> getUserById(String id) async {
    final response = await _client.get('/users/$id');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return User.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch user');
    }
  }

  static Future<User> updateUser(String id, Map<String, dynamic> body) async {
    final response = await _client.put('/users/$id', body: body);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return User.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Failed to update user');
    }
  }

  static Future<bool> deleteUser(String id) async {
    final response = await _client.delete('/users/$id');
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }
}
