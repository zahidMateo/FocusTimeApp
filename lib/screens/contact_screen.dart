import 'package:flutter/material.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// CONTACT SCREEN - PANTALLA DE CONTACTO
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Muestra información de contacto de la app
//
// ═══════════════════════════════════════════════════════════════════════════════════

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  // Información de contacto (personaliza según tu información)
  static const String supportEmail = 'soporte@pomodoroapp.com';
  static const String websiteUrl = 'www.pomodoroapp.com';
  static const String twitterHandle = '@PomodoroApp';
  static const String githubUrl = 'github.com/tuusuario/pomodoro-app';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.appBackground,
      appBar: AppBar(
        title: Text('Contacto'),
        backgroundColor: context.colors.cardBackground,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          // ═══════════════════════════════════════════════════════════════════════════
          // DESCRIPCIÓN
          // ═══════════════════════════════════════════════════════════════════════════
          Card(
            color: context.colors.accent.withValues(alpha: 0.1),
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                children: [
                  Icon(Icons.support_agent, color: context.colors.accent),
                  SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: Text(
                      '¿Necesitas ayuda? Estamos aquí para ti',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: AppConstants.paddingLarge),

          // ═══════════════════════════════════════════════════════════════════════════
          // EMAIL DE SOPORTE
          // ═══════════════════════════════════════════════════════════════════════════
          _buildContactCard(
            context,
            icon: Icons.email_outlined,
            title: 'Email de soporte',
            subtitle: supportEmail,
            onTap: () {
              // TODO: Abrir cliente de email
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Email copiado: $supportEmail'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),

          SizedBox(height: AppConstants.paddingSmall),

          // ═══════════════════════════════════════════════════════════════════════════
          // TWITTER/X
          // ═══════════════════════════════════════════════════════════════════════════
          _buildContactCard(
            context,
            icon: Icons.share,
            title: 'Twitter / X',
            subtitle: twitterHandle,
            onTap: () {
              // TODO: Abrir Twitter
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Twitter: $twitterHandle'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),

          SizedBox(height: AppConstants.paddingXLarge),

          // ═══════════════════════════════════════════════════════════════════════════
          // HORARIO DE ATENCIÓN
          // ═══════════════════════════════════════════════════════════════════════════
          Card(
            color: context.colors.cardBackground,
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: context.colors.accent,
                        size: 20,
                      ),
                      SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        'Horario de atención',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Lunes a Viernes: 9:00 AM - 6:00 PM\nSábados: 10:00 AM - 2:00 PM\nDomingos: Cerrado',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: AppConstants.paddingSmall),

          // ═══════════════════════════════════════════════════════════════════════════
          // TIEMPO DE RESPUESTA
          // ═══════════════════════════════════════════════════════════════════════════
          Card(
            color: context.colors.cardBackground,
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: context.colors.accent,
                        size: 20,
                      ),
                      SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        'Tiempo de respuesta',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Generalmente respondemos en menos de 24 horas',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: context.colors.accent),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: AppTypography.bodySmall),
        trailing: Icon(
          Icons.open_in_new,
          color: context.colors.textSecondary,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
