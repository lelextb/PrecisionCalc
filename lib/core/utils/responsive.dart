import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 && MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  static double buttonSize(BuildContext context) {
    final width = screenWidth(context);
    if (width < 400) return 70;
    if (width < 600) return 80;
    return 100;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 600) return const EdgeInsets.symmetric(horizontal: 16, vertical: 24);
    if (width < 900) return const EdgeInsets.symmetric(horizontal: 32, vertical: 32);
    return EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 40);
  }

  static double displayFontSize(BuildContext context) {
    final width = screenWidth(context);
    if (width < 400) return 36;
    if (width < 600) return 48;
    return 64;
  }

  static double expressionFontSize(BuildContext context) {
    final width = screenWidth(context);
    if (width < 400) return 16;
    if (width < 600) return 20;
    return 24;
  }
}