import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/connection/db.dart';
import '../models/article.dart';

class ArticleService {
  static Future<List<Article>> getArticles({
    int page = 1,
    int limit = 10,
    bool? published,
  }) async {
    final url = Uri.parse(
      '${Connection.baseUrl}/articles?page=$page&limit=$limit${published != null ? '&published=$published' : ''}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final articles = (data['data'] as List)
            .map((e) => Article.fromJson(e))
            .toList();
        return articles;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to Fetch Articles (${response.statusCode})');
    }
  }

  // ✅ Get article by ID
  static Future<Article?> getArticleById(int id) async {
    final url = Uri.parse('${Connection.baseUrl}/articles/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return Article.fromJson(data['data']);
      }
    }
    return null;
  }

  // ✅ Get article by slug
  static Future<Article?> getArticleBySlug(String slug) async {
    final url = Uri.parse('${Connection.baseUrl}/articles/slug/$slug');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return Article.fromJson(data['data']);
      }
    }
    return null;
  }

  static Future<Article?> createArticle({
    required String userId,
    required String title,
    required String content,
    required int categoryId,
    String? featureImage,
    bool isPublished = false,
  }) async {
    final url = Uri.parse('${Connection.baseUrl}/articles');
    final body = jsonEncode({
      'user_id': userId,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'feature_image': featureImage,
      'is_published': isPublished,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return Article.fromJson(data['data']);
      }
    }
    return null;
  }

  // ✅ Update article
  static Future<Article?> updateArticle({
    required int id,
    required String title,
    required String content,
    required int categoryId,
    String? featureImage,
    bool isPublished = false,
  }) async {
    final url = Uri.parse('${Connection.baseUrl}/articles/$id');
    final body = jsonEncode({
      'title': title,
      'content': content,
      'category_id': categoryId,
      'feature_image': featureImage,
      'is_published': isPublished,
    });

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return Article.fromJson(data['data']);
      }
    }
    return null;
  }

  // ✅ Delete article
  static Future<bool> deleteArticle(int id) async {
    final url = Uri.parse('${Connection.baseUrl}/articles/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }
    return false;
  }
}
