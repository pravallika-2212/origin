class ArticleModel {
  const ArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.country,
    required this.civilization,
    required this.readingMinutes,
    required this.artefactCode,
    required this.publishedAt,
    required this.author,
    this.relatedProductIds = const [],
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final String country;
  final String civilization;
  final int readingMinutes;
  final String artefactCode;
  final DateTime publishedAt;
  final String author;
  final List<String> relatedProductIds;
}
