import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodoro_app/global/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// APP TYPOGRAPHY - ESTILOS DE TEXTO (STITCH FOCUS FLOW)
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Sistema tipográfico híbrido de Stitch Focus Flow:
// - "Outfit": Para métricas, reloj y encabezados (geometría limpia y números tabulares)
// - "Inter": Para texto general, etiquetas, cards y descripciones
//
// ═══════════════════════════════════════════════════════════════════════════════════

class AppTypography {
  // Constructor privado - previene instanciación
  AppTypography._();

  // ─────────────────────────────────────────────────────────────────────────────────
  // FUENTES BASE
  // ─────────────────────────────────────────────────────────────────────────────────
  static String get fontFamily => 'Inter';
  static String get headlineFontFamily => 'Outfit';

  // ─────────────────────────────────────────────────────────────────────────────────
  // ESTILOS PRINCIPALES - Jerarquía de texto
  // ─────────────────────────────────────────────────────────────────────────────────

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ TIMER DISPLAY - Reloj principal (64px / 56px mobile)                          ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  static TextStyle get timerDisplay => GoogleFonts.outfit(
        fontSize: 64,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: -1.92,
        height: 1.0,
      );

  static TextStyle get displayTimer => timerDisplay;

  static TextStyle get timerDisplayMobile => GoogleFonts.outfit(
        fontSize: 56,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: -1.68,
        height: 1.0,
      );

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ HEADINGS - Encabezados con Outfit                                             ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  static TextStyle get heading1 => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: -0.64,
      );

  static TextStyle get heading2 => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: -0.24,
      );

  static TextStyle get heading3 => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      );

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ BODY - Texto de lectura con Inter                                            ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.foreground,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.foreground,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedForeground,
        height: 1.3,
      );

  // ╔═══════════════════════════════════════════════════════════════════════════════╗
  // ║ LABELS & BOTONES - Inter con pesos medios y tracking calibrado               ║
  // ╚═══════════════════════════════════════════════════════════════════════════════╝
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedForeground,
        letterSpacing: 0.33,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: 0.14,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.foreground,
        letterSpacing: 0.24,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedForeground,
        letterSpacing: 0.33,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryForeground,
        letterSpacing: 0.15,
      );

  // ─────────────────────────────────────────────────────────────────────────────────
  // VARIANTES DE COLOR - Estilos preconfigurados con colores específicos
  // ─────────────────────────────────────────────────────────────────────────────────
  // Estos son estilos auxiliares que puedes combinar con los anteriores

  // Texto en color primario (Cobalt Blue)
  // Ejemplo: Text('Importante', style: AppTypography.primaryText)
  static TextStyle get primaryText => GoogleFonts.inter(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      );

  // Texto muted/desvanecido (Mid Slate)
  // Ejemplo: Text('Opcional', style: AppTypography.mutedText)
  static TextStyle get mutedText => GoogleFonts.inter(
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
