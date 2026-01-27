import 'dart:convert';
import '../models/user.dart';
import '../models/region.dart';
import 'api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  profileIncomplete,
  passwordChangeRequired,
}

class UserService {
  static final ApiClient _client = ApiClient();
  static User? currentUser;

  /// --- AUTH CHECK ---
  static Future<AuthStatus> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return AuthStatus.unauthenticated;

    final user = User.fromJson(jsonDecode(userJson));
    currentUser = user;

    if (user.forceChangePassword) return AuthStatus.passwordChangeRequired;
    if (!user.isProfileComplete) return AuthStatus.profileIncomplete;

    return AuthStatus.authenticated;
  }

  static Future<bool> validateToken() async {
    try {
      final response = await _client.get('/auth/navbar');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// --- LOGIN & REGISTER ---
  static Future<bool> login({required String telp, required String password}) async {
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
        currentUser = User.fromJson(userData);
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(userData));
      }
      return true;
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

    static Future<User> updateUser(String id, Map<String, dynamic> body) async {
    final response = await _client.put('/users/$id', body: body);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final updatedUser = User.fromJson(data['data']);
      if (currentUser != null && currentUser!.id == updatedUser.id) {
        currentUser = updatedUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data['data']));
      }
      return updatedUser;
    } else {
      throw Exception(data['message'] ?? 'Failed to update user');
    }
  }

  static Future<User> register(Map<String, dynamic> body) async {
    final response = await _client.post('/auth/register', body: {
      ...body,
      'is_mobile': true,
      'role_id': 3,
    }, withAuth: false);

    final data = jsonDecode(response.body);
    if ((response.statusCode == 201 || response.statusCode == 200) && data['success'] == true) {
      return User.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Gagal mendaftar');
    }
  }


  /// --- LOGOUT & STORAGE ---
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    currentUser = null;
  }

  static Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final savedToken = prefs.getString('token');

    if (userJson != null && savedToken != null) {
      try {
        currentUser = User.fromJson(jsonDecode(userJson));
      } catch (e) {
        await logout();
      }
    }
  }

  /// --- WILAYAH FETCHING ---
  static Future<List<Regency>> getCities() async {
    final response = await _client.get('/wilayah/cities');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List).map((e) => Regency.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat kota');
    }
  }

  static Future<List<District>> getDistricts(String cityId) async {
    final response = await _client.get('/wilayah/cities/$cityId/districts');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List).map((e) => District.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat kecamatan');
    }
  }

  static Future<List<Village>> getVillages(String cityId, String districtId) async {
    final response = await _client.get('/wilayah/cities/$cityId/districts/$districtId/villages');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List).map((e) => Village.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat kelurahan');
    }
  }

  /// --- USERS CRUD ---
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

  static Future<bool> deleteUser(String id) async {
    final response = await _client.delete('/users/$id');
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

static Future<bool> forgotPassword({
    required String name,
    required DateTime birthDate,
    required String nik,
    required String telp,
  }) async {
    final response = await _client.post(
      '/auth/forgot',
      body: {
        'name': name,
        'birth_date': birthDate.toIso8601String().split('T').first,
        'nik': nik,
        'telp': telp,
      },
      withAuth: false,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Gagal reset password');
    }
  }
}
