part of 'semantic_index.dart';

// FUTURE-PARITY-BACKLOG.10.5.5.2 — immutable observed runtime projection.

const _semanticExecutionId = 'execution:0';

_SemanticStaticProjection _buildSemanticRuntimeProjection(
  _SemanticStaticProjection staticProjection,
  List<RuntimeSemanticObservationEvent> observation,
) {
  if (observation.isEmpty) {
    throw _invalidSemanticObservation(
      'Execution observation must contain at least one event',
    );
  }
  if (staticProjection.snapshot.state != SemanticSnapshotState.compiled ||
      staticProjection.snapshot.hasExecution) {
    throw _invalidSemanticObservation(
      'Execution observations require a compiled static semantic snapshot',
    );
  }
  for (final event in observation) {
    _validateSemanticObservationEvent(event);
  }

  final resultEvents = observation
      .where(
        (event) =>
            event.eventKind == RuntimeSemanticObservationEventKind.ruleResult,
      )
      .toList();
  if (resultEvents.length != 1 ||
      observation.last.eventKind !=
          RuntimeSemanticObservationEventKind.ruleResult) {
    throw _invalidSemanticObservation(
      'Completed execution observation must contain exactly one final rule result',
    );
  }
  final resultEvent = resultEvents.single;
  if (resultEvent.status != 'succeeded') {
    throw _invalidSemanticObservation(
      'Final rule-result observation must report succeeded status',
    );
  }
  final inputIdentity = resultEvent.inputIdentity;
  if (inputIdentity == null || !_isSemanticInputIdentity(inputIdentity)) {
    throw _invalidSemanticObservation(
      'Final rule-result observation must carry a stable input identity',
    );
  }

  final recordById = <String, Map<String, Object?>>{
    for (final record in staticProjection.records)
      record['id']! as String: record,
  };
  final ruleByName = <String, Map<String, Object?>>{
    for (final record in staticProjection.records)
      if (record['kind'] == 'rule' && record['name'] is String)
        record['name']! as String: record,
  };
  final slotByKey = <(String, int), Map<String, Object?>>{};
  for (final record in staticProjection.records) {
    if (record['kind'] != 'regex_slot') {
      continue;
    }
    final ownerId = record['owner_id'];
    final owner = ownerId is String ? recordById[ownerId] : null;
    final ownerName = owner?['name'];
    final order = record['order'];
    if (ownerName is String && order is int) {
      slotByKey[(ownerName, order)] = record;
    }
  }
  final edgeForSelection = <(String, String), Map<String, Object?>>{};
  for (final selection in staticProjection.relations) {
    if (selection['kind'] != 'selects_regex') {
      continue;
    }
    final fromId = selection['from_id']! as String;
    final edge = recordById[fromId];
    if (edge == null || edge['kind'] != 'edge') {
      continue;
    }
    final ownerId = edge['owner_id'];
    final toId = selection['to_id'];
    if (ownerId is String && toId is String) {
      edgeForSelection.putIfAbsent((ownerId, toId), () => edge);
    }
  }

  final resultRule = ruleByName[resultEvent.ruleLabel];
  if (resultRule == null) {
    throw _invalidSemanticObservation(
      "Observed result rule '${resultEvent.ruleLabel}' does not exist in the semantic index",
    );
  }
  final spec = recordById[_semanticSpecId];
  if (spec == null) {
    throw _invalidSemanticObservation(
      'Static semantic projection has no spec record',
    );
  }
  final specFacts = spec['facts']! as Map<String, Object?>;
  if (specFacts['entry_rule_id'] != resultRule['id']) {
    throw _invalidSemanticObservation(
      'Observed final result does not belong to the selected entry rule',
    );
  }
  final resultShape = _requiredSemanticObservationShape(
    resultRule,
    'Final result rule has no value shape',
  );

  final records = [
    for (final record in staticProjection.records) _detachedFields(record),
  ];
  final relations = [
    for (final relation in staticProjection.relations)
      _detachedFields(relation),
  ];
  records.add(
    _semanticRecord(
      id: _semanticExecutionId,
      kind: 'execution',
      name: 'caller observation',
      ownerId: _semanticSpecId,
      order: 0,
      source: null,
      facts: {
        'input_identity': inputIdentity,
        'status': 'succeeded',
        'result_shape': _detachedFields(resultShape),
      },
    ),
  );

  for (final (order, event) in observation.indexed) {
    final String name;
    final String? source;
    final Map<String, Object?> valueShape;
    final String evidenceId;
    switch (event.eventKind) {
      case RuntimeSemanticObservationEventKind.regexSlotSelected:
        final rule = ruleByName[event.ruleLabel];
        if (rule == null) {
          throw _invalidSemanticObservation(
            "Observed selecting rule '${event.ruleLabel}' does not exist in the semantic index",
          );
        }
        final targetRule = event.targetRule!;
        final regexIndex = event.regexIndex!;
        final slot = slotByKey[(targetRule, regexIndex)];
        if (slot == null) {
          throw _invalidSemanticObservation(
            "Observed regex slot '$targetRule[$regexIndex]' does not exist in the semantic index",
          );
        }
        final edge =
            edgeForSelection[(rule['id']! as String, slot['id']! as String)];
        if (edge == null) {
          throw _invalidSemanticObservation(
            "Observed selecting rule '${event.ruleLabel}' does not select regex slot '$targetRule[$regexIndex]'",
          );
        }
        name = 'slot selected';
        source = slot['source'] as String?;
        valueShape = _requiredSemanticObservationShape(
          edge,
          'Observed selection edge has no value shape',
        );
        evidenceId = slot['id']! as String;
      case RuntimeSemanticObservationEventKind.ruleResult:
        if (order + 1 != observation.length) {
          throw _invalidSemanticObservation(
            'Rule-result event must be the final observation event',
          );
        }
        name = 'rule result';
        source = resultRule['source'] as String?;
        valueShape = resultShape;
        evidenceId = resultRule['id']! as String;
    }
    final eventId = 'event:$_semanticExecutionId:$order';
    records.add(
      _semanticRecord(
        id: eventId,
        kind: 'event',
        name: name,
        ownerId: _semanticExecutionId,
        order: order,
        source: source,
        facts: {
          'event_kind': event.eventKind.wireName,
          'position': event.position,
          'value_shape': _detachedFields(valueShape),
        },
      ),
    );
    relations.add(
      _semanticRelation(
        kind: 'observed_as',
        fromId: _semanticExecutionId,
        toId: eventId,
        order: order,
        source: source,
        evidenceIds: [evidenceId],
      ),
    );
  }

  _canonicalizeSemanticProjection(records, relations);
  return _SemanticStaticProjection(
    snapshot: SemanticSnapshot(
      id: staticProjection.snapshot.id,
      state: staticProjection.snapshot.state,
      hasExecution: true,
      sourceDetailCeiling: staticProjection.snapshot.sourceDetailCeiling,
      contentDigestAvailable: staticProjection.snapshot.contentDigestAvailable,
    ),
    sourceRefs: _detachedFields(staticProjection.sourceRefs),
    records: records,
    relations: relations,
  );
}

void _validateSemanticObservationEvent(RuntimeSemanticObservationEvent event) {
  if (event.contractId != linkedSpecSemanticExecutionObservationContract) {
    throw _invalidSemanticObservation(
      'Execution observation event contract is unsupported',
    );
  }
  if (event.ruleLabel.isEmpty) {
    throw _invalidSemanticObservation(
      'Execution observation rule label is missing',
    );
  }
  if (event.position < 0) {
    throw _invalidSemanticObservation(
      'Execution observation position must be nonnegative',
    );
  }
  switch (event.eventKind) {
    case RuntimeSemanticObservationEventKind.regexSlotSelected:
      if (event.targetRule == null || event.targetRule!.isEmpty) {
        throw _invalidSemanticObservation(
          'Regex-slot observation target rule is missing',
        );
      }
      if (event.regexIndex == null) {
        throw _invalidSemanticObservation(
          'Regex-slot observation index is missing',
        );
      }
      if (event.regexIndex! < 0) {
        throw _invalidSemanticObservation(
          'Regex-slot observation index must be nonnegative',
        );
      }
      if (event.inputIdentity != null || event.status != null) {
        throw _invalidSemanticObservation(
          'Regex-slot observation cannot carry result identity or status',
        );
      }
    case RuntimeSemanticObservationEventKind.ruleResult:
      if (event.targetRule != null || event.regexIndex != null) {
        throw _invalidSemanticObservation(
          'Rule-result observation cannot carry regex-slot identity',
        );
      }
  }
}

Map<String, Object?> _requiredSemanticObservationShape(
  Map<String, Object?> record,
  String message,
) {
  final facts = record['facts']! as Map<String, Object?>;
  final shape = facts['value_shape'];
  if (shape is! Map<String, Object?>) {
    throw _invalidSemanticObservation(message);
  }
  return shape;
}

bool _isSemanticInputIdentity(String value) =>
    RegExp(r'^input:sha256:[0-9a-f]{64}$').hasMatch(value);

SemanticIndexError _invalidSemanticObservation(String message) =>
    SemanticIndexError(
      stage: 'execution_observation',
      code: 'semantic_index_invalid_observation',
      message: message,
    );
