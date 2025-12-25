import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// APP THEME EXTENSIONS - EXTENSIONES PARA ACCEDER A COLORES DEL TEMA ACTUAL
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Este archivo proporciona extensiones para acceder fácilmente a los colores del tema
// actual (claro u oscuro) sin tener que escribir Theme.of(context) cada vez.
//
// ¿POR QUÉ USAR ESTO?
// - Respeta automáticamente el tema actual (claro/oscuro)
// - Código más limpio y legible
// - Fácil de mantener
//
// USO:
// En vez de:
//   ❌ color: AppColors.sky  (siempre el mismo color, ignora tema oscuro)
//   ❌ color: Theme.of(context).colorScheme.tertiary  (muy verboso)
//
// Usa:
//   ✅ color: context.colors.accent  (respeta tema y es corto)
//
// ═══════════════════════════════════════════════════════════════════════════════════

// ┌─────────────────────────────────────────────────────────────────────────────────┐
// │ EXTENSIÓN DE BUILDCONTEXT - Acceso rápido a colores del tema                   │
// └─────────────────────────────────────────────────────────────────────────────────┘
extension ThemeExtension on BuildContext {
  /// Acceso rápido al ColorScheme del tema actual
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Acceso rápido al TextTheme del tema actual
  TextTheme get textTheme => Theme.of(this).textTheme;
}

// ┌─────────────────────────────────────────────────────────────────────────────────┐
// │ EXTENSIÓN DE COLORSCHEME - Nombres semánticos para colores                     │
// └─────────────────────────────────────────────────────────────────────────────────┘
// Proporciona nombres más intuitivos basados en el uso de colores en la app
extension ColorSchemeExtension on ColorScheme {
  // ─── Colores principales ───

  /// Color de acento principal (Sky en claro, adaptado en oscuro)
  /// Usado para: iconos destacados, elementos de acción
  Color get accent => tertiary;

  /// Color de texto principal
  /// Usado para: títulos, texto importante
  Color get textPrimary => onSurface;

  /// Color de texto secundario / desactivado
  /// Usado para: subtítulos, texto de ayuda
  Color get textSecondary => onSurface.withOpacity(0.6);

  /// Color de fondo de cards y superficies
  /// Usado para: Cards, AppBar, superficies elevadas
  Color get cardBackground => surface;

  /// Color de fondo principal de la app
  /// Usado para: Scaffold background
  Color get appBackground => background;

  /// Color para elementos destructivos (eliminar, resetear)
  /// Usado para: botones de eliminar, advertencias
  Color get destructive => error;

  /// Color para bordes
  /// Usado para: bordes de cards, dividers
  Color get borderColor => outline;
}
