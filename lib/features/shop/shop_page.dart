import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
import '../../core/widgets/product_card.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(productFilterProvider.notifier).update(
              (f) => f.copyWith(category: widget.initialCategory),
            );
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _triggerSearch(String query) {
    ref.read(productFilterProvider.notifier).update(
          (f) => f.copyWith(searchQuery: query.trim()),
        );
  }

  void _clearAllFilters() {
    _searchCtrl.clear();
    ref.read(productFilterProvider.notifier).state = const ProductFilter();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(productFilterProvider);
    final products = ref.watch(filteredProductsProvider);
    final categories = ref.watch(productRepositoryProvider.notifier).getCategories();
    final isMobile = Breakpoints.isMobile(context);

    final civilizations = [
      'All',
      'India',
      'China',
      'Korea',
      'Japan',
      'Europe',
      'Persia and Ottoman',
      'The Americas',
      'Africa',
      'Indonesia & Southeast Asia',
      'Mongolia & Central Asia',
    ];

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF3E8D6),
                    OriginColors.ivory,
                    Color(0xFFEDE0D1),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: OriginColors.cardBorder),
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                  child: Column(
                    children: [
                      Text(
                        'THE ROYAL REPOSITORY',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                          color: OriginColors.goldDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Treasures & Heirloom Regalia',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isMobile ? 32 : 44,
                          fontWeight: FontWeight.w400,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: Text(
                          'Browse certified imperial antiques and royal-inspired jewelry, garments, tableware, and living heirlooms from sovereign traditions worldwide.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 13.5,
                            height: 1.6,
                            color: OriginColors.inkLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Area with Filters & Grid
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Controls Bar (Search + Sort + Type Switcher)
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Search field
                      Container(
                        width: isMobile ? double.infinity : 340,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: OriginColors.cardBorder),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _triggerSearch,
                          style: GoogleFonts.montserrat(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search by piece, dynasty, or material...',
                            hintStyle: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: OriginColors.inkMuted,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 18,
                              color: OriginColors.goldDark,
                            ),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      _triggerSearch('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),

                      // Sort dropdown & Type filter
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Type filter: All / Antiques / Royal-Inspired
                          SegmentedButton<ProductType?>(
                            segments: const [
                              ButtonSegment(value: null, label: Text('All')),
                              ButtonSegment(
                                value: ProductType.certifiedAntique,
                                label: Text('Antiques'),
                              ),
                              ButtonSegment(
                                value: ProductType.royalInspired,
                                label: Text('Royal-Inspired'),
                              ),
                            ],
                            selected: {filter.type},
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: OriginColors.goldDark,
                              selectedForegroundColor: Colors.white,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: OriginColors.cardBorder),
                              textStyle: GoogleFonts.montserrat(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onSelectionChanged: (val) {
                              ref.read(productFilterProvider.notifier).update(
                                    (f) => f.copyWith(
                                      type: val.first,
                                      clearType: val.first == null,
                                    ),
                                  );
                            },
                          ),

                          // Sort Dropdown
                          Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: OriginColors.cardBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ProductSort>(
                                value: filter.sort,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: OriginColors.ink,
                                  fontWeight: FontWeight.w500,
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: OriginColors.goldDark,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: ProductSort.newest,
                                    child: Text('Curated Default'),
                                  ),
                                  DropdownMenuItem(
                                    value: ProductSort.priceAsc,
                                    child: Text('Price: Low to High'),
                                  ),
                                  DropdownMenuItem(
                                    value: ProductSort.priceDesc,
                                    child: Text('Price: High to Low'),
                                  ),
                                  DropdownMenuItem(
                                    value: ProductSort.countryAsc,
                                    child: Text('Country: A to Z'),
                                  ),
                                ],
                                onChanged: (sort) {
                                  if (sort != null) {
                                    ref.read(productFilterProvider.notifier).update(
                                          (f) => f.copyWith(sort: sort),
                                        );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Horizontal Category Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterPill(
                          label: 'All Collections',
                          isSelected: filter.category == null,
                          onTap: () {
                            ref.read(productFilterProvider.notifier).update(
                                  (f) => f.copyWith(clearCategory: true),
                                );
                          },
                        ),
                        for (final cat in categories)
                          _FilterPill(
                            label: cat.name,
                            isSelected: filter.category == cat.name,
                            onTap: () {
                              ref.read(productFilterProvider.notifier).update(
                                    (f) => f.copyWith(
                                      category: filter.category == cat.name ? null : cat.name,
                                      clearCategory: filter.category == cat.name,
                                    ),
                                  );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Horizontal Civilization Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final civ in civilizations)
                          _CivilizationPill(
                            label: civ,
                            isSelected: civ == 'All'
                                ? filter.civilization == null
                                : filter.civilization == civ,
                            onTap: () {
                              ref.read(productFilterProvider.notifier).update(
                                    (f) => f.copyWith(
                                      civilization: civ == 'All' ? null : civ,
                                      clearCivilization: civ == 'All',
                                    ),
                                  );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active Filter Chips & Clear All Row
                  if (filter.hasActiveFilters) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'ACTIVE FILTERS:',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: OriginColors.inkMuted,
                          ),
                        ),
                        if (filter.category != null)
                          Chip(
                            label: Text(filter.category!),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () {
                              ref.read(productFilterProvider.notifier).update(
                                    (f) => f.copyWith(clearCategory: true),
                                  );
                            },
                          ),
                        if (filter.civilization != null)
                          Chip(
                            label: Text(filter.civilization!),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () {
                              ref.read(productFilterProvider.notifier).update(
                                    (f) => f.copyWith(clearCivilization: true),
                                  );
                            },
                          ),
                        if (filter.type != null)
                          Chip(
                            label: Text(
                              filter.type == ProductType.certifiedAntique
                                  ? 'Certified Antique'
                                  : 'Royal-Inspired',
                            ),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () {
                              ref.read(productFilterProvider.notifier).update(
                                    (f) => f.copyWith(clearType: true),
                                  );
                            },
                          ),
                        if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty)
                          Chip(
                            label: Text('“${filter.searchQuery}”'),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () {
                              _searchCtrl.clear();
                              _triggerSearch('');
                            },
                          ),
                        TextButton(
                          onPressed: _clearAllFilters,
                          child: Text(
                            'Clear All Filters',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: OriginColors.goldDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Results count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing ${products.length} royal pieces',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: OriginColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Products Grid or Empty State
                  if (products.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: OriginColors.cardBorder),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: OriginColors.goldDark,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Royal Pieces Match Your Selection',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: OriginColors.royalBronze,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try clearing some filters or searching for different historical court periods.',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: OriginColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 24),
                          OriginButton(
                            text: 'CLEAR ALL FILTERS',
                            onPressed: _clearAllFilters,
                          ),
                        ],
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        int cols = 4;
                        if (constraints.maxWidth < 600) {
                          cols = 1;
                        } else if (constraints.maxWidth < 900) {
                          cols = 2;
                        } else if (constraints.maxWidth < 1100) {
                          cols = 3;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.68,
                          ),
                          itemBuilder: (ctx, idx) =>
                              ProductCard(product: products[idx]),
                        );
                      },
                    ),
                ],
              ),
            ),

            // Footer
            const OriginFooter(),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? OriginColors.goldDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? OriginColors.goldDark : OriginColors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : OriginColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _CivilizationPill extends StatelessWidget {
  const _CivilizationPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? OriginColors.royalBronze : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? OriginColors.royalBronze : OriginColors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : OriginColors.inkLight,
            ),
          ),
        ),
      ),
    );
  }
}
