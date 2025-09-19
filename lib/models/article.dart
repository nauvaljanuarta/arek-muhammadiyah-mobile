class Article {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final String photo;
  final String categoryId;
  final String authorId;
  final DateTime publishedAt;
  final DateTime createdAt;
  final int views;
  final bool isPublished;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.photo,
    required this.categoryId,
    required this.authorId,
    required this.publishedAt,
    required this.createdAt,
    required this.views,
    required this.isPublished,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      excerpt: json['excerpt'],
      photo: json['photo'],
      categoryId: json['category_id'],
      authorId: json['author_id'],
      publishedAt: DateTime.parse(json['published_at']),
      createdAt: DateTime.parse(json['created_at']),
      views: json['views'],
      isPublished: json['is_published'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'photo': photo,
      'category_id': categoryId,
      'author_id': authorId,
      'published_at': publishedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'views': views,
      'is_published': isPublished,
    };
  }
}
