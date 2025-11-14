import 'dart:ui';

import 'package:flutter/src/painting/text_style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodoro_app/global/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// APP TYPOGRAPHY - ESTILOS DE TEXTO DE LA APLICACIÓN
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Este archivo define TODOS los estilos de texto (tipografía) de la app.
// Usamos la fuente "Poppins" de Google Fonts para un look moderno y profesional.
//
// ¿POR QUÉ CENTRALIZAR LOS ESTILOS?
// - Consistencia visual en toda la app
// - Si quieres cambiar el tamaño o color de un tipo de texto, solo lo cambias aquí
// - Reutilización de estilos sin código duplicado
// - Facilita seguir guías de diseño (como Material Design 3)
//
// ¿CÓMO USAR?
// En vez de escribir:
//   ❌ Text('Hola', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
//
// Usa:
//   ✅ Text('Hola', style: AppTypography.heading1)
//
// ¿CÓMO MODIFICAR UN ESTILO?
// Usa .copyWith() para cambiar propiedades específicas:
//   Text('Error', style: AppTypography.bodyMedium.copyWith(color: Colors.red))
//
// ═══════════════════════════════════════════════════════════════════════════════════

class AppTypography {
  // Constructor privado - previene instanciación
  AppTypography._();

  // ─────────────────────────────────────────────────────────────────────────────────
  // FUENTE BASE
  // ─────────────────────────────────────────────────────────────────────────────────
  // La app usa "Poppins" como fuente principal

  static String get fontFamily => 'Poppins';

  // ─────────────────────────────────────────────────────────────────────────────────
  // ESTILOS PRINCIPALES - Jerarquía de texto de mayor a menor
  // ─────────────────────────────────────────────────────────────────────────────────

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ TIMER DISPLAY - Texto más grande de la app (60px)                            ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  // Usado para: El timer principal (25:00)
  // Tamaño: text-6xl (60px)
  // Peso: Bold (700) - Extra grueso para máxima legibilidad
  // letterSpacing negativo para que los números se vean más compactos

  static TextStyle get timerDisplay => GoogleFonts.poppins(
        fontSize: 60,
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
        letterSpacing: -1.5,
        height: 1.0,
      );

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ HEADING 1 - Títulos principales (24px)                                       ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  // Usado para: Títulos de secciones principales
  // Tamaño: text-2xl (24px)
  // Peso: Bold (700)

  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
        letterSpacing: 0,
      );

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ HEADING 2 - Subtítulos (20px)                                                ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  // Usado para: Subtítulos y encabezados de cards
  // Tamaño: text-xl (20px)
  // Peso: Semi-Bold (600)

  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: 0,
      );

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ BODY LARGE - Texto normal grande (16px)                                      ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  // Usado para: Párrafos principales, descripciones importantes
  // Tamaño: text-base (16px)
  // Peso: Regular (400) - Grosor normal
  // height 1.5 = espaciado cómodo entre líneas

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.foreground,
        height: 1.5,
      );

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ BODY MEDIUM - Texto normal con peso medio (16px)                             ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  // Usado para: Texto que necesita un poco más de énfasis que bodyLarge
  // Tamaño: text-base (16px)
  // Peso: Medium (500) - Un poco más grueso que Regular

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.foreground,
        height: 1.5,
      );

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ BODY SMALL - Texto pequeño (14px)                                            ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  // Usado para: Descripciones secundarias, subtítulos de list tiles
  // Tamaño: text-sm (14px)
  // Peso: Regular (400)
  // Color: mutedForeground (gris para menos énfasis)

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedForeground,
        height: 1.5,
      );

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ CAPTION - Texto extra pequeño (12px)                                         ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  // Usado para: Notas, etiquetas pequeñas, texto legal
  // Tamaño: text-xs (12px)
  // Peso: Regular (400)
  // Color: mutedForeground (menos prominente)

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedForeground,
        height: 1.4,
      );

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ LABEL - Etiquetas y labels de formularios (14px)                             ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  // Usado para: Etiquetas de campos, labels de switches
  // Tamaño: 14px
  // Peso: Semi-Bold (600) - Peso medio-alto para destacar
  // letterSpacing: 0.5 para mayor legibilidad en etiquetas

  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: 0.5,
      );

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ BUTTON - Texto de botones (16px)                                             ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  // Usado para: Texto dentro de botones
  // Tamaño: 16px
  // Peso: Semi-Bold (600)
  // Color: primaryForeground (contrasta con el fondo del botón)

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryForeground,
        letterSpacing: 0.5,
      );

  // ─────────────────────────────────────────────────────────────────────────────────
  // VARIANTES DE COLOR - Estilos preconfigurados con colores específicos
  // ─────────────────────────────────────────────────────────────────────────────────
  // Estos son estilos auxiliares que puedes combinar con los anteriores

  // Texto en color primario (lavanda)
  // Ejemplo: Text('Importante', style: AppTypography.primaryText)
  static TextStyle get primaryText => GoogleFonts.poppins(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      );

  // Texto muted/desvanecido (gris claro)
  // Ejemplo: Text('Opcional', style: AppTypography.mutedText)
  static TextStyle get mutedText => GoogleFonts.poppins(
        color: AppColors.mutedForeground,
        fontWeight: FontWeight.w400,
      );

  // ─────────────────────────────────────────────────────────────────────────────────
  // GUÍA DE PESOS DE FUENTE (FontWeight)
  // ─────────────────────────────────────────────────────────────────────────────────
  // FontWeight.w100 = Thin (muy delgada)
  // FontWeight.w200 = Extra Light
  // FontWeight.w300 = Light
  // FontWeight.w400 = Regular (normal) ← Más común para texto de lectura
  // FontWeight.w500 = Medium
  // FontWeight.w600 = Semi-Bold ← Más común para títulos pequeños
  // FontWeight.w700 = Bold ← Más común para títulos principales
  // FontWeight.w800 = Extra Bold
  // FontWeight.w900 = Black (muy gruesa)
}
