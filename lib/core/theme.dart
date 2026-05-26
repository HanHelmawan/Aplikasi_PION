import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pion Design System – Modern Tech (Inter)
class PionTheme {
  // ── Color Tokens ────────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF2563EB); // Royal Blue (Biru Utama)
  static const Color primaryDark    = Color(0xFF1D4ED8);
  static const Color primaryLight   = Color(0xFFEFF6FF);
  static const Color primaryBorder  = Color(0xFFBFDBFE);

  static const Color white          = Color(0xFFFFFFFF); // Pure White (Primary Surface)
  static const Color background     = Color(0xFFF8FAFC); // Slate 50 (Secondary Background)
  static const Color surface        = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceAlt     = Color(0xFFF8FAFC); // softer grey-blue

  static const Color textDark       = Color(0xFF0F172A); // Slate 900 (Heading Text)
  static const Color textMedium     = Color(0xFF475569); // Slate 600 (Body Text)
  static const Color textLight      = Color(0xFF94A3B8); // Slate 400 (Placeholder/Disabled)

  static const Color border         = Color(0xFFE2E8F0);
  static const Color divider        = Color(0xFFF1F5F9);

  static const Color error          = Color(0xFFEF4444); // Red 500 (Danger / SOS)
  static const Color errorLight     = Color(0xFFFEE2E2);
  static const Color success        = Color(0xFF10B981); // Emerald (Success / Escrow Clear)
  static const Color successLight   = Color(0xFFD1FAE5);
  static const Color warning        = Color(0xFFF59E0B); // Amber (Warning / Rating)
  static const Color warningLight   = Color(0xFFFEF3C7);

  // ── ThemeData ────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => buildTheme(isWorkerMode: false);

  static ThemeData buildTheme({bool isWorkerMode = false}) {
    final Color currentPrimary = isWorkerMode ? const Color(0xFF4F46E5) : const Color(0xFF2563EB);
    final Color currentPrimaryDark = isWorkerMode ? const Color(0xFF3730A3) : const Color(0xFF1D4ED8);
    final Color currentPrimaryLight = isWorkerMode ? const Color(0xFFEEF2FF) : const Color(0xFFEFF6FF);
    final Color currentPrimaryBorder = isWorkerMode ? const Color(0xFFC7D0F8) : const Color(0xFFBFDBFE);

    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: currentPrimary,
      scaffoldBackgroundColor: background,
      textTheme: baseTextTheme,
      colorScheme: ColorScheme.light(
        primary: currentPrimary,
        primaryContainer: currentPrimaryDark,
        onPrimary: white,
        secondary: currentPrimary,
        surface: surface,
        onSurface: textDark,
        error: error,
        outline: border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: currentPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: textDark, // Keep header text readable with textDark
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: currentPrimary,
          foregroundColor: white,
          elevation: 0,
          shadowColor: currentPrimary.withOpacity(0.3),
          shape: const StadiumBorder(), // Pill shape
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 0;
            return 8; // Soft shadow when idle
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: currentPrimary,
          side: BorderSide(color: currentPrimary, width: 1.5),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: currentPrimary,
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none, // borderless feel
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: currentPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.inter(color: textLight, fontSize: 15),
      ),
      dividerColor: divider,
      dividerTheme: const DividerThemeData(color: divider, space: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: currentPrimary,
        unselectedItemColor: textLight,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: currentPrimary,
        foregroundColor: white,
        elevation: 8,
        shape: const StadiumBorder(),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: currentPrimaryLight,
        labelStyle: GoogleFonts.inter(
          color: currentPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
    );
  }
}

/// A robust network image widget with built-in loading and error fallbacks
class PionImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Color? fallbackColor;

  const PionImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget img = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: fallbackColor ?? Theme.of(context).primaryColor.withOpacity(0.08),
          child: Icon(
            Icons.broken_image_rounded,
            color: Theme.of(context).primaryColor,
            size: width != null ? (width! > 48 ? 32 : 20) : 24,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFF8FAFC),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );

    if (borderRadius > 0) {
      img = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: img,
      );
    }
    return img;
  }
}

/// A robust circular avatar with built-in fallback for network image loading failures
class PionAvatar extends StatelessWidget {
  final String url;
  final double radius;
  final double borderWidth;
  final Color? borderColor;

  const PionAvatar({
    super.key,
    required this.url,
    required this.radius,
    this.borderWidth = 0,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = ClipOval(
      child: Image.network(
        url,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: radius * 2,
            height: radius * 2,
            color: Theme.of(context).primaryColor.withOpacity(0.08),
            child: Icon(
              Icons.person_rounded,
              color: Theme.of(context).primaryColor,
              size: radius * 1.1,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: radius * 2,
            height: radius * 2,
            color: const Color(0xFFF8FAFC),
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ),
          );
        },
      ),
    );

    if (borderWidth > 0) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Colors.white,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    return avatar;
  }
}
