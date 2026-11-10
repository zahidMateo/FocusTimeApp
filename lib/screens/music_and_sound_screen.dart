import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/models/settings_provider.dart';
import 'package:pomodoro_app/services/audio_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MUSIC AND SOUND SCREEN - PANTALLA DE MÚSICA Y SONIDO (GOOGLE STITCH FOCUS FLOW)
// ═══════════════════════════════════════════════════════════════════════════════

class AmbientTrackInfo {
  final String key;
  final String displayName;
  final String subtitle;
  final IconData icon;
  final String frequency;

  const AmbientTrackInfo({
    required this.key,
    required this.displayName,
    required this.subtitle,
    required this.icon,
    this.frequency = '432 Hz',
  });
}

class MusicAndSoundScreen extends StatefulWidget {
  const MusicAndSoundScreen({super.key});

  @override
  State<MusicAndSoundScreen> createState() => _MusicAndSoundScreenState();
}

class _MusicAndSoundScreenState extends State<MusicAndSoundScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  bool _sleepTimerEnabled = true;
  bool _pauseDuringBreaks = true;

  static const List<AmbientTrackInfo> _ambientTracks = [
    AmbientTrackInfo(
      key: 'Lluvia',
      displayName: 'Lluvia de Bosque Suave',
      subtitle: 'Sonido Ambiental Continuo · Bucle Infinito',
      icon: Icons.water_drop_rounded,
      frequency: '432 Hz',
    ),
    AmbientTrackInfo(
      key: 'Oleaje',
      displayName: 'Ondas Alfa 432Hz',
      subtitle: 'Oleaje del Mar Relajante · Bucle Infinito',
      icon: Icons.waves_rounded,
      frequency: '432 Hz',
    ),
    AmbientTrackInfo(
      key: 'Viento suave',
      displayName: 'Viento en Pinos',
      subtitle: 'Brisa de Bosque y Montaña · Bucle Infinito',
      icon: Icons.air_rounded,
      frequency: '528 Hz',
    ),
    AmbientTrackInfo(
      key: 'Ruido blanco',
      displayName: 'Ruido Rosa',
      subtitle: 'Frecuencia Terapéutica para Concentración',
      icon: Icons.graphic_eq_rounded,
      frequency: 'Ruido Rosa',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (AudioService.isPlaying) {
      _waveController.repeat();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  AmbientTrackInfo _getCurrentTrack(String selectedSound) {
    final track = _ambientTracks.firstWhere(
      (t) => t.key == selectedSound,
      orElse: () => _ambientTracks.first,
    );
    return track;
  }

  void _togglePlayPause(SettingsProvider settings) async {
    if (AudioService.isPlaying) {
      await AudioService.pause();
      _waveController.stop();
    } else {
      String soundKey = settings.selectedSound;
      if (soundKey == 'Ninguno' || soundKey.isEmpty) {
        soundKey = 'Lluvia';
        settings.setSelectedSound('Lluvia');
      }
      final success = await AudioService.play(
        soundKey,
        volume: settings.soundVolume,
        fadeDurationMs: 800,
      );
      if (success) {
        _waveController.repeat();
      }
    }
    if (mounted) setState(() {});
  }

  void _playNextTrack(SettingsProvider settings) async {
    int currentIndex = _ambientTracks.indexWhere((t) => t.key == settings.selectedSound);
    if (currentIndex == -1) currentIndex = 0;
    int nextIndex = (currentIndex + 1) % _ambientTracks.length;
    final nextTrack = _ambientTracks[nextIndex];
    settings.setSelectedSound(nextTrack.key);
    if (AudioService.isPlaying) {
      await AudioService.play(
        nextTrack.key,
        volume: settings.soundVolume,
        fadeDurationMs: 500,
      );
      _waveController.repeat();
    }
    if (mounted) setState(() {});
  }

  void _playPrevTrack(SettingsProvider settings) async {
    int currentIndex = _ambientTracks.indexWhere((t) => t.key == settings.selectedSound);
    if (currentIndex == -1) currentIndex = 0;
    int prevIndex = (currentIndex - 1 + _ambientTracks.length) % _ambientTracks.length;
    final prevTrack = _ambientTracks[prevIndex];
    settings.setSelectedSound(prevTrack.key);
    if (AudioService.isPlaying) {
      await AudioService.play(
        prevTrack.key,
        volume: settings.soundVolume,
        fadeDurationMs: 500,
      );
      _waveController.repeat();
    }
    if (mounted) setState(() {});
  }

  void _selectTrack(AmbientTrackInfo track, SettingsProvider settings) async {
    settings.setSelectedSound(track.key);
    if (AudioService.isPlaying) {
      await AudioService.play(
        track.key,
        volume: settings.soundVolume,
        fadeDurationMs: 500,
      );
      _waveController.repeat();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isPlaying = AudioService.isPlaying;
        if (isPlaying && !_waveController.isAnimating) {
          _waveController.repeat();
        } else if (!isPlaying && _waveController.isAnimating) {
          _waveController.stop();
        }

        final currentTrack = _getCurrentTrack(settings.selectedSound);
        final volumePercent = (settings.soundVolume * 100).toInt();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF131B2E),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Música y Sonido',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF131B2E),
              ),
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 8,
                  bottom: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. MÓDULO DEL REPRODUCTOR ACTIVO (HERO SECTION STITCH)
                      _buildActivePlayerModule(
                        currentTrack: currentTrack,
                        isPlaying: isPlaying,
                        volumePercent: volumePercent,
                        settings: settings,
                      ),
                      const SizedBox(height: 24),

                      // 2. SECCIÓN DE FUENTES DE AUDIO
                      _buildAudioSourcesSection(settings, currentTrack),
                      const SizedBox(height: 24),

                      // 3. SECCIÓN AUTOMATIZACIÓN Y ENFOQUE
                      _buildAutomationSection(),
                      const SizedBox(height: 20),

                      // 4. MICRO CARD INFORMATIVA AMBIENTAL
                      _buildInfoCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 1. MÓDULO DEL REPRODUCTOR ACTIVO
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildActivePlayerModule({
    required AmbientTrackInfo currentTrack,
    required bool isPlaying,
    required int volumePercent,
    required SettingsProvider settings,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila superior: Portada / Arte + Información de la pista
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F2B36),
                      Color(0xFF1E3A8A),
                      Color(0xFF0D9488),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      currentTrack.icon,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 28,
                    ),
                    if (isPlaying)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF38BDF8),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F3FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isPlaying ? 'En reproducción' : 'En pausa',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.waves_rounded,
                              size: 14,
                              color: Color(0xFF007D55),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              currentTrack.frequency,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF007D55),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentTrack.displayName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF131B2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentTrack.subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF585F67),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Simulación de visualizador de ondas (Waveform Visualizer)
          _buildWaveformVisualizer(isPlaying),
          const SizedBox(height: 18),

          // Controles de reproducción principales
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón pista anterior (48x48)
              InkWell(
                onTap: () => _playPrevTrack(settings),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F3FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.skip_previous_rounded,
                    color: Color(0xFF585F67),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Botón central Play / Pause (64x64, Cobalt Blue)
              GestureDetector(
                onTap: () => _togglePlayPause(settings),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(37, 99, 235, 0.35),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Botón pista siguiente (48x48)
              InkWell(
                onTap: () => _playNextTrack(settings),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F3FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.skip_next_rounded,
                    color: Color(0xFF585F67),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Slider de rango de volumen
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.volume_down_rounded,
                  color: Color(0xFF585F67),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: const Color(0xFFE2E7FF),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.15),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                    ),
                    child: Slider(
                      value: settings.soundVolume.clamp(0.0, 1.0),
                      min: 0.0,
                      max: 1.0,
                      onChanged: (val) {
                        settings.setSoundVolume(val);
                        AudioService.setVolume(val);
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.volume_up_rounded,
                  color: Color(0xFF585F67),
                  size: 20,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  child: Text(
                    '$volumePercent%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF131B2E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // WAVEFORM VISUALIZER (BARRAS DE ONDA ANIMADAS)
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildWaveformVisualizer(bool isPlaying) {
    return Container(
      width: double.infinity,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          final animVal = _waveController.value;
          const barCount = 16;
          final baseHeights = [
            10.0, 16.0, 24.0, 14.0, 22.0, 28.0, 18.0, 12.0,
            20.0, 26.0, 15.0, 22.0, 27.0, 14.0, 18.0, 10.0,
          ];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(barCount, (i) {
              double h;
              if (isPlaying) {
                final wave = math.sin((animVal * 2 * math.pi) + (i * 0.45)).abs();
                h = (baseHeights[i] * (0.4 + 0.6 * wave)).clamp(6.0, 30.0);
              } else {
                h = 6.0;
              }
              final opacity = isPlaying
                  ? (0.45 + (baseHeights[i] / 30.0) * 0.55)
                  : 0.25;
              return Container(
                width: 3.5,
                height: h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 2. SECCIÓN DE FUENTES DE AUDIO
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildAudioSourcesSection(
    SettingsProvider settings,
    AmbientTrackInfo currentTrack,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Fuentes de Audio',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF131B2E),
              ),
            ),
            Text(
              '4 disponibles',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF585F67),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Fuente 1: Sonidos Ambientales (Tarjeta activa expandida)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.04),
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
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAEDFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.nature_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Sonidos Ambientales',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF131B2E),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Generador offline sin interrupciones',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF585F67),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007D55).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Activo',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007D55),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Selector rápido en cuadrícula 2x2
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3.2,
                ),
                itemCount: _ambientTracks.length,
                itemBuilder: (context, index) {
                  final track = _ambientTracks[index];
                  final isSelected = settings.selectedSound == track.key;

                  return InkWell(
                    onTap: () => _selectTrack(track, settings),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEAEDFF)
                            : const Color(0xFFF2F3FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            track.icon,
                            size: 18,
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFF585F67),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              track.displayName,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : const Color(0xFF131B2E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Fuente 2: Spotify
        _buildExternalSourceCard(
          icon: Icons.play_circle_fill_rounded,
          iconColor: const Color(0xFF1DB954),
          iconBg: const Color(0xFF1DB954).withValues(alpha: 0.12),
          title: 'Spotify',
          subtitle: 'Deep Focus & Lo-Fi Beats',
          buttonLabel: 'Conectar',
          buttonIcon: Icons.sync_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Spotify vinculado con playlists de enfoque'),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(height: 10),

        // Fuente 3: YouTube Music
        _buildExternalSourceCard(
          icon: Icons.smart_display_rounded,
          iconColor: const Color(0xFFEF4444),
          iconBg: const Color(0xFFEF4444).withValues(alpha: 0.12),
          title: 'YouTube Music',
          subtitle: 'Mixes de estudio y síntesis',
          buttonLabel: 'Explorar',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('YouTube Music: Explorando mezclas de enfoque'),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(height: 10),

        // Fuente 4: Música del Dispositivo
        _buildExternalSourceCard(
          icon: Icons.folder_rounded,
          iconColor: const Color(0xFF585F67),
          iconBg: const Color(0xFFDCE3EC),
          title: 'Música del Dispositivo',
          subtitle: 'Archivos locales .mp3 / .flac',
          buttonLabel: 'Explorar',
          buttonIcon: Icons.file_open_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Explorando archivos locales de audio del dispositivo'),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExternalSourceCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String buttonLabel,
    IconData? buttonIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF131B2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF585F67),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (buttonIcon != null) ...[
                    Icon(
                      buttonIcon,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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

  // ═════════════════════════════════════════════════════════════════════════════
  // 3. SECCIÓN AUTOMATIZACIÓN Y ENFOQUE
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildAutomationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Automatización y Enfoque',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF131B2E),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Temporizador de apagado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F3FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bedtime_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Temporizador de apagado',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF131B2E),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Detener el audio automáticamente cuando concluya el bloque Pomodoro',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF585F67),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _sleepTimerEnabled,
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: Colors.white,
                    onChanged: (val) {
                      setState(() {
                        _sleepTimerEnabled = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFEAEDFF), height: 1),
              const SizedBox(height: 12),

              // 2. Sonido en descansos
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F3FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.coffee_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Sonido en descansos',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF131B2E),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pausar música de concentración al iniciar descansos cortos o largos',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF585F67),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _pauseDuringBreaks,
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: Colors.white,
                    onChanged: (val) {
                      setState(() {
                        _pauseDuringBreaks = val;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 4. MICRO CARD INFORMATIVA AMBIENTAL
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Los ritmos monoaurales y sonidos binaurales reducen la fatiga mental durante bloques de trabajo profundo superiores a 45 minutos.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF434655),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
