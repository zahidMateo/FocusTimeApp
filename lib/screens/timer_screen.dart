import 'dart:async'; // Para usar Timer.periodic
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/models/settings_provider.dart';
import 'package:pomodoro_app/services/notification_service.dart';
import 'package:pomodoro_app/services/audio_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// TIMER SCREEN - PANTALLA DEL TEMPORIZADOR POMODORO
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Esta es la pantalla principal de la app. Muestra un timer circular que cuenta regresiva.
//
// CARACTERÍSTICAS:
// - Timer circular con progreso visual
// - Botones para play/pause y reset
// - Contador de ciclos completados
// - Se conecta con SettingsProvider para leer/actualizar configuraciones
//
// ¿POR QUÉ STATEFUL?
// - Necesita "estado mutable": segundos restantes, si está corriendo, ciclos completados
// - Usa Timer.periodic que se actualiza cada segundo
// - setState() reconstruye la UI cada segundo para mostrar el tiempo actualizado
//
// COMPONENTES PRINCIPALES:
// 1. Variables de estado: _remainingSeconds, _isRunning, _completedCycles, _timer
// 2. Métodos del ciclo de vida: initState(), dispose()
// 3. Lógica del timer: _startTimer(), _pauseTimer(), _resetTimer()
// 4. UI: Círculo de progreso, botones, contador de ciclos
//
// CONEXIÓN CON SETTINGS:
// - Lee focusDurationInSeconds del provider para inicializar el timer
// - Registra callback onTimerReset para que Settings pueda reiniciar el timer
// - Notifica isTimerRunning para que Settings valide cambios
//
// ═══════════════════════════════════════════════════════════════════════════════════

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // ═════════════════════════════════════════════════════════════════════════════════
  // VARIABLES DE ESTADO - Datos que cambian durante la vida del widget
  // ═════════════════════════════════════════════════════════════════════════════════

  int _remainingSeconds = 0; // Segundos que quedan en el timer
  int _initialSeconds = 0; // Segundos iniciales con los que empezó el timer (para calcular progreso)
  bool _isRunning = false; // ¿El timer está corriendo?
  int _completedCycles = 0; // Cuántos pomodoros completados en esta sesión
  Timer? _timer; // Timer de Dart que se ejecuta cada segundo (? = puede ser null)
  bool _audioStarted = false; // ¿El audio ambiental ya fue iniciado en esta sesión?

  // ─── GETTER CALCULADO: Progreso del círculo (0.0 a 1.0) ───
  // Divide segundos restantes entre total INICIAL para obtener porcentaje
  // Ejemplo: Si quedan 750 seg de 1500 seg iniciales → 750/1500 = 0.5 (50%)
  // IMPORTANTE: Usa _initialSeconds en lugar de settings para evitar desincronización
  double get _progress {
    if (_initialSeconds == 0) return 0.0; // Evitar división por cero
    return _remainingSeconds / _initialSeconds;
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
  // Aquí se muestran notificaciones, sonidos, y vibración
  void _onTimerComplete() async {
    _timer?.cancel();
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // ═══════════════════════════════════════════════════════════════════════════
    // DETENER SONIDO AMBIENTAL
    // ═══════════════════════════════════════════════════════════════════════════
    // Cuando el timer termina, detener el sonido ambiental que estaba sonando
    await AudioService.stop();

    // Cancelar notificación persistente
    await NotificationService.cancelTimerNotification();

    setState(() {
      _isRunning = false;
      _completedCycles++; // Incrementa ciclos completados
      _remainingSeconds = settings.focusDurationInSeconds; // Reset para próximo
      _initialSeconds = settings.focusDurationInSeconds; // Actualizar valor inicial para próximo ciclo
      _audioStarted = false; // Resetear flag de audio para próximo inicio
    });

    // Notificar al provider que el timer se detuvo
    settings.setTimerRunning(false);

    print('¡Pomodoro completado! Ciclos: $_completedCycles');

    // ═══════════════════════════════════════════════════════════════════════════
    // MOSTRAR NOTIFICACIÓN SI ESTÁ HABILITADA
    // ═══════════════════════════════════════════════════════════════════════════
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
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        // Actualizar tiempo si está detenido
        if (!_isRunning && _remainingSeconds == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _remainingSeconds = settings.focusDurationInSeconds;
              _initialSeconds = settings.focusDurationInSeconds; // También actualizar valor inicial
            });
          });
        }

        return Scaffold(
          backgroundColor: AppColors.card,
          body: SafeArea(
            child: Column(
              children: [
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.muted),
            ),
          ),
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: circleSize * 0.03, // 3% del círculo
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.sky),
              strokeCap: StrokeCap.round,
            ),
          ),
          Container(
            width: circleSize - 20,
            height: circleSize - 20,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.sky.withOpacity(0.15),
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
                    color: AppColors.sky,
                    fontSize: fontSize,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: AppConstants.paddingSmall),
                Text(
                  _getStatusText(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
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
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!_isRunning && _remainingSeconds == settings.focusDurationInSeconds) {
      return 'Listo para comenzar';
    } else if (_isRunning) {
      return '¡Enfócate!';
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
          icon: _isRunning ? Icons.pause : Icons.play_arrow,
          backgroundColor: AppColors.card,
          iconColor: AppColors.sky,
          size: buttonSize,
          onPressed: _toggleTimer,
          hasBorder: true,
        ),
        SizedBox(width: AppConstants.paddingLarge),
        _buildCircleButton(
          icon: Icons.refresh,
          backgroundColor: AppColors.card,
          iconColor: AppColors.sky,
          size: buttonSize,
          onPressed: _resetTimer,
          hasBorder: true,
        ),
      ],
    );
  }

  Widget _buildCircleButton({
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
            ? BorderSide(color: AppColors.border, width: 2)
            : BorderSide.none,
      ),
      elevation: hasBorder ? 4 : 8,
      shadowColor: AppColors.sky.withOpacity(0.2),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ciclos completados: ',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          Text(
            '$_completedCycles de ${AppConstants.pomodorosBeforeLongBreak}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.sky,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
