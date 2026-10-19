import 'package:flutter_test/flutter_test.dart';
import 'package:origin/core/utils/formatters.dart';
import 'package:origin/data/models/product.dart';
import 'package:origin/data/repositories/cart_repository.dart';
import 'package:origin/data/repositories/product_repository.dart';
import 'package:origin/data/repositories/seed_data.dart';
import 'package:origin/features/auth/auth_controller.dart';

void main() {
  group('PRD 17.1 Unit Tests: Price and Currency Formatter', () {
    test('formats price in USD correctly', () {
      final formatted = OriginFormatters.formatPrice(1299.0, Currency.usd);
      expect(formatted, contains(r'$1,299 USD'));
    });

    test('formats price in INR correctly with exchange conversion', () {
      final formatted = OriginFormatters.formatPrice(100.0, Currency.inr);
      // 100 * 85 = 8500 INR
      expect(formatted, contains('₹'));
      expect(formatted, contains('8,500'));
    });
  });

  group('PRD 12 & 13: Product Models and Filter Logic', () {
    test('filters products by category correctly', () {
      final repo = ProductRepository();
      final filtered = repo.filter(const ProductFilter(category: 'Imperial Jewels'));
      expect(filtered.isNotEmpty, true);
      for (final p in filtered) {
        expect(p.category, contains('Imperial Jewels'));
      }
    });

    test('filters products by type (Certified Antique vs Royal-Inspired)', () {
      final repo = ProductRepository();
      final antiques = repo.filter(const ProductFilter(type: ProductType.certifiedAntique));
      expect(antiques.isNotEmpty, true);
      for (final a in antiques) {
        expect(a.type, ProductType.certifiedAntique);
      }

      final inspired = repo.filter(const ProductFilter(type: ProductType.royalInspired));
      expect(inspired.isNotEmpty, true);
      for (final i in inspired) {
        expect(i.type, ProductType.royalInspired);
      }
    });
  });

  group('PRD 8.5 & 12.1: Cart Antique Single-Quantity Enforcement', () {
    test('antiques cannot have quantity greater than 1 in cart', () {
      final cart = CartNotifier();
      final antique = seedProducts.firstWhere((p) => p.type == ProductType.certifiedAntique);

      final addedFirst = cart.add(antique);
      expect(addedFirst, true);
      expect(cart.state.items.length, 1);
      expect(cart.state.items.first.quantity, 1);

      // Attempting to add the same antique again must return false and keep quantity at 1
      final addedSecond = cart.add(antique);
      expect(addedSecond, false);
      expect(cart.state.items.first.quantity, 1);

      // Trying to updateQuantity on antique does not increase
      cart.updateQuantity(antique.id, 1);
      expect(cart.state.items.first.quantity, 1);
    });

    test('royal-inspired items allow multiple quantities in cart', () {
      final cart = CartNotifier();
      final inspired = seedProducts.firstWhere((p) => p.type == ProductType.royalInspired);

      cart.add(inspired);
      expect(cart.state.items.first.quantity, 1);

      cart.add(inspired);
      expect(cart.state.items.first.quantity, 2);

      cart.updateQuantity(inspired.id, 1);
      expect(cart.state.items.first.quantity, 3);
    });
  });

  group('PRD 7: Authentication Controller', () {
    test('registers member with valid credentials', () async {
      final auth = AuthController();
      expect(auth.state.isSignedIn, false);

      final ok = await auth.register(
        name: 'Lady Eleanor',
        email: 'eleanor@royal.org',
        password: 'password123',
      );

      expect(ok, true);
      expect(auth.state.isSignedIn, true);
      expect(auth.state.user?.name, 'Lady Eleanor');
      expect(auth.state.user?.firstName, 'Lady');
    });

    test('rejects short passwords under 6 characters', () async {
      final auth = AuthController();
      final ok = await auth.register(
        name: 'Patron',
        email: 'patron@royal.org',
        password: '123',
      );

      expect(ok, false);
      expect(auth.state.isSignedIn, false);
      expect(auth.state.errorMessage, contains('at least 6 characters'));
    });
  });
}
