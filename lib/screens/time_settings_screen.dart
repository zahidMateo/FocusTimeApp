import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/models/settings_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// TIME SETTINGS SCREEN - PANTALLA DEDICADA PARA CONFIGURAR TIEMPOS
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Esta pantalla permite configurar los 3 tiempos del Pomodoro:
// - Tiempo de trabajo (focus)
// - Descanso corto
// - Descanso largo
//
// VENTAJAS DE ESTA ARQUITECTURA:
// 1. El usuario puede mover todos los sliders libremente sin interrupciones
// 2. Solo se valida UNA VEZ cuando presiona "Guardar cambios"
// 3. Si el timer está corriendo, aparece UN SOLO diálogo
// 4. Si acepta, se aplican TODOS los cambios de una vez
// 5. Código mucho más simple y limpio
//
// ═══════════════════════════════════════════════════════════════════════════════════

class TimeSettingsScreen extends StatefulWidget {
  const TimeSettingsScreen({super.key});

  @override
  State<TimeSettingsScreen> createState() => _TimeSettingsScreenState();
}

class _TimeSettingsScreenState extends State<TimeSettingsScreen> {
  // Variables temporales para los valores de los sliders
  // Estos NO se guardan en el provider hasta que el usuario presione "Guardar"
  late double _tempFocusDuration;
  late double _tempShortBreakDuration;
  late double _tempLongBreakDuration;
  late int _tempPomodorosBeforeLongBreak;

  @override
  void initState() {
    super.initState();
    // Inicializar con los valores actuales del provider
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _tempFocusDuration = settings.focusDuration;
    _tempShortBreakDuration = settings.shortBreakDuration;
    _tempLongBreakDuration = settings.longBreakDuration;
    _tempPomodorosBeforeLongBreak = settings.pomodorosBeforeLongBreak;
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // GUARDAR CAMBIOS - Aplica todos los cambios de una vez
  // ═════════════════════════════════════════════════════════════════════════════════
  void _saveChanges() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Siempre aplicar los cambios
    _applyChanges();

    // Si el timer está corriendo, mostrar advertencia y resetear
    if (settings.isTimerRunning) {
      if (settings.onTimerReset != null) {
        settings.onTimerReset!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Configuración guardada. Timer reiniciado.'),
          backgroundColor: AppColors.sky,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Si no está corriendo, solo confirmar guardado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Configuración guardada exitosamente'),
          backgroundColor: AppColors.sky,
          duration: Duration(seconds: 2),
        ),
      );
    }

    Navigator.of(context).pop(); // Volver a Settings
  }

  // Aplicar los cambios al provider
  void _applyChanges() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.setFocusDuration(_tempFocusDuration);
    settings.setShortBreakDuration(_tempShortBreakDuration);
    settings.setLongBreakDuration(_tempLongBreakDuration);
    settings.setPomodorosBeforeLongBreak(_tempPomodorosBeforeLongBreak);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Configurar tiempos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ─── Sliders (sin validación, se pueden mover libremente) ───
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppConstants.paddingLarge),
              children: [
                // Descripción
                Text(
                  'Ajusta la duración de cada ciclo Pomodoro',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppConstants.paddingXLarge),

                // Slider 1: Tiempo de trabajo
                _buildSimpleSlider(
                  label: 'Tiempo de trabajo',
                  value: _tempFocusDuration,
                  min: 1,
                  max: 60,
                  divisions: 59,
                  onChanged: (value) {
                    setState(() {
                      _tempFocusDuration = value;
                    });
                  },
                ),
                SizedBox(height: AppConstants.paddingXLarge),

                // Slider 2: Descanso corto
                _buildSimpleSlider(
                  label: 'Descanso corto',
                  value: _tempShortBreakDuration,
                  min: 1,
                  max: 15,
                  divisions: 14,
                  onChanged: (value) {
                    setState(() {
                      _tempShortBreakDuration = value;
                    });
                  },
                ),
                SizedBox(height: AppConstants.paddingXLarge),

                // Slider 3: Descanso largo
                _buildSimpleSlider(
                  label: 'Descanso largo',
                  value: _tempLongBreakDuration,
                  min: 5,
                  max: 30,
                  divisions: 25,
                  onChanged: (value) {
                    setState(() {
                      _tempLongBreakDuration = value;
                    });
                  },
                ),
                SizedBox(height: AppConstants.paddingXLarge),

                // Slider 4: Ciclos antes del descanso largo
                _buildCyclesSlider(
                  label: 'Ciclos',
                  value: _tempPomodorosBeforeLongBreak,
                  min: 2,
                  max: 10,
                  divisions: 8,
                  onChanged: (value) {
                    setState(() {
                      _tempPomodorosBeforeLongBreak = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // ─── Botón Guardar (al final de la pantalla) ───
          Container(
            padding: EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.card,
              boxShadow: [
                BoxShadow(
                  color: AppColors.border,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sky,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: AppConstants.paddingMedium,
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Guardar cambios',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // SLIDER SIMPLE - Sin validación, solo cambia el estado local
  // ═════════════════════════════════════════════════════════════════════════════════
  Widget _buildSimpleSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y valor
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.sky.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${value.toInt()} min',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.sky,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.paddingSmall),

        // Slider
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.sky,
            inactiveTrackColor: AppColors.muted,
            thumbColor: AppColors.sky,
            overlayColor: AppColors.sky.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged, // Simple, sin validación
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // SLIDER PARA CICLOS - Similar al slider simple pero con valores int
  // ═════════════════════════════════════════════════════════════════════════════════
  Widget _buildCyclesSlider({
    required String label,
    required int value,
    required int min,
    required int max,
    required int divisions,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y valor
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.sky.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$value ciclos',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.sky,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.paddingSmall),

        // Slider
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.sky,
            inactiveTrackColor: AppColors.muted,
            thumbColor: AppColors.sky,
            overlayColor: AppColors.sky.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: divisions,
            onChanged: (double newValue) {
              onChanged(newValue.toInt());
            },
          ),
        ),
      ],
    );
  }
}
