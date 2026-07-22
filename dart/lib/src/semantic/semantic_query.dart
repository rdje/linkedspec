part of 'semantic_index.dart';

// FUTURE-PARITY-BACKLOG.10.5.4.1 — immutable typed query values and
// package-private record/source kernel. Public query exposure follows only
// after traversal and raw-neutral validation are complete.

const _semanticModelId = 'linkedspec-semantic-model-v1';
const _semanticQueryId = 'linkedspec-semantic-query-v1';
const _semanticPageDefault = 100;
const _semanticPageMax = 1000;
const _semanticRecordBudgetDefault = 1000;
const _semanticRelationBudgetDefault = 2000;
const _semanticDepthBudgetDefault = 4;
const _semanticRecordBudgetMax = 10000;
const _semanticRelationBudgetMax = 20000;
const _semanticDepthBudgetMax = 8;

/// One native semantic-query-v1 operation.
enum SemanticQueryOperation {
  capabilities('capabilities'),
  list('list'),
  get('get'),
  relations('relations'),
  explain('explain');

  const SemanticQueryOperation(this.wireName);

  final String wireName;
}

/// Traversal direction for a semantic relation query.
enum SemanticQueryDirection {
  outgoing('outgoing'),
  incoming('incoming'),
  both('both');

  const SemanticQueryDirection(this.wireName);

  final String wireName;
}

/// Canonical after-id page request.
final class SemanticQueryPage {
  const SemanticQueryPage({this.afterId, this.limit = _semanticPageDefault});

  final String? afterId;
  final int limit;

  Map<String, Object?> toJson() => {'after_id': afterId, 'limit': limit};

  @override
  bool operator ==(Object other) =>
      other is SemanticQueryPage &&
      other.afterId == afterId &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(afterId, limit);
}

/// Logical query budgets, independent of host resource accounting.
final class SemanticQueryBudget {
  const SemanticQueryBudget({
    this.maxRecords = _semanticRecordBudgetDefault,
    this.maxRelations = _semanticRelationBudgetDefault,
    this.maxDepth = _semanticDepthBudgetDefault,
  });

  final int maxRecords;
  final int maxRelations;
  final int maxDepth;

  Map<String, Object?> toJson() => {
    'max_records': maxRecords,
    'max_relations': maxRelations,
    'max_depth': maxDepth,
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticQueryBudget &&
      other.maxRecords == maxRecords &&
      other.maxRelations == maxRelations &&
      other.maxDepth == maxDepth;

  @override
  int get hashCode => Object.hash(maxRecords, maxRelations, maxDepth);
}

/// Query-selected source projection beneath the construction ceiling.
final class SemanticQuerySource {
  const SemanticQuerySource({
    this.detail = SemanticSourceDetail.none,
    this.includeContentDigest = false,
  });

  final SemanticSourceDetail detail;
  final bool includeContentDigest;

  Map<String, Object?> toJson() => {
    'detail': detail.wireName,
    'include_content_digest': includeContentDigest,
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticQuerySource &&
      other.detail == detail &&
      other.includeContentDigest == includeContentDigest;

  @override
  int get hashCode => Object.hash(detail, includeContentDigest);
}

/// Strongly typed native projection of one semantic-query-v1 request.
final class SemanticQuery {
  SemanticQuery({
    this.contract = _semanticQueryId,
    required this.operation,
    List<String> subjects = const [],
    List<String> recordKinds = const [],
    List<String> relationKinds = const [],
    this.direction = SemanticQueryDirection.outgoing,
    this.page = const SemanticQueryPage(),
    this.budget = const SemanticQueryBudget(),
    this.source = const SemanticQuerySource(),
  }) : subjects = List.unmodifiable(subjects),
       recordKinds = List.unmodifiable(recordKinds),
       relationKinds = List.unmodifiable(relationKinds);

  final String contract;
  final SemanticQueryOperation operation;
  final List<String> subjects;
  final List<String> recordKinds;
  final List<String> relationKinds;
  final SemanticQueryDirection direction;
  final SemanticQueryPage page;
  final SemanticQueryBudget budget;
  final SemanticQuerySource source;

  Map<String, Object?> toJson() => {
    'contract': contract,
    'operation': operation.wireName,
    'subjects': [...subjects],
    'record_kinds': [...recordKinds],
    'relation_kinds': [...relationKinds],
    'direction': direction.wireName,
    'page': page.toJson(),
    'budget': budget.toJson(),
    'source': source.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticQuery &&
      other.contract == contract &&
      other.operation == operation &&
      _listsEqual(other.subjects, subjects) &&
      _listsEqual(other.recordKinds, recordKinds) &&
      _listsEqual(other.relationKinds, relationKinds) &&
      other.direction == direction &&
      other.page == page &&
      other.budget == budget &&
      other.source == source;

  @override
  int get hashCode => Object.hash(
    contract,
    operation,
    Object.hashAll(subjects),
    Object.hashAll(recordKinds),
    Object.hashAll(relationKinds),
    direction,
    page,
    budget,
    source,
  );
}

/// Source reference after query-time privacy projection.
final class SemanticQuerySourceReference {
  SemanticQuerySourceReference({
    required this.sourceId,
    required this.logicalName,
    required this.span,
    required this.excerpt,
    required this.contentDigest,
    List<String> provenanceIds = const [],
  }) : provenanceIds = List.unmodifiable(provenanceIds);

  final String sourceId;
  final String logicalName;
  final SemanticSourceSpan? span;
  final String? excerpt;
  final String? contentDigest;
  final List<String> provenanceIds;

  Map<String, Object?> toJson() => {
    'source_id': sourceId,
    'logical_name': logicalName,
    'span': span?.toJson(),
    'excerpt': excerpt,
    'content_digest': contentDigest,
    'provenance_ids': [...provenanceIds],
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticQuerySourceReference &&
      other.sourceId == sourceId &&
      other.logicalName == logicalName &&
      other.span == span &&
      other.excerpt == excerpt &&
      other.contentDigest == contentDigest &&
      _listsEqual(other.provenanceIds, provenanceIds);

  @override
  int get hashCode => Object.hash(
    sourceId,
    logicalName,
    span,
    excerpt,
    contentDigest,
    Object.hashAll(provenanceIds),
  );
}

/// One public clone-safe semantic model record.
final class SemanticQueryRecord {
  SemanticQueryRecord({
    required this.id,
    required this.kind,
    required this.name,
    required this.ownerId,
    required this.order,
    required this.source,
    required Map<String, Object?> facts,
    List<String> redactions = const [],
  }) : facts = _immutableFields(facts),
       redactions = List.unmodifiable(redactions);

  final String id;
  final String kind;
  final String? name;
  final String? ownerId;
  final int order;
  final SemanticQuerySourceReference? source;
  final Map<String, Object?> facts;
  final List<String> redactions;

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind,
    'name': name,
    'owner_id': ownerId,
    'order': order,
    'source': source?.toJson(),
    'facts': _detachedFields(facts),
    'redactions': [...redactions],
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticQueryRecord &&
      _plainValuesEqual(other.toJson(), toJson());

  @override
  int get hashCode => _plainValueHash(toJson());
}

/// One public clone-safe semantic model relation.
final class SemanticQueryRelation {
  SemanticQueryRelation({
    required this.id,
    required this.kind,
    required this.fromId,
    required this.toId,
    required this.order,
    required this.source,
    required Map<String, Object?> facts,
    List<String> evidenceIds = const [],
  }) : facts = _immutableFields(facts),
       evidenceIds = List.unmodifiable(evidenceIds);

  final String id;
  final String kind;
  final String fromId;
  final String toId;
  final int order;
  final SemanticQuerySourceReference? source;
  final Map<String, Object?> facts;
  final List<String> evidenceIds;

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind,
    'from_id': fromId,
    'to_id': toId,
    'order': order,
    'source': source?.toJson(),
    'facts': _detachedFields(facts),
    'evidence_ids': [...evidenceIds],
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticQueryRelation &&
      _plainValuesEqual(other.toJson(), toJson());

  @override
  int get hashCode => _plainValueHash(toJson());
}

/// Portable query diagnostic, distinct from compilation/runtime records.
final class SemanticQueryDiagnostic {
  SemanticQueryDiagnostic({
    required this.code,
    required this.severity,
    required this.message,
    required Map<String, Object?> fields,
  }) : fields = _immutableFields(fields);

  final String code;
  final String severity;
  final String message;
  final Map<String, Object?> fields;

  Map<String, Object?> toJson() => {
    'code': code,
    'severity': severity,
    'message': message,
    'fields': _detachedFields(fields),
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticQueryDiagnostic &&
      _plainValuesEqual(other.toJson(), toJson());

  @override
  int get hashCode => _plainValueHash(toJson());
}

/// Canonical response paging state.
final class SemanticQueryPageState {
  const SemanticQueryPageState({
    required this.afterId,
    required this.nextAfterId,
    required this.complete,
  });

  final String? afterId;
  final String? nextAfterId;
  final bool complete;

  Map<String, Object?> toJson() => {
    'after_id': afterId,
    'next_after_id': nextAfterId,
    'complete': complete,
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticQueryPageState &&
      other.afterId == afterId &&
      other.nextAfterId == nextAfterId &&
      other.complete == complete;

  @override
  int get hashCode => Object.hash(afterId, nextAfterId, complete);
}

/// Logical traversal cost reported by one query.
final class SemanticQueryCost {
  const SemanticQueryCost({
    required this.recordsExamined,
    required this.relationsExamined,
    required this.depthReached,
  });

  final int recordsExamined;
  final int relationsExamined;
  final int depthReached;

  Map<String, Object?> toJson() => {
    'records_examined': recordsExamined,
    'relations_examined': relationsExamined,
    'depth_reached': depthReached,
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticQueryCost &&
      other.recordsExamined == recordsExamined &&
      other.relationsExamined == relationsExamined &&
      other.depthReached == depthReached;

  @override
  int get hashCode =>
      Object.hash(recordsExamined, relationsExamined, depthReached);
}

/// Exact native and neutral semantic-query-v1 response envelope.
final class SemanticQueryResponse {
  SemanticQueryResponse({
    required this.contract,
    required this.model,
    required this.ok,
    required this.snapshot,
    List<SemanticQueryRecord> records = const [],
    List<SemanticQueryRelation> relations = const [],
    required this.page,
    required this.cost,
    List<SemanticQueryDiagnostic> diagnostics = const [],
  }) : records = List.unmodifiable(records),
       relations = List.unmodifiable(relations),
       diagnostics = List.unmodifiable(diagnostics);

  final String contract;
  final String model;
  final bool ok;
  final SemanticSnapshot snapshot;
  final List<SemanticQueryRecord> records;
  final List<SemanticQueryRelation> relations;
  final SemanticQueryPageState page;
  final SemanticQueryCost cost;
  final List<SemanticQueryDiagnostic> diagnostics;

  Map<String, Object?> toJson() => {
    'contract': contract,
    'model': model,
    'ok': ok,
    'snapshot': snapshot.toJson(),
    'records': [for (final record in records) record.toJson()],
    'relations': [for (final relation in relations) relation.toJson()],
    'page': page.toJson(),
    'cost': cost.toJson(),
    'diagnostics': [for (final diagnostic in diagnostics) diagnostic.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticQueryResponse &&
      _plainValuesEqual(other.toJson(), toJson());

  @override
  int get hashCode => _plainValueHash(toJson());
}

/// Package-internal proof seam while the query evaluator is incomplete.
///
/// The public `linkedspec_dart.dart` umbrella deliberately omits this extension
/// and every query type until `.10.5.4.3` completes raw-neutral validation.
extension SemanticIndexQueryKernelTestAccess on SemanticIndex {
  SemanticQueryResponse semanticCapabilitiesForTesting() =>
      _evaluateSemanticQueryKernel(
        _staticProjection.detachedJson(),
        SemanticQuery(operation: SemanticQueryOperation.capabilities),
      );

  SemanticQueryResponse semanticQueryKernelForTesting(SemanticQuery request) =>
      _evaluateSemanticQueryKernel(_staticProjection.detachedJson(), request);
}

SemanticQueryResponse _evaluateSemanticQueryKernel(
  Map<String, Object?> projection,
  SemanticQuery request,
) {
  final snapshot = _semanticQuerySnapshot(projection);
  final ceilingError = _semanticSourceCeilingError(snapshot, request);
  if (ceilingError != null) {
    return ceilingError;
  }
  _requireSemanticKernelDefaults(request);

  final records = (projection['records']! as List<Object?>)
      .cast<Map<String, Object?>>();
  final recordById = <String, Map<String, Object?>>{
    for (final record in records) record['id']! as String: record,
  };
  if (request.operation == SemanticQueryOperation.get &&
      request.subjects.any((subject) => !recordById.containsKey(subject))) {
    return _semanticEmptyQueryResponse(
      snapshot,
      request,
      _semanticQueryDiagnostic(
        'semantic_query_invalid',
        reason: 'unknown_subject',
      ),
    );
  }

  final selectedRecords = <SemanticQueryRecord>[];
  final selectedRelations = <SemanticQueryRelation>[];
  switch (request.operation) {
    case SemanticQueryOperation.capabilities:
      selectedRecords.add(_semanticCapabilitiesRecord(snapshot));
    case SemanticQueryOperation.list:
      final wanted = request.recordKinds.toSet();
      selectedRecords.addAll(
        records
            .where(
              (record) =>
                  wanted.isEmpty || wanted.contains(record['kind']! as String),
            )
            .map(
              (record) => _projectSemanticQueryRecord(
                record,
                projection,
                request.source,
              ),
            ),
      );
    case SemanticQueryOperation.get:
      final wanted = request.subjects.toSet();
      selectedRecords.addAll(
        records
            .where((record) => wanted.contains(record['id']! as String))
            .map(
              (record) => _projectSemanticQueryRecord(
                record,
                projection,
                request.source,
              ),
            ),
      );
    case SemanticQueryOperation.explain:
      final subject = request.subjects.single;
      Map<String, Object?>? decision;
      final direct = recordById[subject];
      if (direct != null && direct['kind'] == 'decision') {
        decision = direct;
      } else {
        final owned = records
            .where(
              (record) =>
                  record['kind'] == 'decision' && record['owner_id'] == subject,
            )
            .toList();
        if (owned.length == 1) {
          decision = owned.single;
        }
      }
      if (decision == null) {
        return _semanticEmptyQueryResponse(
          snapshot,
          request,
          _semanticQueryDiagnostic(
            'semantic_query_invalid',
            reason: 'not_explainable',
          ),
        );
      }
      final steps = records
          .where(
            (record) =>
                record['kind'] == 'explanation_step' &&
                record['owner_id'] == decision!['id'],
          )
          .toList();
      selectedRecords.add(
        _projectSemanticQueryRecord(decision, projection, request.source),
      );
      selectedRecords.addAll(
        steps.map(
          (record) =>
              _projectSemanticQueryRecord(record, projection, request.source),
        ),
      );
      final stepIds = steps.map((record) => record['id']).toSet();
      final relations = (projection['relations']! as List<Object?>)
          .cast<Map<String, Object?>>();
      selectedRelations.addAll(
        relations
            .where(
              (relation) =>
                  relation['kind'] == 'explained_by' &&
                  relation['from_id'] == decision!['id'] &&
                  stepIds.contains(relation['to_id']),
            )
            .map(
              (relation) => _projectSemanticQueryRelation(
                relation,
                projection,
                request.source,
              ),
            ),
      );
    case SemanticQueryOperation.relations:
      throw StateError(
        'Semantic relation traversal is owned by '
        'FUTURE-PARITY-BACKLOG.10.5.4.2',
      );
  }

  final explain = request.operation == SemanticQueryOperation.explain;
  return SemanticQueryResponse(
    contract: _semanticQueryId,
    model: _semanticModelId,
    ok: true,
    snapshot: snapshot,
    records: selectedRecords,
    relations: selectedRelations,
    page: SemanticQueryPageState(
      afterId: request.page.afterId,
      nextAfterId: null,
      complete: true,
    ),
    cost: SemanticQueryCost(
      recordsExamined: selectedRecords.length,
      relationsExamined: selectedRelations.length,
      depthReached: explain && selectedRecords.length > 1 ? 1 : 0,
    ),
  );
}

void _requireSemanticKernelDefaults(SemanticQuery request) {
  if (request.page != const SemanticQueryPage() ||
      request.budget != const SemanticQueryBudget()) {
    throw StateError(
      'Semantic pagination and budgets are owned by '
      'FUTURE-PARITY-BACKLOG.10.5.4.2',
    );
  }
}

SemanticSnapshot _semanticQuerySnapshot(Map<String, Object?> projection) {
  final value = projection['snapshot']! as Map<String, Object?>;
  return SemanticSnapshot(
    id: value['id']! as String,
    state: switch (value['state']) {
      'compiled' => SemanticSnapshotState.compiled,
      'failed_compilation' => SemanticSnapshotState.failedCompilation,
      final state => throw StateError(
        'Unknown semantic snapshot state: $state',
      ),
    },
    hasExecution: value['has_execution']! as bool,
    sourceDetailCeiling: _semanticSourceDetail(value['source_detail_ceiling']),
    contentDigestAvailable: value['content_digest_available']! as bool,
  );
}

SemanticQueryResponse? _semanticSourceCeilingError(
  SemanticSnapshot snapshot,
  SemanticQuery request,
) {
  final source = request.source;
  if (source.detail.index <= snapshot.sourceDetailCeiling.index &&
      (!source.includeContentDigest || snapshot.contentDigestAvailable)) {
    return null;
  }
  return _semanticEmptyQueryResponse(
    snapshot,
    request,
    _semanticQueryDiagnostic(
      'semantic_query_source_detail_forbidden',
      reason: snapshot.sourceDetailCeiling.wireName,
      requested: source.detail.wireName,
    ),
  );
}

SemanticQueryRecord _semanticCapabilitiesRecord(SemanticSnapshot snapshot) =>
    SemanticQueryRecord(
      id: 'capabilities:0',
      kind: 'capabilities',
      name: 'semantic introspection v1',
      ownerId: null,
      order: 0,
      source: null,
      facts: {
        'model_ids': [_semanticModelId],
        'query_ids': [_semanticQueryId],
        'record_kinds': [..._semanticRecordKinds],
        'relation_kinds': [..._semanticRelationKinds],
        'source_detail_ceiling': snapshot.sourceDetailCeiling.wireName,
        'page_default': _semanticPageDefault,
        'page_max': _semanticPageMax,
        'budget_defaults': {
          'max_records': _semanticRecordBudgetDefault,
          'max_relations': _semanticRelationBudgetDefault,
          'max_depth': _semanticDepthBudgetDefault,
        },
        'budget_maxima': {
          'max_records': _semanticRecordBudgetMax,
          'max_relations': _semanticRelationBudgetMax,
          'max_depth': _semanticDepthBudgetMax,
        },
        'execution_observation': snapshot.hasExecution,
        'features': <Object?>[],
      },
    );

SemanticQueryRecord _projectSemanticQueryRecord(
  Map<String, Object?> record,
  Map<String, Object?> projection,
  SemanticQuerySource policy,
) {
  final facts = _detachedFields(record['facts']! as Map<String, Object?>);
  final sensitive = switch (record['kind']) {
    'regex_slot' => ('pattern', '/facts/pattern'),
    'diagnostic' => ('message', '/facts/message'),
    'explanation_step' => ('summary', '/facts/summary'),
    _ => null,
  };
  var redactions = (record['redactions']! as List<Object?>).cast<String>();
  if (policy.detail != SemanticSourceDetail.text && sensitive != null) {
    facts[sensitive.$1] = null;
    redactions = [sensitive.$2];
  }
  return SemanticQueryRecord(
    id: record['id']! as String,
    kind: record['kind']! as String,
    name: record['name'] as String?,
    ownerId: record['owner_id'] as String?,
    order: record['order']! as int,
    source: _projectSemanticQuerySource(
      record['source'] as String?,
      projection,
      policy,
    ),
    facts: facts,
    redactions: redactions,
  );
}

SemanticQueryRelation _projectSemanticQueryRelation(
  Map<String, Object?> relation,
  Map<String, Object?> projection,
  SemanticQuerySource policy,
) => SemanticQueryRelation(
  id: relation['id']! as String,
  kind: relation['kind']! as String,
  fromId: relation['from_id']! as String,
  toId: relation['to_id']! as String,
  order: relation['order']! as int,
  source: _projectSemanticQuerySource(
    relation['source'] as String?,
    projection,
    policy,
  ),
  facts: relation['facts']! as Map<String, Object?>,
  evidenceIds: (relation['evidence_ids']! as List<Object?>).cast<String>(),
);

SemanticQuerySourceReference? _projectSemanticQuerySource(
  String? sourceKey,
  Map<String, Object?> projection,
  SemanticQuerySource policy,
) {
  if (sourceKey == null || policy.detail == SemanticSourceDetail.none) {
    return null;
  }
  final sourceRefs = projection['source_refs']! as Map<String, Object?>;
  final source = sourceRefs[sourceKey]! as Map<String, Object?>;
  return SemanticQuerySourceReference(
    sourceId: source['source_id']! as String,
    logicalName: source['logical_name']! as String,
    span: policy.detail.index >= SemanticSourceDetail.span.index
        ? _semanticQuerySpan(source['span']! as Map<String, Object?>)
        : null,
    excerpt: policy.detail == SemanticSourceDetail.text
        ? source['excerpt']! as String
        : null,
    contentDigest:
        policy.detail == SemanticSourceDetail.text &&
            policy.includeContentDigest
        ? source['content_digest']! as String
        : null,
    provenanceIds: (source['provenance_ids']! as List<Object?>).cast<String>(),
  );
}

SemanticSourceSpan _semanticQuerySpan(Map<String, Object?> value) =>
    SemanticSourceSpan(
      startByte: value['start_byte']! as int,
      endByte: value['end_byte']! as int,
      startLine: value['start_line']! as int,
      startColumn: value['start_column']! as int,
      endLine: value['end_line']! as int,
      endColumn: value['end_column']! as int,
    );

SemanticQueryDiagnostic _semanticQueryDiagnostic(
  String code, {
  String? reason,
  Object? requested,
}) => switch (code) {
  'semantic_query_source_detail_forbidden' => SemanticQueryDiagnostic(
    code: code,
    severity: 'error',
    message: 'Requested source detail exceeds the index ceiling.',
    fields: {'requested': requested, 'ceiling': reason},
  ),
  _ => SemanticQueryDiagnostic(
    code: 'semantic_query_invalid',
    severity: 'error',
    message: 'Invalid semantic query request.',
    fields: {'reason': reason},
  ),
};

SemanticQueryResponse _semanticEmptyQueryResponse(
  SemanticSnapshot snapshot,
  SemanticQuery request,
  SemanticQueryDiagnostic diagnostic,
) => SemanticQueryResponse(
  contract: _semanticQueryId,
  model: _semanticModelId,
  ok: false,
  snapshot: snapshot,
  page: SemanticQueryPageState(
    afterId: request.page.afterId,
    nextAfterId: null,
    complete: true,
  ),
  cost: const SemanticQueryCost(
    recordsExamined: 0,
    relationsExamined: 0,
    depthReached: 0,
  ),
  diagnostics: [diagnostic],
);

SemanticSourceDetail _semanticSourceDetail(Object? value) => switch (value) {
  'none' => SemanticSourceDetail.none,
  'identity' => SemanticSourceDetail.identity,
  'span' => SemanticSourceDetail.span,
  'text' => SemanticSourceDetail.text,
  _ => throw StateError('Unknown semantic source detail: $value'),
};
