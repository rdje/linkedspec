part of 'semantic_index.dart';

// FUTURE-PARITY-BACKLOG.10.5.2.1-.2 — private static v1 projection.

const _semanticSpecId = 'spec:0';

const _semanticRecordKinds = <String>[
  'capabilities',
  'spec',
  'source',
  'rule',
  'regex_slot',
  'edge',
  'lifecycle',
  'function',
  'helper',
  'binding',
  'call',
  'staged_artifact',
  'generated_artifact',
  'diagnostic',
  'decision',
  'execution',
  'event',
  'explanation_step',
];

const _semanticRelationKinds = <String>[
  'declares',
  'contains',
  'depends_on',
  'dispatches_to',
  'selects_regex',
  'calls',
  'resolves_to',
  'reads',
  'writes',
  'consumes',
  'produces',
  'lowered_from',
  'staged_by',
  'generated_as',
  'diagnoses',
  'observed_as',
  'explained_by',
];

final class _SemanticStaticProjection {
  _SemanticStaticProjection({
    required this.snapshot,
    required Map<String, Object?> sourceRefs,
    required List<Map<String, Object?>> records,
    required List<Map<String, Object?>> relations,
  }) : sourceRefs = _immutableObject(sourceRefs),
       records = List.unmodifiable([
         for (final record in records) _immutableObject(record),
       ]),
       relations = List.unmodifiable([
         for (final relation in relations) _immutableObject(relation),
       ]);

  final SemanticSnapshot snapshot;
  final Map<String, Object?> sourceRefs;
  final List<Map<String, Object?>> records;
  final List<Map<String, Object?>> relations;

  Map<String, Object?> detachedJson() => <String, Object?>{
    'snapshot': snapshot.toJson(),
    'source_refs': _detachedFields(sourceRefs),
    'records': [for (final record in records) _detachedFields(record)],
    'relations': [for (final relation in relations) _detachedFields(relation)],
  };
}

/// Package-internal exact-oracle seam, deliberately omitted from the public
/// `linkedspec_dart.dart` export list. Production consumers use the later
/// projection-only query layer rather than receiving unredacted private data.
extension SemanticIndexStaticProjectionTestAccess on SemanticIndex {
  Map<String, Object?> semanticStaticProjectionForTesting() =>
      _staticProjection.detachedJson();
}

final class _SemanticSourceRange {
  const _SemanticSourceRange(this.start, this.end);

  final int start;
  final int end;
}

final class _SemanticScannedRule {
  const _SemanticScannedRule({
    required this.label,
    required this.header,
    required this.members,
  });

  final String label;
  final _SemanticSourceRange header;
  final List<_SemanticScannedMember> members;
}

final class _SemanticScannedMember {
  const _SemanticScannedMember({
    required this.range,
    required this.regex,
    required this.regexFlags,
    required this.edges,
    required this.lifecycle,
    required this.lifecycleHasPayload,
  });

  final _SemanticSourceRange range;
  final String? regex;
  final String regexFlags;
  final List<_SemanticScannedEdge> edges;
  final String? lifecycle;
  final bool lifecycleHasPayload;
}

final class _SemanticScannedEdge {
  const _SemanticScannedEdge({
    required this.ownership,
    required this.target,
    required this.targetIndex,
  });

  final String ownership;
  final String target;
  final int? targetIndex;
}

final class _SemanticProjectedEdge {
  const _SemanticProjectedEdge({
    required this.source,
    required this.ownership,
    required this.target,
    required this.targetIndex,
    required this.hasBlock,
    required this.valueShape,
  });

  final _SemanticSourceRange source;
  final String ownership;
  final String target;
  final int? targetIndex;
  final bool hasBlock;
  final Map<String, Object?> valueShape;
}

final class _SemanticNormalizedFailure {
  const _SemanticNormalizedFailure({
    required this.code,
    required this.stage,
    required this.message,
    required this.fields,
    required this.ruleLabel,
    required this.target,
  });

  final String code;
  final String stage;
  final String message;
  final Map<String, Object?> fields;
  final String? ruleLabel;
  final String? target;
}

_SemanticStaticProjection _buildSemanticStaticProjection({
  required String sourceText,
  required _SemanticSourceMap sourceMap,
  required String logicalName,
  required String contentDigest,
  required SemanticSnapshot snapshot,
  required _SemanticCompilationOutcome outcome,
}) {
  final parsed = outcome.parsed;
  final compiled = outcome.compiled;
  if (parsed != null && compiled != null) {
    return _buildCompiledStaticProjection(
      sourceText: sourceText,
      sourceMap: sourceMap,
      logicalName: logicalName,
      contentDigest: contentDigest,
      snapshot: snapshot,
      parsed: parsed,
      compiled: compiled,
      entry: outcome.entry,
    );
  }
  return _buildFailedStaticProjection(
    sourceText: sourceText,
    sourceMap: sourceMap,
    logicalName: logicalName,
    contentDigest: contentDigest,
    snapshot: snapshot,
    parsed: parsed,
    diagnostic: outcome.diagnostic,
  );
}

_SemanticStaticProjection _buildFailedStaticProjection({
  required String sourceText,
  required _SemanticSourceMap sourceMap,
  required String logicalName,
  required String contentDigest,
  required SemanticSnapshot snapshot,
  required SpecFile? parsed,
  required SemanticCompilationDiagnostic? diagnostic,
}) {
  final scans = parsed == null
      ? const <_SemanticScannedRule>[]
      : _scanSemanticRules(sourceText, parsed);
  final sourceRefs = <String, Object?>{};
  final records = <Map<String, Object?>>[];
  final relations = <Map<String, Object?>>[];
  final rules = parsed?.rules ?? const <Rule>[];
  final normalized = _normalizeSemanticFailure(diagnostic);
  final failedLabel = normalized.ruleLabel ?? rules.firstOrNull?.header.label;
  final failedRuleId = failedLabel == null
      ? null
      : _semanticRuleId(failedLabel);
  final failedScan = failedLabel == null
      ? null
      : scans.where((scan) => scan.label == failedLabel).firstOrNull;

  records.add(
    _semanticRecord(
      id: _semanticSpecId,
      kind: 'spec',
      name: _semanticSpecName(logicalName),
      ownerId: null,
      order: 0,
      source: null,
      facts: {
        'definition_order': [
          for (final rule in rules) _semanticRuleId(rule.header.label),
        ],
        'compiled_rule_order': <Object?>[],
        'entry_rule_id': null,
        'entry_selection_basis': null,
      },
    ),
  );
  records.add(_semanticSourceRecord());

  for (final (order, rule) in rules.indexed) {
    final ruleId = _semanticRuleId(rule.header.label);
    final scan = scans
        .where((candidate) => candidate.label == rule.header.label)
        .firstOrNull;
    final source = scan == null
        ? null
        : _registerSemanticSource(
            sourceRefs: sourceRefs,
            recordId: ruleId,
            range: scan.header,
            sourceText: sourceText,
            sourceMap: sourceMap,
            logicalName: logicalName,
            contentDigest: contentDigest,
          );
    final repetition = _neutralSemanticRepetition(rule.header.mode);
    final bounds = _neutralSemanticBounds(rule.header.mode);
    records.add(
      _semanticRecord(
        id: ruleId,
        kind: 'rule',
        name: rule.header.label,
        ownerId: _semanticSpecId,
        order: order,
        source: source,
        facts: {
          'family': rule.header.mode.isAnd ? 'and' : 'or',
          'cursor_policy': rule.header.mode.isAnd ? 'contiguous' : 'seek',
          'is_entry_marker': rule.header.isTop,
          'is_repetition': repetition,
          'rep_min': bounds.$1,
          'rep_max': bounds.$2,
          'edge_ownership': _semanticScannedEdgeOwnership(scan),
          'value_shape': _semanticValueShape('unknown'),
        },
      ),
    );
  }

  const diagnosticId = 'diagnostic:compile:0';
  final diagnosticMember = normalized.target == null || failedScan == null
      ? null
      : _semanticMemberForTarget(failedScan, normalized.target!);
  final diagnosticSource = diagnosticMember == null
      ? null
      : _registerSemanticSource(
          sourceRefs: sourceRefs,
          recordId: diagnosticId,
          range: diagnosticMember.range,
          sourceText: sourceText,
          sourceMap: sourceMap,
          logicalName: logicalName,
          contentDigest: contentDigest,
        );
  records.add(
    _semanticRecord(
      id: diagnosticId,
      kind: 'diagnostic',
      name: normalized.code,
      ownerId: _semanticSpecId,
      order: 0,
      source: diagnosticSource,
      facts: {
        'code': normalized.code,
        'stage': normalized.stage,
        'severity': 'error',
        'message': normalized.message,
        'fields': normalized.fields,
      },
    ),
  );
  relations.add(
    _semanticRelation(
      kind: 'contains',
      fromId: _semanticSpecId,
      toId: _semanticSourceId,
      order: 0,
      source: null,
    ),
  );
  relations.add(
    _semanticRelation(
      kind: 'contains',
      fromId: _semanticSpecId,
      toId: diagnosticId,
      order: 1,
      source: diagnosticSource,
    ),
  );

  if (normalized.code == 'unknown_rule_reference' &&
      failedLabel != null &&
      failedRuleId != null &&
      normalized.target != null) {
    final target = normalized.target!;
    final decisionId = 'decision:compile:$failedRuleId';
    final explanationId = 'explanation:$decisionId:0';
    records.add(
      _semanticRecord(
        id: decisionId,
        kind: 'decision',
        name: 'compile rule $failedLabel',
        ownerId: failedRuleId,
        order: 0,
        source: diagnosticSource,
        facts: {
          'decision_kind': 'dependency_resolution',
          'outcome': diagnosticId,
        },
      ),
    );
    records.add(
      _semanticRecord(
        id: explanationId,
        kind: 'explanation_step',
        name: null,
        ownerId: decisionId,
        order: 0,
        source: diagnosticSource,
        facts: {
          'rule_code': 'dependency_target_missing',
          'summary': 'The authored dependency $target has no declared rule.',
          'input_ids': [failedRuleId],
          'output_fact': {
            'record_id': decisionId,
            'path': '/facts/outcome',
            'value': diagnosticId,
          },
        },
      ),
    );
    relations.add(
      _semanticRelation(
        kind: 'diagnoses',
        fromId: diagnosticId,
        toId: failedRuleId,
        order: 0,
        source: diagnosticSource,
      ),
    );
    relations.add(
      _semanticRelation(
        kind: 'explained_by',
        fromId: decisionId,
        toId: explanationId,
        order: 0,
        source: diagnosticSource,
        evidenceIds: const [diagnosticId],
      ),
    );
  }

  _canonicalizeSemanticProjection(records, relations);
  return _SemanticStaticProjection(
    snapshot: snapshot,
    sourceRefs: sourceRefs,
    records: records,
    relations: relations,
  );
}

_SemanticNormalizedFailure _normalizeSemanticFailure(
  SemanticCompilationDiagnostic? diagnostic,
) {
  final actual =
      diagnostic ??
      SemanticCompilationDiagnostic(
        code: 'semantic_index_compilation_failed',
        stage: 'compile_source',
        message: 'Spec compilation failed.',
      );
  final ruleLabel = _semanticStringField(actual.fields, 'rule_label');
  final target =
      _semanticStringField(actual.fields, 'target') ??
      _semanticStringField(actual.fields, 'target_rule');
  if ((actual.code == 'bare_edge_target_undefined' ||
          actual.code == 'regex_slot_identity_invalid') &&
      ruleLabel != null &&
      target != null) {
    return _SemanticNormalizedFailure(
      code: 'unknown_rule_reference',
      stage: 'compile',
      message: 'Rule $ruleLabel references unknown rule $target.',
      fields: {
        'rule_id': _semanticRuleId(ruleLabel),
        'missing_rule_id': _semanticRuleId(target),
      },
      ruleLabel: ruleLabel,
      target: target,
    );
  }
  return _SemanticNormalizedFailure(
    code: actual.code,
    stage: actual.stage,
    message: actual.message,
    fields: _detachedFields(actual.fields),
    ruleLabel: ruleLabel,
    target: target,
  );
}

String? _semanticStringField(Map<String, Object?> fields, String name) {
  final value = fields[name];
  return value is String ? value : null;
}

String _semanticScannedEdgeOwnership(_SemanticScannedRule? scan) {
  final ownerships = scan == null
      ? const <String>[]
      : [
          for (final member in scan.members)
            for (final edge in member.edges) edge.ownership,
        ];
  final action = ownerships.contains('action');
  final blind = ownerships.contains('blind');
  return switch ((action, blind)) {
    (true, false) => 'action',
    (false, true) => 'blind',
    (false, false) => 'none',
    (true, true) => 'mixed',
  };
}

_SemanticScannedMember? _semanticMemberForTarget(
  _SemanticScannedRule scan,
  String target,
) => scan.members
    .where((member) => member.edges.any((edge) => edge.target == target))
    .firstOrNull;

_SemanticStaticProjection _buildCompiledStaticProjection({
  required String sourceText,
  required _SemanticSourceMap sourceMap,
  required String logicalName,
  required String contentDigest,
  required SemanticSnapshot snapshot,
  required SpecFile parsed,
  required CompiledSpec compiled,
  required SemanticEntrySelection? entry,
}) {
  final scans = _scanSemanticRules(sourceText, parsed);
  final scansByLabel = <String, _SemanticScannedRule>{
    for (final scan in scans) scan.label: scan,
  };
  final sourceRefs = <String, Object?>{};
  final records = <Map<String, Object?>>[];
  final relations = <Map<String, Object?>>[];
  final recordSources = <String, String?>{};
  final definitionOrder = [
    for (final label in compiled.definitionOrder) _semanticRuleId(label),
  ];
  final compiledOrder = [
    for (final label in compiled.compiledRuleOrder) _semanticRuleId(label),
  ];
  final entryRuleId = entry == null ? null : _semanticRuleId(entry.label);
  final entryBasis = entry == null
      ? null
      : _neutralSemanticEntryBasis(entry.basis);

  records.add(
    _semanticRecord(
      id: _semanticSpecId,
      kind: 'spec',
      name: _semanticSpecName(logicalName),
      ownerId: null,
      order: 0,
      source: null,
      facts: {
        'definition_order': definitionOrder,
        'compiled_rule_order': compiledOrder,
        'entry_rule_id': entryRuleId,
        'entry_selection_basis': entryBasis,
      },
    ),
  );
  records.add(_semanticSourceRecord());

  for (final (ruleOrder, label) in compiled.compiledRuleOrder.indexed) {
    final parsedRule = parsed.rules
        .where((rule) => rule.header.label == label)
        .firstOrNull;
    final compiledRule = compiled.rulesByLabel[label];
    final scan = scansByLabel[label];
    if (parsedRule == null || compiledRule == null || scan == null) {
      throw _semanticCorrelationError(
        'Compiled rule has no matching parsed source owner',
        label,
      );
    }
    final ruleId = _semanticRuleId(label);
    final ruleSource = _registerSemanticSource(
      sourceRefs: sourceRefs,
      recordId: ruleId,
      range: scan.header,
      sourceText: sourceText,
      sourceMap: sourceMap,
      logicalName: logicalName,
      contentDigest: contentDigest,
    );
    recordSources[ruleId] = ruleSource;
    final projectedEdges = _projectSemanticEdges(
      scan: scan,
      compiled: compiledRule,
    );
    final regexSlots = _projectSemanticRegexSlots(
      scan: scan,
      compiled: compiledRule,
    );
    final lifecycles = _projectSemanticLifecycles(
      scan: scan,
      compiled: compiledRule,
    );
    final repetition = _neutralSemanticRepetition(parsedRule.header.mode);
    final bounds = _neutralSemanticBounds(parsedRule.header.mode);
    records.add(
      _semanticRecord(
        id: ruleId,
        kind: 'rule',
        name: label,
        ownerId: _semanticSpecId,
        order: ruleOrder,
        source: ruleSource,
        facts: {
          'family': parsedRule.header.mode.isAnd ? 'and' : 'or',
          'cursor_policy': parsedRule.header.mode.isAnd ? 'contiguous' : 'seek',
          'is_entry_marker': parsedRule.header.isTop,
          'is_repetition': repetition,
          'rep_min': bounds.$1,
          'rep_max': bounds.$2,
          'edge_ownership': _semanticRuleEdgeOwnership(projectedEdges),
          'value_shape': _semanticRuleValueShape(
            repetition: repetition,
            edges: projectedEdges,
            lifecycles: lifecycles,
          ),
        },
      ),
    );

    for (final (slotOrder, slot) in regexSlots.indexed) {
      final slotId = 'regex:$ruleId:$slotOrder';
      final source = _registerSemanticSource(
        sourceRefs: sourceRefs,
        recordId: slotId,
        range: slot.range,
        sourceText: sourceText,
        sourceMap: sourceMap,
        logicalName: logicalName,
        contentDigest: contentDigest,
      );
      recordSources[slotId] = source;
      records.add(
        _semanticRecord(
          id: slotId,
          kind: 'regex_slot',
          name: null,
          ownerId: ruleId,
          order: slotOrder,
          source: source,
          facts: {
            'authored_index': slotOrder,
            'pattern': slot.regex,
            'flags': slot.regexFlags,
            'combined_owner_ids': [ruleId],
            'target_shape': _semanticValueShape('regex_slot'),
          },
        ),
      );
    }

    for (final (edgeOrder, edge) in projectedEdges.indexed) {
      final edgeId = 'edge:$ruleId:$edgeOrder';
      final source = _registerSemanticSource(
        sourceRefs: sourceRefs,
        recordId: edgeId,
        range: edge.source,
        sourceText: sourceText,
        sourceMap: sourceMap,
        logicalName: logicalName,
        contentDigest: contentDigest,
      );
      recordSources[edgeId] = source;
      records.add(
        _semanticRecord(
          id: edgeId,
          kind: 'edge',
          name: null,
          ownerId: ruleId,
          order: edgeOrder,
          source: source,
          facts: {
            'ownership': edge.ownership,
            'source_form': edge.targetIndex == null ? 'direct' : 'indexed',
            'has_block': edge.hasBlock,
            'fluent_call_ids': <Object?>[],
            'value_shape': edge.valueShape,
            'target_shape': _semanticValueShape(
              edge.targetIndex == null ? 'rule' : 'regex_slot',
            ),
          },
        ),
      );
    }

    final markerCounts = <String, int>{};
    for (final lifecycle in lifecycles) {
      final marker = lifecycle.$2;
      final markerOrder = markerCounts.update(
        marker,
        (value) => value + 1,
        ifAbsent: () => 0,
      );
      final lifecycleId = 'lifecycle:$ruleId:$marker:$markerOrder';
      final source = _registerSemanticSource(
        sourceRefs: sourceRefs,
        recordId: lifecycleId,
        range: lifecycle.$1.range,
        sourceText: sourceText,
        sourceMap: sourceMap,
        logicalName: logicalName,
        contentDigest: contentDigest,
      );
      recordSources[lifecycleId] = source;
      records.add(
        _semanticRecord(
          id: lifecycleId,
          kind: 'lifecycle',
          name: marker,
          ownerId: ruleId,
          order: markerOrder,
          source: source,
          facts: {
            'marker': marker,
            'whole_rule_return': marker == 'E',
            'value_shape': lifecycle.$3,
          },
        ),
      );
    }

    relations.add(
      _semanticRelation(
        kind: 'declares',
        fromId: _semanticSpecId,
        toId: ruleId,
        order: ruleOrder,
        source: null,
      ),
    );
    var containsOrder = 0;
    for (var slotOrder = 0; slotOrder < regexSlots.length; slotOrder += 1) {
      final slotId = 'regex:$ruleId:$slotOrder';
      relations.add(
        _semanticRelation(
          kind: 'contains',
          fromId: ruleId,
          toId: slotId,
          order: containsOrder,
          source: recordSources[slotId],
        ),
      );
      containsOrder += 1;
    }
    for (var edgeOrder = 0; edgeOrder < projectedEdges.length; edgeOrder += 1) {
      final edgeId = 'edge:$ruleId:$edgeOrder';
      relations.add(
        _semanticRelation(
          kind: 'contains',
          fromId: ruleId,
          toId: edgeId,
          order: containsOrder,
          source: recordSources[edgeId],
        ),
      );
      containsOrder += 1;
    }
    markerCounts.clear();
    for (final lifecycle in lifecycles) {
      final marker = lifecycle.$2;
      final markerOrder = markerCounts.update(
        marker,
        (value) => value + 1,
        ifAbsent: () => 0,
      );
      final lifecycleId = 'lifecycle:$ruleId:$marker:$markerOrder';
      relations.add(
        _semanticRelation(
          kind: 'contains',
          fromId: ruleId,
          toId: lifecycleId,
          order: containsOrder,
          source: recordSources[lifecycleId],
        ),
      );
      containsOrder += 1;
    }
    for (final (edgeOrder, edge) in projectedEdges.indexed) {
      final edgeId = 'edge:$ruleId:$edgeOrder';
      final targetRuleId = _semanticRuleId(edge.target);
      final source = recordSources[edgeId];
      if (!(targetRuleId == ruleId && edge.targetIndex != null)) {
        relations.add(
          _semanticRelation(
            kind: 'dispatches_to',
            fromId: edgeId,
            toId: targetRuleId,
            order: edgeOrder,
            source: source,
          ),
        );
      }
      if (edge.targetIndex case final targetIndex?) {
        relations.add(
          _semanticRelation(
            kind: 'selects_regex',
            fromId: edgeId,
            toId: 'regex:$targetRuleId:$targetIndex',
            order: edgeOrder,
            source: source,
          ),
        );
      }
    }
  }

  relations.add(
    _semanticRelation(
      kind: 'contains',
      fromId: _semanticSpecId,
      toId: _semanticSourceId,
      order: 0,
      source: null,
    ),
  );
  if (parsed.functions.isEmpty && compiled.compiledRuleOrder.length > 1) {
    if (entry case final selected?) {
      _addSemanticEntryExplanation(
        records: records,
        relations: relations,
        selected: selected,
        source: recordSources[_semanticRuleId(selected.label)],
      );
    }
  }
  _canonicalizeSemanticProjection(records, relations);
  return _SemanticStaticProjection(
    snapshot: snapshot,
    sourceRefs: sourceRefs,
    records: records,
    relations: relations,
  );
}

List<_SemanticProjectedEdge> _projectSemanticEdges({
  required _SemanticScannedRule scan,
  required CompiledRule compiled,
}) {
  final scanned = [
    for (final member in scan.members)
      for (final edge in member.edges) (member.range, edge),
  ];
  if (scanned.length !=
      compiled.actionEdges.length + compiled.blindEdges.length) {
    throw _semanticCorrelationError(
      'Authored and compiled edge counts differ',
      compiled.label,
      fields: {
        'authored_edges': scanned.length,
        'compiled_edges':
            compiled.actionEdges.length + compiled.blindEdges.length,
      },
    );
  }
  final projected = <_SemanticProjectedEdge>[];
  var actionIndex = 0;
  var blindIndex = 0;
  for (final (range, sourceEdge) in scanned) {
    if (sourceEdge.ownership == 'action') {
      if (actionIndex >= compiled.actionEdges.length) {
        throw _semanticCorrelationError(
          'Authored action edge has no compiled owner',
          compiled.label,
        );
      }
      final edge = compiled.actionEdges[actionIndex];
      actionIndex += 1;
      _requireSemanticActionEdgeIdentity(compiled.label, sourceEdge, edge);
      projected.add(
        _SemanticProjectedEdge(
          source: range,
          ownership: 'action',
          target: sourceEdge.target,
          targetIndex: sourceEdge.targetIndex,
          hasBlock: edge.code != null,
          valueShape: _semanticActionBlockReturnShape(
            edge.actionPayload?.actionAst,
          ),
        ),
      );
      continue;
    }
    if (blindIndex >= compiled.blindEdges.length) {
      throw _semanticCorrelationError(
        'Authored blind edge has no compiled owner',
        compiled.label,
      );
    }
    final edge = compiled.blindEdges[blindIndex];
    blindIndex += 1;
    _requireSemanticBlindEdgeIdentity(compiled.label, sourceEdge, edge);
    projected.add(
      _SemanticProjectedEdge(
        source: range,
        ownership: 'blind',
        target: sourceEdge.target,
        targetIndex: null,
        hasBlock: edge.code != null,
        valueShape: _semanticActionBlockReturnShape(
          edge.actionPayload?.actionAst,
        ),
      ),
    );
  }
  return List.unmodifiable(projected);
}

void _requireSemanticActionEdgeIdentity(
  String owner,
  _SemanticScannedEdge source,
  CompiledActionEdge edge,
) {
  if (edge.targets.length == 1 &&
      edge.targets.single.label == source.target &&
      edge.childRegexIndex == (source.targetIndex ?? 0)) {
    return;
  }
  throw _semanticCorrelationError(
    'Authored and compiled action-edge identities differ',
    owner,
  );
}

void _requireSemanticBlindEdgeIdentity(
  String owner,
  _SemanticScannedEdge source,
  CompiledBlindEdge edge,
) {
  if (edge.target.label == source.target) {
    return;
  }
  throw _semanticCorrelationError(
    'Authored and compiled blind-edge identities differ',
    owner,
  );
}

List<_SemanticScannedMember> _projectSemanticRegexSlots({
  required _SemanticScannedRule scan,
  required CompiledRule compiled,
}) {
  final slots = <_SemanticScannedMember>[];
  for (final member in scan.members) {
    if (member.regex == null) {
      continue;
    }
    final retained =
        member.edges.isEmpty ||
        member.edges.any(
          (edge) => edge.target == compiled.label && edge.targetIndex != null,
        );
    if (retained) {
      slots.add(member);
    }
  }
  for (final (index, slot) in slots.indexed) {
    if (index >= compiled.regexPatterns.length ||
        compiled.regexPatterns[index] != slot.regex) {
      throw _semanticCorrelationError(
        'Authored and compiled regex-slot identities differ',
        compiled.label,
        fields: {'slot': index},
      );
    }
  }
  return List.unmodifiable(slots);
}

List<(_SemanticScannedMember, String, Map<String, Object?>)>
_projectSemanticLifecycles({
  required _SemanticScannedRule scan,
  required CompiledRule compiled,
}) {
  final result = <(_SemanticScannedMember, String, Map<String, Object?>)>[];
  var payloadIndex = 0;
  for (final member in scan.members) {
    final marker = member.lifecycle;
    if (marker == null) {
      continue;
    }
    if (!member.lifecycleHasPayload) {
      result.add((member, marker, _semanticValueShape('unknown')));
      continue;
    }
    if (payloadIndex >= compiled.lifecycleActionPayloads.length) {
      throw _semanticCorrelationError(
        'Authored lifecycle block has no compiled payload',
        compiled.label,
        fields: {'marker': marker},
      );
    }
    final payload = compiled.lifecycleActionPayloads[payloadIndex];
    payloadIndex += 1;
    if (payload.lifecycle != marker) {
      throw _semanticCorrelationError(
        'Authored and compiled lifecycle identities differ',
        compiled.label,
        fields: {
          'authored_marker': marker,
          'compiled_marker': payload.lifecycle,
        },
      );
    }
    result.add((
      member,
      marker,
      _semanticActionBlockReturnShape(payload.actionAst),
    ));
  }
  if (payloadIndex != compiled.lifecycleActionPayloads.length) {
    throw _semanticCorrelationError(
      'Compiled lifecycle payload has no authored source owner',
      compiled.label,
      fields: {
        'authored_payloads': payloadIndex,
        'compiled_payloads': compiled.lifecycleActionPayloads.length,
      },
    );
  }
  return List.unmodifiable(result);
}

List<_SemanticScannedRule> _scanSemanticRules(String source, SpecFile parsed) {
  final lines = _semanticLineRanges(source);
  return List.unmodifiable([
    for (final rule in parsed.rules) _scanSemanticRule(source, lines, rule),
  ]);
}

_SemanticScannedRule _scanSemanticRule(
  String source,
  List<_SemanticSourceRange> lines,
  Rule rule,
) {
  final grouped = <int, List<BodyElement>>{};
  for (final element in rule.body) {
    grouped.putIfAbsent(element.line, () => <BodyElement>[]).add(element);
  }
  return _SemanticScannedRule(
    label: rule.header.label,
    header: _semanticTrimmedLineRange(source, lines, rule.header.line),
    members: List.unmodifiable([
      for (final entry in grouped.entries)
        _scanSemanticMember(
          source,
          _semanticMemberRange(source, lines, entry.key),
          entry.value,
          rule.header.mode,
        ),
    ]),
  );
}

_SemanticScannedMember _scanSemanticMember(
  String source,
  _SemanticSourceRange range,
  List<BodyElement> elements,
  RuleMode mode,
) {
  final text = source.substring(range.start, range.end);
  String? regex;
  var flags = '';
  final edges = <_SemanticScannedEdge>[];
  String? lifecycle;
  var lifecycleHasPayload = false;
  for (final element in elements) {
    switch (element.kind) {
      case RegexBodyElementKind(:final pattern):
        regex ??= pattern;
        flags = _semanticLeadingRegexFlags(text);
      case ActionEdgeBodyElementKind(:final targets):
        for (final target in targets) {
          edges.add(
            _SemanticScannedEdge(
              ownership: 'action',
              target: target.label,
              targetIndex: _semanticExplicitTargetIndex(
                text,
                target.label,
                target.index,
              ),
            ),
          );
        }
      case BlindEdgeBodyElementKind(:final target):
        edges.add(
          _SemanticScannedEdge(
            ownership: 'blind',
            target: target,
            targetIndex: null,
          ),
        );
      case BareEdgeBodyElementKind(:final targets):
        for (final target in targets) {
          edges.add(
            _SemanticScannedEdge(
              ownership: mode.isAnd ? 'blind' : 'action',
              target: target.label,
              targetIndex: mode.isAnd ? null : target.index,
            ),
          );
        }
      case CodeBlockBodyElementKind(lifecycle: final marker):
        lifecycle = marker;
        lifecycleHasPayload = true;
      case LifecycleMarkerBodyElementKind(:final marker):
        lifecycle = marker;
      default:
        break;
    }
  }
  return _SemanticScannedMember(
    range: range,
    regex: regex,
    regexFlags: flags,
    edges: List.unmodifiable(edges),
    lifecycle: lifecycle,
    lifecycleHasPayload: lifecycleHasPayload,
  );
}

List<_SemanticSourceRange> _semanticLineRanges(String source) {
  final result = <_SemanticSourceRange>[];
  var start = 0;
  for (var index = 0; index < source.length; index += 1) {
    if (source.codeUnitAt(index) == 0x0A) {
      result.add(_SemanticSourceRange(start, index));
      start = index + 1;
    }
  }
  if (start < source.length || source.isEmpty) {
    result.add(_SemanticSourceRange(start, source.length));
  }
  return List.unmodifiable(result);
}

_SemanticSourceRange _semanticTrimmedLineRange(
  String source,
  List<_SemanticSourceRange> lines,
  int line,
) {
  if (line <= 0 || line > lines.length) {
    throw _semanticCorrelationError(
      'Parsed line is outside the captured source',
      line.toString(),
    );
  }
  final raw = lines[line - 1];
  final text = source.substring(raw.start, raw.end);
  final left = text.length - text.trimLeft().length;
  final right = text.trimRight().length;
  return _SemanticSourceRange(raw.start + left, raw.start + right);
}

_SemanticSourceRange _semanticMemberRange(
  String source,
  List<_SemanticSourceRange> lines,
  int line,
) {
  final first = _semanticTrimmedLineRange(source, lines, line);
  var depth = 0;
  int? quote;
  var escaped = false;
  var regex = source.startsWith('/', first.start);
  var lastNonWhitespace = first.start;
  for (var index = first.start; index < source.length; index += 1) {
    final codeUnit = source.codeUnitAt(index);
    if (codeUnit == 0x0A && quote == null && !regex && depth == 0) {
      return _SemanticSourceRange(first.start, lastNonWhitespace);
    }
    if (!_semanticWhitespace(codeUnit)) {
      lastNonWhitespace = index + 1;
    }
    if (regex) {
      if (escaped) {
        escaped = false;
      } else if (codeUnit == 0x5C) {
        escaped = true;
      } else if (codeUnit == 0x2F && index != first.start) {
        regex = false;
      }
      continue;
    }
    if (quote != null) {
      if (escaped) {
        escaped = false;
      } else if (codeUnit == 0x5C) {
        escaped = true;
      } else if (codeUnit == quote) {
        quote = null;
      }
      continue;
    }
    if (codeUnit == 0x22 || codeUnit == 0x27) {
      quote = codeUnit;
      continue;
    }
    if (codeUnit == 0x28 || codeUnit == 0x5B || codeUnit == 0x7B) {
      depth += 1;
    } else if (codeUnit == 0x29 || codeUnit == 0x5D || codeUnit == 0x7D) {
      depth -= 1;
    }
  }
  return _SemanticSourceRange(first.start, lastNonWhitespace);
}

bool _semanticWhitespace(int codeUnit) =>
    String.fromCharCode(codeUnit).trim().isEmpty;

String _semanticLeadingRegexFlags(String text) {
  if (!text.startsWith('/')) {
    return '';
  }
  var escaped = false;
  for (var index = 1; index < text.length; index += 1) {
    final codeUnit = text.codeUnitAt(index);
    if (escaped) {
      escaped = false;
    } else if (codeUnit == 0x5C) {
      escaped = true;
    } else if (codeUnit == 0x2F) {
      var end = index + 1;
      while (end < text.length) {
        final candidate = text.codeUnitAt(end);
        final asciiLetter =
            (candidate >= 0x41 && candidate <= 0x5A) ||
            (candidate >= 0x61 && candidate <= 0x7A);
        if (!asciiLetter) {
          break;
        }
        end += 1;
      }
      return text.substring(index + 1, end);
    }
  }
  return '';
}

int? _semanticExplicitTargetIndex(String text, String label, int expected) {
  final action = text.indexOf('->');
  final blind = text.indexOf('=>');
  final token = action >= 0 ? action : blind;
  final searchStart = token >= 0 ? token + 2 : 0;
  final relative = text.indexOf(label, searchStart);
  if (relative < 0) {
    return null;
  }
  final rest = text.substring(relative + label.length).trimLeft();
  if (!rest.startsWith('[')) {
    return null;
  }
  final close = rest.indexOf(']');
  if (close < 0) {
    return null;
  }
  final parsed = int.tryParse(rest.substring(1, close).trim());
  return parsed == expected ? parsed : null;
}

void _addSemanticEntryExplanation({
  required List<Map<String, Object?>> records,
  required List<Map<String, Object?>> relations,
  required SemanticEntrySelection selected,
  required String? source,
}) {
  final selectedRuleId = _semanticRuleId(selected.label);
  final basis = _neutralSemanticEntryBasis(selected.basis);
  const decisionId = 'decision:entry:spec:0';
  records.add(
    _semanticRecord(
      id: decisionId,
      kind: 'decision',
      name: 'entry selection',
      ownerId: _semanticSpecId,
      order: 0,
      source: source,
      facts: {'decision_kind': 'entry_selection', 'outcome': selectedRuleId},
    ),
  );
  const firstId = 'explanation:decision:entry:spec:0:0';
  final explicit = selected.basis == 'explicit_selector';
  records.add(
    _semanticRecord(
      id: firstId,
      kind: 'explanation_step',
      name: null,
      ownerId: decisionId,
      order: 0,
      source: source,
      facts: {
        'rule_code': explicit
            ? 'entry_explicit_selector'
            : 'entry_explicit_selector_absent',
        'summary': explicit
            ? 'The caller selected ${selected.label}.'
            : 'No caller selector was supplied.',
        'input_ids': [_semanticSpecId],
        'output_fact': {
          'record_id': _semanticSpecId,
          'path': '/facts/entry_selection_basis',
          'value': basis,
        },
      },
    ),
  );
  const secondId = 'explanation:decision:entry:spec:0:1';
  final ruleCode = switch (basis) {
    'first_marker' => 'entry_first_marker',
    'first_rule' => 'entry_first_rule',
    _ => 'entry_explicit_rule',
  };
  final summary = switch (basis) {
    'first_marker' =>
      'The first authored entry marker selects ${selected.label}.',
    'first_rule' => 'The first authored rule selects ${selected.label}.',
    _ => 'The explicit selector resolves to ${selected.label}.',
  };
  records.add(
    _semanticRecord(
      id: secondId,
      kind: 'explanation_step',
      name: null,
      ownerId: decisionId,
      order: 1,
      source: source,
      facts: {
        'rule_code': ruleCode,
        'summary': summary,
        'input_ids': [selectedRuleId],
        'output_fact': {
          'record_id': _semanticSpecId,
          'path': '/facts/entry_rule_id',
          'value': selectedRuleId,
        },
      },
    ),
  );
  relations.add(
    _semanticRelation(
      kind: 'explained_by',
      fromId: decisionId,
      toId: firstId,
      order: 0,
      source: source,
      evidenceIds: [selectedRuleId],
    ),
  );
  relations.add(
    _semanticRelation(
      kind: 'explained_by',
      fromId: decisionId,
      toId: secondId,
      order: 1,
      source: source,
      evidenceIds: [selectedRuleId],
    ),
  );
}

Map<String, Object?> _semanticRuleValueShape({
  required bool repetition,
  required List<_SemanticProjectedEdge> edges,
  required List<(_SemanticScannedMember, String, Map<String, Object?>)>
  lifecycles,
}) {
  for (final lifecycle in lifecycles) {
    if (lifecycle.$2 == 'E' && lifecycle.$3['kind'] != 'unknown') {
      return lifecycle.$3;
    }
  }
  final edge = edges
      .where((candidate) => candidate.valueShape['kind'] != 'unknown')
      .firstOrNull;
  final element = edge?.valueShape ?? _semanticValueShape('unknown');
  return repetition ? _semanticArrayShape(element) : element;
}

Map<String, Object?> _semanticActionBlockReturnShape(ActionBlock? block) {
  if (block == null) {
    return _semanticValueShape('unknown');
  }
  for (final statement in block.statements) {
    final shape = _semanticReturnShape(statement.expr);
    if (shape != null) {
      return shape;
    }
  }
  return _semanticValueShape('unknown');
}

Map<String, Object?>? _semanticReturnShape(ActionExpr expression) {
  switch (expression) {
    case ActionCallExpr(:final name, :final args) when name == 'return':
      return args.isEmpty
          ? _semanticValueShape('unknown')
          : _semanticExpressionShape(args.first.value);
    case ActionBlockValueExpr(:final block):
      return _semanticActionBlockReturnShape(block);
    case ActionFluentChainExpr(:final receiver, :final calls):
      final receiverShape = _semanticReturnShape(receiver);
      if (receiverShape != null) {
        return receiverShape;
      }
      for (final call in calls) {
        if (call.method == 'return') {
          return call.args.isEmpty
              ? _semanticValueShape('unknown')
              : _semanticExpressionShape(call.args.first.value);
        }
      }
      return null;
    default:
      return null;
  }
}

Map<String, Object?> _semanticExpressionShape(ActionExpr expression) {
  return switch (expression) {
    ActionStringLiteralExpr() => _semanticValueShape('string'),
    ActionNumberLiteralExpr() => _semanticValueShape('number'),
    ActionBooleanLiteralExpr() => _semanticValueShape('boolean'),
    ActionUndefExpr() => _semanticValueShape('null'),
    ActionArrayLiteralExpr(:final items) => _semanticArrayShape(
      _semanticCommonShape(items.map(_semanticExpressionShape)),
    ),
    ActionHashLiteralExpr(:final entries) => _semanticHarrayShape(
      _semanticCommonShape(
        entries.map((entry) => _semanticExpressionShape(entry.key)),
      ),
      _semanticCommonShape(
        entries.map((entry) => _semanticExpressionShape(entry.value)),
      ),
    ),
    ActionCallExpr(:final name, :final args) when name == 'return' =>
      args.isEmpty
          ? _semanticValueShape('unknown')
          : _semanticExpressionShape(args.first.value),
    _ => _semanticValueShape('unknown'),
  };
}

Map<String, Object?> _semanticCommonShape(
  Iterable<Map<String, Object?>> shapes,
) {
  final iterator = shapes.iterator;
  if (!iterator.moveNext()) {
    return _semanticValueShape('unknown');
  }
  final first = iterator.current;
  while (iterator.moveNext()) {
    if (!_plainValuesEqual(first, iterator.current)) {
      return _semanticValueShape('unknown');
    }
  }
  return first;
}

Map<String, Object?> _semanticValueShape(String kind) => <String, Object?>{
  'kind': kind,
  'element': null,
  'key': null,
  'value': null,
  'signature': null,
  'members': <Object?>[],
};

Map<String, Object?> _semanticArrayShape(Map<String, Object?> element) =>
    <String, Object?>{..._semanticValueShape('array'), 'element': element};

Map<String, Object?> _semanticHarrayShape(
  Map<String, Object?> key,
  Map<String, Object?> value,
) => <String, Object?>{
  ..._semanticValueShape('harray'),
  'key': key,
  'value': value,
};

bool _neutralSemanticRepetition(RuleMode mode) =>
    mode != RuleMode.defaultMode &&
    mode != RuleMode.and &&
    mode != RuleMode.single &&
    mode != RuleMode.pipe;

(int?, int?) _neutralSemanticBounds(RuleMode mode) =>
    _neutralSemanticRepetition(mode)
    ? (mode.repMin, mode.repMax)
    : (null, null);

String _semanticRuleEdgeOwnership(List<_SemanticProjectedEdge> edges) {
  final action = edges.any((edge) => edge.ownership == 'action');
  final blind = edges.any((edge) => edge.ownership == 'blind');
  return switch ((action, blind)) {
    (true, false) => 'action',
    (false, true) => 'blind',
    (false, false) => 'none',
    (true, true) => 'mixed',
  };
}

String _registerSemanticSource({
  required Map<String, Object?> sourceRefs,
  required String recordId,
  required _SemanticSourceRange range,
  required String sourceText,
  required _SemanticSourceMap sourceMap,
  required String logicalName,
  required String contentDigest,
}) {
  final key = 'source_ref:$recordId';
  sourceRefs[key] = <String, Object?>{
    'source_id': _semanticSourceId,
    'logical_name': logicalName,
    'span': sourceMap.spanForCodeUnitRange(range.start, range.end).toJson(),
    'excerpt': sourceText.substring(range.start, range.end),
    'content_digest': contentDigest,
    'provenance_ids': <Object?>[],
  };
  return key;
}

Map<String, Object?> _semanticSourceRecord() => _semanticRecord(
  id: _semanticSourceId,
  kind: 'source',
  name: null,
  ownerId: _semanticSpecId,
  order: 0,
  source: null,
  facts: const {'logical_kind': 'spec', 'origin_kind': 'authored'},
);

Map<String, Object?> _semanticRecord({
  required String id,
  required String kind,
  required String? name,
  required String? ownerId,
  required int order,
  required String? source,
  required Map<String, Object?> facts,
}) => <String, Object?>{
  'id': id,
  'kind': kind,
  'name': name,
  'owner_id': ownerId,
  'order': order,
  'source': source,
  'facts': facts,
  'redactions': <Object?>[],
};

Map<String, Object?> _semanticRelation({
  required String kind,
  required String fromId,
  required String toId,
  required int order,
  required String? source,
  List<String> evidenceIds = const [],
}) => <String, Object?>{
  'id': 'relation:$kind:$fromId:$toId:$order',
  'kind': kind,
  'from_id': fromId,
  'to_id': toId,
  'order': order,
  'source': source,
  'facts': <String, Object?>{},
  'evidence_ids': evidenceIds,
};

void _canonicalizeSemanticProjection(
  List<Map<String, Object?>> records,
  List<Map<String, Object?>> relations,
) {
  records.sort((left, right) {
    final kind =
        _semanticKindRank(
          _semanticRecordKinds,
          left['kind']! as String,
        ).compareTo(
          _semanticKindRank(_semanticRecordKinds, right['kind']! as String),
        );
    if (kind != 0) {
      return kind;
    }
    final order = (left['order']! as int).compareTo(right['order']! as int);
    return order != 0
        ? order
        : (left['id']! as String).compareTo(right['id']! as String);
  });
  final recordRank = <String, int>{
    for (final (index, record) in records.indexed)
      record['id']! as String: index,
  };
  relations.sort((left, right) {
    var result = (recordRank[left['from_id']] ?? 0x7FFFFFFF).compareTo(
      recordRank[right['from_id']] ?? 0x7FFFFFFF,
    );
    if (result != 0) {
      return result;
    }
    result = _semanticKindRank(_semanticRelationKinds, left['kind']! as String)
        .compareTo(
          _semanticKindRank(_semanticRelationKinds, right['kind']! as String),
        );
    if (result != 0) {
      return result;
    }
    result = (recordRank[left['to_id']] ?? 0x7FFFFFFF).compareTo(
      recordRank[right['to_id']] ?? 0x7FFFFFFF,
    );
    return result != 0
        ? result
        : (left['id']! as String).compareTo(right['id']! as String);
  });
}

int _semanticKindRank(List<String> kinds, String kind) {
  final index = kinds.indexOf(kind);
  return index < 0 ? 0x7FFFFFFF : index;
}

String _semanticRuleId(String label) => 'rule:${_semanticEscapeName(label)}';

String _semanticEscapeName(String name) {
  final buffer = StringBuffer();
  for (final byte in utf8.encode(name)) {
    final safe =
        (byte >= 0x41 && byte <= 0x5A) ||
        (byte >= 0x61 && byte <= 0x7A) ||
        (byte >= 0x30 && byte <= 0x39) ||
        byte == 0x2E ||
        byte == 0x5F ||
        byte == 0x7E ||
        byte == 0x2D;
    if (safe) {
      buffer.writeCharCode(byte);
    } else {
      buffer.write('%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}');
    }
  }
  return buffer.toString();
}

String _semanticSpecName(String logicalName) => logicalName.endsWith('.spec')
    ? logicalName.substring(0, logicalName.length - 5)
    : logicalName;

String _neutralSemanticEntryBasis(String basis) => switch (basis) {
  'first_authored_marker' => 'first_marker',
  'first_authored_rule' => 'first_rule',
  'explicit_selector' => 'explicit_selector',
  _ => 'first_rule',
};

SemanticIndexError _semanticCorrelationError(
  String message,
  String identity, {
  Map<String, Object?> fields = const {},
}) => SemanticIndexError(
  stage: 'project_static_semantics',
  code: 'semantic_static_correlation_failed',
  message: message,
  fields: {'identity': identity, ...fields},
);

Map<String, Object?> _immutableObject(Map<String, Object?> value) =>
    _immutablePlainValue(value)! as Map<String, Object?>;
