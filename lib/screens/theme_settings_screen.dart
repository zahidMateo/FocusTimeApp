import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/global/app_color_themes.dart';
import 'package:pomodoro_app/models/settings_provider.dart';
import 'package:pomodoro_app/models/rewards_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// THEME SETTINGS SCREEN - CONFIGURACIÓN DE TEMAS DE COLOR
// ═══════════════════════════════════════════════════════════════════════════════════

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, RewardsProvider>(
      builder: (context, settings, rewards, child) {
        final themes = [
          {
            'id': 'default',
            'name': 'Por Defecto',
            'description': 'Azul clásico',
            'colors': {'primary': AppColorThemes.defaultPrimary, 'accent': AppColorThemes.defaultAccent},
            'locked': false,
          },
          {
            'id': 'ocean',
            'name': 'Océano',
            'description': 'Azules y turquesas relajantes',
            'colors': {'primary': AppColorThemes.oceanPrimary, 'accent': AppColorThemes.oceanAccent},
            'locked': !rewards.isItemPurchased('theme_ocean'),
            'price': 150,
          },
          {
            'id': 'forest',
            'name': 'Bosque',
            'description': 'Verdes naturales y frescos',
            'colors': {'primary': AppColorThemes.forestPrimary, 'accent': AppColorThemes.forestAccent},
            'locked': !rewards.isItemPurchased('theme_forest'),
            'price': 150,
          },
          {
            'id': 'sunset',
            'name': 'Atardecer',
            'description': 'Naranjas y rosas cálidos',
            'colors': {'primary': AppColorThemes.sunsetPrimary, 'accent': AppColorThemes.sunsetAccent},
            'locked': !rewards.isItemPurchased('theme_sunset'),
            'price': 150,
          },
          {
            'id': 'lavender',
            'name': 'Lavanda',
            'description': 'Morados y lilas suaves',
            'colors': {'primary': AppColorThemes.lavenderPrimary, 'accent': AppColorThemes.lavenderAccent},
            'locked': !rewards.isItemPurchased('theme_lavender'),
            'price': 150,
          },
        ];

        return Scaffold(
          backgroundColor: context.colors.appBackground,
          appBar: AppBar(
            title: Text('Temas de Color'),
            backgroundColor: context.colors.cardBackground,
            elevation: 0,
          ),
          body: ListView(
            padding: EdgeInsets.all(AppConstants.paddingMedium),
            children: [
              // Descripción
              Padding(
                padding: EdgeInsets.only(bottom: AppConstants.paddingLarge),
                child: Text(
                  'Personaliza los colores de la aplicación',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),

              // Lista de temas
              ...themes.map((theme) {
                final isSelected = settings.selectedTheme == theme['id'];
                final isLocked = theme['locked'] as bool;
                final colors = theme['colors'] as Map<String, Color>;

                return Card(
                  margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
                  color: isSelected
                      ? context.colors.accent.withOpacity(0.1)
                      : context.colors.cardBackground,
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colors['primary'],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.colors.borderColor,
                              width: 1,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colors['accent'],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.colors.borderColor,
                              width: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            theme['name'] as String,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? context.colors.accent
                                  : context.colors.textPrimary,
                            ),
                          ),
                        ),
                        if (isLocked) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.colors.textSecondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_outline,
                                    size: 12, color: context.colors.textSecondary),
                                SizedBox(width: 4),
                                Text(
                                  '${theme['price']}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: context.colors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      theme['description'] as String,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: context.colors.accent)
                        : null,
                    onTap: () {
                      if (isLocked) {
                        _showLockedThemeDialog(context, theme['name'] as String,
                            theme['price'] as int);
                      } else {
                        settings.setSelectedTheme(theme['id'] as String);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tema ${theme['name']} aplicado'),
                            backgroundColor: context.colors.accent,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showLockedThemeDialog(BuildContext context, String themeName, int price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '🔒 Tema Bloqueado',
          style: AppTypography.heading2,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.palette, size: 64, color: context.colors.accent),
            SizedBox(height: 16),
            Text(
              '$themeName está bloqueado.',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Desbloquea este tema en la tienda por $price puntos.',
              style: AppTypography.bodyMedium,
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
      ),
    );
  }
}
