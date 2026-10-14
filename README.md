# GeoLift

App de gym: rutinas, sesiones de entrenamiento, progreso y sugerencias de
mejora. 100% local (sin cuentas ni nube), pensada para usarse con el celular
en la mano entre series.

## Estado actual

El proyecto corre y está versionado en git (remoto `GeovaniMtz/GeoFit` en
GitHub). `develop` tiene la base estable; las funcionalidades nuevas se
desarrollan en ramas `feature/*` (p. ej. `feature/notificaciones`, que
agregó la notificación de progreso y el importador de rutinas por texto).
Se probó en Android físico con `flutter run -d <device>`.

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
  - `importador_rutina.dart` — convierte una rutina pegada como texto
    libre en días/ejercicios estructurados y la empareja contra el
    catálogo existente (Levenshtein + solapamiento de palabras) para no
    crear duplicados por typos o variantes de redacción.
- `lib/presentation/` — pantallas (Inicio, Rutinas, Entrenar, Progreso,
  Historial, Ajustes, Importar rutina), sus widgets, providers de Riverpod
  y el shell de navegación (`MainShell`, con `IndexedStack` perezoso: cada
  tab solo construye su árbol y dispara sus queries la primera vez que se
  visita).
- `lib/core/` — tema visual (claro/oscuro), rutas (`go_router`) y
  `notification_service.dart` (notificación local de progreso de la
  sesión activa, ver "Funcionalidades").
- `test/domain/` y `test/presentation/` — tests de la capa de dominio y
  tests de widgets para las pantallas principales.

## Funcionalidades

- **Rutinas**: crear, **editar** (precarga días y ejercicios existentes) y
  archivar rutinas con días y ejercicios objetivo (series, rango de reps,
  descanso). También se pueden duplicar días dentro del formulario.
- **Importar rutina**: pegar una rutina completa como texto libre (de una
  nota, cuaderno, etc.) y convertirla automáticamente en días/ejercicios,
  emparejando contra el catálogo existente antes de pasarla al formulario
  para revisar y guardar.
- **Entrenar**: sesión enfocada en un ejercicio a la vez, con controles
  grandes para registrar peso/reps por serie y temporizador de descanso;
  al terminar el ejercicio avanza al siguiente. Retoma la sesión del día si
  se sale y se vuelve a entrar sin reiniciar el progreso.
  Cada serie puede llevar un **RPE** opcional (esfuerzo percibido 6–10) y
  la sesión guarda su **duración** tras cada serie.
- **Sugerencias de progresión**: al abrir un ejercicio en Entrenar, el motor
  de `progresion_service.dart` revisa las sesiones anteriores y muestra qué
  hacer hoy (subir, mantener o descargar), con el peso ya precargado. Con
  RPE puede subir tras una sola sesión al tope con reps de sobra (RPE ≤ 8) o
  pedir mantener si se llegó al tope al límite (RPE ≥ 9.5); sin RPE usa la
  regla de 2 sesiones seguidas.
- **Notificación de progreso**: mientras hay una sesión activa, una
  notificación local (no interactiva) muestra el ejercicio y la serie
  actuales, visible desde la pantalla de bloqueo sin desbloquear el
  teléfono. Se retira al terminar la sesión o al salir de "Entrenar". Fase
  1 del plan de notificaciones; la Fase 2 (acción interactiva desde la
  propia notificación) todavía no está implementada.
- **Progreso**: gráfica de e1RM por ejercicio (con marca de mejor PR) y
  gráfica de peso corporal (con registro manual desde la misma pantalla).
- **Historial**: listado de sesiones de entrenamiento pasadas con sets,
  volumen total, duración y notas. Tocar una sesión permite escribir o
  corregir su nota (también se puede anotar al terminar la rutina).
- **Ajustes**: apariencia (sistema / claro / oscuro) y unidad de peso
  (kg / lb), persistidas en la tabla `Configuracion`. La base siempre
  guarda kg: la unidad solo cambia cómo se muestran y capturan los pesos
  (`lib/domain/unidad_peso.dart`).
- El catálogo de ejercicios arranca con 4 ejemplos (Sentadilla, Press de
  banca, Peso muerto, Press militar); agregar uno nuevo desde el
  formulario de rutina o desde el importador lo crea al vuelo.

## Lo que falta / está simplificado

- No hay autenticación ni sincronización en la nube — es 100% local
  (posible v2).
- No hay respaldo / restauración: reinstalar la app (o instalarla con otra
  firma de debug) borra todos los datos — ver "Próximos pasos".
- En Progreso todavía no hay volumen semanal por grupo muscular (solo
  e1RM por ejercicio y peso corporal) — ver "Próximos pasos".
- La notificación de progreso no sobrevive a que Android mate el proceso
  por memoria (no usa un foreground service) ni permite acciones directas
  desde ella todavía — ver "Fase 2" arriba.

## Ponerlo a andar

Necesitas Flutter instalado con acceso normal a internet.

1. Clona el repo e instala dependencias:
   ```
   git clone git@github.com:GeovaniMtz/GeoFit.git
   cd GeoFit
   flutter pub get
   ```
2. Genera el código de Drift:
   ```
   dart run build_runner build --delete-conflicting-outputs
   ```
3. Verifica y corre:
   ```
   flutter analyze
   flutter test
   flutter run
   ```
   Para probar en un dispositivo físico sin el overhead del modo debug:
   ```
   flutter run --profile -d <device>
   ```

   En Windows, si `flutter pub get` falla con "no se puede mover el archivo
   a otra unidad" o Kotlin falla con "different roots", pon la caché de
   paquetes en el mismo disco que el proyecto y fuera de `AppData`, p. ej.
   `PUB_CACHE=C:\src\pub-cache`.

## Próximos pasos sugeridos

1. Respaldo y restauración de la base (exportar a un archivo para
   compartir e importarlo de vuelta).
2. Detalle de una sesión en Historial (series, peso, reps, RPE y PRs).
3. Volumen semanal por grupo muscular en la pantalla de Progreso (las
   gráficas de e1RM y peso corporal ya están).
4. Fase 2 de notificaciones: acción interactiva (p. ej. registrar la
   siguiente serie) directamente desde la notificación de progreso.
5. Evaluar sincronización / cuenta de usuario (fuera de alcance por ahora,
   la app es 100% local).
