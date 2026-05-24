import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF405DE6),
        secondary: Color(0xFFFFDC80),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: Color(0xFF262626),
        error: Colors.red,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF262626),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'SFProDisplay',
        ),
        iconTheme: IconThemeData(color: Color(0xFF262626)),
        actionsIconTheme: IconThemeData(color: Color(0xFF262626)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF262626),
        unselectedItemColor: Color(0xFF8E8E8E),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      tabBarTheme: const TabBarTheme(
        indicatorColor: Colors.black,
        labelColor: Colors.black,
        unselectedLabelColor: Color(0xFF8E8E8E),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF262626),
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF262626),
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF262626),
          fontFamily: 'SFProDisplay',
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF262626),
          fontFamily: 'SFProDisplay',
        ),
        bodySmall: TextStyle(
          color: Color(0xFF8E8E8E),
          fontFamily: 'SFProDisplay',
        ),
        titleLarge: TextStyle(
          color: Color(0xFF262626),
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF262626)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF405DE6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          textStyle: const TextStyle(
            fontFamily: 'SFProDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF262626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          textStyle: const TextStyle(
            fontFamily: 'SFProDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF405DE6),
          textStyle: const TextStyle(
            fontFamily: 'SFProDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF405DE6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: Color(0xFF8E8E8E),
          fontFamily: 'SFProDisplay',
        ),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontFamily: 'SFProDisplay',
        ),
      ),
      cardTheme: const CardTheme(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 0.5,
      ),
      dialogTheme: const DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF405DE6),
        secondary: Color(0xFFFFDC80),
        surface: Color(0xFF121212),
        onPrimary: Colors.white,
        onSurface: Colors.white,
        error: Colors.red,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'SFProDisplay',
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFF8E8E8E),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          color: Colors.white,
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        displayMedium: const TextStyle(
          color: Colors.white,
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: const TextStyle(
          color: Colors.white,
          fontFamily: 'SFProDisplay',
        ),
        bodyMedium: const TextStyle(
          color: Colors.white,
          fontFamily: 'SFProDisplay',
        ),
        bodySmall: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontFamily: 'SFProDisplay',
        ),
        titleLarge: const TextStyle(
          color: Colors.white,
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF405DE6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF405DE6), width: 2),
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontFamily: 'SFProDisplay',
        ),
      ),
      cardTheme: const CardTheme(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 0.5,
      ),
    );
  }
}
