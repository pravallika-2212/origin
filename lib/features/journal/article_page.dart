import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/origin_heritage_image.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
import '../../core/widgets/product_card.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/repositories/product_repository.dart';

class ArticlePage extends ConsumerWidget {
  const ArticlePage({super.key, required this.articleId});

  final String articleId;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(journalRepositoryProvider.notifier).getById(articleId);
    final allProducts = ref.watch(productRepositoryProvider);

    if (article == null) {
      return Scaffold(
        appBar: const OriginHeader(isScrolled: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Article Not Found', style: GoogleFonts.playfairDisplay(fontSize: 24)),
              const SizedBox(height: 12),
              OriginButton(text: 'BACK TO JOURNAL', onPressed: () => context.go('/journal')),
            ],
          ),
        ),
      );
    }

    final relatedProducts = allProducts.where((p) => article.relatedProductIds.contains(p.id)).toList();

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Article Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF7F0),
                border: Border(bottom: BorderSide(color: OriginColors.cardBorder)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: OriginColors.goldDark,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              article.country.toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${article.readingMinutes} MIN READ · ${OriginFormatters.formatDate(article.publishedAt).toUpperCase()}',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: OriginColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        article.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 34,
                          fontWeight: FontWeight.w500,
                          color: OriginColors.royalBronze,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Essay by ${article.author}',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: OriginColors.goldDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Editorial Body
            Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Artefact Photograph
                  Container(
                    width: double.infinity,
                    height: 320,
                    decoration: BoxDecoration(
                      color: OriginColors.ivoryDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: OriginColors.cardBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: OriginHeritageImage(
                      localAssetPath: article.localAssetPath,
                      networkUrl: article.imageUrl,
                      artefactCode: article.artefactCode,
                      fit: BoxFit.contain,
                      semanticLabel: article.title,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Verified archival specimen: ${article.country} royal court material culture. Preserved in open-access museum collections.',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        color: OriginColors.goldDark,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Summary Pull Quote
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: OriginColors.goldDark, width: 3)),
                    ),
                    child: Text(
                      article.summary,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: OriginColors.royalBronze,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Paragraphs
                  for (final paragraph in article.body.split('\n\n')) ...[
                    Text(
                      paragraph,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        height: 1.85,
                        color: OriginColors.ink,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 48),
                  const Divider(color: OriginColors.cardBorder),
                  const SizedBox(height: 36),

                  // Related collection pieces
                  if (relatedProducts.isNotEmpty) ...[
                    Text(
                      'DISCOVER RELATED PIECES IN REPOSITORY',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: OriginColors.goldDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final p in relatedProducts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ProductCard(product: p),
                      ),
                  ],

                  const SizedBox(height: 24),
                  Center(
                    child: OriginButton(
                      text: 'BACK TO ALL ESSAYS',
                      variant: OriginButtonVariant.outlined,
                      onPressed: () => context.go('/journal'),
                    ),
                  ),
                ],
              ),
            ),

            const OriginFooter(),
          ],
        ),
      ),
    );
  }
}
