import '../../core/riverpod.dart';
import '../models/article.dart';
import 'seed_data.dart';

class JournalRepository extends StateNotifier<List<ArticleModel>> {
  JournalRepository() : super(List.of(seedArticles));

  ArticleModel? getById(String id) {
    try {
      return state.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void addArticle(ArticleModel article) {
    state = [article, ...state];
  }
}

final journalRepositoryProvider =
    StateNotifierProvider<JournalRepository, List<ArticleModel>>((ref) {
  return JournalRepository();
});
