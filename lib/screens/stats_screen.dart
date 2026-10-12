import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/models/settings_provider.dart';
import 'package:pomodoro_app/models/rewards_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// STATS SCREEN - PANTALLA DE ESTADÍSTICAS (STITCH FOCUS FLOW)
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Replica fielmente la pantalla "Estadísticas - Stats" de Google Stitch:
// - Resumen de productividad (KPIs de foco, sesiones y racha)
// - Gráfico semanal de barras de actividad con estilo moderno
// - Desglose de distribución de tiempo y logros cercanos
// ═══════════════════════════════════════════════════════════════════════════════════

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.appBackground,
      appBar: AppBar(
        title: Text(
          'Estadísticas',
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
      body: Consumer2<SettingsProvider, RewardsProvider>(
        builder: (context, settings, rewards, child) {
          // Métricas derivadas
          final totalSessions = rewards.totalSessionsCompleted;
          final totalFocusMinutes = rewards.totalMinutesStudied > 0
              ? rewards.totalMinutesStudied
              : (totalSessions * settings.focusDuration).toInt();
          final focusHours = totalFocusMinutes ~/ 60;
          final focusRemainingMinutes = totalFocusMinutes % 60;
          final currentStreak = rewards.currentStreak;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─────────────────────────────────────────────────────────────
                // 1. TARJETAS KPI SUPERIORES (Resumen de Impacto)
                // ─────────────────────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        context: context,
                        title: 'Tiempo Total',
                        value: focusHours > 0
                            ? '${focusHours}h ${focusRemainingMinutes}m'
                            : '${totalFocusMinutes}m',
                        icon: Icons.timer_outlined,
                        iconColor: AppColors.primary,
                        badgeText: 'Foco puro',
                        badgeColor: AppColors.primarySoft,
                        badgeTextColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: _buildKpiCard(
                        context: context,
                        title: 'Racha Actual',
                        value: '$currentStreak días',
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        badgeText: currentStreak > 0 ? 'En racha' : 'Comienza hoy',
                        badgeColor: currentStreak > 0
                            ? AppColors.successSoft
                            : AppColors.muted,
                        badgeTextColor: currentStreak > 0
                            ? AppColors.success
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildKpiCard(
                  context: context,
                  title: 'Sesiones Completadas',
                  value: '$totalSessions pomodoros',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppColors.success,
                  badgeText: '${rewards.points} pts ganados',
                  badgeColor: AppColors.primarySoft,
                  badgeTextColor: AppColors.primary,
                  isFullWidth: true,
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // ─────────────────────────────────────────────────────────────
                // 2. ACTIVIDAD SEMANAL (Gráfico de Barras Stitch)
                // ─────────────────────────────────────────────────────────────
                _buildWeeklyActivityCard(context, totalSessions),

                const SizedBox(height: AppConstants.paddingLarge),

                // ─────────────────────────────────────────────────────────────
                // 3. PRÓXIMO HITO / META DE FOCO
                // ─────────────────────────────────────────────────────────────
                _buildMilestoneCard(context, totalSessions, rewards),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // WIDGETS AUXILIARES
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 8.0,
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
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  badgeText,
                  style: AppTypography.caption.copyWith(
                    color: badgeTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.heading2.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityCard(BuildContext context, int totalSessions) {
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    // Distribución proporcional para demostración visual
    final values = [
      (totalSessions > 0 ? 0.6 : 0.1),
      (totalSessions > 1 ? 0.85 : 0.2),
      (totalSessions > 2 ? 0.45 : 0.15),
      (totalSessions > 3 ? 1.0 : 0.3),
      (totalSessions > 4 ? 0.75 : 0.25),
      (totalSessions > 5 ? 0.3 : 0.1),
      (totalSessions > 6 ? 0.5 : 0.1),
    ];
    final todayIndex = (DateTime.now().weekday - 1) % 7;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 8.0,
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
              Text(
                'Actividad Semanal',
                style: AppTypography.heading3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Esta semana',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Gráfico de barras de altura fija
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final isToday = index == todayIndex;
                final heightFactor = values[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 100 * heightFactor,
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primary : AppColors.secondary,
                        borderRadius: BorderRadius.circular(8.0),
                        border: isToday
                            ? null
                            : Border.all(color: AppColors.border, width: 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: AppTypography.caption.copyWith(
                        color: isToday
                            ? AppColors.primary
                            : context.colors.textSecondary,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(
    BuildContext context,
    int totalSessions,
    RewardsProvider rewards,
  ) {
    const nextGoalSessions = 10;
    final progress = (totalSessions / nextGoalSessions).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próximo Hito: Maestro del Enfoque',
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$totalSessions de $nextGoalSessions sesiones completadas',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
