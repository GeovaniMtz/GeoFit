# GeoLift

App de gym: rutinas, sesiones de entrenamiento, progreso y sugerencias de
mejora. 100% local (sin cuentas ni nube), pensada para usarse con el celular
en la mano entre series.

## Estado actual

El proyecto ya corre: `flutter pub get`, `dart run build_runner build` y
`flutter run` se ejecutaron sobre él, y se probó en un Android físico
(`flutter run -d <device>`). No es un repositorio git todavía.

Si notas la app lenta (scroll, transiciones), primero confirma que no la
estás corriendo en modo debug plano (`flutter run` sin flags) — el modo
debug (JIT, asserts, compilación de shaders la primera vez) explica casi
toda la lentitud percibida. Prueba con `flutter run --profile -d <device>`
antes de asumir que hay un bug.

## Qué contiene

- `lib/data/tables.dart` + `lib/data/database.dart` — las 8 tablas en Drift
  (SQLite): `Ejercicios`, `Rutinas`, `RutinaDias`, `RutinaEjercicios`,
  `SesionesEntrenamiento`, `RegistrosSet`, `RegistrosPesoCorporal`,
  `Configuracion`. `lib/data/queries/` trae las consultas agrupadas por
  tabla/tema.
- `lib/domain/` — lógica pura de Dart (sin Flutter ni Drift), con tests:
  - `progresion_service.dart` — motor de sugerencias (subir peso, deload,
    e1RM con la fórmula de Epley, volumen).
  - `clasificador_ejercicio.dart` — sugiere el descanso por defecto según
    si el ejercicio es de máquina o de peso libre.
  - `planificador_rutina.dart` — decide qué día de la rutina toca entrenar
    hoy, rotando desde el último día entrenado.
- `lib/presentation/` — pantallas (Inicio, Rutinas, Entrenar, Progreso,
  Historial, Ajustes), sus widgets, providers de Riverpod y el shell de
  navegación (`MainShell`, con `IndexedStack` perezoso: cada tab solo
  construye su árbol y dispara sus queries la primera vez que se visita).
- `lib/core/` — tema visual (claro/oscuro) y rutas (`go_router`).
- `test/domain/` y `test/presentation/` — tests de la capa de dominio y
  tests de widgets para las pantallas principales.

## Funcionalidades

- **Rutinas**: crear, **editar** (precarga días y ejercicios existentes) y
  archivar rutinas con días y ejercicios objetivo (series, rango de reps,
  descanso).
- **Entrenar**: sesión enfocada en un ejercicio a la vez, con controles
  grandes para registrar peso/reps por serie y temporizador de descanso;
  al terminar el ejercicio avanza al siguiente.
- **Progreso**: gráfica de e1RM por ejercicio y gráfica de peso corporal
  (con registro manual desde la misma pantalla).
- **Historial**: listado de sesiones de entrenamiento pasadas.
- **Ajustes**: apariencia (sistema / claro / oscuro), persistida en la
  tabla `Configuracion`.
- El catálogo de ejercicios arranca con 4 ejemplos (Sentadilla, Press de
  banca, Peso muerto, Press militar); agregar uno nuevo desde el
  formulario de rutina lo crea al vuelo.

## Lo que falta / está simplificado

- No hay autenticación ni sincronización en la nube — es 100% local
  (posible v2).
- En Progreso todavía no hay volumen semanal por grupo muscular (solo
  e1RM por ejercicio y peso corporal) — ver "Próximos pasos".
- No es un repositorio git; si quieres versionarlo, `git init` cuando
  quieras.

## Ponerlo a andar

Necesitas Flutter instalado con acceso normal a internet.

1. Instala dependencias y genera el código de Drift (si no lo hiciste ya):
   ```
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```
2. Verifica y corre:
   ```
   flutter analyze
   flutter test
   flutter run
   ```
   Para probar en un dispositivo físico sin el overhead del modo debug:
   ```
   flutter run --profile -d <device>
   ```

## Próximos pasos sugeridos

Volumen semanal por grupo muscular en la pantalla de Progreso (las
gráficas de e1RM y peso corporal ya están). Después de eso, evaluar la
Fase 2 del plan (sincronización / cuenta de usuario).
