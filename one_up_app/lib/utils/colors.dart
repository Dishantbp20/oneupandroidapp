import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors{
  static const Color primaryColor = Color(0xFFe5c92e); // Example hex color
  static const Color secondaryColor = Color(0xFFf232a4);
  static const Color textColor = Color(0xFF333333);
  static const Color lightGrayishPink = Color(0xFFdcd6d9);
  static const Color primaryBlue = Color(0xFF5f74f7);
  static const Color darkBlue = Color(0xff0000FF);
  static const Color bgColor = Color(0xFFF9FBFF);
  static const Color lightGrey = Color(0xFF555555);

  static List<Color> getGradientColor(){
    List<Color> colorList = [
      AppColors.primaryColor,
      AppColors.secondaryColor,
      AppColors.primaryBlue, // pink
    ];
    return colorList;
  }
  static List<Color> getDashboardTileColors(){
    List<Color> colorList = [
      lightGrayishPink,
      AppColors.secondaryColor,
      AppColors.primaryBlue, // pink
    ];
    return colorList;
  }
  static List<Color> getTileColor(){
    List<Color> colorList =[
      darkBlue.withAlpha(180),
      primaryBlue, // base yellow
      Colors.white, // warm orange
    ];
    return colorList;
  }
  static List<Color> getGreenColor(){
    List<Color> colorList =[
      Colors.green,
      Colors.lightGreen, // base yellow
      Colors.white, // warm orange
    ];
    return colorList;
  }
  static List<Color> getRedColor(){
    List<Color> colorList =[
      Colors.pink,
      secondaryColor, // base yellow
      Colors.white, // warm orange
    ];
    return colorList;
  }

  static getBlueColor() {}
}