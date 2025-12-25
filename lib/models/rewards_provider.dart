import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ═══════════════════════════════════════════════════════════════════════════════════
// REWARDS PROVIDER - SISTEMA DE RECOMPENSAS
// ═══════════════════════════════════════════════════════════════════════════════════
// Maneja:
// - Puntos/monedas del usuario
// - Logros desbloqueados
// - Items comprados en la tienda
// - Estadísticas para logros (minutos estudiados, días consecutivos, etc.)
// ═══════════════════════════════════════════════════════════════════════════════════

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // Nombre del ícono
  final int points;
  final int requiredValue; // Valor necesario para desbloquear
  final String type; // 'minutes', 'sessions', 'streak', etc.
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.requiredValue,
    required this.type,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isUnlocked': isUnlocked,
      };

  factory Achievement.fromJson(Map<String, dynamic> json, Achievement template) {
    return Achievement(
      id: template.id,
      title: template.title,
      description: template.description,
      icon: template.icon,
      points: template.points,
      requiredValue: template.requiredValue,
      type: template.type,
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }
}

class StoreItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int price;
  bool isPurchased;

  StoreItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.price,
    this.isPurchased = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isPurchased': isPurchased,
      };

  factory StoreItem.fromJson(Map<String, dynamic> json, StoreItem template) {
    return StoreItem(
      id: template.id,
      title: template.title,
      description: template.description,
      icon: template.icon,
      price: template.price,
      isPurchased: json['isPurchased'] ?? false,
    );
  }
}

class RewardsProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════════════════
  // ESTADO
  // ═══════════════════════════════════════════════════════════════════════════════════

  int _points = 1000; // TESTING: Iniciar con 1000 puntos para pruebas
  int _totalMinutesStudied = 0;
  int _totalSessionsCompleted = 0;
  int _currentStreak = 0;
  DateTime? _lastSessionDate;

  List<Achievement> _achievements = [];
  List<StoreItem> _storeItems = [];

  // ═══════════════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════════════════

  int get points => _points;
  int get totalMinutesStudied => _totalMinutesStudied;
  int get totalSessionsCompleted => _totalSessionsCompleted;
  int get currentStreak => _currentStreak;
  int get unlockedAchievementsCount =>
      _achievements.where((a) => a.isUnlocked).length;
  int get totalAchievementsCount => _achievements.length;

  List<Achievement> get achievements => _achievements;
  List<StoreItem> get storeItems => _storeItems;

  // ═══════════════════════════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ═══════════════════════════════════════════════════════════════════════════════════

  RewardsProvider() {
    _initializeAchievements();
    _initializeStoreItems();
    _loadData();
  }

  // ═══════════════════════════════════════════════════════════════════════════════════
  // INICIALIZAR LOGROS
  // ═══════════════════════════════════════════════════════════════════════════════════
  // NOTA: Valores bajos para TESTING (el usuario pidió 5 min para pruebas)

  void _initializeAchievements() {
    _achievements = [
      Achievement(
        id: 'first_session',
        title: 'Primer Pomodoro',
        description: 'Completa tu primer pomodoro',
        icon: 'timer',
        points: 10,
        requiredValue: 1,
        type: 'sessions',
      ),
      Achievement(
        id: 'study_5min',
        title: 'Estudiante Novato',
        description: 'Estudia durante 5 minutos en total',
        icon: 'school',
        points: 15,
        requiredValue: 5,
        type: 'minutes',
      ),
      Achievement(
        id: 'study_30min',
        title: 'Estudiante Dedicado',
        description: 'Estudia durante 30 minutos en total',
        icon: 'book',
        points: 25,
        requiredValue: 30,
        type: 'minutes',
      ),
      Achievement(
        id: 'streak_3',
        title: 'Racha de 3 días',
        description: 'Usa la app durante 3 días consecutivos',
        icon: 'local_fire_department',
        points: 30,
        requiredValue: 3,
        type: 'streak',
      ),
      Achievement(
        id: 'sessions_10',
        title: 'Productivo',
        description: 'Completa 10 sesiones de pomodoro',
        icon: 'checklist',
        points: 40,
        requiredValue: 10,
        type: 'sessions',
      ),
      Achievement(
        id: 'study_60min',
        title: 'Maestro del enfoque',
        description: 'Estudia durante 60 minutos en total',
        icon: 'emoji_events',
        points: 50,
        requiredValue: 60,
        type: 'minutes',
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════════════
  // INICIALIZAR ITEMS DE TIENDA
  // ═══════════════════════════════════════════════════════════════════════════════════
  // PRECIOS PARA TESTING: Total ~1000 puntos

  void _initializeStoreItems() {
    _storeItems = [
      // ─────────────────────────────────────────────────────────────────────────────
      // APARIENCIA - TEMA OSCURO
      // ─────────────────────────────────────────────────────────────────────────────
      StoreItem(
        id: 'dark_mode',
        title: 'Tema Oscuro',
        description: 'Modo oscuro para cuidar tus ojos durante sesiones nocturnas',
        icon: 'dark_mode',
        price: 100,
      ),

      // ─────────────────────────────────────────────────────────────────────────────
      // TEMAS DE COLOR INDIVIDUALES
      // ─────────────────────────────────────────────────────────────────────────────
      StoreItem(
        id: 'theme_ocean',
        title: 'Tema Océano',
        description: 'Tonos azules y turquesas relajantes',
        icon: 'palette',
        price: 150,
      ),
      StoreItem(
        id: 'theme_forest',
        title: 'Tema Bosque',
        description: 'Verdes naturales y frescos',
        icon: 'palette',
        price: 150,
      ),
      StoreItem(
        id: 'theme_sunset',
        title: 'Tema Atardecer',
        description: 'Naranjas y rosas cálidos',
        icon: 'palette',
        price: 150,
      ),
      StoreItem(
        id: 'theme_lavender',
        title: 'Tema Lavanda',
        description: 'Morados y lilas suaves',
        icon: 'palette',
        price: 150,
      ),

      // ─────────────────────────────────────────────────────────────────────────────
      // SONIDOS INDIVIDUALES
      // ─────────────────────────────────────────────────────────────────────────────
      StoreItem(
        id: 'sound_rain',
        title: 'Sonido: Lluvia',
        description: 'Lluvia suave y relajante',
        icon: 'cloud',
        price: 75,
      ),
      StoreItem(
        id: 'sound_forest',
        title: 'Sonido: Bosque',
        description: 'Pájaros y naturaleza',
        icon: 'park',
        price: 75,
      ),
      StoreItem(
        id: 'sound_cafe',
        title: 'Sonido: Café',
        description: 'Ambiente de cafetería',
        icon: 'coffee',
        price: 75,
      ),
      StoreItem(
        id: 'sound_library',
        title: 'Sonido: Biblioteca',
        description: 'Susurros y páginas',
        icon: 'menu_book',
        price: 75,
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════════════
  // CARGAR DATOS DE SHAREDPREFERENCES
  // ═══════════════════════════════════════════════════════════════════════════════════

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar puntos y estadísticas
      _points = prefs.getInt('rewards_points') ?? 0;
      _totalMinutesStudied = prefs.getInt('rewards_total_minutes') ?? 0;
      _totalSessionsCompleted = prefs.getInt('rewards_total_sessions') ?? 0;
      _currentStreak = prefs.getInt('rewards_streak') ?? 0;

      final lastSessionStr = prefs.getString('rewards_last_session');
      if (lastSessionStr != null) {
        _lastSessionDate = DateTime.parse(lastSessionStr);
      }

      // Cargar logros desbloqueados
      final achievementsJson = prefs.getString('rewards_achievements');
      if (achievementsJson != null) {
        final List<dynamic> achievementsList = json.decode(achievementsJson);
        for (var i = 0; i < _achievements.length; i++) {
          final savedData = achievementsList.firstWhere(
            (a) => a['id'] == _achievements[i].id,
            orElse: () => {'id': _achievements[i].id, 'isUnlocked': false},
          );
          _achievements[i].isUnlocked = savedData['isUnlocked'] ?? false;
        }
      }

      // Cargar items comprados
      final storeItemsJson = prefs.getString('rewards_store_items');
      if (storeItemsJson != null) {
        final List<dynamic> storeItemsList = json.decode(storeItemsJson);
        for (var i = 0; i < _storeItems.length; i++) {
          final savedData = storeItemsList.firstWhere(
            (s) => s['id'] == _storeItems[i].id,
            orElse: () => {'id': _storeItems[i].id, 'isPurchased': false},
          );
          _storeItems[i].isPurchased = savedData['isPurchased'] ?? false;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar datos de recompensas: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════════
  // GUARDAR DATOS EN SHAREDPREFERENCES
  // ═══════════════════════════════════════════════════════════════════════════════════

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Guardar puntos y estadísticas
      await prefs.setInt('rewards_points', _points);
      await prefs.setInt('rewards_total_minutes', _totalMinutesStudied);
      await prefs.setInt('rewards_total_sessions', _totalSessionsCompleted);
      await prefs.setInt('rewards_streak', _currentStreak);

      if (_lastSessionDate != null) {
        await prefs.setString('rewards_last_session', _lastSessionDate!.toIso8601String());
      }

      // Guardar logros
      final achievementsJson = json.encode(
        _achievements.map((a) => a.toJson()).toList(),
      );
      await prefs.setString('rewards_achievements', achievementsJson);

      // Guardar items de tienda
      final storeItemsJson = json.encode(
        _storeItems.map((s) => s.toJson()).toList(),
      );
      await prefs.setString('rewards_store_items', storeItemsJson);
    } catch (e) {
      debugPrint('Error al guardar datos de recompensas: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════════
  // REGISTRAR SESIÓN COMPLETADA
  // ═══════════════════════════════════════════════════════════════════════════════════
  // Este método se llama desde el timer cuando el usuario completa una sesión

  Future<List<Achievement>> onSessionCompleted(int minutes) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Actualizar estadísticas
    _totalSessionsCompleted++;
    _totalMinutesStudied += minutes;

    // Actualizar racha
    if (_lastSessionDate == null) {
      _currentStreak = 1;
    } else {
      final lastDay = DateTime(
        _lastSessionDate!.year,
        _lastSessionDate!.month,
        _lastSessionDate!.day,
      );
      final daysDifference = today.difference(lastDay).inDays;

      if (daysDifference == 0) {
        // Mismo día, mantener racha
      } else if (daysDifference == 1) {
        // Día consecutivo, incrementar racha
        _currentStreak++;
      } else {
        // Se rompió la racha
        _currentStreak = 1;
      }
    }

    _lastSessionDate = now;

    // Otorgar puntos base por completar sesión
    _points += 5;

    // Verificar logros y obtener los que se desbloquearon
    final newlyUnlocked = await _checkAchievements();

    // Guardar todo
    await _saveData();
    notifyListeners();

    return newlyUnlocked;
  }

  // ═══════════════════════════════════════════════════════════════════════════════════
  // VERIFICAR LOGROS
  // ═══════════════════════════════════════════════════════════════════════════════════
  // Revisa si se cumplieron las condiciones para desbloquear logros
  // Retorna la lista de logros recién desbloqueados

  Future<List<Achievement>> _checkAchievements() async {
    final newlyUnlocked = <Achievement>[];

    for (var achievement in _achievements) {
      if (achievement.isUnlocked) continue; // Ya desbloqueado

      bool shouldUnlock = false;

      switch (achievement.type) {
        case 'sessions':
          shouldUnlock = _totalSessionsCompleted >= achievement.requiredValue;
          break;
        case 'minutes':
          shouldUnlock = _totalMinutesStudied >= achievement.requiredValue;
          break;
        case 'streak':
          shouldUnlock = _currentStreak >= achievement.requiredValue;
          break;
      }

      if (shouldUnlock) {
        achievement.isUnlocked = true;
        _points += achievement.points;
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  // ═══════════════════════════════════════════════════════════════════════════════════
  // COMPRAR ITEM DE LA TIENDA
  // ═══════════════════════════════════════════════════════════════════════════════════

  Future<bool> purchaseItem(String itemId) async {
    final item = _storeItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    // Verificar si ya está comprado
    if (item.isPurchased) {
      return false;
    }

    // Verificar si tiene suficientes puntos
    if (_points < item.price) {
      return false;
    }

    // Realizar compra
    _points -= item.price;
    item.isPurchased = true;

    await _saveData();
    notifyListeners();

    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════════════════
  // VERIFICAR SI UN ITEM ESTÁ COMPRADO
  // ═══════════════════════════════════════════════════════════════════════════════════

  bool isItemPurchased(String itemId) {
    try {
      final item = _storeItems.firstWhere((item) => item.id == itemId);
      return item.isPurchased;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════════
  // RESETEAR TODO (PARA TESTING)
  // ═══════════════════════════════════════════════════════════════════════════════════

  Future<void> resetAll() async {
    _points = 0;
    _totalMinutesStudied = 0;
    _totalSessionsCompleted = 0;
    _currentStreak = 0;
    _lastSessionDate = null;

    for (var achievement in _achievements) {
      achievement.isUnlocked = false;
    }

    for (var item in _storeItems) {
      item.isPurchased = false;
    }

    await _saveData();
    notifyListeners();
  }
}
