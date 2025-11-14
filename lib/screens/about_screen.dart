import 'package:flutter/material.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/screens/feedback_screen.dart';
import 'package:pomodoro_app/screens/contact_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// ABOUT SCREEN - PANTALLA DE ACERCA DE
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Muestra información sobre la aplicación:
// - Versión de la app
// - Opciones para enviar comentarios
// - Información de contacto
//
// ═══════════════════════════════════════════════════════════════════════════════════

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Versión de la app (debe coincidir con pubspec.yaml)
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Acerca de'),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          // ═══════════════════════════════════════════════════════════════════════════
          // LOGO Y NOMBRE DE LA APP
          // ═══════════════════════════════════════════════════════════════════════════
          SizedBox(height: AppConstants.paddingXLarge),
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.sky.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.timer,
                    size: 50,
                    color: AppColors.sky,
                  ),
                ),
                SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'Pomodoro Timer',
                  style: AppTypography.heading1.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'Administra tu tiempo de manera efectiva',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.paddingLarge),

          // ═══════════════════════════════════════════════════════════════════════════
          // VERSIÓN (solo muestra texto, no navega)
          // ═══════════════════════════════════════════════════════════════════════════
          Card(
            child: ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.sky),
              title: Text(
                'Versión',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '$appVersion ($buildNumber)',
                style: AppTypography.bodySmall,
              ),
            ),
          ),

          SizedBox(height: 8),

          // ═══════════════════════════════════════════════════════════════════════════
          // COMENTARIOS (navega a pantalla de comentarios)
          // ═══════════════════════════════════════════════════════════════════════════
          Card(
            child: ListTile(
              leading: Icon(Icons.feedback_outlined, color: AppColors.sky),
              title: Text(
                'Enviar comentarios',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Comparte tu opinión sobre la app',
                style: AppTypography.bodySmall,
              ),
              trailing: Icon(Icons.chevron_right, color: AppColors.mutedForeground),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FeedbackScreen(),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: AppConstants.paddingSmall),

          // ═══════════════════════════════════════════════════════════════════════════
          // CONTACTO (navega a pantalla de contacto)
          // ═══════════════════════════════════════════════════════════════════════════
          Card(
            child: ListTile(
              leading: Icon(Icons.email_outlined, color: AppColors.sky),
              title: Text(
                'Contacto',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Ponte en contacto con nosotros',
                style: AppTypography.bodySmall,
              ),
              trailing: Icon(Icons.chevron_right, color: AppColors.mutedForeground),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ContactScreen(),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: AppConstants.paddingXLarge * 2),

          // ═══════════════════════════════════════════════════════════════════════════
          // FOOTER
          // ═══════════════════════════════════════════════════════════════════════════
          Center(
            child: Text(
              '© 2025 Pomodoro Timer\nHecho con ❤️ con Flutter',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: AppConstants.paddingXLarge),
        ],
      ),
    );
  }
}
