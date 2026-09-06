import 'package:flutter/material.dart';

/// GeoLift — dirección "industrial": tipografía condensada para títulos
/// (Oswald) y texto de cuerpo en Manrope, con el mismo acento óxido de
/// hierro del plan de acción. [GeoLiftColors] es la variante oscura
/// (fondo casi negro) y [GeoLiftLightColors] la variante clara, pensada
/// como un taller a la luz del día en vez de un negativo del tema oscuro.
class GeoLiftColors {
  GeoLiftColors._();

  static const bg = Color(0xFF141210);
  static const surface = Color(0xFF1D1A17);
  static const surfaceHigh = Color(0xFF241F1B);
  static const surfaceHighest = Color(0xFF2B2521);
  static const border = Color(0xFF35302A);
  static const borderStrong = Color(0xFF473D33);

  static const accent = Color(0xFFFF6B35);
  static const accentDim = Color(0xFFC1481F);
  static const onAccent = Color(0xFF1C120A);

  static const success = Color(0xFFA4C93C);
  static const successContainer = Color(0xFF262C10);
  static const onSuccess = Color(0xFF15170A);

  static const text = Color(0xFFF3ECE3);
  static const textMuted = Color(0xFFB2A296);
  static const textFaint = Color(0xFF786A5E);

  static const error = Color(0xFFE0605A);
  static const onError = Color(0xFF1C0A0A);
}

class GeoLiftLightColors {
  GeoLiftLightColors._();

  static const bg = Color(0xFFF7F4EF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceHigh = Color(0xFFF0EBE3);
  static const surfaceHighest = Color(0xFFE7E0D5);
  static const border = Color(0xFFDCD3C6);
  static const borderStrong = Color(0xFFC2B6A3);

  static const accent = Color(0xFFD8531E);
  static const accentDim = Color(0xFFC1481F);
  static const onAccent = Color(0xFFFFF7F2);

  static const success = Color(0xFF5C7A1E);
  static const successContainer = Color(0xFFE4EDC7);
  static const onSuccess = Color(0xFF283A0A);

  static const text = Color(0xFF231F1B);
  static const textMuted = Color(0xFF6B5F53);
  static const textFaint = Color(0xFF948674);

  static const error = Color(0xFFB3261E);
  static const onError = Color(0xFFFFF7F2);
}

ThemeData geoLiftDarkTheme() => _geoLiftTheme(brightness: Brightness.dark);

ThemeData geoLiftLightTheme() => _geoLiftTheme(brightness: Brightness.light);

ThemeData _geoLiftTheme({required Brightness brightness}) {
  final dark = brightness == Brightness.dark;

  final bg = dark ? GeoLiftColors.bg : GeoLiftLightColors.bg;
  final surface = dark ? GeoLiftColors.surface : GeoLiftLightColors.surface;
  final surfaceHigh =
      dark ? GeoLiftColors.surfaceHigh : GeoLiftLightColors.surfaceHigh;
  final surfaceHighest =
      dark ? GeoLiftColors.surfaceHighest : GeoLiftLightColors.surfaceHighest;
  final border = dark ? GeoLiftColors.border : GeoLiftLightColors.border;
  final borderStrong =
      dark ? GeoLiftColors.borderStrong : GeoLiftLightColors.borderStrong;
  final accent = dark ? GeoLiftColors.accent : GeoLiftLightColors.accent;
  final accentDim = dark ? GeoLiftColors.accentDim : GeoLiftLightColors.accentDim;
  final onAccent = dark ? GeoLiftColors.onAccent : GeoLiftLightColors.onAccent;
  final success = dark ? GeoLiftColors.success : GeoLiftLightColors.success;
  final successContainer = dark
      ? GeoLiftColors.successContainer
      : GeoLiftLightColors.successContainer;
  final onSuccess =
      dark ? GeoLiftColors.onSuccess : GeoLiftLightColors.onSuccess;
  final text = dark ? GeoLiftColors.text : GeoLiftLightColors.text;
  final textMuted =
      dark ? GeoLiftColors.textMuted : GeoLiftLightColors.textMuted;
  final textFaint =
      dark ? GeoLiftColors.textFaint : GeoLiftLightColors.textFaint;
  final error = dark ? GeoLiftColors.error : GeoLiftLightColors.error;
  final onError = dark ? GeoLiftColors.onError : GeoLiftLightColors.onError;

  final base = dark ? const ColorScheme.dark() : const ColorScheme.light();
  final colorScheme = base.copyWith(
    brightness: brightness,
    primary: accent,
    onPrimary: onAccent,
    primaryContainer: accentDim,
    onPrimaryContainer: dark ? text : onAccent,
    secondary: success,
    onSecondary: onSuccess,
    secondaryContainer: successContainer,
    onSecondaryContainer: success,
    surface: bg,
    onSurface: text,
    surfaceContainerLowest: bg,
    surfaceContainerLow: surface,
    surfaceContainer: surface,
    surfaceContainerHigh: surfaceHigh,
    surfaceContainerHighest: surfaceHighest,
    onSurfaceVariant: textMuted,
    outline: border,
    outlineVariant: border,
    inverseSurface: text,
    onInverseSurface: bg,
    error: error,
    onError: onError,
  );

  final baseTypography = Typography.material2021(platform: TargetPlatform.android);
  final baseText = (dark ? baseTypography.white : baseTypography.black)
      .apply(fontFamily: 'Manrope', bodyColor: text, displayColor: text);

  TextStyle oswald(TextStyle? base, {FontWeight weight = FontWeight.w600}) {
    return (base ?? const TextStyle())
        .copyWith(fontFamily: 'Oswald', fontWeight: weight, color: text);
  }

  final textTheme = baseText.copyWith(
    displayLarge: oswald(baseText.displayLarge, weight: FontWeight.w700),
    displayMedium: oswald(baseText.displayMedium, weight: FontWeight.w700),
    displaySmall: oswald(baseText.displaySmall, weight: FontWeight.w700),
    headlineLarge: oswald(baseText.headlineLarge, weight: FontWeight.w700),
    headlineMedium: oswald(baseText.headlineMedium, weight: FontWeight.w700),
    headlineSmall: oswald(baseText.headlineSmall, weight: FontWeight.w600),
    titleLarge: oswald(baseText.titleLarge, weight: FontWeight.w600),
    titleMedium: oswald(baseText.titleMedium, weight: FontWeight.w600),
    titleSmall: oswald(baseText.titleSmall, weight: FontWeight.w600),
    labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w800),
    labelMedium: baseText.labelMedium?.copyWith(fontWeight: FontWeight.w700),
    labelSmall: baseText.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: textFaint,
      letterSpacing: 0.4,
    ),
    bodyMedium: baseText.bodyMedium?.copyWith(color: textMuted),
    bodySmall: baseText.bodySmall?.copyWith(color: textMuted),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: bg,
    dividerColor: border,
    splashFactory: InkRipple.splashFactory,
    iconTheme: IconThemeData(color: textMuted),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Oswald',
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: 0.6,
        color: text,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: border),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: textMuted,
      textColor: text,
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: onAccent,
        disabledBackgroundColor: surfaceHighest,
        disabledForegroundColor: textFaint,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textMuted,
        side: BorderSide(color: borderStrong, width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(
            fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: const TextStyle(
            fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 13),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: surfaceHigh,
        foregroundColor: textMuted,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        minimumSize: const Size(44, 44),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accent, width: 1.6),
      ),
      labelStyle: TextStyle(color: textFaint, fontWeight: FontWeight.w700),
      hintStyle: TextStyle(color: textFaint),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Manrope',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: selected ? accent : textFaint,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? accent : textFaint,
          size: 22,
        );
      }),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? accent
              : Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? onAccent : textMuted;
        }),
        side: WidgetStatePropertyAll(BorderSide(color: border)),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
              fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceHigh,
      contentTextStyle: TextStyle(color: text),
      actionTextColor: accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: border),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Oswald',
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: text,
      ),
      contentTextStyle: TextStyle(fontFamily: 'Manrope', color: textMuted),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
  );
}
