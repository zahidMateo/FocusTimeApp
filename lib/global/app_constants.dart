// ═══════════════════════════════════════════════════════════════════════════════════
// APP CONSTANTS - CONSTANTES Y VALORES FIJOS DE LA APLICACIÓN
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Este archivo define TODOS los valores constantes que se usan en múltiples lugares.
//
// ¿POR QUÉ USAR CONSTANTES?
// - Evita "números mágicos" en el código
// - Si quieres cambiar un valor, solo lo cambias aquí
// - Hace el código más legible y mantenible
// - Garantiza consistencia visual en toda la app
//
// EJEMPLO:
//   ❌ padding: EdgeInsets.all(16)  (¿de dónde sale 16? ¿qué significa?)
//   ✅ padding: EdgeInsets.all(AppConstants.paddingMedium)  (¡mucho más claro!)
//
// ═══════════════════════════════════════════════════════════════════════════════════

class AppConstants {
  // Constructor privado - previene instanciación
  // Solo usamos esta clase para acceder a constantes estáticas
  AppConstants._();

  // ─────────────────────────────────────────────────────────────────────────────────
  // TIEMPOS DEL POMODORO (en minutos)
  // ─────────────────────────────────────────────────────────────────────────────────
  // Estos son los valores por defecto según la técnica Pomodoro tradicional:
  // - 25 min de trabajo enfocado
  // - 5 min de descanso corto (después de cada pomodoro)
  // - 15 min de descanso largo (después de 4 pomodoros)

  static const int focusDuration = 25; // Duración de cada sesión de trabajo
  static const int shortBreakDuration = 5; // Descanso entre pomodoros
  static const int longBreakDuration = 15; // Descanso largo cada 4 pomodoros
  static const int pomodorosBeforeLongBreak = 4; // Ciclos antes del descanso largo

  // ─────────────────────────────────────────────────────────────────────────────────
  // TAMAÑOS (en píxeles lógicos de Flutter)
  // ─────────────────────────────────────────────────────────────────────────────────
  // Define los tamaños de elementos visuales para mantener consistencia

  static const double timerFontSize = 72.0; // Tamaño del texto del timer
  static const double buttonIconSize = 32.0; // Tamaño de iconos en botones
  static const double borderRadius = 16.0; // Radio de esquinas redondeadas

  // ─────────────────────────────────────────────────────────────────────────────────
  // ESPACIADOS (en píxeles lógicos de Flutter)
  // ─────────────────────────────────────────────────────────────────────────────────
  // Sistema de espaciado consistente basado en múltiplos de 8
  // Esto es una práctica común en diseño de interfaces

  static const double paddingSmall = 8.0; // Espaciado pequeño (8px)
  static const double paddingMedium = 16.0; // Espaciado medio (16px)
  static const double paddingLarge = 24.0; // Espaciado grande (24px)
  static const double paddingXLarge = 32.0; // Espaciado extra grande (32px)

  // ─────────────────────────────────────────────────────────────────────────────────
  // ANIMACIONES (en milisegundos)
  // ─────────────────────────────────────────────────────────────────────────────────
  // Define las duraciones de las animaciones para dar consistencia a las transiciones

  // Duración estándar de animaciones (300ms = 0.3 segundos)
  static const int animationDuration = 300;

  // Animación flotante para efectos decorativos (6000ms = 6 segundos)
  static const int floatAnimationDuration = 6000;

  // Animación de pulso para elementos que llaman la atención (2000ms = 2 segundos)
  static const int pulseAnimationDuration = 2000;

  // ─────────────────────────────────────────────────────────────────────────────────
  // NOTA: Cómo usar estas constantes
  // ─────────────────────────────────────────────────────────────────────────────────
  //
  // En cualquier archivo de tu app, importa este archivo y úsalo así:
  //
  //   import 'package:pomodoro_app/global/app_constants.dart';
  //
  //   // Para usar una constante:
  //   int workTime = AppConstants.focusDuration;
  //   padding: EdgeInsets.all(AppConstants.paddingMedium);
  //   duration: Duration(milliseconds: AppConstants.animationDuration);
  //
}
