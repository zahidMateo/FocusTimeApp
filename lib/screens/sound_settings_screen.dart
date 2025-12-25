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
// SOUND SETTINGS SCREEN - CONFIGURACIÓN DE SONIDOS AMBIENTALES
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Pantalla dedicada para configurar sonidos ambientales que se reproducen durante el timer.
//
// ¿POR QUÉ UNA PANTALLA SEPARADA?
// - Permite al usuario explorar y seleccionar sonidos sin interrupciones
// - Puede previsualizar sonidos antes de guardar
// - Validación solo ocurre UNA VEZ al guardar (no en cada cambio)
//
// ═══════════════════════════════════════════════════════════════════════════════════

class SoundSettingsScreen extends StatefulWidget {
  const SoundSettingsScreen({super.key});

  @override
  State<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends State<SoundSettingsScreen> {
  // ═════════════════════════════════════════════════════════════════════════════════
  // ESTADO TEMPORAL
  // ═════════════════════════════════════════════════════════════════════════════════
  // Guardamos valores temporales hasta que el usuario presione "Guardar"

  String _selectedSound = 'Ninguno';
  double _soundVolume = 0.7;
  bool _isPreviewPlaying = false; // ¿Está sonando la previsualización?

  // ═════════════════════════════════════════════════════════════════════════════════
  // LISTA DE SONIDOS DISPONIBLES
  // ═════════════════════════════════════════════════════════════════════════════════

  // Sonidos GRATUITOS (disponibles siempre)
  final List<Map<String, dynamic>> _freeSounds = [
    {'name': 'Ninguno', 'icon': Icons.volume_off, 'premium': false},
    {'name': 'Ruido blanco', 'icon': Icons.waves, 'premium': false},
    {'name': 'Ruido marrón', 'icon': Icons.water, 'premium': false},
    {'name': 'Ruido rosa', 'icon': Icons.grain, 'premium': false},
  ];

  // Sonidos PREMIUM (requieren compra individual)
  final List<Map<String, dynamic>> _premiumSounds = [
    {'name': 'Lluvia', 'icon': Icons.cloud, 'premium': true, 'itemId': 'sound_rain', 'price': 75},
    {'name': 'Bosque', 'icon': Icons.park, 'premium': true, 'itemId': 'sound_forest', 'price': 75},
    {'name': 'Café', 'icon': Icons.coffee, 'premium': true, 'itemId': 'sound_cafe', 'price': 75},
    {'name': 'Biblioteca', 'icon': Icons.menu_book, 'premium': true, 'itemId': 'sound_library', 'price': 75},
  ];

  // ═════════════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═════════════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    // Cargar valores actuales del provider
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
    // Detener cualquier previsualización al salir
    // NO llamar setState() en dispose porque el widget ya está siendo destruido
    AudioService.stop();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // MÉTODOS
  // ═════════════════════════════════════════════════════════════════════════════════

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Previsualizar sonido (5 segundos)                                           │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _previewSound(String soundName) async {
    if (soundName == 'Ninguno') {
      _stopPreview();
      return;
    }

    setState(() {
      _isPreviewPlaying = true;
    });

    // Reproducir preview de 5 segundos
    final success = await AudioService.playPreview(
      soundName,
      volume: _soundVolume,
      durationSeconds: 5,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo reproducir el sonido'),
          backgroundColor: context.colors.destructive,
        ),
      );
    }

    // Actualizar estado después de 5 segundos
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isPreviewPlaying = false;
        });
      }
    });
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Detener previsualización                                                     │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _stopPreview() {
    AudioService.stopImmediately(); // Detener sin fade out
    setState(() {
      _isPreviewPlaying = false;
    });
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Guardar cambios                                                              │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _saveChanges() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Verificar si el timer está corriendo
    if (settings.isTimerRunning) {
      _showTimerRunningWarning();
    } else {
      _applyChanges();
      Navigator.of(context).pop();
    }
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Aplicar cambios al provider                                                  │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _applyChanges() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.setSelectedSound(_selectedSound);
    settings.setSoundVolume(_soundVolume);

    _stopPreview(); // Detener previsualización

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Configuración de sonido guardada'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Mostrar diálogo de advertencia: timer corriendo                              │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _showTimerRunningWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '⚠️ Timer en ejecución',
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
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _applyChangesAndReset();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.accent,
            ),
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ┌───────────────────────────────────────────────────────────────────────────────┐
  // │ Aplicar cambios y resetear timer                                             │
  // └───────────────────────────────────────────────────────────────────────────────┘
  void _applyChangesAndReset() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _applyChanges();
    settings.onTimerReset?.call(); // Resetear timer
  }

  // ═════════════════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ═════════════════════════════════════════════════════════════════════════════════

  Widget _buildSoundCard(Map<String, dynamic> sound, bool isLocked) {
    final isSelected = _selectedSound == sound['name'];
    final price = sound['price'] as int?;

    return Card(
      margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      color: isSelected
          ? context.colors.accent.withOpacity(0.1)
          : context.colors.cardBackground,
      child: ListTile(
        leading: Icon(
          sound['icon'] as IconData,
          color: isLocked
              ? context.colors.textSecondary.withOpacity(0.5)
              : isSelected
                  ? context.colors.accent
                  : context.colors.textSecondary,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                sound['name'] as String,
                style: AppTypography.bodyMedium.copyWith(
                  color: isLocked
                      ? context.colors.textSecondary
                      : isSelected
                          ? context.colors.accent
                          : context.colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isLocked && price != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 12, color: context.colors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      '$price',
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
        trailing: isSelected
            ? Icon(Icons.check_circle, color: context.colors.accent)
            : null,
        onTap: () {
          if (isLocked) {
            _showLockedSoundDialog(sound['name'] as String, price ?? 0);
          } else {
            setState(() {
              _selectedSound = sound['name'] as String;
            });
            // Reproducir preview automáticamente al seleccionar
            _previewSound(sound['name'] as String);
          }
        },
      ),
    );
  }

  void _showLockedSoundDialog(String soundName, int price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '🔒 Sonido Bloqueado',
          style: AppTypography.heading2,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note, size: 64, color: context.colors.accent),
            SizedBox(height: 16),
            Text(
              '$soundName está bloqueado.',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Desbloquea este sonido en la tienda por $price puntos.',
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

  // ═════════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final rewards = Provider.of<RewardsProvider>(context);

    return Scaffold(
      backgroundColor: context.colors.appBackground,
      appBar: AppBar(
        title: Text('Sonidos ambientales'),
        backgroundColor: context.colors.cardBackground,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              children: [
                // ═════════════════════════════════════════════════════════════════
                // SONIDOS GRATUITOS
                // ═════════════════════════════════════════════════════════════════
                Text(
                  'Sonidos Gratuitos',
                  style: AppTypography.heading2.copyWith(fontSize: 18),
                ),
                SizedBox(height: AppConstants.paddingSmall),

                ..._freeSounds.map((sound) {
                  return _buildSoundCard(sound, false);
                }).toList(),

                SizedBox(height: AppConstants.paddingLarge),

                // ═════════════════════════════════════════════════════════════════
                // SONIDOS PREMIUM
                // ═════════════════════════════════════════════════════════════════
                Text(
                  'Sonidos Premium',
                  style: AppTypography.heading2.copyWith(fontSize: 18),
                ),
                SizedBox(height: AppConstants.paddingSmall),

                ..._premiumSounds.map((sound) {
                  // Verificar si este sonido específico está desbloqueado
                  final itemId = sound['itemId'] as String;
                  final isUnlocked = rewards.isItemPurchased(itemId);
                  return _buildSoundCard(sound, !isUnlocked);
                }).toList(),

                SizedBox(height: AppConstants.paddingLarge),

                // ═════════════════════════════════════════════════════════════════
                // CONTROL DE VOLUMEN
                // ═════════════════════════════════════════════════════════════════
                Card(
                  color: context.colors.cardBackground,
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Volumen',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppConstants.paddingSmall),
                        Row(
                          children: [
                            Icon(Icons.volume_down, color: context.colors.textSecondary),
                            Expanded(
                              child: Slider(
                                value: _soundVolume,
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                label: '${(_soundVolume * 100).toInt()}%',
                                activeColor: context.colors.accent,
                                onChanged: (value) {
                                  setState(() {
                                    _soundVolume = value;
                                  });
                                  // Si hay una previsualización, actualizar volumen
                                  if (_isPreviewPlaying) {
                                    AudioService.setVolume(value);
                                  }
                                },
                              ),
                            ),
                            Icon(Icons.volume_up, color: context.colors.textSecondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppConstants.paddingMedium),
              ],
            ),
          ),

          // ═════════════════════════════════════════════════════════════════════
          // BOTÓN GUARDAR (fijo en la parte inferior)
          // ═════════════════════════════════════════════════════════════════════
          Container(
            padding: EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: context.colors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: Text(
                    'Guardar cambios',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
