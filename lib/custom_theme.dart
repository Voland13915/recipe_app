import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CustomTheme {
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: const Color(0xff084f57),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.openSans(
        fontSize: 22.0.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: Colors.black87,
      ),
      headlineLarge: GoogleFonts.openSans(
        fontSize: 12.0.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: Colors.black87,
      ),
      displaySmall: GoogleFonts.openSans(
        fontSize: 10.0.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: Colors.black87,
      ),
      displayMedium: GoogleFonts.openSans(
        fontSize: 12.0.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: Colors.black87,
      ),
      bodyLarge: GoogleFonts.openSans(
        fontSize: 10.0.sp,
        letterSpacing: 1.0,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.openSans(fontSize: 10.0.sp, letterSpacing: 1.0),
      headlineMedium: GoogleFonts.openSans(fontSize: 12.0.sp, letterSpacing: 1.0),
    ),
    splashColor: const Color(0xff084f57),
    iconTheme: const IconThemeData(
      color: Color(0xff084f57),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xff084f57),
      unselectedItemColor: Colors.black54,
    ),
  );

  static final darkTheme = ThemeData.dark().copyWith(
    primaryColor: const Color(0xff55d4c3),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xff55d4c3),
      secondary: Color(0xff4db6ac),
    ),
    scaffoldBackgroundColor: const Color(0xff0f1a1c),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff101f22),
      foregroundColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Color(0xff55d4c3)),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.openSans(
        fontSize: 22.0.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: Colors.white,
      ),
      headlineLarge: GoogleFonts.openSans(
        fontSize: 12.0.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.openSans(
        fontSize: 10.0.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.openSans(
        fontSize: 12.0.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.openSans(
        fontSize: 10.0.sp,
        letterSpacing: 1.0,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.openSans(
        fontSize: 10.0.sp,
        letterSpacing: 1.0,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.openSans(
        fontSize: 12.0.sp,
        letterSpacing: 1.0,
        color: Colors.white,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected)
            ? const Color(0xff55d4c3)
            : Colors.grey.shade600,
      ),
      trackColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected)
            ? const Color(0xff55d4c3).withOpacity(0.4)
            : Colors.grey.shade800,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xff101f22),
      selectedItemColor: Color(0xff55d4c3),
      unselectedItemColor: Colors.white70,
    ),
  );
}