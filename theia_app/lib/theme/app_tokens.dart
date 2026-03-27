import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 30;
}

class AppRadii {
  AppRadii._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
}

class AppSizes {
  AppSizes._();

  static const double compactButtonHeight = 48;
  static const double buttonHeight = 52;
  static const double largeFab = 80;
}

class AppAdaptive {
  AppAdaptive._();

  static double uiScale(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return scale.clamp(0.8, 2.0);
  }

  static double scaled(BuildContext context, double value) {
    return value * uiScale(context);
  }
}
