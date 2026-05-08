// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

/// Single source of truth for every color, radius, shadow, and text style
/// used across HomeScreen, FeedPostCard, SocialFeedScreen, and the nav bar.
class AppTheme {
  AppTheme._();

  // ── Brand colors ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2E7D32); // deep forest green
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primarySurface = Color(0xFFE8F5E9); // green tint bg

  static const Color accent = Color(0xFF00897B); // teal accent
  static const Color accentSurface = Color(0xFFE0F2F1);

  // Post-type badge colors
  static const Color badgeIdentification = Color(0xFF2E7D32);
  static const Color badgeIdentificationBg = Color(0xFFE8F5E9);
  static const Color badgeTranslation = Color(0xFF1565C0);
  static const Color badgeTranslationBg = Color(0xFFE3F2FD);
  static const Color badgePlantOfDay = Color(0xFFE65100);
  static const Color badgePlantOfDayBg = Color(0xFFFFF3E0);

  // Approval chip
  static const Color approvedText = Color(0xFF6A1B9A);
  static const Color approvedBg = Color(0xFFF3E5F5);

  // Translation box
  static const Color translationText = Color(0xFF1565C0);
  static const Color translationBg = Color(0xFFEEF4FF);
  static const Color translationBorder = Color(0xFFBBD4F8);
  static const Color translationTagBg = Color(0xFFDBEAFD);

  // Action icons
  static const Color likeActive = Color(0xFFE91E63);
  static const Color upvoteColor = Color(0xFF2E7D32);
  static const Color downvoteColor = Color(0xFFC62828);
  static const Color actionIcon = Color(0xFF9E9E9E);

  // Surfaces
  static const Color scaffoldBg = Color(0xFFF4F6F4);
  static const Color cardBg = Colors.white;
  static const Color navBg = Colors.white;
  static const Color divider = Color(0xFFEEEEEE);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textHint = Color(0xFFBDBDBD);

  // ── Radii ─────────────────────────────────────────────────────────────────
  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusPill = 40;

  // ── Elevation shadows ─────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.055),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.025),
          blurRadius: 4,
          spreadRadius: 0,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get navShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ];

  // ── Text styles ───────────────────────────────────────────────────────────
  static const TextStyle plantName = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppTheme.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle scientificName = TextStyle(
    fontSize: 13,
    fontStyle: FontStyle.italic,
    color: AppTheme.textSecondary,
    letterSpacing: 0.1,
  );

  static const TextStyle userHandle = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );

  static const TextStyle locationText = TextStyle(
    fontSize: 12,
    color: AppTheme.textSecondary,
  );

  static const TextStyle timeAgo = TextStyle(
    fontSize: 11.5,
    color: Color(0xFFAAAAAA),
  );

  static const TextStyle actionCount = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppTheme.actionIcon,
  );

  // ── Material 3 ThemeData ──────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: scaffoldBg,
        ),
        scaffoldBackgroundColor: scaffoldBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          margin: EdgeInsets.zero,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSm),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSm),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
}
