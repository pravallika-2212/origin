import 'package:flutter/material.dart';
import '../fonts.dart';
import '../../app/theme.dart';
import '../../data/models/image_source.dart';
import '../../data/repositories/image_registry.dart';

void showImageCreditDialog(BuildContext context, {ImageSourceItem? item, String? imageSourceId}) {
  final asset = item ?? (imageSourceId != null ? OriginImageRegistry.findById(imageSourceId) : null);
  if (asset == null) return;

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        decoration: BoxDecoration(
          color: OriginColors.ivoryLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: OriginColors.gold, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D463214),
              blurRadius: 36,
              offset: Offset(0, 16),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, size: 18, color: OriginColors.goldDark),
                    const SizedBox(width: 8),
                    Text(
                      'ORIGIN VERIFIED ARCHIVAL SPECIMEN',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: OriginColors.goldDark,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close, size: 20, color: OriginColors.inkMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Object Title
            Text(
              asset.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: OriginColors.ink,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${asset.countryOrCulture} · ${asset.historicalPeriod}',
              style: GoogleFonts.montserrat(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: OriginColors.goldDark,
              ),
            ),
            const SizedBox(height: 20),

            // Details table
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: OriginColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Museum / Repository', asset.sourceName),
                  const Divider(height: 18, color: OriginColors.cardBorder),
                  _buildDetailRow('Artist / Workshop', asset.creatorOrPhotographer),
                  const Divider(height: 18, color: OriginColors.cardBorder),
                  _buildDetailRow('License Type', asset.license),
                  const Divider(height: 18, color: OriginColors.cardBorder),
                  _buildDetailRow('Object Nature', asset.isAuthenticHistoricalObject ? 'Authentic Historical Artefact' : 'Curated Concept'),
                  const Divider(height: 18, color: OriginColors.cardBorder),
                  _buildDetailRow('Commercial Rights', asset.commercialUseVerified ? 'Verified Cleared for Digital Display' : 'Editorial Reference'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Attribution quote
            Text(
              'OFFICIAL ATTRIBUTION',
              style: GoogleFonts.montserrat(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: OriginColors.inkMuted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: OriginColors.ivoryDark,
                borderRadius: BorderRadius.circular(3),
                border: const Border(
                  left: BorderSide(color: OriginColors.gold, width: 3),
                ),
              ),
              child: Text(
                asset.attributionText,
                style: GoogleFonts.montserrat(
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  color: OriginColors.royalBronze,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Verification Notes
            Text(
              asset.verificationNotes,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: OriginColors.inkMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.check, size: 16, color: OriginColors.goldDark),
                label: Text(
                  'CLOSE RECORD',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: OriginColors.goldDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDetailRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 150,
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: OriginColors.inkMuted,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: OriginColors.ink,
          ),
        ),
      ),
    ],
  );
}

void showFullRegistryDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 780,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: OriginColors.ivoryLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: OriginColors.gold, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D463214),
              blurRadius: 36,
              offset: Offset(0, 16),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, size: 20, color: OriginColors.goldDark),
                    const SizedBox(width: 8),
                    Text(
                      'ORIGIN IMAGE & RIGHTS REGISTRY',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: OriginColors.goldDark,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close, size: 20, color: OriginColors.inkMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Public Domain & Museum Rights Compliance Index (The Metropolitan Museum of Art, Imperial Treasury Vienna, Textile Museum of Canada)',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: OriginColors.inkMuted,
              ),
            ),
            const SizedBox(height: 18),
            const Divider(color: OriginColors.cardBorder),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: OriginImageRegistry.allAssets.length,
                separatorBuilder: (_, _) => const Divider(color: OriginColors.cardBorder, height: 24),
                itemBuilder: (context, idx) {
                  final asset = OriginImageRegistry.allAssets[idx];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: OriginColors.cardBorder),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: asset.localAssetPath != null
                            ? Image.asset(asset.localAssetPath!, fit: BoxFit.cover)
                            : Image.network(asset.imageUrl, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              asset.title,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: OriginColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${asset.countryOrCulture} · ${asset.historicalPeriod}',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: OriginColors.goldDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Repository: ${asset.sourceName} | License: ${asset.license}',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: OriginColors.inkLight,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              asset.attributionText,
                              style: GoogleFonts.montserrat(
                                fontSize: 10.5,
                                fontStyle: FontStyle.italic,
                                color: OriginColors.royalBronze,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => showImageCreditDialog(context, item: asset),
                        icon: const Icon(Icons.info_outline, size: 18, color: OriginColors.goldDark),
                        tooltip: 'View detailed specimen card',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
