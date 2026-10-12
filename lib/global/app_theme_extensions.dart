import 'package:flutter/material.dart';
import 'app_colors.dart';

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
  // ─── Colores principales (Stitch Focus Flow) ───

  /// Color de acento principal (Cobalt Focus Blue #2563EB)
  Color get accent => brightness == Brightness.dark ? const Color(0xFF60A5FA) : AppColors.primary;

  /// Color de texto principal (Deep Slate #0F172A)
  Color get textPrimary => onSurface;

  /// Color de texto secundario (Mid Slate #475569)
  Color get textSecondary => brightness == Brightness.dark ? const Color(0xFF94A3B8) : AppColors.mutedForeground;

  /// Color de fondo de cards y superficies elevadas (Pure White #FFFFFF)
  Color get cardBackground => brightness == Brightness.dark ? const Color(0xFF1E293B) : AppColors.card;

  /// Color de fondo principal del canvas (Focus Flow Canvas #FAF8FF)
  Color get appBackground => brightness == Brightness.dark ? const Color(0xFF131B2E) : AppColors.background;

  /// Color para elementos destructivos (Vivid Crimson #EF4444)
  Color get destructive => error;

  /// Color para bordes (1px subtle border #E2E8F0)
  Color get borderColor => brightness == Brightness.dark ? const Color(0xFF283044) : AppColors.border;
}
