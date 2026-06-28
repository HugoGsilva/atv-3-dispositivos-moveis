import 'package:flutter/material.dart';

/// Constantes de marca (cores fixas usadas em gradientes, estrelas e pódio).
class AppColors {
  // Verde da marca (semente do ColorScheme)
  static const Color seed = Color(0xFF1B8A5A); // Verde esmeralda
  static const Color primaryLight = Color(0xFF1B8A5A); // Esmeralda
  static const Color primaryDark = Color(0xFF4ADE80); // Menta claro
  static const Color secondaryLight = Color(0xFF34D399); // Menta
  static const Color secondaryDark = Color(0xFF6EE7B7); // Menta suave
  static const Color emeraldDeep = Color(0xFF0F5F3D); // Verde profundo

  // Acento (estrelas)
  static const Color starColor = Color(0xFFFBBF24); // Âmbar
  static const Color starEmptyLight = Color(0xFFD5DED9); // Verde-cinza claro
  static const Color starEmptyDark = Color(0xFF3A463F); // Verde-cinza escuro

  // Pódio do ranking
  static const Color gold = Color(0xFFFFC53D); // 1º lugar
  static const Color silver = Color(0xFFB8C2CC); // 2º lugar
  static const Color bronze = Color(0xFFCD8B5C); // 3º lugar

  // Gradiente de marca (esmeralda → menta)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF0F7A4D), Color(0xFF1B8A5A), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradientDark = LinearGradient(
    colors: [Color(0xFF13422E), Color(0xFF1F7A52), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Compatibilidade: alguns widgets ainda usam estes nomes.
  static const LinearGradient primaryGradientLight = brandGradient;
  static const LinearGradient primaryGradientDark = brandGradientDark;
}

/// Define os temas claro e escuro do app.
class AppTheme {
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  /// Constrói o ThemeData para a [brightness] dada, evitando duplicação.
  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final base = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );

    final scheme = isDark
        ? base.copyWith(
            surface: const Color(0xFF0E1512), // Quase-preto verde
            surfaceContainerLowest: const Color(0xFF0B100D),
            surfaceContainerLow: const Color(0xFF141C18),
            surfaceContainer: const Color(0xFF18211C), // Cards
            surfaceContainerHigh: const Color(0xFF1E2823),
            surfaceContainerHighest: const Color(0xFF24302A), // Inputs
            outlineVariant: const Color(0xFF2C3A33), // Bordas sutis
            onSurface: const Color(0xFFE6F0EA),
            onSurfaceVariant: const Color(0xFF9DB3A8),
          )
        : base.copyWith(
            surface: const Color(0xFFF7FBF8), // Off-white verde
            surfaceContainerLowest: const Color(0xFFFFFFFF),
            surfaceContainerLow: const Color(0xFFFFFFFF),
            surfaceContainer: const Color(0xFFFFFFFF), // Cards
            surfaceContainerHigh: const Color(0xFFEFF5F1),
            surfaceContainerHighest: const Color(0xFFEAF2EC), // Inputs
            outlineVariant: const Color(0xFFDCE7E0), // Bordas sutis
            onSurface: const Color(0xFF13241B),
            onSurfaceVariant: const Color(0xFF5B7268),
          );

    final radius = BorderRadius.circular(16);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,

      // AppBar flat: funde com o fundo, título forte, sem sombra.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),

      // Cards: superfície de container, SEM sombra, com borda sutil de 1px.
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      // Botão primário cheio, sem elevação, cantos suaves.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),

      // Inputs preenchidos e sem moldura dura: só o foco mostra o verde.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        prefixIconColor: scheme.onSurfaceVariant,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: scheme.primary),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),

      // Chips (usados como "pills" de informação).
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 1,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      textTheme: _textTheme(scheme),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final primary = scheme.onSurface;
    final secondary = scheme.onSurfaceVariant;
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: TextStyle(fontSize: 15, height: 1.45, color: primary),
      bodyMedium: TextStyle(fontSize: 13.5, height: 1.4, color: secondary),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
    );
  }
}
