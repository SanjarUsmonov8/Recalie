// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreference extends DataClass implements Insertable<AppPreference> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppPreference({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppPreference copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppPreference(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppPreference copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreference(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreference &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreference> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppPreference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PictureGroupsTable extends PictureGroups
    with TableInfo<$PictureGroupsTable, PictureGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PictureGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planTypeMeta = const VerificationMeta(
    'planType',
  );
  @override
  late final GeneratedColumn<String> planType = GeneratedColumn<String>(
    'plan_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('most_effective'),
  );
  static const VerificationMeta _planStartDateMeta = const VerificationMeta(
    'planStartDate',
  );
  @override
  late final GeneratedColumn<DateTime> planStartDate =
      GeneratedColumn<DateTime>(
        'plan_start_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    textContent,
    planType,
    planStartDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'picture_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<PictureGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    }
    if (data.containsKey('plan_type')) {
      context.handle(
        _planTypeMeta,
        planType.isAcceptableOrUnknown(data['plan_type']!, _planTypeMeta),
      );
    }
    if (data.containsKey('plan_start_date')) {
      context.handle(
        _planStartDateMeta,
        planStartDate.isAcceptableOrUnknown(
          data['plan_start_date']!,
          _planStartDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PictureGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PictureGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      ),
      planType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_type'],
      )!,
      planStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}plan_start_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PictureGroupsTable createAlias(String alias) {
    return $PictureGroupsTable(attachedDatabase, alias);
  }
}

class PictureGroup extends DataClass implements Insertable<PictureGroup> {
  final int id;
  final String name;
  final String? textContent;
  final String planType;
  final DateTime? planStartDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PictureGroup({
    required this.id,
    required this.name,
    this.textContent,
    required this.planType,
    this.planStartDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    map['plan_type'] = Variable<String>(planType);
    if (!nullToAbsent || planStartDate != null) {
      map['plan_start_date'] = Variable<DateTime>(planStartDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PictureGroupsCompanion toCompanion(bool nullToAbsent) {
    return PictureGroupsCompanion(
      id: Value(id),
      name: Value(name),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      planType: Value(planType),
      planStartDate: planStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(planStartDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PictureGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PictureGroup(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      planType: serializer.fromJson<String>(json['planType']),
      planStartDate: serializer.fromJson<DateTime?>(json['planStartDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'textContent': serializer.toJson<String?>(textContent),
      'planType': serializer.toJson<String>(planType),
      'planStartDate': serializer.toJson<DateTime?>(planStartDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PictureGroup copyWith({
    int? id,
    String? name,
    Value<String?> textContent = const Value.absent(),
    String? planType,
    Value<DateTime?> planStartDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PictureGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    textContent: textContent.present ? textContent.value : this.textContent,
    planType: planType ?? this.planType,
    planStartDate: planStartDate.present
        ? planStartDate.value
        : this.planStartDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PictureGroup copyWithCompanion(PictureGroupsCompanion data) {
    return PictureGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      planType: data.planType.present ? data.planType.value : this.planType,
      planStartDate: data.planStartDate.present
          ? data.planStartDate.value
          : this.planStartDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PictureGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('textContent: $textContent, ')
          ..write('planType: $planType, ')
          ..write('planStartDate: $planStartDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    textContent,
    planType,
    planStartDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PictureGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.textContent == this.textContent &&
          other.planType == this.planType &&
          other.planStartDate == this.planStartDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PictureGroupsCompanion extends UpdateCompanion<PictureGroup> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> textContent;
  final Value<String> planType;
  final Value<DateTime?> planStartDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PictureGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.textContent = const Value.absent(),
    this.planType = const Value.absent(),
    this.planStartDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PictureGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.textContent = const Value.absent(),
    this.planType = const Value.absent(),
    this.planStartDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PictureGroup> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? textContent,
    Expression<String>? planType,
    Expression<DateTime>? planStartDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (textContent != null) 'text_content': textContent,
      if (planType != null) 'plan_type': planType,
      if (planStartDate != null) 'plan_start_date': planStartDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PictureGroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? textContent,
    Value<String>? planType,
    Value<DateTime?>? planStartDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PictureGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      textContent: textContent ?? this.textContent,
      planType: planType ?? this.planType,
      planStartDate: planStartDate ?? this.planStartDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (planType.present) {
      map['plan_type'] = Variable<String>(planType.value);
    }
    if (planStartDate.present) {
      map['plan_start_date'] = Variable<DateTime>(planStartDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PictureGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('textContent: $textContent, ')
          ..write('planType: $planType, ')
          ..write('planStartDate: $planStartDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GroupPicturesTable extends GroupPictures
    with TableInfo<$GroupPicturesTable, GroupPicture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupPicturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pictureGroupIdMeta = const VerificationMeta(
    'pictureGroupId',
  );
  @override
  late final GeneratedColumn<int> pictureGroupId = GeneratedColumn<int>(
    'picture_group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES picture_groups (id)',
    ),
  );
  static const VerificationMeta _imageBytesMeta = const VerificationMeta(
    'imageBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> imageBytes = GeneratedColumn<Uint8List>(
    'image_bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pictureGroupId,
    imageBytes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_pictures';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupPicture> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('picture_group_id')) {
      context.handle(
        _pictureGroupIdMeta,
        pictureGroupId.isAcceptableOrUnknown(
          data['picture_group_id']!,
          _pictureGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pictureGroupIdMeta);
    }
    if (data.containsKey('image_bytes')) {
      context.handle(
        _imageBytesMeta,
        imageBytes.isAcceptableOrUnknown(data['image_bytes']!, _imageBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_imageBytesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupPicture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupPicture(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pictureGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}picture_group_id'],
      )!,
      imageBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}image_bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GroupPicturesTable createAlias(String alias) {
    return $GroupPicturesTable(attachedDatabase, alias);
  }
}

class GroupPicture extends DataClass implements Insertable<GroupPicture> {
  final int id;
  final int pictureGroupId;
  final Uint8List imageBytes;
  final DateTime createdAt;
  const GroupPicture({
    required this.id,
    required this.pictureGroupId,
    required this.imageBytes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['picture_group_id'] = Variable<int>(pictureGroupId);
    map['image_bytes'] = Variable<Uint8List>(imageBytes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GroupPicturesCompanion toCompanion(bool nullToAbsent) {
    return GroupPicturesCompanion(
      id: Value(id),
      pictureGroupId: Value(pictureGroupId),
      imageBytes: Value(imageBytes),
      createdAt: Value(createdAt),
    );
  }

  factory GroupPicture.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupPicture(
      id: serializer.fromJson<int>(json['id']),
      pictureGroupId: serializer.fromJson<int>(json['pictureGroupId']),
      imageBytes: serializer.fromJson<Uint8List>(json['imageBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pictureGroupId': serializer.toJson<int>(pictureGroupId),
      'imageBytes': serializer.toJson<Uint8List>(imageBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GroupPicture copyWith({
    int? id,
    int? pictureGroupId,
    Uint8List? imageBytes,
    DateTime? createdAt,
  }) => GroupPicture(
    id: id ?? this.id,
    pictureGroupId: pictureGroupId ?? this.pictureGroupId,
    imageBytes: imageBytes ?? this.imageBytes,
    createdAt: createdAt ?? this.createdAt,
  );
  GroupPicture copyWithCompanion(GroupPicturesCompanion data) {
    return GroupPicture(
      id: data.id.present ? data.id.value : this.id,
      pictureGroupId: data.pictureGroupId.present
          ? data.pictureGroupId.value
          : this.pictureGroupId,
      imageBytes: data.imageBytes.present
          ? data.imageBytes.value
          : this.imageBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupPicture(')
          ..write('id: $id, ')
          ..write('pictureGroupId: $pictureGroupId, ')
          ..write('imageBytes: $imageBytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pictureGroupId,
    $driftBlobEquality.hash(imageBytes),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupPicture &&
          other.id == this.id &&
          other.pictureGroupId == this.pictureGroupId &&
          $driftBlobEquality.equals(other.imageBytes, this.imageBytes) &&
          other.createdAt == this.createdAt);
}

class GroupPicturesCompanion extends UpdateCompanion<GroupPicture> {
  final Value<int> id;
  final Value<int> pictureGroupId;
  final Value<Uint8List> imageBytes;
  final Value<DateTime> createdAt;
  const GroupPicturesCompanion({
    this.id = const Value.absent(),
    this.pictureGroupId = const Value.absent(),
    this.imageBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GroupPicturesCompanion.insert({
    this.id = const Value.absent(),
    required int pictureGroupId,
    required Uint8List imageBytes,
    required DateTime createdAt,
  }) : pictureGroupId = Value(pictureGroupId),
       imageBytes = Value(imageBytes),
       createdAt = Value(createdAt);
  static Insertable<GroupPicture> custom({
    Expression<int>? id,
    Expression<int>? pictureGroupId,
    Expression<Uint8List>? imageBytes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pictureGroupId != null) 'picture_group_id': pictureGroupId,
      if (imageBytes != null) 'image_bytes': imageBytes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GroupPicturesCompanion copyWith({
    Value<int>? id,
    Value<int>? pictureGroupId,
    Value<Uint8List>? imageBytes,
    Value<DateTime>? createdAt,
  }) {
    return GroupPicturesCompanion(
      id: id ?? this.id,
      pictureGroupId: pictureGroupId ?? this.pictureGroupId,
      imageBytes: imageBytes ?? this.imageBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pictureGroupId.present) {
      map['picture_group_id'] = Variable<int>(pictureGroupId.value);
    }
    if (imageBytes.present) {
      map['image_bytes'] = Variable<Uint8List>(imageBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupPicturesCompanion(')
          ..write('id: $id, ')
          ..write('pictureGroupId: $pictureGroupId, ')
          ..write('imageBytes: $imageBytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecallEventsTable extends RecallEvents
    with TableInfo<$RecallEventsTable, RecallEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecallEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pictureGroupIdMeta = const VerificationMeta(
    'pictureGroupId',
  );
  @override
  late final GeneratedColumn<int> pictureGroupId = GeneratedColumn<int>(
    'picture_group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES picture_groups (id)',
    ),
  );
  static const VerificationMeta _recalledAtMeta = const VerificationMeta(
    'recalledAt',
  );
  @override
  late final GeneratedColumn<DateTime> recalledAt = GeneratedColumn<DateTime>(
    'recalled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, pictureGroupId, recalledAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recall_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecallEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('picture_group_id')) {
      context.handle(
        _pictureGroupIdMeta,
        pictureGroupId.isAcceptableOrUnknown(
          data['picture_group_id']!,
          _pictureGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pictureGroupIdMeta);
    }
    if (data.containsKey('recalled_at')) {
      context.handle(
        _recalledAtMeta,
        recalledAt.isAcceptableOrUnknown(data['recalled_at']!, _recalledAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recalledAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecallEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecallEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pictureGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}picture_group_id'],
      )!,
      recalledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recalled_at'],
      )!,
    );
  }

  @override
  $RecallEventsTable createAlias(String alias) {
    return $RecallEventsTable(attachedDatabase, alias);
  }
}

class RecallEvent extends DataClass implements Insertable<RecallEvent> {
  final int id;
  final int pictureGroupId;
  final DateTime recalledAt;
  const RecallEvent({
    required this.id,
    required this.pictureGroupId,
    required this.recalledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['picture_group_id'] = Variable<int>(pictureGroupId);
    map['recalled_at'] = Variable<DateTime>(recalledAt);
    return map;
  }

  RecallEventsCompanion toCompanion(bool nullToAbsent) {
    return RecallEventsCompanion(
      id: Value(id),
      pictureGroupId: Value(pictureGroupId),
      recalledAt: Value(recalledAt),
    );
  }

  factory RecallEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecallEvent(
      id: serializer.fromJson<int>(json['id']),
      pictureGroupId: serializer.fromJson<int>(json['pictureGroupId']),
      recalledAt: serializer.fromJson<DateTime>(json['recalledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pictureGroupId': serializer.toJson<int>(pictureGroupId),
      'recalledAt': serializer.toJson<DateTime>(recalledAt),
    };
  }

  RecallEvent copyWith({int? id, int? pictureGroupId, DateTime? recalledAt}) =>
      RecallEvent(
        id: id ?? this.id,
        pictureGroupId: pictureGroupId ?? this.pictureGroupId,
        recalledAt: recalledAt ?? this.recalledAt,
      );
  RecallEvent copyWithCompanion(RecallEventsCompanion data) {
    return RecallEvent(
      id: data.id.present ? data.id.value : this.id,
      pictureGroupId: data.pictureGroupId.present
          ? data.pictureGroupId.value
          : this.pictureGroupId,
      recalledAt: data.recalledAt.present
          ? data.recalledAt.value
          : this.recalledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecallEvent(')
          ..write('id: $id, ')
          ..write('pictureGroupId: $pictureGroupId, ')
          ..write('recalledAt: $recalledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pictureGroupId, recalledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecallEvent &&
          other.id == this.id &&
          other.pictureGroupId == this.pictureGroupId &&
          other.recalledAt == this.recalledAt);
}

class RecallEventsCompanion extends UpdateCompanion<RecallEvent> {
  final Value<int> id;
  final Value<int> pictureGroupId;
  final Value<DateTime> recalledAt;
  const RecallEventsCompanion({
    this.id = const Value.absent(),
    this.pictureGroupId = const Value.absent(),
    this.recalledAt = const Value.absent(),
  });
  RecallEventsCompanion.insert({
    this.id = const Value.absent(),
    required int pictureGroupId,
    required DateTime recalledAt,
  }) : pictureGroupId = Value(pictureGroupId),
       recalledAt = Value(recalledAt);
  static Insertable<RecallEvent> custom({
    Expression<int>? id,
    Expression<int>? pictureGroupId,
    Expression<DateTime>? recalledAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pictureGroupId != null) 'picture_group_id': pictureGroupId,
      if (recalledAt != null) 'recalled_at': recalledAt,
    });
  }

  RecallEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? pictureGroupId,
    Value<DateTime>? recalledAt,
  }) {
    return RecallEventsCompanion(
      id: id ?? this.id,
      pictureGroupId: pictureGroupId ?? this.pictureGroupId,
      recalledAt: recalledAt ?? this.recalledAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pictureGroupId.present) {
      map['picture_group_id'] = Variable<int>(pictureGroupId.value);
    }
    if (recalledAt.present) {
      map['recalled_at'] = Variable<DateTime>(recalledAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecallEventsCompanion(')
          ..write('id: $id, ')
          ..write('pictureGroupId: $pictureGroupId, ')
          ..write('recalledAt: $recalledAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final $PictureGroupsTable pictureGroups = $PictureGroupsTable(this);
  late final $GroupPicturesTable groupPictures = $GroupPicturesTable(this);
  late final $RecallEventsTable recallEvents = $RecallEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appPreferences,
    pictureGroups,
    groupPictures,
    recallEvents,
  ];
}

typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPreferencesTable,
          AppPreference,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreference,
            BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreference>,
          ),
          AppPreference,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$AppDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppPreferencesTable, AppPreference>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppPreferencesTable,
                    AppPreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPreferencesTable,
      AppPreference,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreference,
        BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreference>,
      ),
      AppPreference,
      PrefetchHooks Function()
    >;
typedef $$PictureGroupsTableCreateCompanionBuilder =
    PictureGroupsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> textContent,
      Value<String> planType,
      Value<DateTime?> planStartDate,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$PictureGroupsTableUpdateCompanionBuilder =
    PictureGroupsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> textContent,
      Value<String> planType,
      Value<DateTime?> planStartDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$PictureGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $PictureGroupsTable, PictureGroup> {
  $$PictureGroupsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$GroupPicturesTable, List<GroupPicture>>
  _groupPicturesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupPictures,
    aliasName: 'picture_groups__id__group_pictures__picture_group_id',
  );

  $$GroupPicturesTableProcessedTableManager get groupPicturesRefs {
    final manager = $$GroupPicturesTableTableManager(
      $_db,
      $_db.groupPictures,
    ).filter((f) => f.pictureGroupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupPicturesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecallEventsTable, List<RecallEvent>>
  _recallEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recallEvents,
    aliasName: 'picture_groups__id__recall_events__picture_group_id',
  );

  $$RecallEventsTableProcessedTableManager get recallEventsRefs {
    final manager = $$RecallEventsTableTableManager(
      $_db,
      $_db.recallEvents,
    ).filter((f) => f.pictureGroupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recallEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PictureGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $PictureGroupsTable> {
  $$PictureGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planType => $composableBuilder(
    column: $table.planType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> groupPicturesRefs(
    Expression<bool> Function($$GroupPicturesTableFilterComposer f) f,
  ) {
    final $$GroupPicturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupPictures,
      getReferencedColumn: (t) => t.pictureGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupPicturesTableFilterComposer(
            $db: $db,
            $table: $db.groupPictures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recallEventsRefs(
    Expression<bool> Function($$RecallEventsTableFilterComposer f) f,
  ) {
    final $$RecallEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recallEvents,
      getReferencedColumn: (t) => t.pictureGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecallEventsTableFilterComposer(
            $db: $db,
            $table: $db.recallEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PictureGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $PictureGroupsTable> {
  $$PictureGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planType => $composableBuilder(
    column: $table.planType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PictureGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PictureGroupsTable> {
  $$PictureGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planType =>
      $composableBuilder(column: $table.planType, builder: (column) => column);

  GeneratedColumn<DateTime> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> groupPicturesRefs<T extends Object>(
    Expression<T> Function($$GroupPicturesTableAnnotationComposer a) f,
  ) {
    final $$GroupPicturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupPictures,
      getReferencedColumn: (t) => t.pictureGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupPicturesTableAnnotationComposer(
            $db: $db,
            $table: $db.groupPictures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recallEventsRefs<T extends Object>(
    Expression<T> Function($$RecallEventsTableAnnotationComposer a) f,
  ) {
    final $$RecallEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recallEvents,
      getReferencedColumn: (t) => t.pictureGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecallEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.recallEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PictureGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PictureGroupsTable,
          PictureGroup,
          $$PictureGroupsTableFilterComposer,
          $$PictureGroupsTableOrderingComposer,
          $$PictureGroupsTableAnnotationComposer,
          $$PictureGroupsTableCreateCompanionBuilder,
          $$PictureGroupsTableUpdateCompanionBuilder,
          (PictureGroup, $$PictureGroupsTableReferences),
          PictureGroup,
          PrefetchHooks Function({
            bool groupPicturesRefs,
            bool recallEventsRefs,
          })
        > {
  $$PictureGroupsTableTableManager(_$AppDatabase db, $PictureGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PictureGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PictureGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PictureGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<String> planType = const Value.absent(),
                Value<DateTime?> planStartDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PictureGroupsCompanion(
                id: id,
                name: name,
                textContent: textContent,
                planType: planType,
                planStartDate: planStartDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> textContent = const Value.absent(),
                Value<String> planType = const Value.absent(),
                Value<DateTime?> planStartDate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => PictureGroupsCompanion.insert(
                id: id,
                name: name,
                textContent: textContent,
                planType: planType,
                planStartDate: planStartDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PictureGroupsTable, PictureGroup>(table),
                  $$PictureGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({groupPicturesRefs = false, recallEventsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupPicturesRefs) db.groupPictures,
                    if (recallEventsRefs) db.recallEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupPicturesRefs)
                        await $_getPrefetchedData<
                          PictureGroup,
                          $PictureGroupsTable,
                          GroupPicture
                        >(
                          currentTable: table,
                          referencedTable: $$PictureGroupsTableReferences
                              ._groupPicturesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PictureGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupPicturesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pictureGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recallEventsRefs)
                        await $_getPrefetchedData<
                          PictureGroup,
                          $PictureGroupsTable,
                          RecallEvent
                        >(
                          currentTable: table,
                          referencedTable: $$PictureGroupsTableReferences
                              ._recallEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PictureGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).recallEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pictureGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PictureGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PictureGroupsTable,
      PictureGroup,
      $$PictureGroupsTableFilterComposer,
      $$PictureGroupsTableOrderingComposer,
      $$PictureGroupsTableAnnotationComposer,
      $$PictureGroupsTableCreateCompanionBuilder,
      $$PictureGroupsTableUpdateCompanionBuilder,
      (PictureGroup, $$PictureGroupsTableReferences),
      PictureGroup,
      PrefetchHooks Function({bool groupPicturesRefs, bool recallEventsRefs})
    >;
typedef $$GroupPicturesTableCreateCompanionBuilder =
    GroupPicturesCompanion Function({
      Value<int> id,
      required int pictureGroupId,
      required Uint8List imageBytes,
      required DateTime createdAt,
    });
typedef $$GroupPicturesTableUpdateCompanionBuilder =
    GroupPicturesCompanion Function({
      Value<int> id,
      Value<int> pictureGroupId,
      Value<Uint8List> imageBytes,
      Value<DateTime> createdAt,
    });

final class $$GroupPicturesTableReferences
    extends BaseReferences<_$AppDatabase, $GroupPicturesTable, GroupPicture> {
  $$GroupPicturesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PictureGroupsTable _pictureGroupIdTable(_$AppDatabase db) => db
      .pictureGroups
      .createAlias('group_pictures__picture_group_id__picture_groups__id');

  $$PictureGroupsTableProcessedTableManager get pictureGroupId {
    final $_column = $_itemColumn<int>('picture_group_id')!;

    final manager = $$PictureGroupsTableTableManager(
      $_db,
      $_db.pictureGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pictureGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupPicturesTableFilterComposer
    extends Composer<_$AppDatabase, $GroupPicturesTable> {
  $$GroupPicturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PictureGroupsTableFilterComposer get pictureGroupId {
    final $$PictureGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureGroupId,
      referencedTable: $db.pictureGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PictureGroupsTableFilterComposer(
            $db: $db,
            $table: $db.pictureGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupPicturesTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupPicturesTable> {
  $$GroupPicturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PictureGroupsTableOrderingComposer get pictureGroupId {
    final $$PictureGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureGroupId,
      referencedTable: $db.pictureGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PictureGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.pictureGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupPicturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupPicturesTable> {
  $$GroupPicturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PictureGroupsTableAnnotationComposer get pictureGroupId {
    final $$PictureGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureGroupId,
      referencedTable: $db.pictureGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PictureGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.pictureGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupPicturesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupPicturesTable,
          GroupPicture,
          $$GroupPicturesTableFilterComposer,
          $$GroupPicturesTableOrderingComposer,
          $$GroupPicturesTableAnnotationComposer,
          $$GroupPicturesTableCreateCompanionBuilder,
          $$GroupPicturesTableUpdateCompanionBuilder,
          (GroupPicture, $$GroupPicturesTableReferences),
          GroupPicture,
          PrefetchHooks Function({bool pictureGroupId})
        > {
  $$GroupPicturesTableTableManager(_$AppDatabase db, $GroupPicturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupPicturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupPicturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupPicturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pictureGroupId = const Value.absent(),
                Value<Uint8List> imageBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GroupPicturesCompanion(
                id: id,
                pictureGroupId: pictureGroupId,
                imageBytes: imageBytes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pictureGroupId,
                required Uint8List imageBytes,
                required DateTime createdAt,
              }) => GroupPicturesCompanion.insert(
                id: id,
                pictureGroupId: pictureGroupId,
                imageBytes: imageBytes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupPicturesTable, GroupPicture>(table),
                  $$GroupPicturesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pictureGroupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (pictureGroupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pictureGroupId,
                                referencedTable: $$GroupPicturesTableReferences
                                    ._pictureGroupIdTable(db),
                                referencedColumn: $$GroupPicturesTableReferences
                                    ._pictureGroupIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroupPicturesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupPicturesTable,
      GroupPicture,
      $$GroupPicturesTableFilterComposer,
      $$GroupPicturesTableOrderingComposer,
      $$GroupPicturesTableAnnotationComposer,
      $$GroupPicturesTableCreateCompanionBuilder,
      $$GroupPicturesTableUpdateCompanionBuilder,
      (GroupPicture, $$GroupPicturesTableReferences),
      GroupPicture,
      PrefetchHooks Function({bool pictureGroupId})
    >;
typedef $$RecallEventsTableCreateCompanionBuilder =
    RecallEventsCompanion Function({
      Value<int> id,
      required int pictureGroupId,
      required DateTime recalledAt,
    });
typedef $$RecallEventsTableUpdateCompanionBuilder =
    RecallEventsCompanion Function({
      Value<int> id,
      Value<int> pictureGroupId,
      Value<DateTime> recalledAt,
    });

final class $$RecallEventsTableReferences
    extends BaseReferences<_$AppDatabase, $RecallEventsTable, RecallEvent> {
  $$RecallEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PictureGroupsTable _pictureGroupIdTable(_$AppDatabase db) => db
      .pictureGroups
      .createAlias('recall_events__picture_group_id__picture_groups__id');

  $$PictureGroupsTableProcessedTableManager get pictureGroupId {
    final $_column = $_itemColumn<int>('picture_group_id')!;

    final manager = $$PictureGroupsTableTableManager(
      $_db,
      $_db.pictureGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pictureGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecallEventsTableFilterComposer
    extends Composer<_$AppDatabase, $RecallEventsTable> {
  $$RecallEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recalledAt => $composableBuilder(
    column: $table.recalledAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PictureGroupsTableFilterComposer get pictureGroupId {
    final $$PictureGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureGroupId,
      referencedTable: $db.pictureGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PictureGroupsTableFilterComposer(
            $db: $db,
            $table: $db.pictureGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecallEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecallEventsTable> {
  $$RecallEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recalledAt => $composableBuilder(
    column: $table.recalledAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PictureGroupsTableOrderingComposer get pictureGroupId {
    final $$PictureGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureGroupId,
      referencedTable: $db.pictureGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PictureGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.pictureGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecallEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecallEventsTable> {
  $$RecallEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get recalledAt => $composableBuilder(
    column: $table.recalledAt,
    builder: (column) => column,
  );

  $$PictureGroupsTableAnnotationComposer get pictureGroupId {
    final $$PictureGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureGroupId,
      referencedTable: $db.pictureGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PictureGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.pictureGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecallEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecallEventsTable,
          RecallEvent,
          $$RecallEventsTableFilterComposer,
          $$RecallEventsTableOrderingComposer,
          $$RecallEventsTableAnnotationComposer,
          $$RecallEventsTableCreateCompanionBuilder,
          $$RecallEventsTableUpdateCompanionBuilder,
          (RecallEvent, $$RecallEventsTableReferences),
          RecallEvent,
          PrefetchHooks Function({bool pictureGroupId})
        > {
  $$RecallEventsTableTableManager(_$AppDatabase db, $RecallEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecallEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecallEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecallEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pictureGroupId = const Value.absent(),
                Value<DateTime> recalledAt = const Value.absent(),
              }) => RecallEventsCompanion(
                id: id,
                pictureGroupId: pictureGroupId,
                recalledAt: recalledAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pictureGroupId,
                required DateTime recalledAt,
              }) => RecallEventsCompanion.insert(
                id: id,
                pictureGroupId: pictureGroupId,
                recalledAt: recalledAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecallEventsTable, RecallEvent>(table),
                  $$RecallEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pictureGroupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (pictureGroupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pictureGroupId,
                                referencedTable: $$RecallEventsTableReferences
                                    ._pictureGroupIdTable(db),
                                referencedColumn: $$RecallEventsTableReferences
                                    ._pictureGroupIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecallEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecallEventsTable,
      RecallEvent,
      $$RecallEventsTableFilterComposer,
      $$RecallEventsTableOrderingComposer,
      $$RecallEventsTableAnnotationComposer,
      $$RecallEventsTableCreateCompanionBuilder,
      $$RecallEventsTableUpdateCompanionBuilder,
      (RecallEvent, $$RecallEventsTableReferences),
      RecallEvent,
      PrefetchHooks Function({bool pictureGroupId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
  $$PictureGroupsTableTableManager get pictureGroups =>
      $$PictureGroupsTableTableManager(_db, _db.pictureGroups);
  $$GroupPicturesTableTableManager get groupPictures =>
      $$GroupPicturesTableTableManager(_db, _db.groupPictures);
  $$RecallEventsTableTableManager get recallEvents =>
      $$RecallEventsTableTableManager(_db, _db.recallEvents);
}
