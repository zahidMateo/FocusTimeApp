import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/screens/main_screens.dart';
import 'package:pomodoro_app/models/settings_provider.dart';
import 'package:pomodoro_app/models/rewards_provider.dart';
import 'package:pomodoro_app/services/notification_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// MAIN.DART - PUNTO DE ENTRADA DE LA APLICACIÓN
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Este es el archivo MÁS IMPORTANTE de tu app Flutter.
// Es el PRIMER archivo que se ejecuta cuando abres la aplicación.
//
// ¿QUÉ HACE ESTE ARCHIVO?
// 1. La función main() es el punto de inicio
// 2. runApp() le dice a Flutter qué widget mostrar primero
// 3. ChangeNotifierProvider envuelve toda la app para compartir estado
// 4. MaterialApp configura la estructura básica de la app (tema, navegación, etc.)
//
// ¿QUÉ ES PROVIDER?
// - Es un patrón de gestión de estado en Flutter
// - Permite compartir datos entre pantallas sin pasar parámetros manualmente
// - ChangeNotifierProvider crea una instancia de SettingsProvider que TODAS las
//   pantallas pueden acceder usando Consumer o Provider.of
//
// FLUJO DE EJECUCIÓN:
// main() → runApp(PomodoroApp) → MaterialApp → MainScreen → las 4 pantallas
//
// ═══════════════════════════════════════════════════════════════════════════════════

// ┌─────────────────────────────────────────────────────────────────────────────────┐
// │ FUNCIÓN MAIN - Punto de entrada de la aplicación                               │
// └─────────────────────────────────────────────────────────────────────────────────┘
// Esta es la PRIMERA función que se ejecuta cuando abres la app
// void main() es obligatoria en TODOS los programas de Dart

void main() async {
  // WidgetsFlutterBinding.ensureInitialized() es necesario cuando usas funciones
  // async en main() ANTES de runApp(). Inicializa el sistema de widgets de Flutter.
  WidgetsFlutterBinding.ensureInitialized();

  // ═════════════════════════════════════════════════════════════════════════════
  // INICIALIZAR NOTIFICACIONES Y PEDIR PERMISOS
  // ═════════════════════════════════════════════════════════════════════════════
  // 1. Inicializar el servicio (configura canales de notificación)
  await NotificationService.initialize();

  // 2. Pedir permisos explícitamente al usuario
  // En Android 13+ (API 33+) es OBLIGATORIO pedir permiso para notificaciones
  // También es necesario para vibración
  await NotificationService.requestPermissions();

  // runApp() es una función de Flutter que inicia la aplicación
  // Le pasamos el widget raíz (PomodoroApp) que representa toda la app
  runApp(const PomodoroApp());
}

// ┌─────────────────────────────────────────────────────────────────────────────────┐
// │ POMODORO APP - Widget raíz de la aplicación                                    │
// └─────────────────────────────────────────────────────────────────────────────────┘
// StatelessWidget porque este widget nunca cambia (no tiene estado interno)
// Es simplemente un "contenedor" para configurar la app

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ═════════════════════════════════════════════════════════════════════════════
    // CHANGE NOTIFIER PROVIDER - Gestor de estado global
    // ═════════════════════════════════════════════════════════════════════════════
    //
    // ¿QUÉ HACE?
    // - Crea una instancia de SettingsProvider (nuestro gestor de configuraciones)
    // - La hace disponible para TODAS las pantallas de la app
    // - Cuando SettingsProvider llama notifyListeners(), todas las pantallas
    //   que estén "escuchando" se reconstruyen automáticamente
    //
    // ¿POR QUÉ EN LA RAÍZ?
    // - Al envolver MaterialApp, TODAS las pantallas tienen acceso al provider
    // - Si lo pones más abajo, solo algunas pantallas tendrían acceso
    //
    // ¿CÓMO USARLO EN OTRAS PANTALLAS?
    // Opción 1 - Consumer (recomendado para UI que se actualiza):
    //   Consumer<SettingsProvider>(
    //     builder: (context, settings, child) {
    //       return Text('Tiempo: ${settings.focusDuration}');
    //     },
    //   )
    //
    // Opción 2 - Provider.of (para leer valores una vez):
    //   final settings = Provider.of<SettingsProvider>(context, listen: false);
    //   settings.setFocusDuration(30);

    return MultiProvider(
      // Proporcionamos múltiples providers: SettingsProvider y RewardsProvider
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => RewardsProvider()),
      ],

      // child: define qué widget tiene acceso a los providers (en este caso, toda la app)
      // Usamos Consumer para que el MaterialApp se reconstruya cuando cambie el tema
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            // ─────────────────────────────────────────────────────────────────────
            // CONFIGURACIÓN DE LA APP
            // ─────────────────────────────────────────────────────────────────────

            // Título que aparece en el task switcher del sistema operativo
            title: 'Pomodoro Timer',

            // Quita el banner de "DEBUG" de la esquina superior derecha
            debugShowCheckedModeBanner: false,

            // ═════════════════════════════════════════════════════════════════════
            // THEME - Aplica el tema visual según la configuración del usuario
            // ═════════════════════════════════════════════════════════════════════
            // theme: tema claro (siempre disponible)
            // darkTheme: tema oscuro (cuando el usuario lo activa)
            // themeMode: controla qué tema usar basándose en settings.darkModeEnabled
            // getThemedLight/Dark: aplica el tema de color seleccionado
            theme: AppTheme.getThemedLight(settings.selectedTheme),
            darkTheme: AppTheme.getThemedDark(settings.selectedTheme),
            themeMode: settings.darkModeEnabled
                ? ThemeMode.dark
                : ThemeMode.light,

            // ═════════════════════════════════════════════════════════════════════
            // HOME - Primera pantalla que se muestra al abrir la app
            // ═════════════════════════════════════════════════════════════════════
            // MainScreen es nuestro NavigationBar con las 5 pantallas
            home: const MainScreen(),

            // ───────────────────────────────────────────────────────────────────
            // NOTA: Si quieres agregar rutas nombradas en el futuro:
            // ───────────────────────────────────────────────────────────────────
            // routes: {
            //   '/': (context) => MainScreen(),
            //   '/settings': (context) => SettingsScreen(),
            //   '/timer': (context) => TimerScreen(),
            // },
            //
            // Y navegarías así:
            //   Navigator.pushNamed(context, '/settings');
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// RESUMEN DEL FLUJO DE LA APP
// ═══════════════════════════════════════════════════════════════════════════════════
//
// 1. main() se ejecuta al abrir la app
// 2. runApp() inicia Flutter con PomodoroApp
// 3. ChangeNotifierProvider crea SettingsProvider y lo hace disponible globalmente
// 4. MaterialApp configura el tema y navegación
// 5. MainScreen se muestra como primera pantalla (home)
// 6. MainScreen tiene un NavigationBar con 4 opciones
// 7. Usuario navega entre: Timer, Estadísticas, Tareas, Configuración
//
// ═══════════════════════════════════════════════════════════════════════════════════
