import 'package:tirta/features/education/data/models/category_model.dart';
import 'package:tirta/features/education/domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.slug,
    super.excerpt,
    required super.content,
    super.imageUrl,
    super.categoryId,
    required super.readTimeMinutes,
    required super.author,
    super.isFeatured,
    super.publishedAt,
    super.category,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    CategoryModel? categoryModel;
    if (json['article_categories'] != null) {
      final catData = json['article_categories'];
      if (catData is Map<String, dynamic>) {
        categoryModel = CategoryModel.fromJson(catData);
      }
    }

    return ArticleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      excerpt: json['excerpt'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      categoryId: json['category_id'] as int?,
      readTimeMinutes: json['read_time_minutes'] as int? ?? 3,
      author: json['author'] as String? ?? 'Tim TIRTA',
      isFeatured: json['is_featured'] as bool? ?? false,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      category: categoryModel?.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'excerpt': excerpt,
      'content': content,
      'image_url': imageUrl,
      'category_id': categoryId,
      'read_time_minutes': readTimeMinutes,
      'author': author,
      'is_featured': isFeatured,
      'published_at': publishedAt?.toIso8601String(),
    };
  }

  Article toEntity() {
    return Article(
      id: id,
      title: title,
      slug: slug,
      excerpt: excerpt,
      content: content,
      imageUrl: imageUrl,
      categoryId: categoryId,
      readTimeMinutes: readTimeMinutes,
      author: author,
      isFeatured: isFeatured,
      publishedAt: publishedAt,
      category: category,
    );
  }

  factory ArticleModel.fromEntity(Article entity) {
    return ArticleModel(
      id: entity.id,
      title: entity.title,
      slug: entity.slug,
      excerpt: entity.excerpt,
      content: entity.content,
      imageUrl: entity.imageUrl,
      categoryId: entity.categoryId,
      readTimeMinutes: entity.readTimeMinutes,
      author: entity.author,
      isFeatured: entity.isFeatured,
      publishedAt: entity.publishedAt,
      category: entity.category,
    );
  }
}
