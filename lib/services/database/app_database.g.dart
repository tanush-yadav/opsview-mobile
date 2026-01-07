// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceMeta = const VerificationMeta(
    'service',
  );
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
    'service',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userJsonMeta = const VerificationMeta(
    'userJson',
  );
  @override
  late final GeneratedColumn<String> userJson = GeneratedColumn<String>(
    'user_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _examJsonMeta = const VerificationMeta(
    'examJson',
  );
  @override
  late final GeneratedColumn<String> examJson = GeneratedColumn<String>(
    'exam_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _centerJsonMeta = const VerificationMeta(
    'centerJson',
  );
  @override
  late final GeneratedColumn<String> centerJson = GeneratedColumn<String>(
    'center_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onboardingStepMeta = const VerificationMeta(
    'onboardingStep',
  );
  @override
  late final GeneratedColumn<String> onboardingStep = GeneratedColumn<String>(
    'onboarding_step',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmation'),
  );
  static const VerificationMeta _selectedShiftIdMeta = const VerificationMeta(
    'selectedShiftId',
  );
  @override
  late final GeneratedColumn<String> selectedShiftId = GeneratedColumn<String>(
    'selected_shift_id',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    service,
    userJson,
    examJson,
    centerJson,
    onboardingStep,
    selectedShiftId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    }
    if (data.containsKey('user_json')) {
      context.handle(
        _userJsonMeta,
        userJson.isAcceptableOrUnknown(data['user_json']!, _userJsonMeta),
      );
    }
    if (data.containsKey('exam_json')) {
      context.handle(
        _examJsonMeta,
        examJson.isAcceptableOrUnknown(data['exam_json']!, _examJsonMeta),
      );
    }
    if (data.containsKey('center_json')) {
      context.handle(
        _centerJsonMeta,
        centerJson.isAcceptableOrUnknown(data['center_json']!, _centerJsonMeta),
      );
    }
    if (data.containsKey('onboarding_step')) {
      context.handle(
        _onboardingStepMeta,
        onboardingStep.isAcceptableOrUnknown(
          data['onboarding_step']!,
          _onboardingStepMeta,
        ),
      );
    }
    if (data.containsKey('selected_shift_id')) {
      context.handle(
        _selectedShiftIdMeta,
        selectedShiftId.isAcceptableOrUnknown(
          data['selected_shift_id']!,
          _selectedShiftIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      ),
      userJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_json'],
      ),
      examJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_json'],
      ),
      centerJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}center_json'],
      ),
      onboardingStep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}onboarding_step'],
      )!,
      selectedShiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_shift_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String? service;
  final String? userJson;
  final String? examJson;
  final String? centerJson;
  final String onboardingStep;
  final String? selectedShiftId;
  final DateTime createdAt;
  const Session({
    required this.id,
    this.service,
    this.userJson,
    this.examJson,
    this.centerJson,
    required this.onboardingStep,
    this.selectedShiftId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || service != null) {
      map['service'] = Variable<String>(service);
    }
    if (!nullToAbsent || userJson != null) {
      map['user_json'] = Variable<String>(userJson);
    }
    if (!nullToAbsent || examJson != null) {
      map['exam_json'] = Variable<String>(examJson);
    }
    if (!nullToAbsent || centerJson != null) {
      map['center_json'] = Variable<String>(centerJson);
    }
    map['onboarding_step'] = Variable<String>(onboardingStep);
    if (!nullToAbsent || selectedShiftId != null) {
      map['selected_shift_id'] = Variable<String>(selectedShiftId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      service: service == null && nullToAbsent
          ? const Value.absent()
          : Value(service),
      userJson: userJson == null && nullToAbsent
          ? const Value.absent()
          : Value(userJson),
      examJson: examJson == null && nullToAbsent
          ? const Value.absent()
          : Value(examJson),
      centerJson: centerJson == null && nullToAbsent
          ? const Value.absent()
          : Value(centerJson),
      onboardingStep: Value(onboardingStep),
      selectedShiftId: selectedShiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedShiftId),
      createdAt: Value(createdAt),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      service: serializer.fromJson<String?>(json['service']),
      userJson: serializer.fromJson<String?>(json['userJson']),
      examJson: serializer.fromJson<String?>(json['examJson']),
      centerJson: serializer.fromJson<String?>(json['centerJson']),
      onboardingStep: serializer.fromJson<String>(json['onboardingStep']),
      selectedShiftId: serializer.fromJson<String?>(json['selectedShiftId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'service': serializer.toJson<String?>(service),
      'userJson': serializer.toJson<String?>(userJson),
      'examJson': serializer.toJson<String?>(examJson),
      'centerJson': serializer.toJson<String?>(centerJson),
      'onboardingStep': serializer.toJson<String>(onboardingStep),
      'selectedShiftId': serializer.toJson<String?>(selectedShiftId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Session copyWith({
    String? id,
    Value<String?> service = const Value.absent(),
    Value<String?> userJson = const Value.absent(),
    Value<String?> examJson = const Value.absent(),
    Value<String?> centerJson = const Value.absent(),
    String? onboardingStep,
    Value<String?> selectedShiftId = const Value.absent(),
    DateTime? createdAt,
  }) => Session(
    id: id ?? this.id,
    service: service.present ? service.value : this.service,
    userJson: userJson.present ? userJson.value : this.userJson,
    examJson: examJson.present ? examJson.value : this.examJson,
    centerJson: centerJson.present ? centerJson.value : this.centerJson,
    onboardingStep: onboardingStep ?? this.onboardingStep,
    selectedShiftId: selectedShiftId.present
        ? selectedShiftId.value
        : this.selectedShiftId,
    createdAt: createdAt ?? this.createdAt,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      service: data.service.present ? data.service.value : this.service,
      userJson: data.userJson.present ? data.userJson.value : this.userJson,
      examJson: data.examJson.present ? data.examJson.value : this.examJson,
      centerJson: data.centerJson.present
          ? data.centerJson.value
          : this.centerJson,
      onboardingStep: data.onboardingStep.present
          ? data.onboardingStep.value
          : this.onboardingStep,
      selectedShiftId: data.selectedShiftId.present
          ? data.selectedShiftId.value
          : this.selectedShiftId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('service: $service, ')
          ..write('userJson: $userJson, ')
          ..write('examJson: $examJson, ')
          ..write('centerJson: $centerJson, ')
          ..write('onboardingStep: $onboardingStep, ')
          ..write('selectedShiftId: $selectedShiftId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    service,
    userJson,
    examJson,
    centerJson,
    onboardingStep,
    selectedShiftId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.service == this.service &&
          other.userJson == this.userJson &&
          other.examJson == this.examJson &&
          other.centerJson == this.centerJson &&
          other.onboardingStep == this.onboardingStep &&
          other.selectedShiftId == this.selectedShiftId &&
          other.createdAt == this.createdAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String?> service;
  final Value<String?> userJson;
  final Value<String?> examJson;
  final Value<String?> centerJson;
  final Value<String> onboardingStep;
  final Value<String?> selectedShiftId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.service = const Value.absent(),
    this.userJson = const Value.absent(),
    this.examJson = const Value.absent(),
    this.centerJson = const Value.absent(),
    this.onboardingStep = const Value.absent(),
    this.selectedShiftId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    this.service = const Value.absent(),
    this.userJson = const Value.absent(),
    this.examJson = const Value.absent(),
    this.centerJson = const Value.absent(),
    this.onboardingStep = const Value.absent(),
    this.selectedShiftId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? service,
    Expression<String>? userJson,
    Expression<String>? examJson,
    Expression<String>? centerJson,
    Expression<String>? onboardingStep,
    Expression<String>? selectedShiftId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (service != null) 'service': service,
      if (userJson != null) 'user_json': userJson,
      if (examJson != null) 'exam_json': examJson,
      if (centerJson != null) 'center_json': centerJson,
      if (onboardingStep != null) 'onboarding_step': onboardingStep,
      if (selectedShiftId != null) 'selected_shift_id': selectedShiftId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? service,
    Value<String?>? userJson,
    Value<String?>? examJson,
    Value<String?>? centerJson,
    Value<String>? onboardingStep,
    Value<String?>? selectedShiftId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      service: service ?? this.service,
      userJson: userJson ?? this.userJson,
      examJson: examJson ?? this.examJson,
      centerJson: centerJson ?? this.centerJson,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      selectedShiftId: selectedShiftId ?? this.selectedShiftId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (userJson.present) {
      map['user_json'] = Variable<String>(userJson.value);
    }
    if (examJson.present) {
      map['exam_json'] = Variable<String>(examJson.value);
    }
    if (centerJson.present) {
      map['center_json'] = Variable<String>(centerJson.value);
    }
    if (onboardingStep.present) {
      map['onboarding_step'] = Variable<String>(onboardingStep.value);
    }
    if (selectedShiftId.present) {
      map['selected_shift_id'] = Variable<String>(selectedShiftId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('service: $service, ')
          ..write('userJson: $userJson, ')
          ..write('examJson: $examJson, ')
          ..write('centerJson: $centerJson, ')
          ..write('onboardingStep: $onboardingStep, ')
          ..write('selectedShiftId: $selectedShiftId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _contactMeta = const VerificationMeta(
    'contact',
  );
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
    'contact',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aadhaarMeta = const VerificationMeta(
    'aadhaar',
  );
  @override
  late final GeneratedColumn<String> aadhaar = GeneratedColumn<String>(
    'aadhaar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selfieLocalPathMeta = const VerificationMeta(
    'selfieLocalPath',
  );
  @override
  late final GeneratedColumn<String> selfieLocalPath = GeneratedColumn<String>(
    'selfie_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _livenessStatusMeta = const VerificationMeta(
    'livenessStatus',
  );
  @override
  late final GeneratedColumn<String> livenessStatus = GeneratedColumn<String>(
    'liveness_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _livenessScoreMeta = const VerificationMeta(
    'livenessScore',
  );
  @override
  late final GeneratedColumn<double> livenessScore = GeneratedColumn<double>(
    'liveness_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _livenessAttemptedAtMeta =
      const VerificationMeta('livenessAttemptedAt');
  @override
  late final GeneratedColumn<DateTime> livenessAttemptedAt =
      GeneratedColumn<DateTime>(
        'liveness_attempted_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mobileVerificationIdMeta =
      const VerificationMeta('mobileVerificationId');
  @override
  late final GeneratedColumn<String> mobileVerificationId =
      GeneratedColumn<String>(
        'mobile_verification_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _backendProfileIdMeta = const VerificationMeta(
    'backendProfileId',
  );
  @override
  late final GeneratedColumn<String> backendProfileId = GeneratedColumn<String>(
    'backend_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trainingCompletedMeta = const VerificationMeta(
    'trainingCompleted',
  );
  @override
  late final GeneratedColumn<bool> trainingCompleted = GeneratedColumn<bool>(
    'training_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("training_completed" IN (0, 1))',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shiftId,
    name,
    contact,
    age,
    aadhaar,
    selfieLocalPath,
    livenessStatus,
    livenessScore,
    livenessAttemptedAt,
    latitude,
    longitude,
    location,
    mobileVerificationId,
    backendProfileId,
    trainingCompleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact')) {
      context.handle(
        _contactMeta,
        contact.isAcceptableOrUnknown(data['contact']!, _contactMeta),
      );
    } else if (isInserting) {
      context.missing(_contactMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('aadhaar')) {
      context.handle(
        _aadhaarMeta,
        aadhaar.isAcceptableOrUnknown(data['aadhaar']!, _aadhaarMeta),
      );
    } else if (isInserting) {
      context.missing(_aadhaarMeta);
    }
    if (data.containsKey('selfie_local_path')) {
      context.handle(
        _selfieLocalPathMeta,
        selfieLocalPath.isAcceptableOrUnknown(
          data['selfie_local_path']!,
          _selfieLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('liveness_status')) {
      context.handle(
        _livenessStatusMeta,
        livenessStatus.isAcceptableOrUnknown(
          data['liveness_status']!,
          _livenessStatusMeta,
        ),
      );
    }
    if (data.containsKey('liveness_score')) {
      context.handle(
        _livenessScoreMeta,
        livenessScore.isAcceptableOrUnknown(
          data['liveness_score']!,
          _livenessScoreMeta,
        ),
      );
    }
    if (data.containsKey('liveness_attempted_at')) {
      context.handle(
        _livenessAttemptedAtMeta,
        livenessAttemptedAt.isAcceptableOrUnknown(
          data['liveness_attempted_at']!,
          _livenessAttemptedAtMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('mobile_verification_id')) {
      context.handle(
        _mobileVerificationIdMeta,
        mobileVerificationId.isAcceptableOrUnknown(
          data['mobile_verification_id']!,
          _mobileVerificationIdMeta,
        ),
      );
    }
    if (data.containsKey('backend_profile_id')) {
      context.handle(
        _backendProfileIdMeta,
        backendProfileId.isAcceptableOrUnknown(
          data['backend_profile_id']!,
          _backendProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('training_completed')) {
      context.handle(
        _trainingCompletedMeta,
        trainingCompleted.isAcceptableOrUnknown(
          data['training_completed']!,
          _trainingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      aadhaar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aadhaar'],
      )!,
      selfieLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selfie_local_path'],
      ),
      livenessStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liveness_status'],
      )!,
      livenessScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}liveness_score'],
      ),
      livenessAttemptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}liveness_attempted_at'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      mobileVerificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_verification_id'],
      ),
      backendProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backend_profile_id'],
      ),
      trainingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}training_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String shiftId;
  final String name;
  final String contact;
  final int age;
  final String aadhaar;
  final String? selfieLocalPath;
  final String livenessStatus;
  final double? livenessScore;
  final DateTime? livenessAttemptedAt;
  final double? latitude;
  final double? longitude;
  final String? location;
  final String? mobileVerificationId;
  final String? backendProfileId;
  final bool trainingCompleted;
  final DateTime createdAt;
  const Profile({
    required this.id,
    required this.shiftId,
    required this.name,
    required this.contact,
    required this.age,
    required this.aadhaar,
    this.selfieLocalPath,
    required this.livenessStatus,
    this.livenessScore,
    this.livenessAttemptedAt,
    this.latitude,
    this.longitude,
    this.location,
    this.mobileVerificationId,
    this.backendProfileId,
    required this.trainingCompleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shift_id'] = Variable<String>(shiftId);
    map['name'] = Variable<String>(name);
    map['contact'] = Variable<String>(contact);
    map['age'] = Variable<int>(age);
    map['aadhaar'] = Variable<String>(aadhaar);
    if (!nullToAbsent || selfieLocalPath != null) {
      map['selfie_local_path'] = Variable<String>(selfieLocalPath);
    }
    map['liveness_status'] = Variable<String>(livenessStatus);
    if (!nullToAbsent || livenessScore != null) {
      map['liveness_score'] = Variable<double>(livenessScore);
    }
    if (!nullToAbsent || livenessAttemptedAt != null) {
      map['liveness_attempted_at'] = Variable<DateTime>(livenessAttemptedAt);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || mobileVerificationId != null) {
      map['mobile_verification_id'] = Variable<String>(mobileVerificationId);
    }
    if (!nullToAbsent || backendProfileId != null) {
      map['backend_profile_id'] = Variable<String>(backendProfileId);
    }
    map['training_completed'] = Variable<bool>(trainingCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      shiftId: Value(shiftId),
      name: Value(name),
      contact: Value(contact),
      age: Value(age),
      aadhaar: Value(aadhaar),
      selfieLocalPath: selfieLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(selfieLocalPath),
      livenessStatus: Value(livenessStatus),
      livenessScore: livenessScore == null && nullToAbsent
          ? const Value.absent()
          : Value(livenessScore),
      livenessAttemptedAt: livenessAttemptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(livenessAttemptedAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      mobileVerificationId: mobileVerificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(mobileVerificationId),
      backendProfileId: backendProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(backendProfileId),
      trainingCompleted: Value(trainingCompleted),
      createdAt: Value(createdAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      name: serializer.fromJson<String>(json['name']),
      contact: serializer.fromJson<String>(json['contact']),
      age: serializer.fromJson<int>(json['age']),
      aadhaar: serializer.fromJson<String>(json['aadhaar']),
      selfieLocalPath: serializer.fromJson<String?>(json['selfieLocalPath']),
      livenessStatus: serializer.fromJson<String>(json['livenessStatus']),
      livenessScore: serializer.fromJson<double?>(json['livenessScore']),
      livenessAttemptedAt: serializer.fromJson<DateTime?>(
        json['livenessAttemptedAt'],
      ),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      location: serializer.fromJson<String?>(json['location']),
      mobileVerificationId: serializer.fromJson<String?>(
        json['mobileVerificationId'],
      ),
      backendProfileId: serializer.fromJson<String?>(json['backendProfileId']),
      trainingCompleted: serializer.fromJson<bool>(json['trainingCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shiftId': serializer.toJson<String>(shiftId),
      'name': serializer.toJson<String>(name),
      'contact': serializer.toJson<String>(contact),
      'age': serializer.toJson<int>(age),
      'aadhaar': serializer.toJson<String>(aadhaar),
      'selfieLocalPath': serializer.toJson<String?>(selfieLocalPath),
      'livenessStatus': serializer.toJson<String>(livenessStatus),
      'livenessScore': serializer.toJson<double?>(livenessScore),
      'livenessAttemptedAt': serializer.toJson<DateTime?>(livenessAttemptedAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'location': serializer.toJson<String?>(location),
      'mobileVerificationId': serializer.toJson<String?>(mobileVerificationId),
      'backendProfileId': serializer.toJson<String?>(backendProfileId),
      'trainingCompleted': serializer.toJson<bool>(trainingCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Profile copyWith({
    String? id,
    String? shiftId,
    String? name,
    String? contact,
    int? age,
    String? aadhaar,
    Value<String?> selfieLocalPath = const Value.absent(),
    String? livenessStatus,
    Value<double?> livenessScore = const Value.absent(),
    Value<DateTime?> livenessAttemptedAt = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> mobileVerificationId = const Value.absent(),
    Value<String?> backendProfileId = const Value.absent(),
    bool? trainingCompleted,
    DateTime? createdAt,
  }) => Profile(
    id: id ?? this.id,
    shiftId: shiftId ?? this.shiftId,
    name: name ?? this.name,
    contact: contact ?? this.contact,
    age: age ?? this.age,
    aadhaar: aadhaar ?? this.aadhaar,
    selfieLocalPath: selfieLocalPath.present
        ? selfieLocalPath.value
        : this.selfieLocalPath,
    livenessStatus: livenessStatus ?? this.livenessStatus,
    livenessScore: livenessScore.present
        ? livenessScore.value
        : this.livenessScore,
    livenessAttemptedAt: livenessAttemptedAt.present
        ? livenessAttemptedAt.value
        : this.livenessAttemptedAt,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    location: location.present ? location.value : this.location,
    mobileVerificationId: mobileVerificationId.present
        ? mobileVerificationId.value
        : this.mobileVerificationId,
    backendProfileId: backendProfileId.present
        ? backendProfileId.value
        : this.backendProfileId,
    trainingCompleted: trainingCompleted ?? this.trainingCompleted,
    createdAt: createdAt ?? this.createdAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      name: data.name.present ? data.name.value : this.name,
      contact: data.contact.present ? data.contact.value : this.contact,
      age: data.age.present ? data.age.value : this.age,
      aadhaar: data.aadhaar.present ? data.aadhaar.value : this.aadhaar,
      selfieLocalPath: data.selfieLocalPath.present
          ? data.selfieLocalPath.value
          : this.selfieLocalPath,
      livenessStatus: data.livenessStatus.present
          ? data.livenessStatus.value
          : this.livenessStatus,
      livenessScore: data.livenessScore.present
          ? data.livenessScore.value
          : this.livenessScore,
      livenessAttemptedAt: data.livenessAttemptedAt.present
          ? data.livenessAttemptedAt.value
          : this.livenessAttemptedAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      location: data.location.present ? data.location.value : this.location,
      mobileVerificationId: data.mobileVerificationId.present
          ? data.mobileVerificationId.value
          : this.mobileVerificationId,
      backendProfileId: data.backendProfileId.present
          ? data.backendProfileId.value
          : this.backendProfileId,
      trainingCompleted: data.trainingCompleted.present
          ? data.trainingCompleted.value
          : this.trainingCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('age: $age, ')
          ..write('aadhaar: $aadhaar, ')
          ..write('selfieLocalPath: $selfieLocalPath, ')
          ..write('livenessStatus: $livenessStatus, ')
          ..write('livenessScore: $livenessScore, ')
          ..write('livenessAttemptedAt: $livenessAttemptedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('location: $location, ')
          ..write('mobileVerificationId: $mobileVerificationId, ')
          ..write('backendProfileId: $backendProfileId, ')
          ..write('trainingCompleted: $trainingCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shiftId,
    name,
    contact,
    age,
    aadhaar,
    selfieLocalPath,
    livenessStatus,
    livenessScore,
    livenessAttemptedAt,
    latitude,
    longitude,
    location,
    mobileVerificationId,
    backendProfileId,
    trainingCompleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.shiftId == this.shiftId &&
          other.name == this.name &&
          other.contact == this.contact &&
          other.age == this.age &&
          other.aadhaar == this.aadhaar &&
          other.selfieLocalPath == this.selfieLocalPath &&
          other.livenessStatus == this.livenessStatus &&
          other.livenessScore == this.livenessScore &&
          other.livenessAttemptedAt == this.livenessAttemptedAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.location == this.location &&
          other.mobileVerificationId == this.mobileVerificationId &&
          other.backendProfileId == this.backendProfileId &&
          other.trainingCompleted == this.trainingCompleted &&
          other.createdAt == this.createdAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String> shiftId;
  final Value<String> name;
  final Value<String> contact;
  final Value<int> age;
  final Value<String> aadhaar;
  final Value<String?> selfieLocalPath;
  final Value<String> livenessStatus;
  final Value<double?> livenessScore;
  final Value<DateTime?> livenessAttemptedAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> location;
  final Value<String?> mobileVerificationId;
  final Value<String?> backendProfileId;
  final Value<bool> trainingCompleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.name = const Value.absent(),
    this.contact = const Value.absent(),
    this.age = const Value.absent(),
    this.aadhaar = const Value.absent(),
    this.selfieLocalPath = const Value.absent(),
    this.livenessStatus = const Value.absent(),
    this.livenessScore = const Value.absent(),
    this.livenessAttemptedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.location = const Value.absent(),
    this.mobileVerificationId = const Value.absent(),
    this.backendProfileId = const Value.absent(),
    this.trainingCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required String shiftId,
    required String name,
    required String contact,
    required int age,
    required String aadhaar,
    this.selfieLocalPath = const Value.absent(),
    this.livenessStatus = const Value.absent(),
    this.livenessScore = const Value.absent(),
    this.livenessAttemptedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.location = const Value.absent(),
    this.mobileVerificationId = const Value.absent(),
    this.backendProfileId = const Value.absent(),
    this.trainingCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shiftId = Value(shiftId),
       name = Value(name),
       contact = Value(contact),
       age = Value(age),
       aadhaar = Value(aadhaar);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? shiftId,
    Expression<String>? name,
    Expression<String>? contact,
    Expression<int>? age,
    Expression<String>? aadhaar,
    Expression<String>? selfieLocalPath,
    Expression<String>? livenessStatus,
    Expression<double>? livenessScore,
    Expression<DateTime>? livenessAttemptedAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? location,
    Expression<String>? mobileVerificationId,
    Expression<String>? backendProfileId,
    Expression<bool>? trainingCompleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftId != null) 'shift_id': shiftId,
      if (name != null) 'name': name,
      if (contact != null) 'contact': contact,
      if (age != null) 'age': age,
      if (aadhaar != null) 'aadhaar': aadhaar,
      if (selfieLocalPath != null) 'selfie_local_path': selfieLocalPath,
      if (livenessStatus != null) 'liveness_status': livenessStatus,
      if (livenessScore != null) 'liveness_score': livenessScore,
      if (livenessAttemptedAt != null)
        'liveness_attempted_at': livenessAttemptedAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (location != null) 'location': location,
      if (mobileVerificationId != null)
        'mobile_verification_id': mobileVerificationId,
      if (backendProfileId != null) 'backend_profile_id': backendProfileId,
      if (trainingCompleted != null) 'training_completed': trainingCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? shiftId,
    Value<String>? name,
    Value<String>? contact,
    Value<int>? age,
    Value<String>? aadhaar,
    Value<String?>? selfieLocalPath,
    Value<String>? livenessStatus,
    Value<double?>? livenessScore,
    Value<DateTime?>? livenessAttemptedAt,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? location,
    Value<String?>? mobileVerificationId,
    Value<String?>? backendProfileId,
    Value<bool>? trainingCompleted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      age: age ?? this.age,
      aadhaar: aadhaar ?? this.aadhaar,
      selfieLocalPath: selfieLocalPath ?? this.selfieLocalPath,
      livenessStatus: livenessStatus ?? this.livenessStatus,
      livenessScore: livenessScore ?? this.livenessScore,
      livenessAttemptedAt: livenessAttemptedAt ?? this.livenessAttemptedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      mobileVerificationId: mobileVerificationId ?? this.mobileVerificationId,
      backendProfileId: backendProfileId ?? this.backendProfileId,
      trainingCompleted: trainingCompleted ?? this.trainingCompleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (aadhaar.present) {
      map['aadhaar'] = Variable<String>(aadhaar.value);
    }
    if (selfieLocalPath.present) {
      map['selfie_local_path'] = Variable<String>(selfieLocalPath.value);
    }
    if (livenessStatus.present) {
      map['liveness_status'] = Variable<String>(livenessStatus.value);
    }
    if (livenessScore.present) {
      map['liveness_score'] = Variable<double>(livenessScore.value);
    }
    if (livenessAttemptedAt.present) {
      map['liveness_attempted_at'] = Variable<DateTime>(
        livenessAttemptedAt.value,
      );
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (mobileVerificationId.present) {
      map['mobile_verification_id'] = Variable<String>(
        mobileVerificationId.value,
      );
    }
    if (backendProfileId.present) {
      map['backend_profile_id'] = Variable<String>(backendProfileId.value);
    }
    if (trainingCompleted.present) {
      map['training_completed'] = Variable<bool>(trainingCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('age: $age, ')
          ..write('aadhaar: $aadhaar, ')
          ..write('selfieLocalPath: $selfieLocalPath, ')
          ..write('livenessStatus: $livenessStatus, ')
          ..write('livenessScore: $livenessScore, ')
          ..write('livenessAttemptedAt: $livenessAttemptedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('location: $location, ')
          ..write('mobileVerificationId: $mobileVerificationId, ')
          ..write('backendProfileId: $backendProfileId, ')
          ..write('trainingCompleted: $trainingCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientCodeMeta = const VerificationMeta(
    'clientCode',
  );
  @override
  late final GeneratedColumn<String> clientCode = GeneratedColumn<String>(
    'client_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<String> examId = GeneratedColumn<String>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _centerIdMeta = const VerificationMeta(
    'centerId',
  );
  @override
  late final GeneratedColumn<String> centerId = GeneratedColumn<String>(
    'center_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceMeta = const VerificationMeta(
    'service',
  );
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
    'service',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqNumberMeta = const VerificationMeta(
    'seqNumber',
  );
  @override
  late final GeneratedColumn<int> seqNumber = GeneratedColumn<int>(
    'seq_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _requiredMeta = const VerificationMeta(
    'required',
  );
  @override
  late final GeneratedColumn<bool> required = GeneratedColumn<bool>(
    'required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("required" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskLabelMeta = const VerificationMeta(
    'taskLabel',
  );
  @override
  late final GeneratedColumn<String> taskLabel = GeneratedColumn<String>(
    'task_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskDescMeta = const VerificationMeta(
    'taskDesc',
  );
  @override
  late final GeneratedColumn<String> taskDesc = GeneratedColumn<String>(
    'task_desc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskTypeMeta = const VerificationMeta(
    'taskType',
  );
  @override
  late final GeneratedColumn<String> taskType = GeneratedColumn<String>(
    'task_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('IMAGE'),
  );
  static const VerificationMeta _taskStatusMeta = const VerificationMeta(
    'taskStatus',
  );
  @override
  late final GeneratedColumn<String> taskStatus = GeneratedColumn<String>(
    'task_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _centerCodeMeta = const VerificationMeta(
    'centerCode',
  );
  @override
  late final GeneratedColumn<String> centerCode = GeneratedColumn<String>(
    'center_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _centerNameMeta = const VerificationMeta(
    'centerName',
  );
  @override
  late final GeneratedColumn<String> centerName = GeneratedColumn<String>(
    'center_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metaDataJsonMeta = const VerificationMeta(
    'metaDataJson',
  );
  @override
  late final GeneratedColumn<String> metaDataJson = GeneratedColumn<String>(
    'meta_data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checklistJsonMeta = const VerificationMeta(
    'checklistJson',
  );
  @override
  late final GeneratedColumn<String> checklistJson = GeneratedColumn<String>(
    'checklist_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientCode,
    examId,
    centerId,
    shiftId,
    service,
    seqNumber,
    required,
    taskId,
    taskLabel,
    taskDesc,
    taskType,
    taskStatus,
    centerCode,
    centerName,
    metaDataJson,
    checklistJson,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_code')) {
      context.handle(
        _clientCodeMeta,
        clientCode.isAcceptableOrUnknown(data['client_code']!, _clientCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_clientCodeMeta);
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('center_id')) {
      context.handle(
        _centerIdMeta,
        centerId.isAcceptableOrUnknown(data['center_id']!, _centerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_centerIdMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    } else if (isInserting) {
      context.missing(_serviceMeta);
    }
    if (data.containsKey('seq_number')) {
      context.handle(
        _seqNumberMeta,
        seqNumber.isAcceptableOrUnknown(data['seq_number']!, _seqNumberMeta),
      );
    }
    if (data.containsKey('required')) {
      context.handle(
        _requiredMeta,
        required.isAcceptableOrUnknown(data['required']!, _requiredMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('task_label')) {
      context.handle(
        _taskLabelMeta,
        taskLabel.isAcceptableOrUnknown(data['task_label']!, _taskLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_taskLabelMeta);
    }
    if (data.containsKey('task_desc')) {
      context.handle(
        _taskDescMeta,
        taskDesc.isAcceptableOrUnknown(data['task_desc']!, _taskDescMeta),
      );
    }
    if (data.containsKey('task_type')) {
      context.handle(
        _taskTypeMeta,
        taskType.isAcceptableOrUnknown(data['task_type']!, _taskTypeMeta),
      );
    }
    if (data.containsKey('task_status')) {
      context.handle(
        _taskStatusMeta,
        taskStatus.isAcceptableOrUnknown(data['task_status']!, _taskStatusMeta),
      );
    }
    if (data.containsKey('center_code')) {
      context.handle(
        _centerCodeMeta,
        centerCode.isAcceptableOrUnknown(data['center_code']!, _centerCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_centerCodeMeta);
    }
    if (data.containsKey('center_name')) {
      context.handle(
        _centerNameMeta,
        centerName.isAcceptableOrUnknown(data['center_name']!, _centerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_centerNameMeta);
    }
    if (data.containsKey('meta_data_json')) {
      context.handle(
        _metaDataJsonMeta,
        metaDataJson.isAcceptableOrUnknown(
          data['meta_data_json']!,
          _metaDataJsonMeta,
        ),
      );
    }
    if (data.containsKey('checklist_json')) {
      context.handle(
        _checklistJsonMeta,
        checklistJson.isAcceptableOrUnknown(
          data['checklist_json']!,
          _checklistJsonMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_code'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_id'],
      )!,
      centerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}center_id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      seqNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq_number'],
      )!,
      required: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}required'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      taskLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_label'],
      )!,
      taskDesc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_desc'],
      ),
      taskType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_type'],
      )!,
      taskStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_status'],
      )!,
      centerCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}center_code'],
      )!,
      centerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}center_name'],
      )!,
      metaDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_data_json'],
      ),
      checklistJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checklist_json'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String clientCode;
  final String examId;
  final String centerId;
  final String shiftId;
  final String service;
  final int seqNumber;
  final bool required;
  final String taskId;
  final String taskLabel;
  final String? taskDesc;
  final String taskType;
  final String taskStatus;
  final String centerCode;
  final String centerName;
  final String? metaDataJson;
  final String? checklistJson;
  final DateTime downloadedAt;
  const Task({
    required this.id,
    required this.clientCode,
    required this.examId,
    required this.centerId,
    required this.shiftId,
    required this.service,
    required this.seqNumber,
    required this.required,
    required this.taskId,
    required this.taskLabel,
    this.taskDesc,
    required this.taskType,
    required this.taskStatus,
    required this.centerCode,
    required this.centerName,
    this.metaDataJson,
    this.checklistJson,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_code'] = Variable<String>(clientCode);
    map['exam_id'] = Variable<String>(examId);
    map['center_id'] = Variable<String>(centerId);
    map['shift_id'] = Variable<String>(shiftId);
    map['service'] = Variable<String>(service);
    map['seq_number'] = Variable<int>(seqNumber);
    map['required'] = Variable<bool>(required);
    map['task_id'] = Variable<String>(taskId);
    map['task_label'] = Variable<String>(taskLabel);
    if (!nullToAbsent || taskDesc != null) {
      map['task_desc'] = Variable<String>(taskDesc);
    }
    map['task_type'] = Variable<String>(taskType);
    map['task_status'] = Variable<String>(taskStatus);
    map['center_code'] = Variable<String>(centerCode);
    map['center_name'] = Variable<String>(centerName);
    if (!nullToAbsent || metaDataJson != null) {
      map['meta_data_json'] = Variable<String>(metaDataJson);
    }
    if (!nullToAbsent || checklistJson != null) {
      map['checklist_json'] = Variable<String>(checklistJson);
    }
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      clientCode: Value(clientCode),
      examId: Value(examId),
      centerId: Value(centerId),
      shiftId: Value(shiftId),
      service: Value(service),
      seqNumber: Value(seqNumber),
      required: Value(required),
      taskId: Value(taskId),
      taskLabel: Value(taskLabel),
      taskDesc: taskDesc == null && nullToAbsent
          ? const Value.absent()
          : Value(taskDesc),
      taskType: Value(taskType),
      taskStatus: Value(taskStatus),
      centerCode: Value(centerCode),
      centerName: Value(centerName),
      metaDataJson: metaDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metaDataJson),
      checklistJson: checklistJson == null && nullToAbsent
          ? const Value.absent()
          : Value(checklistJson),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      clientCode: serializer.fromJson<String>(json['clientCode']),
      examId: serializer.fromJson<String>(json['examId']),
      centerId: serializer.fromJson<String>(json['centerId']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      service: serializer.fromJson<String>(json['service']),
      seqNumber: serializer.fromJson<int>(json['seqNumber']),
      required: serializer.fromJson<bool>(json['required']),
      taskId: serializer.fromJson<String>(json['taskId']),
      taskLabel: serializer.fromJson<String>(json['taskLabel']),
      taskDesc: serializer.fromJson<String?>(json['taskDesc']),
      taskType: serializer.fromJson<String>(json['taskType']),
      taskStatus: serializer.fromJson<String>(json['taskStatus']),
      centerCode: serializer.fromJson<String>(json['centerCode']),
      centerName: serializer.fromJson<String>(json['centerName']),
      metaDataJson: serializer.fromJson<String?>(json['metaDataJson']),
      checklistJson: serializer.fromJson<String?>(json['checklistJson']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientCode': serializer.toJson<String>(clientCode),
      'examId': serializer.toJson<String>(examId),
      'centerId': serializer.toJson<String>(centerId),
      'shiftId': serializer.toJson<String>(shiftId),
      'service': serializer.toJson<String>(service),
      'seqNumber': serializer.toJson<int>(seqNumber),
      'required': serializer.toJson<bool>(required),
      'taskId': serializer.toJson<String>(taskId),
      'taskLabel': serializer.toJson<String>(taskLabel),
      'taskDesc': serializer.toJson<String?>(taskDesc),
      'taskType': serializer.toJson<String>(taskType),
      'taskStatus': serializer.toJson<String>(taskStatus),
      'centerCode': serializer.toJson<String>(centerCode),
      'centerName': serializer.toJson<String>(centerName),
      'metaDataJson': serializer.toJson<String?>(metaDataJson),
      'checklistJson': serializer.toJson<String?>(checklistJson),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  Task copyWith({
    String? id,
    String? clientCode,
    String? examId,
    String? centerId,
    String? shiftId,
    String? service,
    int? seqNumber,
    bool? required,
    String? taskId,
    String? taskLabel,
    Value<String?> taskDesc = const Value.absent(),
    String? taskType,
    String? taskStatus,
    String? centerCode,
    String? centerName,
    Value<String?> metaDataJson = const Value.absent(),
    Value<String?> checklistJson = const Value.absent(),
    DateTime? downloadedAt,
  }) => Task(
    id: id ?? this.id,
    clientCode: clientCode ?? this.clientCode,
    examId: examId ?? this.examId,
    centerId: centerId ?? this.centerId,
    shiftId: shiftId ?? this.shiftId,
    service: service ?? this.service,
    seqNumber: seqNumber ?? this.seqNumber,
    required: required ?? this.required,
    taskId: taskId ?? this.taskId,
    taskLabel: taskLabel ?? this.taskLabel,
    taskDesc: taskDesc.present ? taskDesc.value : this.taskDesc,
    taskType: taskType ?? this.taskType,
    taskStatus: taskStatus ?? this.taskStatus,
    centerCode: centerCode ?? this.centerCode,
    centerName: centerName ?? this.centerName,
    metaDataJson: metaDataJson.present ? metaDataJson.value : this.metaDataJson,
    checklistJson: checklistJson.present
        ? checklistJson.value
        : this.checklistJson,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      clientCode: data.clientCode.present
          ? data.clientCode.value
          : this.clientCode,
      examId: data.examId.present ? data.examId.value : this.examId,
      centerId: data.centerId.present ? data.centerId.value : this.centerId,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      service: data.service.present ? data.service.value : this.service,
      seqNumber: data.seqNumber.present ? data.seqNumber.value : this.seqNumber,
      required: data.required.present ? data.required.value : this.required,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      taskLabel: data.taskLabel.present ? data.taskLabel.value : this.taskLabel,
      taskDesc: data.taskDesc.present ? data.taskDesc.value : this.taskDesc,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      taskStatus: data.taskStatus.present
          ? data.taskStatus.value
          : this.taskStatus,
      centerCode: data.centerCode.present
          ? data.centerCode.value
          : this.centerCode,
      centerName: data.centerName.present
          ? data.centerName.value
          : this.centerName,
      metaDataJson: data.metaDataJson.present
          ? data.metaDataJson.value
          : this.metaDataJson,
      checklistJson: data.checklistJson.present
          ? data.checklistJson.value
          : this.checklistJson,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('clientCode: $clientCode, ')
          ..write('examId: $examId, ')
          ..write('centerId: $centerId, ')
          ..write('shiftId: $shiftId, ')
          ..write('service: $service, ')
          ..write('seqNumber: $seqNumber, ')
          ..write('required: $required, ')
          ..write('taskId: $taskId, ')
          ..write('taskLabel: $taskLabel, ')
          ..write('taskDesc: $taskDesc, ')
          ..write('taskType: $taskType, ')
          ..write('taskStatus: $taskStatus, ')
          ..write('centerCode: $centerCode, ')
          ..write('centerName: $centerName, ')
          ..write('metaDataJson: $metaDataJson, ')
          ..write('checklistJson: $checklistJson, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientCode,
    examId,
    centerId,
    shiftId,
    service,
    seqNumber,
    required,
    taskId,
    taskLabel,
    taskDesc,
    taskType,
    taskStatus,
    centerCode,
    centerName,
    metaDataJson,
    checklistJson,
    downloadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.clientCode == this.clientCode &&
          other.examId == this.examId &&
          other.centerId == this.centerId &&
          other.shiftId == this.shiftId &&
          other.service == this.service &&
          other.seqNumber == this.seqNumber &&
          other.required == this.required &&
          other.taskId == this.taskId &&
          other.taskLabel == this.taskLabel &&
          other.taskDesc == this.taskDesc &&
          other.taskType == this.taskType &&
          other.taskStatus == this.taskStatus &&
          other.centerCode == this.centerCode &&
          other.centerName == this.centerName &&
          other.metaDataJson == this.metaDataJson &&
          other.checklistJson == this.checklistJson &&
          other.downloadedAt == this.downloadedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> clientCode;
  final Value<String> examId;
  final Value<String> centerId;
  final Value<String> shiftId;
  final Value<String> service;
  final Value<int> seqNumber;
  final Value<bool> required;
  final Value<String> taskId;
  final Value<String> taskLabel;
  final Value<String?> taskDesc;
  final Value<String> taskType;
  final Value<String> taskStatus;
  final Value<String> centerCode;
  final Value<String> centerName;
  final Value<String?> metaDataJson;
  final Value<String?> checklistJson;
  final Value<DateTime> downloadedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.clientCode = const Value.absent(),
    this.examId = const Value.absent(),
    this.centerId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.service = const Value.absent(),
    this.seqNumber = const Value.absent(),
    this.required = const Value.absent(),
    this.taskId = const Value.absent(),
    this.taskLabel = const Value.absent(),
    this.taskDesc = const Value.absent(),
    this.taskType = const Value.absent(),
    this.taskStatus = const Value.absent(),
    this.centerCode = const Value.absent(),
    this.centerName = const Value.absent(),
    this.metaDataJson = const Value.absent(),
    this.checklistJson = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String clientCode,
    required String examId,
    required String centerId,
    required String shiftId,
    required String service,
    this.seqNumber = const Value.absent(),
    this.required = const Value.absent(),
    required String taskId,
    required String taskLabel,
    this.taskDesc = const Value.absent(),
    this.taskType = const Value.absent(),
    this.taskStatus = const Value.absent(),
    required String centerCode,
    required String centerName,
    this.metaDataJson = const Value.absent(),
    this.checklistJson = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientCode = Value(clientCode),
       examId = Value(examId),
       centerId = Value(centerId),
       shiftId = Value(shiftId),
       service = Value(service),
       taskId = Value(taskId),
       taskLabel = Value(taskLabel),
       centerCode = Value(centerCode),
       centerName = Value(centerName);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? clientCode,
    Expression<String>? examId,
    Expression<String>? centerId,
    Expression<String>? shiftId,
    Expression<String>? service,
    Expression<int>? seqNumber,
    Expression<bool>? required,
    Expression<String>? taskId,
    Expression<String>? taskLabel,
    Expression<String>? taskDesc,
    Expression<String>? taskType,
    Expression<String>? taskStatus,
    Expression<String>? centerCode,
    Expression<String>? centerName,
    Expression<String>? metaDataJson,
    Expression<String>? checklistJson,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientCode != null) 'client_code': clientCode,
      if (examId != null) 'exam_id': examId,
      if (centerId != null) 'center_id': centerId,
      if (shiftId != null) 'shift_id': shiftId,
      if (service != null) 'service': service,
      if (seqNumber != null) 'seq_number': seqNumber,
      if (required != null) 'required': required,
      if (taskId != null) 'task_id': taskId,
      if (taskLabel != null) 'task_label': taskLabel,
      if (taskDesc != null) 'task_desc': taskDesc,
      if (taskType != null) 'task_type': taskType,
      if (taskStatus != null) 'task_status': taskStatus,
      if (centerCode != null) 'center_code': centerCode,
      if (centerName != null) 'center_name': centerName,
      if (metaDataJson != null) 'meta_data_json': metaDataJson,
      if (checklistJson != null) 'checklist_json': checklistJson,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? clientCode,
    Value<String>? examId,
    Value<String>? centerId,
    Value<String>? shiftId,
    Value<String>? service,
    Value<int>? seqNumber,
    Value<bool>? required,
    Value<String>? taskId,
    Value<String>? taskLabel,
    Value<String?>? taskDesc,
    Value<String>? taskType,
    Value<String>? taskStatus,
    Value<String>? centerCode,
    Value<String>? centerName,
    Value<String?>? metaDataJson,
    Value<String?>? checklistJson,
    Value<DateTime>? downloadedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      clientCode: clientCode ?? this.clientCode,
      examId: examId ?? this.examId,
      centerId: centerId ?? this.centerId,
      shiftId: shiftId ?? this.shiftId,
      service: service ?? this.service,
      seqNumber: seqNumber ?? this.seqNumber,
      required: required ?? this.required,
      taskId: taskId ?? this.taskId,
      taskLabel: taskLabel ?? this.taskLabel,
      taskDesc: taskDesc ?? this.taskDesc,
      taskType: taskType ?? this.taskType,
      taskStatus: taskStatus ?? this.taskStatus,
      centerCode: centerCode ?? this.centerCode,
      centerName: centerName ?? this.centerName,
      metaDataJson: metaDataJson ?? this.metaDataJson,
      checklistJson: checklistJson ?? this.checklistJson,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientCode.present) {
      map['client_code'] = Variable<String>(clientCode.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<String>(examId.value);
    }
    if (centerId.present) {
      map['center_id'] = Variable<String>(centerId.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (seqNumber.present) {
      map['seq_number'] = Variable<int>(seqNumber.value);
    }
    if (required.present) {
      map['required'] = Variable<bool>(required.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (taskLabel.present) {
      map['task_label'] = Variable<String>(taskLabel.value);
    }
    if (taskDesc.present) {
      map['task_desc'] = Variable<String>(taskDesc.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<String>(taskType.value);
    }
    if (taskStatus.present) {
      map['task_status'] = Variable<String>(taskStatus.value);
    }
    if (centerCode.present) {
      map['center_code'] = Variable<String>(centerCode.value);
    }
    if (centerName.present) {
      map['center_name'] = Variable<String>(centerName.value);
    }
    if (metaDataJson.present) {
      map['meta_data_json'] = Variable<String>(metaDataJson.value);
    }
    if (checklistJson.present) {
      map['checklist_json'] = Variable<String>(checklistJson.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('clientCode: $clientCode, ')
          ..write('examId: $examId, ')
          ..write('centerId: $centerId, ')
          ..write('shiftId: $shiftId, ')
          ..write('service: $service, ')
          ..write('seqNumber: $seqNumber, ')
          ..write('required: $required, ')
          ..write('taskId: $taskId, ')
          ..write('taskLabel: $taskLabel, ')
          ..write('taskDesc: $taskDesc, ')
          ..write('taskType: $taskType, ')
          ..write('taskStatus: $taskStatus, ')
          ..write('centerCode: $centerCode, ')
          ..write('centerName: $centerName, ')
          ..write('metaDataJson: $metaDataJson, ')
          ..write('checklistJson: $checklistJson, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskSubmissionsTable extends TaskSubmissions
    with TableInfo<$TaskSubmissionsTable, TaskSubmission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskSubmissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observationsMeta = const VerificationMeta(
    'observations',
  );
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
    'observations',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verificationAnswersMeta =
      const VerificationMeta('verificationAnswers');
  @override
  late final GeneratedColumn<String> verificationAnswers =
      GeneratedColumn<String>(
        'verification_answers',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _imagePathsMeta = const VerificationMeta(
    'imagePaths',
  );
  @override
  late final GeneratedColumn<String> imagePaths = GeneratedColumn<String>(
    'image_paths',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UNSYNCED'),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
    'submitted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    observations,
    verificationAnswers,
    imagePaths,
    status,
    latitude,
    longitude,
    submittedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_submissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskSubmission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('observations')) {
      context.handle(
        _observationsMeta,
        observations.isAcceptableOrUnknown(
          data['observations']!,
          _observationsMeta,
        ),
      );
    }
    if (data.containsKey('verification_answers')) {
      context.handle(
        _verificationAnswersMeta,
        verificationAnswers.isAcceptableOrUnknown(
          data['verification_answers']!,
          _verificationAnswersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verificationAnswersMeta);
    }
    if (data.containsKey('image_paths')) {
      context.handle(
        _imagePathsMeta,
        imagePaths.isAcceptableOrUnknown(data['image_paths']!, _imagePathsMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskSubmission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskSubmission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      observations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observations'],
      ),
      verificationAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verification_answers'],
      )!,
      imagePaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_paths'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $TaskSubmissionsTable createAlias(String alias) {
    return $TaskSubmissionsTable(attachedDatabase, alias);
  }
}

class TaskSubmission extends DataClass implements Insertable<TaskSubmission> {
  final String id;
  final String taskId;
  final String? observations;
  final String verificationAnswers;
  final String imagePaths;
  final String status;
  final double? latitude;
  final double? longitude;
  final DateTime submittedAt;
  final DateTime? syncedAt;
  const TaskSubmission({
    required this.id,
    required this.taskId,
    this.observations,
    required this.verificationAnswers,
    required this.imagePaths,
    required this.status,
    this.latitude,
    this.longitude,
    required this.submittedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    if (!nullToAbsent || observations != null) {
      map['observations'] = Variable<String>(observations);
    }
    map['verification_answers'] = Variable<String>(verificationAnswers);
    map['image_paths'] = Variable<String>(imagePaths);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['submitted_at'] = Variable<DateTime>(submittedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  TaskSubmissionsCompanion toCompanion(bool nullToAbsent) {
    return TaskSubmissionsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      observations: observations == null && nullToAbsent
          ? const Value.absent()
          : Value(observations),
      verificationAnswers: Value(verificationAnswers),
      imagePaths: Value(imagePaths),
      status: Value(status),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      submittedAt: Value(submittedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory TaskSubmission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskSubmission(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      observations: serializer.fromJson<String?>(json['observations']),
      verificationAnswers: serializer.fromJson<String>(
        json['verificationAnswers'],
      ),
      imagePaths: serializer.fromJson<String>(json['imagePaths']),
      status: serializer.fromJson<String>(json['status']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      submittedAt: serializer.fromJson<DateTime>(json['submittedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'observations': serializer.toJson<String?>(observations),
      'verificationAnswers': serializer.toJson<String>(verificationAnswers),
      'imagePaths': serializer.toJson<String>(imagePaths),
      'status': serializer.toJson<String>(status),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'submittedAt': serializer.toJson<DateTime>(submittedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  TaskSubmission copyWith({
    String? id,
    String? taskId,
    Value<String?> observations = const Value.absent(),
    String? verificationAnswers,
    String? imagePaths,
    String? status,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    DateTime? submittedAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => TaskSubmission(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    observations: observations.present ? observations.value : this.observations,
    verificationAnswers: verificationAnswers ?? this.verificationAnswers,
    imagePaths: imagePaths ?? this.imagePaths,
    status: status ?? this.status,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    submittedAt: submittedAt ?? this.submittedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  TaskSubmission copyWithCompanion(TaskSubmissionsCompanion data) {
    return TaskSubmission(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      verificationAnswers: data.verificationAnswers.present
          ? data.verificationAnswers.value
          : this.verificationAnswers,
      imagePaths: data.imagePaths.present
          ? data.imagePaths.value
          : this.imagePaths,
      status: data.status.present ? data.status.value : this.status,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskSubmission(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('observations: $observations, ')
          ..write('verificationAnswers: $verificationAnswers, ')
          ..write('imagePaths: $imagePaths, ')
          ..write('status: $status, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    observations,
    verificationAnswers,
    imagePaths,
    status,
    latitude,
    longitude,
    submittedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskSubmission &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.observations == this.observations &&
          other.verificationAnswers == this.verificationAnswers &&
          other.imagePaths == this.imagePaths &&
          other.status == this.status &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.submittedAt == this.submittedAt &&
          other.syncedAt == this.syncedAt);
}

class TaskSubmissionsCompanion extends UpdateCompanion<TaskSubmission> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String?> observations;
  final Value<String> verificationAnswers;
  final Value<String> imagePaths;
  final Value<String> status;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime> submittedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const TaskSubmissionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.observations = const Value.absent(),
    this.verificationAnswers = const Value.absent(),
    this.imagePaths = const Value.absent(),
    this.status = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskSubmissionsCompanion.insert({
    required String id,
    required String taskId,
    this.observations = const Value.absent(),
    required String verificationAnswers,
    required String imagePaths,
    this.status = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       verificationAnswers = Value(verificationAnswers),
       imagePaths = Value(imagePaths);
  static Insertable<TaskSubmission> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? observations,
    Expression<String>? verificationAnswers,
    Expression<String>? imagePaths,
    Expression<String>? status,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? submittedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (observations != null) 'observations': observations,
      if (verificationAnswers != null)
        'verification_answers': verificationAnswers,
      if (imagePaths != null) 'image_paths': imagePaths,
      if (status != null) 'status': status,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskSubmissionsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String?>? observations,
    Value<String>? verificationAnswers,
    Value<String>? imagePaths,
    Value<String>? status,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<DateTime>? submittedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return TaskSubmissionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      observations: observations ?? this.observations,
      verificationAnswers: verificationAnswers ?? this.verificationAnswers,
      imagePaths: imagePaths ?? this.imagePaths,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      submittedAt: submittedAt ?? this.submittedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (verificationAnswers.present) {
      map['verification_answers'] = Variable<String>(verificationAnswers.value);
    }
    if (imagePaths.present) {
      map['image_paths'] = Variable<String>(imagePaths.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskSubmissionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('observations: $observations, ')
          ..write('verificationAnswers: $verificationAnswers, ')
          ..write('imagePaths: $imagePaths, ')
          ..write('status: $status, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskSubmissionsTable taskSubmissions = $TaskSubmissionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    profiles,
    tasks,
    taskSubmissions,
  ];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      Value<String?> service,
      Value<String?> userJson,
      Value<String?> examJson,
      Value<String?> centerJson,
      Value<String> onboardingStep,
      Value<String?> selectedShiftId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String?> service,
      Value<String?> userJson,
      Value<String?> examJson,
      Value<String?> centerJson,
      Value<String> onboardingStep,
      Value<String?> selectedShiftId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userJson => $composableBuilder(
    column: $table.userJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examJson => $composableBuilder(
    column: $table.examJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get centerJson => $composableBuilder(
    column: $table.centerJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedShiftId => $composableBuilder(
    column: $table.selectedShiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userJson => $composableBuilder(
    column: $table.userJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examJson => $composableBuilder(
    column: $table.examJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get centerJson => $composableBuilder(
    column: $table.centerJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedShiftId => $composableBuilder(
    column: $table.selectedShiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<String> get userJson =>
      $composableBuilder(column: $table.userJson, builder: (column) => column);

  GeneratedColumn<String> get examJson =>
      $composableBuilder(column: $table.examJson, builder: (column) => column);

  GeneratedColumn<String> get centerJson => $composableBuilder(
    column: $table.centerJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedShiftId => $composableBuilder(
    column: $table.selectedShiftId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> service = const Value.absent(),
                Value<String?> userJson = const Value.absent(),
                Value<String?> examJson = const Value.absent(),
                Value<String?> centerJson = const Value.absent(),
                Value<String> onboardingStep = const Value.absent(),
                Value<String?> selectedShiftId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                service: service,
                userJson: userJson,
                examJson: examJson,
                centerJson: centerJson,
                onboardingStep: onboardingStep,
                selectedShiftId: selectedShiftId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> service = const Value.absent(),
                Value<String?> userJson = const Value.absent(),
                Value<String?> examJson = const Value.absent(),
                Value<String?> centerJson = const Value.absent(),
                Value<String> onboardingStep = const Value.absent(),
                Value<String?> selectedShiftId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                service: service,
                userJson: userJson,
                examJson: examJson,
                centerJson: centerJson,
                onboardingStep: onboardingStep,
                selectedShiftId: selectedShiftId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String id,
      required String shiftId,
      required String name,
      required String contact,
      required int age,
      required String aadhaar,
      Value<String?> selfieLocalPath,
      Value<String> livenessStatus,
      Value<double?> livenessScore,
      Value<DateTime?> livenessAttemptedAt,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> location,
      Value<String?> mobileVerificationId,
      Value<String?> backendProfileId,
      Value<bool> trainingCompleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<String> shiftId,
      Value<String> name,
      Value<String> contact,
      Value<int> age,
      Value<String> aadhaar,
      Value<String?> selfieLocalPath,
      Value<String> livenessStatus,
      Value<double?> livenessScore,
      Value<DateTime?> livenessAttemptedAt,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> location,
      Value<String?> mobileVerificationId,
      Value<String?> backendProfileId,
      Value<bool> trainingCompleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aadhaar => $composableBuilder(
    column: $table.aadhaar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selfieLocalPath => $composableBuilder(
    column: $table.selfieLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get livenessStatus => $composableBuilder(
    column: $table.livenessStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get livenessScore => $composableBuilder(
    column: $table.livenessScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get livenessAttemptedAt => $composableBuilder(
    column: $table.livenessAttemptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileVerificationId => $composableBuilder(
    column: $table.mobileVerificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backendProfileId => $composableBuilder(
    column: $table.backendProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trainingCompleted => $composableBuilder(
    column: $table.trainingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aadhaar => $composableBuilder(
    column: $table.aadhaar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selfieLocalPath => $composableBuilder(
    column: $table.selfieLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get livenessStatus => $composableBuilder(
    column: $table.livenessStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get livenessScore => $composableBuilder(
    column: $table.livenessScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get livenessAttemptedAt => $composableBuilder(
    column: $table.livenessAttemptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileVerificationId => $composableBuilder(
    column: $table.mobileVerificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backendProfileId => $composableBuilder(
    column: $table.backendProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trainingCompleted => $composableBuilder(
    column: $table.trainingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get aadhaar =>
      $composableBuilder(column: $table.aadhaar, builder: (column) => column);

  GeneratedColumn<String> get selfieLocalPath => $composableBuilder(
    column: $table.selfieLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get livenessStatus => $composableBuilder(
    column: $table.livenessStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get livenessScore => $composableBuilder(
    column: $table.livenessScore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get livenessAttemptedAt => $composableBuilder(
    column: $table.livenessAttemptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get mobileVerificationId => $composableBuilder(
    column: $table.mobileVerificationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backendProfileId => $composableBuilder(
    column: $table.backendProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get trainingCompleted => $composableBuilder(
    column: $table.trainingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shiftId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> contact = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<String> aadhaar = const Value.absent(),
                Value<String?> selfieLocalPath = const Value.absent(),
                Value<String> livenessStatus = const Value.absent(),
                Value<double?> livenessScore = const Value.absent(),
                Value<DateTime?> livenessAttemptedAt = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> mobileVerificationId = const Value.absent(),
                Value<String?> backendProfileId = const Value.absent(),
                Value<bool> trainingCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                shiftId: shiftId,
                name: name,
                contact: contact,
                age: age,
                aadhaar: aadhaar,
                selfieLocalPath: selfieLocalPath,
                livenessStatus: livenessStatus,
                livenessScore: livenessScore,
                livenessAttemptedAt: livenessAttemptedAt,
                latitude: latitude,
                longitude: longitude,
                location: location,
                mobileVerificationId: mobileVerificationId,
                backendProfileId: backendProfileId,
                trainingCompleted: trainingCompleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shiftId,
                required String name,
                required String contact,
                required int age,
                required String aadhaar,
                Value<String?> selfieLocalPath = const Value.absent(),
                Value<String> livenessStatus = const Value.absent(),
                Value<double?> livenessScore = const Value.absent(),
                Value<DateTime?> livenessAttemptedAt = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> mobileVerificationId = const Value.absent(),
                Value<String?> backendProfileId = const Value.absent(),
                Value<bool> trainingCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                shiftId: shiftId,
                name: name,
                contact: contact,
                age: age,
                aadhaar: aadhaar,
                selfieLocalPath: selfieLocalPath,
                livenessStatus: livenessStatus,
                livenessScore: livenessScore,
                livenessAttemptedAt: livenessAttemptedAt,
                latitude: latitude,
                longitude: longitude,
                location: location,
                mobileVerificationId: mobileVerificationId,
                backendProfileId: backendProfileId,
                trainingCompleted: trainingCompleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String id,
      required String clientCode,
      required String examId,
      required String centerId,
      required String shiftId,
      required String service,
      Value<int> seqNumber,
      Value<bool> required,
      required String taskId,
      required String taskLabel,
      Value<String?> taskDesc,
      Value<String> taskType,
      Value<String> taskStatus,
      required String centerCode,
      required String centerName,
      Value<String?> metaDataJson,
      Value<String?> checklistJson,
      Value<DateTime> downloadedAt,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<String> clientCode,
      Value<String> examId,
      Value<String> centerId,
      Value<String> shiftId,
      Value<String> service,
      Value<int> seqNumber,
      Value<bool> required,
      Value<String> taskId,
      Value<String> taskLabel,
      Value<String?> taskDesc,
      Value<String> taskType,
      Value<String> taskStatus,
      Value<String> centerCode,
      Value<String> centerName,
      Value<String?> metaDataJson,
      Value<String?> checklistJson,
      Value<DateTime> downloadedAt,
      Value<int> rowid,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientCode => $composableBuilder(
    column: $table.clientCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examId => $composableBuilder(
    column: $table.examId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get centerId => $composableBuilder(
    column: $table.centerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seqNumber => $composableBuilder(
    column: $table.seqNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get required => $composableBuilder(
    column: $table.required,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskLabel => $composableBuilder(
    column: $table.taskLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskDesc => $composableBuilder(
    column: $table.taskDesc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskStatus => $composableBuilder(
    column: $table.taskStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get centerCode => $composableBuilder(
    column: $table.centerCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get centerName => $composableBuilder(
    column: $table.centerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metaDataJson => $composableBuilder(
    column: $table.metaDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientCode => $composableBuilder(
    column: $table.clientCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examId => $composableBuilder(
    column: $table.examId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get centerId => $composableBuilder(
    column: $table.centerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seqNumber => $composableBuilder(
    column: $table.seqNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get required => $composableBuilder(
    column: $table.required,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskLabel => $composableBuilder(
    column: $table.taskLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskDesc => $composableBuilder(
    column: $table.taskDesc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskStatus => $composableBuilder(
    column: $table.taskStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get centerCode => $composableBuilder(
    column: $table.centerCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get centerName => $composableBuilder(
    column: $table.centerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metaDataJson => $composableBuilder(
    column: $table.metaDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientCode => $composableBuilder(
    column: $table.clientCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examId =>
      $composableBuilder(column: $table.examId, builder: (column) => column);

  GeneratedColumn<String> get centerId =>
      $composableBuilder(column: $table.centerId, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<int> get seqNumber =>
      $composableBuilder(column: $table.seqNumber, builder: (column) => column);

  GeneratedColumn<bool> get required =>
      $composableBuilder(column: $table.required, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get taskLabel =>
      $composableBuilder(column: $table.taskLabel, builder: (column) => column);

  GeneratedColumn<String> get taskDesc =>
      $composableBuilder(column: $table.taskDesc, builder: (column) => column);

  GeneratedColumn<String> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumn<String> get taskStatus => $composableBuilder(
    column: $table.taskStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get centerCode => $composableBuilder(
    column: $table.centerCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get centerName => $composableBuilder(
    column: $table.centerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metaDataJson => $composableBuilder(
    column: $table.metaDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientCode = const Value.absent(),
                Value<String> examId = const Value.absent(),
                Value<String> centerId = const Value.absent(),
                Value<String> shiftId = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<int> seqNumber = const Value.absent(),
                Value<bool> required = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> taskLabel = const Value.absent(),
                Value<String?> taskDesc = const Value.absent(),
                Value<String> taskType = const Value.absent(),
                Value<String> taskStatus = const Value.absent(),
                Value<String> centerCode = const Value.absent(),
                Value<String> centerName = const Value.absent(),
                Value<String?> metaDataJson = const Value.absent(),
                Value<String?> checklistJson = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                clientCode: clientCode,
                examId: examId,
                centerId: centerId,
                shiftId: shiftId,
                service: service,
                seqNumber: seqNumber,
                required: required,
                taskId: taskId,
                taskLabel: taskLabel,
                taskDesc: taskDesc,
                taskType: taskType,
                taskStatus: taskStatus,
                centerCode: centerCode,
                centerName: centerName,
                metaDataJson: metaDataJson,
                checklistJson: checklistJson,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientCode,
                required String examId,
                required String centerId,
                required String shiftId,
                required String service,
                Value<int> seqNumber = const Value.absent(),
                Value<bool> required = const Value.absent(),
                required String taskId,
                required String taskLabel,
                Value<String?> taskDesc = const Value.absent(),
                Value<String> taskType = const Value.absent(),
                Value<String> taskStatus = const Value.absent(),
                required String centerCode,
                required String centerName,
                Value<String?> metaDataJson = const Value.absent(),
                Value<String?> checklistJson = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                clientCode: clientCode,
                examId: examId,
                centerId: centerId,
                shiftId: shiftId,
                service: service,
                seqNumber: seqNumber,
                required: required,
                taskId: taskId,
                taskLabel: taskLabel,
                taskDesc: taskDesc,
                taskType: taskType,
                taskStatus: taskStatus,
                centerCode: centerCode,
                centerName: centerName,
                metaDataJson: metaDataJson,
                checklistJson: checklistJson,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$TaskSubmissionsTableCreateCompanionBuilder =
    TaskSubmissionsCompanion Function({
      required String id,
      required String taskId,
      Value<String?> observations,
      required String verificationAnswers,
      required String imagePaths,
      Value<String> status,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime> submittedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$TaskSubmissionsTableUpdateCompanionBuilder =
    TaskSubmissionsCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String?> observations,
      Value<String> verificationAnswers,
      Value<String> imagePaths,
      Value<String> status,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime> submittedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$TaskSubmissionsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskSubmissionsTable> {
  $$TaskSubmissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verificationAnswers => $composableBuilder(
    column: $table.verificationAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePaths => $composableBuilder(
    column: $table.imagePaths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskSubmissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskSubmissionsTable> {
  $$TaskSubmissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verificationAnswers => $composableBuilder(
    column: $table.verificationAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePaths => $composableBuilder(
    column: $table.imagePaths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskSubmissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskSubmissionsTable> {
  $$TaskSubmissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get verificationAnswers => $composableBuilder(
    column: $table.verificationAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePaths => $composableBuilder(
    column: $table.imagePaths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$TaskSubmissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskSubmissionsTable,
          TaskSubmission,
          $$TaskSubmissionsTableFilterComposer,
          $$TaskSubmissionsTableOrderingComposer,
          $$TaskSubmissionsTableAnnotationComposer,
          $$TaskSubmissionsTableCreateCompanionBuilder,
          $$TaskSubmissionsTableUpdateCompanionBuilder,
          (
            TaskSubmission,
            BaseReferences<
              _$AppDatabase,
              $TaskSubmissionsTable,
              TaskSubmission
            >,
          ),
          TaskSubmission,
          PrefetchHooks Function()
        > {
  $$TaskSubmissionsTableTableManager(
    _$AppDatabase db,
    $TaskSubmissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskSubmissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskSubmissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskSubmissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String?> observations = const Value.absent(),
                Value<String> verificationAnswers = const Value.absent(),
                Value<String> imagePaths = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime> submittedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskSubmissionsCompanion(
                id: id,
                taskId: taskId,
                observations: observations,
                verificationAnswers: verificationAnswers,
                imagePaths: imagePaths,
                status: status,
                latitude: latitude,
                longitude: longitude,
                submittedAt: submittedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                Value<String?> observations = const Value.absent(),
                required String verificationAnswers,
                required String imagePaths,
                Value<String> status = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime> submittedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskSubmissionsCompanion.insert(
                id: id,
                taskId: taskId,
                observations: observations,
                verificationAnswers: verificationAnswers,
                imagePaths: imagePaths,
                status: status,
                latitude: latitude,
                longitude: longitude,
                submittedAt: submittedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskSubmissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskSubmissionsTable,
      TaskSubmission,
      $$TaskSubmissionsTableFilterComposer,
      $$TaskSubmissionsTableOrderingComposer,
      $$TaskSubmissionsTableAnnotationComposer,
      $$TaskSubmissionsTableCreateCompanionBuilder,
      $$TaskSubmissionsTableUpdateCompanionBuilder,
      (
        TaskSubmission,
        BaseReferences<_$AppDatabase, $TaskSubmissionsTable, TaskSubmission>,
      ),
      TaskSubmission,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskSubmissionsTableTableManager get taskSubmissions =>
      $$TaskSubmissionsTableTableManager(_db, _db.taskSubmissions);
}
