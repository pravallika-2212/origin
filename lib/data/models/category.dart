import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.name,
    required this.tagline,
    required this.artefactCode,
    required this.bgColor,
  });

  final String id;
  final String name;
  final String tagline;
  final String artefactCode;
  final Color bgColor;
}
