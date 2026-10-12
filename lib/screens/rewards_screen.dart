import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/models/rewards_provider.dart';
import 'package:pomodoro_app/models/settings_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// REWARDS SCREEN - RECOMPENSAS Y TIENDA (STITCH FOCUS FLOW)
// ═══════════════════════════════════════════════════════════════════════════════════

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.appBackground,
      appBar: AppBar(
        title: Text(
          'Recompensas',
          style: AppTypography.heading2,
        ),
        backgroundColor: context.colors.cardBackground,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49.0),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.mutedForeground,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelStyle: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                unselectedLabelStyle: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.emoji_events_outlined, size: 20),
                    text: 'Logros',
                  ),
                  Tab(
                    icon: Icon(Icons.storefront_outlined, size: 20),
                    text: 'Tienda',
                  ),
                ],
              ),
              Container(
                color: AppColors.border,
                height: 1.0,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AchievementsTab(),
          StoreTab(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// ACHIEVEMENTS TAB - PESTAÑA DE LOGROS
// ═══════════════════════════════════════════════════════════════════════════════════

class AchievementsTab extends StatelessWidget {
  const AchievementsTab({super.key});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'timer':
        return Icons.timer_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'book':
        return Icons.menu_book_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'checklist':
        return Icons.checklist_rounded;
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      default:
        return Icons.emoji_events_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RewardsProvider>(
      builder: (context, rewards, child) {
        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingMedium,
          ),
          children: [
            // Resumen de estadísticas de recompensas
            _buildStatsCard(context, rewards),
            const SizedBox(height: AppConstants.paddingLarge),

            // Encabezado
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.military_tech_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tus Logros',
                    style: AppTypography.heading3.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de logros
            ...rewards.achievements.map(
              (achievement) => _buildAchievementCard(
                context,
                achievement: achievement,
                iconData: _getIconData(achievement.icon),
              ),
            ),
            const SizedBox(height: AppConstants.paddingXLarge),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(BuildContext context, RewardsProvider rewards) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: Icons.emoji_events_rounded,
            iconBg: AppColors.primarySoft,
            iconColor: AppColors.primary,
            label: 'Logros',
            value:
                '${rewards.unlockedAchievementsCount}/${rewards.totalAchievementsCount}',
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.border,
          ),
          _buildStatItem(
            context,
            icon: Icons.star_rounded,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            label: 'Puntos',
            value: '${rewards.points}',
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.border,
          ),
          _buildStatItem(
            context,
            icon: Icons.local_fire_department_rounded,
            iconBg: const Color(0xFFFFEDD5),
            iconColor: const Color(0xFFEA580C),
            label: 'Racha',
            value: '${rewards.currentStreak} d',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.heading2.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context, {
    required Achievement achievement,
    required IconData iconData,
  }) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? AppColors.border
              : AppColors.border.withValues(alpha: 0.6),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono del logro
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.primarySoft
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: isUnlocked
                  ? AppColors.primary
                  : AppColors.mutedForeground,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Información del logro
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? context.colors.textPrimary
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge de puntos
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppColors.successSoft
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        '+${achievement.points} pts',
                        style: AppTypography.bodySmall.copyWith(
                          color: isUnlocked
                              ? AppColors.success
                              : AppColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Indicador de completado
          if (isUnlocked)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 22,
            )
          else
            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.mutedForeground,
              size: 20,
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// STORE TAB - PESTAÑA DE TIENDA
// ═══════════════════════════════════════════════════════════════════════════════════

class StoreTab extends StatelessWidget {
  const StoreTab({super.key});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'dark_mode':
        return Icons.dark_mode_outlined;
      case 'palette':
        return Icons.palette_outlined;
      case 'cloud':
        return Icons.water_drop_outlined;
      case 'park':
        return Icons.park_outlined;
      case 'coffee':
        return Icons.local_cafe_outlined;
      case 'menu_book':
        return Icons.menu_book_rounded;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RewardsProvider>(
      builder: (context, rewards, child) {
        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingMedium,
          ),
          children: [
            // Encabezado con puntos disponibles (Gradient Stitch Cobalt)
            _buildPointsCard(context, rewards),
            const SizedBox(height: AppConstants.paddingLarge),

            // Título de la sección
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.store_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Artículos Disponibles',
                    style: AppTypography.heading3.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de items de la tienda
            ...rewards.storeItems.map(
              (item) => _buildStoreItem(
                context,
                rewards,
                item: item,
                iconData: _getIconData(item.icon),
              ),
            ),
            const SizedBox(height: AppConstants.paddingXLarge),
          ],
        );
      },
    );
  }

  Widget _buildPointsCard(BuildContext context, RewardsProvider rewards) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1D4ED8),
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo Disponible',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFDE047),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${rewards.points}',
                    style: AppTypography.heading1.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'puntos',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItem(
    BuildContext context,
    RewardsProvider rewards, {
    required StoreItem item,
    required IconData iconData,
  }) {
    final hasEnoughPoints = rewards.points >= item.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono del item
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),

          // Información del item
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Botón de compra o indicador de comprado
          if (item.isPurchased)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Comprado',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: hasEnoughPoints
                  ? () => _showPurchaseDialog(context, rewards, item)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasEnoughPoints
                    ? AppColors.primary
                    : const Color(0xFFF1F5F9),
                foregroundColor: hasEnoughPoints
                    ? Colors.white
                    : AppColors.mutedForeground,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: hasEnoughPoints
                        ? const Color(0xFFFDE047)
                        : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.price}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: hasEnoughPoints
                          ? Colors.white
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(
    BuildContext context,
    RewardsProvider rewards,
    StoreItem item,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Confirmar Compra',
          style: AppTypography.heading2,
          textAlign: TextAlign.center,
        ),
        content: Text(
          '¿Quieres desbloquear "${item.title}" por ${item.price} puntos?',
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await rewards.purchaseItem(item.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              if (success) {
                if (context.mounted) {
                  _applyPurchasedItem(context, item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡${item.title} comprado con éxito!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No tienes suficientes puntos'),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }

  void _applyPurchasedItem(BuildContext context, String itemId) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    switch (itemId) {
      case 'dark_mode':
        settings.setDarkModeEnabled(true);
        break;
      case 'sound_rain':
      case 'sound_forest':
      case 'sound_cafe':
      case 'sound_library':
        break;
      case 'theme_ocean':
      case 'theme_forest':
      case 'theme_sunset':
      case 'theme_lavender':
        break;
      default:
        break;
    }
  }
}
