class ImageSourceItem {
  const ImageSourceItem({
    required this.id,
    required this.title,
    required this.countryOrCulture,
    required this.category,
    required this.historicalPeriod,
    required this.imageUrl,
    this.localAssetPath,
    required this.sourceName,
    required this.sourcePageUrl,
    required this.creatorOrPhotographer,
    required this.license,
    required this.attributionText,
    required this.commercialUseVerified,
    required this.isAuthenticHistoricalObject,
    required this.isAIConceptImage,
    required this.verificationNotes,
  });

  final String id;
  final String title;
  final String countryOrCulture;
  final String category;
  final String historicalPeriod;
  final String imageUrl;
  final String? localAssetPath;
  final String sourceName;
  final String sourcePageUrl;
  final String creatorOrPhotographer;
  final String license;
  final String attributionText;
  final bool commercialUseVerified;
  final bool isAuthenticHistoricalObject;
  final bool isAIConceptImage;
  final String verificationNotes;
}
