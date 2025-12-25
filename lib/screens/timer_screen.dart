import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/models/settings_provider.dart';
import 'package:pomodoro_app/models/rewards_provider.dart';
import 'package:pomodoro_app/services/notification_service.dart';
import 'package:pomodoro_app/services/audio_service.dart';
import 'package:pomodoro_app/services/focus_mode_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// TIMER SCREEN - PANTALLA DEL TEMPORIZADOR POMODORO CON CICLOS
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Esta es la pantalla principal de la app. Muestra un timer circular que alterna entre
// trabajo (pomodoro) y descansos (cortos y largos).
//
// CARACTERÍSTICAS:
// - Timer circular con progreso visual (aumenta en pomodoro, disminuye en descanso)
// - Botones para play/pause y reset
// - Contador de ciclos completados
// - Manejo de ciclos: pomodoro → descanso corto → ... → descanso largo
// - Mensajes de transición entre fases
// - Mensaje de felicitaciones al completar todos los ciclos
//
// ═══════════════════════════════════════════════════════════════════════════════════

enum TimerMode {
  pomodoro,
  shortBreak,
  longBreak,
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // ═════════════════════════════════════════════════════════════════════════════════
  // VARIABLES DE ESTADO
  // ═════════════════════════════════════════════════════════════════════════════════

  int _remainingSeconds = 0;
  int _initialSeconds = 0;
  bool _isRunning = false;
  int _completedCycles = 0;
  Timer? _timer;
  bool _audioStarted = false;
  TimerMode _currentMode = TimerMode.pomodoro;

  // ─── GETTER: Progreso del círculo ───
  // En pomodoro: barra AUMENTA (crece de 0 a 1)
  // En descanso: barra DISMINUYE (decrece de 1 a 0)
  double get _progress {
    if (_initialSeconds == 0) return 0.0;
    final baseProgress = _remainingSeconds / _initialSeconds;

    if (_currentMode == TimerMode.pomodoro) {
      // En pomodoro: invertir para que la barra crezca
      return 1.0 - baseProgress;
    } else {
      // En descanso: normal (la barra decrece)
      return baseProgress;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // LIFECYCLE METHODS - Métodos del ciclo de vida del widget
  // ═════════════════════════════════════════════════════════════════════════════════

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ initState() - Se ejecuta UNA VEZ cuando se crea el widget                    │
  // └───────────────────────────────────────────────────────────────────────────────┘
  // Aquí inicializamos el timer con el valor del provider
  @override
  void initState() {
    super.initState();
    // addPostFrameCallback = ejecuta DESPUÉS del primer build()
    // Necesario porque no podemos usar context directamente en initState()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTimer(); // Configura tiempo inicial
      _registerTimerResetCallback(); // Registra callback para Settings
    });
  }

  // Inicializa el timer con el tiempo configurado
  void _initializeTimer() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      _remainingSeconds = settings.focusDurationInSeconds;
      _initialSeconds = settings.focusDurationInSeconds; // Guardar valor inicial
    });
  }

  // Registra función de reset en el provider para que Settings la pueda llamar
  void _registerTimerResetCallback() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.onTimerReset = () {
      _resetTimer(); // Settings puede llamar esto cuando cambian configuraciones
    };
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ dispose() - Se ejecuta cuando el widget se ELIMINA permanentemente           │
  // └───────────────────────────────────────────────────────────────────────────────┘
  // MUY IMPORTANTE: Cancelar timers y limpiar callbacks para evitar memory leaks
  @override
  void dispose() {
    _timer?.cancel(); // Cancela el timer activo si existe
    FocusModeService.disableFocusMode(); // Desactivar modo concentración
    AudioService.stopImmediately(); // Detener sonido sin fade out al cerrar
    NotificationService.cancelTimerNotification(); // Cancelar notificación persistente
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.onTimerReset = null; // Limpia el callback
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // MÉTODOS AUXILIARES - Funciones helper para lógica del timer
  // ═════════════════════════════════════════════════════════════════════════════════

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Formatear tiempo como MM:SS                                                  │
  // └───────────────────────────────────────────────────────────────────────────────┘
  // Ejemplo: 125 segundos → "02:05"
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60; // División entera: 125 ~/ 60 = 2
    int secs = seconds % 60; // Módulo (resto): 125 % 60 = 5
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    // padLeft(2, '0') rellena con ceros: '2' → '02'
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Play/Pause - Alternar entre correr y pausar                                  │
  // └───────────────────────────────────────────────────────────────────────────────┘
  // Este método se ejecuta cuando tocas el botón de play/pause
  void _toggleTimer() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    setState(() {
      _isRunning = !_isRunning; // Invierte el estado: true → false, false → true
    });

    // Notificar al provider (para que Settings lo sepa)
    settings.setTimerRunning(_isRunning);

    if (_isRunning) {
      _startTimer(); // Iniciar el contador
    } else {
      _pauseTimer(); // Pausar el contador
    }
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Iniciar timer - Crea un Timer que se ejecuta cada segundo                    │
  // └───────────────────────────────────────────────────────────────────────────────┘
  // Timer.periodic ejecuta una función repetidamente cada X tiempo
  void _startTimer() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // ═══════════════════════════════════════════════════════════════════════════
    // ACTIVAR MODO CONCENTRACIÓN SI ESTÁ HABILITADO
    // ═══════════════════════════════════════════════════════════════════════════
    if (settings.appLockMode && _currentMode == TimerMode.pomodoro) {
      FocusModeService.enableFocusMode();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REPRODUCIR O REANUDAR SONIDO AMBIENTAL
    // ═══════════════════════════════════════════════════════════════════════════
    // Si el usuario tiene un sonido ambiental seleccionado (y sonido está habilitado)
    if (settings.soundEnabled && settings.selectedSound != 'Ninguno') {
      if (_audioStarted) {
        // Si el audio ya fue iniciado, solo reanudarlo
        AudioService.resume();
      } else {
        // Si es la primera vez, iniciar el audio con fade in
        AudioService.play(
          settings.selectedSound,
          volume: settings.soundVolume,
          fadeDurationMs: 2000, // 2 segundos de fade in
        ).then((success) {
          if (success) {
            _audioStarted = true; // Marcar que el audio fue iniciado
          } else {
            // Mostrar error si no se pudo reproducir
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No se pudo reproducir "${settings.selectedSound}"'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--; // Resta 1 segundo

          // Actualizar notificación persistente cada segundo
          NotificationService.showTimerNotification(
            remainingSeconds: _remainingSeconds,
            isRunning: true,
          );
        } else {
          _onTimerComplete(); // Llegó a 0, completó el ciclo
        }
      });
    });
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Pausar timer - Cancela el Timer.periodic                                     │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _pauseTimer() {
    _timer?.cancel(); // ? = si _timer no es null, cancela

    // Desactivar modo concentración
    FocusModeService.disableFocusMode();

    // Pausar sonido ambiental
    AudioService.pause();

    // Actualizar notificación a estado pausado
    NotificationService.showTimerNotification(
      remainingSeconds: _remainingSeconds,
      isRunning: false,
    );
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Resetear timer - Vuelve al estado inicial                                    │
  // └───────────────────────────────────────────────────────────────────────────────┘
  // Settings llama esto cuando cambian configuraciones mientras timer está corriendo
  void _resetTimer() {
    _timer?.cancel();
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Detener sonido inmediatamente (sin fade out porque es acción del usuario)
    AudioService.stopImmediately();

    // Cancelar notificación persistente
    NotificationService.cancelTimerNotification();

    setState(() {
      _remainingSeconds = settings.focusDurationInSeconds; // Tiempo completo
      _initialSeconds = settings.focusDurationInSeconds; // Actualizar valor inicial
      _isRunning = false; // Parado
      _audioStarted = false; // Resetear flag de audio para próximo inicio
    });

    // Notificar al provider que el timer se detuvo
    settings.setTimerRunning(false);
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Timer completado - Ejecuta cuando el timer llega a 0                         │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _onTimerComplete() async {
    _timer?.cancel();
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Desactivar modo concentración
    await FocusModeService.disableFocusMode();

    await AudioService.stop();
    await NotificationService.cancelTimerNotification();

    setState(() {
      _isRunning = false;
      _audioStarted = false;
    });

    settings.setTimerRunning(false);

    // Mostrar notificación
    if (settings.notificationsEnabled) {
      try {
        await NotificationService.showPomodoroComplete(
          playSound: settings.soundEnabled,
          enableVibration: settings.vibrationEnabled,
        );
      } catch (e) {
        debugPrint('❌ Error al mostrar notificación: $e');
      }
    }

    // Determinar siguiente fase
    if (_currentMode == TimerMode.pomodoro) {
      // Completamos un pomodoro
      setState(() {
        _completedCycles++;
      });

      // Registrar sesión completada en el sistema de recompensas
      final rewards = Provider.of<RewardsProvider>(context, listen: false);
      final completedMinutes = settings.focusDuration.toInt();
      final newAchievements = await rewards.onSessionCompleted(completedMinutes);

      // Si se desbloquearon logros, mostrarlos
      if (newAchievements.isNotEmpty && mounted) {
        _showAchievementsUnlockedDialog(newAchievements);
      }

      // Siempre mostrar diálogo de descanso después de un pomodoro
      _showBreakDialog();
    } else {
      // Completamos un descanso
      // Verificar si completamos todos los ciclos (después del descanso largo)
      if (_completedCycles >= settings.pomodorosBeforeLongBreak &&
          _currentMode == TimerMode.longBreak) {
        // Mostrar felicitaciones DESPUÉS del descanso largo
        _showCongratulationsDialog();
      } else {
        // Volver a pomodoro normalmente
        _switchToPomodoro();
      }
    }
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Mostrar diálogo de descanso                                                  │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _showBreakDialog() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isLongBreak = _completedCycles >= settings.pomodorosBeforeLongBreak;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isLongBreak ? '¡Excelente trabajo! 🎉' : '¡Buen trabajo! ☕',
            style: AppTypography.heading2,
            textAlign: TextAlign.center,
          ),
          content: Text(
            isLongBreak
                ? 'Has completado $_completedCycles pomodoros. Es hora de tomar un descanso largo para recargar energías.\n\n¿Quieres comenzar tu descanso ahora?'
                : 'Has completado un pomodoro con éxito. Es momento de tomar un breve descanso.\n\n¿Quieres comenzar tu descanso ahora?',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _switchToPomodoro();
              },
              child: Text('Más tarde'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isLongBreak) {
                  _switchToLongBreak();
                } else {
                  _switchToShortBreak();
                }
                _toggleTimer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.accent,
              ),
              child: Text('Comenzar ahora'),
            ),
          ],
        );
      },
    );
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Mostrar diálogo de felicitaciones                                            │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _showCongratulationsDialog() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    final quotes = [
      {
        'text': 'El éxito no es la clave de la felicidad. La felicidad es la clave del éxito.',
        'author': '— Albert Schweitzer'
      },
      {
        'text': 'La única forma de hacer un gran trabajo es amar lo que haces.',
        'author': '— Steve Jobs'
      },
      {
        'text': 'El futuro pertenece a quienes creen en la belleza de sus sueños.',
        'author': '— Eleanor Roosevelt'
      },
      {
        'text': 'No cuentes los días, haz que los días cuenten.',
        'author': '— Muhammad Ali'
      },
      {
        'text': 'La disciplina es el puente entre las metas y el logro.',
        'author': '— Jim Rohn'
      },
    ];

    final randomQuote = (quotes..shuffle()).first;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '🎊 ¡Felicitaciones! 🎊',
            style: AppTypography.heading2,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡Has completado ${settings.pomodorosBeforeLongBreak} pomodoros con éxito!',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppConstants.paddingMedium),
              Text(
                '"${randomQuote['text']}"',
                style: AppTypography.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppConstants.paddingSmall),
              Text(
                randomQuote['author']!,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetAllCycles();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.accent,
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge * 2,
                  vertical: AppConstants.paddingMedium,
                ),
              ),
              child: Text('Comenzar nueva sesión'),
            ),
          ],
        );
      },
    );
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Mostrar logros desbloqueados                                                 │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _showAchievementsUnlockedDialog(List<Achievement> achievements) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: context.colors.accent, size: 32),
              SizedBox(width: 8),
              Text(
                '¡Logro${achievements.length > 1 ? 's' : ''} Desbloqueado${achievements.length > 1 ? 's' : ''}!',
                style: AppTypography.heading2,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: achievements.map((achievement) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.accent.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      achievement.title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: context.colors.accent, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '+${achievement.points} puntos',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.colors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Cambiar a diferentes modos                                                   │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _switchToPomodoro() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      _currentMode = TimerMode.pomodoro;
      _remainingSeconds = settings.focusDurationInSeconds;
      _initialSeconds = settings.focusDurationInSeconds;
    });
  }

  void _switchToShortBreak() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      _currentMode = TimerMode.shortBreak;
      _remainingSeconds = settings.shortBreakDurationInSeconds;
      _initialSeconds = settings.shortBreakDurationInSeconds;
    });
  }

  void _switchToLongBreak() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      _currentMode = TimerMode.longBreak;
      _remainingSeconds = settings.longBreakDurationInSeconds;
      _initialSeconds = settings.longBreakDurationInSeconds;
    });
  }

  void _resetAllCycles() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      _completedCycles = 0;
      _currentMode = TimerMode.pomodoro;
      _remainingSeconds = settings.focusDurationInSeconds;
      _initialSeconds = settings.focusDurationInSeconds;
      _isRunning = false;
      _audioStarted = false;
    });
    settings.setTimerRunning(false);
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        // Actualizar tiempo si está detenido y la configuración ha cambiado
        if (!_isRunning) {
          int expectedSeconds;
          switch (_currentMode) {
            case TimerMode.pomodoro:
              expectedSeconds = settings.focusDurationInSeconds;
              break;
            case TimerMode.shortBreak:
              expectedSeconds = settings.shortBreakDurationInSeconds;
              break;
            case TimerMode.longBreak:
              expectedSeconds = settings.longBreakDurationInSeconds;
              break;
          }

          // Si el tiempo mostrado no coincide con la configuración actual, actualizar
          if (_initialSeconds != expectedSeconds) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _remainingSeconds = expectedSeconds;
                _initialSeconds = expectedSeconds;
              });
            });
          }
        }

        // Determinar si se debe bloquear la salida
        final shouldBlock = settings.appLockMode &&
                           _isRunning &&
                           _currentMode == TimerMode.pomodoro;

        return PopScope(
          canPop: !shouldBlock,
          onPopInvokedWithResult: (didPop, result) {
            if (shouldBlock && !didPop) {
              // Mostrar mensaje indicando que no se puede salir
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🔒 El modo concentración está activo. Debes pausar el timer para poder salir.',
                  ),
                  duration: Duration(seconds: 3),
                  backgroundColor: context.colors.destructive,
                ),
              );
            }
          },
          child: Scaffold(
            backgroundColor: context.colors.cardBackground,
            body: SafeArea(
              child: Column(
                children: [
                  // Indicador de modo concentración
                  if (shouldBlock)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: AppConstants.paddingSmall,
                      ),
                      color: context.colors.accent.withOpacity(0.2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, size: 16, color: context.colors.accent),
                          SizedBox(width: AppConstants.paddingSmall),
                          Text(
                            'Modo Concentración Activo',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Spacer(flex: 2),
                  _buildCircularTimer(),
                  SizedBox(height: AppConstants.paddingXLarge * 2),
                  _buildControlButtons(),
                  SizedBox(height: AppConstants.paddingXLarge * 2),
                  _buildCycleCounter(),
                  Spacer(flex: 3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CÍRCULO DE PROGRESO CON TIMER (RESPONSIVE)
  // ═══════════════════════════════════════════════════════════

  Widget _buildCircularTimer() {
    // Obtener ancho de pantalla para hacer responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calcular tamaño del círculo basado en la pantalla
    // Usar el 60% del ancho o 400px, lo que sea menor
    double circleSize = (screenWidth * 0.6).clamp(240.0, 400.0);

    // Si es una pantalla muy alta (tablet en vertical), ajustar según altura también
    if (screenHeight > 800) {
      circleSize = (screenHeight * 0.35).clamp(280.0, 450.0);
    }

    // Calcular tamaño de fuente proporcionalmente
    double fontSize = circleSize * 0.2; // 20% del círculo

    return SizedBox(
      width: circleSize,
      height: circleSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: circleSize * 0.03, // 3% del círculo
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.borderColor.withOpacity(0.3)),
            ),
          ),
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: circleSize * 0.03, // 3% del círculo
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.accent),
              strokeCap: StrokeCap.round,
            ),
          ),
          Container(
            width: circleSize - 20,
            height: circleSize - 20,
            decoration: BoxDecoration(
              color: context.colors.cardBackground,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.colors.accent.withOpacity(0.15),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(_remainingSeconds),
                  style: AppTypography.timerDisplay.copyWith(
                    color: context.colors.accent,
                    fontSize: fontSize,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: AppConstants.paddingSmall),
                Text(
                  _getStatusText(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                    fontSize: fontSize * 0.25, // 25% del tiempo
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (!_isRunning && _remainingSeconds == _initialSeconds) {
      return 'Listo para comenzar';
    } else if (_isRunning) {
      if (_currentMode == TimerMode.pomodoro) {
        return '¡Enfócate!';
      } else if (_currentMode == TimerMode.shortBreak) {
        return 'Descanso corto';
      } else {
        return 'Descanso largo';
      }
    } else {
      return 'Pausado';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BOTONES DE CONTROL (RESPONSIVE)
  // ═══════════════════════════════════════════════════════════

  Widget _buildControlButtons() {
    // Hacer los botones responsive también
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = (screenWidth * 0.15).clamp(60.0, 90.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircleButton(
          context: context,
          icon: _isRunning ? Icons.pause : Icons.play_arrow,
          backgroundColor: context.colors.cardBackground,
          iconColor: context.colors.accent,
          size: buttonSize,
          onPressed: _toggleTimer,
          hasBorder: true,
        ),
        SizedBox(width: AppConstants.paddingLarge),
        _buildCircleButton(
          context: context,
          icon: Icons.refresh,
          backgroundColor: context.colors.cardBackground,
          iconColor: context.colors.accent,
          size: buttonSize,
          onPressed: _resetTimer,
          hasBorder: true,
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required BuildContext context,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required double size,
    required VoidCallback onPressed,
    bool hasBorder = false,
  }) {
    return Material(
      color: backgroundColor,
      shape: CircleBorder(
        side: hasBorder
            ? BorderSide(color: context.colors.borderColor, width: 2)
            : BorderSide.none,
      ),
      elevation: hasBorder ? 4 : 8,
      shadowColor: context.colors.accent.withOpacity(0.2),
      child: InkWell(
        onTap: onPressed,
        customBorder: CircleBorder(),
        child: Container(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CONTADOR DE CICLOS
  // ═══════════════════════════════════════════════════════════

  Widget _buildCycleCounter() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: context.colors.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ciclos completados: ',
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          Text(
            '$_completedCycles de ${settings.pomodorosBeforeLongBreak}',
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
