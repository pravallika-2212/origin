import '../../core/riverpod.dart';
import '../models/order.dart';
import '../models/product.dart';

class CartState {
  const CartState({this.items = const []});

  final List<OrderItem> items;

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotalUsd => items.fold(0.0, (sum, i) => sum + i.total);

  // White glove secure insured art transport
  double get shippingCostUsd {
    if (items.isEmpty) return 0.0;
    return subtotalUsd > 10000 ? 0.0 : 150.0;
  }

  double get totalUsd => subtotalUsd + shippingCostUsd;

  bool containsProduct(String productId) =>
      items.any((i) => i.product.id == productId);

  bool hasAntique() =>
      items.any((i) => i.product.type == ProductType.certifiedAntique);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  bool add(Product product) {
    final existingIndex =
        state.items.indexWhere((i) => i.product.id == product.id);

    // Antiques are strictly single-quantity unique pieces!
    if (product.type == ProductType.certifiedAntique) {
      if (existingIndex >= 0) {
        return false; // Already in bag as unique piece
      }
      state = CartState(
        items: [
          ...state.items,
          OrderItem(product: product, quantity: 1, priceUsd: product.priceUsd),
        ],
      );
      return true;
    }

    // Royal-inspired products can have multiple quantities
    if (existingIndex >= 0) {
      final current = state.items[existingIndex];
      final updated = OrderItem(
        product: current.product,
        quantity: current.quantity + 1,
        priceUsd: current.priceUsd,
      );
      final newItems = List<OrderItem>.from(state.items);
      newItems[existingIndex] = updated;
      state = CartState(items: newItems);
    } else {
      state = CartState(
        items: [
          ...state.items,
          OrderItem(product: product, quantity: 1, priceUsd: product.priceUsd),
        ],
      );
    }
    return true;
  }

  void remove(String productId) {
    state = CartState(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int delta) {
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;

    final item = state.items[index];
    if (item.product.type == ProductType.certifiedAntique) {
      // Antique quantity cannot be altered beyond 1
      return;
    }

    final newQty = item.quantity + delta;
    if (newQty <= 0) {
      remove(productId);
    } else {
      final newItems = List<OrderItem>.from(state.items);
      newItems[index] = OrderItem(
        product: item.product,
        quantity: newQty,
        priceUsd: item.priceUsd,
      );
      state = CartState(items: newItems);
    }
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
