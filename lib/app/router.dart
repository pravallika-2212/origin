import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/account/account_page.dart';
import '../features/admin/admin_page.dart';
import '../features/authenticity/authenticity_page.dart';
import '../features/cart/cart_page.dart';
import '../features/cart/checkout_page.dart';
import '../features/cart/order_success_page.dart';
import '../features/heritage/heritage_page.dart';
import '../features/journal/article_page.dart';
import '../features/journal/journal_page.dart';
import '../features/landing/landing_page.dart';
import '../features/legal/legal_pages.dart';
import '../features/shop/product_detail_page.dart';
import '../features/shop/shop_page.dart';
import '../features/wishlist/wishlist_page.dart';

CustomTransitionPage<T> fadePage<T>({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
        child: child,
      );
    },
  );
}

final originRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const LandingPage(),
      ),
    ),
    GoRoute(
      path: '/shop',
      pageBuilder: (context, state) {
        final cat = state.uri.queryParameters['category'];
        return fadePage(
          key: state.pageKey,
          child: ShopPage(initialCategory: cat),
        );
      },
    ),
    GoRoute(
      path: '/product/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? 'prod-1';
        return fadePage(
          key: state.pageKey,
          child: ProductDetailPage(productId: id),
        );
      },
    ),
    GoRoute(
      path: '/heritage/:country',
      pageBuilder: (context, state) {
        final country = state.pathParameters['country'] ?? 'India';
        return fadePage(
          key: state.pageKey,
          child: HeritagePage(country: country),
        );
      },
    ),
    GoRoute(
      path: '/journal',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const JournalPage(),
      ),
    ),
    GoRoute(
      path: '/journal/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? 'art-1';
        return fadePage(
          key: state.pageKey,
          child: ArticlePage(articleId: id),
        );
      },
    ),
    GoRoute(
      path: '/authenticity',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const AuthenticityPage(),
      ),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const AboutPage(),
      ),
    ),
    GoRoute(
      path: '/privacy',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const PrivacyPage(),
      ),
    ),
    GoRoute(
      path: '/terms',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const TermsPage(),
      ),
    ),
    GoRoute(
      path: '/shipping',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const ShippingPage(),
      ),
    ),
    GoRoute(
      path: '/help',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const ShippingPage(),
      ),
    ),
    GoRoute(
      path: '/wishlist',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const WishlistPage(),
      ),
    ),
    GoRoute(
      path: '/cart',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const CartPage(),
      ),
    ),
    GoRoute(
      path: '/checkout',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const CheckoutPage(),
      ),
    ),
    GoRoute(
      path: '/order-success/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return fadePage(
          key: state.pageKey,
          child: OrderSuccessPage(orderId: id),
        );
      },
    ),
    GoRoute(
      path: '/account',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const AccountPage(),
      ),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        child: const AdminPage(),
      ),
    ),
  ],
);
