import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirta/features/education/data/models/article_model.dart';
import 'package:tirta/features/education/data/models/category_model.dart';
import 'package:tirta/shared/services/supabase_service.dart';

class ArticleRemoteDatasource {
  Future<List<ArticleModel>> getArticles({
    String? categorySlug,
    String? search,
  }) async {
    PostgrestList response;

    if (categorySlug != null && categorySlug.isNotEmpty) {
      response = await SupabaseService.client
          .from('articles')
          .select('*, article_categories!inner(*)')
          .eq('article_categories.slug', categorySlug)
          .order('published_at', ascending: false);
    } else if (search != null && search.isNotEmpty) {
      response = await SupabaseService.client
          .from('articles')
          .select('*, article_categories(*)')
          .ilike('title', '%$search%')
          .order('published_at', ascending: false);
    } else {
      response = await SupabaseService.client
          .from('articles')
          .select('*, article_categories(*)')
          .order('published_at', ascending: false);
    }

    return response
        .map((json) => ArticleModel.fromJson(json))
        .toList();
  }

  Future<ArticleModel> getArticleById(String id) async {
    final response = await SupabaseService.client
        .from('articles')
        .select('*, article_categories(*)')
        .eq('id', id)
        .single();

    return ArticleModel.fromJson(response);
  }

  Future<List<ArticleModel>> getFeaturedArticles() async {
    final response = await SupabaseService.client
        .from('articles')
        .select('*, article_categories(*)')
        .eq('is_featured', true)
        .order('published_at', ascending: false)
        .limit(2);

    return response
        .map((json) => ArticleModel.fromJson(json))
        .toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await SupabaseService.client
        .from('article_categories')
        .select()
        .order('name', ascending: true);

    return response
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }
}
