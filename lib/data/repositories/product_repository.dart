import '../../core/riverpod.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'seed_data.dart';

enum ProductSort { newest, priceAsc, priceDesc, countryAsc }

class ProductFilter {
  const ProductFilter({
    this.category,
    this.civilization,
    this.era,
    this.material,
    this.type,
    this.minPrice,
    this.maxPrice,
    this.searchQuery,
    this.sort = ProductSort.newest,
    this.onlyPublished = true,
  });

  final String? category;
  final String? civilization;
  final String? era;
  final String? material;
  final ProductType? type;
  final double? minPrice;
  final double? maxPrice;
  final String? searchQuery;
  final ProductSort sort;
  final bool onlyPublished;

  bool get hasActiveFilters =>
      category != null ||
      civilization != null ||
      era != null ||
      material != null ||
      type != null ||
      minPrice != null ||
      maxPrice != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);

  ProductFilter copyWith({
    String? category,
    bool clearCategory = false,
    String? civilization,
    bool clearCivilization = false,
    String? era,
    bool clearEra = false,
    String? material,
    bool clearMaterial = false,
    ProductType? type,
    bool clearType = false,
    double? minPrice,
    double? maxPrice,
    bool clearPrice = false,
    String? searchQuery,
    bool clearSearch = false,
    ProductSort? sort,
    bool? onlyPublished,
  }) {
    return ProductFilter(
      category: clearCategory ? null : (category ?? this.category),
      civilization: clearCivilization ? null : (civilization ?? this.civilization),
      era: clearEra ? null : (era ?? this.era),
      material: clearMaterial ? null : (material ?? this.material),
      type: clearType ? null : (type ?? this.type),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      sort: sort ?? this.sort,
      onlyPublished: onlyPublished ?? this.onlyPublished,
    );
  }
}

class ProductRepository extends StateNotifier<List<Product>> {
  ProductRepository() : super(List.of(seedProducts));

  List<CategoryItem> getCategories() => List.unmodifiable(seedCategories);

  List<Product> filter(ProductFilter filter) {
    return state.where((p) {
      if (filter.onlyPublished && !p.published) return false;

      if (filter.category != null && filter.category!.isNotEmpty) {
        if (!p.category.toLowerCase().contains(filter.category!.toLowerCase())) {
          return false;
        }
      }

      if (filter.civilization != null && filter.civilization!.isNotEmpty) {
        if (!p.civilization.toLowerCase().contains(filter.civilization!.toLowerCase()) &&
            !p.country.toLowerCase().contains(filter.civilization!.toLowerCase())) {
          return false;
        }
      }

      if (filter.era != null && filter.era!.isNotEmpty) {
        if (!p.era.toLowerCase().contains(filter.era!.toLowerCase())) {
          return false;
        }
      }

      if (filter.type != null) {
        if (p.type != filter.type) return false;
      }

      if (filter.minPrice != null) {
        if (p.priceUsd < filter.minPrice!) return false;
      }

      if (filter.maxPrice != null) {
        if (p.priceUsd > filter.maxPrice!) return false;
      }

      if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
        final q = filter.searchQuery!.trim().toLowerCase();
        final match = p.name.toLowerCase().contains(q) ||
            p.country.toLowerCase().contains(q) ||
            p.civilization.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.story.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (filter.sort) {
          case ProductSort.newest:
            return 0; // Default curated order
          case ProductSort.priceAsc:
            return a.priceUsd.compareTo(b.priceUsd);
          case ProductSort.priceDesc:
            return b.priceUsd.compareTo(a.priceUsd);
          case ProductSort.countryAsc:
            return a.country.compareTo(b.country);
        }
      });
  }

  Product? getById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void addProduct(Product product) {
    state = [product, ...state];
  }

  void updateProduct(Product product) {
    state = [
      for (final p in state)
        if (p.id == product.id) product else p,
    ];
  }

  void togglePublish(String id) {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(published: !p.published) else p,
    ];
  }

  void deleteProduct(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

final productRepositoryProvider =
    StateNotifierProvider<ProductRepository, List<Product>>((ref) {
  return ProductRepository();
});

final productFilterProvider = StateProvider<ProductFilter>((ref) {
  return const ProductFilter();
});

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider.notifier);
  final filter = ref.watch(productFilterProvider);
  // Ensure listening to state updates
  ref.watch(productRepositoryProvider);
  return repo.filter(filter);
});
