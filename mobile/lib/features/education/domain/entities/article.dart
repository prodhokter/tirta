import 'package:tirta/features/education/domain/entities/category.dart';

class Article {
  final String id;
  final String title;
  final String slug;
  final String? excerpt;
  final String content;
  final String? imageUrl;
  final int? categoryId;
  final int readTimeMinutes;
  final String author;
  final bool isFeatured;
  final DateTime? publishedAt;
  final Category? category;

  const Article({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    required this.content,
    this.imageUrl,
    this.categoryId,
    required this.readTimeMinutes,
    required this.author,
    this.isFeatured = false,
    this.publishedAt,
    this.category,
  });
}
