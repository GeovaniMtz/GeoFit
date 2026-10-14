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

/// Escala única de bordes redondeados. Antes cada widget elegía el suyo
/// (6, 8, 9, 10, 12, 14…) y eso se notaba como falta de armonía: todo lo
/// que tenga esquinas debe salir de aquí.
class GeoLiftRadius {
  GeoLiftRadius._();

  /// Chips, etiquetas, elementos pequeños.
  static const double sm = 8;

  /// Botones, campos de texto, steppers, filas tocables.
  static const double md = 14;

  /// Tarjetas y contenedores de sección.
  static const double lg = 20;

  /// Diálogos y hojas inferiores.
  static const double xl = 28;
}

/// Escala de espaciado (múltiplos de 4). [page] es el margen lateral de
/// todas las pantallas; los saltos entre bloques salen del resto.
class GeoLiftSpacing {
  GeoLiftSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double page = 20;
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
    outline: borderStrong,
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
      fontWeight: FontWeight.w800,
      color: textFaint,
      letterSpacing: 1.2,
    ),
    bodyMedium: baseText.bodyMedium?.copyWith(color: textMuted),
    bodySmall: baseText.bodySmall?.copyWith(color: textMuted),
  );

  final radioMd = BorderRadius.circular(GeoLiftRadius.md);
  final formaMd = RoundedRectangleBorder(borderRadius: radioMd);

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
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: GeoLiftSpacing.page,
      titleTextStyle: TextStyle(
        fontFamily: 'Oswald',
        fontWeight: FontWeight.w700,
        fontSize: 26,
        letterSpacing: 0.4,
        color: text,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeoLiftRadius.lg),
        side: BorderSide(color: border),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: textMuted,
      textColor: text,
      shape: formaMd,
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: onAccent,
        disabledBackgroundColor: surfaceHighest,
        disabledForegroundColor: textFaint,
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 15,
          letterSpacing: 0.8,
        ),
        shape: formaMd,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        side: BorderSide(color: borderStrong, width: 1.2),
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 0.6,
        ),
        shape: formaMd,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 0.6,
        ),
        shape: formaMd,
      ),
    ),
    // Botones de solo ícono: superficie suave, sin borde, mismo radio que
    // el resto de botones. Los que necesiten destacar usan IconButton.filled.
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: surfaceHigh,
        foregroundColor: textMuted,
        disabledBackgroundColor: surfaceHigh,
        disabledForegroundColor: textFaint.withValues(alpha: 0.5),
        shape: formaMd,
        minimumSize: const Size(48, 48),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: onAccent,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      iconSize: 28,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeoLiftRadius.lg),
      ),
    ),
    // Como muchos botones ya no llevan texto, el tooltip es su "nombre":
    // se ve al mantener presionado y lo leen los lectores de pantalla.
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceHighest,
        borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
        border: Border.all(color: borderStrong),
      ),
      textStyle: TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: text,
      ),
      waitDuration: const Duration(milliseconds: 400),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: radioMd,
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radioMd,
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radioMd,
        borderSide: BorderSide(color: accent, width: 1.6),
      ),
      labelStyle: TextStyle(color: textFaint, fontWeight: FontWeight.w700),
      hintStyle: TextStyle(color: textFaint),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      // Solo íconos: el nombre de cada sección queda como tooltip (mantener
      // presionado) y la píldora de color marca cuál está activa.
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      indicatorColor: accent.withValues(alpha: dark ? 0.18 : 0.14),
      indicatorShape: formaMd,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 64,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? accent : textFaint,
          size: 26,
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
        shape: WidgetStatePropertyAll(formaMd),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 14),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
              fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceHighest,
      contentTextStyle: TextStyle(
          color: text, fontFamily: 'Manrope', fontWeight: FontWeight.w600),
      actionTextColor: accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: radioMd,
        side: BorderSide(color: borderStrong),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Oswald',
        fontWeight: FontWeight.w600,
        fontSize: 22,
        color: text,
      ),
      contentTextStyle: TextStyle(fontFamily: 'Manrope', color: textMuted),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeoLiftRadius.xl),
        side: BorderSide(color: border),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: borderStrong,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(GeoLiftRadius.xl)),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: accent,
      linearTrackColor: surfaceHighest,
    ),
  );
}
