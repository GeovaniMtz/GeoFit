import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'router.dart';

/// Notificación local (no interactiva, solo "tocar para volver") con el
/// progreso de la sesión de entrenamiento activa — ejercicio y serie
/// actuales — para poder verla en la pantalla de bloqueo sin desbloquear ni
/// navegar la app. No depende de un foreground service: bloquear el
/// teléfono o salir de la app sin cerrarla no destruye el estado de
/// Flutter, así que basta con mostrarla mientras la app sigue en primer
/// plano para que quede visible (congelada en el último estado) al
/// bloquear. Si Android mata el proceso por memoria, la notificación queda
/// obsoleta — limitación conocida y aceptada en esta fase.
class NotificacionEntrenamientoService {
  NotificacionEntrenamientoService();

  /// Id fijo: repetir show() con este mismo id reemplaza la notificación
  /// existente en vez de apilar una nueva por cada serie registrada.
  static const int _idNotificacion = 7001;

  static const String _canalId = 'entrenamiento_progreso';
  static const String _canalNombre = 'Progreso de entrenamiento';
  static const String _canalDescripcion =
      'Ejercicio y serie actuales de la sesión de entrenamiento activa.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _inicializado = false;

  /// Inicializa el plugin la primera vez que hace falta, en vez de en
  /// main.dart: así arrancar la app no paga este costo si el usuario nunca
  /// entra a entrenar.
  Future<void> _asegurarInicializado() async {
    if (_inicializado) return;
    const configAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    // No pedir permiso aquí (todo en false): el único punto donde se pide
    // es solicitarPermiso(), llamado explícitamente al empezar una sesión.
    const configIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: configAndroid,
        iOS: configIOS,
      ),
      onDidReceiveNotificationResponse: _alTocarNotificacion,
    );
    _inicializado = true;
  }

  /// Al tocar la notificación (con la app todavía viva, aunque bloqueada o
  /// en segundo plano) navega de vuelta a esa sesión de "Entrenar". No
  /// cubre el arranque en frío con la app totalmente cerrada — fuera de
  /// alcance en esta fase.
  static void _alTocarNotificacion(NotificationResponse respuesta) {
    final rutinaDiaId = respuesta.payload;
    if (rutinaDiaId == null) return;
    appRouter.go('/entrenar/$rutinaDiaId');
  }

  /// Pide permiso de notificaciones (Android 13+ / iOS). Se llama al
  /// empezar una sesión de entrenamiento, no al abrir la app. Si se niega,
  /// el resto de la app sigue funcionando igual — solo sin notificación.
  Future<void> solicitarPermiso() async {
    await _asegurarInicializado();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true);
  }

  /// Muestra (o actualiza, si ya está visible) la notificación de progreso
  /// de la sesión activa.
  Future<void> mostrarProgreso({
    required int rutinaDiaId,
    required String nombreEjercicio,
    required int numeroEjercicio,
    required int totalEjercicios,
    required int numeroSet,
    required int totalSets,
  }) async {
    await _asegurarInicializado();
    const detalleAndroid = AndroidNotificationDetails(
      _canalId,
      _canalNombre,
      channelDescription: _canalDescripcion,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      // Solo suena/vibra la primera vez que aparece en la sesión; las
      // actualizaciones de texto en cada serie son silenciosas.
      onlyAlertOnce: true,
      autoCancel: false,
      visibility: NotificationVisibility.public,
    );
    // Todo en false: mientras la app está en primer plano, la pantalla de
    // Entrenar ya muestra esto en vivo, no hace falta un banner encima; al
    // bloquear/salir, iOS la muestra igual en la pantalla de bloqueo.
    const detalleIOS = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );
    await _plugin.show(
      id: _idNotificacion,
      title: 'Ejercicio $numeroEjercicio de $totalEjercicios: '
          '$nombreEjercicio',
      body: 'Serie $numeroSet/$totalSets',
      notificationDetails: const NotificationDetails(
        android: detalleAndroid,
        iOS: detalleIOS,
      ),
      payload: '$rutinaDiaId',
    );
  }

  /// Retira la notificación de progreso — sesión completa o se salió de
  /// "Entrenar". Sin efecto si ya no había ninguna visible.
  Future<void> cancelar() async {
    await _asegurarInicializado();
    await _plugin.cancel(id: _idNotificacion);
  }
}
