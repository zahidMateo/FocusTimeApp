import 'package:flutter/material.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/screens/settings_screens.dart';
import 'package:pomodoro_app/screens/timer_screen.dart';
import 'package:pomodoro_app/screens/rewards_screen.dart';
import 'package:pomodoro_app/screens/stats_screen.dart';

// ═════════ ══════════════════════════════════════════════════════════════════════════
// MAIN SCREEN - PANTALLA PRINCIPAL CON NAVEGACIÓN
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Esta es la pantalla principal que contiene el menú de navegación inferior.
// Permite al usuario navegar entre las 4 secciones de la app.
//
// ¿POR QUÉ STATEFUL?
// - Porque necesita "recordar" qué pantalla está seleccionada (_currentIndex)
// - Cuando el usuario toca un botón del menú, _currentIndex cambia
// - setState() le dice a Flutter que reconstruya la UI con la nueva pantalla
//
// ESTRUCTURA:
// MainScreen (StatefulWidget)
//   └─ body: _screens[_currentIndex]  ← Muestra la pantalla actual
//   └─ bottomNavigationBar: NavigationBar  ← El menú inferior
//       ├─ Timer
//       ├─ Estadísticas
//       ├─ Tareas
//       └─ Configuración
//
// ═══════════════════════════════════════════════════════════════════════════════════

// ┌─────────────────────────────────────────────────────────────────────────────────┐
// │ MAIN SCREEN - Widget principal                                                 │
// └─────────────────────────────────────────────────────────────────────────────────┘
// StatefulWidget porque tiene estado que cambia (qué pantalla está visible)

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// ┌─────────────────────────────────────────────────────────────────────────────────┐
// │ MAIN SCREEN STATE - Estado y lógica del widget                                 │
// └─────────────────────────────────────────────────────────────────────────────────┘
// Esta clase privada (_MainScreenState) contiene el estado y la lógica

class _MainScreenState extends State<MainScreen> {
  // ═════════════════════════════════════════════════════════════════════════════════
  // ESTADO INTERNO
  // ═════════════════════════════════════════════════════════════════════════════════

  // ─── Índice de la página actual ───
  // Indica qué pantalla está visible:
  // 0 = Timer
  // 1 = Estadísticas
  // 2 = Recompensas
  // 3 = Configuración
  // (Tareas temporalmente oculto)
  int _currentIndex = 0;

  // ─── Lista de pantallas ───
  // Cada posición corresponde a un índice del menú
  // Cuando cambias _currentIndex, se muestra una pantalla diferente
  final List<Widget> _screens = [
    TimerScreen(), // [0] Timer - Pantalla del temporizador
    const StatsScreen(), // [1] Stats - Estadísticas y métricas Stitch
    RewardsScreen(), // [2] Recompensas - Logros y Tienda
    // TasksScreen(), // Tareas - Gestión de tareas diarias (TEMPORALMENTE OCULTO)
    SettingsScreen(), // [3] Configuración - Pantalla de ajustes
  ];

  // ═════════════════════════════════════════════════════════════════════════════════
  // BUILD - Construye la UI
  // ═════════════════════════════════════════════════════════════════════════════════
  // Este método se ejecuta:
  // 1. La primera vez que se muestra la pantalla
  // 2. Cada vez que llamamos setState()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ───────────────────────────────────────────────────────────────────────────
      // BODY - Contenido principal de la pantalla
      // ───────────────────────────────────────────────────────────────────────────
      // IMPORTANTE: Usamos IndexedStack en lugar de _screens[_currentIndex]
      //
      // ¿POR QUÉ IndexedStack?
      // - Mantiene TODAS las pantallas vivas en memoria
      // - Solo muestra la pantalla del índice actual
      // - Cuando cambias de pestaña, el estado se conserva (el timer no se resetea)
      //
      // Alternativa (NO usar):
      //   body: _screens[_currentIndex]  ← Esto destruye y recrea widgets
      //
      // Con IndexedStack:
      //   - TimerScreen mantiene _remainingSeconds, _isRunning, etc.
      //   - El Timer.periodic no se cancela al cambiar de pestaña
      //   - Vuelves y el timer sigue corriendo donde lo dejaste ✅
      body: IndexedStack(index: _currentIndex, children: _screens),

      // ───────────────────────────────────────────────────────────────────────────
      // BOTTOM NAVIGATION BAR - Menú de navegación inferior (Focus Flow)
      // ───────────────────────────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          height: 68,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primarySoft,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer_rounded, color: AppColors.primary),
              label: 'Timer',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(
                Icons.bar_chart_rounded,
                color: AppColors.primary,
              ),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(
                Icons.emoji_events_rounded,
                color: AppColors.primary,
              ),
              label: 'Premios',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(
                Icons.settings_rounded,
                color: AppColors.primary,
              ),
              label: 'Config',
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// PLACEHOLDER SCREEN - Pantalla temporal de ejemplo
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Este widget es TEMPORAL. Lo usamos mientras no hemos implementado
// las pantallas de Estadísticas y Tareas.
//
// ¿POR QUÉ UN PLACEHOLDER?
// - Permite probar el menú de navegación antes de tener todas las pantallas listas
// - Muestra visualmente qué pantalla se está mostrando
// - Es más fácil que dejar pantallas en blanco
//
// ¿CUÁNDO ELIMINAR?
// - Cuando implementes las pantallas reales de Estadísticas y Tareas
// - Entonces reemplazas:
//     _PlaceholderScreen(title: 'Estadísticas', ...)
//   Por:
//     StatsScreen()
//
// ═══════════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════════
// RESUMEN DEL FLUJO
// ═══════════════════════════════════════════════════════════════════════════════════
//
// 1. MainScreen se muestra con _currentIndex = 0
// 2. body muestra _screens[0] que es TimerScreen
// 3. Usuario toca el botón "Stats" en el menú
// 4. onDestinationSelected se ejecuta con index = 1
// 5. setState(() { _currentIndex = 1; }) actualiza el estado
// 6. build() se ejecuta de nuevo
// 7. body ahora muestra _screens[1] que es _PlaceholderScreen('Estadísticas')
// 8. La pantalla cambia visualmente sin reiniciar toda la app
//
// ═══════════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════════
// PRÓXIMOS PASOS PARA MEJORAR ESTA PANTALLA
// ═══════════════════════════════════════════════════════════════════════════════════
//
// 1. Implementar StatsScreen para reemplazar el placeholder de Estadísticas
// 2. Implementar TasksScreen para reemplazar el placeholder de Tareas
// 3. (Opcional) Agregar animaciones al cambiar de pantalla usando PageView
// 4. (Opcional) Guardar la última pantalla visitada con SharedPreferences
//
// ═══════════════════════════════════════════════════════════════════════════════════
