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
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'set_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _coverIconMeta = const VerificationMeta(
    'coverIcon',
  );
  @override
  late final GeneratedColumn<String> coverIcon = GeneratedColumn<String>(
    'cover_icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverColorStartMeta = const VerificationMeta(
    'coverColorStart',
  );
  @override
  late final GeneratedColumn<String> coverColorStart = GeneratedColumn<String>(
    'cover_color_start',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverColorEndMeta = const VerificationMeta(
    'coverColorEnd',
  );
  @override
  late final GeneratedColumn<String> coverColorEnd = GeneratedColumn<String>(
    'cover_color_end',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverImageUrlMeta = const VerificationMeta(
    'coverImageUrl',
  );
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
    'cover_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    setNumber,
    name,
    textContent,
    planType,
    planStartDate,
    coverIcon,
    coverColorStart,
    coverColorEnd,
    coverImageUrl,
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
    if (data.containsKey('set_number')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['set_number']!, _setNumberMeta),
      );
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
    if (data.containsKey('cover_icon')) {
      context.handle(
        _coverIconMeta,
        coverIcon.isAcceptableOrUnknown(data['cover_icon']!, _coverIconMeta),
      );
    }
    if (data.containsKey('cover_color_start')) {
      context.handle(
        _coverColorStartMeta,
        coverColorStart.isAcceptableOrUnknown(
          data['cover_color_start']!,
          _coverColorStartMeta,
        ),
      );
    }
    if (data.containsKey('cover_color_end')) {
      context.handle(
        _coverColorEndMeta,
        coverColorEnd.isAcceptableOrUnknown(
          data['cover_color_end']!,
          _coverColorEndMeta,
        ),
      );
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
        _coverImageUrlMeta,
        coverImageUrl.isAcceptableOrUnknown(
          data['cover_image_url']!,
          _coverImageUrlMeta,
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
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_number'],
      ),
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
      coverIcon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_icon'],
      ),
      coverColorStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_color_start'],
      ),
      coverColorEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_color_end'],
      ),
      coverImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_url'],
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
  final int? setNumber;
  final String name;
  final String? textContent;
  final String planType;
  final DateTime? planStartDate;
  final String? coverIcon;
  final String? coverColorStart;
  final String? coverColorEnd;
  final String? coverImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PictureGroup({
    required this.id,
    this.setNumber,
    required this.name,
    this.textContent,
    required this.planType,
    this.planStartDate,
    this.coverIcon,
    this.coverColorStart,
    this.coverColorEnd,
    this.coverImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || setNumber != null) {
      map['set_number'] = Variable<int>(setNumber);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    map['plan_type'] = Variable<String>(planType);
    if (!nullToAbsent || planStartDate != null) {
      map['plan_start_date'] = Variable<DateTime>(planStartDate);
    }
    if (!nullToAbsent || coverIcon != null) {
      map['cover_icon'] = Variable<String>(coverIcon);
    }
    if (!nullToAbsent || coverColorStart != null) {
      map['cover_color_start'] = Variable<String>(coverColorStart);
    }
    if (!nullToAbsent || coverColorEnd != null) {
      map['cover_color_end'] = Variable<String>(coverColorEnd);
    }
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PictureGroupsCompanion toCompanion(bool nullToAbsent) {
    return PictureGroupsCompanion(
      id: Value(id),
      setNumber: setNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(setNumber),
      name: Value(name),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      planType: Value(planType),
      planStartDate: planStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(planStartDate),
      coverIcon: coverIcon == null && nullToAbsent
          ? const Value.absent()
          : Value(coverIcon),
      coverColorStart: coverColorStart == null && nullToAbsent
          ? const Value.absent()
          : Value(coverColorStart),
      coverColorEnd: coverColorEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(coverColorEnd),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
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
      setNumber: serializer.fromJson<int?>(json['setNumber']),
      name: serializer.fromJson<String>(json['name']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      planType: serializer.fromJson<String>(json['planType']),
      planStartDate: serializer.fromJson<DateTime?>(json['planStartDate']),
      coverIcon: serializer.fromJson<String?>(json['coverIcon']),
      coverColorStart: serializer.fromJson<String?>(json['coverColorStart']),
      coverColorEnd: serializer.fromJson<String?>(json['coverColorEnd']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'setNumber': serializer.toJson<int?>(setNumber),
      'name': serializer.toJson<String>(name),
      'textContent': serializer.toJson<String?>(textContent),
      'planType': serializer.toJson<String>(planType),
      'planStartDate': serializer.toJson<DateTime?>(planStartDate),
      'coverIcon': serializer.toJson<String?>(coverIcon),
      'coverColorStart': serializer.toJson<String?>(coverColorStart),
      'coverColorEnd': serializer.toJson<String?>(coverColorEnd),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PictureGroup copyWith({
    int? id,
    Value<int?> setNumber = const Value.absent(),
    String? name,
    Value<String?> textContent = const Value.absent(),
    String? planType,
    Value<DateTime?> planStartDate = const Value.absent(),
    Value<String?> coverIcon = const Value.absent(),
    Value<String?> coverColorStart = const Value.absent(),
    Value<String?> coverColorEnd = const Value.absent(),
    Value<String?> coverImageUrl = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PictureGroup(
    id: id ?? this.id,
    setNumber: setNumber.present ? setNumber.value : this.setNumber,
    name: name ?? this.name,
    textContent: textContent.present ? textContent.value : this.textContent,
    planType: planType ?? this.planType,
    planStartDate: planStartDate.present
        ? planStartDate.value
        : this.planStartDate,
    coverIcon: coverIcon.present ? coverIcon.value : this.coverIcon,
    coverColorStart: coverColorStart.present
        ? coverColorStart.value
        : this.coverColorStart,
    coverColorEnd: coverColorEnd.present
        ? coverColorEnd.value
        : this.coverColorEnd,
    coverImageUrl: coverImageUrl.present
        ? coverImageUrl.value
        : this.coverImageUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PictureGroup copyWithCompanion(PictureGroupsCompanion data) {
    return PictureGroup(
      id: data.id.present ? data.id.value : this.id,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      name: data.name.present ? data.name.value : this.name,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      planType: data.planType.present ? data.planType.value : this.planType,
      planStartDate: data.planStartDate.present
          ? data.planStartDate.value
          : this.planStartDate,
      coverIcon: data.coverIcon.present ? data.coverIcon.value : this.coverIcon,
      coverColorStart: data.coverColorStart.present
          ? data.coverColorStart.value
          : this.coverColorStart,
      coverColorEnd: data.coverColorEnd.present
          ? data.coverColorEnd.value
          : this.coverColorEnd,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PictureGroup(')
          ..write('id: $id, ')
          ..write('setNumber: $setNumber, ')
          ..write('name: $name, ')
          ..write('textContent: $textContent, ')
          ..write('planType: $planType, ')
          ..write('planStartDate: $planStartDate, ')
          ..write('coverIcon: $coverIcon, ')
          ..write('coverColorStart: $coverColorStart, ')
          ..write('coverColorEnd: $coverColorEnd, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    setNumber,
    name,
    textContent,
    planType,
    planStartDate,
    coverIcon,
    coverColorStart,
    coverColorEnd,
    coverImageUrl,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PictureGroup &&
          other.id == this.id &&
          other.setNumber == this.setNumber &&
          other.name == this.name &&
          other.textContent == this.textContent &&
          other.planType == this.planType &&
          other.planStartDate == this.planStartDate &&
          other.coverIcon == this.coverIcon &&
          other.coverColorStart == this.coverColorStart &&
          other.coverColorEnd == this.coverColorEnd &&
          other.coverImageUrl == this.coverImageUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PictureGroupsCompanion extends UpdateCompanion<PictureGroup> {
  final Value<int> id;
  final Value<int?> setNumber;
  final Value<String> name;
  final Value<String?> textContent;
  final Value<String> planType;
  final Value<DateTime?> planStartDate;
  final Value<String?> coverIcon;
  final Value<String?> coverColorStart;
  final Value<String?> coverColorEnd;
  final Value<String?> coverImageUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PictureGroupsCompanion({
    this.id = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.textContent = const Value.absent(),
    this.planType = const Value.absent(),
    this.planStartDate = const Value.absent(),
    this.coverIcon = const Value.absent(),
    this.coverColorStart = const Value.absent(),
    this.coverColorEnd = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PictureGroupsCompanion.insert({
    this.id = const Value.absent(),
    this.setNumber = const Value.absent(),
    required String name,
    this.textContent = const Value.absent(),
    this.planType = const Value.absent(),
    this.planStartDate = const Value.absent(),
    this.coverIcon = const Value.absent(),
    this.coverColorStart = const Value.absent(),
    this.coverColorEnd = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PictureGroup> custom({
    Expression<int>? id,
    Expression<int>? setNumber,
    Expression<String>? name,
    Expression<String>? textContent,
    Expression<String>? planType,
    Expression<DateTime>? planStartDate,
    Expression<String>? coverIcon,
    Expression<String>? coverColorStart,
    Expression<String>? coverColorEnd,
    Expression<String>? coverImageUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setNumber != null) 'set_number': setNumber,
      if (name != null) 'name': name,
      if (textContent != null) 'text_content': textContent,
      if (planType != null) 'plan_type': planType,
      if (planStartDate != null) 'plan_start_date': planStartDate,
      if (coverIcon != null) 'cover_icon': coverIcon,
      if (coverColorStart != null) 'cover_color_start': coverColorStart,
      if (coverColorEnd != null) 'cover_color_end': coverColorEnd,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PictureGroupsCompanion copyWith({
    Value<int>? id,
    Value<int?>? setNumber,
    Value<String>? name,
    Value<String?>? textContent,
    Value<String>? planType,
    Value<DateTime?>? planStartDate,
    Value<String?>? coverIcon,
    Value<String?>? coverColorStart,
    Value<String?>? coverColorEnd,
    Value<String?>? coverImageUrl,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PictureGroupsCompanion(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      name: name ?? this.name,
      textContent: textContent ?? this.textContent,
      planType: planType ?? this.planType,
      planStartDate: planStartDate ?? this.planStartDate,
      coverIcon: coverIcon ?? this.coverIcon,
      coverColorStart: coverColorStart ?? this.coverColorStart,
      coverColorEnd: coverColorEnd ?? this.coverColorEnd,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
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
    if (setNumber.present) {
      map['set_number'] = Variable<int>(setNumber.value);
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
    if (coverIcon.present) {
      map['cover_icon'] = Variable<String>(coverIcon.value);
    }
    if (coverColorStart.present) {
      map['cover_color_start'] = Variable<String>(coverColorStart.value);
    }
    if (coverColorEnd.present) {
      map['cover_color_end'] = Variable<String>(coverColorEnd.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
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
          ..write('setNumber: $setNumber, ')
          ..write('name: $name, ')
          ..write('textContent: $textContent, ')
          ..write('planType: $planType, ')
          ..write('planStartDate: $planStartDate, ')
          ..write('coverIcon: $coverIcon, ')
          ..write('coverColorStart: $coverColorStart, ')
          ..write('coverColorEnd: $coverColorEnd, ')
          ..write('coverImageUrl: $coverImageUrl, ')
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
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isReviewedMeta = const VerificationMeta(
    'isReviewed',
  );
  @override
  late final GeneratedColumn<bool> isReviewed = GeneratedColumn<bool>(
    'is_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_reviewed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    position,
    isReviewed,
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
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('is_reviewed')) {
      context.handle(
        _isReviewedMeta,
        isReviewed.isAcceptableOrUnknown(data['is_reviewed']!, _isReviewedMeta),
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
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      isReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_reviewed'],
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
  final int position;
  final bool isReviewed;
  final DateTime createdAt;
  const GroupPicture({
    required this.id,
    required this.pictureGroupId,
    required this.imageBytes,
    required this.position,
    required this.isReviewed,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['picture_group_id'] = Variable<int>(pictureGroupId);
    map['image_bytes'] = Variable<Uint8List>(imageBytes);
    map['position'] = Variable<int>(position);
    map['is_reviewed'] = Variable<bool>(isReviewed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GroupPicturesCompanion toCompanion(bool nullToAbsent) {
    return GroupPicturesCompanion(
      id: Value(id),
      pictureGroupId: Value(pictureGroupId),
      imageBytes: Value(imageBytes),
      position: Value(position),
      isReviewed: Value(isReviewed),
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
      position: serializer.fromJson<int>(json['position']),
      isReviewed: serializer.fromJson<bool>(json['isReviewed']),
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
      'position': serializer.toJson<int>(position),
      'isReviewed': serializer.toJson<bool>(isReviewed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GroupPicture copyWith({
    int? id,
    int? pictureGroupId,
    Uint8List? imageBytes,
    int? position,
    bool? isReviewed,
    DateTime? createdAt,
  }) => GroupPicture(
    id: id ?? this.id,
    pictureGroupId: pictureGroupId ?? this.pictureGroupId,
    imageBytes: imageBytes ?? this.imageBytes,
    position: position ?? this.position,
    isReviewed: isReviewed ?? this.isReviewed,
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
      position: data.position.present ? data.position.value : this.position,
      isReviewed: data.isReviewed.present
          ? data.isReviewed.value
          : this.isReviewed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupPicture(')
          ..write('id: $id, ')
          ..write('pictureGroupId: $pictureGroupId, ')
          ..write('imageBytes: $imageBytes, ')
          ..write('position: $position, ')
          ..write('isReviewed: $isReviewed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pictureGroupId,
    $driftBlobEquality.hash(imageBytes),
    position,
    isReviewed,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupPicture &&
          other.id == this.id &&
          other.pictureGroupId == this.pictureGroupId &&
          $driftBlobEquality.equals(other.imageBytes, this.imageBytes) &&
          other.position == this.position &&
          other.isReviewed == this.isReviewed &&
          other.createdAt == this.createdAt);
}

class GroupPicturesCompanion extends UpdateCompanion<GroupPicture> {
  final Value<int> id;
  final Value<int> pictureGroupId;
  final Value<Uint8List> imageBytes;
  final Value<int> position;
  final Value<bool> isReviewed;
  final Value<DateTime> createdAt;
  const GroupPicturesCompanion({
    this.id = const Value.absent(),
    this.pictureGroupId = const Value.absent(),
    this.imageBytes = const Value.absent(),
    this.position = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GroupPicturesCompanion.insert({
    this.id = const Value.absent(),
    required int pictureGroupId,
    required Uint8List imageBytes,
    this.position = const Value.absent(),
    this.isReviewed = const Value.absent(),
    required DateTime createdAt,
  }) : pictureGroupId = Value(pictureGroupId),
       imageBytes = Value(imageBytes),
       createdAt = Value(createdAt);
  static Insertable<GroupPicture> custom({
    Expression<int>? id,
    Expression<int>? pictureGroupId,
    Expression<Uint8List>? imageBytes,
    Expression<int>? position,
    Expression<bool>? isReviewed,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pictureGroupId != null) 'picture_group_id': pictureGroupId,
      if (imageBytes != null) 'image_bytes': imageBytes,
      if (position != null) 'position': position,
      if (isReviewed != null) 'is_reviewed': isReviewed,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GroupPicturesCompanion copyWith({
    Value<int>? id,
    Value<int>? pictureGroupId,
    Value<Uint8List>? imageBytes,
    Value<int>? position,
    Value<bool>? isReviewed,
    Value<DateTime>? createdAt,
  }) {
    return GroupPicturesCompanion(
      id: id ?? this.id,
      pictureGroupId: pictureGroupId ?? this.pictureGroupId,
      imageBytes: imageBytes ?? this.imageBytes,
      position: position ?? this.position,
      isReviewed: isReviewed ?? this.isReviewed,
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
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (isReviewed.present) {
      map['is_reviewed'] = Variable<bool>(isReviewed.value);
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
          ..write('position: $position, ')
          ..write('isReviewed: $isReviewed, ')
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

class $ImageAnnotationStrokesTable extends ImageAnnotationStrokes
    with TableInfo<$ImageAnnotationStrokesTable, ImageAnnotationStroke> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageAnnotationStrokesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pictureIdMeta = const VerificationMeta(
    'pictureId',
  );
  @override
  late final GeneratedColumn<int> pictureId = GeneratedColumn<int>(
    'picture_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_pictures (id)',
    ),
  );
  static const VerificationMeta _toolMeta = const VerificationMeta('tool');
  @override
  late final GeneratedColumn<String> tool = GeneratedColumn<String>(
    'tool',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isStraightMeta = const VerificationMeta(
    'isStraight',
  );
  @override
  late final GeneratedColumn<bool> isStraight = GeneratedColumn<bool>(
    'is_straight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_straight" IN (0, 1))',
    ),
  );
  static const VerificationMeta _thicknessMeta = const VerificationMeta(
    'thickness',
  );
  @override
  late final GeneratedColumn<double> thickness = GeneratedColumn<double>(
    'thickness',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opacityMeta = const VerificationMeta(
    'opacity',
  );
  @override
  late final GeneratedColumn<double> opacity = GeneratedColumn<double>(
    'opacity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedPointsMeta = const VerificationMeta(
    'normalizedPoints',
  );
  @override
  late final GeneratedColumn<Uint8List> normalizedPoints =
      GeneratedColumn<Uint8List>(
        'normalized_points',
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
    pictureId,
    tool,
    isStraight,
    thickness,
    opacity,
    colorValue,
    normalizedPoints,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_annotation_strokes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageAnnotationStroke> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('picture_id')) {
      context.handle(
        _pictureIdMeta,
        pictureId.isAcceptableOrUnknown(data['picture_id']!, _pictureIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pictureIdMeta);
    }
    if (data.containsKey('tool')) {
      context.handle(
        _toolMeta,
        tool.isAcceptableOrUnknown(data['tool']!, _toolMeta),
      );
    } else if (isInserting) {
      context.missing(_toolMeta);
    }
    if (data.containsKey('is_straight')) {
      context.handle(
        _isStraightMeta,
        isStraight.isAcceptableOrUnknown(data['is_straight']!, _isStraightMeta),
      );
    } else if (isInserting) {
      context.missing(_isStraightMeta);
    }
    if (data.containsKey('thickness')) {
      context.handle(
        _thicknessMeta,
        thickness.isAcceptableOrUnknown(data['thickness']!, _thicknessMeta),
      );
    } else if (isInserting) {
      context.missing(_thicknessMeta);
    }
    if (data.containsKey('opacity')) {
      context.handle(
        _opacityMeta,
        opacity.isAcceptableOrUnknown(data['opacity']!, _opacityMeta),
      );
    } else if (isInserting) {
      context.missing(_opacityMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('normalized_points')) {
      context.handle(
        _normalizedPointsMeta,
        normalizedPoints.isAcceptableOrUnknown(
          data['normalized_points']!,
          _normalizedPointsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedPointsMeta);
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
  ImageAnnotationStroke map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageAnnotationStroke(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pictureId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}picture_id'],
      )!,
      tool: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool'],
      )!,
      isStraight: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_straight'],
      )!,
      thickness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}thickness'],
      )!,
      opacity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opacity'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      normalizedPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}normalized_points'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ImageAnnotationStrokesTable createAlias(String alias) {
    return $ImageAnnotationStrokesTable(attachedDatabase, alias);
  }
}

class ImageAnnotationStroke extends DataClass
    implements Insertable<ImageAnnotationStroke> {
  final int id;
  final int pictureId;
  final String tool;
  final bool isStraight;
  final double thickness;
  final double opacity;
  final int colorValue;
  final Uint8List normalizedPoints;
  final DateTime createdAt;
  const ImageAnnotationStroke({
    required this.id,
    required this.pictureId,
    required this.tool,
    required this.isStraight,
    required this.thickness,
    required this.opacity,
    required this.colorValue,
    required this.normalizedPoints,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['picture_id'] = Variable<int>(pictureId);
    map['tool'] = Variable<String>(tool);
    map['is_straight'] = Variable<bool>(isStraight);
    map['thickness'] = Variable<double>(thickness);
    map['opacity'] = Variable<double>(opacity);
    map['color_value'] = Variable<int>(colorValue);
    map['normalized_points'] = Variable<Uint8List>(normalizedPoints);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ImageAnnotationStrokesCompanion toCompanion(bool nullToAbsent) {
    return ImageAnnotationStrokesCompanion(
      id: Value(id),
      pictureId: Value(pictureId),
      tool: Value(tool),
      isStraight: Value(isStraight),
      thickness: Value(thickness),
      opacity: Value(opacity),
      colorValue: Value(colorValue),
      normalizedPoints: Value(normalizedPoints),
      createdAt: Value(createdAt),
    );
  }

  factory ImageAnnotationStroke.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageAnnotationStroke(
      id: serializer.fromJson<int>(json['id']),
      pictureId: serializer.fromJson<int>(json['pictureId']),
      tool: serializer.fromJson<String>(json['tool']),
      isStraight: serializer.fromJson<bool>(json['isStraight']),
      thickness: serializer.fromJson<double>(json['thickness']),
      opacity: serializer.fromJson<double>(json['opacity']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      normalizedPoints: serializer.fromJson<Uint8List>(
        json['normalizedPoints'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pictureId': serializer.toJson<int>(pictureId),
      'tool': serializer.toJson<String>(tool),
      'isStraight': serializer.toJson<bool>(isStraight),
      'thickness': serializer.toJson<double>(thickness),
      'opacity': serializer.toJson<double>(opacity),
      'colorValue': serializer.toJson<int>(colorValue),
      'normalizedPoints': serializer.toJson<Uint8List>(normalizedPoints),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ImageAnnotationStroke copyWith({
    int? id,
    int? pictureId,
    String? tool,
    bool? isStraight,
    double? thickness,
    double? opacity,
    int? colorValue,
    Uint8List? normalizedPoints,
    DateTime? createdAt,
  }) => ImageAnnotationStroke(
    id: id ?? this.id,
    pictureId: pictureId ?? this.pictureId,
    tool: tool ?? this.tool,
    isStraight: isStraight ?? this.isStraight,
    thickness: thickness ?? this.thickness,
    opacity: opacity ?? this.opacity,
    colorValue: colorValue ?? this.colorValue,
    normalizedPoints: normalizedPoints ?? this.normalizedPoints,
    createdAt: createdAt ?? this.createdAt,
  );
  ImageAnnotationStroke copyWithCompanion(
    ImageAnnotationStrokesCompanion data,
  ) {
    return ImageAnnotationStroke(
      id: data.id.present ? data.id.value : this.id,
      pictureId: data.pictureId.present ? data.pictureId.value : this.pictureId,
      tool: data.tool.present ? data.tool.value : this.tool,
      isStraight: data.isStraight.present
          ? data.isStraight.value
          : this.isStraight,
      thickness: data.thickness.present ? data.thickness.value : this.thickness,
      opacity: data.opacity.present ? data.opacity.value : this.opacity,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      normalizedPoints: data.normalizedPoints.present
          ? data.normalizedPoints.value
          : this.normalizedPoints,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageAnnotationStroke(')
          ..write('id: $id, ')
          ..write('pictureId: $pictureId, ')
          ..write('tool: $tool, ')
          ..write('isStraight: $isStraight, ')
          ..write('thickness: $thickness, ')
          ..write('opacity: $opacity, ')
          ..write('colorValue: $colorValue, ')
          ..write('normalizedPoints: $normalizedPoints, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pictureId,
    tool,
    isStraight,
    thickness,
    opacity,
    colorValue,
    $driftBlobEquality.hash(normalizedPoints),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageAnnotationStroke &&
          other.id == this.id &&
          other.pictureId == this.pictureId &&
          other.tool == this.tool &&
          other.isStraight == this.isStraight &&
          other.thickness == this.thickness &&
          other.opacity == this.opacity &&
          other.colorValue == this.colorValue &&
          $driftBlobEquality.equals(
            other.normalizedPoints,
            this.normalizedPoints,
          ) &&
          other.createdAt == this.createdAt);
}

class ImageAnnotationStrokesCompanion
    extends UpdateCompanion<ImageAnnotationStroke> {
  final Value<int> id;
  final Value<int> pictureId;
  final Value<String> tool;
  final Value<bool> isStraight;
  final Value<double> thickness;
  final Value<double> opacity;
  final Value<int> colorValue;
  final Value<Uint8List> normalizedPoints;
  final Value<DateTime> createdAt;
  const ImageAnnotationStrokesCompanion({
    this.id = const Value.absent(),
    this.pictureId = const Value.absent(),
    this.tool = const Value.absent(),
    this.isStraight = const Value.absent(),
    this.thickness = const Value.absent(),
    this.opacity = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.normalizedPoints = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ImageAnnotationStrokesCompanion.insert({
    this.id = const Value.absent(),
    required int pictureId,
    required String tool,
    required bool isStraight,
    required double thickness,
    required double opacity,
    required int colorValue,
    required Uint8List normalizedPoints,
    required DateTime createdAt,
  }) : pictureId = Value(pictureId),
       tool = Value(tool),
       isStraight = Value(isStraight),
       thickness = Value(thickness),
       opacity = Value(opacity),
       colorValue = Value(colorValue),
       normalizedPoints = Value(normalizedPoints),
       createdAt = Value(createdAt);
  static Insertable<ImageAnnotationStroke> custom({
    Expression<int>? id,
    Expression<int>? pictureId,
    Expression<String>? tool,
    Expression<bool>? isStraight,
    Expression<double>? thickness,
    Expression<double>? opacity,
    Expression<int>? colorValue,
    Expression<Uint8List>? normalizedPoints,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pictureId != null) 'picture_id': pictureId,
      if (tool != null) 'tool': tool,
      if (isStraight != null) 'is_straight': isStraight,
      if (thickness != null) 'thickness': thickness,
      if (opacity != null) 'opacity': opacity,
      if (colorValue != null) 'color_value': colorValue,
      if (normalizedPoints != null) 'normalized_points': normalizedPoints,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ImageAnnotationStrokesCompanion copyWith({
    Value<int>? id,
    Value<int>? pictureId,
    Value<String>? tool,
    Value<bool>? isStraight,
    Value<double>? thickness,
    Value<double>? opacity,
    Value<int>? colorValue,
    Value<Uint8List>? normalizedPoints,
    Value<DateTime>? createdAt,
  }) {
    return ImageAnnotationStrokesCompanion(
      id: id ?? this.id,
      pictureId: pictureId ?? this.pictureId,
      tool: tool ?? this.tool,
      isStraight: isStraight ?? this.isStraight,
      thickness: thickness ?? this.thickness,
      opacity: opacity ?? this.opacity,
      colorValue: colorValue ?? this.colorValue,
      normalizedPoints: normalizedPoints ?? this.normalizedPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pictureId.present) {
      map['picture_id'] = Variable<int>(pictureId.value);
    }
    if (tool.present) {
      map['tool'] = Variable<String>(tool.value);
    }
    if (isStraight.present) {
      map['is_straight'] = Variable<bool>(isStraight.value);
    }
    if (thickness.present) {
      map['thickness'] = Variable<double>(thickness.value);
    }
    if (opacity.present) {
      map['opacity'] = Variable<double>(opacity.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (normalizedPoints.present) {
      map['normalized_points'] = Variable<Uint8List>(normalizedPoints.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageAnnotationStrokesCompanion(')
          ..write('id: $id, ')
          ..write('pictureId: $pictureId, ')
          ..write('tool: $tool, ')
          ..write('isStraight: $isStraight, ')
          ..write('thickness: $thickness, ')
          ..write('opacity: $opacity, ')
          ..write('colorValue: $colorValue, ')
          ..write('normalizedPoints: $normalizedPoints, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ImageNotesTable extends ImageNotes
    with TableInfo<$ImageNotesTable, ImageNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageNotesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pictureIdMeta = const VerificationMeta(
    'pictureId',
  );
  @override
  late final GeneratedColumn<int> pictureId = GeneratedColumn<int>(
    'picture_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_pictures (id)',
    ),
  );
  static const VerificationMeta _normalizedXMeta = const VerificationMeta(
    'normalizedX',
  );
  @override
  late final GeneratedColumn<double> normalizedX = GeneratedColumn<double>(
    'normalized_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedYMeta = const VerificationMeta(
    'normalizedY',
  );
  @override
  late final GeneratedColumn<double> normalizedY = GeneratedColumn<double>(
    'normalized_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    pictureId,
    normalizedX,
    normalizedY,
    content,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('picture_id')) {
      context.handle(
        _pictureIdMeta,
        pictureId.isAcceptableOrUnknown(data['picture_id']!, _pictureIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pictureIdMeta);
    }
    if (data.containsKey('normalized_x')) {
      context.handle(
        _normalizedXMeta,
        normalizedX.isAcceptableOrUnknown(
          data['normalized_x']!,
          _normalizedXMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedXMeta);
    }
    if (data.containsKey('normalized_y')) {
      context.handle(
        _normalizedYMeta,
        normalizedY.isAcceptableOrUnknown(
          data['normalized_y']!,
          _normalizedYMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedYMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
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
  ImageNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pictureId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}picture_id'],
      )!,
      normalizedX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}normalized_x'],
      )!,
      normalizedY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}normalized_y'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
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
  $ImageNotesTable createAlias(String alias) {
    return $ImageNotesTable(attachedDatabase, alias);
  }
}

class ImageNote extends DataClass implements Insertable<ImageNote> {
  final int id;
  final int pictureId;
  final double normalizedX;
  final double normalizedY;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ImageNote({
    required this.id,
    required this.pictureId,
    required this.normalizedX,
    required this.normalizedY,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['picture_id'] = Variable<int>(pictureId);
    map['normalized_x'] = Variable<double>(normalizedX);
    map['normalized_y'] = Variable<double>(normalizedY);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ImageNotesCompanion toCompanion(bool nullToAbsent) {
    return ImageNotesCompanion(
      id: Value(id),
      pictureId: Value(pictureId),
      normalizedX: Value(normalizedX),
      normalizedY: Value(normalizedY),
      content: Value(content),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ImageNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageNote(
      id: serializer.fromJson<int>(json['id']),
      pictureId: serializer.fromJson<int>(json['pictureId']),
      normalizedX: serializer.fromJson<double>(json['normalizedX']),
      normalizedY: serializer.fromJson<double>(json['normalizedY']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pictureId': serializer.toJson<int>(pictureId),
      'normalizedX': serializer.toJson<double>(normalizedX),
      'normalizedY': serializer.toJson<double>(normalizedY),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ImageNote copyWith({
    int? id,
    int? pictureId,
    double? normalizedX,
    double? normalizedY,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ImageNote(
    id: id ?? this.id,
    pictureId: pictureId ?? this.pictureId,
    normalizedX: normalizedX ?? this.normalizedX,
    normalizedY: normalizedY ?? this.normalizedY,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ImageNote copyWithCompanion(ImageNotesCompanion data) {
    return ImageNote(
      id: data.id.present ? data.id.value : this.id,
      pictureId: data.pictureId.present ? data.pictureId.value : this.pictureId,
      normalizedX: data.normalizedX.present
          ? data.normalizedX.value
          : this.normalizedX,
      normalizedY: data.normalizedY.present
          ? data.normalizedY.value
          : this.normalizedY,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageNote(')
          ..write('id: $id, ')
          ..write('pictureId: $pictureId, ')
          ..write('normalizedX: $normalizedX, ')
          ..write('normalizedY: $normalizedY, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pictureId,
    normalizedX,
    normalizedY,
    content,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageNote &&
          other.id == this.id &&
          other.pictureId == this.pictureId &&
          other.normalizedX == this.normalizedX &&
          other.normalizedY == this.normalizedY &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ImageNotesCompanion extends UpdateCompanion<ImageNote> {
  final Value<int> id;
  final Value<int> pictureId;
  final Value<double> normalizedX;
  final Value<double> normalizedY;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ImageNotesCompanion({
    this.id = const Value.absent(),
    this.pictureId = const Value.absent(),
    this.normalizedX = const Value.absent(),
    this.normalizedY = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ImageNotesCompanion.insert({
    this.id = const Value.absent(),
    required int pictureId,
    required double normalizedX,
    required double normalizedY,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : pictureId = Value(pictureId),
       normalizedX = Value(normalizedX),
       normalizedY = Value(normalizedY),
       content = Value(content),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ImageNote> custom({
    Expression<int>? id,
    Expression<int>? pictureId,
    Expression<double>? normalizedX,
    Expression<double>? normalizedY,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pictureId != null) 'picture_id': pictureId,
      if (normalizedX != null) 'normalized_x': normalizedX,
      if (normalizedY != null) 'normalized_y': normalizedY,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ImageNotesCompanion copyWith({
    Value<int>? id,
    Value<int>? pictureId,
    Value<double>? normalizedX,
    Value<double>? normalizedY,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ImageNotesCompanion(
      id: id ?? this.id,
      pictureId: pictureId ?? this.pictureId,
      normalizedX: normalizedX ?? this.normalizedX,
      normalizedY: normalizedY ?? this.normalizedY,
      content: content ?? this.content,
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
    if (pictureId.present) {
      map['picture_id'] = Variable<int>(pictureId.value);
    }
    if (normalizedX.present) {
      map['normalized_x'] = Variable<double>(normalizedX.value);
    }
    if (normalizedY.present) {
      map['normalized_y'] = Variable<double>(normalizedY.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
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
    return (StringBuffer('ImageNotesCompanion(')
          ..write('id: $id, ')
          ..write('pictureId: $pictureId, ')
          ..write('normalizedX: $normalizedX, ')
          ..write('normalizedY: $normalizedY, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
  late final $ImageAnnotationStrokesTable imageAnnotationStrokes =
      $ImageAnnotationStrokesTable(this);
  late final $ImageNotesTable imageNotes = $ImageNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appPreferences,
    pictureGroups,
    groupPictures,
    recallEvents,
    imageAnnotationStrokes,
    imageNotes,
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
      Value<int?> setNumber,
      required String name,
      Value<String?> textContent,
      Value<String> planType,
      Value<DateTime?> planStartDate,
      Value<String?> coverIcon,
      Value<String?> coverColorStart,
      Value<String?> coverColorEnd,
      Value<String?> coverImageUrl,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$PictureGroupsTableUpdateCompanionBuilder =
    PictureGroupsCompanion Function({
      Value<int> id,
      Value<int?> setNumber,
      Value<String> name,
      Value<String?> textContent,
      Value<String> planType,
      Value<DateTime?> planStartDate,
      Value<String?> coverIcon,
      Value<String?> coverColorStart,
      Value<String?> coverColorEnd,
      Value<String?> coverImageUrl,
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

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
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

  ColumnFilters<String> get coverIcon => $composableBuilder(
    column: $table.coverIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverColorStart => $composableBuilder(
    column: $table.coverColorStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverColorEnd => $composableBuilder(
    column: $table.coverColorEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
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

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
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

  ColumnOrderings<String> get coverIcon => $composableBuilder(
    column: $table.coverIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverColorStart => $composableBuilder(
    column: $table.coverColorStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverColorEnd => $composableBuilder(
    column: $table.coverColorEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
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

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);

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

  GeneratedColumn<String> get coverIcon =>
      $composableBuilder(column: $table.coverIcon, builder: (column) => column);

  GeneratedColumn<String> get coverColorStart => $composableBuilder(
    column: $table.coverColorStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverColorEnd => $composableBuilder(
    column: $table.coverColorEnd,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
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
                Value<int?> setNumber = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<String> planType = const Value.absent(),
                Value<DateTime?> planStartDate = const Value.absent(),
                Value<String?> coverIcon = const Value.absent(),
                Value<String?> coverColorStart = const Value.absent(),
                Value<String?> coverColorEnd = const Value.absent(),
                Value<String?> coverImageUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PictureGroupsCompanion(
                id: id,
                setNumber: setNumber,
                name: name,
                textContent: textContent,
                planType: planType,
                planStartDate: planStartDate,
                coverIcon: coverIcon,
                coverColorStart: coverColorStart,
                coverColorEnd: coverColorEnd,
                coverImageUrl: coverImageUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> setNumber = const Value.absent(),
                required String name,
                Value<String?> textContent = const Value.absent(),
                Value<String> planType = const Value.absent(),
                Value<DateTime?> planStartDate = const Value.absent(),
                Value<String?> coverIcon = const Value.absent(),
                Value<String?> coverColorStart = const Value.absent(),
                Value<String?> coverColorEnd = const Value.absent(),
                Value<String?> coverImageUrl = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => PictureGroupsCompanion.insert(
                id: id,
                setNumber: setNumber,
                name: name,
                textContent: textContent,
                planType: planType,
                planStartDate: planStartDate,
                coverIcon: coverIcon,
                coverColorStart: coverColorStart,
                coverColorEnd: coverColorEnd,
                coverImageUrl: coverImageUrl,
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
      Value<int> position,
      Value<bool> isReviewed,
      required DateTime createdAt,
    });
typedef $$GroupPicturesTableUpdateCompanionBuilder =
    GroupPicturesCompanion Function({
      Value<int> id,
      Value<int> pictureGroupId,
      Value<Uint8List> imageBytes,
      Value<int> position,
      Value<bool> isReviewed,
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

  static MultiTypedResultKey<
    $ImageAnnotationStrokesTable,
    List<ImageAnnotationStroke>
  >
  _imageAnnotationStrokesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.imageAnnotationStrokes,
        aliasName: 'group_pictures__id__image_annotation_strokes__picture_id',
      );

  $$ImageAnnotationStrokesTableProcessedTableManager
  get imageAnnotationStrokesRefs {
    final manager = $$ImageAnnotationStrokesTableTableManager(
      $_db,
      $_db.imageAnnotationStrokes,
    ).filter((f) => f.pictureId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _imageAnnotationStrokesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImageNotesTable, List<ImageNote>>
  _imageNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.imageNotes,
    aliasName: 'group_pictures__id__image_notes__picture_id',
  );

  $$ImageNotesTableProcessedTableManager get imageNotesRefs {
    final manager = $$ImageNotesTableTableManager(
      $_db,
      $_db.imageNotes,
    ).filter((f) => f.pictureId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_imageNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
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

  Expression<bool> imageAnnotationStrokesRefs(
    Expression<bool> Function($$ImageAnnotationStrokesTableFilterComposer f) f,
  ) {
    final $$ImageAnnotationStrokesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.imageAnnotationStrokes,
          getReferencedColumn: (t) => t.pictureId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImageAnnotationStrokesTableFilterComposer(
                $db: $db,
                $table: $db.imageAnnotationStrokes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> imageNotesRefs(
    Expression<bool> Function($$ImageNotesTableFilterComposer f) f,
  ) {
    final $$ImageNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imageNotes,
      getReferencedColumn: (t) => t.pictureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImageNotesTableFilterComposer(
            $db: $db,
            $table: $db.imageNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
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

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
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

  Expression<T> imageAnnotationStrokesRefs<T extends Object>(
    Expression<T> Function($$ImageAnnotationStrokesTableAnnotationComposer a) f,
  ) {
    final $$ImageAnnotationStrokesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.imageAnnotationStrokes,
          getReferencedColumn: (t) => t.pictureId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImageAnnotationStrokesTableAnnotationComposer(
                $db: $db,
                $table: $db.imageAnnotationStrokes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> imageNotesRefs<T extends Object>(
    Expression<T> Function($$ImageNotesTableAnnotationComposer a) f,
  ) {
    final $$ImageNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imageNotes,
      getReferencedColumn: (t) => t.pictureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImageNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.imageNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
          PrefetchHooks Function({
            bool pictureGroupId,
            bool imageAnnotationStrokesRefs,
            bool imageNotesRefs,
          })
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
                Value<int> position = const Value.absent(),
                Value<bool> isReviewed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GroupPicturesCompanion(
                id: id,
                pictureGroupId: pictureGroupId,
                imageBytes: imageBytes,
                position: position,
                isReviewed: isReviewed,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pictureGroupId,
                required Uint8List imageBytes,
                Value<int> position = const Value.absent(),
                Value<bool> isReviewed = const Value.absent(),
                required DateTime createdAt,
              }) => GroupPicturesCompanion.insert(
                id: id,
                pictureGroupId: pictureGroupId,
                imageBytes: imageBytes,
                position: position,
                isReviewed: isReviewed,
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
          prefetchHooksCallback:
              ({
                pictureGroupId = false,
                imageAnnotationStrokesRefs = false,
                imageNotesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (imageAnnotationStrokesRefs) db.imageAnnotationStrokes,
                    if (imageNotesRefs) db.imageNotes,
                  ],
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
                                    referencedTable:
                                        $$GroupPicturesTableReferences
                                            ._pictureGroupIdTable(db),
                                    referencedColumn:
                                        $$GroupPicturesTableReferences
                                            ._pictureGroupIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (imageAnnotationStrokesRefs)
                        await $_getPrefetchedData<
                          GroupPicture,
                          $GroupPicturesTable,
                          ImageAnnotationStroke
                        >(
                          currentTable: table,
                          referencedTable: $$GroupPicturesTableReferences
                              ._imageAnnotationStrokesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupPicturesTableReferences(
                                db,
                                table,
                                p0,
                              ).imageAnnotationStrokesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pictureId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (imageNotesRefs)
                        await $_getPrefetchedData<
                          GroupPicture,
                          $GroupPicturesTable,
                          ImageNote
                        >(
                          currentTable: table,
                          referencedTable: $$GroupPicturesTableReferences
                              ._imageNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupPicturesTableReferences(
                                db,
                                table,
                                p0,
                              ).imageNotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pictureId == item.id,
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
      PrefetchHooks Function({
        bool pictureGroupId,
        bool imageAnnotationStrokesRefs,
        bool imageNotesRefs,
      })
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
typedef $$ImageAnnotationStrokesTableCreateCompanionBuilder =
    ImageAnnotationStrokesCompanion Function({
      Value<int> id,
      required int pictureId,
      required String tool,
      required bool isStraight,
      required double thickness,
      required double opacity,
      required int colorValue,
      required Uint8List normalizedPoints,
      required DateTime createdAt,
    });
typedef $$ImageAnnotationStrokesTableUpdateCompanionBuilder =
    ImageAnnotationStrokesCompanion Function({
      Value<int> id,
      Value<int> pictureId,
      Value<String> tool,
      Value<bool> isStraight,
      Value<double> thickness,
      Value<double> opacity,
      Value<int> colorValue,
      Value<Uint8List> normalizedPoints,
      Value<DateTime> createdAt,
    });

final class $$ImageAnnotationStrokesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ImageAnnotationStrokesTable,
          ImageAnnotationStroke
        > {
  $$ImageAnnotationStrokesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupPicturesTable _pictureIdTable(_$AppDatabase db) => db
      .groupPictures
      .createAlias('image_annotation_strokes__picture_id__group_pictures__id');

  $$GroupPicturesTableProcessedTableManager get pictureId {
    final $_column = $_itemColumn<int>('picture_id')!;

    final manager = $$GroupPicturesTableTableManager(
      $_db,
      $_db.groupPictures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pictureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImageAnnotationStrokesTableFilterComposer
    extends Composer<_$AppDatabase, $ImageAnnotationStrokesTable> {
  $$ImageAnnotationStrokesTableFilterComposer({
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

  ColumnFilters<String> get tool => $composableBuilder(
    column: $table.tool,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStraight => $composableBuilder(
    column: $table.isStraight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thickness => $composableBuilder(
    column: $table.thickness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get opacity => $composableBuilder(
    column: $table.opacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get normalizedPoints => $composableBuilder(
    column: $table.normalizedPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupPicturesTableFilterComposer get pictureId {
    final $$GroupPicturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureId,
      referencedTable: $db.groupPictures,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$ImageAnnotationStrokesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageAnnotationStrokesTable> {
  $$ImageAnnotationStrokesTableOrderingComposer({
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

  ColumnOrderings<String> get tool => $composableBuilder(
    column: $table.tool,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStraight => $composableBuilder(
    column: $table.isStraight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thickness => $composableBuilder(
    column: $table.thickness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get opacity => $composableBuilder(
    column: $table.opacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get normalizedPoints => $composableBuilder(
    column: $table.normalizedPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupPicturesTableOrderingComposer get pictureId {
    final $$GroupPicturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureId,
      referencedTable: $db.groupPictures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupPicturesTableOrderingComposer(
            $db: $db,
            $table: $db.groupPictures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImageAnnotationStrokesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageAnnotationStrokesTable> {
  $$ImageAnnotationStrokesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tool =>
      $composableBuilder(column: $table.tool, builder: (column) => column);

  GeneratedColumn<bool> get isStraight => $composableBuilder(
    column: $table.isStraight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get thickness =>
      $composableBuilder(column: $table.thickness, builder: (column) => column);

  GeneratedColumn<double> get opacity =>
      $composableBuilder(column: $table.opacity, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get normalizedPoints => $composableBuilder(
    column: $table.normalizedPoints,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GroupPicturesTableAnnotationComposer get pictureId {
    final $$GroupPicturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureId,
      referencedTable: $db.groupPictures,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$ImageAnnotationStrokesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImageAnnotationStrokesTable,
          ImageAnnotationStroke,
          $$ImageAnnotationStrokesTableFilterComposer,
          $$ImageAnnotationStrokesTableOrderingComposer,
          $$ImageAnnotationStrokesTableAnnotationComposer,
          $$ImageAnnotationStrokesTableCreateCompanionBuilder,
          $$ImageAnnotationStrokesTableUpdateCompanionBuilder,
          (ImageAnnotationStroke, $$ImageAnnotationStrokesTableReferences),
          ImageAnnotationStroke,
          PrefetchHooks Function({bool pictureId})
        > {
  $$ImageAnnotationStrokesTableTableManager(
    _$AppDatabase db,
    $ImageAnnotationStrokesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageAnnotationStrokesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ImageAnnotationStrokesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImageAnnotationStrokesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pictureId = const Value.absent(),
                Value<String> tool = const Value.absent(),
                Value<bool> isStraight = const Value.absent(),
                Value<double> thickness = const Value.absent(),
                Value<double> opacity = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<Uint8List> normalizedPoints = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ImageAnnotationStrokesCompanion(
                id: id,
                pictureId: pictureId,
                tool: tool,
                isStraight: isStraight,
                thickness: thickness,
                opacity: opacity,
                colorValue: colorValue,
                normalizedPoints: normalizedPoints,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pictureId,
                required String tool,
                required bool isStraight,
                required double thickness,
                required double opacity,
                required int colorValue,
                required Uint8List normalizedPoints,
                required DateTime createdAt,
              }) => ImageAnnotationStrokesCompanion.insert(
                id: id,
                pictureId: pictureId,
                tool: tool,
                isStraight: isStraight,
                thickness: thickness,
                opacity: opacity,
                colorValue: colorValue,
                normalizedPoints: normalizedPoints,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ImageAnnotationStrokesTable,
                    ImageAnnotationStroke
                  >(table),
                  $$ImageAnnotationStrokesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pictureId = false}) {
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
                    if (pictureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pictureId,
                                referencedTable:
                                    $$ImageAnnotationStrokesTableReferences
                                        ._pictureIdTable(db),
                                referencedColumn:
                                    $$ImageAnnotationStrokesTableReferences
                                        ._pictureIdTable(db)
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

typedef $$ImageAnnotationStrokesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImageAnnotationStrokesTable,
      ImageAnnotationStroke,
      $$ImageAnnotationStrokesTableFilterComposer,
      $$ImageAnnotationStrokesTableOrderingComposer,
      $$ImageAnnotationStrokesTableAnnotationComposer,
      $$ImageAnnotationStrokesTableCreateCompanionBuilder,
      $$ImageAnnotationStrokesTableUpdateCompanionBuilder,
      (ImageAnnotationStroke, $$ImageAnnotationStrokesTableReferences),
      ImageAnnotationStroke,
      PrefetchHooks Function({bool pictureId})
    >;
typedef $$ImageNotesTableCreateCompanionBuilder =
    ImageNotesCompanion Function({
      Value<int> id,
      required int pictureId,
      required double normalizedX,
      required double normalizedY,
      required String content,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ImageNotesTableUpdateCompanionBuilder =
    ImageNotesCompanion Function({
      Value<int> id,
      Value<int> pictureId,
      Value<double> normalizedX,
      Value<double> normalizedY,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ImageNotesTableReferences
    extends BaseReferences<_$AppDatabase, $ImageNotesTable, ImageNote> {
  $$ImageNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupPicturesTable _pictureIdTable(_$AppDatabase db) => db
      .groupPictures
      .createAlias('image_notes__picture_id__group_pictures__id');

  $$GroupPicturesTableProcessedTableManager get pictureId {
    final $_column = $_itemColumn<int>('picture_id')!;

    final manager = $$GroupPicturesTableTableManager(
      $_db,
      $_db.groupPictures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pictureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImageNotesTableFilterComposer
    extends Composer<_$AppDatabase, $ImageNotesTable> {
  $$ImageNotesTableFilterComposer({
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

  ColumnFilters<double> get normalizedX => $composableBuilder(
    column: $table.normalizedX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get normalizedY => $composableBuilder(
    column: $table.normalizedY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
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

  $$GroupPicturesTableFilterComposer get pictureId {
    final $$GroupPicturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureId,
      referencedTable: $db.groupPictures,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$ImageNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageNotesTable> {
  $$ImageNotesTableOrderingComposer({
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

  ColumnOrderings<double> get normalizedX => $composableBuilder(
    column: $table.normalizedX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get normalizedY => $composableBuilder(
    column: $table.normalizedY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
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

  $$GroupPicturesTableOrderingComposer get pictureId {
    final $$GroupPicturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureId,
      referencedTable: $db.groupPictures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupPicturesTableOrderingComposer(
            $db: $db,
            $table: $db.groupPictures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImageNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageNotesTable> {
  $$ImageNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get normalizedX => $composableBuilder(
    column: $table.normalizedX,
    builder: (column) => column,
  );

  GeneratedColumn<double> get normalizedY => $composableBuilder(
    column: $table.normalizedY,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$GroupPicturesTableAnnotationComposer get pictureId {
    final $$GroupPicturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pictureId,
      referencedTable: $db.groupPictures,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$ImageNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImageNotesTable,
          ImageNote,
          $$ImageNotesTableFilterComposer,
          $$ImageNotesTableOrderingComposer,
          $$ImageNotesTableAnnotationComposer,
          $$ImageNotesTableCreateCompanionBuilder,
          $$ImageNotesTableUpdateCompanionBuilder,
          (ImageNote, $$ImageNotesTableReferences),
          ImageNote,
          PrefetchHooks Function({bool pictureId})
        > {
  $$ImageNotesTableTableManager(_$AppDatabase db, $ImageNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pictureId = const Value.absent(),
                Value<double> normalizedX = const Value.absent(),
                Value<double> normalizedY = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ImageNotesCompanion(
                id: id,
                pictureId: pictureId,
                normalizedX: normalizedX,
                normalizedY: normalizedY,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pictureId,
                required double normalizedX,
                required double normalizedY,
                required String content,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ImageNotesCompanion.insert(
                id: id,
                pictureId: pictureId,
                normalizedX: normalizedX,
                normalizedY: normalizedY,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImageNotesTable, ImageNote>(table),
                  $$ImageNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pictureId = false}) {
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
                    if (pictureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pictureId,
                                referencedTable: $$ImageNotesTableReferences
                                    ._pictureIdTable(db),
                                referencedColumn: $$ImageNotesTableReferences
                                    ._pictureIdTable(db)
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

typedef $$ImageNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImageNotesTable,
      ImageNote,
      $$ImageNotesTableFilterComposer,
      $$ImageNotesTableOrderingComposer,
      $$ImageNotesTableAnnotationComposer,
      $$ImageNotesTableCreateCompanionBuilder,
      $$ImageNotesTableUpdateCompanionBuilder,
      (ImageNote, $$ImageNotesTableReferences),
      ImageNote,
      PrefetchHooks Function({bool pictureId})
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
  $$ImageAnnotationStrokesTableTableManager get imageAnnotationStrokes =>
      $$ImageAnnotationStrokesTableTableManager(
        _db,
        _db.imageAnnotationStrokes,
      );
  $$ImageNotesTableTableManager get imageNotes =>
      $$ImageNotesTableTableManager(_db, _db.imageNotes);
}
