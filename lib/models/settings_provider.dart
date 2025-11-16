import 'package:flutter/material.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// SETTINGS PROVIDER - GESTOR DE ESTADO DE CONFIGURACIONES
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Esta clase guarda TODAS las configuraciones de la app y las comparte entre pantallas.
//
// ¿QUÉ ES UN PROVIDER?
// - Es un patrón de Flutter para compartir datos entre pantallas
// - Extiende ChangeNotifier que permite notificar cambios
// - Cuando una configuración cambia, TODAS las pantallas que escuchan se actualizan
//
// ¿CÓMO FUNCIONA?
// 1. main.dart crea una instancia con ChangeNotifierProvider
// 2. Todas las pantallas pueden leer/modificar estas configuraciones
// 3. Cuando llamas un setter (ejemplo: setFocusDuration), se ejecuta notifyListeners()
// 4. notifyListeners() le dice a Flutter "¡Hey! algo cambió, actualiza las pantallas!"
// 5. Todas las pantallas con Consumer<SettingsProvider> se reconstruyen automáticamente
//
// ¿POR QUÉ USAR PROVIDER EN VEZ DE PASAR PARÁMETROS?
// SIN Provider:
//   TimerScreen(focusDuration: 25, shortBreak: 5, longBreak: 15, ...)
//   SettingsScreen(focusDuration: 25, shortBreak: 5, longBreak: 15, ...)
//   ^ Tienes que pasar los mismos datos a CADA pantalla 😫
//
// CON Provider:
//   Consumer<SettingsProvider>((context, settings, child) {
//     return Text('${settings.focusDuration}');
//   })
//   ^ Cualquier pantalla puede acceder a los datos directamente 😊
//
// ═══════════════════════════════════════════════════════════════════════════════════

class SettingsProvider extends ChangeNotifier {
  // ═════════════════════════════════════════════════════════════════════════════════
  // CONSTRUCTOR - Cargar configuraciones al iniciar
  // ═════════════════════════════════════════════════════════════════════════════════
  SettingsProvider() {
    _loadSettings(); // Cargar configuraciones guardadas
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // VARIABLES PRIVADAS (con guion bajo _)
  // ═════════════════════════════════════════════════════════════════════════════════
  //
  // ¿POR QUÉ PRIVADAS?
  // - En Dart, el _ hace que la variable sea privada (solo accesible en este archivo)
  // - Esto previene que otras pantallas modifiquen directamente los valores
  // - Solo se pueden cambiar usando los setters que definimos abajo
  //
  // BUENA PRÁCTICA:
  //   ✅ settings.setFocusDuration(30)  ← Usa el setter que llama notifyListeners()
  //   ❌ settings._focusDuration = 30   ← NO compila (privado) y no notifica cambios

  // ─────────────────────────────────────────────────────────────────────────────────
  // TIEMPOS DEL POMODORO (en minutos)
  // ─────────────────────────────────────────────────────────────────────────────────
  // Usamos double para que funcione con Slider (que usa double)

  double _focusDuration = AppConstants.focusDuration.toDouble(); // 25 minutos
  double _shortBreakDuration =
      AppConstants.shortBreakDuration.toDouble(); // 5 minutos
  double _longBreakDuration =
      AppConstants.longBreakDuration.toDouble(); // 15 minutos
  int _pomodorosBeforeLongBreak = AppConstants.pomodorosBeforeLongBreak; // 4 ciclos

  // ─────────────────────────────────────────────────────────────────────────────────
  // CONFIGURACIONES DE NOTIFICACIONES
  // ─────────────────────────────────────────────────────────────────────────────────

  bool _notificationsEnabled = true; // ¿Mostrar notificaciones?
  bool _soundEnabled = true; // ¿Reproducir sonido?
  bool _vibrationEnabled = true; // ¿Vibrar el dispositivo?

  // ─────────────────────────────────────────────────────────────────────────────────
  // CONFIGURACIONES DE COMPORTAMIENTO
  // ─────────────────────────────────────────────────────────────────────────────────

  bool _autoStartBreaks = false; // ¿Iniciar descanso automáticamente?
  bool _autoStartPomodoros = false; // ¿Iniciar siguiente pomodoro automáticamente?
  bool _keepScreenOn = false; // ¿Mantener pantalla encendida?
  bool _appLockMode = false; // ¿Bloquear aplicación durante pomodoro?

  // ─────────────────────────────────────────────────────────────────────────────────
  // CONFIGURACIONES DE SONIDO
  // ─────────────────────────────────────────────────────────────────────────────────

  String _selectedSound = 'Ninguno'; // Sonido ambiental durante el timer
  double _soundVolume = 0.7; // Volumen (0.0 a 1.0)

  // ─────────────────────────────────────────────────────────────────────────────────
  // ESTADO DEL TIMER
  // ─────────────────────────────────────────────────────────────────────────────────
  // Esto nos permite saber si el timer está corriendo para validar cambios

  bool _isTimerRunning = false; // ¿El timer está activo?

  // ─────────────────────────────────────────────────────────────────────────────────
  // CALLBACK PARA RESETEAR TIMER
  // ─────────────────────────────────────────────────────────────────────────────────
  // VoidCallback? significa: "puede ser una función o null"
  // Lo usa timer_screen.dart para registrar su función _resetTimer()
  // Cuando cambiamos configuraciones, llamamos este callback para reiniciar el timer

  VoidCallback? onTimerReset;

  // ═════════════════════════════════════════════════════════════════════════════════
  // GETTERS (para LEER los valores desde otras pantallas)
  // ═════════════════════════════════════════════════════════════════════════════════
  //
  // ¿QUÉ ES UN GETTER?
  // - Es una función que se usa como si fuera una variable
  // - Permite leer valores privados desde otras pantallas
  //
  // EJEMPLO:
  //   double tiempo = settings.focusDuration;  ← Llama al getter
  //   print(tiempo);  // Imprime: 25.0

  // ─── Tiempos en minutos ───
  double get focusDuration => _focusDuration;
  double get shortBreakDuration => _shortBreakDuration;
  double get longBreakDuration => _longBreakDuration;
  int get pomodorosBeforeLongBreak => _pomodorosBeforeLongBreak;

  // ─── Tiempos en segundos (para el timer) ───
  // Convertimos minutos a segundos multiplicando por 60
  // .toInt() convierte double a int (60.0 → 60)
  int get focusDurationInSeconds => (_focusDuration * 60).toInt();
  int get shortBreakDurationInSeconds => (_shortBreakDuration * 60).toInt();
  int get longBreakDurationInSeconds => (_longBreakDuration * 60).toInt();

  // ─── Notificaciones ───
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  // ─── Comportamiento ───
  bool get autoStartBreaks => _autoStartBreaks;
  bool get autoStartPomodoros => _autoStartPomodoros;
  bool get keepScreenOn => _keepScreenOn;
  bool get appLockMode => _appLockMode;

  // ─── Sonido ───
  String get selectedSound => _selectedSound;
  double get soundVolume => _soundVolume;

  // ─── Estado del timer ───
  bool get isTimerRunning => _isTimerRunning;

  // ═════════════════════════════════════════════════════════════════════════════════
  // SETTERS (para CAMBIAR los valores y NOTIFICAR a los listeners)
  // ═════════════════════════════════════════════════════════════════════════════════
  //
  // ¿QUÉ ES UN SETTER?
  // - Es una función que cambia un valor Y notifica a las pantallas
  // - SIEMPRE debe llamar notifyListeners() al final
  //
  // ¿QUÉ HACE notifyListeners()?
  // - Le dice a Flutter: "¡Los datos cambiaron!"
  // - Flutter reconstruye todos los Consumer<SettingsProvider>
  // - Las pantallas se actualizan automáticamente con los nuevos valores
  //
  // EJEMPLO:
  //   settings.setFocusDuration(30);
  //   ↓
  //   _focusDuration = 30
  //   ↓
  //   notifyListeners() se ejecuta
  //   ↓
  //   Timer se actualiza, Settings se actualiza, ¡todo automático!

  // ─────────────────────────────────────────────────────────────────────────────────
  // SETTERS DE TIEMPOS
  // ─────────────────────────────────────────────────────────────────────────────────

  void setFocusDuration(double value) {
    _focusDuration = value; // Cambia el valor
    _saveSettings(); // Guarda automáticamente
    notifyListeners(); // Notifica a las pantallas
  }

  void setShortBreakDuration(double value) {
    _shortBreakDuration = value;
    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  void setLongBreakDuration(double value) {
    _longBreakDuration = value;
    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  void setPomodorosBeforeLongBreak(int value) {
    _pomodorosBeforeLongBreak = value;
    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────────────
  // SETTERS DE NOTIFICACIONES
  // ─────────────────────────────────────────────────────────────────────────────────

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;

    // LÓGICA ESPECIAL: Si desactivas notificaciones, también desactivar vibración
    // (la vibración solo funciona con notificaciones)
    // NOTA: El sonido es independiente (sonidos ambientales durante el timer)
    if (!value) {
      _vibrationEnabled = false;
    }

    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  void setVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────────────
  // SETTERS DE COMPORTAMIENTO
  // ─────────────────────────────────────────────────────────────────────────────────

  void setAutoStartBreaks(bool value) {
    _autoStartBreaks = value;
    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  void setAutoStartPomodoros(bool value) {
    _autoStartPomodoros = value;
    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  void setKeepScreenOn(bool value) {
    _keepScreenOn = value;
    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  void setAppLockMode(bool value) {
    _appLockMode = value;
    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────────────
  // SETTERS DE SONIDO
  // ─────────────────────────────────────────────────────────────────────────────────

  void setSelectedSound(String value) {
    _selectedSound = value;
    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  void setSoundVolume(double value) {
    _soundVolume = value;
    _saveSettings(); // Guarda automáticamente
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────────────
  // SETTER DE ESTADO DEL TIMER
  // ─────────────────────────────────────────────────────────────────────────────────
  // timer_screen.dart llama esto cuando el timer inicia/pausa

  void setTimerRunning(bool value) {
    _isTimerRunning = value;
    notifyListeners();
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // MÉTODOS ÚTILES
  // ═════════════════════════════════════════════════════════════════════════════════

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ RESET TO DEFAULTS - Restablecer configuraciones a valores por defecto        │
  // └───────────────────────────────────────────────────────────────────────────────┘
  // Usado en la opción "Restablecer estadísticas" de configuraciones
  // Vuelve todos los valores a lo que estaban cuando instalaste la app

  void resetToDefaults() {
    // Tiempos
    _focusDuration = AppConstants.focusDuration.toDouble();
    _shortBreakDuration = AppConstants.shortBreakDuration.toDouble();
    _longBreakDuration = AppConstants.longBreakDuration.toDouble();
    _pomodorosBeforeLongBreak = AppConstants.pomodorosBeforeLongBreak;

    // Notificaciones
    _notificationsEnabled = true;
    _soundEnabled = true;
    _vibrationEnabled = true;

    // Comportamiento
    _autoStartBreaks = false;
    _autoStartPomodoros = false;
    _keepScreenOn = false;
    _appLockMode = false;

    // Sonido
    _selectedSound = 'Ninguno';
    _soundVolume = 0.7;

    // Guardar los valores por defecto
    _saveSettings();

    // Notificar que TODO cambió
    notifyListeners();
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // PERSISTENCIA - Guardar y cargar configuraciones
  // ═════════════════════════════════════════════════════════════════════════════════

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ CARGAR CONFIGURACIONES desde SharedPreferences                                │
  // └───────────────────────────────────────────────────────────────────────────────┘
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar tiempos (si no existen, usar valores por defecto de AppConstants)
      _focusDuration = prefs.getDouble('focusDuration') ??
          AppConstants.focusDuration.toDouble();
      _shortBreakDuration = prefs.getDouble('shortBreakDuration') ??
          AppConstants.shortBreakDuration.toDouble();
      _longBreakDuration = prefs.getDouble('longBreakDuration') ??
          AppConstants.longBreakDuration.toDouble();
      _pomodorosBeforeLongBreak = prefs.getInt('pomodorosBeforeLongBreak') ??
          AppConstants.pomodorosBeforeLongBreak;

      // Cargar configuraciones de notificaciones
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;

      // Cargar configuraciones de comportamiento
      _autoStartBreaks = prefs.getBool('autoStartBreaks') ?? false;
      _autoStartPomodoros = prefs.getBool('autoStartPomodoros') ?? false;
      _keepScreenOn = prefs.getBool('keepScreenOn') ?? false;
      _appLockMode = prefs.getBool('appLockMode') ?? false;

      // Cargar configuraciones de sonido
      _selectedSound = prefs.getString('selectedSound') ?? 'Ninguno';
      _soundVolume = prefs.getDouble('soundVolume') ?? 0.7;

      // Notificar que las configuraciones se cargaron
      notifyListeners();
      debugPrint('✅ Configuraciones cargadas desde SharedPreferences');
    } catch (e) {
      debugPrint('❌ Error al cargar configuraciones: $e');
      // Si hay error, usar valores por defecto
    }
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ GUARDAR CONFIGURACIONES en SharedPreferences                                  │
  // └───────────────────────────────────────────────────────────────────────────────┘
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Guardar tiempos
      await prefs.setDouble('focusDuration', _focusDuration);
      await prefs.setDouble('shortBreakDuration', _shortBreakDuration);
      await prefs.setDouble('longBreakDuration', _longBreakDuration);
      await prefs.setInt('pomodorosBeforeLongBreak', _pomodorosBeforeLongBreak);

      // Guardar notificaciones
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);
      await prefs.setBool('soundEnabled', _soundEnabled);
      await prefs.setBool('vibrationEnabled', _vibrationEnabled);

      // Guardar comportamiento
      await prefs.setBool('autoStartBreaks', _autoStartBreaks);
      await prefs.setBool('autoStartPomodoros', _autoStartPomodoros);
      await prefs.setBool('keepScreenOn', _keepScreenOn);
      await prefs.setBool('appLockMode', _appLockMode);

      // Guardar sonido
      await prefs.setString('selectedSound', _selectedSound);
      await prefs.setDouble('soundVolume', _soundVolume);

      debugPrint('💾 Configuraciones guardadas');
    } catch (e) {
      debugPrint('❌ Error al guardar configuraciones: $e');
    }
  }
}
