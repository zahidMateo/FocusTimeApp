import 'dart:typed_data'; // Para Int64List (patrón de vibración)
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart'; // Para vibración directa

// ═══════════════════════════════════════════════════════════════════════════════════
// NOTIFICATION SERVICE - SERVICIO DE NOTIFICACIONES LOCALES
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Este servicio maneja TODAS las notificaciones de la app.
//
// CARACTERÍSTICAS:
// - Muestra notificaciones cuando el timer termina
// - Soporta sonido y vibración
// - Pide permisos en Android 13+
// - Funciona en Android, iOS, Windows, Linux, macOS
//
// USO:
//   await NotificationService.initialize();  // Al iniciar la app
//   await NotificationService.showPomodoroComplete();  // Cuando termina el timer
//
// ═══════════════════════════════════════════════════════════════════════════════════

class NotificationService {
  // Instancia del plugin de notificaciones
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Flag para saber si ya se inicializó
  static bool _initialized = false;

  // ═════════════════════════════════════════════════════════════════════════════════
  // INICIALIZAR - Configurar notificaciones al inicio de la app
  // ═════════════════════════════════════════════════════════════════════════════════
  // Llamar esto en main.dart ANTES de runApp()
  static Future<void> initialize() async {
    if (_initialized) return;

    // ─── Configuración para Android ───
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ─── Configuración para iOS ───
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // ─── Configuración para Linux ───
    const LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Abrir');

    // ─── Configuración combinada ───
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    // Inicializar el plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('✅ NotificationService inicializado');
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // PEDIR PERMISOS - Necesario en Android 13+ e iOS
  // ═════════════════════════════════════════════════════════════════════════════════
  static Future<bool> requestPermissions() async {
    // Android 13+
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }

    // iOS
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? true;
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // VIBRAR DISPOSITIVO (método directo más confiable)
  // ═════════════════════════════════════════════════════════════════════════════════
  static Future<void> vibrate({int duration = 500}) async {
    try {
      // Verificar si el dispositivo soporta vibración
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: duration);
        debugPrint('📳 Vibración ejecutada: ${duration}ms');
      } else {
        debugPrint('⚠️ Este dispositivo no tiene vibrador');
      }
    } catch (e) {
      debugPrint('❌ Error al vibrar: $e');
    }
  }

  // Vibración con patrón personalizado
  static Future<void> vibratePattern(List<int> pattern) async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Patrón: [espera, vibrar, espera, vibrar, ...]
        await Vibration.vibrate(pattern: pattern);
        debugPrint('📳 Vibración con patrón ejecutada');
      }
    } catch (e) {
      debugPrint('❌ Error al vibrar con patrón: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // MOSTRAR NOTIFICACIÓN DE POMODORO COMPLETADO
  // ═════════════════════════════════════════════════════════════════════════════════
  static Future<void> showPomodoroComplete({
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    // Asegurar que está inicializado
    if (!_initialized) {
      await initialize();
    }

    // VIBRAR DIRECTAMENTE (más confiable que la vibración de la notificación)
    if (enableVibration) {
      // Patrón: espera 0ms, vibra 500ms, espera 250ms, vibra 500ms
      await vibratePattern([0, 500, 250, 500]);
    }

    // Detalles de la notificación en Android
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pomodoro_channel', // ID del canal
      'Pomodoro Timer', // Nombre del canal
      channelDescription: 'Notificaciones del temporizador Pomodoro',
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      enableVibration: false, // Deshabilitamos aquí porque ya vibramos arriba
      icon: '@mipmap/ic_launcher',
      // Color de la notificación
      color: const Color(0xFFAEA8D6), // Lavanda
    );

    // Detalles de la notificación en iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Detalles combinados
    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Mostrar la notificación
    await _notifications.show(
      0, // ID de la notificación
      '🎉 ¡Pomodoro completado!', // Título
      'Buen trabajo. Es hora de tomar un descanso.', // Mensaje
      details,
    );

    debugPrint('📬 Notificación mostrada: Pomodoro completado');
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // MOSTRAR NOTIFICACIÓN DE DESCANSO COMPLETADO
  // ═════════════════════════════════════════════════════════════════════════════════
  static Future<void> showBreakComplete({
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // VIBRAR DIRECTAMENTE (3 vibraciones cortas)
    if (enableVibration) {
      await vibratePattern([0, 300, 150, 300, 150, 300]);
    }

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Timer',
      channelDescription: 'Notificaciones del temporizador Pomodoro',
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      enableVibration: false, // Ya vibramos arriba
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFB8E3C8), // Mint
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '☕ Descanso terminado',
      '¡Es hora de volver al trabajo!',
      details,
    );

    debugPrint('📬 Notificación mostrada: Descanso completado');
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // CANCELAR TODAS LAS NOTIFICACIONES
  // ═════════════════════════════════════════════════════════════════════════════════
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('🗑️ Todas las notificaciones canceladas');
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // CALLBACK - Cuando el usuario toca la notificación
  // ═════════════════════════════════════════════════════════════════════════════════
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('👆 Notificación tocada: ${response.payload}');
    // Aquí puedes navegar a una pantalla específica si quieres
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // VERIFICAR SI LAS NOTIFICACIONES ESTÁN HABILITADAS
  // ═════════════════════════════════════════════════════════════════════════════════
  static Future<bool> areNotificationsEnabled() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    return false;
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // NOTIFICACIÓN PERSISTENTE DEL TIMER (cuando la app está en segundo plano)
  // ═════════════════════════════════════════════════════════════════════════════════

  /// Mostrar/actualizar notificación persistente con el tiempo restante
  static Future<void> showTimerNotification({
    required int remainingSeconds,
    required bool isRunning,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Formatear tiempo como MM:SS
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Título según el estado
    final title = isRunning ? '⏱️ Pomodoro en curso' : '⏸️ Pomodoro pausado';

    // Detalles de la notificación en Android
    final androidDetails = AndroidNotificationDetails(
      'timer_channel', // Canal diferente para el timer persistente
      'Timer', // Nombre del canal
      channelDescription: 'Muestra el tiempo restante del Pomodoro',
      importance: Importance.low, // Baja para que no haga ruido
      priority: Priority.low,
      ongoing: true, // Hace que la notificación sea persistente
      autoCancel: false, // No se cancela al tocarla
      playSound: false, // Sin sonido
      enableVibration: false, // Sin vibración
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFAEA8D6),
      // Mostrar progreso con barra
      showProgress: true,
      maxProgress: 100,
      progress: remainingSeconds, // Esto se debe calcular como porcentaje
      // Botones de acción (opcional)
      // actions: [
      //   AndroidNotificationAction(
      //     'pause',
      //     'Pausar',
      //     icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      //   ),
      // ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Usar ID fijo (999) para que siempre actualice la misma notificación
    await _notifications.show(
      999, // ID único para notificación del timer
      title,
      timeString,
      details,
    );
  }

  /// Cancelar la notificación persistente del timer
  static Future<void> cancelTimerNotification() async {
    await _notifications.cancel(999);
    debugPrint('🗑️ Notificación del timer cancelada');
  }
}
