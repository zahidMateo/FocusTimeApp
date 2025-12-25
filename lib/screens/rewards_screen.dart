import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/models/rewards_provider.dart';
import 'package:pomodoro_app/models/settings_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// REWARDS SCREEN - PANTALLA DE RECOMPENSAS (LOGROS Y TIENDA)
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
      appBar: AppBar(
        title: Text('Recompensas'),
        backgroundColor: context.colors.cardBackground,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.textSecondary,
          indicatorColor: context.colors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTypography.bodyLarge,
          tabs: [
            Tab(icon: Icon(Icons.emoji_events_outlined), text: 'Logros'),
            Tab(icon: Icon(Icons.store_outlined), text: 'Tienda'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
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
        return Icons.timer;
      case 'school':
        return Icons.school;
      case 'book':
        return Icons.book;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'checklist':
        return Icons.checklist;
      case 'emoji_events':
        return Icons.emoji_events;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RewardsProvider>(
      builder: (context, rewards, child) {
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Encabezado con estadísticas
            _buildStatsCard(context, rewards),
            SizedBox(height: 20),

            // Título de la sección
            Text('Tus Logros', style: AppTypography.heading2),
            SizedBox(height: 12),

            // Lista de logros
            ...rewards.achievements.map((achievement) => _buildAchievementCard(
                  context,
                  achievement: achievement,
                  iconData: _getIconData(achievement.icon),
                )),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(BuildContext context, RewardsProvider rewards) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: Icons.emoji_events,
            label: 'Logros',
            value: '${rewards.unlockedAchievementsCount}/${rewards.totalAchievementsCount}',
          ),
          _buildStatItem(
            context,
            icon: Icons.star,
            label: 'Puntos',
            value: '${rewards.points}',
          ),
          _buildStatItem(
            context,
            icon: Icons.local_fire_department,
            label: 'Racha',
            value: '${rewards.currentStreak}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: context.colors.primary, size: 32),
        SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.heading2.copyWith(color: context.colors.primary),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
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
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? context.colors.cardBackground
            : context.colors.appBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked
              ? AppColors.primary.withOpacity(0.3)
              : context.colors.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ícono del logro
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? context.colors.primary.withOpacity(0.2)
                  : context.colors.textSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: achievement.isUnlocked
                  ? context.colors.primary
                  : context.colors.textSecondary,
              size: 32,
            ),
          ),
          SizedBox(width: 16),

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
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: achievement.isUnlocked
                              ? context.colors.textPrimary
                              : context.colors.textSecondary,
                        ),
                      ),
                    ),
                    // Badge de puntos
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked
                            ? context.colors.accent
                            : context.colors.textSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star,
                              size: 14,
                              color: achievement.isUnlocked
                                  ? Colors.white
                                  : context.colors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            '+${achievement.points}',
                            style: AppTypography.bodySmall.copyWith(
                              color: achievement.isUnlocked
                                  ? Colors.white
                                  : context.colors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Indicador de desbloqueado
          if (achievement.isUnlocked)
            Icon(Icons.check_circle, color: context.colors.primary, size: 24)
          else
            Icon(Icons.lock_outline,
                color: context.colors.textSecondary, size: 24),
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
        return Icons.dark_mode;
      case 'palette':
        return Icons.palette;
      case 'cloud':
        return Icons.cloud;
      case 'park':
        return Icons.park;
      case 'coffee':
        return Icons.coffee;
      case 'menu_book':
        return Icons.menu_book;
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RewardsProvider>(
      builder: (context, rewards, child) {
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Encabezado con puntos disponibles
            _buildPointsCard(context, rewards),
            SizedBox(height: 20),

            // Título de la sección
            Text('Artículos Disponibles', style: AppTypography.heading2),
            SizedBox(height: 12),

            // Lista de items de la tienda
            ...rewards.storeItems.map((item) => _buildStoreItem(
                  context,
                  rewards,
                  item: item,
                  iconData: _getIconData(item.icon),
                )),
          ],
        );
      },
    );
  }

  Widget _buildPointsCard(BuildContext context, RewardsProvider rewards) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primary, context.colors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
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
                'Tus Puntos',
                style: AppTypography.bodyLarge.copyWith(color: Colors.white70),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.white, size: 32),
                  SizedBox(width: 8),
                  Text(
                    '${rewards.points}',
                    style: AppTypography.heading1.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          Icon(Icons.account_balance_wallet, color: Colors.white70, size: 48),
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
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ícono del item
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: context.colors.primary, size: 32),
          ),
          SizedBox(width: 16),

          // Información del item
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),

          // Botón de compra o indicador de comprado
          item.isPurchased
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 16, color: context.colors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Comprado',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: hasEnoughPoints
                      ? () => _showPurchaseDialog(context, rewards, item)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasEnoughPoints ? context.colors.accent : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${item.price}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(
      BuildContext context, RewardsProvider rewards, StoreItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Confirmar Compra', style: AppTypography.heading2),
        content:
            Text('¿Quieres comprar "${item.title}" por ${item.price} puntos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await rewards.purchaseItem(item.id);
              Navigator.pop(dialogContext);

              if (success) {
                // Aplicar el item comprado inmediatamente
                _applyPurchasedItem(context, item.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡${item.title} comprado!'),
                      backgroundColor: context.colors.accent,
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al comprar el item'),
                      backgroundColor: context.colors.destructive,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.accent),
            child: Text('Comprar'),
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
      // Los sonidos individuales se desbloquean automáticamente
      case 'sound_rain':
      case 'sound_forest':
      case 'sound_cafe':
      case 'sound_library':
        // No hacen nada aquí, solo desbloquean en sound_settings_screen
        break;
      // Los temas de color se aplicarán después
      case 'theme_ocean':
      case 'theme_forest':
      case 'theme_sunset':
      case 'theme_lavender':
        // Por ahora no hacen nada, se implementarán después
        break;
      default:
        break;
    }
  }
}
