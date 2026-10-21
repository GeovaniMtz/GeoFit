import 'package:flutter/material.dart';

/// GeoLift — dirección "fitness": negro puro, tarjetas sin borde, números
/// enormes como protagonistas (con la unidad chiquita pegada) y anillos de
/// progreso. Inspirada en la mezcla de Google Fit (anillos, fila de
/// métricas, semana con mini anillos) y Apple Fitness (fondo negro,
/// tipografía grande, barra flotante), con el naranja óxido de siempre y un
/// verde lima para volumen, récords y sugerencias.
///
/// [GeoLiftColors] es la variante oscura (la principal) y
/// [GeoLiftLightColors] la clara.
class GeoLiftColors {
  GeoLiftColors._();

  static const bg = Color(0xFF000000);
  static const surface = Color(0xFF161514);
  static const surfaceHigh = Color(0xFF1F1C1A);
  static const surfaceHighest = Color(0xFF2A2624);
  static const border = Color(0xFF262321);
  static const borderStrong = Color(0xFF3A3532);

  static const accent = Color(0xFFFF6B35);

  /// Pista de los anillos de acento (el acento muy apagado).
  static const accentTrack = Color(0xFF3A1A0E);
  static const accentDim = Color(0xFFC1481F);
  static const onAccent = Color(0xFF1C120A);

  static const success = Color(0xFFB8E34A);
  static const successContainer = Color(0xFF1A2008);
  static const successTrack = Color(0xFF26300F);
  static const onSuccess = Color(0xFF15170A);

  static const text = Color(0xFFF5F1EC);
  static const textMuted = Color(0xFF9A928A);
  static const textFaint = Color(0xFF8A827B);

  static const error = Color(0xFFFF6A63);
  static const onError = Color(0xFF1C0A0A);
}

class GeoLiftLightColors {
  GeoLiftLightColors._();

  static const bg = Color(0xFFF6F3EE);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceHigh = Color(0xFFEFEAE3);
  static const surfaceHighest = Color(0xFFE5DED4);
  static const border = Color(0xFFE5DED4);
  static const borderStrong = Color(0xFFCFC5B8);

  static const accent = Color(0xFFD8531E);
  static const accentTrack = Color(0xFFF6DDD1);
  static const accentDim = Color(0xFFC1481F);
  static const onAccent = Color(0xFFFFF7F2);

  static const success = Color(0xFF4F7A0E);
  static const successContainer = Color(0xFFE6F0CC);
  static const successTrack = Color(0xFFDCE8BE);
  static const onSuccess = Color(0xFFF4FAE6);

  static const text = Color(0xFF1B1714);
  static const textMuted = Color(0xFF6B5F53);
  static const textFaint = Color(0xFF7A6E62);

  static const error = Color(0xFFB3261E);
  static const onError = Color(0xFFFFF7F2);
}

/// Escala única de bordes redondeados: todo lo que tenga esquinas sale de
/// aquí. Los botones principales son píldoras (StadiumBorder).
class GeoLiftRadius {
  GeoLiftRadius._();

  /// Etiquetas y elementos pequeños.
  static const double sm = 10;

  /// Campos de texto, filas tocables, avisos.
  static const double md = 18;

  /// Tarjetas.
  static const double lg = 24;

  /// Diálogos y hojas inferiores.
  static const double xl = 32;
}

/// Escala de espaciado (múltiplos de 4). [page] es el margen lateral de
/// todas las pantallas.
class GeoLiftSpacing {
  GeoLiftSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double page = 16;

  /// Espacio al final de las pantallas con barra de navegación: la barra
  /// flota sobre el contenido, así que lo último de la lista no debe
  /// quedar debajo de ella.
  static const double bajoBarra = 120;
}

/// Colores que el ColorScheme de Material no tiene: las pistas apagadas de
/// los anillos. Se leen con `Theme.of(context).extension<GeoLiftExtra>()`
/// o, más corto, `GeoLiftExtra.of(context)`.
class GeoLiftExtra extends ThemeExtension<GeoLiftExtra> {
  final Color pistaAcento;
  final Color pistaExito;

  const GeoLiftExtra({required this.pistaAcento, required this.pistaExito});

  /// Si el tema no trae la extensión (p. ej. un MaterialApp de test sin el
  /// tema de GeoLift), se derivan las pistas de los colores del tema.
  static GeoLiftExtra of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<GeoLiftExtra>() ??
        GeoLiftExtra(
          pistaAcento: theme.colorScheme.primary.withValues(alpha: 0.2),
          pistaExito: theme.colorScheme.secondary.withValues(alpha: 0.2),
        );
  }

  @override
  GeoLiftExtra copyWith({Color? pistaAcento, Color? pistaExito}) =>
      GeoLiftExtra(
        pistaAcento: pistaAcento ?? this.pistaAcento,
        pistaExito: pistaExito ?? this.pistaExito,
      );

  @override
  GeoLiftExtra lerp(GeoLiftExtra? other, double t) {
    if (other == null) return this;
    return GeoLiftExtra(
      pistaAcento: Color.lerp(pistaAcento, other.pistaAcento, t)!,
      pistaExito: Color.lerp(pistaExito, other.pistaExito, t)!,
    );
  }
}

/// Estilo para números grandes: cifras de ancho fijo, así "62.5" y "67.5"
/// ocupan lo mismo y nada brinca al cambiar el peso.
TextStyle estiloNumero(double tamano, {Color? color, FontWeight? peso}) {
  return TextStyle(
    fontFamily: 'Manrope',
    fontSize: tamano,
    fontWeight: peso ?? FontWeight.w800,
    height: 1.05,
    letterSpacing: -0.5,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
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
  final accentDim =
      dark ? GeoLiftColors.accentDim : GeoLiftLightColors.accentDim;
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

  final baseTypography =
      Typography.material2021(platform: TargetPlatform.android);
  final baseText = (dark ? baseTypography.white : baseTypography.black)
      .apply(fontFamily: 'Manrope', bodyColor: text, displayColor: text);

  TextStyle fuerte(TextStyle? base, double tracking) =>
      (base ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w800, letterSpacing: tracking, color: text);

  final textTheme = baseText.copyWith(
    displayLarge: fuerte(baseText.displayLarge, -1.5),
    displayMedium: fuerte(baseText.displayMedium, -1.2),
    displaySmall: fuerte(baseText.displaySmall, -1),
    headlineLarge: fuerte(baseText.headlineLarge, -0.8),
    headlineMedium: fuerte(baseText.headlineMedium, -0.6),
    headlineSmall: fuerte(baseText.headlineSmall, -0.4),
    titleLarge: fuerte(baseText.titleLarge, -0.3),
    titleMedium: fuerte(baseText.titleMedium, -0.2),
    titleSmall: fuerte(baseText.titleSmall, 0),
    labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w800),
    labelMedium: baseText.labelMedium?.copyWith(fontWeight: FontWeight.w700),
    labelSmall: baseText.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: textFaint,
      letterSpacing: 1,
    ),
    bodyLarge: baseText.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
    bodyMedium: baseText.bodyMedium
        ?.copyWith(color: textMuted, fontWeight: FontWeight.w600),
    bodySmall: baseText.bodySmall
        ?.copyWith(color: textMuted, fontWeight: FontWeight.w600),
  );

  final radioMd = BorderRadius.circular(GeoLiftRadius.md);
  final formaMd = RoundedRectangleBorder(borderRadius: radioMd);
  const pildora = StadiumBorder();

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: bg,
    dividerColor: border,
    splashFactory: InkRipple.splashFactory,
    iconTheme: IconThemeData(color: textMuted),
    extensions: [
      GeoLiftExtra(
        pistaAcento:
            dark ? GeoLiftColors.accentTrack : GeoLiftLightColors.accentTrack,
        pistaExito:
            dark ? GeoLiftColors.successTrack : GeoLiftLightColors.successTrack,
      ),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: GeoLiftSpacing.page + 4,
      toolbarHeight: 64,
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w800,
        fontSize: 30,
        letterSpacing: -0.6,
        color: text,
      ),
    ),
    // Tarjetas sin borde: se separan del fondo solo por su color.
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeoLiftRadius.lg),
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
        minimumSize: const Size(48, 58),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 0.4,
        ),
        shape: pildora,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        backgroundColor: surface,
        side: BorderSide.none,
        minimumSize: const Size(48, 54),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 15,
          letterSpacing: 0.4,
        ),
        shape: pildora,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 0.4,
        ),
        shape: pildora,
      ),
    ),
    // Botones de solo ícono: círculo gris, sin borde.
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: surfaceHigh,
        foregroundColor: text,
        disabledBackgroundColor: surfaceHigh,
        disabledForegroundColor: textFaint.withValues(alpha: 0.5),
        shape: const CircleBorder(),
        minimumSize: const Size(46, 46),
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
      shape: const CircleBorder(),
    ),
    // Como muchos botones no llevan texto, el tooltip es su "nombre": se ve
    // al mantener presionado y lo leen los lectores de pantalla.
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceHighest,
        borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
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
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radioMd,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radioMd,
        borderSide: BorderSide(color: accent, width: 1.6),
      ),
      labelStyle: TextStyle(color: textFaint, fontWeight: FontWeight.w700),
      hintStyle: TextStyle(color: textFaint),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? accent : surfaceHigh;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? onAccent : textMuted;
        }),
        side: const WidgetStatePropertyAll(BorderSide.none),
        shape: const WidgetStatePropertyAll(pildora),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 14),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
              fontFamily: 'Manrope', fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceHighest,
      contentTextStyle: TextStyle(
          color: text, fontFamily: 'Manrope', fontWeight: FontWeight.w700),
      actionTextColor: accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: radioMd),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w800,
        fontSize: 22,
        letterSpacing: -0.3,
        color: text,
      ),
      contentTextStyle: TextStyle(
          fontFamily: 'Manrope', color: textMuted, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeoLiftRadius.xl),
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
