import 'package:tirta/features/education/domain/entities/article.dart';
import 'package:tirta/features/education/domain/repositories/article_repository.dart';

class SearchArticlesUseCase {
  final ArticleRepository _repository;

  SearchArticlesUseCase(this._repository);

  Future<List<Article>> call(String query) {
    return _repository.getArticles(search: query);
  }
}
