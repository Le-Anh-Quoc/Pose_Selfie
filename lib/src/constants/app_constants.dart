import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppFontSize {
  static const double extraSmall_ = 11.0;
  static const double extraSmall = 12.0;
  static const double small = 13.0;
  static const double mediumSmall = 14.0;
  static const double normal = 15.0;
  static const double medium = 16.0;
  static const double mediumLarge = 18.0;
  static const double large = 20.0;
  static const double extraLarge = 22.0;
  static const double extraExtraLarge = 24.0;
}

class AppColor {
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color yellowButton = Color(0xFFF9E954);
  static const Color transparent = Colors.transparent;
}

class AppIcon {
  static final collection = SvgPicture.asset(
    'assets/images/collection.svg',
    width: 30,
    height: 30,
  );
  static final both = SvgPicture.asset(
    'assets/images/both.svg',
    width: 25,
    height: 25,
  );
  static final change = SvgPicture.asset(
    'assets/images/change.svg',
    width: 25,
    height: 25,
  );
}