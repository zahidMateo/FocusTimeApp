import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// AUDIO SERVICE - SERVICIO DE REPRODUCCIÓN DE SONIDOS AMBIENTALES
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Este servicio maneja la reproducción de sonidos ambientales durante el timer.
//
// CARACTERÍSTICAS:
// - Reproduce sonidos en loop (repetición continua)
// - Control de volumen
// - Pausa y reanuda la reproducción
// - Detiene el audio completamente
//
// USO:
//   await AudioService.play('Lluvia', volume: 0.7);  // Iniciar sonido
//   await AudioService.pause();  // Pausar
//   await AudioService.resume();  // Reanudar
//   await AudioService.stop();  // Detener completamente
//
// NOTA IMPORTANTE:
// Por ahora, este servicio está preparado para usar archivos de audio.
// Los archivos deben agregarse en la carpeta assets/sounds/ y declararse en pubspec.yaml
//
// ═══════════════════════════════════════════════════════════════════════════════════

class AudioService {
  // ═════════════════════════════════════════════════════════════════════════════════
  // INSTANCIA DEL REPRODUCTOR
  // ═════════════════════════════════════════════════════════════════════════════════
  // AudioPlayer es el objeto que maneja la reproducción de audio
  // static = compartido por toda la aplicación (solo hay UNO)
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // ═════════════════════════════════════════════════════════════════════════════════
  // ESTADO DEL REPRODUCTOR
  // ═════════════════════════════════════════════════════════════════════════════════
  static String? _currentSound; // ¿Qué sonido está reproduciéndose?
  static bool _isPlaying = false; // ¿Está reproduciéndose?
  static double _targetVolume = 0.7; // Volumen objetivo (antes del fade)

  // ═════════════════════════════════════════════════════════════════════════════════
  // MAPA DE SONIDOS - Relaciona nombre con archivo de audio
  // ═════════════════════════════════════════════════════════════════════════════════
  //
  // Archivos MP3 ubicados en assets/sounds/
  // Los archivos reales disponibles:
  // - sound-rain.mp3 → Lluvia
  // - sound-ocean.mp3 → Oleaje
  // - wind.mp3 → Viento suave
  //
  static final Map<String, String> _soundFiles = {
    'Ninguno': '', // Sin sonido
    'Lluvia': 'sound-rain.mp3', // GRATIS ✅ Archivo disponible
    'Oleaje': 'sound-ocean.mp3', // 🔒 PREMIUM ✅ Archivo disponible
    'Viento suave': 'wind.mp3', // 🔒 PREMIUM ✅ Archivo disponible
    // Sonidos adicionales (sin archivo por ahora)
    'Ruido blanco': '', // GRATIS (archivo no disponible)
    'Ruido marrón': '', // GRATIS (archivo no disponible)
    'Ruido rosa': '', // GRATIS (archivo no disponible)
    'Música instrumental': '', // 🔒 PREMIUM (archivo no disponible)
    'Ventilador': '', // GRATIS (archivo no disponible)
    'Río': '', // 🔒 PREMIUM (archivo no disponible)
    'Fuego crepitante': '', // 🔒 PREMIUM (archivo no disponible)
  };


  // ═════════════════════════════════════════════════════════════════════════════════
  // REPRODUCIR SONIDO AMBIENTAL CON FADE IN
  // ═════════════════════════════════════════════════════════════════════════════════
  // Inicia la reproducción de un sonido en loop con fade in (sube el volumen gradualmente)
  //
  // Parámetros:
  // - soundName: Nombre del sonido (debe estar en _soundFiles)
  // - volume: Volumen objetivo de 0.0 (silencio) a 1.0 (máximo)
  // - fadeDurationMs: Duración del fade in en milisegundos (por defecto 2000ms = 2 segundos)
  //
  // Retorna:
  // - true si se reprodujo correctamente
  // - false si hubo error
  static Future<bool> play(
    String soundName, {
    double volume = 0.7,
    int fadeDurationMs = 2000,
  }) async {
    try {
      // Si es "Ninguno", detener cualquier sonido que esté sonando
      if (soundName == 'Ninguno') {
        await stop();
        return true;
      }

      // Detener sonido anterior si hay uno
      await stop();

      // Obtener archivo de audio
      String? audioFile = _soundFiles[soundName];
      if (audioFile == null || audioFile.isEmpty) {
        debugPrint('❌ No se encontró archivo para: $soundName');
        return false;
      }

      _targetVolume = volume; // Guardar volumen objetivo

      // Iniciar con volumen 0 (silencio)
      await _audioPlayer.setVolume(0.0);

      // Configurar modo LOOP (repetir infinitamente)
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // ─────────────────────────────────────────────────────────────────────────────
      // REPRODUCIR DESDE ASSETS (archivos locales)
      // ─────────────────────────────────────────────────────────────────────────────
      debugPrint('🎵 Reproduciendo: $soundName con fade in');
      debugPrint('📁 Archivo: $audioFile');

      await _audioPlayer.play(AssetSource('sounds/$audioFile'));

      _currentSound = soundName;
      _isPlaying = true;

      // ─────────────────────────────────────────────────────────────────────────────
      // FADE IN: Subir volumen gradualmente
      // ─────────────────────────────────────────────────────────────────────────────
      await _fadeIn(volume, fadeDurationMs);

      debugPrint('✅ $soundName iniciado con volumen: $volume');
      return true;
    } catch (e) {
      debugPrint('❌ Error al reproducir sonido: $e');
      return false;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // REPRODUCIR PREVIEW (solo 5 segundos, sin loop)
  // ═════════════════════════════════════════════════════════════════════════════════
  static Future<bool> playPreview(
    String soundName, {
    double volume = 0.7,
    int durationSeconds = 5,
  }) async {
    try {
      // Si es "Ninguno", no hacer nada
      if (soundName == 'Ninguno') {
        return true;
      }

      // Detener sonido anterior si hay uno
      await stop();

      // Obtener archivo de audio
      String? audioFile = _soundFiles[soundName];
      if (audioFile == null || audioFile.isEmpty) {
        debugPrint('❌ No se encontró archivo para: $soundName');
        return false;
      }

      _targetVolume = volume;

      // Configurar volumen completo (sin fade en preview)
      await _audioPlayer.setVolume(volume);

      // NO configurar loop para preview
      await _audioPlayer.setReleaseMode(ReleaseMode.release);

      debugPrint('🎵 Preview: $soundName ($durationSeconds segundos)');

      await _audioPlayer.play(AssetSource('sounds/$audioFile'));

      _currentSound = soundName;
      _isPlaying = true;

      // Detener después de X segundos
      Future.delayed(Duration(seconds: durationSeconds), () {
        stop();
      });

      return true;
    } catch (e) {
      debugPrint('❌ Error al reproducir preview: $e');
      return false;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // FADE IN - Subir volumen gradualmente
  // ═════════════════════════════════════════════════════════════════════════════════
  static Future<void> _fadeIn(double targetVolume, int durationMs) async {
    const int steps = 20; // Número de pasos en el fade
    final int stepDuration = durationMs ~/ steps; // Duración de cada paso
    final double volumeStep = targetVolume / steps; // Cuánto subir en cada paso

    for (int i = 0; i <= steps; i++) {
      if (!_isPlaying) break; // Si se detuvo, cancelar fade
      await _audioPlayer.setVolume(volumeStep * i);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // PAUSAR REPRODUCCIÓN
  // ═════════════════════════════════════════════════════════════════════════════════
  // Pausa el sonido actual (se puede reanudar con resume())
  static Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      debugPrint('⏸️ Sonido pausado');
    } catch (e) {
      debugPrint('❌ Error al pausar: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // REANUDAR REPRODUCCIÓN
  // ═════════════════════════════════════════════════════════════════════════════════
  // Reanuda el sonido pausado
  static Future<void> resume() async {
    try {
      await _audioPlayer.resume();
      _isPlaying = true;
      debugPrint('▶️ Sonido reanudado');
    } catch (e) {
      debugPrint('❌ Error al reanudar: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // DETENER REPRODUCCIÓN CON FADE OUT
  // ═════════════════════════════════════════════════════════════════════════════════
  // Detiene completamente el sonido con fade out (baja el volumen gradualmente)
  static Future<void> stop({int fadeDurationMs = 1500}) async {
    try {
      if (_isPlaying) {
        // Hacer fade out antes de detener
        await _fadeOut(fadeDurationMs);
      }

      await _audioPlayer.stop();
      _isPlaying = false;
      _currentSound = null;
      debugPrint('⏹️ Sonido detenido con fade out');
    } catch (e) {
      debugPrint('❌ Error al detener: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // DETENER INMEDIATAMENTE (sin fade out)
  // ═════════════════════════════════════════════════════════════════════════════════
  static Future<void> stopImmediately() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentSound = null;
      debugPrint('⏹️ Sonido detenido inmediatamente');
    } catch (e) {
      debugPrint('❌ Error al detener: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // FADE OUT - Bajar volumen gradualmente
  // ═════════════════════════════════════════════════════════════════════════════════
  static Future<void> _fadeOut(int durationMs) async {
    const int steps = 15; // Número de pasos en el fade
    final int stepDuration = durationMs ~/ steps; // Duración de cada paso
    final double volumeStep = _targetVolume / steps; // Cuánto bajar en cada paso

    for (int i = steps; i >= 0; i--) {
      if (!_isPlaying) break; // Si ya se detuvo, cancelar fade
      await _audioPlayer.setVolume(volumeStep * i);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // CAMBIAR VOLUMEN
  // ═════════════════════════════════════════════════════════════════════════════════
  // Ajusta el volumen del sonido actual (0.0 a 1.0)
  static Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
      debugPrint('🔊 Volumen ajustado a: $volume');
    } catch (e) {
      debugPrint('❌ Error al ajustar volumen: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═════════════════════════════════════════════════════════════════════════════════
  static String? get currentSound => _currentSound;
  static bool get isPlaying => _isPlaying;

  // ═════════════════════════════════════════════════════════════════════════════════
  // DISPOSE - Limpiar recursos
  // ═════════════════════════════════════════════════════════════════════════════════
  // Llamar esto cuando se cierre la app
  static Future<void> dispose() async {
    await _audioPlayer.dispose();
    debugPrint('🗑️ AudioService disposed');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// NOTAS PARA EL FUTURO
// ═══════════════════════════════════════════════════════════════════════════════════
//
// 📁 AGREGAR ARCHIVOS DE AUDIO:
//
// 1. Descarga archivos MP3 de sonidos ambientales (gratis desde freesound.org)
// 2. Crea la carpeta: assets/sounds/
// 3. Guarda los archivos con los nombres especificados en _soundFiles
// 4. Modifica pubspec.yaml:
//
//    flutter:
//      assets:
//        - assets/sounds/
//
// 5. En el método play(), descomenta:
//    await _audioPlayer.play(AssetSource('sounds/$audioFile'));
//
// 💰 IMPLEMENTAR SISTEMA DE PAGOS:
//
// 1. Agrega el paquete: in_app_purchase: ^3.1.0
// 2. Configura productos en Google Play Console / App Store Connect
// 3. Implementa verificación de compra en setHasPremium()
// 4. Guarda estado premium con SharedPreferences
//
// ═══════════════════════════════════════════════════════════════════════════════════
