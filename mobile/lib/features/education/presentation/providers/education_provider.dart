import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tirta/features/education/data/datasources/article_remote_datasource.dart';
import 'package:tirta/features/education/data/repositories/article_repository_impl.dart';
import 'package:tirta/features/education/domain/entities/article.dart';
import 'package:tirta/features/education/domain/entities/category.dart';
import 'package:tirta/features/education/domain/usecases/get_article_detail_usecase.dart';
import 'package:tirta/features/education/domain/usecases/get_articles_usecase.dart';
import 'package:tirta/features/education/domain/usecases/search_articles_usecase.dart';

// --- Providers ---

final articleRemoteDatasourceProvider = Provider<ArticleRemoteDatasource>(
  (ref) => ArticleRemoteDatasource(),
);

final articleRepositoryProvider = Provider<ArticleRepositoryImpl>(
  (ref) => ArticleRepositoryImpl(ref.read(articleRemoteDatasourceProvider)),
);

final getArticlesUseCaseProvider = Provider<GetArticlesUseCase>(
  (ref) => GetArticlesUseCase(ref.read(articleRepositoryProvider)),
);

final searchArticlesUseCaseProvider = Provider<SearchArticlesUseCase>(
  (ref) => SearchArticlesUseCase(ref.read(articleRepositoryProvider)),
);

final getArticleDetailUseCaseProvider = Provider<GetArticleDetailUseCase>(
  (ref) => GetArticleDetailUseCase(ref.read(articleRepositoryProvider)),
);

final educationProvider =
    StateNotifierProvider<EducationNotifier, EducationState>(
  (ref) => EducationNotifier(
    getArticlesUseCase: ref.read(getArticlesUseCaseProvider),
    searchArticlesUseCase: ref.read(searchArticlesUseCaseProvider),
    getArticleDetailUseCase: ref.read(getArticleDetailUseCaseProvider),
    repository: ref.read(articleRepositoryProvider),
  ),
);

// --- State ---

class EducationState {
  final List<Article> articles;
  final List<Category> categories;
  final List<Article> featuredArticles;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;
  final String searchQuery;

  const EducationState({
    this.articles = const [],
    this.categories = const [],
    this.featuredArticles = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.searchQuery = '',
  });

  EducationState copyWith({
    List<Article>? articles,
    List<Category>? categories,
    List<Article>? featuredArticles,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return EducationState(
      articles: articles ?? this.articles,
      categories: categories ?? this.categories,
      featuredArticles: featuredArticles ?? this.featuredArticles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// --- Notifier ---

class EducationNotifier extends StateNotifier<EducationState> {
  final GetArticlesUseCase _getArticlesUseCase;
  final SearchArticlesUseCase _searchArticlesUseCase;
  final GetArticleDetailUseCase _getArticleDetailUseCase;
  final ArticleRepositoryImpl _repository;

  EducationNotifier({
    required GetArticlesUseCase getArticlesUseCase,
    required SearchArticlesUseCase searchArticlesUseCase,
    required GetArticleDetailUseCase getArticleDetailUseCase,
    required ArticleRepositoryImpl repository,
  })  : _getArticlesUseCase = getArticlesUseCase,
        _searchArticlesUseCase = searchArticlesUseCase,
        _getArticleDetailUseCase = getArticleDetailUseCase,
        _repository = repository,
        super(const EducationState());

  Future<void> loadCategories() async {
    try {
      final categories = await _repository.getCategories();
      state = state.copyWith(categories: categories);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadArticles() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final articles = await _getArticlesUseCase(
        categorySlug: state.selectedCategory,
      );
      state = state.copyWith(articles: articles, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchArticles(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true, error: null);
    try {
      if (query.isEmpty) {
        await loadArticles();
        return;
      }
      final articles = await _searchArticlesUseCase(query);
      state = state.copyWith(articles: articles, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectCategory(String? slug) async {
    state = state.copyWith(selectedCategory: slug, isLoading: true, error: null);
    try {
      final articles = await _getArticlesUseCase(categorySlug: slug);
      state = state.copyWith(articles: articles, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadFeaturedArticles() async {
    try {
      final featured = await _repository.getFeaturedArticles();
      state = state.copyWith(featuredArticles: featured);
    } catch (_) {
      // Silently fail for featured articles
    }
  }

  Future<Article?> getArticleDetail(String id) async {
    try {
      return await _getArticleDetailUseCase(id);
    } catch (e) {
      return null;
    }
  }
}
