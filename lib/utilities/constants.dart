// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Constants {}

class ColorPalette {
  static const Color bgColor = Color(0xFFf5f5f5);
  static const Color black = Color(0xFF2B2B2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey1 = Color(0xFF5E5E5E);
  static const Color grey2 = Color(0xFF9E9E9E);
  static const Color yellow = Color(0xFFBC3F);
  static const Color red = Color(0xFFF55A51);
  static const Color green = Color(0xFF00FF00);
}

final List<Map<String, String>> restaurantTypes = [
  {"key": "10662", "name": "British"},
  {"key": "10345", "name": "Steakhouse"},
  {"key": "10648", "name": "International"},
  {"key": "10665", "name": "Vegetarian friendly"},
  {"key": "10697", "name": "Vegan options"},
  {"key": "10992", "name": "Gluten free options"},
  {"key": "10642", "name": "Cafe"},
  {"key": "10659", "name": "Asian"},
  {"key": "10654", "name": "European"},
  {"key": "10660", "name": "Thai"},
  {"key": "10679", "name": "Healthy"},
  {"key": "21353", "name": "Dining bars"},
  {"key": "10665", "name": "Vegetarian friendly"},
  {"key": "10697", "name": "Vegan options"},
  {"key": "10992", "name": "Gluten free options"},
  {"key": "10640", "name": "Bar"},
  {"key": "10671", "name": "Fusion"},
  {"key": "21353", "name": "Dining bars"},
  {"key": "10643", "name": "Seafood"},
  {"key": "10651", "name": "Barbecue"},
  {"key": "10660", "name": "Thai"},
  {"key": "10659", "name": "Asian"},
  {"key": "10665", "name": "Vegetarian friendly"},
  {"key": "10992", "name": "Gluten free options"},
];

class Fonts {
  static const String regular = 'monrapeRegular';
  static const String semibold = 'monrapeSemiBold';
  static const String medium = 'monrapeMedium';
  static const String bold = 'monrapeBold';
  static const String light = 'monrapeLight';
  static const String extralight = 'monrapeExtraLight';
}

class FontsSize {
  static const double head1 = 48.0;
  static const double head2 = 40.0;
  static const double head3 = 32.0;
  static const double head4 = 24.0;
  static const double head5 = 20.0;
  static const double head6 = 18.0;

  static const double xlarge = 18.0;
  static const double large = 16.0;
  static const double medium = 14.0;
  static const double small = 12.0;
  static const double xsmall = 10.0;
}

class AssetName {
  static const String appName = "Food";
}

class ImagesName {
  static const String avatar = "assets/images/avatar.png";
}

class IconsName {
  static const String dropdown = "assets/icons/dropdown.svg";
  static const String filters = "assets/icons/filters.svg";
  static const String location = "assets/icons/location.svg";
  static const String search = "assets/icons/search.svg";
  static const String menu = "assets/icons/menu.svg";
  static const String close = "assets/icons/close.svg";
  static const rate = "assets/icons/rate.svg";
}
