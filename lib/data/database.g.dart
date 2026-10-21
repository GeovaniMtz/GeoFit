// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EjerciciosTable extends Ejercicios
    with TableInfo<$EjerciciosTable, Ejercicio> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EjerciciosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _grupoMuscularMeta =
      const VerificationMeta('grupoMuscular');
  @override
  late final GeneratedColumn<String> grupoMuscular = GeneratedColumn<String>(
      'grupo_muscular', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _equipoMeta = const VerificationMeta('equipo');
  @override
  late final GeneratedColumn<String> equipo = GeneratedColumn<String>(
      'equipo', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _esPersonalizadoMeta =
      const VerificationMeta('esPersonalizado');
  @override
  late final GeneratedColumn<bool> esPersonalizado = GeneratedColumn<bool>(
      'es_personalizado', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("es_personalizado" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, nombre, grupoMuscular, equipo, esPersonalizado];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ejercicios';
  @override
  VerificationContext validateIntegrity(Insertable<Ejercicio> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('grupo_muscular')) {
      context.handle(
          _grupoMuscularMeta,
          grupoMuscular.isAcceptableOrUnknown(
              data['grupo_muscular']!, _grupoMuscularMeta));
    } else if (isInserting) {
      context.missing(_grupoMuscularMeta);
    }
    if (data.containsKey('equipo')) {
      context.handle(_equipoMeta,
          equipo.isAcceptableOrUnknown(data['equipo']!, _equipoMeta));
    }
    if (data.containsKey('es_personalizado')) {
      context.handle(
          _esPersonalizadoMeta,
          esPersonalizado.isAcceptableOrUnknown(
              data['es_personalizado']!, _esPersonalizadoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ejercicio map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ejercicio(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      grupoMuscular: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grupo_muscular'])!,
      equipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}equipo'])!,
      esPersonalizado: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}es_personalizado'])!,
    );
  }

  @override
  $EjerciciosTable createAlias(String alias) {
    return $EjerciciosTable(attachedDatabase, alias);
  }
}

class Ejercicio extends DataClass implements Insertable<Ejercicio> {
  final int id;
  final String nombre;
  final String grupoMuscular;
  final String equipo;
  final bool esPersonalizado;
  const Ejercicio(
      {required this.id,
      required this.nombre,
      required this.grupoMuscular,
      required this.equipo,
      required this.esPersonalizado});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['grupo_muscular'] = Variable<String>(grupoMuscular);
    map['equipo'] = Variable<String>(equipo);
    map['es_personalizado'] = Variable<bool>(esPersonalizado);
    return map;
  }

  EjerciciosCompanion toCompanion(bool nullToAbsent) {
    return EjerciciosCompanion(
      id: Value(id),
      nombre: Value(nombre),
      grupoMuscular: Value(grupoMuscular),
      equipo: Value(equipo),
      esPersonalizado: Value(esPersonalizado),
    );
  }

  factory Ejercicio.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ejercicio(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      grupoMuscular: serializer.fromJson<String>(json['grupoMuscular']),
      equipo: serializer.fromJson<String>(json['equipo']),
      esPersonalizado: serializer.fromJson<bool>(json['esPersonalizado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'grupoMuscular': serializer.toJson<String>(grupoMuscular),
      'equipo': serializer.toJson<String>(equipo),
      'esPersonalizado': serializer.toJson<bool>(esPersonalizado),
    };
  }

  Ejercicio copyWith(
          {int? id,
          String? nombre,
          String? grupoMuscular,
          String? equipo,
          bool? esPersonalizado}) =>
      Ejercicio(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        grupoMuscular: grupoMuscular ?? this.grupoMuscular,
        equipo: equipo ?? this.equipo,
        esPersonalizado: esPersonalizado ?? this.esPersonalizado,
      );
  Ejercicio copyWithCompanion(EjerciciosCompanion data) {
    return Ejercicio(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      grupoMuscular: data.grupoMuscular.present
          ? data.grupoMuscular.value
          : this.grupoMuscular,
      equipo: data.equipo.present ? data.equipo.value : this.equipo,
      esPersonalizado: data.esPersonalizado.present
          ? data.esPersonalizado.value
          : this.esPersonalizado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ejercicio(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('grupoMuscular: $grupoMuscular, ')
          ..write('equipo: $equipo, ')
          ..write('esPersonalizado: $esPersonalizado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, grupoMuscular, equipo, esPersonalizado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ejercicio &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.grupoMuscular == this.grupoMuscular &&
          other.equipo == this.equipo &&
          other.esPersonalizado == this.esPersonalizado);
}

class EjerciciosCompanion extends UpdateCompanion<Ejercicio> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> grupoMuscular;
  final Value<String> equipo;
  final Value<bool> esPersonalizado;
  const EjerciciosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.grupoMuscular = const Value.absent(),
    this.equipo = const Value.absent(),
    this.esPersonalizado = const Value.absent(),
  });
  EjerciciosCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required String grupoMuscular,
    this.equipo = const Value.absent(),
    this.esPersonalizado = const Value.absent(),
  })  : nombre = Value(nombre),
        grupoMuscular = Value(grupoMuscular);
  static Insertable<Ejercicio> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? grupoMuscular,
    Expression<String>? equipo,
    Expression<bool>? esPersonalizado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (grupoMuscular != null) 'grupo_muscular': grupoMuscular,
      if (equipo != null) 'equipo': equipo,
      if (esPersonalizado != null) 'es_personalizado': esPersonalizado,
    });
  }

  EjerciciosCompanion copyWith(
      {Value<int>? id,
      Value<String>? nombre,
      Value<String>? grupoMuscular,
      Value<String>? equipo,
      Value<bool>? esPersonalizado}) {
    return EjerciciosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      grupoMuscular: grupoMuscular ?? this.grupoMuscular,
      equipo: equipo ?? this.equipo,
      esPersonalizado: esPersonalizado ?? this.esPersonalizado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (grupoMuscular.present) {
      map['grupo_muscular'] = Variable<String>(grupoMuscular.value);
    }
    if (equipo.present) {
      map['equipo'] = Variable<String>(equipo.value);
    }
    if (esPersonalizado.present) {
      map['es_personalizado'] = Variable<bool>(esPersonalizado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EjerciciosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('grupoMuscular: $grupoMuscular, ')
          ..write('equipo: $equipo, ')
          ..write('esPersonalizado: $esPersonalizado')
          ..write(')'))
        .toString();
  }
}

class $RutinasTable extends Rutinas with TableInfo<$RutinasTable, Rutina> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RutinasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _activaMeta = const VerificationMeta('activa');
  @override
  late final GeneratedColumn<bool> activa = GeneratedColumn<bool>(
      'activa', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activa" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _creadaEnMeta =
      const VerificationMeta('creadaEn');
  @override
  late final GeneratedColumn<DateTime> creadaEn = GeneratedColumn<DateTime>(
      'creada_en', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, nombre, activa, creadaEn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rutinas';
  @override
  VerificationContext validateIntegrity(Insertable<Rutina> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('activa')) {
      context.handle(_activaMeta,
          activa.isAcceptableOrUnknown(data['activa']!, _activaMeta));
    }
    if (data.containsKey('creada_en')) {
      context.handle(_creadaEnMeta,
          creadaEn.isAcceptableOrUnknown(data['creada_en']!, _creadaEnMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Rutina map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rutina(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      activa: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activa'])!,
      creadaEn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}creada_en'])!,
    );
  }

  @override
  $RutinasTable createAlias(String alias) {
    return $RutinasTable(attachedDatabase, alias);
  }
}

class Rutina extends DataClass implements Insertable<Rutina> {
  final int id;
  final String nombre;
  final bool activa;
  final DateTime creadaEn;
  const Rutina(
      {required this.id,
      required this.nombre,
      required this.activa,
      required this.creadaEn});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['activa'] = Variable<bool>(activa);
    map['creada_en'] = Variable<DateTime>(creadaEn);
    return map;
  }

  RutinasCompanion toCompanion(bool nullToAbsent) {
    return RutinasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      activa: Value(activa),
      creadaEn: Value(creadaEn),
    );
  }

  factory Rutina.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rutina(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      activa: serializer.fromJson<bool>(json['activa']),
      creadaEn: serializer.fromJson<DateTime>(json['creadaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'activa': serializer.toJson<bool>(activa),
      'creadaEn': serializer.toJson<DateTime>(creadaEn),
    };
  }

  Rutina copyWith(
          {int? id, String? nombre, bool? activa, DateTime? creadaEn}) =>
      Rutina(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        activa: activa ?? this.activa,
        creadaEn: creadaEn ?? this.creadaEn,
      );
  Rutina copyWithCompanion(RutinasCompanion data) {
    return Rutina(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      activa: data.activa.present ? data.activa.value : this.activa,
      creadaEn: data.creadaEn.present ? data.creadaEn.value : this.creadaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rutina(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('activa: $activa, ')
          ..write('creadaEn: $creadaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, activa, creadaEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rutina &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.activa == this.activa &&
          other.creadaEn == this.creadaEn);
}

class RutinasCompanion extends UpdateCompanion<Rutina> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<bool> activa;
  final Value<DateTime> creadaEn;
  const RutinasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.activa = const Value.absent(),
    this.creadaEn = const Value.absent(),
  });
  RutinasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.activa = const Value.absent(),
    this.creadaEn = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Rutina> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<bool>? activa,
    Expression<DateTime>? creadaEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (activa != null) 'activa': activa,
      if (creadaEn != null) 'creada_en': creadaEn,
    });
  }

  RutinasCompanion copyWith(
      {Value<int>? id,
      Value<String>? nombre,
      Value<bool>? activa,
      Value<DateTime>? creadaEn}) {
    return RutinasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      activa: activa ?? this.activa,
      creadaEn: creadaEn ?? this.creadaEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (activa.present) {
      map['activa'] = Variable<bool>(activa.value);
    }
    if (creadaEn.present) {
      map['creada_en'] = Variable<DateTime>(creadaEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RutinasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('activa: $activa, ')
          ..write('creadaEn: $creadaEn')
          ..write(')'))
        .toString();
  }
}

class $RutinaDiasTable extends RutinaDias
    with TableInfo<$RutinaDiasTable, RutinaDia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RutinaDiasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rutinaIdMeta =
      const VerificationMeta('rutinaId');
  @override
  late final GeneratedColumn<int> rutinaId = GeneratedColumn<int>(
      'rutina_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rutinas (id) ON DELETE CASCADE'));
  static const VerificationMeta _nombreDiaMeta =
      const VerificationMeta('nombreDia');
  @override
  late final GeneratedColumn<String> nombreDia = GeneratedColumn<String>(
      'nombre_dia', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
      'orden', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, rutinaId, nombreDia, orden];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rutina_dias';
  @override
  VerificationContext validateIntegrity(Insertable<RutinaDia> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rutina_id')) {
      context.handle(_rutinaIdMeta,
          rutinaId.isAcceptableOrUnknown(data['rutina_id']!, _rutinaIdMeta));
    } else if (isInserting) {
      context.missing(_rutinaIdMeta);
    }
    if (data.containsKey('nombre_dia')) {
      context.handle(_nombreDiaMeta,
          nombreDia.isAcceptableOrUnknown(data['nombre_dia']!, _nombreDiaMeta));
    } else if (isInserting) {
      context.missing(_nombreDiaMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
          _ordenMeta, orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RutinaDia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RutinaDia(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rutinaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rutina_id'])!,
      nombreDia: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre_dia'])!,
      orden: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}orden'])!,
    );
  }

  @override
  $RutinaDiasTable createAlias(String alias) {
    return $RutinaDiasTable(attachedDatabase, alias);
  }
}

class RutinaDia extends DataClass implements Insertable<RutinaDia> {
  final int id;
  final int rutinaId;
  final String nombreDia;
  final int orden;
  const RutinaDia(
      {required this.id,
      required this.rutinaId,
      required this.nombreDia,
      required this.orden});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rutina_id'] = Variable<int>(rutinaId);
    map['nombre_dia'] = Variable<String>(nombreDia);
    map['orden'] = Variable<int>(orden);
    return map;
  }

  RutinaDiasCompanion toCompanion(bool nullToAbsent) {
    return RutinaDiasCompanion(
      id: Value(id),
      rutinaId: Value(rutinaId),
      nombreDia: Value(nombreDia),
      orden: Value(orden),
    );
  }

  factory RutinaDia.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RutinaDia(
      id: serializer.fromJson<int>(json['id']),
      rutinaId: serializer.fromJson<int>(json['rutinaId']),
      nombreDia: serializer.fromJson<String>(json['nombreDia']),
      orden: serializer.fromJson<int>(json['orden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rutinaId': serializer.toJson<int>(rutinaId),
      'nombreDia': serializer.toJson<String>(nombreDia),
      'orden': serializer.toJson<int>(orden),
    };
  }

  RutinaDia copyWith({int? id, int? rutinaId, String? nombreDia, int? orden}) =>
      RutinaDia(
        id: id ?? this.id,
        rutinaId: rutinaId ?? this.rutinaId,
        nombreDia: nombreDia ?? this.nombreDia,
        orden: orden ?? this.orden,
      );
  RutinaDia copyWithCompanion(RutinaDiasCompanion data) {
    return RutinaDia(
      id: data.id.present ? data.id.value : this.id,
      rutinaId: data.rutinaId.present ? data.rutinaId.value : this.rutinaId,
      nombreDia: data.nombreDia.present ? data.nombreDia.value : this.nombreDia,
      orden: data.orden.present ? data.orden.value : this.orden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RutinaDia(')
          ..write('id: $id, ')
          ..write('rutinaId: $rutinaId, ')
          ..write('nombreDia: $nombreDia, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rutinaId, nombreDia, orden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RutinaDia &&
          other.id == this.id &&
          other.rutinaId == this.rutinaId &&
          other.nombreDia == this.nombreDia &&
          other.orden == this.orden);
}

class RutinaDiasCompanion extends UpdateCompanion<RutinaDia> {
  final Value<int> id;
  final Value<int> rutinaId;
  final Value<String> nombreDia;
  final Value<int> orden;
  const RutinaDiasCompanion({
    this.id = const Value.absent(),
    this.rutinaId = const Value.absent(),
    this.nombreDia = const Value.absent(),
    this.orden = const Value.absent(),
  });
  RutinaDiasCompanion.insert({
    this.id = const Value.absent(),
    required int rutinaId,
    required String nombreDia,
    this.orden = const Value.absent(),
  })  : rutinaId = Value(rutinaId),
        nombreDia = Value(nombreDia);
  static Insertable<RutinaDia> custom({
    Expression<int>? id,
    Expression<int>? rutinaId,
    Expression<String>? nombreDia,
    Expression<int>? orden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rutinaId != null) 'rutina_id': rutinaId,
      if (nombreDia != null) 'nombre_dia': nombreDia,
      if (orden != null) 'orden': orden,
    });
  }

  RutinaDiasCompanion copyWith(
      {Value<int>? id,
      Value<int>? rutinaId,
      Value<String>? nombreDia,
      Value<int>? orden}) {
    return RutinaDiasCompanion(
      id: id ?? this.id,
      rutinaId: rutinaId ?? this.rutinaId,
      nombreDia: nombreDia ?? this.nombreDia,
      orden: orden ?? this.orden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rutinaId.present) {
      map['rutina_id'] = Variable<int>(rutinaId.value);
    }
    if (nombreDia.present) {
      map['nombre_dia'] = Variable<String>(nombreDia.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RutinaDiasCompanion(')
          ..write('id: $id, ')
          ..write('rutinaId: $rutinaId, ')
          ..write('nombreDia: $nombreDia, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }
}

class $RutinaEjerciciosTable extends RutinaEjercicios
    with TableInfo<$RutinaEjerciciosTable, RutinaEjercicio> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RutinaEjerciciosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rutinaDiaIdMeta =
      const VerificationMeta('rutinaDiaId');
  @override
  late final GeneratedColumn<int> rutinaDiaId = GeneratedColumn<int>(
      'rutina_dia_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rutina_dias (id) ON DELETE CASCADE'));
  static const VerificationMeta _ejercicioIdMeta =
      const VerificationMeta('ejercicioId');
  @override
  late final GeneratedColumn<int> ejercicioId = GeneratedColumn<int>(
      'ejercicio_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ejercicios (id)'));
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
      'orden', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _seriesObjetivoMeta =
      const VerificationMeta('seriesObjetivo');
  @override
  late final GeneratedColumn<int> seriesObjetivo = GeneratedColumn<int>(
      'series_objetivo', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _repsMinMeta =
      const VerificationMeta('repsMin');
  @override
  late final GeneratedColumn<int> repsMin = GeneratedColumn<int>(
      'reps_min', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(8));
  static const VerificationMeta _repsMaxMeta =
      const VerificationMeta('repsMax');
  @override
  late final GeneratedColumn<int> repsMax = GeneratedColumn<int>(
      'reps_max', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(12));
  static const VerificationMeta _descansoSegMeta =
      const VerificationMeta('descansoSeg');
  @override
  late final GeneratedColumn<int> descansoSeg = GeneratedColumn<int>(
      'descanso_seg', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(90));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        rutinaDiaId,
        ejercicioId,
        orden,
        seriesObjetivo,
        repsMin,
        repsMax,
        descansoSeg
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rutina_ejercicios';
  @override
  VerificationContext validateIntegrity(Insertable<RutinaEjercicio> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rutina_dia_id')) {
      context.handle(
          _rutinaDiaIdMeta,
          rutinaDiaId.isAcceptableOrUnknown(
              data['rutina_dia_id']!, _rutinaDiaIdMeta));
    } else if (isInserting) {
      context.missing(_rutinaDiaIdMeta);
    }
    if (data.containsKey('ejercicio_id')) {
      context.handle(
          _ejercicioIdMeta,
          ejercicioId.isAcceptableOrUnknown(
              data['ejercicio_id']!, _ejercicioIdMeta));
    } else if (isInserting) {
      context.missing(_ejercicioIdMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
          _ordenMeta, orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta));
    }
    if (data.containsKey('series_objetivo')) {
      context.handle(
          _seriesObjetivoMeta,
          seriesObjetivo.isAcceptableOrUnknown(
              data['series_objetivo']!, _seriesObjetivoMeta));
    }
    if (data.containsKey('reps_min')) {
      context.handle(_repsMinMeta,
          repsMin.isAcceptableOrUnknown(data['reps_min']!, _repsMinMeta));
    }
    if (data.containsKey('reps_max')) {
      context.handle(_repsMaxMeta,
          repsMax.isAcceptableOrUnknown(data['reps_max']!, _repsMaxMeta));
    }
    if (data.containsKey('descanso_seg')) {
      context.handle(
          _descansoSegMeta,
          descansoSeg.isAcceptableOrUnknown(
              data['descanso_seg']!, _descansoSegMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RutinaEjercicio map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RutinaEjercicio(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rutinaDiaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rutina_dia_id'])!,
      ejercicioId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ejercicio_id'])!,
      orden: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}orden'])!,
      seriesObjetivo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}series_objetivo'])!,
      repsMin: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps_min'])!,
      repsMax: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps_max'])!,
      descansoSeg: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}descanso_seg'])!,
    );
  }

  @override
  $RutinaEjerciciosTable createAlias(String alias) {
    return $RutinaEjerciciosTable(attachedDatabase, alias);
  }
}

class RutinaEjercicio extends DataClass implements Insertable<RutinaEjercicio> {
  final int id;
  final int rutinaDiaId;
  final int ejercicioId;
  final int orden;
  final int seriesObjetivo;
  final int repsMin;
  final int repsMax;
  final int descansoSeg;
  const RutinaEjercicio(
      {required this.id,
      required this.rutinaDiaId,
      required this.ejercicioId,
      required this.orden,
      required this.seriesObjetivo,
      required this.repsMin,
      required this.repsMax,
      required this.descansoSeg});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rutina_dia_id'] = Variable<int>(rutinaDiaId);
    map['ejercicio_id'] = Variable<int>(ejercicioId);
    map['orden'] = Variable<int>(orden);
    map['series_objetivo'] = Variable<int>(seriesObjetivo);
    map['reps_min'] = Variable<int>(repsMin);
    map['reps_max'] = Variable<int>(repsMax);
    map['descanso_seg'] = Variable<int>(descansoSeg);
    return map;
  }

  RutinaEjerciciosCompanion toCompanion(bool nullToAbsent) {
    return RutinaEjerciciosCompanion(
      id: Value(id),
      rutinaDiaId: Value(rutinaDiaId),
      ejercicioId: Value(ejercicioId),
      orden: Value(orden),
      seriesObjetivo: Value(seriesObjetivo),
      repsMin: Value(repsMin),
      repsMax: Value(repsMax),
      descansoSeg: Value(descansoSeg),
    );
  }

  factory RutinaEjercicio.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RutinaEjercicio(
      id: serializer.fromJson<int>(json['id']),
      rutinaDiaId: serializer.fromJson<int>(json['rutinaDiaId']),
      ejercicioId: serializer.fromJson<int>(json['ejercicioId']),
      orden: serializer.fromJson<int>(json['orden']),
      seriesObjetivo: serializer.fromJson<int>(json['seriesObjetivo']),
      repsMin: serializer.fromJson<int>(json['repsMin']),
      repsMax: serializer.fromJson<int>(json['repsMax']),
      descansoSeg: serializer.fromJson<int>(json['descansoSeg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rutinaDiaId': serializer.toJson<int>(rutinaDiaId),
      'ejercicioId': serializer.toJson<int>(ejercicioId),
      'orden': serializer.toJson<int>(orden),
      'seriesObjetivo': serializer.toJson<int>(seriesObjetivo),
      'repsMin': serializer.toJson<int>(repsMin),
      'repsMax': serializer.toJson<int>(repsMax),
      'descansoSeg': serializer.toJson<int>(descansoSeg),
    };
  }

  RutinaEjercicio copyWith(
          {int? id,
          int? rutinaDiaId,
          int? ejercicioId,
          int? orden,
          int? seriesObjetivo,
          int? repsMin,
          int? repsMax,
          int? descansoSeg}) =>
      RutinaEjercicio(
        id: id ?? this.id,
        rutinaDiaId: rutinaDiaId ?? this.rutinaDiaId,
        ejercicioId: ejercicioId ?? this.ejercicioId,
        orden: orden ?? this.orden,
        seriesObjetivo: seriesObjetivo ?? this.seriesObjetivo,
        repsMin: repsMin ?? this.repsMin,
        repsMax: repsMax ?? this.repsMax,
        descansoSeg: descansoSeg ?? this.descansoSeg,
      );
  RutinaEjercicio copyWithCompanion(RutinaEjerciciosCompanion data) {
    return RutinaEjercicio(
      id: data.id.present ? data.id.value : this.id,
      rutinaDiaId:
          data.rutinaDiaId.present ? data.rutinaDiaId.value : this.rutinaDiaId,
      ejercicioId:
          data.ejercicioId.present ? data.ejercicioId.value : this.ejercicioId,
      orden: data.orden.present ? data.orden.value : this.orden,
      seriesObjetivo: data.seriesObjetivo.present
          ? data.seriesObjetivo.value
          : this.seriesObjetivo,
      repsMin: data.repsMin.present ? data.repsMin.value : this.repsMin,
      repsMax: data.repsMax.present ? data.repsMax.value : this.repsMax,
      descansoSeg:
          data.descansoSeg.present ? data.descansoSeg.value : this.descansoSeg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RutinaEjercicio(')
          ..write('id: $id, ')
          ..write('rutinaDiaId: $rutinaDiaId, ')
          ..write('ejercicioId: $ejercicioId, ')
          ..write('orden: $orden, ')
          ..write('seriesObjetivo: $seriesObjetivo, ')
          ..write('repsMin: $repsMin, ')
          ..write('repsMax: $repsMax, ')
          ..write('descansoSeg: $descansoSeg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rutinaDiaId, ejercicioId, orden,
      seriesObjetivo, repsMin, repsMax, descansoSeg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RutinaEjercicio &&
          other.id == this.id &&
          other.rutinaDiaId == this.rutinaDiaId &&
          other.ejercicioId == this.ejercicioId &&
          other.orden == this.orden &&
          other.seriesObjetivo == this.seriesObjetivo &&
          other.repsMin == this.repsMin &&
          other.repsMax == this.repsMax &&
          other.descansoSeg == this.descansoSeg);
}

class RutinaEjerciciosCompanion extends UpdateCompanion<RutinaEjercicio> {
  final Value<int> id;
  final Value<int> rutinaDiaId;
  final Value<int> ejercicioId;
  final Value<int> orden;
  final Value<int> seriesObjetivo;
  final Value<int> repsMin;
  final Value<int> repsMax;
  final Value<int> descansoSeg;
  const RutinaEjerciciosCompanion({
    this.id = const Value.absent(),
    this.rutinaDiaId = const Value.absent(),
    this.ejercicioId = const Value.absent(),
    this.orden = const Value.absent(),
    this.seriesObjetivo = const Value.absent(),
    this.repsMin = const Value.absent(),
    this.repsMax = const Value.absent(),
    this.descansoSeg = const Value.absent(),
  });
  RutinaEjerciciosCompanion.insert({
    this.id = const Value.absent(),
    required int rutinaDiaId,
    required int ejercicioId,
    this.orden = const Value.absent(),
    this.seriesObjetivo = const Value.absent(),
    this.repsMin = const Value.absent(),
    this.repsMax = const Value.absent(),
    this.descansoSeg = const Value.absent(),
  })  : rutinaDiaId = Value(rutinaDiaId),
        ejercicioId = Value(ejercicioId);
  static Insertable<RutinaEjercicio> custom({
    Expression<int>? id,
    Expression<int>? rutinaDiaId,
    Expression<int>? ejercicioId,
    Expression<int>? orden,
    Expression<int>? seriesObjetivo,
    Expression<int>? repsMin,
    Expression<int>? repsMax,
    Expression<int>? descansoSeg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rutinaDiaId != null) 'rutina_dia_id': rutinaDiaId,
      if (ejercicioId != null) 'ejercicio_id': ejercicioId,
      if (orden != null) 'orden': orden,
      if (seriesObjetivo != null) 'series_objetivo': seriesObjetivo,
      if (repsMin != null) 'reps_min': repsMin,
      if (repsMax != null) 'reps_max': repsMax,
      if (descansoSeg != null) 'descanso_seg': descansoSeg,
    });
  }

  RutinaEjerciciosCompanion copyWith(
      {Value<int>? id,
      Value<int>? rutinaDiaId,
      Value<int>? ejercicioId,
      Value<int>? orden,
      Value<int>? seriesObjetivo,
      Value<int>? repsMin,
      Value<int>? repsMax,
      Value<int>? descansoSeg}) {
    return RutinaEjerciciosCompanion(
      id: id ?? this.id,
      rutinaDiaId: rutinaDiaId ?? this.rutinaDiaId,
      ejercicioId: ejercicioId ?? this.ejercicioId,
      orden: orden ?? this.orden,
      seriesObjetivo: seriesObjetivo ?? this.seriesObjetivo,
      repsMin: repsMin ?? this.repsMin,
      repsMax: repsMax ?? this.repsMax,
      descansoSeg: descansoSeg ?? this.descansoSeg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rutinaDiaId.present) {
      map['rutina_dia_id'] = Variable<int>(rutinaDiaId.value);
    }
    if (ejercicioId.present) {
      map['ejercicio_id'] = Variable<int>(ejercicioId.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (seriesObjetivo.present) {
      map['series_objetivo'] = Variable<int>(seriesObjetivo.value);
    }
    if (repsMin.present) {
      map['reps_min'] = Variable<int>(repsMin.value);
    }
    if (repsMax.present) {
      map['reps_max'] = Variable<int>(repsMax.value);
    }
    if (descansoSeg.present) {
      map['descanso_seg'] = Variable<int>(descansoSeg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RutinaEjerciciosCompanion(')
          ..write('id: $id, ')
          ..write('rutinaDiaId: $rutinaDiaId, ')
          ..write('ejercicioId: $ejercicioId, ')
          ..write('orden: $orden, ')
          ..write('seriesObjetivo: $seriesObjetivo, ')
          ..write('repsMin: $repsMin, ')
          ..write('repsMax: $repsMax, ')
          ..write('descansoSeg: $descansoSeg')
          ..write(')'))
        .toString();
  }
}

class $SesionesEntrenamientoTable extends SesionesEntrenamiento
    with TableInfo<$SesionesEntrenamientoTable, SesionesEntrenamientoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SesionesEntrenamientoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rutinaDiaIdMeta =
      const VerificationMeta('rutinaDiaId');
  @override
  late final GeneratedColumn<int> rutinaDiaId = GeneratedColumn<int>(
      'rutina_dia_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES rutina_dias (id)'));
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
      'fecha', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _duracionSegMeta =
      const VerificationMeta('duracionSeg');
  @override
  late final GeneratedColumn<int> duracionSeg = GeneratedColumn<int>(
      'duracion_seg', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
      'notas', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, rutinaDiaId, fecha, duracionSeg, notas];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sesiones_entrenamiento';
  @override
  VerificationContext validateIntegrity(
      Insertable<SesionesEntrenamientoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rutina_dia_id')) {
      context.handle(
          _rutinaDiaIdMeta,
          rutinaDiaId.isAcceptableOrUnknown(
              data['rutina_dia_id']!, _rutinaDiaIdMeta));
    } else if (isInserting) {
      context.missing(_rutinaDiaIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    }
    if (data.containsKey('duracion_seg')) {
      context.handle(
          _duracionSegMeta,
          duracionSeg.isAcceptableOrUnknown(
              data['duracion_seg']!, _duracionSegMeta));
    }
    if (data.containsKey('notas')) {
      context.handle(
          _notasMeta, notas.isAcceptableOrUnknown(data['notas']!, _notasMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SesionesEntrenamientoData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SesionesEntrenamientoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rutinaDiaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rutina_dia_id'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha'])!,
      duracionSeg: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duracion_seg']),
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas']),
    );
  }

  @override
  $SesionesEntrenamientoTable createAlias(String alias) {
    return $SesionesEntrenamientoTable(attachedDatabase, alias);
  }
}

class SesionesEntrenamientoData extends DataClass
    implements Insertable<SesionesEntrenamientoData> {
  final int id;
  final int rutinaDiaId;
  final DateTime fecha;
  final int? duracionSeg;
  final String? notas;
  const SesionesEntrenamientoData(
      {required this.id,
      required this.rutinaDiaId,
      required this.fecha,
      this.duracionSeg,
      this.notas});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rutina_dia_id'] = Variable<int>(rutinaDiaId);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || duracionSeg != null) {
      map['duracion_seg'] = Variable<int>(duracionSeg);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  SesionesEntrenamientoCompanion toCompanion(bool nullToAbsent) {
    return SesionesEntrenamientoCompanion(
      id: Value(id),
      rutinaDiaId: Value(rutinaDiaId),
      fecha: Value(fecha),
      duracionSeg: duracionSeg == null && nullToAbsent
          ? const Value.absent()
          : Value(duracionSeg),
      notas:
          notas == null && nullToAbsent ? const Value.absent() : Value(notas),
    );
  }

  factory SesionesEntrenamientoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SesionesEntrenamientoData(
      id: serializer.fromJson<int>(json['id']),
      rutinaDiaId: serializer.fromJson<int>(json['rutinaDiaId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      duracionSeg: serializer.fromJson<int?>(json['duracionSeg']),
      notas: serializer.fromJson<String?>(json['notas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rutinaDiaId': serializer.toJson<int>(rutinaDiaId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'duracionSeg': serializer.toJson<int?>(duracionSeg),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  SesionesEntrenamientoData copyWith(
          {int? id,
          int? rutinaDiaId,
          DateTime? fecha,
          Value<int?> duracionSeg = const Value.absent(),
          Value<String?> notas = const Value.absent()}) =>
      SesionesEntrenamientoData(
        id: id ?? this.id,
        rutinaDiaId: rutinaDiaId ?? this.rutinaDiaId,
        fecha: fecha ?? this.fecha,
        duracionSeg: duracionSeg.present ? duracionSeg.value : this.duracionSeg,
        notas: notas.present ? notas.value : this.notas,
      );
  SesionesEntrenamientoData copyWithCompanion(
      SesionesEntrenamientoCompanion data) {
    return SesionesEntrenamientoData(
      id: data.id.present ? data.id.value : this.id,
      rutinaDiaId:
          data.rutinaDiaId.present ? data.rutinaDiaId.value : this.rutinaDiaId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      duracionSeg:
          data.duracionSeg.present ? data.duracionSeg.value : this.duracionSeg,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SesionesEntrenamientoData(')
          ..write('id: $id, ')
          ..write('rutinaDiaId: $rutinaDiaId, ')
          ..write('fecha: $fecha, ')
          ..write('duracionSeg: $duracionSeg, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rutinaDiaId, fecha, duracionSeg, notas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SesionesEntrenamientoData &&
          other.id == this.id &&
          other.rutinaDiaId == this.rutinaDiaId &&
          other.fecha == this.fecha &&
          other.duracionSeg == this.duracionSeg &&
          other.notas == this.notas);
}

class SesionesEntrenamientoCompanion
    extends UpdateCompanion<SesionesEntrenamientoData> {
  final Value<int> id;
  final Value<int> rutinaDiaId;
  final Value<DateTime> fecha;
  final Value<int?> duracionSeg;
  final Value<String?> notas;
  const SesionesEntrenamientoCompanion({
    this.id = const Value.absent(),
    this.rutinaDiaId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.duracionSeg = const Value.absent(),
    this.notas = const Value.absent(),
  });
  SesionesEntrenamientoCompanion.insert({
    this.id = const Value.absent(),
    required int rutinaDiaId,
    this.fecha = const Value.absent(),
    this.duracionSeg = const Value.absent(),
    this.notas = const Value.absent(),
  }) : rutinaDiaId = Value(rutinaDiaId);
  static Insertable<SesionesEntrenamientoData> custom({
    Expression<int>? id,
    Expression<int>? rutinaDiaId,
    Expression<DateTime>? fecha,
    Expression<int>? duracionSeg,
    Expression<String>? notas,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rutinaDiaId != null) 'rutina_dia_id': rutinaDiaId,
      if (fecha != null) 'fecha': fecha,
      if (duracionSeg != null) 'duracion_seg': duracionSeg,
      if (notas != null) 'notas': notas,
    });
  }

  SesionesEntrenamientoCompanion copyWith(
      {Value<int>? id,
      Value<int>? rutinaDiaId,
      Value<DateTime>? fecha,
      Value<int?>? duracionSeg,
      Value<String?>? notas}) {
    return SesionesEntrenamientoCompanion(
      id: id ?? this.id,
      rutinaDiaId: rutinaDiaId ?? this.rutinaDiaId,
      fecha: fecha ?? this.fecha,
      duracionSeg: duracionSeg ?? this.duracionSeg,
      notas: notas ?? this.notas,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rutinaDiaId.present) {
      map['rutina_dia_id'] = Variable<int>(rutinaDiaId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (duracionSeg.present) {
      map['duracion_seg'] = Variable<int>(duracionSeg.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SesionesEntrenamientoCompanion(')
          ..write('id: $id, ')
          ..write('rutinaDiaId: $rutinaDiaId, ')
          ..write('fecha: $fecha, ')
          ..write('duracionSeg: $duracionSeg, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }
}

class $RegistrosSetTable extends RegistrosSet
    with TableInfo<$RegistrosSetTable, RegistrosSetData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegistrosSetTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sesionIdMeta =
      const VerificationMeta('sesionId');
  @override
  late final GeneratedColumn<int> sesionId = GeneratedColumn<int>(
      'sesion_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES sesiones_entrenamiento (id) ON DELETE CASCADE'));
  static const VerificationMeta _rutinaEjercicioIdMeta =
      const VerificationMeta('rutinaEjercicioId');
  @override
  late final GeneratedColumn<int> rutinaEjercicioId = GeneratedColumn<int>(
      'rutina_ejercicio_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rutina_ejercicios (id)'));
  static const VerificationMeta _numeroSetMeta =
      const VerificationMeta('numeroSet');
  @override
  late final GeneratedColumn<int> numeroSet = GeneratedColumn<int>(
      'numero_set', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pesoMeta = const VerificationMeta('peso');
  @override
  late final GeneratedColumn<double> peso = GeneratedColumn<double>(
      'peso', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
      'rpe', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _esPrMeta = const VerificationMeta('esPr');
  @override
  late final GeneratedColumn<bool> esPr = GeneratedColumn<bool>(
      'es_pr', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("es_pr" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, sesionId, rutinaEjercicioId, numeroSet, peso, reps, rpe, esPr];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registros_set';
  @override
  VerificationContext validateIntegrity(Insertable<RegistrosSetData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sesion_id')) {
      context.handle(_sesionIdMeta,
          sesionId.isAcceptableOrUnknown(data['sesion_id']!, _sesionIdMeta));
    } else if (isInserting) {
      context.missing(_sesionIdMeta);
    }
    if (data.containsKey('rutina_ejercicio_id')) {
      context.handle(
          _rutinaEjercicioIdMeta,
          rutinaEjercicioId.isAcceptableOrUnknown(
              data['rutina_ejercicio_id']!, _rutinaEjercicioIdMeta));
    } else if (isInserting) {
      context.missing(_rutinaEjercicioIdMeta);
    }
    if (data.containsKey('numero_set')) {
      context.handle(_numeroSetMeta,
          numeroSet.isAcceptableOrUnknown(data['numero_set']!, _numeroSetMeta));
    } else if (isInserting) {
      context.missing(_numeroSetMeta);
    }
    if (data.containsKey('peso')) {
      context.handle(
          _pesoMeta, peso.isAcceptableOrUnknown(data['peso']!, _pesoMeta));
    } else if (isInserting) {
      context.missing(_pesoMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('rpe')) {
      context.handle(
          _rpeMeta, rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta));
    }
    if (data.containsKey('es_pr')) {
      context.handle(
          _esPrMeta, esPr.isAcceptableOrUnknown(data['es_pr']!, _esPrMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegistrosSetData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegistrosSetData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sesionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sesion_id'])!,
      rutinaEjercicioId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}rutina_ejercicio_id'])!,
      numeroSet: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}numero_set'])!,
      peso: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}peso'])!,
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps'])!,
      rpe: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rpe']),
      esPr: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}es_pr'])!,
    );
  }

  @override
  $RegistrosSetTable createAlias(String alias) {
    return $RegistrosSetTable(attachedDatabase, alias);
  }
}

class RegistrosSetData extends DataClass
    implements Insertable<RegistrosSetData> {
  final int id;
  final int sesionId;
  final int rutinaEjercicioId;
  final int numeroSet;
  final double peso;
  final int reps;
  final double? rpe;
  final bool esPr;
  const RegistrosSetData(
      {required this.id,
      required this.sesionId,
      required this.rutinaEjercicioId,
      required this.numeroSet,
      required this.peso,
      required this.reps,
      this.rpe,
      required this.esPr});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sesion_id'] = Variable<int>(sesionId);
    map['rutina_ejercicio_id'] = Variable<int>(rutinaEjercicioId);
    map['numero_set'] = Variable<int>(numeroSet);
    map['peso'] = Variable<double>(peso);
    map['reps'] = Variable<int>(reps);
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    map['es_pr'] = Variable<bool>(esPr);
    return map;
  }

  RegistrosSetCompanion toCompanion(bool nullToAbsent) {
    return RegistrosSetCompanion(
      id: Value(id),
      sesionId: Value(sesionId),
      rutinaEjercicioId: Value(rutinaEjercicioId),
      numeroSet: Value(numeroSet),
      peso: Value(peso),
      reps: Value(reps),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      esPr: Value(esPr),
    );
  }

  factory RegistrosSetData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegistrosSetData(
      id: serializer.fromJson<int>(json['id']),
      sesionId: serializer.fromJson<int>(json['sesionId']),
      rutinaEjercicioId: serializer.fromJson<int>(json['rutinaEjercicioId']),
      numeroSet: serializer.fromJson<int>(json['numeroSet']),
      peso: serializer.fromJson<double>(json['peso']),
      reps: serializer.fromJson<int>(json['reps']),
      rpe: serializer.fromJson<double?>(json['rpe']),
      esPr: serializer.fromJson<bool>(json['esPr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sesionId': serializer.toJson<int>(sesionId),
      'rutinaEjercicioId': serializer.toJson<int>(rutinaEjercicioId),
      'numeroSet': serializer.toJson<int>(numeroSet),
      'peso': serializer.toJson<double>(peso),
      'reps': serializer.toJson<int>(reps),
      'rpe': serializer.toJson<double?>(rpe),
      'esPr': serializer.toJson<bool>(esPr),
    };
  }

  RegistrosSetData copyWith(
          {int? id,
          int? sesionId,
          int? rutinaEjercicioId,
          int? numeroSet,
          double? peso,
          int? reps,
          Value<double?> rpe = const Value.absent(),
          bool? esPr}) =>
      RegistrosSetData(
        id: id ?? this.id,
        sesionId: sesionId ?? this.sesionId,
        rutinaEjercicioId: rutinaEjercicioId ?? this.rutinaEjercicioId,
        numeroSet: numeroSet ?? this.numeroSet,
        peso: peso ?? this.peso,
        reps: reps ?? this.reps,
        rpe: rpe.present ? rpe.value : this.rpe,
        esPr: esPr ?? this.esPr,
      );
  RegistrosSetData copyWithCompanion(RegistrosSetCompanion data) {
    return RegistrosSetData(
      id: data.id.present ? data.id.value : this.id,
      sesionId: data.sesionId.present ? data.sesionId.value : this.sesionId,
      rutinaEjercicioId: data.rutinaEjercicioId.present
          ? data.rutinaEjercicioId.value
          : this.rutinaEjercicioId,
      numeroSet: data.numeroSet.present ? data.numeroSet.value : this.numeroSet,
      peso: data.peso.present ? data.peso.value : this.peso,
      reps: data.reps.present ? data.reps.value : this.reps,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      esPr: data.esPr.present ? data.esPr.value : this.esPr,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosSetData(')
          ..write('id: $id, ')
          ..write('sesionId: $sesionId, ')
          ..write('rutinaEjercicioId: $rutinaEjercicioId, ')
          ..write('numeroSet: $numeroSet, ')
          ..write('peso: $peso, ')
          ..write('reps: $reps, ')
          ..write('rpe: $rpe, ')
          ..write('esPr: $esPr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, sesionId, rutinaEjercicioId, numeroSet, peso, reps, rpe, esPr);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegistrosSetData &&
          other.id == this.id &&
          other.sesionId == this.sesionId &&
          other.rutinaEjercicioId == this.rutinaEjercicioId &&
          other.numeroSet == this.numeroSet &&
          other.peso == this.peso &&
          other.reps == this.reps &&
          other.rpe == this.rpe &&
          other.esPr == this.esPr);
}

class RegistrosSetCompanion extends UpdateCompanion<RegistrosSetData> {
  final Value<int> id;
  final Value<int> sesionId;
  final Value<int> rutinaEjercicioId;
  final Value<int> numeroSet;
  final Value<double> peso;
  final Value<int> reps;
  final Value<double?> rpe;
  final Value<bool> esPr;
  const RegistrosSetCompanion({
    this.id = const Value.absent(),
    this.sesionId = const Value.absent(),
    this.rutinaEjercicioId = const Value.absent(),
    this.numeroSet = const Value.absent(),
    this.peso = const Value.absent(),
    this.reps = const Value.absent(),
    this.rpe = const Value.absent(),
    this.esPr = const Value.absent(),
  });
  RegistrosSetCompanion.insert({
    this.id = const Value.absent(),
    required int sesionId,
    required int rutinaEjercicioId,
    required int numeroSet,
    required double peso,
    required int reps,
    this.rpe = const Value.absent(),
    this.esPr = const Value.absent(),
  })  : sesionId = Value(sesionId),
        rutinaEjercicioId = Value(rutinaEjercicioId),
        numeroSet = Value(numeroSet),
        peso = Value(peso),
        reps = Value(reps);
  static Insertable<RegistrosSetData> custom({
    Expression<int>? id,
    Expression<int>? sesionId,
    Expression<int>? rutinaEjercicioId,
    Expression<int>? numeroSet,
    Expression<double>? peso,
    Expression<int>? reps,
    Expression<double>? rpe,
    Expression<bool>? esPr,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sesionId != null) 'sesion_id': sesionId,
      if (rutinaEjercicioId != null) 'rutina_ejercicio_id': rutinaEjercicioId,
      if (numeroSet != null) 'numero_set': numeroSet,
      if (peso != null) 'peso': peso,
      if (reps != null) 'reps': reps,
      if (rpe != null) 'rpe': rpe,
      if (esPr != null) 'es_pr': esPr,
    });
  }

  RegistrosSetCompanion copyWith(
      {Value<int>? id,
      Value<int>? sesionId,
      Value<int>? rutinaEjercicioId,
      Value<int>? numeroSet,
      Value<double>? peso,
      Value<int>? reps,
      Value<double?>? rpe,
      Value<bool>? esPr}) {
    return RegistrosSetCompanion(
      id: id ?? this.id,
      sesionId: sesionId ?? this.sesionId,
      rutinaEjercicioId: rutinaEjercicioId ?? this.rutinaEjercicioId,
      numeroSet: numeroSet ?? this.numeroSet,
      peso: peso ?? this.peso,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      esPr: esPr ?? this.esPr,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sesionId.present) {
      map['sesion_id'] = Variable<int>(sesionId.value);
    }
    if (rutinaEjercicioId.present) {
      map['rutina_ejercicio_id'] = Variable<int>(rutinaEjercicioId.value);
    }
    if (numeroSet.present) {
      map['numero_set'] = Variable<int>(numeroSet.value);
    }
    if (peso.present) {
      map['peso'] = Variable<double>(peso.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (esPr.present) {
      map['es_pr'] = Variable<bool>(esPr.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosSetCompanion(')
          ..write('id: $id, ')
          ..write('sesionId: $sesionId, ')
          ..write('rutinaEjercicioId: $rutinaEjercicioId, ')
          ..write('numeroSet: $numeroSet, ')
          ..write('peso: $peso, ')
          ..write('reps: $reps, ')
          ..write('rpe: $rpe, ')
          ..write('esPr: $esPr')
          ..write(')'))
        .toString();
  }
}

class $RegistrosPesoCorporalTable extends RegistrosPesoCorporal
    with TableInfo<$RegistrosPesoCorporalTable, RegistrosPesoCorporalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegistrosPesoCorporalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
      'fecha', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _pesoMeta = const VerificationMeta('peso');
  @override
  late final GeneratedColumn<double> peso = GeneratedColumn<double>(
      'peso', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
      'nota', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, fecha, peso, nota];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registros_peso_corporal';
  @override
  VerificationContext validateIntegrity(
      Insertable<RegistrosPesoCorporalData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    }
    if (data.containsKey('peso')) {
      context.handle(
          _pesoMeta, peso.isAcceptableOrUnknown(data['peso']!, _pesoMeta));
    } else if (isInserting) {
      context.missing(_pesoMeta);
    }
    if (data.containsKey('nota')) {
      context.handle(
          _notaMeta, nota.isAcceptableOrUnknown(data['nota']!, _notaMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegistrosPesoCorporalData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegistrosPesoCorporalData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha'])!,
      peso: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}peso'])!,
      nota: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nota']),
    );
  }

  @override
  $RegistrosPesoCorporalTable createAlias(String alias) {
    return $RegistrosPesoCorporalTable(attachedDatabase, alias);
  }
}

class RegistrosPesoCorporalData extends DataClass
    implements Insertable<RegistrosPesoCorporalData> {
  final int id;
  final DateTime fecha;
  final double peso;
  final String? nota;
  const RegistrosPesoCorporalData(
      {required this.id, required this.fecha, required this.peso, this.nota});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    map['peso'] = Variable<double>(peso);
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    return map;
  }

  RegistrosPesoCorporalCompanion toCompanion(bool nullToAbsent) {
    return RegistrosPesoCorporalCompanion(
      id: Value(id),
      fecha: Value(fecha),
      peso: Value(peso),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
    );
  }

  factory RegistrosPesoCorporalData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegistrosPesoCorporalData(
      id: serializer.fromJson<int>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      peso: serializer.fromJson<double>(json['peso']),
      nota: serializer.fromJson<String?>(json['nota']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'peso': serializer.toJson<double>(peso),
      'nota': serializer.toJson<String?>(nota),
    };
  }

  RegistrosPesoCorporalData copyWith(
          {int? id,
          DateTime? fecha,
          double? peso,
          Value<String?> nota = const Value.absent()}) =>
      RegistrosPesoCorporalData(
        id: id ?? this.id,
        fecha: fecha ?? this.fecha,
        peso: peso ?? this.peso,
        nota: nota.present ? nota.value : this.nota,
      );
  RegistrosPesoCorporalData copyWithCompanion(
      RegistrosPesoCorporalCompanion data) {
    return RegistrosPesoCorporalData(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      peso: data.peso.present ? data.peso.value : this.peso,
      nota: data.nota.present ? data.nota.value : this.nota,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosPesoCorporalData(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('peso: $peso, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fecha, peso, nota);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegistrosPesoCorporalData &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.peso == this.peso &&
          other.nota == this.nota);
}

class RegistrosPesoCorporalCompanion
    extends UpdateCompanion<RegistrosPesoCorporalData> {
  final Value<int> id;
  final Value<DateTime> fecha;
  final Value<double> peso;
  final Value<String?> nota;
  const RegistrosPesoCorporalCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.peso = const Value.absent(),
    this.nota = const Value.absent(),
  });
  RegistrosPesoCorporalCompanion.insert({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    required double peso,
    this.nota = const Value.absent(),
  }) : peso = Value(peso);
  static Insertable<RegistrosPesoCorporalData> custom({
    Expression<int>? id,
    Expression<DateTime>? fecha,
    Expression<double>? peso,
    Expression<String>? nota,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (peso != null) 'peso': peso,
      if (nota != null) 'nota': nota,
    });
  }

  RegistrosPesoCorporalCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? fecha,
      Value<double>? peso,
      Value<String?>? nota}) {
    return RegistrosPesoCorporalCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      peso: peso ?? this.peso,
      nota: nota ?? this.nota,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (peso.present) {
      map['peso'] = Variable<double>(peso.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosPesoCorporalCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('peso: $peso, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }
}

class $ConfiguracionTable extends Configuracion
    with TableInfo<$ConfiguracionTable, ConfiguracionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfiguracionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _unidadPesoMeta =
      const VerificationMeta('unidadPeso');
  @override
  late final GeneratedColumn<String> unidadPeso = GeneratedColumn<String>(
      'unidad_peso', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('kg'));
  static const VerificationMeta _metaPrincipalMeta =
      const VerificationMeta('metaPrincipal');
  @override
  late final GeneratedColumn<String> metaPrincipal = GeneratedColumn<String>(
      'meta_principal', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _temaMeta = const VerificationMeta('tema');
  @override
  late final GeneratedColumn<String> tema = GeneratedColumn<String>(
      'tema', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('sistema'));
  static const VerificationMeta _metaSesionesSemanaMeta =
      const VerificationMeta('metaSesionesSemana');
  @override
  late final GeneratedColumn<int> metaSesionesSemana = GeneratedColumn<int>(
      'meta_sesiones_semana', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(4));
  @override
  List<GeneratedColumn> get $columns =>
      [id, unidadPeso, metaPrincipal, tema, metaSesionesSemana];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuracion';
  @override
  VerificationContext validateIntegrity(Insertable<ConfiguracionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('unidad_peso')) {
      context.handle(
          _unidadPesoMeta,
          unidadPeso.isAcceptableOrUnknown(
              data['unidad_peso']!, _unidadPesoMeta));
    }
    if (data.containsKey('meta_principal')) {
      context.handle(
          _metaPrincipalMeta,
          metaPrincipal.isAcceptableOrUnknown(
              data['meta_principal']!, _metaPrincipalMeta));
    }
    if (data.containsKey('tema')) {
      context.handle(
          _temaMeta, tema.isAcceptableOrUnknown(data['tema']!, _temaMeta));
    }
    if (data.containsKey('meta_sesiones_semana')) {
      context.handle(
          _metaSesionesSemanaMeta,
          metaSesionesSemana.isAcceptableOrUnknown(
              data['meta_sesiones_semana']!, _metaSesionesSemanaMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConfiguracionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfiguracionData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      unidadPeso: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unidad_peso'])!,
      metaPrincipal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meta_principal']),
      tema: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tema'])!,
      metaSesionesSemana: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}meta_sesiones_semana'])!,
    );
  }

  @override
  $ConfiguracionTable createAlias(String alias) {
    return $ConfiguracionTable(attachedDatabase, alias);
  }
}

class ConfiguracionData extends DataClass
    implements Insertable<ConfiguracionData> {
  final int id;
  final String unidadPeso;
  final String? metaPrincipal;
  final String tema;
  final int metaSesionesSemana;
  const ConfiguracionData(
      {required this.id,
      required this.unidadPeso,
      this.metaPrincipal,
      required this.tema,
      required this.metaSesionesSemana});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['unidad_peso'] = Variable<String>(unidadPeso);
    if (!nullToAbsent || metaPrincipal != null) {
      map['meta_principal'] = Variable<String>(metaPrincipal);
    }
    map['tema'] = Variable<String>(tema);
    map['meta_sesiones_semana'] = Variable<int>(metaSesionesSemana);
    return map;
  }

  ConfiguracionCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracionCompanion(
      id: Value(id),
      unidadPeso: Value(unidadPeso),
      metaPrincipal: metaPrincipal == null && nullToAbsent
          ? const Value.absent()
          : Value(metaPrincipal),
      tema: Value(tema),
      metaSesionesSemana: Value(metaSesionesSemana),
    );
  }

  factory ConfiguracionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfiguracionData(
      id: serializer.fromJson<int>(json['id']),
      unidadPeso: serializer.fromJson<String>(json['unidadPeso']),
      metaPrincipal: serializer.fromJson<String?>(json['metaPrincipal']),
      tema: serializer.fromJson<String>(json['tema']),
      metaSesionesSemana: serializer.fromJson<int>(json['metaSesionesSemana']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'unidadPeso': serializer.toJson<String>(unidadPeso),
      'metaPrincipal': serializer.toJson<String?>(metaPrincipal),
      'tema': serializer.toJson<String>(tema),
      'metaSesionesSemana': serializer.toJson<int>(metaSesionesSemana),
    };
  }

  ConfiguracionData copyWith(
          {int? id,
          String? unidadPeso,
          Value<String?> metaPrincipal = const Value.absent(),
          String? tema,
          int? metaSesionesSemana}) =>
      ConfiguracionData(
        id: id ?? this.id,
        unidadPeso: unidadPeso ?? this.unidadPeso,
        metaPrincipal:
            metaPrincipal.present ? metaPrincipal.value : this.metaPrincipal,
        tema: tema ?? this.tema,
        metaSesionesSemana: metaSesionesSemana ?? this.metaSesionesSemana,
      );
  ConfiguracionData copyWithCompanion(ConfiguracionCompanion data) {
    return ConfiguracionData(
      id: data.id.present ? data.id.value : this.id,
      unidadPeso:
          data.unidadPeso.present ? data.unidadPeso.value : this.unidadPeso,
      metaPrincipal: data.metaPrincipal.present
          ? data.metaPrincipal.value
          : this.metaPrincipal,
      tema: data.tema.present ? data.tema.value : this.tema,
      metaSesionesSemana: data.metaSesionesSemana.present
          ? data.metaSesionesSemana.value
          : this.metaSesionesSemana,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionData(')
          ..write('id: $id, ')
          ..write('unidadPeso: $unidadPeso, ')
          ..write('metaPrincipal: $metaPrincipal, ')
          ..write('tema: $tema, ')
          ..write('metaSesionesSemana: $metaSesionesSemana')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, unidadPeso, metaPrincipal, tema, metaSesionesSemana);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfiguracionData &&
          other.id == this.id &&
          other.unidadPeso == this.unidadPeso &&
          other.metaPrincipal == this.metaPrincipal &&
          other.tema == this.tema &&
          other.metaSesionesSemana == this.metaSesionesSemana);
}

class ConfiguracionCompanion extends UpdateCompanion<ConfiguracionData> {
  final Value<int> id;
  final Value<String> unidadPeso;
  final Value<String?> metaPrincipal;
  final Value<String> tema;
  final Value<int> metaSesionesSemana;
  const ConfiguracionCompanion({
    this.id = const Value.absent(),
    this.unidadPeso = const Value.absent(),
    this.metaPrincipal = const Value.absent(),
    this.tema = const Value.absent(),
    this.metaSesionesSemana = const Value.absent(),
  });
  ConfiguracionCompanion.insert({
    this.id = const Value.absent(),
    this.unidadPeso = const Value.absent(),
    this.metaPrincipal = const Value.absent(),
    this.tema = const Value.absent(),
    this.metaSesionesSemana = const Value.absent(),
  });
  static Insertable<ConfiguracionData> custom({
    Expression<int>? id,
    Expression<String>? unidadPeso,
    Expression<String>? metaPrincipal,
    Expression<String>? tema,
    Expression<int>? metaSesionesSemana,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unidadPeso != null) 'unidad_peso': unidadPeso,
      if (metaPrincipal != null) 'meta_principal': metaPrincipal,
      if (tema != null) 'tema': tema,
      if (metaSesionesSemana != null)
        'meta_sesiones_semana': metaSesionesSemana,
    });
  }

  ConfiguracionCompanion copyWith(
      {Value<int>? id,
      Value<String>? unidadPeso,
      Value<String?>? metaPrincipal,
      Value<String>? tema,
      Value<int>? metaSesionesSemana}) {
    return ConfiguracionCompanion(
      id: id ?? this.id,
      unidadPeso: unidadPeso ?? this.unidadPeso,
      metaPrincipal: metaPrincipal ?? this.metaPrincipal,
      tema: tema ?? this.tema,
      metaSesionesSemana: metaSesionesSemana ?? this.metaSesionesSemana,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (unidadPeso.present) {
      map['unidad_peso'] = Variable<String>(unidadPeso.value);
    }
    if (metaPrincipal.present) {
      map['meta_principal'] = Variable<String>(metaPrincipal.value);
    }
    if (tema.present) {
      map['tema'] = Variable<String>(tema.value);
    }
    if (metaSesionesSemana.present) {
      map['meta_sesiones_semana'] = Variable<int>(metaSesionesSemana.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionCompanion(')
          ..write('id: $id, ')
          ..write('unidadPeso: $unidadPeso, ')
          ..write('metaPrincipal: $metaPrincipal, ')
          ..write('tema: $tema, ')
          ..write('metaSesionesSemana: $metaSesionesSemana')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EjerciciosTable ejercicios = $EjerciciosTable(this);
  late final $RutinasTable rutinas = $RutinasTable(this);
  late final $RutinaDiasTable rutinaDias = $RutinaDiasTable(this);
  late final $RutinaEjerciciosTable rutinaEjercicios =
      $RutinaEjerciciosTable(this);
  late final $SesionesEntrenamientoTable sesionesEntrenamiento =
      $SesionesEntrenamientoTable(this);
  late final $RegistrosSetTable registrosSet = $RegistrosSetTable(this);
  late final $RegistrosPesoCorporalTable registrosPesoCorporal =
      $RegistrosPesoCorporalTable(this);
  late final $ConfiguracionTable configuracion = $ConfiguracionTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        ejercicios,
        rutinas,
        rutinaDias,
        rutinaEjercicios,
        sesionesEntrenamiento,
        registrosSet,
        registrosPesoCorporal,
        configuracion
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('rutinas',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('rutina_dias', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('rutina_dias',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('rutina_ejercicios', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('sesiones_entrenamiento',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('registros_set', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$EjerciciosTableCreateCompanionBuilder = EjerciciosCompanion Function({
  Value<int> id,
  required String nombre,
  required String grupoMuscular,
  Value<String> equipo,
  Value<bool> esPersonalizado,
});
typedef $$EjerciciosTableUpdateCompanionBuilder = EjerciciosCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<String> grupoMuscular,
  Value<String> equipo,
  Value<bool> esPersonalizado,
});

final class $$EjerciciosTableReferences
    extends BaseReferences<_$AppDatabase, $EjerciciosTable, Ejercicio> {
  $$EjerciciosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RutinaEjerciciosTable, List<RutinaEjercicio>>
      _rutinaEjerciciosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.rutinaEjercicios,
              aliasName: 'ejercicios__id__rutina_ejercicios__ejercicio_id');

  $$RutinaEjerciciosTableProcessedTableManager get rutinaEjerciciosRefs {
    final manager = $$RutinaEjerciciosTableTableManager(
            $_db, $_db.rutinaEjercicios)
        .filter((f) => f.ejercicioId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_rutinaEjerciciosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$EjerciciosTableFilterComposer
    extends Composer<_$AppDatabase, $EjerciciosTable> {
  $$EjerciciosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grupoMuscular => $composableBuilder(
      column: $table.grupoMuscular, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get equipo => $composableBuilder(
      column: $table.equipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get esPersonalizado => $composableBuilder(
      column: $table.esPersonalizado,
      builder: (column) => ColumnFilters(column));

  Expression<bool> rutinaEjerciciosRefs(
      Expression<bool> Function($$RutinaEjerciciosTableFilterComposer f) f) {
    final $$RutinaEjerciciosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rutinaEjercicios,
        getReferencedColumn: (t) => t.ejercicioId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaEjerciciosTableFilterComposer(
              $db: $db,
              $table: $db.rutinaEjercicios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EjerciciosTableOrderingComposer
    extends Composer<_$AppDatabase, $EjerciciosTable> {
  $$EjerciciosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grupoMuscular => $composableBuilder(
      column: $table.grupoMuscular,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get equipo => $composableBuilder(
      column: $table.equipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get esPersonalizado => $composableBuilder(
      column: $table.esPersonalizado,
      builder: (column) => ColumnOrderings(column));
}

class $$EjerciciosTableAnnotationComposer
    extends Composer<_$AppDatabase, $EjerciciosTable> {
  $$EjerciciosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get grupoMuscular => $composableBuilder(
      column: $table.grupoMuscular, builder: (column) => column);

  GeneratedColumn<String> get equipo =>
      $composableBuilder(column: $table.equipo, builder: (column) => column);

  GeneratedColumn<bool> get esPersonalizado => $composableBuilder(
      column: $table.esPersonalizado, builder: (column) => column);

  Expression<T> rutinaEjerciciosRefs<T extends Object>(
      Expression<T> Function($$RutinaEjerciciosTableAnnotationComposer a) f) {
    final $$RutinaEjerciciosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rutinaEjercicios,
        getReferencedColumn: (t) => t.ejercicioId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaEjerciciosTableAnnotationComposer(
              $db: $db,
              $table: $db.rutinaEjercicios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EjerciciosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EjerciciosTable,
    Ejercicio,
    $$EjerciciosTableFilterComposer,
    $$EjerciciosTableOrderingComposer,
    $$EjerciciosTableAnnotationComposer,
    $$EjerciciosTableCreateCompanionBuilder,
    $$EjerciciosTableUpdateCompanionBuilder,
    (Ejercicio, $$EjerciciosTableReferences),
    Ejercicio,
    PrefetchHooks Function({bool rutinaEjerciciosRefs})> {
  $$EjerciciosTableTableManager(_$AppDatabase db, $EjerciciosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EjerciciosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EjerciciosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EjerciciosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String> grupoMuscular = const Value.absent(),
            Value<String> equipo = const Value.absent(),
            Value<bool> esPersonalizado = const Value.absent(),
          }) =>
              EjerciciosCompanion(
            id: id,
            nombre: nombre,
            grupoMuscular: grupoMuscular,
            equipo: equipo,
            esPersonalizado: esPersonalizado,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nombre,
            required String grupoMuscular,
            Value<String> equipo = const Value.absent(),
            Value<bool> esPersonalizado = const Value.absent(),
          }) =>
              EjerciciosCompanion.insert(
            id: id,
            nombre: nombre,
            grupoMuscular: grupoMuscular,
            equipo: equipo,
            esPersonalizado: esPersonalizado,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$EjerciciosTable, Ejercicio>(table),
                    $$EjerciciosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({rutinaEjerciciosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (rutinaEjerciciosRefs) db.rutinaEjercicios
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rutinaEjerciciosRefs)
                    await $_getPrefetchedData<Ejercicio, $EjerciciosTable,
                            RutinaEjercicio>(
                        currentTable: table,
                        referencedTable: $$EjerciciosTableReferences
                            ._rutinaEjerciciosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EjerciciosTableReferences(db, table, p0)
                                .rutinaEjerciciosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ejercicioId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$EjerciciosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EjerciciosTable,
    Ejercicio,
    $$EjerciciosTableFilterComposer,
    $$EjerciciosTableOrderingComposer,
    $$EjerciciosTableAnnotationComposer,
    $$EjerciciosTableCreateCompanionBuilder,
    $$EjerciciosTableUpdateCompanionBuilder,
    (Ejercicio, $$EjerciciosTableReferences),
    Ejercicio,
    PrefetchHooks Function({bool rutinaEjerciciosRefs})>;
typedef $$RutinasTableCreateCompanionBuilder = RutinasCompanion Function({
  Value<int> id,
  required String nombre,
  Value<bool> activa,
  Value<DateTime> creadaEn,
});
typedef $$RutinasTableUpdateCompanionBuilder = RutinasCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<bool> activa,
  Value<DateTime> creadaEn,
});

final class $$RutinasTableReferences
    extends BaseReferences<_$AppDatabase, $RutinasTable, Rutina> {
  $$RutinasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RutinaDiasTable, List<RutinaDia>>
      _rutinaDiasRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.rutinaDias,
              aliasName: 'rutinas__id__rutina_dias__rutina_id');

  $$RutinaDiasTableProcessedTableManager get rutinaDiasRefs {
    final manager = $$RutinaDiasTableTableManager($_db, $_db.rutinaDias)
        .filter((f) => f.rutinaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rutinaDiasRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RutinasTableFilterComposer
    extends Composer<_$AppDatabase, $RutinasTable> {
  $$RutinasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get activa => $composableBuilder(
      column: $table.activa, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get creadaEn => $composableBuilder(
      column: $table.creadaEn, builder: (column) => ColumnFilters(column));

  Expression<bool> rutinaDiasRefs(
      Expression<bool> Function($$RutinaDiasTableFilterComposer f) f) {
    final $$RutinaDiasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rutinaDias,
        getReferencedColumn: (t) => t.rutinaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaDiasTableFilterComposer(
              $db: $db,
              $table: $db.rutinaDias,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RutinasTableOrderingComposer
    extends Composer<_$AppDatabase, $RutinasTable> {
  $$RutinasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get activa => $composableBuilder(
      column: $table.activa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get creadaEn => $composableBuilder(
      column: $table.creadaEn, builder: (column) => ColumnOrderings(column));
}

class $$RutinasTableAnnotationComposer
    extends Composer<_$AppDatabase, $RutinasTable> {
  $$RutinasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<bool> get activa =>
      $composableBuilder(column: $table.activa, builder: (column) => column);

  GeneratedColumn<DateTime> get creadaEn =>
      $composableBuilder(column: $table.creadaEn, builder: (column) => column);

  Expression<T> rutinaDiasRefs<T extends Object>(
      Expression<T> Function($$RutinaDiasTableAnnotationComposer a) f) {
    final $$RutinaDiasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rutinaDias,
        getReferencedColumn: (t) => t.rutinaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaDiasTableAnnotationComposer(
              $db: $db,
              $table: $db.rutinaDias,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RutinasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RutinasTable,
    Rutina,
    $$RutinasTableFilterComposer,
    $$RutinasTableOrderingComposer,
    $$RutinasTableAnnotationComposer,
    $$RutinasTableCreateCompanionBuilder,
    $$RutinasTableUpdateCompanionBuilder,
    (Rutina, $$RutinasTableReferences),
    Rutina,
    PrefetchHooks Function({bool rutinaDiasRefs})> {
  $$RutinasTableTableManager(_$AppDatabase db, $RutinasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RutinasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RutinasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RutinasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<bool> activa = const Value.absent(),
            Value<DateTime> creadaEn = const Value.absent(),
          }) =>
              RutinasCompanion(
            id: id,
            nombre: nombre,
            activa: activa,
            creadaEn: creadaEn,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nombre,
            Value<bool> activa = const Value.absent(),
            Value<DateTime> creadaEn = const Value.absent(),
          }) =>
              RutinasCompanion.insert(
            id: id,
            nombre: nombre,
            activa: activa,
            creadaEn: creadaEn,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$RutinasTable, Rutina>(table),
                    $$RutinasTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({rutinaDiasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (rutinaDiasRefs) db.rutinaDias],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rutinaDiasRefs)
                    await $_getPrefetchedData<Rutina, $RutinasTable, RutinaDia>(
                        currentTable: table,
                        referencedTable:
                            $$RutinasTableReferences._rutinaDiasRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RutinasTableReferences(db, table, p0)
                                .rutinaDiasRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.rutinaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RutinasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RutinasTable,
    Rutina,
    $$RutinasTableFilterComposer,
    $$RutinasTableOrderingComposer,
    $$RutinasTableAnnotationComposer,
    $$RutinasTableCreateCompanionBuilder,
    $$RutinasTableUpdateCompanionBuilder,
    (Rutina, $$RutinasTableReferences),
    Rutina,
    PrefetchHooks Function({bool rutinaDiasRefs})>;
typedef $$RutinaDiasTableCreateCompanionBuilder = RutinaDiasCompanion Function({
  Value<int> id,
  required int rutinaId,
  required String nombreDia,
  Value<int> orden,
});
typedef $$RutinaDiasTableUpdateCompanionBuilder = RutinaDiasCompanion Function({
  Value<int> id,
  Value<int> rutinaId,
  Value<String> nombreDia,
  Value<int> orden,
});

final class $$RutinaDiasTableReferences
    extends BaseReferences<_$AppDatabase, $RutinaDiasTable, RutinaDia> {
  $$RutinaDiasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RutinasTable _rutinaIdTable(_$AppDatabase db) =>
      db.rutinas.createAlias('rutina_dias__rutina_id__rutinas__id');

  $$RutinasTableProcessedTableManager get rutinaId {
    final $_column = $_itemColumn<int>('rutina_id')!;

    final manager = $$RutinasTableTableManager($_db, $_db.rutinas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rutinaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RutinaEjerciciosTable, List<RutinaEjercicio>>
      _rutinaEjerciciosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.rutinaEjercicios,
              aliasName: 'rutina_dias__id__rutina_ejercicios__rutina_dia_id');

  $$RutinaEjerciciosTableProcessedTableManager get rutinaEjerciciosRefs {
    final manager = $$RutinaEjerciciosTableTableManager(
            $_db, $_db.rutinaEjercicios)
        .filter((f) => f.rutinaDiaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_rutinaEjerciciosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SesionesEntrenamientoTable,
      List<SesionesEntrenamientoData>> _sesionesEntrenamientoRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sesionesEntrenamiento,
          aliasName: 'rutina_dias__id__sesiones_entrenamiento__rutina_dia_id');

  $$SesionesEntrenamientoTableProcessedTableManager
      get sesionesEntrenamientoRefs {
    final manager = $$SesionesEntrenamientoTableTableManager(
            $_db, $_db.sesionesEntrenamiento)
        .filter((f) => f.rutinaDiaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_sesionesEntrenamientoRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RutinaDiasTableFilterComposer
    extends Composer<_$AppDatabase, $RutinaDiasTable> {
  $$RutinaDiasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombreDia => $composableBuilder(
      column: $table.nombreDia, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orden => $composableBuilder(
      column: $table.orden, builder: (column) => ColumnFilters(column));

  $$RutinasTableFilterComposer get rutinaId {
    final $$RutinasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaId,
        referencedTable: $db.rutinas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinasTableFilterComposer(
              $db: $db,
              $table: $db.rutinas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> rutinaEjerciciosRefs(
      Expression<bool> Function($$RutinaEjerciciosTableFilterComposer f) f) {
    final $$RutinaEjerciciosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rutinaEjercicios,
        getReferencedColumn: (t) => t.rutinaDiaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaEjerciciosTableFilterComposer(
              $db: $db,
              $table: $db.rutinaEjercicios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sesionesEntrenamientoRefs(
      Expression<bool> Function($$SesionesEntrenamientoTableFilterComposer f)
          f) {
    final $$SesionesEntrenamientoTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.sesionesEntrenamiento,
            getReferencedColumn: (t) => t.rutinaDiaId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SesionesEntrenamientoTableFilterComposer(
                  $db: $db,
                  $table: $db.sesionesEntrenamiento,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$RutinaDiasTableOrderingComposer
    extends Composer<_$AppDatabase, $RutinaDiasTable> {
  $$RutinaDiasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombreDia => $composableBuilder(
      column: $table.nombreDia, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orden => $composableBuilder(
      column: $table.orden, builder: (column) => ColumnOrderings(column));

  $$RutinasTableOrderingComposer get rutinaId {
    final $$RutinasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaId,
        referencedTable: $db.rutinas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinasTableOrderingComposer(
              $db: $db,
              $table: $db.rutinas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RutinaDiasTableAnnotationComposer
    extends Composer<_$AppDatabase, $RutinaDiasTable> {
  $$RutinaDiasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombreDia =>
      $composableBuilder(column: $table.nombreDia, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  $$RutinasTableAnnotationComposer get rutinaId {
    final $$RutinasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaId,
        referencedTable: $db.rutinas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinasTableAnnotationComposer(
              $db: $db,
              $table: $db.rutinas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> rutinaEjerciciosRefs<T extends Object>(
      Expression<T> Function($$RutinaEjerciciosTableAnnotationComposer a) f) {
    final $$RutinaEjerciciosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rutinaEjercicios,
        getReferencedColumn: (t) => t.rutinaDiaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaEjerciciosTableAnnotationComposer(
              $db: $db,
              $table: $db.rutinaEjercicios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sesionesEntrenamientoRefs<T extends Object>(
      Expression<T> Function($$SesionesEntrenamientoTableAnnotationComposer a)
          f) {
    final $$SesionesEntrenamientoTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.sesionesEntrenamiento,
            getReferencedColumn: (t) => t.rutinaDiaId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SesionesEntrenamientoTableAnnotationComposer(
                  $db: $db,
                  $table: $db.sesionesEntrenamiento,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$RutinaDiasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RutinaDiasTable,
    RutinaDia,
    $$RutinaDiasTableFilterComposer,
    $$RutinaDiasTableOrderingComposer,
    $$RutinaDiasTableAnnotationComposer,
    $$RutinaDiasTableCreateCompanionBuilder,
    $$RutinaDiasTableUpdateCompanionBuilder,
    (RutinaDia, $$RutinaDiasTableReferences),
    RutinaDia,
    PrefetchHooks Function(
        {bool rutinaId,
        bool rutinaEjerciciosRefs,
        bool sesionesEntrenamientoRefs})> {
  $$RutinaDiasTableTableManager(_$AppDatabase db, $RutinaDiasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RutinaDiasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RutinaDiasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RutinaDiasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> rutinaId = const Value.absent(),
            Value<String> nombreDia = const Value.absent(),
            Value<int> orden = const Value.absent(),
          }) =>
              RutinaDiasCompanion(
            id: id,
            rutinaId: rutinaId,
            nombreDia: nombreDia,
            orden: orden,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int rutinaId,
            required String nombreDia,
            Value<int> orden = const Value.absent(),
          }) =>
              RutinaDiasCompanion.insert(
            id: id,
            rutinaId: rutinaId,
            nombreDia: nombreDia,
            orden: orden,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$RutinaDiasTable, RutinaDia>(table),
                    $$RutinaDiasTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {rutinaId = false,
              rutinaEjerciciosRefs = false,
              sesionesEntrenamientoRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (rutinaEjerciciosRefs) db.rutinaEjercicios,
                if (sesionesEntrenamientoRefs) db.sesionesEntrenamiento
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (rutinaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.rutinaId,
                    referencedTable:
                        $$RutinaDiasTableReferences._rutinaIdTable(db),
                    referencedColumn:
                        $$RutinaDiasTableReferences._rutinaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rutinaEjerciciosRefs)
                    await $_getPrefetchedData<RutinaDia, $RutinaDiasTable,
                            RutinaEjercicio>(
                        currentTable: table,
                        referencedTable: $$RutinaDiasTableReferences
                            ._rutinaEjerciciosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RutinaDiasTableReferences(db, table, p0)
                                .rutinaEjerciciosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.rutinaDiaId == item.id),
                        typedResults: items),
                  if (sesionesEntrenamientoRefs)
                    await $_getPrefetchedData<RutinaDia, $RutinaDiasTable,
                            SesionesEntrenamientoData>(
                        currentTable: table,
                        referencedTable: $$RutinaDiasTableReferences
                            ._sesionesEntrenamientoRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RutinaDiasTableReferences(db, table, p0)
                                .sesionesEntrenamientoRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.rutinaDiaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RutinaDiasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RutinaDiasTable,
    RutinaDia,
    $$RutinaDiasTableFilterComposer,
    $$RutinaDiasTableOrderingComposer,
    $$RutinaDiasTableAnnotationComposer,
    $$RutinaDiasTableCreateCompanionBuilder,
    $$RutinaDiasTableUpdateCompanionBuilder,
    (RutinaDia, $$RutinaDiasTableReferences),
    RutinaDia,
    PrefetchHooks Function(
        {bool rutinaId,
        bool rutinaEjerciciosRefs,
        bool sesionesEntrenamientoRefs})>;
typedef $$RutinaEjerciciosTableCreateCompanionBuilder
    = RutinaEjerciciosCompanion Function({
  Value<int> id,
  required int rutinaDiaId,
  required int ejercicioId,
  Value<int> orden,
  Value<int> seriesObjetivo,
  Value<int> repsMin,
  Value<int> repsMax,
  Value<int> descansoSeg,
});
typedef $$RutinaEjerciciosTableUpdateCompanionBuilder
    = RutinaEjerciciosCompanion Function({
  Value<int> id,
  Value<int> rutinaDiaId,
  Value<int> ejercicioId,
  Value<int> orden,
  Value<int> seriesObjetivo,
  Value<int> repsMin,
  Value<int> repsMax,
  Value<int> descansoSeg,
});

final class $$RutinaEjerciciosTableReferences extends BaseReferences<
    _$AppDatabase, $RutinaEjerciciosTable, RutinaEjercicio> {
  $$RutinaEjerciciosTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RutinaDiasTable _rutinaDiaIdTable(_$AppDatabase db) => db.rutinaDias
      .createAlias('rutina_ejercicios__rutina_dia_id__rutina_dias__id');

  $$RutinaDiasTableProcessedTableManager get rutinaDiaId {
    final $_column = $_itemColumn<int>('rutina_dia_id')!;

    final manager = $$RutinaDiasTableTableManager($_db, $_db.rutinaDias)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rutinaDiaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $EjerciciosTable _ejercicioIdTable(_$AppDatabase db) => db.ejercicios
      .createAlias('rutina_ejercicios__ejercicio_id__ejercicios__id');

  $$EjerciciosTableProcessedTableManager get ejercicioId {
    final $_column = $_itemColumn<int>('ejercicio_id')!;

    final manager = $$EjerciciosTableTableManager($_db, $_db.ejercicios)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ejercicioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RegistrosSetTable, List<RegistrosSetData>>
      _registrosSetRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.registrosSet,
              aliasName:
                  'rutina_ejercicios__id__registros_set__rutina_ejercicio_id');

  $$RegistrosSetTableProcessedTableManager get registrosSetRefs {
    final manager = $$RegistrosSetTableTableManager($_db, $_db.registrosSet)
        .filter(
            (f) => f.rutinaEjercicioId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_registrosSetRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RutinaEjerciciosTableFilterComposer
    extends Composer<_$AppDatabase, $RutinaEjerciciosTable> {
  $$RutinaEjerciciosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orden => $composableBuilder(
      column: $table.orden, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seriesObjetivo => $composableBuilder(
      column: $table.seriesObjetivo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repsMin => $composableBuilder(
      column: $table.repsMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repsMax => $composableBuilder(
      column: $table.repsMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get descansoSeg => $composableBuilder(
      column: $table.descansoSeg, builder: (column) => ColumnFilters(column));

  $$RutinaDiasTableFilterComposer get rutinaDiaId {
    final $$RutinaDiasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaDiaId,
        referencedTable: $db.rutinaDias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaDiasTableFilterComposer(
              $db: $db,
              $table: $db.rutinaDias,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EjerciciosTableFilterComposer get ejercicioId {
    final $$EjerciciosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ejercicioId,
        referencedTable: $db.ejercicios,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EjerciciosTableFilterComposer(
              $db: $db,
              $table: $db.ejercicios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> registrosSetRefs(
      Expression<bool> Function($$RegistrosSetTableFilterComposer f) f) {
    final $$RegistrosSetTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.registrosSet,
        getReferencedColumn: (t) => t.rutinaEjercicioId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RegistrosSetTableFilterComposer(
              $db: $db,
              $table: $db.registrosSet,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RutinaEjerciciosTableOrderingComposer
    extends Composer<_$AppDatabase, $RutinaEjerciciosTable> {
  $$RutinaEjerciciosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orden => $composableBuilder(
      column: $table.orden, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seriesObjetivo => $composableBuilder(
      column: $table.seriesObjetivo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repsMin => $composableBuilder(
      column: $table.repsMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repsMax => $composableBuilder(
      column: $table.repsMax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get descansoSeg => $composableBuilder(
      column: $table.descansoSeg, builder: (column) => ColumnOrderings(column));

  $$RutinaDiasTableOrderingComposer get rutinaDiaId {
    final $$RutinaDiasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaDiaId,
        referencedTable: $db.rutinaDias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaDiasTableOrderingComposer(
              $db: $db,
              $table: $db.rutinaDias,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EjerciciosTableOrderingComposer get ejercicioId {
    final $$EjerciciosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ejercicioId,
        referencedTable: $db.ejercicios,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EjerciciosTableOrderingComposer(
              $db: $db,
              $table: $db.ejercicios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RutinaEjerciciosTableAnnotationComposer
    extends Composer<_$AppDatabase, $RutinaEjerciciosTable> {
  $$RutinaEjerciciosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<int> get seriesObjetivo => $composableBuilder(
      column: $table.seriesObjetivo, builder: (column) => column);

  GeneratedColumn<int> get repsMin =>
      $composableBuilder(column: $table.repsMin, builder: (column) => column);

  GeneratedColumn<int> get repsMax =>
      $composableBuilder(column: $table.repsMax, builder: (column) => column);

  GeneratedColumn<int> get descansoSeg => $composableBuilder(
      column: $table.descansoSeg, builder: (column) => column);

  $$RutinaDiasTableAnnotationComposer get rutinaDiaId {
    final $$RutinaDiasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaDiaId,
        referencedTable: $db.rutinaDias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaDiasTableAnnotationComposer(
              $db: $db,
              $table: $db.rutinaDias,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EjerciciosTableAnnotationComposer get ejercicioId {
    final $$EjerciciosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ejercicioId,
        referencedTable: $db.ejercicios,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EjerciciosTableAnnotationComposer(
              $db: $db,
              $table: $db.ejercicios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> registrosSetRefs<T extends Object>(
      Expression<T> Function($$RegistrosSetTableAnnotationComposer a) f) {
    final $$RegistrosSetTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.registrosSet,
        getReferencedColumn: (t) => t.rutinaEjercicioId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RegistrosSetTableAnnotationComposer(
              $db: $db,
              $table: $db.registrosSet,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RutinaEjerciciosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RutinaEjerciciosTable,
    RutinaEjercicio,
    $$RutinaEjerciciosTableFilterComposer,
    $$RutinaEjerciciosTableOrderingComposer,
    $$RutinaEjerciciosTableAnnotationComposer,
    $$RutinaEjerciciosTableCreateCompanionBuilder,
    $$RutinaEjerciciosTableUpdateCompanionBuilder,
    (RutinaEjercicio, $$RutinaEjerciciosTableReferences),
    RutinaEjercicio,
    PrefetchHooks Function(
        {bool rutinaDiaId, bool ejercicioId, bool registrosSetRefs})> {
  $$RutinaEjerciciosTableTableManager(
      _$AppDatabase db, $RutinaEjerciciosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RutinaEjerciciosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RutinaEjerciciosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RutinaEjerciciosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> rutinaDiaId = const Value.absent(),
            Value<int> ejercicioId = const Value.absent(),
            Value<int> orden = const Value.absent(),
            Value<int> seriesObjetivo = const Value.absent(),
            Value<int> repsMin = const Value.absent(),
            Value<int> repsMax = const Value.absent(),
            Value<int> descansoSeg = const Value.absent(),
          }) =>
              RutinaEjerciciosCompanion(
            id: id,
            rutinaDiaId: rutinaDiaId,
            ejercicioId: ejercicioId,
            orden: orden,
            seriesObjetivo: seriesObjetivo,
            repsMin: repsMin,
            repsMax: repsMax,
            descansoSeg: descansoSeg,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int rutinaDiaId,
            required int ejercicioId,
            Value<int> orden = const Value.absent(),
            Value<int> seriesObjetivo = const Value.absent(),
            Value<int> repsMin = const Value.absent(),
            Value<int> repsMax = const Value.absent(),
            Value<int> descansoSeg = const Value.absent(),
          }) =>
              RutinaEjerciciosCompanion.insert(
            id: id,
            rutinaDiaId: rutinaDiaId,
            ejercicioId: ejercicioId,
            orden: orden,
            seriesObjetivo: seriesObjetivo,
            repsMin: repsMin,
            repsMax: repsMax,
            descansoSeg: descansoSeg,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$RutinaEjerciciosTable, RutinaEjercicio>(table),
                    $$RutinaEjerciciosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {rutinaDiaId = false,
              ejercicioId = false,
              registrosSetRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (registrosSetRefs) db.registrosSet],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (rutinaDiaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.rutinaDiaId,
                    referencedTable:
                        $$RutinaEjerciciosTableReferences._rutinaDiaIdTable(db),
                    referencedColumn: $$RutinaEjerciciosTableReferences
                        ._rutinaDiaIdTable(db)
                        .id,
                  ) as T;
                }
                if (ejercicioId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ejercicioId,
                    referencedTable:
                        $$RutinaEjerciciosTableReferences._ejercicioIdTable(db),
                    referencedColumn: $$RutinaEjerciciosTableReferences
                        ._ejercicioIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (registrosSetRefs)
                    await $_getPrefetchedData<RutinaEjercicio,
                            $RutinaEjerciciosTable, RegistrosSetData>(
                        currentTable: table,
                        referencedTable: $$RutinaEjerciciosTableReferences
                            ._registrosSetRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RutinaEjerciciosTableReferences(db, table, p0)
                                .registrosSetRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.rutinaEjercicioId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RutinaEjerciciosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RutinaEjerciciosTable,
    RutinaEjercicio,
    $$RutinaEjerciciosTableFilterComposer,
    $$RutinaEjerciciosTableOrderingComposer,
    $$RutinaEjerciciosTableAnnotationComposer,
    $$RutinaEjerciciosTableCreateCompanionBuilder,
    $$RutinaEjerciciosTableUpdateCompanionBuilder,
    (RutinaEjercicio, $$RutinaEjerciciosTableReferences),
    RutinaEjercicio,
    PrefetchHooks Function(
        {bool rutinaDiaId, bool ejercicioId, bool registrosSetRefs})>;
typedef $$SesionesEntrenamientoTableCreateCompanionBuilder
    = SesionesEntrenamientoCompanion Function({
  Value<int> id,
  required int rutinaDiaId,
  Value<DateTime> fecha,
  Value<int?> duracionSeg,
  Value<String?> notas,
});
typedef $$SesionesEntrenamientoTableUpdateCompanionBuilder
    = SesionesEntrenamientoCompanion Function({
  Value<int> id,
  Value<int> rutinaDiaId,
  Value<DateTime> fecha,
  Value<int?> duracionSeg,
  Value<String?> notas,
});

final class $$SesionesEntrenamientoTableReferences extends BaseReferences<
    _$AppDatabase, $SesionesEntrenamientoTable, SesionesEntrenamientoData> {
  $$SesionesEntrenamientoTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RutinaDiasTable _rutinaDiaIdTable(_$AppDatabase db) => db.rutinaDias
      .createAlias('sesiones_entrenamiento__rutina_dia_id__rutina_dias__id');

  $$RutinaDiasTableProcessedTableManager get rutinaDiaId {
    final $_column = $_itemColumn<int>('rutina_dia_id')!;

    final manager = $$RutinaDiasTableTableManager($_db, $_db.rutinaDias)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rutinaDiaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RegistrosSetTable, List<RegistrosSetData>>
      _registrosSetRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.registrosSet,
          aliasName: 'sesiones_entrenamiento__id__registros_set__sesion_id');

  $$RegistrosSetTableProcessedTableManager get registrosSetRefs {
    final manager = $$RegistrosSetTableTableManager($_db, $_db.registrosSet)
        .filter((f) => f.sesionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_registrosSetRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SesionesEntrenamientoTableFilterComposer
    extends Composer<_$AppDatabase, $SesionesEntrenamientoTable> {
  $$SesionesEntrenamientoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duracionSeg => $composableBuilder(
      column: $table.duracionSeg, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnFilters(column));

  $$RutinaDiasTableFilterComposer get rutinaDiaId {
    final $$RutinaDiasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaDiaId,
        referencedTable: $db.rutinaDias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaDiasTableFilterComposer(
              $db: $db,
              $table: $db.rutinaDias,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> registrosSetRefs(
      Expression<bool> Function($$RegistrosSetTableFilterComposer f) f) {
    final $$RegistrosSetTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.registrosSet,
        getReferencedColumn: (t) => t.sesionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RegistrosSetTableFilterComposer(
              $db: $db,
              $table: $db.registrosSet,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SesionesEntrenamientoTableOrderingComposer
    extends Composer<_$AppDatabase, $SesionesEntrenamientoTable> {
  $$SesionesEntrenamientoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duracionSeg => $composableBuilder(
      column: $table.duracionSeg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnOrderings(column));

  $$RutinaDiasTableOrderingComposer get rutinaDiaId {
    final $$RutinaDiasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaDiaId,
        referencedTable: $db.rutinaDias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaDiasTableOrderingComposer(
              $db: $db,
              $table: $db.rutinaDias,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SesionesEntrenamientoTableAnnotationComposer
    extends Composer<_$AppDatabase, $SesionesEntrenamientoTable> {
  $$SesionesEntrenamientoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get duracionSeg => $composableBuilder(
      column: $table.duracionSeg, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  $$RutinaDiasTableAnnotationComposer get rutinaDiaId {
    final $$RutinaDiasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaDiaId,
        referencedTable: $db.rutinaDias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaDiasTableAnnotationComposer(
              $db: $db,
              $table: $db.rutinaDias,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> registrosSetRefs<T extends Object>(
      Expression<T> Function($$RegistrosSetTableAnnotationComposer a) f) {
    final $$RegistrosSetTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.registrosSet,
        getReferencedColumn: (t) => t.sesionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RegistrosSetTableAnnotationComposer(
              $db: $db,
              $table: $db.registrosSet,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SesionesEntrenamientoTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SesionesEntrenamientoTable,
    SesionesEntrenamientoData,
    $$SesionesEntrenamientoTableFilterComposer,
    $$SesionesEntrenamientoTableOrderingComposer,
    $$SesionesEntrenamientoTableAnnotationComposer,
    $$SesionesEntrenamientoTableCreateCompanionBuilder,
    $$SesionesEntrenamientoTableUpdateCompanionBuilder,
    (SesionesEntrenamientoData, $$SesionesEntrenamientoTableReferences),
    SesionesEntrenamientoData,
    PrefetchHooks Function({bool rutinaDiaId, bool registrosSetRefs})> {
  $$SesionesEntrenamientoTableTableManager(
      _$AppDatabase db, $SesionesEntrenamientoTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SesionesEntrenamientoTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$SesionesEntrenamientoTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SesionesEntrenamientoTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> rutinaDiaId = const Value.absent(),
            Value<DateTime> fecha = const Value.absent(),
            Value<int?> duracionSeg = const Value.absent(),
            Value<String?> notas = const Value.absent(),
          }) =>
              SesionesEntrenamientoCompanion(
            id: id,
            rutinaDiaId: rutinaDiaId,
            fecha: fecha,
            duracionSeg: duracionSeg,
            notas: notas,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int rutinaDiaId,
            Value<DateTime> fecha = const Value.absent(),
            Value<int?> duracionSeg = const Value.absent(),
            Value<String?> notas = const Value.absent(),
          }) =>
              SesionesEntrenamientoCompanion.insert(
            id: id,
            rutinaDiaId: rutinaDiaId,
            fecha: fecha,
            duracionSeg: duracionSeg,
            notas: notas,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SesionesEntrenamientoTable,
                        SesionesEntrenamientoData>(table),
                    $$SesionesEntrenamientoTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {rutinaDiaId = false, registrosSetRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (registrosSetRefs) db.registrosSet],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (rutinaDiaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.rutinaDiaId,
                    referencedTable: $$SesionesEntrenamientoTableReferences
                        ._rutinaDiaIdTable(db),
                    referencedColumn: $$SesionesEntrenamientoTableReferences
                        ._rutinaDiaIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (registrosSetRefs)
                    await $_getPrefetchedData<SesionesEntrenamientoData,
                            $SesionesEntrenamientoTable, RegistrosSetData>(
                        currentTable: table,
                        referencedTable: $$SesionesEntrenamientoTableReferences
                            ._registrosSetRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SesionesEntrenamientoTableReferences(
                                    db, table, p0)
                                .registrosSetRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.sesionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SesionesEntrenamientoTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SesionesEntrenamientoTable,
        SesionesEntrenamientoData,
        $$SesionesEntrenamientoTableFilterComposer,
        $$SesionesEntrenamientoTableOrderingComposer,
        $$SesionesEntrenamientoTableAnnotationComposer,
        $$SesionesEntrenamientoTableCreateCompanionBuilder,
        $$SesionesEntrenamientoTableUpdateCompanionBuilder,
        (SesionesEntrenamientoData, $$SesionesEntrenamientoTableReferences),
        SesionesEntrenamientoData,
        PrefetchHooks Function({bool rutinaDiaId, bool registrosSetRefs})>;
typedef $$RegistrosSetTableCreateCompanionBuilder = RegistrosSetCompanion
    Function({
  Value<int> id,
  required int sesionId,
  required int rutinaEjercicioId,
  required int numeroSet,
  required double peso,
  required int reps,
  Value<double?> rpe,
  Value<bool> esPr,
});
typedef $$RegistrosSetTableUpdateCompanionBuilder = RegistrosSetCompanion
    Function({
  Value<int> id,
  Value<int> sesionId,
  Value<int> rutinaEjercicioId,
  Value<int> numeroSet,
  Value<double> peso,
  Value<int> reps,
  Value<double?> rpe,
  Value<bool> esPr,
});

final class $$RegistrosSetTableReferences extends BaseReferences<_$AppDatabase,
    $RegistrosSetTable, RegistrosSetData> {
  $$RegistrosSetTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SesionesEntrenamientoTable _sesionIdTable(_$AppDatabase db) =>
      db.sesionesEntrenamiento
          .createAlias('registros_set__sesion_id__sesiones_entrenamiento__id');

  $$SesionesEntrenamientoTableProcessedTableManager get sesionId {
    final $_column = $_itemColumn<int>('sesion_id')!;

    final manager = $$SesionesEntrenamientoTableTableManager(
            $_db, $_db.sesionesEntrenamiento)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sesionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $RutinaEjerciciosTable _rutinaEjercicioIdTable(_$AppDatabase db) => db
      .rutinaEjercicios
      .createAlias('registros_set__rutina_ejercicio_id__rutina_ejercicios__id');

  $$RutinaEjerciciosTableProcessedTableManager get rutinaEjercicioId {
    final $_column = $_itemColumn<int>('rutina_ejercicio_id')!;

    final manager =
        $$RutinaEjerciciosTableTableManager($_db, $_db.rutinaEjercicios)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rutinaEjercicioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RegistrosSetTableFilterComposer
    extends Composer<_$AppDatabase, $RegistrosSetTable> {
  $$RegistrosSetTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numeroSet => $composableBuilder(
      column: $table.numeroSet, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get peso => $composableBuilder(
      column: $table.peso, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rpe => $composableBuilder(
      column: $table.rpe, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get esPr => $composableBuilder(
      column: $table.esPr, builder: (column) => ColumnFilters(column));

  $$SesionesEntrenamientoTableFilterComposer get sesionId {
    final $$SesionesEntrenamientoTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sesionId,
            referencedTable: $db.sesionesEntrenamiento,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SesionesEntrenamientoTableFilterComposer(
                  $db: $db,
                  $table: $db.sesionesEntrenamiento,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$RutinaEjerciciosTableFilterComposer get rutinaEjercicioId {
    final $$RutinaEjerciciosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaEjercicioId,
        referencedTable: $db.rutinaEjercicios,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaEjerciciosTableFilterComposer(
              $db: $db,
              $table: $db.rutinaEjercicios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RegistrosSetTableOrderingComposer
    extends Composer<_$AppDatabase, $RegistrosSetTable> {
  $$RegistrosSetTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numeroSet => $composableBuilder(
      column: $table.numeroSet, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get peso => $composableBuilder(
      column: $table.peso, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rpe => $composableBuilder(
      column: $table.rpe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get esPr => $composableBuilder(
      column: $table.esPr, builder: (column) => ColumnOrderings(column));

  $$SesionesEntrenamientoTableOrderingComposer get sesionId {
    final $$SesionesEntrenamientoTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sesionId,
            referencedTable: $db.sesionesEntrenamiento,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SesionesEntrenamientoTableOrderingComposer(
                  $db: $db,
                  $table: $db.sesionesEntrenamiento,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$RutinaEjerciciosTableOrderingComposer get rutinaEjercicioId {
    final $$RutinaEjerciciosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaEjercicioId,
        referencedTable: $db.rutinaEjercicios,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaEjerciciosTableOrderingComposer(
              $db: $db,
              $table: $db.rutinaEjercicios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RegistrosSetTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegistrosSetTable> {
  $$RegistrosSetTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get numeroSet =>
      $composableBuilder(column: $table.numeroSet, builder: (column) => column);

  GeneratedColumn<double> get peso =>
      $composableBuilder(column: $table.peso, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<bool> get esPr =>
      $composableBuilder(column: $table.esPr, builder: (column) => column);

  $$SesionesEntrenamientoTableAnnotationComposer get sesionId {
    final $$SesionesEntrenamientoTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sesionId,
            referencedTable: $db.sesionesEntrenamiento,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SesionesEntrenamientoTableAnnotationComposer(
                  $db: $db,
                  $table: $db.sesionesEntrenamiento,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$RutinaEjerciciosTableAnnotationComposer get rutinaEjercicioId {
    final $$RutinaEjerciciosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rutinaEjercicioId,
        referencedTable: $db.rutinaEjercicios,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RutinaEjerciciosTableAnnotationComposer(
              $db: $db,
              $table: $db.rutinaEjercicios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RegistrosSetTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RegistrosSetTable,
    RegistrosSetData,
    $$RegistrosSetTableFilterComposer,
    $$RegistrosSetTableOrderingComposer,
    $$RegistrosSetTableAnnotationComposer,
    $$RegistrosSetTableCreateCompanionBuilder,
    $$RegistrosSetTableUpdateCompanionBuilder,
    (RegistrosSetData, $$RegistrosSetTableReferences),
    RegistrosSetData,
    PrefetchHooks Function({bool sesionId, bool rutinaEjercicioId})> {
  $$RegistrosSetTableTableManager(_$AppDatabase db, $RegistrosSetTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegistrosSetTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegistrosSetTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegistrosSetTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sesionId = const Value.absent(),
            Value<int> rutinaEjercicioId = const Value.absent(),
            Value<int> numeroSet = const Value.absent(),
            Value<double> peso = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<double?> rpe = const Value.absent(),
            Value<bool> esPr = const Value.absent(),
          }) =>
              RegistrosSetCompanion(
            id: id,
            sesionId: sesionId,
            rutinaEjercicioId: rutinaEjercicioId,
            numeroSet: numeroSet,
            peso: peso,
            reps: reps,
            rpe: rpe,
            esPr: esPr,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sesionId,
            required int rutinaEjercicioId,
            required int numeroSet,
            required double peso,
            required int reps,
            Value<double?> rpe = const Value.absent(),
            Value<bool> esPr = const Value.absent(),
          }) =>
              RegistrosSetCompanion.insert(
            id: id,
            sesionId: sesionId,
            rutinaEjercicioId: rutinaEjercicioId,
            numeroSet: numeroSet,
            peso: peso,
            reps: reps,
            rpe: rpe,
            esPr: esPr,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$RegistrosSetTable, RegistrosSetData>(table),
                    $$RegistrosSetTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {sesionId = false, rutinaEjercicioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sesionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sesionId,
                    referencedTable:
                        $$RegistrosSetTableReferences._sesionIdTable(db),
                    referencedColumn:
                        $$RegistrosSetTableReferences._sesionIdTable(db).id,
                  ) as T;
                }
                if (rutinaEjercicioId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.rutinaEjercicioId,
                    referencedTable: $$RegistrosSetTableReferences
                        ._rutinaEjercicioIdTable(db),
                    referencedColumn: $$RegistrosSetTableReferences
                        ._rutinaEjercicioIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RegistrosSetTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RegistrosSetTable,
    RegistrosSetData,
    $$RegistrosSetTableFilterComposer,
    $$RegistrosSetTableOrderingComposer,
    $$RegistrosSetTableAnnotationComposer,
    $$RegistrosSetTableCreateCompanionBuilder,
    $$RegistrosSetTableUpdateCompanionBuilder,
    (RegistrosSetData, $$RegistrosSetTableReferences),
    RegistrosSetData,
    PrefetchHooks Function({bool sesionId, bool rutinaEjercicioId})>;
typedef $$RegistrosPesoCorporalTableCreateCompanionBuilder
    = RegistrosPesoCorporalCompanion Function({
  Value<int> id,
  Value<DateTime> fecha,
  required double peso,
  Value<String?> nota,
});
typedef $$RegistrosPesoCorporalTableUpdateCompanionBuilder
    = RegistrosPesoCorporalCompanion Function({
  Value<int> id,
  Value<DateTime> fecha,
  Value<double> peso,
  Value<String?> nota,
});

class $$RegistrosPesoCorporalTableFilterComposer
    extends Composer<_$AppDatabase, $RegistrosPesoCorporalTable> {
  $$RegistrosPesoCorporalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get peso => $composableBuilder(
      column: $table.peso, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nota => $composableBuilder(
      column: $table.nota, builder: (column) => ColumnFilters(column));
}

class $$RegistrosPesoCorporalTableOrderingComposer
    extends Composer<_$AppDatabase, $RegistrosPesoCorporalTable> {
  $$RegistrosPesoCorporalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get peso => $composableBuilder(
      column: $table.peso, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nota => $composableBuilder(
      column: $table.nota, builder: (column) => ColumnOrderings(column));
}

class $$RegistrosPesoCorporalTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegistrosPesoCorporalTable> {
  $$RegistrosPesoCorporalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<double> get peso =>
      $composableBuilder(column: $table.peso, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);
}

class $$RegistrosPesoCorporalTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RegistrosPesoCorporalTable,
    RegistrosPesoCorporalData,
    $$RegistrosPesoCorporalTableFilterComposer,
    $$RegistrosPesoCorporalTableOrderingComposer,
    $$RegistrosPesoCorporalTableAnnotationComposer,
    $$RegistrosPesoCorporalTableCreateCompanionBuilder,
    $$RegistrosPesoCorporalTableUpdateCompanionBuilder,
    (
      RegistrosPesoCorporalData,
      BaseReferences<_$AppDatabase, $RegistrosPesoCorporalTable,
          RegistrosPesoCorporalData>
    ),
    RegistrosPesoCorporalData,
    PrefetchHooks Function()> {
  $$RegistrosPesoCorporalTableTableManager(
      _$AppDatabase db, $RegistrosPesoCorporalTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegistrosPesoCorporalTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$RegistrosPesoCorporalTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegistrosPesoCorporalTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> fecha = const Value.absent(),
            Value<double> peso = const Value.absent(),
            Value<String?> nota = const Value.absent(),
          }) =>
              RegistrosPesoCorporalCompanion(
            id: id,
            fecha: fecha,
            peso: peso,
            nota: nota,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> fecha = const Value.absent(),
            required double peso,
            Value<String?> nota = const Value.absent(),
          }) =>
              RegistrosPesoCorporalCompanion.insert(
            id: id,
            fecha: fecha,
            peso: peso,
            nota: nota,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$RegistrosPesoCorporalTable,
                        RegistrosPesoCorporalData>(table),
                    BaseReferences<_$AppDatabase, $RegistrosPesoCorporalTable,
                        RegistrosPesoCorporalData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RegistrosPesoCorporalTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RegistrosPesoCorporalTable,
        RegistrosPesoCorporalData,
        $$RegistrosPesoCorporalTableFilterComposer,
        $$RegistrosPesoCorporalTableOrderingComposer,
        $$RegistrosPesoCorporalTableAnnotationComposer,
        $$RegistrosPesoCorporalTableCreateCompanionBuilder,
        $$RegistrosPesoCorporalTableUpdateCompanionBuilder,
        (
          RegistrosPesoCorporalData,
          BaseReferences<_$AppDatabase, $RegistrosPesoCorporalTable,
              RegistrosPesoCorporalData>
        ),
        RegistrosPesoCorporalData,
        PrefetchHooks Function()>;
typedef $$ConfiguracionTableCreateCompanionBuilder = ConfiguracionCompanion
    Function({
  Value<int> id,
  Value<String> unidadPeso,
  Value<String?> metaPrincipal,
  Value<String> tema,
  Value<int> metaSesionesSemana,
});
typedef $$ConfiguracionTableUpdateCompanionBuilder = ConfiguracionCompanion
    Function({
  Value<int> id,
  Value<String> unidadPeso,
  Value<String?> metaPrincipal,
  Value<String> tema,
  Value<int> metaSesionesSemana,
});

class $$ConfiguracionTableFilterComposer
    extends Composer<_$AppDatabase, $ConfiguracionTable> {
  $$ConfiguracionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unidadPeso => $composableBuilder(
      column: $table.unidadPeso, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metaPrincipal => $composableBuilder(
      column: $table.metaPrincipal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tema => $composableBuilder(
      column: $table.tema, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get metaSesionesSemana => $composableBuilder(
      column: $table.metaSesionesSemana,
      builder: (column) => ColumnFilters(column));
}

class $$ConfiguracionTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfiguracionTable> {
  $$ConfiguracionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unidadPeso => $composableBuilder(
      column: $table.unidadPeso, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metaPrincipal => $composableBuilder(
      column: $table.metaPrincipal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tema => $composableBuilder(
      column: $table.tema, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get metaSesionesSemana => $composableBuilder(
      column: $table.metaSesionesSemana,
      builder: (column) => ColumnOrderings(column));
}

class $$ConfiguracionTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfiguracionTable> {
  $$ConfiguracionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unidadPeso => $composableBuilder(
      column: $table.unidadPeso, builder: (column) => column);

  GeneratedColumn<String> get metaPrincipal => $composableBuilder(
      column: $table.metaPrincipal, builder: (column) => column);

  GeneratedColumn<String> get tema =>
      $composableBuilder(column: $table.tema, builder: (column) => column);

  GeneratedColumn<int> get metaSesionesSemana => $composableBuilder(
      column: $table.metaSesionesSemana, builder: (column) => column);
}

class $$ConfiguracionTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConfiguracionTable,
    ConfiguracionData,
    $$ConfiguracionTableFilterComposer,
    $$ConfiguracionTableOrderingComposer,
    $$ConfiguracionTableAnnotationComposer,
    $$ConfiguracionTableCreateCompanionBuilder,
    $$ConfiguracionTableUpdateCompanionBuilder,
    (
      ConfiguracionData,
      BaseReferences<_$AppDatabase, $ConfiguracionTable, ConfiguracionData>
    ),
    ConfiguracionData,
    PrefetchHooks Function()> {
  $$ConfiguracionTableTableManager(_$AppDatabase db, $ConfiguracionTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfiguracionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfiguracionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfiguracionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> unidadPeso = const Value.absent(),
            Value<String?> metaPrincipal = const Value.absent(),
            Value<String> tema = const Value.absent(),
            Value<int> metaSesionesSemana = const Value.absent(),
          }) =>
              ConfiguracionCompanion(
            id: id,
            unidadPeso: unidadPeso,
            metaPrincipal: metaPrincipal,
            tema: tema,
            metaSesionesSemana: metaSesionesSemana,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> unidadPeso = const Value.absent(),
            Value<String?> metaPrincipal = const Value.absent(),
            Value<String> tema = const Value.absent(),
            Value<int> metaSesionesSemana = const Value.absent(),
          }) =>
              ConfiguracionCompanion.insert(
            id: id,
            unidadPeso: unidadPeso,
            metaPrincipal: metaPrincipal,
            tema: tema,
            metaSesionesSemana: metaSesionesSemana,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ConfiguracionTable, ConfiguracionData>(table),
                    BaseReferences<_$AppDatabase, $ConfiguracionTable,
                        ConfiguracionData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConfiguracionTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConfiguracionTable,
    ConfiguracionData,
    $$ConfiguracionTableFilterComposer,
    $$ConfiguracionTableOrderingComposer,
    $$ConfiguracionTableAnnotationComposer,
    $$ConfiguracionTableCreateCompanionBuilder,
    $$ConfiguracionTableUpdateCompanionBuilder,
    (
      ConfiguracionData,
      BaseReferences<_$AppDatabase, $ConfiguracionTable, ConfiguracionData>
    ),
    ConfiguracionData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EjerciciosTableTableManager get ejercicios =>
      $$EjerciciosTableTableManager(_db, _db.ejercicios);
  $$RutinasTableTableManager get rutinas =>
      $$RutinasTableTableManager(_db, _db.rutinas);
  $$RutinaDiasTableTableManager get rutinaDias =>
      $$RutinaDiasTableTableManager(_db, _db.rutinaDias);
  $$RutinaEjerciciosTableTableManager get rutinaEjercicios =>
      $$RutinaEjerciciosTableTableManager(_db, _db.rutinaEjercicios);
  $$SesionesEntrenamientoTableTableManager get sesionesEntrenamiento =>
      $$SesionesEntrenamientoTableTableManager(_db, _db.sesionesEntrenamiento);
  $$RegistrosSetTableTableManager get registrosSet =>
      $$RegistrosSetTableTableManager(_db, _db.registrosSet);
  $$RegistrosPesoCorporalTableTableManager get registrosPesoCorporal =>
      $$RegistrosPesoCorporalTableTableManager(_db, _db.registrosPesoCorporal);
  $$ConfiguracionTableTableManager get configuracion =>
      $$ConfiguracionTableTableManager(_db, _db.configuracion);
}
