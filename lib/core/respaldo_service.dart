import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';

/// Respaldo manual de GeoLift: exporta toda la base a un archivo que el
/// usuario guarda donde quiera (Drive, WhatsApp, correo…) con el menú de
/// compartir del sistema, y la restaura desde un archivo elegido.
///
/// La app es 100% local: sin esto, reinstalarla o cambiar de teléfono
/// borra todo el historial.
class RespaldoService {
  /// Exporta la base a un archivo temporal y abre el menú de compartir.
  /// Devuelve false si el usuario cerró el menú sin compartir.
  Future<bool> exportarYCompartir(AppDatabase db) async {
    final carpeta = await getTemporaryDirectory();
    final fecha = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    final archivo =
        File(p.join(carpeta.path, 'geolift-respaldo-$fecha.sqlite'));
    // VACUUM INTO no sobrescribe: falla si el archivo ya existe.
    if (await archivo.exists()) await archivo.delete();

    await db.exportarA(archivo.path);

    final resultado = await SharePlus.instance.share(ShareParams(
      files: [XFile(archivo.path, mimeType: 'application/octet-stream')],
      subject: 'Respaldo de GeoLift',
      text: 'Respaldo de GeoLift del $fecha. Para recuperarlo: Ajustes → '
          'Restaurar respaldo.',
    ));
    return resultado.status != ShareResultStatus.dismissed;
  }

  /// Deja elegir un archivo de respaldo y reemplaza con él todos los datos.
  /// Devuelve false si el usuario no eligió nada. Lanza [RespaldoInvalido]
  /// si el archivo no sirve (en ese caso no se toca ningún dato).
  Future<bool> elegirYRestaurar(AppDatabase db) async {
    final elegido = await FilePicker.pickFile(
      dialogTitle: 'Elige tu respaldo de GeoLift',
    );
    if (elegido == null) return false;

    // En Android el archivo llega como content:// (sin ruta local): se lee
    // y se escribe a una copia temporal que SQLite sí puede abrir.
    final bytes = await elegido.xFile.readAsBytes();
    final carpeta = await getTemporaryDirectory();
    final copia = File(p.join(carpeta.path, 'geolift-restaurar.sqlite'));
    await copia.writeAsBytes(bytes, flush: true);
    try {
      await db.restaurarDesde(copia.path);
    } finally {
      if (await copia.exists()) await copia.delete();
    }
    return true;
  }
}
