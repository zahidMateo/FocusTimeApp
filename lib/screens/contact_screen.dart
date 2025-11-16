import 'package:flutter/material.dart';
import 'package:pomodoro_app/global/app_colors.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Contacto'),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          // ═══════════════════════════════════════════════════════════════════════════
          // DESCRIPCIÓN
          // ═══════════════════════════════════════════════════════════════════════════
          Card(
            color: AppColors.sky.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                children: [
                  Icon(Icons.support_agent, color: AppColors.sky),
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
            color: AppColors.card,
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: AppColors.sky, size: 20),
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
                      color: AppColors.mutedForeground,
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
            color: AppColors.card,
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: AppColors.sky, size: 20),
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
                      color: AppColors.mutedForeground,
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.sky),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall,
        ),
        trailing: Icon(Icons.open_in_new, color: AppColors.mutedForeground, size: 20),
        onTap: onTap,
      ),
    );
  }
}
