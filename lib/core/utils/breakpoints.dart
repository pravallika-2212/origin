import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 600.0;
  static const double tablet = 1000.0;
  static const double maxContentWidth = 1180.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobile && width <= tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width > tablet;

  static bool isReducedMotion(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
