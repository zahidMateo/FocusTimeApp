package com.example.pomodoro_app

import android.os.Build
import android.view.View
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "pomodoro_app/focus_mode"
    private var windowInsetsController: WindowInsetsControllerCompat? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Configurar WindowInsetsController
        window?.let { window ->
            WindowCompat.setDecorFitsSystemWindows(window, false)
            windowInsetsController = WindowCompat.getInsetsController(window, window.decorView)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableFocusMode" -> {
                    enableImmersiveMode()
                    result.success(null)
                }
                "disableFocusMode" -> {
                    disableImmersiveMode()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun enableImmersiveMode() {
        window?.let { window ->
            // Mantener la pantalla encendida
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

            windowInsetsController?.let { controller ->
                // Ocultar barras del sistema
                controller.hide(WindowInsetsCompat.Type.systemBars())

                // Modo inmersivo sticky - las barras vuelven a ocultarse si el usuario las desliza
                controller.systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        }
    }

    private fun disableImmersiveMode() {
        window?.let { window ->
            // Quitar flag de mantener pantalla encendida
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

            windowInsetsController?.let { controller ->
                // Mostrar barras del sistema
                controller.show(WindowInsetsCompat.Type.systemBars())
            }
        }
    }
}
