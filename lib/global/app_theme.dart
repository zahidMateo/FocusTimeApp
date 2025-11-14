import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'app_colors.dart';

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

  // ═══════════════════════════════════════════════════════════════════════════════════
  // NOTA: Dark Mode (Tema oscuro)
  // ═══════════════════════════════════════════════════════════════════════════════════
  //
  // Si en el futuro quieres agregar un tema oscuro, crea otro ThemeData:
  //
  // static ThemeData darkTheme = ThemeData(
  //   useMaterial3: true,
  //   colorScheme: ColorScheme.dark(
  //     primary: AppColors.lavender,
  //     background: Color(0xFF121212),  // Fondo oscuro
  //     surface: Color(0xFF1E1E1E),     // Superficies oscuras
  //     // ... etc
  //   ),
  //   // ... resto de configuraciones
  // );
  //
  // Y en main.dart:
  //   MaterialApp(
  //     theme: AppTheme.lightTheme,      ← Tema claro
  //     darkTheme: AppTheme.darkTheme,   ← Tema oscuro
  //     themeMode: ThemeMode.system,     ← Sigue configuración del sistema
  //   )
}
