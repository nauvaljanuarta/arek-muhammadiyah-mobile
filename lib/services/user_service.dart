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
  static String? _token;

  static const String _adminDefaultPassword = 'password123'; 

  static String? get token => _token;

  static Future<AuthStatus> checkAuthStatus() async {
    if (currentUser == null) {
      await loadUserFromStorage();
    }

    if (currentUser == null) return AuthStatus.unauthenticated;

    final prefs = await SharedPreferences.getInstance();
    final isDefaultPass = prefs.getBool('is_using_default_pass') ?? false;

    if (isDefaultPass) return AuthStatus.passwordChangeRequired;
    if (!currentUser!.isProfileComplete) return AuthStatus.profileIncomplete;

    return AuthStatus.authenticated;
}


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
        _token = token;
        currentUser = User.fromJson(userData);
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(userData));

        if (password == _adminDefaultPassword) {
          await prefs.setBool('is_using_default_pass', true);
        } else {
          await prefs.setBool('is_using_default_pass', false);
        }
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
      if (currentUser != null && currentUser!.id.toString() == id) {
        currentUser = User.fromJson(data['data']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data['data']));
        
        if (body.containsKey('password')) {
           await prefs.setBool('is_using_default_pass', false);
        }
      }
      return User.fromJson(data['data']);
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

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('is_using_default_pass'); // Bersihkan flag
    
    _token = null;
    currentUser = null;
  }

  static Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final savedToken = prefs.getString('token');

    if (userJson != null && savedToken != null) {
      _token = savedToken;
      try {
        currentUser = User.fromJson(jsonDecode(userJson));
      } catch (e) {
        await logout();
      }
    }
  }

  static Future<bool> isStillLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token = prefs.getString('token');
    return isLoggedIn && token != null && token.isNotEmpty;
  }

  // --- WILAYAH FETCHING ---
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
}