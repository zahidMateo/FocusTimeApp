import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/models/settings_provider.dart';
import 'package:pomodoro_app/models/rewards_provider.dart';
import 'package:pomodoro_app/screens/time_settings_screen.dart';
import 'package:pomodoro_app/screens/sound_settings_screen.dart';
import 'package:pomodoro_app/screens/theme_settings_screen.dart';
import 'package:pomodoro_app/screens/about_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// SETTINGS SCREEN - PANTALLA DE CONFIGURACIONES
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Esta pantalla permite al usuario personalizar TODA la app.
// Es la pantalla más compleja porque tiene muchos tipos de controles diferentes.
//
// SECCIONES:
// 1. ⏱️ Tiempos - Sliders para configurar duración de pomodoro y descansos
// 2. 🔔 Notificaciones - Switches para notificaciones y vibración
// 3. 🔊 Sonido - Switch, dropdown, y slider de volumen
// 4. ⚙️ Comportamiento - Switches para auto-inicio y mantener pantalla
// 5. 📊 Datos - Botón para resetear estadísticas
//
// CARACTERÍSTICAS TÉCNICAS IMPORTANTES:
//
// 1. VALIDACIÓN MIENTRAS TIMER CORRE:
//    - Detecta si el timer está corriendo usando settings.isTimerRunning
//    - Si intentas cambiar una configuración, muestra un diálogo de advertencia
//    - Si aceptas, la configuración cambia y el timer se resetea
//    - Esto previene bugs (ej: cambiar de 25 min a 5 min con timer en 20 min)
//
// 2. SLIDER CON VALIDACIÓN SIN MÚLTIPLES DIÁLOGOS:
//    - Problema: Slider llama onChanged() muchas veces mientras arrastras
//    - Solución: Usamos onChangeStart (UNA VEZ al empezar), onChanged (continuo),
//      y onChangeEnd (UNA VEZ al soltar)
//    - El diálogo solo aparece en onChangeStart
//    - StatefulBuilder mantiene estado temporal del slider
//
// 3. PROVIDER PATTERN:
//    - Consumer<SettingsProvider> envuelve todo para reactividad
//    - Cualquier cambio en SettingsProvider actualiza esta pantalla automáticamente
//    - _handleSettingChange() centraliza la lógica de validación
//
// 4. WIDGETS REUTILIZABLES:
//    - _buildTimeSlider(): Slider con validación para tiempos
//    - _buildSwitchTile(): Switch estándar para opciones on/off
//    - _buildDropdownTile(): Dropdown para seleccionar entre opciones
//    - _buildSectionHeader(): Encabezado de sección con emoji
//
// CONEXIÓN CON TIMER:
// - settings.onTimerReset es un callback que timer_screen.dart registra
// - Cuando cambias configuraciones aquí, se llama onTimerReset() para reiniciar
// - settings.isTimerRunning permite saber si mostrar advertencia o no
//
// ¿POR QUÉ STATELESS?
// - No tiene estado propio (_no variables con setState)
// - Todo el estado está en SettingsProvider
// - Los sliders usan StatefulBuilder para mantener estado temporal local
//
// ═══════════════════════════════════════════════════════════════════════════════════

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, RewardsProvider>(
      builder: (context, settings, rewards, child) {
        return Scaffold(
          backgroundColor: context.colors.cardBackground,
          appBar: AppBar(
            title: Text('Configuración'),
            centerTitle: true,
          ),
          body: ListView(
            padding: EdgeInsets.all(AppConstants.paddingMedium),
            children: [
              _buildSectionHeader('⏱️ Tiempos'),
              _buildTimeNavigationCard(context, settings),
              SizedBox(height: AppConstants.paddingLarge),
              _buildSectionHeader('🔔 Notificaciones'),
              _buildNotificationsCard(context, settings),
              SizedBox(height: AppConstants.paddingLarge),
              _buildSectionHeader('🔊 Sonido'),
              _buildSoundCard(context, settings),
              SizedBox(height: AppConstants.paddingLarge),
              _buildSectionHeader('🌙 Apariencia'),
              _buildAppearanceCard(context, settings, rewards),
              SizedBox(height: AppConstants.paddingLarge),
              _buildSectionHeader('🔒 Modo Concentración'),
              _buildBehaviorCard(context, settings, rewards),
              SizedBox(height: AppConstants.paddingLarge),
              _buildSectionHeader('ℹ️ Acerca de'),
              _buildAboutCard(context, settings),
              SizedBox(height: AppConstants.paddingLarge),
              _buildSectionHeader('📊 Datos'),
              _buildDataCard(context, settings),
              SizedBox(height: AppConstants.paddingXLarge),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppConstants.paddingSmall,
        bottom: AppConstants.paddingSmall,
      ),
      child: Text(
        title,
        style: AppTypography.heading2.copyWith(fontSize: 18),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // CARD DE NAVEGACIÓN A CONFIGURACIÓN DE TIEMPOS
  // ═════════════════════════════════════════════════════════════════════════════════
  // Muestra los valores actuales y permite navegar a la pantalla dedicada
  Widget _buildTimeNavigationCard(BuildContext context, SettingsProvider settings) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.timer, color: context.colors.accent),
        title: Text(
          'Configurar duraciones',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Trabajo: ${settings.focusDuration.toInt()}m  •  Descanso: ${settings.shortBreakDuration.toInt()}m / ${settings.longBreakDuration.toInt()}m',
          style: AppTypography.bodySmall,
        ),
        trailing: Icon(Icons.chevron_right, color: context.colors.textSecondary),
        onTap: () {
          // Navegar a la pantalla de configuración de tiempos
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TimeSettingsScreen(),
            ),
          );
        },
      ),
    );
  }

  // NOTA: La antigua función _buildTimeCard con sliders complejos fue reemplazada
  // por la nueva arquitectura que usa una pantalla separada (TimeSettingsScreen)

  // ═════════════════════════════════════════════════════════════════════════════════
  // CARD DE NAVEGACIÓN A CONFIGURACIÓN DE SONIDOS
  // ═════════════════════════════════════════════════════════════════════════════════
  Widget _buildSoundNavigationCard(BuildContext context, SettingsProvider settings) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.music_note, color: context.colors.accent),
        title: Text(
          'Sonidos ambientales',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Actual: ${settings.selectedSound}  •  Volumen: ${(settings.soundVolume * 100).toInt()}%',
          style: AppTypography.bodySmall,
        ),
        trailing: Icon(Icons.chevron_right, color: context.colors.textSecondary),
        onTap: () {
          // Navegar a la pantalla de configuración de sonidos
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SoundSettingsScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeCard_OLD_COMMENTED(BuildContext context, SettingsProvider settings) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            _buildTimeSlider(
              context: context,
              settings: settings,
              label: 'Tiempo de trabajo',
              value: settings.focusDuration,
              min: 1,
              max: 60,
              divisions: 59,
              onApplyChange: (value) => settings.setFocusDuration(value),
            ),
            Divider(height: AppConstants.paddingLarge * 2),
            _buildTimeSlider(
              context: context,
              settings: settings,
              label: 'Descanso corto',
              value: settings.shortBreakDuration,
              min: 1,
              max: 15,
              divisions: 14,
              onApplyChange: (value) => settings.setShortBreakDuration(value),
            ),
            Divider(height: AppConstants.paddingLarge * 2),
            _buildTimeSlider(
              context: context,
              settings: settings,
              label: 'Descanso largo',
              value: settings.longBreakDuration,
              min: 5,
              max: 30,
              divisions: 25,
              onApplyChange: (value) => settings.setLongBreakDuration(value),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // MÉTODO DE VALIDACIÓN CENTRAL
  // ═════════════════════════════════════════════════════════════════════════════════
  // Este método es CRUCIAL para la funcionalidad de validación.
  // Todas las configuraciones que pueden afectar el timer pasan por aquí.
  //
  // ¿CÓMO FUNCIONA?
  // 1. Recibe un callback (onChange) que contiene la acción a realizar
  // 2. Revisa si settings.isTimerRunning es true
  // 3. Si está corriendo: muestra diálogo de confirmación
  // 4. Si no está corriendo: ejecuta onChange() directamente
  //
  // EJEMPLO DE USO:
  //   _handleSettingChange(
  //     context,
  //     settings,
  //     () => settings.setFocusDuration(30),  ← Este es el onChange
  //   );

  void _handleSettingChange(
    BuildContext context,
    SettingsProvider settings,
    VoidCallback onChange, // Función que se ejecuta si el usuario confirma
  ) {
    // Si el timer está corriendo, mostrar advertencia
    if (settings.isTimerRunning) {
      _showTimerRunningWarning(context, settings, onChange);
    } else {
      // Si no está corriendo, aplicar el cambio directamente
      onChange();
    }
  }

  Widget _buildTimeSlider({
    required BuildContext context,
    required SettingsProvider settings,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onApplyChange,
  }) {
    double tempValue = value;
    bool changeApproved = false;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setSliderState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    color: context.colors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${tempValue.toInt()} min',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingSmall),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.sky,
                inactiveTrackColor: AppColors.muted,
                thumbColor: AppColors.sky,
                overlayColor: AppColors.sky.withOpacity(0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: tempValue,
                min: min,
                max: max,
                divisions: divisions,
                onChangeStart: (double startValue) async {
                  // Mostrar advertencia solo una vez cuando empieza a mover el slider
                  if (settings.isTimerRunning) {
                    bool? shouldProceed = await _showTimerRunningWarningAsync(context, settings);
                    changeApproved = shouldProceed ?? false;
                  } else {
                    changeApproved = true;
                  }
                },
                onChanged: (double newValue) {
                  // Actualizar el valor visual mientras arrastra
                  if (changeApproved || !settings.isTimerRunning) {
                    setSliderState(() {
                      tempValue = newValue;
                    });
                  }
                },
                onChangeEnd: (double finalValue) {
                  // Aplicar el cambio final solo si fue aprobado
                  if (changeApproved) {
                    // 1. Actualizar el provider primero
                    onApplyChange(finalValue);

                    // 2. Si el timer estaba corriendo, resetearlo con el NUEVO valor
                    if (settings.isTimerRunning && settings.onTimerReset != null) {
                      // Esperamos a que el provider actualice completamente
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        // Llamar al reset del timer
                        settings.onTimerReset!();

                        // Mostrar confirmación UNA SOLA VEZ aquí
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Configuración actualizada. Timer reiniciado.'),
                            backgroundColor: context.colors.accent,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      });
                    }
                  } else {
                    // Revertir al valor original si no fue aprobado
                    setSliderState(() {
                      tempValue = value;
                    });
                  }
                  changeApproved = false;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationsCard(BuildContext context, SettingsProvider settings) {
    return Card(
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            title: 'Activar notificaciones',
            subtitle: 'Recibir alertas al terminar ciclos',
            value: settings.notificationsEnabled,
            onChanged: (value) {
              _handleSettingChange(
                context,
                settings,
                () => settings.setNotificationsEnabled(value),
              );
            },
          ),
          Divider(height: 1),
          _buildSwitchTile(
            context,
            title: 'Vibración',
            subtitle: 'Vibrar al terminar',
            value: settings.vibrationEnabled,
            enabled: settings.notificationsEnabled,
            onChanged: (value) {
              _handleSettingChange(
                context,
                settings,
                () => settings.setVibrationEnabled(value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSoundCard(BuildContext context, SettingsProvider settings) {
    return Card(
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            title: 'Sonidos ambientales',
            subtitle: 'Reproducir sonidos mientras el timer está activo',
            value: settings.soundEnabled,
            // NOTA: El sonido es INDEPENDIENTE de las notificaciones
            // (sonidos ambientales durante el timer, no sonido de notificación)
            onChanged: (value) {
              _handleSettingChange(
                context,
                settings,
                () => settings.setSoundEnabled(value),
              );
            },
          ),
          if (settings.soundEnabled) ...[
            Divider(height: 1),
            _buildSoundNavigationCard(context, settings),
          ],
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // CARD DE APARIENCIA - TEMA OSCURO Y COLORES
  // ═════════════════════════════════════════════════════════════════════════════════
  Widget _buildAppearanceCard(BuildContext context, SettingsProvider settings, RewardsProvider rewards) {
    final darkModeUnlocked = rewards.isItemPurchased('dark_mode');

    return Card(
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            title: 'Tema oscuro',
            subtitle: darkModeUnlocked
                ? 'Usar tema oscuro en la aplicación'
                : '🔒 Desbloquea en la tienda (100 puntos)',
            value: settings.darkModeEnabled,
            enabled: darkModeUnlocked,
            onChanged: (value) {
              if (darkModeUnlocked) {
                settings.setDarkModeEnabled(value);
              } else {
                _showLockedFeatureDialog(context, 'Tema Oscuro', 100);
              }
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.palette, color: context.colors.accent),
            title: Text(
              'Temas de color',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Personaliza los colores de la aplicación',
              style: AppTypography.bodySmall,
            ),
            trailing: Icon(Icons.chevron_right, color: context.colors.textSecondary),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ThemeSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // CARD DE COMPORTAMIENTO - MODO CONCENTRACIÓN
  // ═════════════════════════════════════════════════════════════════════════════════
  Widget _buildBehaviorCard(BuildContext context, SettingsProvider settings, RewardsProvider rewards) {
    return Card(
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            title: 'Bloqueo de aplicación',
            subtitle: 'Bloquea la salida de la app durante el pomodoro',
            value: settings.appLockMode,
            onChanged: (value) {
              if (value) {
                // Mostrar advertencia antes de activar
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: Text(
                        '🔒 Modo Concentración',
                        style: AppTypography.heading2,
                        textAlign: TextAlign.center,
                      ),
                      content: Text(
                        'Al activar este modo, no podrás salir de la aplicación mientras el pomodoro esté en ejecución.\n\nEsto te ayudará a mantener el enfoque total.\n\n¿Deseas activarlo?',
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _handleSettingChange(
                              context,
                              settings,
                              () => settings.setAppLockMode(true),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.accent,
                          ),
                          child: Text('Activar'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                _handleSettingChange(
                  context,
                  settings,
                  () => settings.setAppLockMode(false),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // CARD DE NAVEGACIÓN A ACERCA DE
  // ═════════════════════════════════════════════════════════════════════════════════
  Widget _buildAboutCard(BuildContext context, SettingsProvider settings) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.info_outline, color: context.colors.accent),
        title: Text(
          'Acerca de la app',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Versión, comentarios y contacto',
          style: AppTypography.bodySmall,
        ),
        trailing: Icon(Icons.chevron_right, color: context.colors.textSecondary),
        onTap: () {
          // Navegar a la pantalla de "Acerca de"
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AboutScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataCard(BuildContext context, SettingsProvider settings) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.refresh, color: context.colors.destructive),
            title: Text(
              'Restablecer estadísticas',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.destructive,
              ),
            ),
            subtitle: Text(
              'Borrar todos los datos de progreso',
              style: AppTypography.bodySmall,
            ),
            onTap: () {
              _showResetConfirmationDialog(context, settings);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      // Si está deshabilitado, hacer todo más transparente para que se vea claramente bloqueado
      opacity: enabled ? 1.0 : 0.4,
      child: SwitchListTile(
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: enabled ? context.colors.textPrimary : context.colors.textSecondary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: enabled ? context.colors.textSecondary : context.colors.textSecondary.withOpacity(0.5),
          ),
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: context.colors.accent,
        inactiveThumbColor: enabled ? null : context.colors.textSecondary.withOpacity(0.3),
        inactiveTrackColor: enabled ? null : context.colors.borderColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context, {
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: SizedBox(),
        dropdownColor: context.colors.cardBackground,
        style: AppTypography.bodyMedium.copyWith(
          color: context.colors.accent,
          fontWeight: FontWeight.w600,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showTimerRunningWarning(
    BuildContext context,
    SettingsProvider settings,
    VoidCallback onChange,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '⏱️ Timer en ejecución',
            style: AppTypography.heading2,
          ),
          content: Text(
            'El temporizador está en ejecución. Si cambias esta configuración, el timer se reiniciará y perderás el progreso actual.\n\n¿Deseas continuar?',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Aplicar el cambio
                onChange();

                // Resetear el timer usando el callback
                if (settings.onTimerReset != null) {
                  settings.onTimerReset!();
                }

                Navigator.of(context).pop();

                // Mostrar confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Configuración actualizada. Timer reiniciado.'),
                    backgroundColor: context.colors.accent,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.destructive,
              ),
              child: Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // DIÁLOGO ASYNC - Versión que retorna true/false para los sliders
  // ═════════════════════════════════════════════════════════════════════════════════
  // Esta versión NO llama a onTimerReset ni muestra SnackBar
  // Solo pregunta al usuario y retorna su decisión
  // Los sliders manejan el reset por su cuenta en onChangeEnd

  Future<bool?> _showTimerRunningWarningAsync(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // No permitir cerrar tocando afuera
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '⏱️ Timer en ejecución',
            style: AppTypography.heading2,
          ),
          content: Text(
            'El temporizador está en ejecución. Si cambias esta configuración, el timer se reiniciará y perderás el progreso actual.\n\n¿Deseas continuar?',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Retornar false = cancelar
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Retornar true = continuar
                // NO mostramos SnackBar aquí, se mostrará después del reset
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.destructive,
              ),
              child: Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmationDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '¿Restablecer estadísticas?',
            style: AppTypography.heading2,
          ),
          content: Text(
            'Esto borrará todos tus ciclos completados y no se puede deshacer.',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                settings.resetToDefaults();
                print('Estadísticas restablecidas');
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Estadísticas restablecidas'),
                    backgroundColor: context.colors.accent,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.destructive,
              ),
              child: Text('Restablecer'),
            ),
          ],
        );
      },
    );
  }

  void _showLockedFeatureDialog(BuildContext context, String featureName, int price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '🔒 Característica Bloqueada',
            style: AppTypography.heading2,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: context.colors.accent,
              ),
              SizedBox(height: 16),
              Text(
                '$featureName está bloqueada.',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Puedes desbloquearla en la tienda por $price puntos.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Completa sesiones de pomodoro para ganar puntos.',
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
