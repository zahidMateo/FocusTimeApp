import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// FOCUS MODE SERVICE - Servicio para modo concentración
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Este servicio maneja el modo concentración usando código nativo de Android
// para ocultar la barra de navegación y hacer la app inmersiva.
//
// ═══════════════════════════════════════════════════════════════════════════════════

class FocusModeService {
  static const MethodChannel _channel = MethodChannel('pomodoro_app/focus_mode');

  // Activar modo inmersivo (oculta barra de navegación y estado)
  static Future<void> enableFocusMode() async {
    try {
      await _channel.invokeMethod('enableFocusMode');
    } catch (e) {
      print('Error al activar modo concentración: $e');
    }
  }

  // Desactivar modo inmersivo
  static Future<void> disableFocusMode() async {
    try {
      await _channel.invokeMethod('disableFocusMode');
    } catch (e) {
      print('Error al desactivar modo concentración: $e');
    }
  }
}
