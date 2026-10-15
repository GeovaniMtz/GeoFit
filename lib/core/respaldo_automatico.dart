import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/database.dart';

/// Respaldo semanal automático en una carpeta visible del teléfono
/// (Documentos/GeoLift en Android).
///
/// No corre en segundo plano: se revisa cada vez que se abre la app, y si el
/// último respaldo tiene [intervalo] o más, se crea uno nuevo. Si la app no
/// se abre, tampoco hay datos nuevos que respaldar.
///
/// La fecha del último respaldo se deduce de los propios archivos (van
/// fechados en el nombre), así que no hace falta guardarla en la base.
class RespaldoAutomatico {
  /// Carpeta donde se guardan los respaldos.
  final Directory carpeta;

  final Duration intervalo;

  /// Cuántos respaldos automáticos se conservan; los más viejos se borran.
  final int conservar;

  RespaldoAutomatico(
    this.carpeta, {
    this.intervalo = const Duration(days: 7),
    this.conservar = 4,
  });

  static const _prefijo = 'geolift-auto-';
  static const _extension = '.sqlite';
  static final _formato = DateFormat('yyyy-MM-dd_HHmm');
  // Mismo formato que [_formato], para leer la fecha de vuelta del nombre.
  static final _patronFecha =
      RegExp(r'^(\d{4})-(\d{2})-(\d{2})_(\d{2})(\d{2})$');

  /// Los respaldos automáticos que hay en [carpeta], del más nuevo al más
  /// viejo. Solo cuenta los archivos con el nombre que genera esta clase.
  Future<List<({File archivo, DateTime fecha})>> respaldos() async {
    if (!await carpeta.exists()) return const [];
    final encontrados = <({File archivo, DateTime fecha})>[];
    await for (final entidad in carpeta.list()) {
      if (entidad is! File) continue;
      final fecha = _fechaDeNombre(p.basename(entidad.path));
      if (fecha != null) encontrados.add((archivo: entidad, fecha: fecha));
    }
    encontrados.sort((a, b) => b.fecha.compareTo(a.fecha));
    return encontrados;
  }

  Future<DateTime?> ultimo() async {
    final lista = await respaldos();
    return lista.isEmpty ? null : lista.first.fecha;
  }

  /// Crea un respaldo si ya toca (nunca se ha hecho, o el último tiene
  /// [intervalo] o más) y poda los viejos. Devuelve el archivo creado, o
  /// null si todavía no tocaba.
  Future<File?> respaldarSiToca(AppDatabase db, {DateTime? ahora}) async {
    final momento = ahora ?? DateTime.now();
    final anterior = await ultimo();
    if (anterior != null && momento.difference(anterior) < intervalo) {
      return null;
    }

    await carpeta.create(recursive: true);
    final archivo = File(p.join(
        carpeta.path, '$_prefijo${_formato.format(momento)}$_extension'));
    // VACUUM INTO no sobrescribe; solo pasaría si se corre dos veces en el
    // mismo minuto.
    if (await archivo.exists()) await archivo.delete();
    await db.exportarA(archivo.path);

    await _podar();
    return archivo;
  }

  Future<void> _podar() async {
    final lista = await respaldos();
    for (final viejo in lista.skip(conservar)) {
      try {
        await viejo.archivo.delete();
      } catch (_) {
        // Tras reinstalar, Android no deja borrar archivos que creó la
        // instalación anterior: se quedan, no pasa nada.
      }
    }
  }

  static DateTime? _fechaDeNombre(String nombre) {
    if (!nombre.startsWith(_prefijo) || !nombre.endsWith(_extension)) {
      return null;
    }
    final m = _patronFecha.firstMatch(
        nombre.substring(_prefijo.length, nombre.length - _extension.length));
    if (m == null) return null;
    final [
      anio,
      mes,
      dia,
      hora,
      minuto
    ] = [for (var i = 1; i <= 5; i++) int.parse(m.group(i)!)];
    return DateTime(anio, mes, dia, hora, minuto);
  }
}

/// Carpeta para los respaldos automáticos.
///
/// En Android se prefiere Documentos/GeoLift: es visible desde el
/// administrador de archivos y, a diferencia de las carpetas propias de la
/// app, NO se borra al desinstalarla. Desde Android 11 la app puede crear
/// archivos ahí sin pedir permisos; si el teléfono no lo permite (Android
/// 10 o anterior), se usa la carpeta externa de la app, que sí se borra al
/// desinstalar — para eso queda el respaldo manual.
Future<Directory> carpetaRespaldoAutomatico() async {
  if (Platform.isAndroid) {
    final externa = await getExternalStorageDirectory();
    if (externa != null) {
      // /storage/emulated/0/Android/data/<paquete>/files → /storage/emulated/0
      final raiz =
          externa.path.split('${p.separator}Android${p.separator}').first;
      final publica = Directory(p.join(raiz, 'Documents', 'GeoLift'));
      if (await _sePuedeEscribir(publica)) return publica;
      return Directory(p.join(externa.path, 'respaldos'));
    }
  }
  final documentos = await getApplicationDocumentsDirectory();
  return Directory(p.join(documentos.path, 'respaldos'));
}

Future<bool> _sePuedeEscribir(Directory carpeta) async {
  try {
    await carpeta.create(recursive: true);
    // Nombre único: tras reinstalar, Android no deja tocar archivos que
    // creó la instalación anterior.
    final prueba = File(p.join(carpeta.path,
        '.geolift-prueba-${DateTime.now().microsecondsSinceEpoch}'));
    await prueba.writeAsString('ok', flush: true);
    await prueba.delete();
    return true;
  } catch (_) {
    return false;
  }
}
