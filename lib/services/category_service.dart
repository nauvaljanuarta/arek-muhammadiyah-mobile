import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/connection/db.dart';
import '../models/category.dart';

class CategoryService {
  static Future<List<Category>> getCategories({
    int page = 1,
    int limit = 10,
    bool activeOnly = false,
  }) async {
    final url = Uri.parse(
      '${Connection.baseUrl}/categories?page=$page&limit=$limit&active=$activeOnly',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final categories = (data['data'] as List)
            .map((e) => Category.fromJson(e))
            .toList();
        return categories;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to Fetch Category (${response.statusCode})');
    }
  }

  
}
