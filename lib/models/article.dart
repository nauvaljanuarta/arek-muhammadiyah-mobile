class Article {
  final int id;
  final String userId;
  final int? categoryId;
  final String title;
  final String slug;
  final String content;
  final String? featureImage;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.title,
    required this.slug,
    required this.content,
    this.featureImage,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['id'],
        userId: json['user_id'].toString(),
        categoryId: json['category_id'],
        title: json['title'],
        slug: json['slug'],
        content: json['content'],
        featureImage: json['feature_image'],
        isPublished: json['is_published'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'category_id': categoryId,
        'title': title,
        'slug': slug,
        'content': content,
        'feature_image': featureImage,
        'is_published': isPublished,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
