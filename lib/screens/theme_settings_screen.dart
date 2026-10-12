import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/global/app_color_themes.dart';
import 'package:pomodoro_app/models/settings_provider.dart';
import 'package:pomodoro_app/models/rewards_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// THEME SETTINGS SCREEN - TEMAS DE COLOR (STITCH FOCUS FLOW)
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
            'description': 'Azul cobalto y cielo de enfoque',
            'colors': {
              'primary': AppColorThemes.defaultPrimary,
              'accent': AppColorThemes.defaultAccent,
            },
            'locked': false,
          },
          {
            'id': 'ocean',
            'name': 'Océano',
            'description': 'Azules y turquesas relajantes',
            'colors': {
              'primary': AppColorThemes.oceanPrimary,
              'accent': AppColorThemes.oceanAccent,
            },
            'locked': !rewards.isItemPurchased('theme_ocean'),
            'price': 150,
          },
          {
            'id': 'forest',
            'name': 'Bosque',
            'description': 'Verdes naturales y frescos',
            'colors': {
              'primary': AppColorThemes.forestPrimary,
              'accent': AppColorThemes.forestAccent,
            },
            'locked': !rewards.isItemPurchased('theme_forest'),
            'price': 150,
          },
          {
            'id': 'sunset',
            'name': 'Atardecer',
            'description': 'Naranjas y rosas cálidos',
            'colors': {
              'primary': AppColorThemes.sunsetPrimary,
              'accent': AppColorThemes.sunsetAccent,
            },
            'locked': !rewards.isItemPurchased('theme_sunset'),
            'price': 150,
          },
          {
            'id': 'lavender',
            'name': 'Lavanda',
            'description': 'Morados y lilas suaves',
            'colors': {
              'primary': AppColorThemes.lavenderPrimary,
              'accent': AppColorThemes.lavenderAccent,
            },
            'locked': !rewards.isItemPurchased('theme_lavender'),
            'price': 150,
          },
        ];

        return Scaffold(
          backgroundColor: context.colors.appBackground,
          appBar: AppBar(
            title: Text(
              'Temas de Color',
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
              Text(
                'Personaliza los colores de acento y botones de la aplicación',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingLarge),

              ...themes.map((theme) {
                final isSelected = settings.selectedTheme == theme['id'];
                final isLocked = theme['locked'] as bool;
                final colors = theme['colors'] as Map<String, Color>;
                final price = theme['price'] as int?;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySoft
                        : context.colors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(15, 23, 42, 0.03),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
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
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(15, 23, 42, 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colors['accent'],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(15, 23, 42, 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            theme['name'] as String,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isLocked
                                  ? AppColors.mutedForeground
                                  : isSelected
                                  ? AppColors.primary
                                  : context.colors.textPrimary,
                            ),
                          ),
                        ),
                        if (isLocked && price != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 13,
                                  color: AppColors.mutedForeground,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$price pts',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.mutedForeground,
                                    fontWeight: FontWeight.w600,
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
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 22,
                          )
                        : null,
                    onTap: () {
                      if (isLocked) {
                        _showLockedThemeDialog(
                          context,
                          theme['name'] as String,
                          theme['price'] as int,
                        );
                      } else {
                        settings.setSelectedTheme(theme['id'] as String);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tema ${theme['name']} aplicado'),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showLockedThemeDialog(
    BuildContext context,
    String themeName,
    int price,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Tema Bloqueado',
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
                Icons.palette_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$themeName está bloqueado.',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Desbloquea este tema en la tienda por $price puntos.',
              style: AppTypography.bodyMedium,
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
      ),
    );
  }
}
