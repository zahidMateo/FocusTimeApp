import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
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

enum TimerMode { pomodoro, shortBreak, longBreak }

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
      _initialSeconds =
          settings.focusDurationInSeconds; // Guardar valor inicial
    });
  }

  // Registra función de reset en el provider para que Settings la pueda llamar
  void _registerTimerResetCallback() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.onTimerReset = () {
      _resetTimer(); // Settings puede llamar esto cuando cambian configuraciones
    };
  }

  SettingsProvider? _settingsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
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
    _settingsProvider?.onTimerReset =
        null; // Limpia el callback de forma segura
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
      _isRunning =
          !_isRunning; // Invierte el estado: true → false, false → true
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
                content: Text(
                  'No se pudo reproducir "${settings.selectedSound}"',
                ),
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

    int resetSeconds;
    switch (_currentMode) {
      case TimerMode.pomodoro:
        resetSeconds = settings.focusDurationInSeconds;
        break;
      case TimerMode.shortBreak:
        resetSeconds = settings.shortBreakDurationInSeconds;
        break;
      case TimerMode.longBreak:
        resetSeconds = settings.longBreakDurationInSeconds;
        break;
    }

    setState(() {
      _remainingSeconds = resetSeconds;
      _initialSeconds = resetSeconds;
      _isRunning = false;
      _audioStarted = false;
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
      final newAchievements = await rewards.onSessionCompleted(
        completedMinutes,
      );

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
        'text':
            'El éxito no es la clave de la felicidad. La felicidad es la clave del éxito.',
        'author': '— Albert Schweitzer',
      },
      {
        'text': 'La única forma de hacer un gran trabajo es amar lo que haces.',
        'author': '— Steve Jobs',
      },
      {
        'text':
            'El futuro pertenece a quienes creen en la belleza de sus sueños.',
        'author': '— Eleanor Roosevelt',
      },
      {
        'text': 'No cuentes los días, haz que los días cuenten.',
        'author': '— Muhammad Ali',
      },
      {
        'text': 'La disciplina es el puente entre las metas y el logro.',
        'author': '— Jim Rohn',
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
                  color: context.colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.accent.withValues(alpha: 0.3),
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
                        Icon(
                          Icons.star,
                          color: context.colors.accent,
                          size: 20,
                        ),
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
        final shouldBlock =
            settings.appLockMode &&
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
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMedium,
                            vertical: AppConstants.paddingSmall,
                          ),
                          child: Column(
                            children: [
                              // Indicador de modo concentración
                              if (shouldBlock)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(
                                    bottom: AppConstants.paddingSmall,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppConstants.paddingSmall,
                                    horizontal: AppConstants.paddingMedium,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(9999),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.lock,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(
                                        width: AppConstants.paddingSmall,
                                      ),
                                      Text(
                                        'Modo Concentración Activo',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 8),

                              // Selector de modo tipo Pills (Stitch Focus Flow)
                              _buildModeSelector(),

                              const Spacer(flex: 2),

                              // Reloj circular con anillo de 8px
                              _buildCircularTimer(),

                              const Spacer(flex: 2),

                              // Botones de control (Reset 48px, Play/Pause 64px Cobalt, Skip 48px)
                              _buildControlButtons(),

                              const SizedBox(height: 24),

                              // Contador de ciclos Stitch
                              _buildCycleCounter(),

                              const Spacer(flex: 1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SELECTOR DE MODO EN PÍLDORAS (STITCH FOCUS FLOW)
  // ═══════════════════════════════════════════════════════════

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModePill(
              title: 'Pomodoro',
              mode: TimerMode.pomodoro,
              onTap: () {
                if (!_isRunning) _switchToPomodoro();
              },
            ),
          ),
          Expanded(
            child: _buildModePill(
              title: 'Descanso',
              mode: TimerMode.shortBreak,
              onTap: () {
                if (!_isRunning) _switchToShortBreak();
              },
            ),
          ),
          Expanded(
            child: _buildModePill(
              title: 'Largo',
              mode: TimerMode.longBreak,
              onTap: () {
                if (!_isRunning) _switchToLongBreak();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required String title,
    required TimerMode mode,
    required VoidCallback onTap,
  }) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppTypography.label.copyWith(
            color: isSelected ? AppColors.primary : AppColors.mutedForeground,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CÍRCULO DE PROGRESO CON TIMER (STITCH RING 8PX)
  // ═══════════════════════════════════════════════════════════

  Widget _buildCircularTimer() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double circleSize = (screenWidth * 0.65).clamp(210.0, 320.0);
    if (screenHeight < 680) {
      circleSize = (screenHeight * 0.35).clamp(180.0, 240.0);
    } else if (screenHeight > 800) {
      circleSize = (screenHeight * 0.35).clamp(240.0, 340.0);
    }

    return SizedBox(
      width: circleSize,
      height: circleSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Track inactivo (1.0 completo, borde sutil #E2E8F0 de 8px)
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: const CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8.0,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.border),
            ),
          ),
          // Arco activo de progreso (#2563EB Cobalt Blue de 8px con puntas redondeadas)
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 8.0,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Contenedor central elevado
          Container(
            width: circleSize - 36,
            height: circleSize - 36,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(15, 23, 42, 0.04),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(_remainingSeconds),
                  style: AppTypography.displayTimer.copyWith(
                    color: AppColors.foreground,
                    fontSize: (circleSize * 0.22).clamp(48.0, 64.0),
                    height: 1.0,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _isRunning ? AppColors.primarySoft : AppColors.muted,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: AppTypography.caption.copyWith(
                      color: _isRunning
                          ? AppColors.primary
                          : AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
      return 'En pausa';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BOTONES DE CONTROL (STITCH FOCUS FLOW)
  // ═══════════════════════════════════════════════════════════

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón secundario de reinicio (48x48)
        InkWell(
          onTap: _resetTimer,
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.muted,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppColors.mutedForeground,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.paddingLarge),

        // Botón principal Play / Pause (64x64, Cobalt Blue #2563EB)
        InkWell(
          onTap: _toggleTimer,
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(37, 99, 235, 0.35),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.paddingLarge),

        // Botón secundario de saltar fase (48x48)
        InkWell(
          onTap: () {
            if (_isRunning) {
              _pauseTimer();
            }
            if (_currentMode == TimerMode.pomodoro) {
              _showBreakDialog();
            } else {
              _switchToPomodoro();
            }
          },
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.muted,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: const Icon(
              Icons.skip_next_rounded,
              color: AppColors.mutedForeground,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CONTADOR DE CICLOS (STITCH TARJETA CON INDICADORES)
  // ═══════════════════════════════════════════════════════════

  Widget _buildCycleCounter() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final total = settings.pomodorosBeforeLongBreak;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.all_inclusive_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Ciclo: ',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          Text(
            '$_completedCycles de $total',
            style: AppTypography.label.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          // Indicadores visuales de puntos Stitch
          Row(
            children: List.generate(total, (i) {
              final isDone = i < _completedCycles;
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : AppColors.border,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
