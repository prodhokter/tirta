import 'package:tirta/features/education/domain/entities/article.dart';
import 'package:tirta/features/education/domain/repositories/article_repository.dart';

class GetArticleDetailUseCase {
  final ArticleRepository _repository;

  GetArticleDetailUseCase(this._repository);

  Future<Article> call(String id) {
    return _repository.getArticleById(id);
  }
}
