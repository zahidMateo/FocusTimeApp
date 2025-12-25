import 'package:flutter/material.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/screens/settings_screens.dart';
import 'package:pomodoro_app/screens/timer_screen.dart';
import 'package:pomodoro_app/screens/tasks_screen.dart';
import 'package:pomodoro_app/screens/rewards_screen.dart';

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
    _PlaceholderScreen(
        title: 'Estadísticas',
        icon: Icons.bar_chart), // [1] Stats - Por implementar
    RewardsScreen(), // [2] Recompensas - Logros y Tienda
    // TasksScreen(), // [3] Tareas - Gestión de tareas diarias (TEMPORALMENTE OCULTO)
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // ───────────────────────────────────────────────────────────────────────────
      // BOTTOM NAVIGATION BAR - Menú de navegación inferior
      // ───────────────────────────────────────────────────────────────────────────
      // Este es el menú con los 4 botones en la parte inferior de la pantalla
      bottomNavigationBar: NavigationBar(
        // ═══════════════════════════════════════════════════════════════════════
        // CONFIGURACIÓN DEL NAVIGATION BAR
        // ═══════════════════════════════════════════════════════════════════════

        // selectedIndex: Índice del botón actualmente seleccionado
        // Le dice al NavigationBar qué botón debe mostrarse como activo
        selectedIndex: _currentIndex,

        // onDestinationSelected: Callback que se ejecuta cuando tocas un botón
        // Recibe el índice del botón que tocaste
        onDestinationSelected: (int index) {
          // setState() actualiza el estado Y reconstruye la UI
          setState(() {
            _currentIndex = index; // Cambia a la nueva pantalla
          });
          // Después de setState(), build() se ejecuta de nuevo
          // y muestra _screens[index]
        },

        // height: Altura del menú de navegación en píxeles
        height: 70,

        // backgroundColor: Color de fondo del menú (respeta tema oscuro)
        backgroundColor: Theme.of(context).colorScheme.surface,

        // indicatorColor: Color del fondo del botón seleccionado
        // withOpacity(0.2) = color primario con 20% de opacidad (muy suave)
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),

        // labelBehavior: Controla cuándo mostrar las etiquetas (Timer, Stats, etc.)
        // alwaysShow = las etiquetas siempre son visibles
        // Otras opciones:
        //   - alwaysHide = nunca mostrar etiquetas
        //   - onlyShowSelected = solo mostrar la etiqueta del botón seleccionado
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        // ═══════════════════════════════════════════════════════════════════════
        // DESTINATIONS - Los botones del menú
        // ═══════════════════════════════════════════════════════════════════════
        // Cada NavigationDestination es un botón en el menú
        // El orden aquí corresponde a los índices: [0, 1, 2, 3]
        destinations: [
          // ───────────────────────────────────────────────────────────────────
          // [0] TIMER - Temporizador Pomodoro
          // ───────────────────────────────────────────────────────────────────
          NavigationDestination(
            icon: Icon(Icons.timer_outlined), // Ícono cuando NO está seleccionado
            selectedIcon: Icon(Icons.timer), // Ícono cuando SÍ está seleccionado
            label: 'Timer', // Texto debajo del ícono
          ),

          // ───────────────────────────────────────────────────────────────────
          // [1] ESTADÍSTICAS - Historial y métricas
          // ───────────────────────────────────────────────────────────────────
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),

          // ───────────────────────────────────────────────────────────────────
          // [2] RECOMPENSAS - Logros y Tienda
          // ───────────────────────────────────────────────────────────────────
          NavigationDestination(
            icon: Icon(Icons.card_giftcard_outlined),
            selectedIcon: Icon(Icons.card_giftcard),
            label: 'Premios',
          ),

          // ───────────────────────────────────────────────────────────────────
          // [3] TAREAS - Lista de tareas pendientes (TEMPORALMENTE OCULTO)
          // ───────────────────────────────────────────────────────────────────
          // NavigationDestination(
          //   icon: Icon(Icons.list_outlined),
          //   selectedIcon: Icon(Icons.list),
          //   label: 'Tareas',
          // ),

          // ───────────────────────────────────────────────────────────────────
          // [3] CONFIGURACIÓN - Ajustes de la app
          // ───────────────────────────────────────────────────────────────────
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
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

class _PlaceholderScreen extends StatelessWidget {
  // ─── Propiedades requeridas ───
  final String title; // Título a mostrar
  final IconData icon; // Ícono a mostrar

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ───────────────────────────────────────────────────────────────────────────
      // APP BAR - Barra superior con el título
      // ───────────────────────────────────────────────────────────────────────────
      appBar: AppBar(
        title: Text(title), // Muestra el título (Ej: "Estadísticas")
      ),

      // ───────────────────────────────────────────────────────────────────────────
      // BODY - Contenido centrado con ícono y texto
      // ───────────────────────────────────────────────────────────────────────────
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ─── Ícono grande ───
            Icon(
              icon,
              size: 100, // Ícono de 100x100 píxeles
              color: context.colors.primary, // Color primario (respeta tema)
            ),
            SizedBox(height: 20), // Espacio de 20 píxeles

            // ─── Título ───
            Text(
              title,
              style: AppTypography.heading1, // Estilo grande y bold
            ),
            SizedBox(height: 10), // Espacio de 10 píxeles

            // ─── Descripción ───
            Text(
              'Pantalla de $title', // Ej: "Pantalla de Estadísticas"
              style: AppTypography.bodySmall, // Estilo pequeño y gris
            ),
          ],
        ),
      ),
    );
  }
}

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
