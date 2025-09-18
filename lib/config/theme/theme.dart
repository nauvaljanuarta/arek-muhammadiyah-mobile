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

  // Theme
  static const CupertinoThemeData cupertinoTheme = CupertinoThemeData(
    primaryColor: primaryDark,
    scaffoldBackgroundColor: background,
    barBackgroundColor: primaryDark,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16,
        color: textPrimary,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: 'Montserrat',
        color: CupertinoColors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}