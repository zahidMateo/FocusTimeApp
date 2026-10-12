import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/models/settings_provider.dart';
import 'package:pomodoro_app/models/rewards_provider.dart';
import 'package:pomodoro_app/services/audio_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// SOUND SETTINGS SCREEN - CONFIGURACIÓN DE SONIDOS (STITCH FOCUS FLOW)
// ═══════════════════════════════════════════════════════════════════════════════════

class SoundSettingsScreen extends StatefulWidget {
  const SoundSettingsScreen({super.key});

  @override
  State<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends State<SoundSettingsScreen> {
  String _selectedSound = 'Ninguno';
  double _soundVolume = 0.7;
  bool _isPreviewPlaying = false;

  final List<Map<String, dynamic>> _freeSounds = [
    {'name': 'Ninguno', 'icon': Icons.volume_off_rounded, 'premium': false},
    {'name': 'Ruido blanco', 'icon': Icons.waves_rounded, 'premium': false},
    {'name': 'Ruido marrón', 'icon': Icons.water_rounded, 'premium': false},
    {'name': 'Ruido rosa', 'icon': Icons.grain_rounded, 'premium': false},
  ];

  final List<Map<String, dynamic>> _premiumSounds = [
    {
      'name': 'Lluvia',
      'icon': Icons.water_drop_outlined,
      'premium': true,
      'itemId': 'sound_rain',
      'price': 75,
    },
    {
      'name': 'Bosque',
      'icon': Icons.park_outlined,
      'premium': true,
      'itemId': 'sound_forest',
      'price': 75,
    },
    {
      'name': 'Café',
      'icon': Icons.local_cafe_outlined,
      'premium': true,
      'itemId': 'sound_cafe',
      'price': 75,
    },
    {
      'name': 'Biblioteca',
      'icon': Icons.menu_book_rounded,
      'premium': true,
      'itemId': 'sound_library',
      'price': 75,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      setState(() {
        _selectedSound = settings.selectedSound;
        _soundVolume = settings.soundVolume;
      });
    });
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  void _previewSound(String soundName) async {
    if (soundName == 'Ninguno') {
      _stopPreview();
      return;
    }

    setState(() {
      _isPreviewPlaying = true;
    });

    final success = await AudioService.playPreview(
      soundName,
      volume: _soundVolume,
      durationSeconds: 5,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo reproducir el sonido'),
          backgroundColor: AppColors.destructive,
        ),
      );
    }

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isPreviewPlaying = false;
        });
      }
    });
  }

  void _stopPreview() {
    AudioService.stopImmediately();
    setState(() {
      _isPreviewPlaying = false;
    });
  }

  void _saveChanges() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    if (settings.isTimerRunning) {
      _showTimerRunningWarning();
    } else {
      _applyChanges();
      Navigator.of(context).pop();
    }
  }

  void _applyChanges() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.setSelectedSound(_selectedSound);
    settings.setSoundVolume(_soundVolume);

    _stopPreview();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración de sonido guardada'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showTimerRunningWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Timer en ejecución',
          textAlign: TextAlign.center,
          style: AppTypography.heading2,
        ),
        content: Text(
          'El timer está corriendo. Si guardas estos cambios, se reiniciará.\n\n¿Deseas continuar?',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium,
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
              Navigator.of(context).pop();
              _applyChangesAndReset();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _applyChangesAndReset() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _applyChanges();
    settings.onTimerReset?.call();
  }

  Widget _buildSoundCard(Map<String, dynamic> sound, bool isLocked) {
    final isSelected = _selectedSound == sound['name'];
    final price = sound['price'] as int?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySoft : context.colors.cardBackground,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : isLocked
                ? const Color(0xFFF1F5F9)
                : AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            sound['icon'] as IconData,
            color: isLocked
                ? AppColors.mutedForeground
                : AppColors.primary,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                sound['name'] as String,
                style: AppTypography.bodyMedium.copyWith(
                  color: isLocked
                      ? AppColors.mutedForeground
                      : isSelected
                      ? AppColors.primary
                      : context.colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isLocked && price != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        trailing: isSelected
            ? const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 22,
              )
            : null,
        onTap: () {
          if (isLocked) {
            _showLockedSoundDialog(sound['name'] as String, price ?? 0);
          } else {
            setState(() {
              _selectedSound = sound['name'] as String;
            });
            _previewSound(sound['name'] as String);
          }
        },
      ),
      ),
    );
  }

  void _showLockedSoundDialog(String soundName, int price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Sonido Bloqueado',
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
                Icons.music_note_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$soundName está bloqueado.',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Desbloquea este sonido en la tienda por $price puntos.',
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

  @override
  Widget build(BuildContext context) {
    final rewards = Provider.of<RewardsProvider>(context);

    return Scaffold(
      backgroundColor: context.colors.appBackground,
      appBar: AppBar(
        title: Text(
          'Sonidos ambientales',
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingMedium,
              ),
              children: [
                // Sonidos Gratuitos
                Text(
                  'Sonidos Gratuitos',
                  style: AppTypography.heading3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._freeSounds.map((sound) => _buildSoundCard(sound, false)),

                const SizedBox(height: AppConstants.paddingLarge),

                // Sonidos Premium
                Text(
                  'Sonidos Premium',
                  style: AppTypography.heading3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._premiumSounds.map((sound) {
                  final itemId = sound['itemId'] as String;
                  final isUnlocked = rewards.isItemPurchased(itemId);
                  return _buildSoundCard(sound, !isUnlocked);
                }),

                const SizedBox(height: AppConstants.paddingLarge),

                // Control de Volumen
                Container(
                  padding: const EdgeInsets.all(16.0),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Volumen del sonido',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              '${(_soundVolume * 100).toInt()}%',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.volume_down_rounded,
                            color: AppColors.mutedForeground,
                            size: 20,
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: AppColors.border,
                                thumbColor: AppColors.primary,
                                overlayColor: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: _soundVolume,
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                onChanged: (value) {
                                  setState(() {
                                    _soundVolume = value;
                                  });
                                  if (_isPreviewPlaying) {
                                    AudioService.setVolume(value);
                                  }
                                },
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.volume_up_rounded,
                            color: AppColors.mutedForeground,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          ),

          // Botón Guardar cambios tipo Pill de Stitch (52px)
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: context.colors.cardBackground,
              border: const Border(
                top: BorderSide(color: AppColors.border, width: 1.0),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(15, 23, 42, 0.03),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Guardar cambios',
                    style: AppTypography.button.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
