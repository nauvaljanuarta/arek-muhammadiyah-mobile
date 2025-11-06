import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/connection/db.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static User? currentUser;

  // === LOGIN ===
  static Future<bool> login({
    required String id,
    required String password,
  }) async {
    final url = Uri.parse('${Connection.baseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'password': password}),
    );

    final data = jsonDecode(response.body);
    print('Response login: $data');

    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['data']?['token'];
      final userData = data['data']?['user'];

      if (token != null && userData != null) {
        final prefs = await SharedPreferences.getInstance();

        // Simpan token dan data user
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(userData));

        // Set user saat ini
        currentUser = User.fromJson(userData);
      }

      return true;
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

  // === LOAD USER DARI STORAGE ===
  static Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson != null) {
      currentUser = User.fromJson(jsonDecode(userJson));
    }
  }

  // === LOGOUT ===
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    currentUser = null;
  }

  // === REGISTER ===
  static Future<User> register({
    required String name,
    required String password,
    required int roleId,
    required String villageId,
    required String nik,
    required String address,
  }) async {
    final url = Uri.parse('${Connection.baseUrl}/users');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'password': password,
        'role_id': roleId,
        'village_id': villageId,
        'nik': nik,
        'address': address,
        'is_mobile': true,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to register (${response.statusCode})');
    }
  }

  // === GET ALL ===
  static Future<List<User>> getUsers({int page = 1, int limit = 10}) async {
    final url = Uri.parse('${Connection.baseUrl}/users?page=$page&limit=$limit');
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List).map((e) => User.fromJson(e)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to fetch users (${response.statusCode})');
    }
  }

  // === GET BY ID ===
static Future<User> getUserById(String id) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // ambil token login

    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login ulang.');
    }

    final url = Uri.parse('${Connection.baseUrl}/users/$id');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // kirim token JWT
      },
    );
    print('GET /users/$id -> ${response.statusCode}'); // debug
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        return User.fromJson(data['data']);
      } else {
        throw Exception('User not found');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Silakan login ulang');
    } else {
      throw Exception('Failed to fetch user (${response.statusCode})');
    }
  } catch (e) {
    throw Exception('Error while fetching user: $e');
  }
}


  // === UPDATE ===
  static Future<User> updateUser(String id, Map<String, dynamic> body) async {
    final url = Uri.parse('${Connection.baseUrl}/users/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to update user (${response.statusCode})');
    }
  }

  // === DELETE ===
  static Future<bool> deleteUser(String id) async {
    final url = Uri.parse('${Connection.baseUrl}/users/$id');
    final response =
        await http.delete(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Failed to delete user (${response.statusCode})');
    }
  }
}
