import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design system — QuestBoard Fantasy RPG
/// ─────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // ── Dark Theme (Default) ──────────────────────────
  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: const Color(0xFF07071A),
        card: const Color(0xFF0D0D24),
        surface: const Color(0xFF141438),
        text: const Color(0xFFEEEEFF),
        textMuted: const Color(0xFF9090B8),
      );

  // ── Light Theme (Parchment/Stone) ──────────────────
  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: const Color(0xFFF5F2E9),
        card: const Color(0xFFE8E4D8),
        surface: const Color(0xFFDCD8CC),
        text: const Color(0xFF1A1A2E),
        textMuted: const Color(0xFF6B6B8A),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color card,
    required Color surface,
    required Color text,
    required Color textMuted,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      primaryColor: AppColors.gold,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: brightness,
        primary: AppColors.gold,
        secondary: AppColors.crimson,
        surface: card,
      ),
      extensions: [
        AppThemeExtension(
          bg: bg,
          bgCard: card,
          bgSurface: surface,
          textPrimary: text,
          textSecondary: textMuted,
          textMuted: isDark ? const Color(0xFF555577) : const Color(0xFFAAAAAA),
          borderSubtle: isDark ? const Color(0xFF1E1E45) : const Color(0xFFD1CDC0),
        ),
      ],
      textTheme: GoogleFonts.rajdhaniTextTheme(base.textTheme).apply(
        bodyColor: text,
        displayColor: AppColors.gold,
      ),
    );
  }
}

/// Custom colors that aren't part of standard ThemeData
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color bg;
  final Color bgCard;
  final Color bgSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color borderSubtle;

  const AppThemeExtension({
    required this.bg,
    required this.bgCard,
    required this.bgSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.borderSubtle,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? bg,
    Color? bgCard,
    Color? bgSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? borderSubtle,
  }) {
    return AppThemeExtension(
      bg: bg ?? this.bg,
      bgCard: bgCard ?? this.bgCard,
      bgSurface: bgSurface ?? this.bgSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      borderSubtle: borderSubtle ?? this.borderSubtle,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      bg: Color.lerp(bg, other.bg, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
    );
  }
}

class AppColors {
  AppColors._();
  static const Color gold = Color(0xFFF5C518);
  static const Color crimson = Color(0xFFE53935);
  static const Color academic = Color(0xFF2979FF);
  static const Color fitness = Color(0xFF00E676);
  static const Color life = Color(0xFF7C4DFF);

  static const Color easy = Color(0xFF00E676);
  static const Color medium = Color(0xFFF5C518);
  static const Color hard = Color(0xFFE53935);
  static const Color orange = Color(0xFFFF6D00);
  static const Color emerald = Color(0xFF00E676);

  // Helpers to access the extension
  static AppThemeExtension of(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()!;
}

class AppGradients {
  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFF5C518), Color(0xFFFFB300)],
  );
  
  static LinearGradient bg(BuildContext context) {
    final colors = AppColors.of(context);
    return LinearGradient(
      colors: [colors.bg, colors.bgSurface],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient header(BuildContext context) {
    final colors = AppColors.of(context);
    return LinearGradient(
      colors: [colors.bgCard, colors.bg],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}

class AppText {
  static TextStyle display({double size = 28, Color? color}) => GoogleFonts.cinzel(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.gold,
        letterSpacing: 2,
      );

  static TextStyle heading({double size = 18, Color? color}) => GoogleFonts.cinzel(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 1,
      );

  static TextStyle label({double size = 13, Color? color, double spacing = 0.5}) =>
      GoogleFonts.rajdhani(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: spacing,
      );

  static TextStyle body({double size = 15, Color? color}) => GoogleFonts.rajdhani(
        fontSize: size,
        color: color,
      );

  static TextStyle stat({double size = 20, Color? color}) => GoogleFonts.exo2(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.gold,
      );
}
