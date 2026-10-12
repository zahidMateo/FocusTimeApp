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
// SETTINGS SCREEN - PANTALLA DE CONFIGURACIONES (STITCH FOCUS FLOW)
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Esta pantalla permite al usuario personalizar TODA la app siguiendo el sistema
// de diseño Focus Flow de Stitch:
// - Tarjetas con bordes de 1px (#E2E8F0) y radio de 16px
// - Iconografía moderna vectorial en contenedores circulares/redondeados con fondo azul suave (#EFF6FF)
// - Tipografía Outfit para encabezados y Inter para cuerpos y etiquetas
// - Conserva el 100% de las funcionalidades, configuraciones, validaciones y lógica
// ═══════════════════════════════════════════════════════════════════════════════════

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, RewardsProvider>(
      builder: (context, settings, rewards, child) {
        return Scaffold(
          backgroundColor: context.colors.appBackground,
          appBar: AppBar(
            title: Text(
              'Configuración',
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
          body: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingMedium,
            ),
            children: [
              _buildSectionHeader(context, 'Tiempos', Icons.timer_outlined),
              _buildTimeNavigationCard(context, settings),
              const SizedBox(height: AppConstants.paddingLarge),

              _buildSectionHeader(
                context,
                'Notificaciones',
                Icons.notifications_outlined,
              ),
              _buildNotificationsCard(context, settings),
              const SizedBox(height: AppConstants.paddingLarge),

              _buildSectionHeader(context, 'Sonido', Icons.volume_up_outlined),
              _buildSoundCard(context, settings),
              const SizedBox(height: AppConstants.paddingLarge),

              _buildSectionHeader(
                context,
                'Apariencia',
                Icons.palette_outlined,
              ),
              _buildAppearanceCard(context, settings, rewards),
              const SizedBox(height: AppConstants.paddingLarge),

              _buildSectionHeader(
                context,
                'Modo Concentración',
                Icons.lock_outline_rounded,
              ),
              _buildBehaviorCard(context, settings),
              const SizedBox(height: AppConstants.paddingLarge),

              _buildSectionHeader(context, 'Acerca de', Icons.info_outline),
              _buildAboutCard(context),
              const SizedBox(height: AppConstants.paddingLarge),

              _buildSectionHeader(
                context,
                'Datos',
                Icons.delete_outline_rounded,
                isDestructive: true,
              ),
              _buildDataCard(context, settings),
              const SizedBox(height: AppConstants.paddingXLarge * 2),
            ],
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // ENCABEZADO DE SECCIÓN (STITCH FOCUS FLOW - SIN EMOJIS)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppColors.destructive
        : context.colors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(
        left: 4.0,
        bottom: 8.0,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTypography.heading3.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDestructive
                  ? AppColors.destructive
                  : context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // CONTENEDOR DE TARJETA ESTILO STITCH (16px radio, 1px borde #E2E8F0)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildGroupCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // CARD DE NAVEGACIÓN A CONFIGURACIÓN DE TIEMPOS
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildTimeNavigationCard(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return _buildGroupCard(
      context: context,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: _buildLeadingIcon(Icons.timer_outlined),
          title: Text(
            'Configurar duraciones',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Trabajo: ${settings.focusDuration.toInt()}m  •  Descanso: ${settings.shortBreakDuration.toInt()}m / ${settings.longBreakDuration.toInt()}m',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mutedForeground,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TimeSettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // CARD DE NOTIFICACIONES Y VIBRACIÓN
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildNotificationsCard(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return _buildGroupCard(
      context: context,
      children: [
        _buildSwitchTile(
          context,
          icon: Icons.notifications_active_outlined,
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
        _buildDivider(),
        _buildSwitchTile(
          context,
          icon: Icons.vibration_rounded,
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
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // CARD DE SONIDO Y SONIDOS AMBIENTALES
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildSoundCard(BuildContext context, SettingsProvider settings) {
    return _buildGroupCard(
      context: context,
      children: [
        _buildSwitchTile(
          context,
          icon: Icons.volume_up_outlined,
          title: 'Sonidos ambientales',
          subtitle: 'Reproducir sonidos mientras el timer está activo',
          value: settings.soundEnabled,
          onChanged: (value) {
            _handleSettingChange(
              context,
              settings,
              () => settings.setSoundEnabled(value),
            );
          },
        ),
        if (settings.soundEnabled) ...[
          _buildDivider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: _buildLeadingIcon(Icons.music_note_outlined),
            title: Text(
              'Configurar sonido ambiental',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Actual: ${settings.selectedSound}  •  Volumen: ${(settings.soundVolume * 100).toInt()}%',
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedForeground,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SoundSettingsScreen()),
              );
            },
          ),
        ],
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // CARD DE APARIENCIA - TEMA OSCURO Y COLORES
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildAppearanceCard(
    BuildContext context,
    SettingsProvider settings,
    RewardsProvider rewards,
  ) {
    final darkModeUnlocked = rewards.isItemPurchased('dark_mode');

    return _buildGroupCard(
      context: context,
      children: [
        _buildSwitchTile(
          context,
          icon: Icons.dark_mode_outlined,
          title: 'Tema oscuro',
          subtitle: darkModeUnlocked
              ? 'Usar tema oscuro en la aplicación'
              : 'Bloqueado en la tienda (100 puntos)',
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
        _buildDivider(),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: _buildLeadingIcon(Icons.palette_outlined),
          title: Text(
            'Temas de color',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Personaliza los colores de la aplicación',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mutedForeground,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // CARD DE MODO CONCENTRACIÓN (BLOQUEO DE APP)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildBehaviorCard(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return _buildGroupCard(
      context: context,
      children: [
        _buildSwitchTile(
          context,
          icon: Icons.lock_outline_rounded,
          title: 'Bloqueo de aplicación',
          subtitle: 'Bloquea la salida de la app durante el pomodoro',
          value: settings.appLockMode,
          onChanged: (value) {
            if (value) {
              _showFocusModeConfirmDialog(context, settings);
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
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // CARD DE NAVEGACIÓN A ACERCA DE
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildAboutCard(BuildContext context) {
    return _buildGroupCard(
      context: context,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: _buildLeadingIcon(Icons.info_outline_rounded),
          title: Text(
            'Acerca de la app',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Versión, comentarios y contacto',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mutedForeground,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          },
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // CARD DE RESTABLECER DATOS (ACCIÓN DESTRUCTIVA)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildDataCard(BuildContext context, SettingsProvider settings) {
    return _buildGroupCard(
      context: context,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.destructiveSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.destructive,
              size: 20,
            ),
          ),
          title: Text(
            'Restablecer estadísticas',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.destructive,
            ),
          ),
          subtitle: Text(
            'Borrar todos los datos de progreso',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mutedForeground,
          ),
          onTap: () {
            _showResetConfirmationDialog(context, settings);
          },
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // COMPONENTES REUTILIZABLES
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildLeadingIcon(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
      indent: 68,
      endIndent: 16,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        secondary: _buildLeadingIcon(icon),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: enabled
                ? context.colors.textPrimary
                : context.colors.textSecondary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // MÉTODO DE VALIDACIÓN CENTRAL
  // ═════════════════════════════════════════════════════════════════════════════
  void _handleSettingChange(
    BuildContext context,
    SettingsProvider settings,
    VoidCallback onChange,
  ) {
    if (settings.isTimerRunning) {
      _showTimerRunningWarning(context, settings, onChange);
    } else {
      onChange();
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // DIÁLOGOS DE CONFIRMACIÓN CON ESTILO STITCH
  // ═════════════════════════════════════════════════════════════════════════════

  void _showFocusModeConfirmDialog(
    BuildContext context,
    SettingsProvider settings,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Modo Concentración',
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: context.colors.textSecondary),
              ),
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Activar'),
            ),
          ],
        );
      },
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Timer en ejecución',
            style: AppTypography.heading2,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'El temporizador está en ejecución. Si cambias esta configuración, el timer se reiniciará y perderás el progreso actual.\n\n¿Deseas continuar?',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onChange();
                if (settings.onTimerReset != null) {
                  settings.onTimerReset!();
                }
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuración actualizada. Timer reiniciado.'),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmationDialog(
    BuildContext context,
    SettingsProvider settings,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '¿Restablecer estadísticas?',
            style: AppTypography.heading2,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Esto borrará todos tus ciclos completados y no se puede deshacer.',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                settings.resetToDefaults();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Estadísticas restablecidas'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Restablecer'),
            ),
          ],
        );
      },
    );
  }

  void _showLockedFeatureDialog(
    BuildContext context,
    String featureName,
    int price,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Característica Bloqueada',
            style: AppTypography.heading2,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$featureName está bloqueada.',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Puedes desbloquearla en la tienda por $price puntos.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Completa sesiones de pomodoro para ganar puntos.',
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
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }
}
