import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/models/settings_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// TIME SETTINGS SCREEN - CONFIGURAR TIEMPOS (STITCH FOCUS FLOW)
// ═══════════════════════════════════════════════════════════════════════════════════

class TimeSettingsScreen extends StatefulWidget {
  const TimeSettingsScreen({super.key});

  @override
  State<TimeSettingsScreen> createState() => _TimeSettingsScreenState();
}

class _TimeSettingsScreenState extends State<TimeSettingsScreen> {
  late double _tempFocusDuration;
  late double _tempShortBreakDuration;
  late double _tempLongBreakDuration;
  late int _tempPomodorosBeforeLongBreak;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _tempFocusDuration = settings.focusDuration;
    _tempShortBreakDuration = settings.shortBreakDuration;
    _tempLongBreakDuration = settings.longBreakDuration;
    _tempPomodorosBeforeLongBreak = settings.pomodorosBeforeLongBreak;
  }

  void _saveChanges() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _applyChanges();

    if (settings.isTimerRunning) {
      if (settings.onTimerReset != null) {
        settings.onTimerReset!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración guardada. Timer reiniciado.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración guardada exitosamente'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }

    Navigator.of(context).pop();
  }

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
      backgroundColor: context.colors.appBackground,
      appBar: AppBar(
        title: Text(
          'Configurar tiempos',
          style: AppTypography.heading2,
        ),
        backgroundColor: context.colors.cardBackground,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.border,
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingMedium,
              ),
              children: [
                Text(
                  'Ajusta la duración de cada ciclo Pomodoro y descansos',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // Slider 1: Tiempo de trabajo
                _buildSliderCard(
                  icon: Icons.timer_outlined,
                  label: 'Tiempo de trabajo',
                  valueText: '${_tempFocusDuration.toInt()} min',
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
                const SizedBox(height: AppConstants.paddingMedium),

                // Slider 2: Descanso
                _buildSliderCard(
                  icon: Icons.coffee_outlined,
                  label: 'Descanso',
                  valueText: '${_tempShortBreakDuration.toInt()} min',
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
                const SizedBox(height: AppConstants.paddingMedium),

                // Slider 3: Descanso largo
                _buildSliderCard(
                  icon: Icons.hotel_outlined,
                  label: 'Descanso largo',
                  valueText: '${_tempLongBreakDuration.toInt()} min',
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
                const SizedBox(height: AppConstants.paddingMedium),

                // Slider 4: Ciclos antes del descanso largo
                _buildSliderCard(
                  icon: Icons.repeat_rounded,
                  label: 'Ciclos para descanso largo',
                  valueText: '$_tempPomodorosBeforeLongBreak ciclos',
                  value: _tempPomodorosBeforeLongBreak.toDouble(),
                  min: 2,
                  max: 10,
                  divisions: 8,
                  onChanged: (value) {
                    setState(() {
                      _tempPomodorosBeforeLongBreak = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          ),

          // Botón Guardar cambios tipo Pill de Stitch (52px de alto)
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: context.colors.cardBackground,
              border: const Border(
                top: BorderSide(color: AppColors.border, width: 1.0),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(15, 23, 42, 0.03),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Guardar cambios',
                    style: AppTypography.button.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required IconData icon,
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  valueText,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
