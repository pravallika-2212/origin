import '../../core/riverpod.dart';
import '../models/product.dart';

class WishlistNotifier extends StateNotifier<List<Product>> {
  WishlistNotifier() : super(const []);

  bool toggle(Product product) {
    final exists = state.any((p) => p.id == product.id);
    if (exists) {
      state = state.where((p) => p.id != product.id).toList();
      return false; // Removed
    } else {
      state = [product, ...state];
      return true; // Added
    }
  }

  bool contains(String productId) {
    return state.any((p) => p.id == productId);
  }

  void remove(String productId) {
    state = state.where((p) => p.id != productId).toList();
  }

  void clear() {
    state = const [];
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<Product>>((ref) {
  return WishlistNotifier();
});
