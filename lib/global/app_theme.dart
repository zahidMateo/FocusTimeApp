import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'app_colors.dart';
import 'app_color_themes.dart';

// Exportar las extensiones para facilitar el acceso
export 'app_theme_extensions.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// APP THEME - TEMA VISUAL DE LA APLICACIÓN
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Este archivo define el TEMA COMPLETO de la app usando Material Design 3.
//
// ¿QUÉ ES UN THEME?
// Un theme es como una "plantilla" que define cómo se ve toda la aplicación:
// - Colores de botones, cards, fondos, texto
// - Tamaños y estilos de texto
// - Bordes, sombras, espaciados
// - Formas y animaciones
//
// ¿POR QUÉ USAR UN THEME?
// - Flutter usa estos valores automáticamente en TODOS los widgets
// - Si creas un ElevatedButton, automáticamente usa el estilo de elevatedButtonTheme
// - Si cambias un valor aquí, cambia en TODA la app instantáneamente
// - No necesitas especificar colores/estilos manualmente en cada widget
//
// ¿QUÉ ES MATERIAL DESIGN 3?
// - Es el sistema de diseño de Google (última versión)
// - Define cómo deben verse las apps modernas
// - Incluye colores, tipografía, componentes, espaciado, etc.
// - useMaterial3: true lo activa
//
// EJEMPLO DE USO:
// En main.dart, aplicas este theme:
//   MaterialApp(
//     theme: AppTheme.lightTheme,  ← Aplica TODOS estos estilos
//     home: MyHomePage(),
//   )
//
// ═══════════════════════════════════════════════════════════════════════════════════

class AppTheme {
  // Constructor privado - previene instanciación
  AppTheme._();

  // ─────────────────────────────────────────────────────────────────────────────────
  // THEME PRINCIPAL (Light Mode)
  // ─────────────────────────────────────────────────────────────────────────────────
  // ThemeData contiene TODAS las configuraciones visuales de la app

  static ThemeData lightTheme = ThemeData(
    // Activar Material Design 3 (la versión más reciente)
    useMaterial3: true,

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ COLOR SCHEME - Esquema de colores de Material Design 3                       ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝
    //
    // Material Design usa un sistema de "roles de color":
    // - primary: Color principal de la marca (lavanda)
    // - secondary: Color secundario de apoyo (mint)
    // - tertiary: Color terciario para variedad (sky)
    // - surface: Color de superficies (cards, sheets)
    // - background: Color del fondo principal
    // - error: Color para errores y acciones destructivas
    //
    // Cada color tiene su "onColor" (texto que va sobre ese color)
    // Ejemplo: primary = lavanda, onPrimary = texto claro para que se lea bien

    colorScheme: ColorScheme.light(
      // ─── Colores principales ───
      primary: AppColors.primary, // Lavanda - Color de marca principal
      onPrimary: AppColors.primaryForeground, // Texto sobre lavanda
      primaryContainer: AppColors.lavender, // Variante más clara/oscura

      // ─── Colores secundarios ───
      secondary: AppColors.secondary, // Mint - Color de apoyo
      onSecondary: AppColors.secondaryForeground, // Texto sobre mint
      secondaryContainer: AppColors.mint, // Variante del secundario

      // ─── Superficies (Cards, Sheets, etc) ───
      surface: AppColors.card, // Blanco para cards y superficies
      onSurface: AppColors.foreground, // Texto sobre superficies
      surfaceContainerHighest: AppColors.muted, // Superficie con más elevación

      // ─── Fondos ───
      background: AppColors.background, // Fondo general de la app
      onBackground: AppColors.foreground, // Texto sobre el fondo

      // ─── Error/Destructivo ───
      error: AppColors.destructive, // Rojo para errores
      onError: AppColors.destructiveForeground, // Texto sobre error (blanco)

      // ─── Bordes y contornos ───
      outline: AppColors.border, // Color de bordes principales
      outlineVariant: AppColors.input, // Variante más sutil de bordes

      // ─── Color terciario ───
      tertiary: AppColors.sky, // Sky - Color de acento adicional
      onTertiary: AppColors.accentForeground, // Texto sobre sky
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ APP BAR - Barra superior de navegación                                       ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝
    // Define cómo se ve la barra de título en todas las pantallas

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.card, // Fondo blanco
      foregroundColor: AppColors.foreground, // Texto e iconos oscuros
      elevation: 0, // Sin sombra (diseño flat/plano)
      centerTitle: true, // Título centrado
      surfaceTintColor: Colors.transparent, // Sin tinte de color
      shadowColor: AppColors.border, // Color de sombra si hay

      // Estilo del título
      titleTextStyle: TextStyle(
        color: AppColors.foreground,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ SCAFFOLD - Estructura básica de cada pantalla                                ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝
    // El Scaffold es el "lienzo" donde dibujas cada pantalla

    scaffoldBackgroundColor: AppColors.background,

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ TEXT THEME - Estilos de texto de Material Design 3                           ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝
    // Mapea nuestros estilos personalizados a los nombres de Material Design
    // Flutter usa automáticamente estos estilos en widgets como Text()

    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        // displayLarge: Texto decorativo muy grande (60px)
        // Usado en: El timer principal
        displayLarge: AppTypography.timerDisplay,

        // headlineLarge: Títulos principales (24px)
        // Usado en: Encabezados de secciones
        headlineLarge: AppTypography.heading1,

        // headlineMedium: Subtítulos (20px)
        // Usado en: Subtítulos y títulos de cards
        headlineMedium: AppTypography.heading2,

        // bodyLarge: Texto de párrafo normal grande (16px)
        // Usado en: Contenido principal
        bodyLarge: AppTypography.bodyLarge,

        // bodyMedium: Texto de párrafo mediano (14px)
        // Usado en: Descripciones, subtítulos
        bodyMedium: AppTypography.bodySmall,

        // bodySmall: Texto pequeño (12px)
        // Usado en: Notas, texto legal
        bodySmall: AppTypography.caption,

        // labelLarge: Etiquetas (14px)
        // Usado en: Labels de formularios
        labelLarge: AppTypography.label,
      ),
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ CARD - Tarjetas que contienen información                                    ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝
    // Define cómo se ven TODOS los Cards en la app

    cardTheme: CardThemeData(
      color: AppColors.card, // Fondo blanco
      elevation: 0, // Sin sombra (diseño flat moderno)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(
          color: AppColors.border, // Borde sutil gris
          width: 1,
        ),
      ),
      margin: EdgeInsets.all(AppConstants.paddingMedium),
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ ELEVATED BUTTON - Botón elevado con fondo sólido                             ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝
    // Define cómo se ven TODOS los ElevatedButton en la app
    // Ejemplo: ElevatedButton(onPressed: () {}, child: Text('Click'))

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // Fondo lavanda
        foregroundColor: AppColors.primaryForeground, // Texto claro
        elevation: 0, // Sin sombra (diseño flat)
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ OUTLINED BUTTON - Botón con borde sin fondo sólido                           ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝
    // Define cómo se ven TODOS los OutlinedButton en la app
    // Ejemplo: OutlinedButton(onPressed: () {}, child: Text('Click'))

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary, // Texto lavanda
        side: BorderSide(color: AppColors.border, width: 1.5), // Borde sutil
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ TEXT BUTTON - Botón de solo texto sin fondo ni borde                         ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝
    // Define cómo se ven TODOS los TextButton en la app
    // Ejemplo: TextButton(onPressed: () {}, child: Text('Click'))

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary, // Texto lavanda
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
      ),
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ ICON - Configuración por defecto de iconos                                   ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝
    // Define color y tamaño por defecto de TODOS los Icon en la app

    iconTheme: IconThemeData(
      color: AppColors.foreground, // Color oscuro
      size: AppConstants.buttonIconSize, // 32px
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ DIVIDER - Líneas divisoras horizontales                                      ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝
    // Define cómo se ven TODOS los Divider en la app
    // Ejemplo: Divider()

    dividerTheme: DividerThemeData(
      color: AppColors.border, // Color gris sutil
      thickness: 1, // Grosor de 1 píxel
      space: AppConstants.paddingMedium, // Espacio alrededor
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ INPUT DECORATION - Campos de texto (TextFields)                              ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝
    // Define cómo se ven TODOS los TextField en la app
    // Ejemplo: TextField(decoration: InputDecoration(labelText: 'Nombre'))

    inputDecorationTheme: InputDecorationTheme(
      filled: true, // Fondo relleno
      fillColor: AppColors.muted, // Fondo gris claro

      // Borde normal (cuando no está seleccionado)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppColors.border),
      ),

      // Borde cuando está habilitado pero no seleccionado
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppColors.border),
      ),

      // Borde cuando está seleccionado (tiene foco)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(
            color: AppColors.ring, width: 2), // Borde lavanda más grueso
      ),

      // Espaciado interno del texto
      contentPadding: EdgeInsets.all(AppConstants.paddingMedium),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────────────
  // THEME OSCURO (Dark Mode)
  // ─────────────────────────────────────────────────────────────────────────────────
  // Tema oscuro moderno usando Material Design 3 Dark Color Scheme

  static ThemeData darkTheme = ThemeData(
    // Activar Material Design 3
    useMaterial3: true,

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ COLOR SCHEME OSCURO - Paleta de colores para modo oscuro                     ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝

    colorScheme: ColorScheme.dark(
      // ─── Colores principales ───
      primary: AppColors.lavender, // Lavanda (más brillante en oscuro)
      onPrimary: Color(0xFF1A1A2E), // Texto oscuro sobre lavanda
      primaryContainer: AppColors.lavender.withOpacity(0.3),

      // ─── Colores secundarios ───
      secondary: AppColors.mint, // Mint
      onSecondary: Color(0xFF1A1A2E), // Texto oscuro sobre mint
      secondaryContainer: AppColors.mint.withOpacity(0.3),

      // ─── Superficies (Cards, Sheets, etc) ───
      surface: Color(0xFF1E1E2E), // Superficie oscura (cards)
      onSurface: Color(0xFFE5E5F0), // Texto claro sobre superficies
      surfaceContainerHighest: Color(0xFF2A2A3E), // Superficie elevada

      // ─── Fondos ───
      background: Color(0xFF121218), // Fondo principal muy oscuro
      onBackground: Color(0xFFE5E5F0), // Texto claro sobre fondo

      // ─── Error/Destructivo ───
      error: Color(0xFFFF6B6B), // Rojo más suave para oscuro
      onError: Color(0xFF1A1A2E), // Texto oscuro sobre error

      // ─── Bordes y contornos ───
      outline: Color(0xFF3A3A4E), // Bordes sutiles oscuros
      outlineVariant: Color(0xFF2A2A3E), // Variante de bordes

      // ─── Color terciario ───
      tertiary: AppColors.sky, // Sky
      onTertiary: Color(0xFF1A1A2E), // Texto oscuro sobre sky
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ APP BAR OSCURO                                                                ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝

    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E2E), // Fondo oscuro
      foregroundColor: Color(0xFFE5E5F0), // Texto claro
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      shadowColor: Color(0xFF000000),
      titleTextStyle: TextStyle(
        color: Color(0xFFE5E5F0),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ SCAFFOLD OSCURO                                                               ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝

    scaffoldBackgroundColor: Color(0xFF121218),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ TEXT THEME OSCURO                                                             ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝

    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        displayLarge: AppTypography.timerDisplay.copyWith(
          color: Color(0xFFE5E5F0),
        ),
        headlineLarge: AppTypography.heading1.copyWith(
          color: Color(0xFFE5E5F0),
        ),
        headlineMedium: AppTypography.heading2.copyWith(
          color: Color(0xFFE5E5F0),
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: Color(0xFFD0D0E0),
        ),
        bodyMedium: AppTypography.bodySmall.copyWith(
          color: Color(0xFFD0D0E0),
        ),
        bodySmall: AppTypography.caption.copyWith(
          color: Color(0xFFA0A0B5),
        ),
        labelLarge: AppTypography.label.copyWith(
          color: Color(0xFFD0D0E0),
        ),
      ),
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ CARD OSCURO                                                                   ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝

    cardTheme: CardThemeData(
      color: Color(0xFF1E1E2E), // Fondo de card oscuro
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(
          color: Color(0xFF3A3A4E), // Borde sutil
          width: 1,
        ),
      ),
      margin: EdgeInsets.all(AppConstants.paddingMedium),
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ BOTONES OSCUROS                                                               ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lavender,
        foregroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lavender,
        side: BorderSide(color: Color(0xFF3A3A4E), width: 1.5),
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lavender,
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
      ),
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ ICONOS OSCUROS                                                                ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝

    iconTheme: IconThemeData(
      color: Color(0xFFE5E5F0),
      size: AppConstants.buttonIconSize,
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ DIVIDER OSCURO                                                                ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝

    dividerTheme: DividerThemeData(
      color: Color(0xFF3A3A4E),
      thickness: 1,
      space: AppConstants.paddingMedium,
    ),

    // ╔═══════════════════════════════════════════════════════════════════════════════╗
    // ║ INPUT DECORATION OSCURO                                                       ║
    // ╚═══════════════════════════════════════════════════════════════════════════════╝

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2A2A3E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: Color(0xFF3A3A4E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: Color(0xFF3A3A4E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppColors.lavender, width: 2),
      ),
      contentPadding: EdgeInsets.all(AppConstants.paddingMedium),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════════════
  // MÉTODO PARA GENERAR THEME PERSONALIZADO SEGÚN EL TEMA SELECCIONADO
  // ═══════════════════════════════════════════════════════════════════════════════════
  static ThemeData getThemedLight(String selectedTheme) {
    final themeColors = AppColorThemes.getThemeColors(selectedTheme);
    final primaryColor = themeColors['primary']!;
    final accentColor = themeColors['accent']!;

    return lightTheme.copyWith(
      colorScheme: lightTheme.colorScheme.copyWith(
        primary: primaryColor,
        secondary: accentColor,
        tertiary: accentColor,
      ),
    );
  }

  static ThemeData getThemedDark(String selectedTheme) {
    final themeColors = AppColorThemes.getThemeColors(selectedTheme);
    final primaryColor = themeColors['primary']!;
    final accentColor = themeColors['accent']!;

    return darkTheme.copyWith(
      colorScheme: darkTheme.colorScheme.copyWith(
        primary: primaryColor,
        secondary: accentColor,
        tertiary: accentColor,
      ),
    );
  }
}
