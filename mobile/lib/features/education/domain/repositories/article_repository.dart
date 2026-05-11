import 'package:tirta/features/education/domain/entities/article.dart';
import 'package:tirta/features/education/domain/entities/category.dart';

abstract class ArticleRepository {
  Future<List<Article>> getArticles({
    String? categorySlug,
    String? search,
  });

  Future<Article> getArticleById(String id);

  Future<List<Article>> getFeaturedArticles();

  Future<List<Category>> getCategories();
}
