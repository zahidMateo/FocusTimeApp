import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/models/settings_provider.dart';
import 'package:pomodoro_app/models/rewards_provider.dart';
import 'package:pomodoro_app/services/notification_service.dart';
import 'package:pomodoro_app/services/audio_service.dart';
import 'package:pomodoro_app/services/focus_mode_service.dart';
import 'package:pomodoro_app/screens/music_and_sound_screen.dart';

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
  bool _isBreakMode = false;
  bool _isLongBreak = false;
  Timer? _timer;
  bool _audioStarted = false;

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
          if (!mounted) return;
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
  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Resetear timer - Vuelve al estado inicial de la fase actual                  │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _resetTimer() {
    _timer?.cancel();
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Detener sonido inmediatamente
    AudioService.stopImmediately();

    // Cancelar notificación persistente
    NotificationService.cancelTimerNotification();

    final resetSeconds = _isBreakMode
        ? (_isLongBreak
            ? settings.longBreakDurationInSeconds
            : settings.shortBreakDurationInSeconds)
        : settings.focusDurationInSeconds;

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
  // │ Saltar fase (Skip) - Avanza inmediatamente al siguiente ciclo o descanso     │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _skipPhase() {
    _timer?.cancel();
    AudioService.stopImmediately();
    NotificationService.cancelTimerNotification();

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final totalCycles = settings.pomodorosBeforeLongBreak;

    if (!_isBreakMode) {
      // Salto durante el trabajo: se incrementa el ciclo y se pasa al descanso
      settings.incrementCompletedCycle();
      final isLongBreak = settings.completedCycles >= totalCycles;
      final breakSeconds = isLongBreak
          ? settings.longBreakDurationInSeconds
          : settings.shortBreakDurationInSeconds;
      final breakMinutes = isLongBreak
          ? settings.longBreakDuration.toInt()
          : settings.shortBreakDuration.toInt();

      setState(() {
        _remainingSeconds = breakSeconds;
        _initialSeconds = breakSeconds;
        _isRunning = false;
        _isBreakMode = true;
        _isLongBreak = isLongBreak;
        _audioStarted = false;
      });

      settings.setTimerRunning(false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLongBreak
                ? 'Ciclo saltado. Descanso largo de $breakMinutes min listo.'
                : 'Ciclo saltado. Descanso de $breakMinutes min listo.',
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Salto durante el descanso: pasa al siguiente ciclo de enfoque
      if (_isLongBreak || settings.completedCycles >= totalCycles) {
        settings.resetCompletedCycles();
        _isLongBreak = false;
      }

      final workSeconds = settings.focusDurationInSeconds;

      setState(() {
        _remainingSeconds = workSeconds;
        _initialSeconds = workSeconds;
        _isRunning = false;
        _isBreakMode = false;
        _audioStarted = false;
      });

      settings.setTimerRunning(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descanso saltado. Sesión de enfoque lista.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Timer completado - Ejecuta cuando el timer llega a 0                         │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _onTimerComplete() async {
    _timer?.cancel();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final rewards = Provider.of<RewardsProvider>(context, listen: false);
    final totalCycles = settings.pomodorosBeforeLongBreak;

    await AudioService.stop();
    await NotificationService.cancelTimerNotification();

    if (!_isBreakMode) {
      // 1. COMPLETÓ UN POMODORO DE TRABAJO
      settings.incrementCompletedCycle();

      // Registrar sesión en RewardsProvider
      try {
        await rewards.onSessionCompleted(settings.focusDuration.toInt());
      } catch (e) {
        debugPrint('❌ Error al actualizar recompensas/estadísticas: $e');
      }

      // Determinar si corresponde descanso largo o corto
      final isLongBreak = settings.completedCycles >= totalCycles;
      final breakSeconds = isLongBreak
          ? settings.longBreakDurationInSeconds
          : settings.shortBreakDurationInSeconds;
      final breakMinutes = isLongBreak
          ? settings.longBreakDuration.toInt()
          : settings.shortBreakDuration.toInt();

      setState(() {
        _remainingSeconds = breakSeconds;
        _initialSeconds = breakSeconds;
        _isRunning = false;
        _isBreakMode = true;
        _isLongBreak = isLongBreak;
        _audioStarted = false;
      });

      settings.setTimerRunning(false);

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

      if (!mounted) return;

      final message = isLongBreak
          ? 'Completaste todos los ciclos ($totalCycles/$totalCycles). Descanso largo de $breakMinutes min listo.'
          : 'Ciclo completado (${settings.completedCycles}/$totalCycles). Descanso de $breakMinutes min listo.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Empezar',
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _isRunning = true;
              });
              settings.setTimerRunning(true);
              _startTimer();
            },
          ),
        ),
      );

      // Auto-iniciar descanso si está activado
      if (settings.autoStartBreaks) {
        setState(() {
          _isRunning = true;
        });
        settings.setTimerRunning(true);
        _startTimer();
      }
    } else {
      // 2. COMPLETÓ UN DESCANSO
      if (_isLongBreak || settings.completedCycles >= totalCycles) {
        settings.resetCompletedCycles();
        _isLongBreak = false;
      }

      final workSeconds = settings.focusDurationInSeconds;

      setState(() {
        _remainingSeconds = workSeconds;
        _initialSeconds = workSeconds;
        _isRunning = false;
        _isBreakMode = false;
        _audioStarted = false;
      });

      settings.setTimerRunning(false);

      if (settings.notificationsEnabled) {
        try {
          await NotificationService.showBreakComplete(
            playSound: settings.soundEnabled,
            enableVibration: settings.vibrationEnabled,
          );
        } catch (e) {
          debugPrint('❌ Error al mostrar notificación de descanso: $e');
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Descanso finalizado. ¿Listo para el siguiente ciclo?'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Iniciar',
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _isRunning = true;
              });
              settings.setTimerRunning(true);
              _startTimer();
            },
          ),
        ),
      );

      // Auto-iniciar siguiente pomodoro si está activado
      if (settings.autoStartPomodoros) {
        setState(() {
          _isRunning = true;
        });
        settings.setTimerRunning(true);
        _startTimer();
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        if (!_isRunning) {
          final targetSeconds = _isBreakMode
              ? (_isLongBreak
                  ? settings.longBreakDurationInSeconds
                  : settings.shortBreakDurationInSeconds)
              : settings.focusDurationInSeconds;

          if (_initialSeconds != targetSeconds) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _remainingSeconds = targetSeconds;
                _initialSeconds = targetSeconds;
              });
            });
          }
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: 24,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 420,
                      padding: const EdgeInsets.all(35),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTopAccountSection(settings),
                          const SizedBox(height: 20),
                          _buildCircularTimer(),
                          const SizedBox(height: 24),
                          _buildQuickTimeButtons(),
                          const SizedBox(height: 20),
                          _buildControlButtons(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCyclesCompletedCard(
                      completedCycles: settings.completedCycles,
                      totalCycles: settings.pomodorosBeforeLongBreak,
                      isBreakMode: _isBreakMode,
                    ),
                    const SizedBox(height: 16),
                    _buildAudioPlayerCard(settings),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TARJETA DE CICLOS COMPLETADOS (GOOGLE STITCH FOCUS FLOW)
  // ═══════════════════════════════════════════════════════════

  Widget _buildCyclesCompletedCard({
    required int completedCycles,
    required int totalCycles,
    bool isBreakMode = false,
  }) {
    final effectiveTotal = totalCycles < 1 ? 1 : totalCycles;
    final effectiveCompleted = completedCycles.clamp(0, effectiveTotal);

    // Si la configuración tiene más de 4 ciclos (ej. 5, 8 o 10), agrupamos visualmente
    // en bloques de máximo 4 para que la UI conserve sus proporciones amplias y limpias.
    final int visualSlots = effectiveTotal > 4 ? 4 : effectiveTotal;

    int visualFilled;
    if (effectiveCompleted == 0) {
      visualFilled = 0;
    } else if (effectiveCompleted == effectiveTotal) {
      // Meta total alcanzada: todos los slots pintados
      visualFilled = visualSlots;
    } else if (effectiveTotal > 4 && effectiveCompleted % 4 == 0) {
      // Si completó un múltiplo de 4 (ej. el ciclo 4):
      // - En el descanso se ven los 4 llenos (meta del bloque).
      // - Al iniciar el 5° ciclo de trabajo se despintan para la nueva tanda.
      visualFilled = isBreakMode ? 4 : 0;
    } else {
      visualFilled = effectiveTotal > 4
          ? (effectiveCompleted % 4)
          : effectiveCompleted;
    }

    return Container(
      width: 420,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: Bandera + Título + "X de Y" global
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.flag_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ciclos completados',
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF131B2E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$effectiveCompleted',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' de $effectiveTotal',
                      style: AppTypography.bodyMedium.copyWith(
                        color: const Color(0xFF131B2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Fila inferior: Segmentos horizontales + Marcadores circulares
          Row(
            children: [
              // Segmentos horizontales (máximo 4 para conservar proporciones elegantes)
              Expanded(
                child: Row(
                  children: List.generate(visualSlots, (index) {
                    final isFilled = index < visualFilled;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index < visualSlots - 1 ? 6.0 : 0.0,
                        ),
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: isFilled
                              ? AppColors.primary
                              : const Color(0xFFEAEDFF),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              // Marcadores circulares estilo Stitch (máximo 4)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(visualSlots, (index) {
                  final isDone = index < visualFilled;
                  final isCurrent = index == visualFilled;
                  return Container(
                    margin: EdgeInsets.only(
                      right: index < visualSlots - 1 ? 6.0 : 0.0,
                    ),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (isDone || isCurrent)
                            ? AppColors.primary
                            : const Color(0xFFC3C6D7),
                        width: 2.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: isDone
                        ? Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopAccountSection(SettingsProvider settings) {
    final modeLabel = _isBreakMode
        ? (_isLongBreak ? 'Descanso largo' : 'Descanso')
        : '${settings.focusDuration.toInt()} min';

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cuenta',
                style: AppTypography.caption.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              Text(
                'Focus Time',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isBreakMode ? const Color(0xFFECFDF5) : AppColors.muted,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            modeLabel,
            style: AppTypography.caption.copyWith(
              color: _isBreakMode ? const Color(0xFF10B981) : AppColors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CÍRCULO DE PROGRESO CON TIMER (STITCH RING 8PX)
  // ═══════════════════════════════════════════════════════════

  Widget _buildCircularTimer() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double circleSize = (screenWidth * 0.46).clamp(180.0, 260.0);
    if (screenHeight < 680) {
      circleSize = (screenHeight * 0.26).clamp(160.0, 210.0);
    } else if (screenHeight > 800) {
      circleSize = (screenHeight * 0.28).clamp(180.0, 240.0);
    }

    final progress = _initialSeconds == 0
        ? 0.0
        : 1.0 - (_remainingSeconds / _initialSeconds);

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
          // Arco activo de progreso con azul suave para no competir con el valor del tiempo
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: CircularProgressIndicator(
              value: progress,
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
            width: circleSize - 28,
            height: circleSize - 28,
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
                    color: AppColors.primary,
                    fontSize: (circleSize * 0.18).clamp(36.0, 52.0),
                    height: 1.0,
                    letterSpacing: -1.2,
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
    if (_isBreakMode) {
      if (_isRunning) {
        return _isLongBreak ? 'Descanso largo activo' : 'Descanso activo';
      } else if (_remainingSeconds == _initialSeconds) {
        return _isLongBreak ? 'Descanso largo listo' : 'Descanso listo';
      } else {
        return 'Descanso en pausa';
      }
    }

    if (!_isRunning && _remainingSeconds == _initialSeconds) {
      return 'Listo para comenzar';
    } else if (_isRunning) {
      return 'Enfocado y fluyendo';
    } else {
      return 'Sesión pausada';
    }
  }

  Widget _buildQuickTimeButtons() {
    final quickTimes = [5, 15, 25];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: quickTimes.map((minutes) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () {
              final addedSeconds = minutes * 60;

              setState(() {
                _remainingSeconds += addedSeconds;
                _initialSeconds += addedSeconds;
              });

              if (!_isRunning) {
                AudioService.stopImmediately();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Text(
                '+$minutes min',
                style: AppTypography.caption.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
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
          onLongPress: () {
            final settings = Provider.of<SettingsProvider>(context, listen: false);
            settings.resetCompletedCycles();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ciclos reiniciados a 0'),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 2),
              ),
            );
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

        // Botón secundario de saltar fase (48x48) - Conectado a _skipPhase
        InkWell(
          onTap: _skipPhase,
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
  // TARJETA DE REPRODUCCIÓN DE MÚSICA / AUDIO (GOOGLE STITCH)
  // ═══════════════════════════════════════════════════════════

  bool get _isAudioPlaying => AudioService.isPlaying;

  static const List<String> _soundCycleList = [
    'Lluvia',
    'Oleaje',
    'Viento suave',
  ];

  String _getSoundDisplayName(String soundKey) {
    switch (soundKey) {
      case 'Lluvia':
        return 'Lluvia de bosque';
      case 'Oleaje':
        return 'Oleaje del mar';
      case 'Viento suave':
        return 'Viento suave';
      case 'Ruido blanco':
        return 'Ruido blanco';
      case 'Ninguno':
        return 'Lluvia de bosque';
      default:
        return soundKey;
    }
  }

  IconData _getSoundIcon(String soundKey) {
    switch (soundKey) {
      case 'Lluvia':
      case 'Ninguno':
        return Icons.water_drop_rounded;
      case 'Oleaje':
        return Icons.waves_rounded;
      case 'Viento suave':
        return Icons.air_rounded;
      case 'Ruido blanco':
        return Icons.graphic_eq_rounded;
      default:
        return Icons.water_drop_rounded;
    }
  }

  void _toggleAudioPlayback(SettingsProvider settings) async {
    if (AudioService.isPlaying) {
      await AudioService.pause();
    } else {
      String soundToPlay = settings.selectedSound;
      if (soundToPlay == 'Ninguno' || soundToPlay.isEmpty) {
        soundToPlay = 'Lluvia';
        settings.setSelectedSound('Lluvia');
      }
      _audioStarted = true;
      await AudioService.play(
        soundToPlay,
        volume: settings.soundVolume,
        fadeDurationMs: 800,
      );
    }
    if (mounted) setState(() {});
  }

  void _playPreviousSound(SettingsProvider settings) async {
    int currentIndex = _soundCycleList.indexOf(settings.selectedSound);
    if (currentIndex == -1) currentIndex = 0;
    int prevIndex =
        (currentIndex - 1 + _soundCycleList.length) % _soundCycleList.length;
    final nextSound = _soundCycleList[prevIndex];
    settings.setSelectedSound(nextSound);
    if (_isAudioPlaying) {
      await AudioService.play(
        nextSound,
        volume: settings.soundVolume,
        fadeDurationMs: 500,
      );
    }
    if (mounted) setState(() {});
  }

  void _playNextSound(SettingsProvider settings) async {
    int currentIndex = _soundCycleList.indexOf(settings.selectedSound);
    if (currentIndex == -1) currentIndex = 0;
    int nextIndex = (currentIndex + 1) % _soundCycleList.length;
    final nextSound = _soundCycleList[nextIndex];
    settings.setSelectedSound(nextSound);
    if (_isAudioPlaying) {
      await AudioService.play(
        nextSound,
        volume: settings.soundVolume,
        fadeDurationMs: 500,
      );
    }
    if (mounted) setState(() {});
  }

  Widget _buildAudioIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        icon: Icon(icon, size: 20, color: const Color(0xFF585F67)),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
          maxWidth: 32,
          maxHeight: 32,
        ),
        splashRadius: 18,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildAudioPlayerCard(SettingsProvider settings) {
    final soundKey = settings.selectedSound;
    final displayName = _getSoundDisplayName(soundKey);
    final volumePercent = (settings.soundVolume * 100).toInt();

    return Container(
      width: 420,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sección izquierda de información de pista (tappable para abrir modal de fuentes)
          Expanded(
            child: InkWell(
              onTap: () => _showMusicSourceBottomSheet(context, settings),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F3FF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _getSoundIcon(soundKey),
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF131B2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sonido ambiental · $volumePercent%',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF585F67),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Sección derecha de controles de reproducción
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAudioIconButton(
                icon: Icons.skip_previous_rounded,
                tooltip: 'Pista anterior',
                onTap: () => _playPreviousSound(settings),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _toggleAudioPlayback(settings),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isAudioPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _buildAudioIconButton(
                icon: Icons.skip_next_rounded,
                tooltip: 'Pista siguiente',
                onTap: () => _playNextSound(settings),
              ),
              _buildAudioIconButton(
                icon: Icons.tune_rounded,
                tooltip: 'Configurar fuente de música',
                onTap: () => _showMusicSourceBottomSheet(context, settings),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MODAL BOTTOM SHEET: FUENTE DE MÚSICA Y AUDIO (GOOGLE STITCH)
  // ═══════════════════════════════════════════════════════════

  void _showMusicSourceBottomSheet(
    BuildContext context,
    SettingsProvider settings,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentVolume = settings.soundVolume;
            final volumePercent = (currentVolume * 100).toInt();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador de arrastre superior
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    // Encabezado con título e ícono de audífonos y botón de cerrar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.headphones_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Fuente de música y audio',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF131B2E),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Elige la fuente de sonido para acompañar tu sesión',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF585F67),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(modalContext),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF2F3FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Color(0xFF585F67),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: Color(0xFFE2E7FF), height: 1),
                    const SizedBox(height: 16),

                    // Opción 1: Sonidos ambientales (Activo / Seleccionado)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.water_drop_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Sonidos ambientales',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF131B2E),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Lluvia, bosque, frecuencias binaurales y ruido blanco',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: Color(0xFF585F67),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Chips rápidos para cambiar sonido ambiental
                          Row(
                            children: _soundCycleList.map((sound) {
                              final isCurrent = settings.selectedSound == sound;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: InkWell(
                                  onTap: () {
                                    settings.setSelectedSound(sound);
                                    if (_isAudioPlaying) {
                                      AudioService.play(
                                        sound,
                                        volume: settings.soundVolume,
                                      );
                                    }
                                    setModalState(() {});
                                    setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? AppColors.primary
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isCurrent
                                            ? AppColors.primary
                                            : const Color(0xFFDCE3EC),
                                      ),
                                    ),
                                    child: Text(
                                      sound,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isCurrent
                                            ? Colors.white
                                            : const Color(0xFF131B2E),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(modalContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MusicAndSoundScreen(),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  'Ver catálogo completo →',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Opción 2: Spotify
                    _buildModalSourceTile(
                      icon: Icons.podcasts_rounded,
                      iconColor: const Color(0xFF1DB954),
                      iconBg: const Color(0xFF1DB954).withValues(alpha: 0.12),
                      title: 'Spotify',
                      subtitle: 'Playlists de concentración y estudio',
                      badge: 'Conectado',
                      badgeColor: const Color(0xFF1DB954),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Spotify vinculado con playlists de enfoque'),
                            backgroundColor: AppColors.primary,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    // Opción 3: YouTube Music
                    _buildModalSourceTile(
                      icon: Icons.play_circle_filled_rounded,
                      iconColor: const Color(0xFFEF4444),
                      iconBg: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      title: 'YouTube Music',
                      subtitle: 'Playlists instrumentales y mezclas de enfoque',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('YouTube Music: Seleccionando mezcla instrumental'),
                            backgroundColor: AppColors.primary,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    // Opción 4: Música local / Teléfono
                    _buildModalSourceTile(
                      icon: Icons.folder_open_rounded,
                      iconColor: const Color(0xFF585F67),
                      iconBg: const Color(0xFFDCE3EC),
                      title: 'Música local / Teléfono',
                      subtitle: 'Explorar archivos de audio del dispositivo',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Explorando archivos locales de audio'),
                            backgroundColor: AppColors.primary,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // Contenedor de Slider de Volumen
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.volume_up_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Volumen de música',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF131B2E),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$volumePercent%',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF585F67),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: const Color(0xFFE2E7FF),
                              thumbColor: AppColors.primary,
                              overlayColor: AppColors.primary.withValues(alpha: 0.15),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7,
                              ),
                            ),
                            child: Slider(
                              value: currentVolume.clamp(0.0, 1.0),
                              min: 0.0,
                              max: 1.0,
                              onChanged: (val) {
                                setModalState(() {
                                  settings.setSoundVolume(val);
                                });
                                AudioService.setVolume(val);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Botón de acción: Listo
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(modalContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'Listo',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalSourceTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF131B2E),
                        ),
                      ),
                      if (badge != null && badgeColor != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF585F67),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF585F67),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
