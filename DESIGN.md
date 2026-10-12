# DESIGN.md — Focus Flow Design System
> Extraído directamente desde Google Stitch MCP para el proyecto **Pomodoro Productivity App Redesign** (`projects/14254510945323026143`).

---

## 1. Identidad y Filosofía de Diseño

El sistema de diseño **Focus Flow** establece un entorno de productividad de alto rendimiento que combina un enfoque profundo con calidez y accesibilidad. Dirigido a profesionales, estudiantes y creadores que requieren claridad cognitiva sin sobrecarga sensorial.

- **Estilo:** *Modern Clean* con sutiles toques táctiles.
- **Atmósfera:** Calma, ritmo constante y sensación de logro continuo.
- **Tensión visual baja:** Eliminación de bordes duros y sombras pesadas; uso de bordes limpios de 1px (`#E2E8F0`), superficies elevadas blanco puro (`#FFFFFF`) y fondo ultra suave (`#FAF8FF` / `#F8FAFC`) para evitar fatiga ocular durante sesiones prolongadas de estudio o trabajo.

---

## 2. Paleta de Colores (Tokens)

### Colores Clave de Marca e Interfaz

| Token | Hex | Nombre / Rol | Uso en la UI |
| :--- | :--- | :--- | :--- |
| `primary` | `#2563EB` | Cobalt Focus Blue | Botón principal (CTA), anillo de progreso del temporizador, estados activos |
| `primary-soft` | `#EFF6FF` | Pastel Blue Tint | Fondo de botones secundarios, pill de navegación activa, badges |
| `primary-dark` | `#004AC6` | Deep Blue Accent | Variantes con mayor contraste |
| `background` | `#FAF8FF` / `#F8FAFC` | Canvas Base | Fondo global de la app (reduce deslumbramiento frente a blanco puro) |
| `surface` | `#FFFFFF` | Card & Container | Tarjetas elevadas, modales, campos de texto y barra de navegación |
| `surface-container` | `#EAEDFF` | Subtle Container | Contenedores sutiles y chips secundarios |
| `text-primary` | `#0F172A` / `#131B2E` | Deep Slate | Dígitos del temporizador, títulos H1/H2, tareas activas |
| `text-secondary` | `#475569` / `#434655` | Mid Slate (WCAG AA) | Subtítulos, timestamps, etiquetas inactivas y descripciones |
| `border` | `#E2E8F0` | Light Border (1px) | Delimitador de tarjetas, separadores y track inactivo del temporizador |
| `border-hover` | `#CBD5E1` | Medium Border | Estado hover o focus de bordes y controles secundarios |
| `success` | `#10B981` | Emerald Achievement | Tareas completadas, rachas (streaks), hitos y reconocimientos |
| `success-soft` | `#ECFDF5` | Soft Emerald Tint | Fondo de badges de éxito y logros desbloqueados |
| `destructive` | `#EF4444` / `#BA1A1A` | Crimson Reset/Alert | Abortar sesión, reiniciar temporizador, eliminar tarea |
| `destructive-soft`| `#FEE2E2` / `#FFDAD6` | Soft Crimson Tint | Fondo para acciones destructivas |

### Mapeo para Flutter (`Color`)
```dart
class FocusFlowColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primarySoft = Color(0xFFEFF6FF);
  static const Color primaryDark = Color(0xFF004AC6);
  static const Color background = Color(0xFFFAF8FF);
  static const Color canvasAlt = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color success = Color(0xFF10B981);
  static const Color successSoft = Color(0xFFECFDF5);
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveSoft = Color(0xFFFEE2E2);
}
```

---

## 3. Tipografía (Typography Scale)

El sistema tipográfico combina la geometría amigable y tabular de **Outfit** para métricas y encabezados con la neutralidad funcional de **Inter** para lectura y formularios.

> **Regla de oro:** No usar emojis en títulos ni métricas técnicas; utilizar iconografía vectorial stroke limpia.

| Token | Familia | Tamaño | Peso | Line Height | Letter Spacing | Uso |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `display-timer` | Outfit | `64px` | SemiBold (600) | `72px` | `-0.03em` | Reloj principal (Desktop / Tablet / Mobile amplio) |
| `display-timer-mobile`| Outfit | `56px` | SemiBold (600) | `64px` | `-0.03em` | Reloj en pantallas compactas (<380px) |
| `headline-lg` | Outfit | `32px` | SemiBold (600) | `40px` | `-0.02em` | Títulos de pantalla (Timer, Stats, Premios) |
| `headline-md` | Outfit | `24px` | SemiBold (600) | `32px` | `-0.01em` | Títulos de sección y tarjetas destacadas |
| `headline-sm` | Outfit | `20px` | SemiBold (600) | `28px` | normal | Encabezados de listas o modales |
| `body-lg` | Inter | `16px` | Regular (400) | `24px` | normal | Texto principal y descripciones |
| `body-md` | Inter | `14px` | Regular (400) | `20px` | normal | Tareas de la lista y ajustes |
| `body-sm` | Inter | `12px` | Regular (400) | `16px` | normal | Metadatos, fechas y notas |
| `label-lg` | Inter | `14px` | SemiBold (600) | `20px` | `+0.01em` | Botones principales y acciones de navegación |
| `label-md` | Inter | `12px` | Medium (500) | `16px` | `+0.02em` | Filtros y chips de selección |
| `label-sm` | Inter | `11px` | Medium (500) | `14px` | `+0.03em` | Etiquetas de navegación inferior |

---

## 4. Espaciado y Cuadrícula (Spacing & Layout)

Basado en una cadencia de múltiplos de **8px** (con sub-grid de **4px** para paddings compactos):

| Token | Valor (rem) | Pixels | Aplicación |
| :--- | :--- | :--- | :--- |
| `space-xs` | `0.25rem` | `4px` | Separación micro entre icono y texto, badges |
| `space-sm` | `0.5rem` | `8px` | Padding interno de chips, separación entre items compactos |
| `space-md` | `1rem` | `16px` | Padding de tarjetas, margen estándar entre elementos |
| `space-lg` | `1.5rem` | `24px` | Padding amplio de tarjetas de estadísticas y modales |
| `space-xl` | `2.0rem` | `32px` | Separación entre bloques mayores (Temporizador a Lista de Tareas) |
| `gutter` | `1rem` | `16px` | Canaleta de grid en Desktop/Tablet (`12px` en mobile) |
| `margin` | `1.25rem` | `20px` | Margen exterior de pantalla (`16px` en mobile) |

---

## 5. Formas y Radios de Borde (Border Radius)

Se utiliza un lenguaje visual **dual-tier**:

1. **Estructuras y Contenedores:** Curvatura controlada de `16px` (`rounded-2xl` / `1rem`).
   - Tarjetas de tareas
   - Paneles de estadísticas
   - Cajas de ajustes y diálogos modales
2. **Interactables y Cápsulas:** Curvatura total `9999px` (`rounded-full`).
   - Botones de acción principales (CTA)
   - Controles circulares flotantes del reloj (Play/Pause, Reset, Skip)
   - Pill de navegación activa
   - Badges y chips de estado

```dart
// Flutter Radii
const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16.0));
const BorderRadius pillRadius = BorderRadius.all(Radius.circular(9999.0));
const BorderRadius inputRadius = BorderRadius.all(Radius.circular(12.0));
const BorderRadius checkboxRadius = BorderRadius.all(Radius.circular(6.0));
```

---

## 6. Elevaciones y Sombras (Depth & Elevation)

- **Nivel 0 (Fondo Base):** `#FAF8FF` / `#F8FAFC` — Plano, sin sombra.
- **Nivel 1 (Tarjetas y Paneles):** Superficie `#FFFFFF`, borde `1px solid #E2E8F0`, sombra:
  ```css
  box-shadow: 0px 2px 8px rgba(15, 23, 42, 0.04);
  ```
- **Nivel 2 (Modales y Flotantes):** Superficie `#FFFFFF`, borde `1px solid #CBD5E1`, sombra:
  ```css
  box-shadow: 0px 8px 24px rgba(15, 23, 42, 0.08);
  ```
- **Nivel 3 (Barra de Navegación Inferior):** `#FFFFFF`, borde superior `1px solid #E2E8F0`, sombra difusa hacia arriba:
  ```css
  box-shadow: 0px -4px 16px rgba(15, 23, 42, 0.03);
  ```

---

## 7. Especificación de Componentes

### 1. Temporizador Circular (Timer Ring & Display)
- **Calibre del Anillo:** Trazo de `8px`.
- **Fondo de la Guía (Track):** `#E2E8F0` con terminaciones redondeadas.
- **Arco de Progreso Activo:** `#2563EB` animado con terminación circular (`StrokeCap.round`).
- **Dígitos Centrales:** Tipografía `display-timer` (`64px` SemiBold Outfit) en color `#0F172A`.

### 2. Botones de Control del Temporizador
- **Play / Pause Principal:** Botón circular flotante de `64x64px`, relleno `#2563EB`, icono blanco (`#FFFFFF`) de `28px`. Al pulsar reduce ligeramente su escala (`scale(0.98)`).
- **Reset / Skip Secundarios:** Botones circulares de `48x48px`, fondo `#F1F5F9`, icono vectorial `#475569` de `20px`.

### 3. Botones Generales
- **Botón Primario:** Altura de `52px`, radio `9999px`, fondo `#2563EB`, texto blanco `#FFFFFF` en estilo `label-lg`.
- **Botón Secundario:** Altura de `44px`, radio `9999px`, fondo `#EFF6FF`, texto `#2563EB`.
- **Botón Destructivo:** Fondo `#FEE2E2`, texto `#EF4444`, radio `9999px`.

### 4. Lista de Tareas y Checkboxes
- **Fila de Tarea:** Fondo `#FFFFFF`, radio `16px`, padding `16px`, borde `1px solid #E2E8F0`.
- **Checkbox:** Tamaño `22x22px`, radio `6px`, borde `1.5px solid #CBD5E1`.
  - Al marcarse: Fondo `#10B981` con icono de check blanco.
  - Texto de la tarea completada: Cambia a `#475569` con tachado (`lineThrough`).

### 5. Barra de Navegación Inferior (Bottom Navigation Bar)
- Fijada en la parte inferior respetando el área segura (`SafeArea`).
- 4 destinos principales:
  1. **Timer** (Temporizador Pomodoro)
  2. **Stats** (Estadísticas y Métricas de Productividad)
  3. **Premios** (Recompensas y Logros)
  4. **Config** (Configuración)
- **Elemento Activo:** Encapsulado en una cápsula pill pastel `#EFF6FF` con padding horizontal de `16px` y vertical de `8px`, icono y texto en `#2563EB`.
- **Elemento Inactivo:** Icono vectorial de `24px` en `#475569`, texto `label-sm` en `#475569`.

---

## 8. Pantallas Extraídas desde Stitch

| Nombre de Pantalla en Stitch | ID en Stitch | Propósito |
| :--- | :--- | :--- |
| **Timer - Pomodoro** | `ab65df7d082d4bd4a2dd25b66f3e1ba0` | Pantalla principal con el contador circular, controles de reproducción y lista rápida de tareas. |
| **Estadísticas - Stats** | `c8db66fd785146df8b98e2199c0b8a7c` | Dashboard con gráfico de sesiones completadas, tiempo enfocado y rachas semanales. |
| **Recompensas - Logros** | `d9194f30d36143e8abffcd6a6d76273d` | Sistema de gamificación con medallas, puntos de foco y desbloqueo de niveles. |
| **Configuración** | `30f712b4cbbb47bd9c9f41ba6fb4e053` | Tiempos de foco (25/50m), descanso corto (5m), descanso largo (15m), sonidos y notificaciones. |

---

## 9. Configuración para Tailwind CSS (`tailwind.config.js`)

Si se requiere exportar estos tokens a Tailwind CSS o para componentes web:

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx,vue}",
  ],
  theme: {
    extend: {
      colors: {
        focus: {
          primary: '#2563eb',
          'primary-soft': '#eff6ff',
          'primary-dark': '#004ac6',
          bg: '#faf8ff',
          surface: '#ffffff',
          'surface-container': '#eaedff',
          text: '#0f172a',
          'text-muted': '#475569',
          border: '#e2e8f0',
          'border-medium': '#cbd5e1',
          success: '#10b981',
          'success-soft': '#ecfdf5',
          destructive: '#ef4444',
          'destructive-soft': '#fee2e2',
        }
      },
      fontFamily: {
        outfit: ['Outfit', 'sans-serif'],
        inter: ['Inter', 'sans-serif'],
      },
      fontSize: {
        'display-timer': ['64px', { lineHeight: '72px', letterSpacing: '-0.03em', fontWeight: '600' }],
        'display-timer-mobile': ['56px', { lineHeight: '64px', letterSpacing: '-0.03em', fontWeight: '600' }],
      },
      borderRadius: {
        'card': '16px',
        'input': '12px',
        'checkbox': '6px',
      },
      boxShadow: {
        'level-1': '0px 2px 8px rgba(15, 23, 42, 0.04)',
        'level-2': '0px 8px 24px rgba(15, 23, 42, 0.08)',
        'nav-bottom': '0px -4px 16px rgba(15, 23, 42, 0.03)',
      }
    },
  },
  plugins: [],
}
```
