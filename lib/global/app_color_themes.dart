import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// APP COLOR THEMES - TEMAS DE COLOR PERSONALIZADOS
// ═══════════════════════════════════════════════════════════════════════════════════
// Define diferentes paletas de colores para los temas premium

class AppColorThemes {
  // ─────────────────────────────────────────────────────────────────────────────────
  // TEMA POR DEFECTO (Azul - el tema actual)
  // ─────────────────────────────────────────────────────────────────────────────────
  static const defaultPrimary = Color(0xFF2563EB); // Azul
  static const defaultAccent = Color(0xFF3B82F6);

  // ─────────────────────────────────────────────────────────────────────────────────
  // TEMA OCÉANO (Azules y Turquesas)
  // ─────────────────────────────────────────────────────────────────────────────────
  static const oceanPrimary = Color(0xFF0EA5E9); // Azul cielo
  static const oceanAccent = Color(0xFF06B6D4); // Turquesa

  // ─────────────────────────────────────────────────────────────────────────────────
  // TEMA BOSQUE (Verdes Naturales)
  // ─────────────────────────────────────────────────────────────────────────────────
  static const forestPrimary = Color(0xFF10B981); // Verde esmeralda
  static const forestAccent = Color(0xFF059669); // Verde oscuro

  // ─────────────────────────────────────────────────────────────────────────────────
  // TEMA ATARDECER (Naranjas y Rosas)
  // ─────────────────────────────────────────────────────────────────────────────────
  static const sunsetPrimary = Color(0xFFF97316); // Naranja
  static const sunsetAccent = Color(0xFFEF4444); // Rojo-rosa

  // ─────────────────────────────────────────────────────────────────────────────────
  // TEMA LAVANDA (Morados y Lilas)
  // ─────────────────────────────────────────────────────────────────────────────────
  static const lavenderPrimary = Color(0xFF8B5CF6); // Morado
  static const lavenderAccent = Color(0xFFA78BFA); // Lila

  // ─────────────────────────────────────────────────────────────────────────────────
  // MÉTODO PARA OBTENER COLORES SEGÚN EL TEMA SELECCIONADO
  // ─────────────────────────────────────────────────────────────────────────────────
  static Map<String, Color> getThemeColors(String theme) {
    switch (theme) {
      case 'ocean':
        return {'primary': oceanPrimary, 'accent': oceanAccent};
      case 'forest':
        return {'primary': forestPrimary, 'accent': forestAccent};
      case 'sunset':
        return {'primary': sunsetPrimary, 'accent': sunsetAccent};
      case 'lavender':
        return {'primary': lavenderPrimary, 'accent': lavenderAccent};
      case 'default':
      default:
        return {'primary': defaultPrimary, 'accent': defaultAccent};
    }
  }
}
