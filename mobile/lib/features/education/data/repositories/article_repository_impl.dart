import 'package:tirta/features/education/data/datasources/article_remote_datasource.dart';
import 'package:tirta/features/education/domain/entities/article.dart';
import 'package:tirta/features/education/domain/entities/category.dart';
import 'package:tirta/features/education/domain/repositories/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDatasource _remoteDatasource;

  ArticleRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<Article>> getArticles({
    String? categorySlug,
    String? search,
  }) async {
    final models = await _remoteDatasource.getArticles(
      categorySlug: categorySlug,
      search: search,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Article> getArticleById(String id) async {
    final model = await _remoteDatasource.getArticleById(id);
    return model.toEntity();
  }

  @override
  Future<List<Article>> getFeaturedArticles() async {
    final models = await _remoteDatasource.getFeaturedArticles();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Category>> getCategories() async {
    final models = await _remoteDatasource.getCategories();
    return models.map((model) => model.toEntity()).toList();
  }
}
