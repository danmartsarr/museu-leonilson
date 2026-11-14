import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Fundos (papel envelhecido e tinta)
  static const Color background = Color(0xFF100E0C);      // fundo tinta escura
  static const Color surface = Color(0xFF1C1916);          // superfície papel tonado
  static const Color surfaceElevated = Color(0xFF252018);
  static const Color surfaceHighlight = Color(0xFF2E2820);

  // ── Papel claro (para seções que evocam obras sobre papel)
  static const Color paperLight = Color(0xFFF0EBE1);       // papel aquarela bruto
  static const Color paperMid = Color(0xFFE2D9CC);         // papel levemente tintado
  static const Color paperInk = Color(0xFF1A1510);         // tinta sobre papel

  // ── Texto
  static const Color onBackground = Color(0xFFEDE8DF);
  static const Color onSurface = Color(0xFFC5BEB4);
  static const Color onSurfaceMuted = Color(0xFF7A726A);
  static const Color onSurfaceDisabled = Color(0xFF3A3530);

  // ── Cores de aquarela (extraídas das obras)
  static const Color accent = Color(0xFFCFA02A);           // âmbar dourado (obras bordado)
  static const Color accentLight = Color(0xFFE5BF50);
  static const Color accentDark = Color(0xFF7A5C10);

  static const Color watercolorBlue = Color(0xFF7B8EC4);   // azul-periwinkle característico
  static const Color watercolorBlueDark = Color(0xFF4A5C8A);
  static const Color crimson = Color(0xFFC0403A);          // vermelho aquarela (Pequenos Fogos)
  static const Color teal = Color(0xFF4A7B6E);             // verde-azulado (telas verdes)
  static const Color mauve = Color(0xFF8B6898);            // púrpura (obras tardias)
  static const Color sandYellow = Color(0xFFD4A85C);       // amarelo areia/aquarela

  // ── Divisores
  static const Color divider = Color(0xFF2A2420);
  static const Color dividerLight = Color(0xFF3A3428);

  // ── Utilidade
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFF5F0E8);
  static const Color black = Color(0xFF080706);
}

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.cormorant(
        fontSize: 80,
        fontWeight: FontWeight.w300,
        letterSpacing: 12,
        color: AppColors.onBackground,
        height: 1.0,
      );

  static TextStyle get displayMedium => GoogleFonts.cormorant(
        fontSize: 52,
        fontWeight: FontWeight.w300,
        letterSpacing: 8,
        color: AppColors.onBackground,
        height: 1.1,
      );

  static TextStyle get displaySmall => GoogleFonts.cormorant(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 4,
        color: AppColors.onBackground,
        height: 1.2,
      );

  static TextStyle get headlineLarge => GoogleFonts.cormorant(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        color: AppColors.onBackground,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.cormorant(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 1,
        color: AppColors.onBackground,
        height: 1.4,
      );

  static TextStyle get titleLarge => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.onBackground,
      );

  static TextStyle get titleMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: AppColors.onBackground,
      );

  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: AppColors.onSurface,
        height: 1.7,
      );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: AppColors.onSurface,
        height: 1.6,
      );

  static TextStyle get labelLarge => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.5,
        color: AppColors.onSurfaceMuted,
      );

  static TextStyle get labelMedium => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        color: AppColors.onSurfaceMuted,
      );

  // Estilo para texto em seções de papel claro (tinta sobre papel)
  static TextStyle get bodyOnPaper => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.paperInk,
        height: 1.6,
      );

  static TextStyle get labelOnPaper => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: AppColors.paperInk.withValues(alpha: 0.5),
      );

  static TextStyle get accent => GoogleFonts.cormorant(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: AppColors.accent,
        letterSpacing: 0.5,
      );
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.accent,
        secondary: AppColors.crimson,
        onSurface: AppColors.onBackground,
        onPrimary: AppColors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.labelLarge.copyWith(
          fontSize: 12,
          letterSpacing: 4,
          color: AppColors.onBackground,
        ),
        iconTheme: const IconThemeData(color: AppColors.onBackground),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.onSurface,
        size: 20,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.onSurfaceMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceMuted,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accent.withValues(alpha: 0.2),
        labelStyle: AppTextStyles.labelLarge,
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
