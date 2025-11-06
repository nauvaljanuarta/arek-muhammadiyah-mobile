import 'package:flutter/cupertino.dart';

class AppTheme {
  static const Color primaryDark = Color(0xFF19183B);    
  static const Color primaryMedium = Color(0xFF4A90E2);    
  static const Color primaryLight = Color(0xFF63B3ED);   
  static const Color accent = Color(0xFF4FD1C7);         // Teal
  static const Color lightAccent = Color(0xFF9AE6B4);    // Light green
  
  static const Color background = CupertinoColors.systemBackground;
  static const Color surface = CupertinoColors.systemGrey6;
  static const Color textPrimary = CupertinoColors.label;
  static const Color textSecondary = CupertinoColors.secondaryLabel;

  static const CupertinoThemeData cupertinoTheme = CupertinoThemeData(
    primaryColor: primaryDark,
    scaffoldBackgroundColor: background,
    barBackgroundColor: primaryDark,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        inherit: false,
        fontFamily: 'Montserrat',
        fontSize: 16,
        color: textPrimary,
      ),
      navTitleTextStyle: TextStyle(
        inherit: false,
        fontFamily: 'Montserrat',
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      actionTextStyle: TextStyle(
        inherit: false,
      fontFamily: 'Montserrat',
      color: accent,
    ),
    ),
  );
}