import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/models/settings_provider.dart';
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

  final List<Map<String, dynamic>> _availableSounds = [
    {'name': 'Ninguno', 'icon': Icons.volume_off},
    {'name': 'Ruido blanco', 'icon': Icons.waves},
    {'name': 'Ruido marrón', 'icon': Icons.water},
    {'name': 'Ruido rosa', 'icon': Icons.grain},
    {'name': 'Lluvia', 'icon': Icons.cloud},
    {'name': 'Oleaje', 'icon': Icons.beach_access},
    {'name': 'Viento suave', 'icon': Icons.air},
    {'name': 'Música instrumental', 'icon': Icons.music_note},
    {'name': 'Ventilador', 'icon': Icons.ac_unit},
    {'name': 'Río', 'icon': Icons.water_drop},
    {'name': 'Fuego crepitante', 'icon': Icons.local_fire_department},
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
          backgroundColor: AppColors.destructive,
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
        title: Text('⚠️ Timer en ejecución'),
        content: Text(
          'El timer está corriendo. Si guardas estos cambios, se reiniciará. ¿Deseas continuar?',
        ),
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
            child: Text('Guardar y reiniciar'),
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
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sonidos ambientales'),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              children: [
                // ═════════════════════════════════════════════════════════════════
                // LISTA DE SONIDOS (todos disponibles)
                // ═════════════════════════════════════════════════════════════════
                ..._availableSounds.map((sound) {
                  final isSelected = _selectedSound == sound['name'];

                  return Card(
                    margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
                    color: isSelected ? AppColors.sky.withOpacity(0.1) : AppColors.card,
                    child: ListTile(
                      leading: Icon(
                        sound['icon'] as IconData,
                        color: isSelected ? AppColors.sky : AppColors.mutedForeground,
                      ),
                      title: Text(
                        sound['name'] as String,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isSelected ? AppColors.sky : AppColors.foreground,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: AppColors.sky)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedSound = sound['name'] as String;
                        });
                        // Reproducir preview automáticamente al seleccionar
                        _previewSound(sound['name'] as String);
                      },
                    ),
                  );
                }).toList(),

                SizedBox(height: AppConstants.paddingLarge),

                // ═════════════════════════════════════════════════════════════════
                // CONTROL DE VOLUMEN
                // ═════════════════════════════════════════════════════════════════
                Card(
                  color: AppColors.card,
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
                            Icon(Icons.volume_down, color: AppColors.mutedForeground),
                            Expanded(
                              child: Slider(
                                value: _soundVolume,
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                label: '${(_soundVolume * 100).toInt()}%',
                                activeColor: AppColors.sky,
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
                            Icon(Icons.volume_up, color: AppColors.mutedForeground),
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
              color: AppColors.card,
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
