enum ProductType { certifiedAntique, royalInspired }

enum ProductStatus { available, reserved, sold }

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.country,
    required this.civilization,
    required this.era,
    required this.category,
    required this.story,
    required this.priceUsd,
    required this.type,
    required this.images,
    required this.artefactCode,
    this.material = 'Gold filigree, untreated natural gems, fine silk',
    this.dimensions = '24 cm × 18 cm × 12 cm',
    this.condition = 'Museum grade, expertly conserved with patina preserved',
    this.provenance = const [
      'Documented in the Royal Treasury Inventory of 1884.',
      'Transferred by bequest to the Grand Duke archival collection in 1922.',
      'Examined and verified by the International Heritage Antiquities Board in 2024.',
    ],
    this.certificateUrl = 'ORIGIN-CERT-ROYAL-AUTHENTICITY.pdf',
    this.status = ProductStatus.available,
    this.published = true,
    this.featured = false,
    this.imageSourceId,
    this.localAssetPath,
    this.isHistoricalReference = false,
    this.museumName,
    this.accessionNumber,
  });

  final String id;
  final String name;
  final String country;
  final String civilization;
  final String era;
  final String category;
  final String story;
  final double priceUsd;
  final ProductType type;
  final List<String> images;
  final String artefactCode;
  final String material;
  final String dimensions;
  final String condition;
  final List<String> provenance;
  final String? certificateUrl;
  final ProductStatus status;
  final bool published;
  final bool featured;
  final String? imageSourceId;
  final String? localAssetPath;
  final bool isHistoricalReference;
  final String? museumName;
  final String? accessionNumber;

  String get typeLabel =>
      type == ProductType.certifiedAntique ? 'Antique · Certified' : 'Royal-Inspired';

  String? get primaryImage {
    if (localAssetPath != null && localAssetPath!.isNotEmpty) {
      return localAssetPath;
    }
    for (final img in images) {
      if (img.startsWith('assets/') || img.startsWith('http://') || img.startsWith('https://')) {
        return img;
      }
    }
    return null;
  }

  Product copyWith({
    String? id,
    String? name,
    String? country,
    String? civilization,
    String? era,
    String? category,
    String? story,
    double? priceUsd,
    ProductType? type,
    List<String>? images,
    String? artefactCode,
    String? material,
    String? dimensions,
    String? condition,
    List<String>? provenance,
    String? certificateUrl,
    ProductStatus? status,
    bool? published,
    bool? featured,
    String? imageSourceId,
    String? localAssetPath,
    bool? isHistoricalReference,
    String? museumName,
    String? accessionNumber,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      civilization: civilization ?? this.civilization,
      era: era ?? this.era,
      category: category ?? this.category,
      story: story ?? this.story,
      priceUsd: priceUsd ?? this.priceUsd,
      type: type ?? this.type,
      images: images ?? this.images,
      artefactCode: artefactCode ?? this.artefactCode,
      material: material ?? this.material,
      dimensions: dimensions ?? this.dimensions,
      condition: condition ?? this.condition,
      provenance: provenance ?? this.provenance,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      status: status ?? this.status,
      published: published ?? this.published,
      featured: featured ?? this.featured,
      imageSourceId: imageSourceId ?? this.imageSourceId,
      localAssetPath: localAssetPath ?? this.localAssetPath,
      isHistoricalReference: isHistoricalReference ?? this.isHistoricalReference,
      museumName: museumName ?? this.museumName,
      accessionNumber: accessionNumber ?? this.accessionNumber,
    );
  }
}
