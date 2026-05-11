import 'package:tirta/features/education/domain/entities/article.dart';
import 'package:tirta/features/education/domain/repositories/article_repository.dart';

class GetArticlesUseCase {
  final ArticleRepository _repository;

  GetArticlesUseCase(this._repository);

  Future<List<Article>> call({String? categorySlug}) {
    return _repository.getArticles(categorySlug: categorySlug);
  }
}
