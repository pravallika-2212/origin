import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/artefact_art.dart';
import '../../core/widgets/origin_heritage_image.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
import '../../data/models/article.dart';
import '../../data/repositories/journal_repository.dart';

class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});

  ArtefactType _getArtefactType(String code) {
    switch (code) {
      case 'neck':
        return ArtefactType.neck;
      case 'crown':
        return ArtefactType.crown;
      case 'vase':
        return ArtefactType.vase;
      case 'robe':
        return ArtefactType.robe;
      case 'fan':
        return ArtefactType.fan;
      case 'box':
        return ArtefactType.box;
      default:
        return ArtefactType.lotus;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(journalRepositoryProvider);
    final isMobile = Breakpoints.isMobile(context);

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Journal Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF3EAD8),
                    OriginColors.ivory,
                    Color(0xFFEBDCD3),
                  ],
                ),
                border: Border(bottom: BorderSide(color: OriginColors.cardBorder)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                  child: Column(
                    children: [
                      Text(
                        'THE ROYAL JOURNAL',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                          color: OriginColors.goldDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chronicles of Court Heritage & Craft',
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
                          'Essays by museum curators, gemmologists, and antique conservators uncovering the lost techniques, dynastic lore, and provenance of royal regalia.',
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

            // Articles List
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: articles.length,
                separatorBuilder: (ctx, idx) => const SizedBox(height: 32),
                itemBuilder: (ctx, idx) {
                  final a = articles[idx];
                  return _ArticleItemCard(article: a, type: _getArtefactType(a.artefactCode));
                },
              ),
            ),

            const OriginFooter(),
          ],
        ),
      ),
    );
  }
}

class _ArticleItemCard extends StatefulWidget {
  const _ArticleItemCard({required this.article, required this.type});

  final ArticleModel article;
  final ArtefactType type;

  @override
  State<_ArticleItemCard> createState() => _ArticleItemCardState();
}

class _ArticleItemCardState extends State<_ArticleItemCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/journal/${widget.article.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _hovered ? OriginColors.goldDark : OriginColors.cardBorder,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: _hovered ? const Color(0x249A7440) : const Color(0x08000000),
                blurRadius: _hovered ? 24 : 8,
                offset: Offset(0, _hovered ? 8 : 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 700;

              final textCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: OriginColors.goldDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          widget.article.country.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${widget.article.readingMinutes} min read · ${OriginFormatters.formatDate(widget.article.publishedAt)}',
                        style: GoogleFonts.montserrat(fontSize: 11.5, color: OriginColors.inkMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.article.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: OriginColors.ink,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.article.summary,
                    style: GoogleFonts.montserrat(
                      fontSize: 13.5,
                      height: 1.6,
                      color: OriginColors.inkLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'By ${widget.article.author}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: OriginColors.royalBronze,
                    ),
                  ),
                ],
              );

              final artBox = Container(
                width: isWide ? 180 : double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: OriginColors.ivoryDark,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: OriginColors.cardBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: OriginHeritageImage(
                  localAssetPath: widget.article.localAssetPath,
                  networkUrl: widget.article.imageUrl,
                  artefactCode: widget.article.artefactCode,
                  fit: BoxFit.cover,
                  semanticLabel: widget.article.title,
                ),
              );

              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: textCol),
                        const SizedBox(width: 32),
                        artBox,
                      ],
                    )
                  : Column(
                      children: [
                        artBox,
                        const SizedBox(height: 20),
                        textCol,
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
