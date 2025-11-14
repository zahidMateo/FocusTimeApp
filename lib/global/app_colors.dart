import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// APP COLORS - PALETA DE COLORES DE LA APLICACIÓN
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Este archivo define TODOS los colores que usamos en la app.
//
// ¿POR QUÉ USAR ESTA CLASE?
// - Centraliza todos los colores en un solo lugar
// - Si quieres cambiar un color, solo lo cambias aquí (no en 50 archivos diferentes)
// - Evita errores de tipeo con colores
// - Hace el código más legible: AppColors.sky en lugar de Color(0xFFB8DBE8)
//
// ¿QUÉ ES "AppColors._()"?
// - Es un constructor privado que previene que alguien haga "AppColors()"
// - Esta clase solo debe usarse para acceder a los colores estáticos
// - Ejemplo: AppColors.sky ✅   |   AppColors() ❌
//
// FORMATO DE COLORES:
// - Usamos Color(0xFFRRGGBB) donde:
//   - FF = opacidad (255 = 100% opaco)
//   - RR = rojo (00-FF)
//   - GG = verde (00-FF)
//   - BB = azul (00-FF)
// ═══════════════════════════════════════════════════════════════════════════════════

class AppColors {
  // Constructor privado - previene instanciación
  AppColors._();

  // ─────────────────────────────────────────────────────────────────────────────────
  // COLORES BASE (Siguiendo Material Design 3)
  // ─────────────────────────────────────────────────────────────────────────────────

  // background - Fondo principal de la aplicación
  static const Color background = Color(0xFFFAFAFD);

  // foreground - Color del texto principal (oscuro para contrastar con background)
  static const Color foreground = Color(0xFF52526B);

  // card - Color de fondo de las tarjetas (Cards)
  // cardForeground - Color del texto dentro de las tarjetas
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF52526B);

  // popover - Color de fondo para menús emergentes y dropdowns
  // popoverForeground - Color del texto en los menús emergentes
  static const Color popover = Color(0xFFFFFFFF);
  static const Color popoverForeground = Color(0xFF52526B);

  // primary - Color principal de la app (Lavanda)
  // primaryForeground - Color del texto sobre el color primary
  static const Color primary = Color(0xFFAEA8D6);
  static const Color primaryForeground = Color(0xFFFAFAFD);

  // secondary - Color secundario (Mint/Verde menta)
  // secondaryForeground - Color del texto sobre el color secondary
  static const Color secondary = Color(0xFFB8E3C8);
  static const Color secondaryForeground = Color(0xFF52526B);

  // muted - Color apagado/deshabilitado (gris claro)
  // mutedForeground - Color del texto secundario o deshabilitado
  static const Color muted = Color(0xFFF2F2F7);
  static const Color mutedForeground = Color(0xFF8B8B9E);

  // accent - Color de acento para highlights (Sky/Azul cielo)
  // accentForeground - Color del texto sobre el color accent
  static const Color accent = Color(0xFFB8DBE8);
  static const Color accentForeground = Color(0xFF52526B);

  // destructive - Color para acciones destructivas (eliminar, resetear)
  // destructiveForeground - Color del texto sobre el color destructive
  static const Color destructive = Color(0xFFE74C3C);
  static const Color destructiveForeground = Color(0xFFFCFCFC);

  // border - Color de los bordes de elementos
  static const Color border = Color(0xFFE8E8F0);

  // input - Color de fondo de campos de texto
  static const Color input = Color(0xFFE8E8F0);

  // ring - Color del anillo de enfoque cuando un elemento está seleccionado
  static const Color ring = Color(0xFFAEA8D6);

  // ─────────────────────────────────────────────────────────────────────────────────
  // COLORES PASTEL PERSONALIZADOS
  // ─────────────────────────────────────────────────────────────────────────────────
  // Estos son colores pastel suaves que usamos en la app para dar un look tranquilo

  // Sky - Azul cielo pastel (usado en el timer y elementos principales)
  static const Color sky = Color(0xFFB8DBE8);

  // Mint - Verde menta pastel (para descansos cortos)
  static const Color mint = Color(0xFFB8E3C8);

  // Lavender - Lavanda pastel (para modo enfoque/trabajo)
  static const Color lavender = Color(0xFFAEA8D6);

  // Peach - Durazno pastel (para decoración)
  static const Color peach = Color(0xFFEDD4C5);

  // Rose - Rosa pastel (para decoración)
  static const Color rose = Color(0xFFE8C8D8);

  // ─────────────────────────────────────────────────────────────────────────────────
  // COLORES PARA GRÁFICOS Y ESTADÍSTICAS
  // ─────────────────────────────────────────────────────────────────────────────────
  // Si en el futuro agregas gráficas, estos colores combinan bien entre sí

  static const Color chart1 = lavender;
  static const Color chart2 = mint;
  static const Color chart3 = sky;
  static const Color chart4 = rose;
  static const Color chart5 = peach;

  // ─────────────────────────────────────────────────────────────────────────────────
  // COLORES PARA SIDEBAR (Barra lateral)
  // ─────────────────────────────────────────────────────────────────────────────────
  // Por si en el futuro quieres agregar una barra lateral de navegación

  static const Color sidebar = Color(0xFFFCFCFC);
  static const Color sidebarForeground = Color(0xFF52526B);
  static const Color sidebarPrimary = lavender;
  static const Color sidebarPrimaryForeground = Color(0xFFFCFCFC);
  static const Color sidebarAccent = Color(0xFFF8F8F8);
  static const Color sidebarAccentForeground = Color(0xFF52526B);
  static const Color sidebarBorder = Color(0xFFE8E8F0);
  static const Color sidebarRing = lavender;

  // ─────────────────────────────────────────────────────────────────────────────────
  // COLORES SEMÁNTICOS PARA ESTADOS DEL POMODORO
  // ─────────────────────────────────────────────────────────────────────────────────
  // Asignamos colores específicos a cada estado del timer para darles personalidad

  static const Color focusMode = lavender; // Modo trabajo/enfoque - Lavanda
  static const Color shortBreak = mint; // Descanso corto - Verde menta
  static const Color longBreak = sky; // Descanso largo - Azul cielo

  // ─────────────────────────────────────────────────────────────────────────────────
  // NOTA SOBRE GRADIENTES
  // ─────────────────────────────────────────────────────────────────────────────────
  // Los gradientes no pueden ser constantes en Dart, pero si quieres usarlos:
  //
  // Gradiente pastel (3 colores):
  //   LinearGradient(colors: [AppColors.sky, AppColors.rose, AppColors.lavender])
  //
  // Gradiente tranquilo (2 colores):
  //   LinearGradient(colors: [AppColors.sky, AppColors.mint])
}