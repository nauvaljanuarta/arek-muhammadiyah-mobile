import 'dart:convert';
import '../models/article.dart';
import '../services/api_client.dart';

class ArticleService {
  static final ApiClient _client = ApiClient();

  static Future<List<Article>> getArticles({
    int page = 1,
    int limit = 10,
    bool? published,
  }) async {
    final response = await _client.get(
      '/articles?page=$page&limit=$limit${published != null ? '&published=$published' : ''}',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final List articles = data['data'] ?? [];
      return articles.map((e) => Article.fromJson(e)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch articles');
    }
  }

  static Future<List<Article>> getArticlesByCategory(
    int categoryId, {
    int page = 1,
    int limit = 10,
    bool? published,
  }) async {
    final response = await _client.get(
      '/articles/category/$categoryId?page=$page&limit=$limit${published != null ? '&published=$published' : ''}',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final List articles = data['data'] ?? [];
      return articles.map((e) => Article.fromJson(e)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch articles by category');
    }
  }

  static Future<Article?> getArticleById(int id) async {
    final response = await _client.get('/articles/$id');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return Article.fromJson(data['data']);
    }
    return null;
  }

  static Future<Article?> getArticleBySlug(String slug) async {
    final response = await _client.get('/articles/slug/$slug');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return Article.fromJson(data['data']);
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
    final body = {
      'user_id': userId,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'feature_image': featureImage,
      'is_published': isPublished,
    };

    final response = await _client.post('/articles', body: body);
    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return Article.fromJson(data['data']);
    }
    return null;
  }

  static Future<Article?> updateArticle({
    required int id,
    required String title,
    required String content,
    required int categoryId,
    String? featureImage,
    bool isPublished = false,
  }) async {
    final body = {
      'title': title,
      'content': content,
      'category_id': categoryId,
      'feature_image': featureImage,
      'is_published': isPublished,
    };

    final response = await _client.put('/articles/$id', body: body);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return Article.fromJson(data['data']);
    }
    return null;
  }

  static Future<bool> deleteArticle(int id) async {
    final response = await _client.delete('/articles/$id');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    }
    return false;
  }
}