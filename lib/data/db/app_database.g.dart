// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BriefingRunsTable extends BriefingRuns
    with TableInfo<$BriefingRunsTable, BriefingRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BriefingRunsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RankedBy, String> rankedBy =
      GeneratedColumn<String>(
        'ranked_by',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RankedBy>($BriefingRunsTable.$converterrankedBy);
  static const VerificationMeta _promptVersionMeta = const VerificationMeta(
    'promptVersion',
  );
  @override
  late final GeneratedColumn<String> promptVersion = GeneratedColumn<String>(
    'prompt_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    completedAt,
    rankedBy,
    promptVersion,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'briefing_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<BriefingRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('prompt_version')) {
      context.handle(
        _promptVersionMeta,
        promptVersion.isAcceptableOrUnknown(
          data['prompt_version']!,
          _promptVersionMeta,
        ),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BriefingRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BriefingRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      rankedBy: $BriefingRunsTable.$converterrankedBy.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ranked_by'],
        )!,
      ),
      promptVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_version'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $BriefingRunsTable createAlias(String alias) {
    return $BriefingRunsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RankedBy, String, String> $converterrankedBy =
      const EnumNameConverter<RankedBy>(RankedBy.values);
}

class BriefingRun extends DataClass implements Insertable<BriefingRun> {
  final int id;
  final DateTime startedAt;
  final DateTime completedAt;
  final RankedBy rankedBy;
  final String? promptVersion;
  final String? error;
  const BriefingRun({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.rankedBy,
    this.promptVersion,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['completed_at'] = Variable<DateTime>(completedAt);
    {
      map['ranked_by'] = Variable<String>(
        $BriefingRunsTable.$converterrankedBy.toSql(rankedBy),
      );
    }
    if (!nullToAbsent || promptVersion != null) {
      map['prompt_version'] = Variable<String>(promptVersion);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  BriefingRunsCompanion toCompanion(bool nullToAbsent) {
    return BriefingRunsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      completedAt: Value(completedAt),
      rankedBy: Value(rankedBy),
      promptVersion: promptVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(promptVersion),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory BriefingRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BriefingRun(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      rankedBy: $BriefingRunsTable.$converterrankedBy.fromJson(
        serializer.fromJson<String>(json['rankedBy']),
      ),
      promptVersion: serializer.fromJson<String?>(json['promptVersion']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'rankedBy': serializer.toJson<String>(
        $BriefingRunsTable.$converterrankedBy.toJson(rankedBy),
      ),
      'promptVersion': serializer.toJson<String?>(promptVersion),
      'error': serializer.toJson<String?>(error),
    };
  }

  BriefingRun copyWith({
    int? id,
    DateTime? startedAt,
    DateTime? completedAt,
    RankedBy? rankedBy,
    Value<String?> promptVersion = const Value.absent(),
    Value<String?> error = const Value.absent(),
  }) => BriefingRun(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    rankedBy: rankedBy ?? this.rankedBy,
    promptVersion: promptVersion.present
        ? promptVersion.value
        : this.promptVersion,
    error: error.present ? error.value : this.error,
  );
  BriefingRun copyWithCompanion(BriefingRunsCompanion data) {
    return BriefingRun(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      rankedBy: data.rankedBy.present ? data.rankedBy.value : this.rankedBy,
      promptVersion: data.promptVersion.present
          ? data.promptVersion.value
          : this.promptVersion,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BriefingRun(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rankedBy: $rankedBy, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startedAt, completedAt, rankedBy, promptVersion, error);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BriefingRun &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.rankedBy == this.rankedBy &&
          other.promptVersion == this.promptVersion &&
          other.error == this.error);
}

class BriefingRunsCompanion extends UpdateCompanion<BriefingRun> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime> completedAt;
  final Value<RankedBy> rankedBy;
  final Value<String?> promptVersion;
  final Value<String?> error;
  const BriefingRunsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rankedBy = const Value.absent(),
    this.promptVersion = const Value.absent(),
    this.error = const Value.absent(),
  });
  BriefingRunsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    required DateTime completedAt,
    required RankedBy rankedBy,
    this.promptVersion = const Value.absent(),
    this.error = const Value.absent(),
  }) : startedAt = Value(startedAt),
       completedAt = Value(completedAt),
       rankedBy = Value(rankedBy);
  static Insertable<BriefingRun> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? rankedBy,
    Expression<String>? promptVersion,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rankedBy != null) 'ranked_by': rankedBy,
      if (promptVersion != null) 'prompt_version': promptVersion,
      if (error != null) 'error': error,
    });
  }

  BriefingRunsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime>? completedAt,
    Value<RankedBy>? rankedBy,
    Value<String?>? promptVersion,
    Value<String?>? error,
  }) {
    return BriefingRunsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rankedBy: rankedBy ?? this.rankedBy,
      promptVersion: promptVersion ?? this.promptVersion,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rankedBy.present) {
      map['ranked_by'] = Variable<String>(
        $BriefingRunsTable.$converterrankedBy.toSql(rankedBy.value),
      );
    }
    if (promptVersion.present) {
      map['prompt_version'] = Variable<String>(promptVersion.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BriefingRunsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rankedBy: $rankedBy, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

class $SnapshotItemsTable extends SnapshotItems
    with TableInfo<$SnapshotItemsTable, SnapshotItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnapshotItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<int> runId = GeneratedColumn<int>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES briefing_runs (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fallbackRankMeta = const VerificationMeta(
    'fallbackRank',
  );
  @override
  late final GeneratedColumn<int> fallbackRank = GeneratedColumn<int>(
    'fallback_rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _producedRankMeta = const VerificationMeta(
    'producedRank',
  );
  @override
  late final GeneratedColumn<int> producedRank = GeneratedColumn<int>(
    'produced_rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctedRankMeta = const VerificationMeta(
    'correctedRank',
  );
  @override
  late final GeneratedColumn<int> correctedRank = GeneratedColumn<int>(
    'corrected_rank',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runId,
    itemId,
    payloadJson,
    fallbackRank,
    producedRank,
    correctedRank,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snapshot_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SnapshotItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('fallback_rank')) {
      context.handle(
        _fallbackRankMeta,
        fallbackRank.isAcceptableOrUnknown(
          data['fallback_rank']!,
          _fallbackRankMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fallbackRankMeta);
    }
    if (data.containsKey('produced_rank')) {
      context.handle(
        _producedRankMeta,
        producedRank.isAcceptableOrUnknown(
          data['produced_rank']!,
          _producedRankMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_producedRankMeta);
    }
    if (data.containsKey('corrected_rank')) {
      context.handle(
        _correctedRankMeta,
        correctedRank.isAcceptableOrUnknown(
          data['corrected_rank']!,
          _correctedRankMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnapshotItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnapshotItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}run_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      fallbackRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fallback_rank'],
      )!,
      producedRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produced_rank'],
      )!,
      correctedRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corrected_rank'],
      ),
    );
  }

  @override
  $SnapshotItemsTable createAlias(String alias) {
    return $SnapshotItemsTable(attachedDatabase, alias);
  }
}

class SnapshotItem extends DataClass implements Insertable<SnapshotItem> {
  final int id;
  final int runId;
  final String itemId;

  /// The item as the ranker saw it, including its computed features.
  final String payloadJson;
  final int fallbackRank;
  final int producedRank;

  /// Set only once a human has dragged this item to a different position.
  final int? correctedRank;
  const SnapshotItem({
    required this.id,
    required this.runId,
    required this.itemId,
    required this.payloadJson,
    required this.fallbackRank,
    required this.producedRank,
    this.correctedRank,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['run_id'] = Variable<int>(runId);
    map['item_id'] = Variable<String>(itemId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['fallback_rank'] = Variable<int>(fallbackRank);
    map['produced_rank'] = Variable<int>(producedRank);
    if (!nullToAbsent || correctedRank != null) {
      map['corrected_rank'] = Variable<int>(correctedRank);
    }
    return map;
  }

  SnapshotItemsCompanion toCompanion(bool nullToAbsent) {
    return SnapshotItemsCompanion(
      id: Value(id),
      runId: Value(runId),
      itemId: Value(itemId),
      payloadJson: Value(payloadJson),
      fallbackRank: Value(fallbackRank),
      producedRank: Value(producedRank),
      correctedRank: correctedRank == null && nullToAbsent
          ? const Value.absent()
          : Value(correctedRank),
    );
  }

  factory SnapshotItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnapshotItem(
      id: serializer.fromJson<int>(json['id']),
      runId: serializer.fromJson<int>(json['runId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      fallbackRank: serializer.fromJson<int>(json['fallbackRank']),
      producedRank: serializer.fromJson<int>(json['producedRank']),
      correctedRank: serializer.fromJson<int?>(json['correctedRank']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runId': serializer.toJson<int>(runId),
      'itemId': serializer.toJson<String>(itemId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'fallbackRank': serializer.toJson<int>(fallbackRank),
      'producedRank': serializer.toJson<int>(producedRank),
      'correctedRank': serializer.toJson<int?>(correctedRank),
    };
  }

  SnapshotItem copyWith({
    int? id,
    int? runId,
    String? itemId,
    String? payloadJson,
    int? fallbackRank,
    int? producedRank,
    Value<int?> correctedRank = const Value.absent(),
  }) => SnapshotItem(
    id: id ?? this.id,
    runId: runId ?? this.runId,
    itemId: itemId ?? this.itemId,
    payloadJson: payloadJson ?? this.payloadJson,
    fallbackRank: fallbackRank ?? this.fallbackRank,
    producedRank: producedRank ?? this.producedRank,
    correctedRank: correctedRank.present
        ? correctedRank.value
        : this.correctedRank,
  );
  SnapshotItem copyWithCompanion(SnapshotItemsCompanion data) {
    return SnapshotItem(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      fallbackRank: data.fallbackRank.present
          ? data.fallbackRank.value
          : this.fallbackRank,
      producedRank: data.producedRank.present
          ? data.producedRank.value
          : this.producedRank,
      correctedRank: data.correctedRank.present
          ? data.correctedRank.value
          : this.correctedRank,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotItem(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('itemId: $itemId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fallbackRank: $fallbackRank, ')
          ..write('producedRank: $producedRank, ')
          ..write('correctedRank: $correctedRank')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    runId,
    itemId,
    payloadJson,
    fallbackRank,
    producedRank,
    correctedRank,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnapshotItem &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.itemId == this.itemId &&
          other.payloadJson == this.payloadJson &&
          other.fallbackRank == this.fallbackRank &&
          other.producedRank == this.producedRank &&
          other.correctedRank == this.correctedRank);
}

class SnapshotItemsCompanion extends UpdateCompanion<SnapshotItem> {
  final Value<int> id;
  final Value<int> runId;
  final Value<String> itemId;
  final Value<String> payloadJson;
  final Value<int> fallbackRank;
  final Value<int> producedRank;
  final Value<int?> correctedRank;
  const SnapshotItemsCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.fallbackRank = const Value.absent(),
    this.producedRank = const Value.absent(),
    this.correctedRank = const Value.absent(),
  });
  SnapshotItemsCompanion.insert({
    this.id = const Value.absent(),
    required int runId,
    required String itemId,
    required String payloadJson,
    required int fallbackRank,
    required int producedRank,
    this.correctedRank = const Value.absent(),
  }) : runId = Value(runId),
       itemId = Value(itemId),
       payloadJson = Value(payloadJson),
       fallbackRank = Value(fallbackRank),
       producedRank = Value(producedRank);
  static Insertable<SnapshotItem> custom({
    Expression<int>? id,
    Expression<int>? runId,
    Expression<String>? itemId,
    Expression<String>? payloadJson,
    Expression<int>? fallbackRank,
    Expression<int>? producedRank,
    Expression<int>? correctedRank,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (itemId != null) 'item_id': itemId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (fallbackRank != null) 'fallback_rank': fallbackRank,
      if (producedRank != null) 'produced_rank': producedRank,
      if (correctedRank != null) 'corrected_rank': correctedRank,
    });
  }

  SnapshotItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? runId,
    Value<String>? itemId,
    Value<String>? payloadJson,
    Value<int>? fallbackRank,
    Value<int>? producedRank,
    Value<int?>? correctedRank,
  }) {
    return SnapshotItemsCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      itemId: itemId ?? this.itemId,
      payloadJson: payloadJson ?? this.payloadJson,
      fallbackRank: fallbackRank ?? this.fallbackRank,
      producedRank: producedRank ?? this.producedRank,
      correctedRank: correctedRank ?? this.correctedRank,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<int>(runId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (fallbackRank.present) {
      map['fallback_rank'] = Variable<int>(fallbackRank.value);
    }
    if (producedRank.present) {
      map['produced_rank'] = Variable<int>(producedRank.value);
    }
    if (correctedRank.present) {
      map['corrected_rank'] = Variable<int>(correctedRank.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotItemsCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('itemId: $itemId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fallbackRank: $fallbackRank, ')
          ..write('producedRank: $producedRank, ')
          ..write('correctedRank: $correctedRank')
          ..write(')'))
        .toString();
  }
}

class $RunRatingsTable extends RunRatings
    with TableInfo<$RunRatingsTable, RunRating> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunRatingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<int> runId = GeneratedColumn<int>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES briefing_runs (id)',
    ),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notedAtMeta = const VerificationMeta(
    'notedAt',
  );
  @override
  late final GeneratedColumn<DateTime> notedAt = GeneratedColumn<DateTime>(
    'noted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, runId, rating, notedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'run_ratings';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunRating> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('noted_at')) {
      context.handle(
        _notedAtMeta,
        notedAt.isAcceptableOrUnknown(data['noted_at']!, _notedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_notedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunRating map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunRating(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}run_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      notedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}noted_at'],
      )!,
    );
  }

  @override
  $RunRatingsTable createAlias(String alias) {
    return $RunRatingsTable(attachedDatabase, alias);
  }
}

class RunRating extends DataClass implements Insertable<RunRating> {
  final int id;
  final int runId;
  final int rating;
  final DateTime notedAt;
  const RunRating({
    required this.id,
    required this.runId,
    required this.rating,
    required this.notedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['run_id'] = Variable<int>(runId);
    map['rating'] = Variable<int>(rating);
    map['noted_at'] = Variable<DateTime>(notedAt);
    return map;
  }

  RunRatingsCompanion toCompanion(bool nullToAbsent) {
    return RunRatingsCompanion(
      id: Value(id),
      runId: Value(runId),
      rating: Value(rating),
      notedAt: Value(notedAt),
    );
  }

  factory RunRating.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunRating(
      id: serializer.fromJson<int>(json['id']),
      runId: serializer.fromJson<int>(json['runId']),
      rating: serializer.fromJson<int>(json['rating']),
      notedAt: serializer.fromJson<DateTime>(json['notedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runId': serializer.toJson<int>(runId),
      'rating': serializer.toJson<int>(rating),
      'notedAt': serializer.toJson<DateTime>(notedAt),
    };
  }

  RunRating copyWith({int? id, int? runId, int? rating, DateTime? notedAt}) =>
      RunRating(
        id: id ?? this.id,
        runId: runId ?? this.runId,
        rating: rating ?? this.rating,
        notedAt: notedAt ?? this.notedAt,
      );
  RunRating copyWithCompanion(RunRatingsCompanion data) {
    return RunRating(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      rating: data.rating.present ? data.rating.value : this.rating,
      notedAt: data.notedAt.present ? data.notedAt.value : this.notedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunRating(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('rating: $rating, ')
          ..write('notedAt: $notedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, runId, rating, notedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunRating &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.rating == this.rating &&
          other.notedAt == this.notedAt);
}

class RunRatingsCompanion extends UpdateCompanion<RunRating> {
  final Value<int> id;
  final Value<int> runId;
  final Value<int> rating;
  final Value<DateTime> notedAt;
  const RunRatingsCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.rating = const Value.absent(),
    this.notedAt = const Value.absent(),
  });
  RunRatingsCompanion.insert({
    this.id = const Value.absent(),
    required int runId,
    required int rating,
    required DateTime notedAt,
  }) : runId = Value(runId),
       rating = Value(rating),
       notedAt = Value(notedAt);
  static Insertable<RunRating> custom({
    Expression<int>? id,
    Expression<int>? runId,
    Expression<int>? rating,
    Expression<DateTime>? notedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (rating != null) 'rating': rating,
      if (notedAt != null) 'noted_at': notedAt,
    });
  }

  RunRatingsCompanion copyWith({
    Value<int>? id,
    Value<int>? runId,
    Value<int>? rating,
    Value<DateTime>? notedAt,
  }) {
    return RunRatingsCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      rating: rating ?? this.rating,
      notedAt: notedAt ?? this.notedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<int>(runId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (notedAt.present) {
      map['noted_at'] = Variable<DateTime>(notedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunRatingsCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('rating: $rating, ')
          ..write('notedAt: $notedAt')
          ..write(')'))
        .toString();
  }
}

class $PromptsTable extends Prompts with TableInfo<$PromptsTable, Prompt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
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
  List<GeneratedColumn> get $columns => [version, body, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Prompt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
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
  Set<GeneratedColumn> get $primaryKey => {version};
  @override
  Prompt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prompt(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PromptsTable createAlias(String alias) {
    return $PromptsTable(attachedDatabase, alias);
  }
}

class Prompt extends DataClass implements Insertable<Prompt> {
  final int version;
  final String body;
  final DateTime updatedAt;
  const Prompt({
    required this.version,
    required this.body,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version'] = Variable<int>(version);
    map['body'] = Variable<String>(body);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PromptsCompanion toCompanion(bool nullToAbsent) {
    return PromptsCompanion(
      version: Value(version),
      body: Value(body),
      updatedAt: Value(updatedAt),
    );
  }

  factory Prompt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prompt(
      version: serializer.fromJson<int>(json['version']),
      body: serializer.fromJson<String>(json['body']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int>(version),
      'body': serializer.toJson<String>(body),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Prompt copyWith({int? version, String? body, DateTime? updatedAt}) => Prompt(
    version: version ?? this.version,
    body: body ?? this.body,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Prompt copyWithCompanion(PromptsCompanion data) {
    return Prompt(
      version: data.version.present ? data.version.value : this.version,
      body: data.body.present ? data.body.value : this.body,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prompt(')
          ..write('version: $version, ')
          ..write('body: $body, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(version, body, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prompt &&
          other.version == this.version &&
          other.body == this.body &&
          other.updatedAt == this.updatedAt);
}

class PromptsCompanion extends UpdateCompanion<Prompt> {
  final Value<int> version;
  final Value<String> body;
  final Value<DateTime> updatedAt;
  const PromptsCompanion({
    this.version = const Value.absent(),
    this.body = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PromptsCompanion.insert({
    this.version = const Value.absent(),
    required String body,
    required DateTime updatedAt,
  }) : body = Value(body),
       updatedAt = Value(updatedAt);
  static Insertable<Prompt> custom({
    Expression<int>? version,
    Expression<String>? body,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (body != null) 'body': body,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PromptsCompanion copyWith({
    Value<int>? version,
    Value<String>? body,
    Value<DateTime>? updatedAt,
  }) {
    return PromptsCompanion(
      version: version ?? this.version,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptsCompanion(')
          ..write('version: $version, ')
          ..write('body: $body, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BriefingRunsTable briefingRuns = $BriefingRunsTable(this);
  late final $SnapshotItemsTable snapshotItems = $SnapshotItemsTable(this);
  late final $RunRatingsTable runRatings = $RunRatingsTable(this);
  late final $PromptsTable prompts = $PromptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    briefingRuns,
    snapshotItems,
    runRatings,
    prompts,
  ];
}

typedef $$BriefingRunsTableCreateCompanionBuilder =
    BriefingRunsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      required DateTime completedAt,
      required RankedBy rankedBy,
      Value<String?> promptVersion,
      Value<String?> error,
    });
typedef $$BriefingRunsTableUpdateCompanionBuilder =
    BriefingRunsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<DateTime> completedAt,
      Value<RankedBy> rankedBy,
      Value<String?> promptVersion,
      Value<String?> error,
    });

final class $$BriefingRunsTableReferences
    extends BaseReferences<_$AppDatabase, $BriefingRunsTable, BriefingRun> {
  $$BriefingRunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SnapshotItemsTable, List<SnapshotItem>>
  _snapshotItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.snapshotItems,
    aliasName: 'briefing_runs__id__snapshot_items__run_id',
  );

  $$SnapshotItemsTableProcessedTableManager get snapshotItemsRefs {
    final manager = $$SnapshotItemsTableTableManager(
      $_db,
      $_db.snapshotItems,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_snapshotItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RunRatingsTable, List<RunRating>>
  _runRatingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.runRatings,
    aliasName: 'briefing_runs__id__run_ratings__run_id',
  );

  $$RunRatingsTableProcessedTableManager get runRatingsRefs {
    final manager = $$RunRatingsTableTableManager(
      $_db,
      $_db.runRatings,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_runRatingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BriefingRunsTableFilterComposer
    extends Composer<_$AppDatabase, $BriefingRunsTable> {
  $$BriefingRunsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RankedBy, RankedBy, String> get rankedBy =>
      $composableBuilder(
        column: $table.rankedBy,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> snapshotItemsRefs(
    Expression<bool> Function($$SnapshotItemsTableFilterComposer f) f,
  ) {
    final $$SnapshotItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.snapshotItems,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SnapshotItemsTableFilterComposer(
            $db: $db,
            $table: $db.snapshotItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> runRatingsRefs(
    Expression<bool> Function($$RunRatingsTableFilterComposer f) f,
  ) {
    final $$RunRatingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runRatings,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunRatingsTableFilterComposer(
            $db: $db,
            $table: $db.runRatings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BriefingRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $BriefingRunsTable> {
  $$BriefingRunsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rankedBy => $composableBuilder(
    column: $table.rankedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BriefingRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BriefingRunsTable> {
  $$BriefingRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RankedBy, String> get rankedBy =>
      $composableBuilder(column: $table.rankedBy, builder: (column) => column);

  GeneratedColumn<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  Expression<T> snapshotItemsRefs<T extends Object>(
    Expression<T> Function($$SnapshotItemsTableAnnotationComposer a) f,
  ) {
    final $$SnapshotItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.snapshotItems,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SnapshotItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.snapshotItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> runRatingsRefs<T extends Object>(
    Expression<T> Function($$RunRatingsTableAnnotationComposer a) f,
  ) {
    final $$RunRatingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runRatings,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunRatingsTableAnnotationComposer(
            $db: $db,
            $table: $db.runRatings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BriefingRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BriefingRunsTable,
          BriefingRun,
          $$BriefingRunsTableFilterComposer,
          $$BriefingRunsTableOrderingComposer,
          $$BriefingRunsTableAnnotationComposer,
          $$BriefingRunsTableCreateCompanionBuilder,
          $$BriefingRunsTableUpdateCompanionBuilder,
          (BriefingRun, $$BriefingRunsTableReferences),
          BriefingRun,
          PrefetchHooks Function({bool snapshotItemsRefs, bool runRatingsRefs})
        > {
  $$BriefingRunsTableTableManager(_$AppDatabase db, $BriefingRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BriefingRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BriefingRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BriefingRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<RankedBy> rankedBy = const Value.absent(),
                Value<String?> promptVersion = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => BriefingRunsCompanion(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                rankedBy: rankedBy,
                promptVersion: promptVersion,
                error: error,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                required DateTime completedAt,
                required RankedBy rankedBy,
                Value<String?> promptVersion = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => BriefingRunsCompanion.insert(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                rankedBy: rankedBy,
                promptVersion: promptVersion,
                error: error,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BriefingRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({snapshotItemsRefs = false, runRatingsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (snapshotItemsRefs) db.snapshotItems,
                    if (runRatingsRefs) db.runRatings,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (snapshotItemsRefs)
                        await $_getPrefetchedData<
                          BriefingRun,
                          $BriefingRunsTable,
                          SnapshotItem
                        >(
                          currentTable: table,
                          referencedTable: $$BriefingRunsTableReferences
                              ._snapshotItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BriefingRunsTableReferences(
                                db,
                                table,
                                p0,
                              ).snapshotItemsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.runId == item.id),
                          typedResults: items,
                        ),
                      if (runRatingsRefs)
                        await $_getPrefetchedData<
                          BriefingRun,
                          $BriefingRunsTable,
                          RunRating
                        >(
                          currentTable: table,
                          referencedTable: $$BriefingRunsTableReferences
                              ._runRatingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BriefingRunsTableReferences(
                                db,
                                table,
                                p0,
                              ).runRatingsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.runId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BriefingRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BriefingRunsTable,
      BriefingRun,
      $$BriefingRunsTableFilterComposer,
      $$BriefingRunsTableOrderingComposer,
      $$BriefingRunsTableAnnotationComposer,
      $$BriefingRunsTableCreateCompanionBuilder,
      $$BriefingRunsTableUpdateCompanionBuilder,
      (BriefingRun, $$BriefingRunsTableReferences),
      BriefingRun,
      PrefetchHooks Function({bool snapshotItemsRefs, bool runRatingsRefs})
    >;
typedef $$SnapshotItemsTableCreateCompanionBuilder =
    SnapshotItemsCompanion Function({
      Value<int> id,
      required int runId,
      required String itemId,
      required String payloadJson,
      required int fallbackRank,
      required int producedRank,
      Value<int?> correctedRank,
    });
typedef $$SnapshotItemsTableUpdateCompanionBuilder =
    SnapshotItemsCompanion Function({
      Value<int> id,
      Value<int> runId,
      Value<String> itemId,
      Value<String> payloadJson,
      Value<int> fallbackRank,
      Value<int> producedRank,
      Value<int?> correctedRank,
    });

final class $$SnapshotItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SnapshotItemsTable, SnapshotItem> {
  $$SnapshotItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BriefingRunsTable _runIdTable(_$AppDatabase db) =>
      db.briefingRuns.createAlias('snapshot_items__run_id__briefing_runs__id');

  $$BriefingRunsTableProcessedTableManager get runId {
    final $_column = $_itemColumn<int>('run_id')!;

    final manager = $$BriefingRunsTableTableManager(
      $_db,
      $_db.briefingRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SnapshotItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SnapshotItemsTable> {
  $$SnapshotItemsTableFilterComposer({
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

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fallbackRank => $composableBuilder(
    column: $table.fallbackRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get producedRank => $composableBuilder(
    column: $table.producedRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctedRank => $composableBuilder(
    column: $table.correctedRank,
    builder: (column) => ColumnFilters(column),
  );

  $$BriefingRunsTableFilterComposer get runId {
    final $$BriefingRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.briefingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BriefingRunsTableFilterComposer(
            $db: $db,
            $table: $db.briefingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SnapshotItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SnapshotItemsTable> {
  $$SnapshotItemsTableOrderingComposer({
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

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fallbackRank => $composableBuilder(
    column: $table.fallbackRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get producedRank => $composableBuilder(
    column: $table.producedRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctedRank => $composableBuilder(
    column: $table.correctedRank,
    builder: (column) => ColumnOrderings(column),
  );

  $$BriefingRunsTableOrderingComposer get runId {
    final $$BriefingRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.briefingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BriefingRunsTableOrderingComposer(
            $db: $db,
            $table: $db.briefingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SnapshotItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnapshotItemsTable> {
  $$SnapshotItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fallbackRank => $composableBuilder(
    column: $table.fallbackRank,
    builder: (column) => column,
  );

  GeneratedColumn<int> get producedRank => $composableBuilder(
    column: $table.producedRank,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctedRank => $composableBuilder(
    column: $table.correctedRank,
    builder: (column) => column,
  );

  $$BriefingRunsTableAnnotationComposer get runId {
    final $$BriefingRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.briefingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BriefingRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.briefingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SnapshotItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnapshotItemsTable,
          SnapshotItem,
          $$SnapshotItemsTableFilterComposer,
          $$SnapshotItemsTableOrderingComposer,
          $$SnapshotItemsTableAnnotationComposer,
          $$SnapshotItemsTableCreateCompanionBuilder,
          $$SnapshotItemsTableUpdateCompanionBuilder,
          (SnapshotItem, $$SnapshotItemsTableReferences),
          SnapshotItem,
          PrefetchHooks Function({bool runId})
        > {
  $$SnapshotItemsTableTableManager(_$AppDatabase db, $SnapshotItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnapshotItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnapshotItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnapshotItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> fallbackRank = const Value.absent(),
                Value<int> producedRank = const Value.absent(),
                Value<int?> correctedRank = const Value.absent(),
              }) => SnapshotItemsCompanion(
                id: id,
                runId: runId,
                itemId: itemId,
                payloadJson: payloadJson,
                fallbackRank: fallbackRank,
                producedRank: producedRank,
                correctedRank: correctedRank,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int runId,
                required String itemId,
                required String payloadJson,
                required int fallbackRank,
                required int producedRank,
                Value<int?> correctedRank = const Value.absent(),
              }) => SnapshotItemsCompanion.insert(
                id: id,
                runId: runId,
                itemId: itemId,
                payloadJson: payloadJson,
                fallbackRank: fallbackRank,
                producedRank: producedRank,
                correctedRank: correctedRank,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SnapshotItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runId = false}) {
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
                    if (runId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.runId,
                        referencedTable: $$SnapshotItemsTableReferences
                            ._runIdTable(db),
                        referencedColumn: $$SnapshotItemsTableReferences
                            ._runIdTable(db)
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
        ),
      );
}

typedef $$SnapshotItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnapshotItemsTable,
      SnapshotItem,
      $$SnapshotItemsTableFilterComposer,
      $$SnapshotItemsTableOrderingComposer,
      $$SnapshotItemsTableAnnotationComposer,
      $$SnapshotItemsTableCreateCompanionBuilder,
      $$SnapshotItemsTableUpdateCompanionBuilder,
      (SnapshotItem, $$SnapshotItemsTableReferences),
      SnapshotItem,
      PrefetchHooks Function({bool runId})
    >;
typedef $$RunRatingsTableCreateCompanionBuilder = RunRatingsCompanion Function({
  Value<int> id,
  required int runId,
  required int rating,
  required DateTime notedAt,
});
typedef $$RunRatingsTableUpdateCompanionBuilder = RunRatingsCompanion Function({
  Value<int> id,
  Value<int> runId,
  Value<int> rating,
  Value<DateTime> notedAt,
});

final class $$RunRatingsTableReferences
    extends BaseReferences<_$AppDatabase, $RunRatingsTable, RunRating> {
  $$RunRatingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BriefingRunsTable _runIdTable(_$AppDatabase db) =>
      db.briefingRuns.createAlias('run_ratings__run_id__briefing_runs__id');

  $$BriefingRunsTableProcessedTableManager get runId {
    final $_column = $_itemColumn<int>('run_id')!;

    final manager = $$BriefingRunsTableTableManager(
      $_db,
      $_db.briefingRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RunRatingsTableFilterComposer
    extends Composer<_$AppDatabase, $RunRatingsTable> {
  $$RunRatingsTableFilterComposer({
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

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get notedAt => $composableBuilder(
    column: $table.notedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BriefingRunsTableFilterComposer get runId {
    final $$BriefingRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.briefingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BriefingRunsTableFilterComposer(
            $db: $db,
            $table: $db.briefingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunRatingsTableOrderingComposer
    extends Composer<_$AppDatabase, $RunRatingsTable> {
  $$RunRatingsTableOrderingComposer({
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

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get notedAt => $composableBuilder(
    column: $table.notedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BriefingRunsTableOrderingComposer get runId {
    final $$BriefingRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.briefingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BriefingRunsTableOrderingComposer(
            $db: $db,
            $table: $db.briefingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunRatingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunRatingsTable> {
  $$RunRatingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get notedAt =>
      $composableBuilder(column: $table.notedAt, builder: (column) => column);

  $$BriefingRunsTableAnnotationComposer get runId {
    final $$BriefingRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.briefingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BriefingRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.briefingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunRatingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunRatingsTable,
          RunRating,
          $$RunRatingsTableFilterComposer,
          $$RunRatingsTableOrderingComposer,
          $$RunRatingsTableAnnotationComposer,
          $$RunRatingsTableCreateCompanionBuilder,
          $$RunRatingsTableUpdateCompanionBuilder,
          (RunRating, $$RunRatingsTableReferences),
          RunRating,
          PrefetchHooks Function({bool runId})
        > {
  $$RunRatingsTableTableManager(_$AppDatabase db, $RunRatingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunRatingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunRatingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunRatingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<DateTime> notedAt = const Value.absent(),
              }) => RunRatingsCompanion(
                id: id,
                runId: runId,
                rating: rating,
                notedAt: notedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int runId,
                required int rating,
                required DateTime notedAt,
              }) => RunRatingsCompanion.insert(
                id: id,
                runId: runId,
                rating: rating,
                notedAt: notedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RunRatingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runId = false}) {
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
                    if (runId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.runId,
                        referencedTable: $$RunRatingsTableReferences
                            ._runIdTable(db),
                        referencedColumn: $$RunRatingsTableReferences
                            ._runIdTable(db)
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
        ),
      );
}

typedef $$RunRatingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunRatingsTable,
      RunRating,
      $$RunRatingsTableFilterComposer,
      $$RunRatingsTableOrderingComposer,
      $$RunRatingsTableAnnotationComposer,
      $$RunRatingsTableCreateCompanionBuilder,
      $$RunRatingsTableUpdateCompanionBuilder,
      (RunRating, $$RunRatingsTableReferences),
      RunRating,
      PrefetchHooks Function({bool runId})
    >;
typedef $$PromptsTableCreateCompanionBuilder = PromptsCompanion Function({
  Value<int> version,
  required String body,
  required DateTime updatedAt,
});
typedef $$PromptsTableUpdateCompanionBuilder = PromptsCompanion Function({
  Value<int> version,
  Value<String> body,
  Value<DateTime> updatedAt,
});

class $$PromptsTableFilterComposer
    extends Composer<_$AppDatabase, $PromptsTable> {
  $$PromptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PromptsTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptsTable> {
  $$PromptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PromptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptsTable> {
  $$PromptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PromptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PromptsTable,
          Prompt,
          $$PromptsTableFilterComposer,
          $$PromptsTableOrderingComposer,
          $$PromptsTableAnnotationComposer,
          $$PromptsTableCreateCompanionBuilder,
          $$PromptsTableUpdateCompanionBuilder,
          (Prompt, BaseReferences<_$AppDatabase, $PromptsTable, Prompt>),
          Prompt,
          PrefetchHooks Function()
        > {
  $$PromptsTableTableManager(_$AppDatabase db, $PromptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> version = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PromptsCompanion(
                version: version,
                body: body,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> version = const Value.absent(),
                required String body,
                required DateTime updatedAt,
              }) => PromptsCompanion.insert(
                version: version,
                body: body,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PromptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PromptsTable,
      Prompt,
      $$PromptsTableFilterComposer,
      $$PromptsTableOrderingComposer,
      $$PromptsTableAnnotationComposer,
      $$PromptsTableCreateCompanionBuilder,
      $$PromptsTableUpdateCompanionBuilder,
      (Prompt, BaseReferences<_$AppDatabase, $PromptsTable, Prompt>),
      Prompt,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BriefingRunsTableTableManager get briefingRuns =>
      $$BriefingRunsTableTableManager(_db, _db.briefingRuns);
  $$SnapshotItemsTableTableManager get snapshotItems =>
      $$SnapshotItemsTableTableManager(_db, _db.snapshotItems);
  $$RunRatingsTableTableManager get runRatings =>
      $$RunRatingsTableTableManager(_db, _db.runRatings);
  $$PromptsTableTableManager get prompts =>
      $$PromptsTableTableManager(_db, _db.prompts);
}
