import 'category.dart';
import 'user.dart';

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
  final User? user; // Ganti dari 'author' menjadi 'user'
  final Category? category;

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
    this.user,
    this.category,
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
        user: json['user'] != null ? User.fromJson(json['user']) : null, // Ganti 'author' menjadi 'user'
        category: json['category'] != null ? Category.fromJson(json['category']) : null,
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
        'user': user?.toJson(), 
        'category': category?.toJson(),
      };

  String get authorName => user?.name ?? 'Unknown Author';
  String get categoryName => category?.name ?? 'Uncategorized';

  String get formattedDate {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return formattedDate;
    }
  }
}