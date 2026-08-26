/// Private inert staged parse-job declarations and typed provenance.
///
/// This module owns no parser registry, cache, scheduler, callback, source
/// path, or stitching behavior. Live match boundaries are converted through
/// the existing typed source authority before a detached marker is returned.
library;

import '../action/action_ast.dart';
import 'matching.dart';
import 'source_location.dart';

const _errorPrefix = 'LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:';
const _provenanceCode = 'staged_source_provenance_invalid';
const _sourceId = 'input';

/// One detached staged-declaration failure.
final class StagedParseJobDeclarationException implements Exception {
  StagedParseJobDeclarationException._(Map<String, Object?> record)
    : _record = Map<String, Object?>.unmodifiable(record);

  factory StagedParseJobDeclarationException.provenance({
    required String origin,
    required String sourceId,
    required String provenance,
  }) {
    return StagedParseJobDeclarationException._(<String, Object?>{
      'code': _provenanceCode,
      'phase': 'declare',
      'origin': origin,
      'source_id': sourceId,
      'provenance': provenance,
    });
  }

  final Map<String, Object?> _record;

  Map<String, Object?> toJson() => Map<String, Object?>.from(_record);

  @override
  String toString() => '$_errorPrefix${_record['code']}';
}

/// Validates and materializes one detached neutral direct or ordered-derived
/// provenance record.
Map<String, Object?> validateAndMaterializeStagedProvenance({
  required SourceAuthority authority,
  required Object? record,
  required String origin,
}) {
  if (record is Map && record['kind'] == 'direct_span') {
    final typed = _typedDirectSpan(authority, record, origin);
    try {
      return <String, Object?>{
        'text': authority.materialize(typed.span, context: _context(origin)),
        'provenance': typed.detached,
      };
    } on SourceLocationException {
      throw StagedParseJobDeclarationException.provenance(
        origin: origin,
        sourceId: typed.sourceId,
        provenance: typed.provenance,
      );
    }
  }

  if (record is! Map ||
      !_hasExactKeys(record, const <String>['kind', 'policy', 'segments']) ||
      record['kind'] != 'derived_text' ||
      record['policy'] != ActionStagedParseJobDerivedTextPlan.policy ||
      record['segments'] is! List ||
      (record['segments']! as List).isEmpty) {
    throw StagedParseJobDeclarationException.provenance(
      origin: origin,
      sourceId: '<derived>',
      provenance: 'derived_text',
    );
  }

  final spans = <Span>[];
  final detachedSegments = <Map<String, Object?>>[];
  for (final segment in record['segments']! as List) {
    final typed = _typedDirectSpan(authority, segment, origin);
    spans.add(typed.span);
    detachedSegments.add(typed.detached);
  }
  try {
    final derived = authority.derivedText(
      policy: DerivedTextPolicy.concatenateInOrder,
      spans: spans,
      context: _context(origin),
    );
    return <String, Object?>{
      'text': authority.materialize(derived, context: _context(origin)),
      'provenance': <String, Object?>{
        'kind': 'derived_text',
        'policy': ActionStagedParseJobDerivedTextPlan.policy,
        'segments': detachedSegments,
      },
    };
  } on SourceLocationException {
    throw StagedParseJobDeclarationException.provenance(
      origin: origin,
      sourceId: '<derived>',
      provenance: 'derived_text',
    );
  }
}

/// Constructs one detached inert marker from live typed match provenance.
Map<String, Object?> constructStagedParseJobMarker({
  required SourceAuthority authority,
  required RuntimeMatchRegisters registers,
  required String origin,
  required ActionStagedParseJobTextPlan textPlan,
  required ActionStagedParseJobOptions options,
}) {
  final provenance = switch (textPlan) {
    ActionStagedParseJobDirectSpanPlan(:final source, :final index) =>
      _directRuntimeRecord(
        authority: authority,
        registers: registers,
        origin: origin,
        source: source,
        index: index,
      ),
    ActionStagedParseJobDerivedTextPlan(:final segments) => <String, Object?>{
      'kind': 'derived_text',
      'policy': ActionStagedParseJobDerivedTextPlan.policy,
      'segments': <Object?>[
        for (final segment in segments)
          _directRuntimeRecord(
            authority: authority,
            registers: registers,
            origin: origin,
            source: segment.source,
            index: segment.index,
          ),
      ],
    },
  };
  final materialized = validateAndMaterializeStagedProvenance(
    authority: authority,
    record: provenance,
    origin: origin,
  );
  final sidecar = <String, Object?>{
    'kind': ActionStagedParseJobExpr.sidecarKind,
    'version': ActionStagedParseJobExpr.version,
    'state': 'declared',
    'effect': ActionStagedParseJobExpr.effect,
    'node_kind': options.nodeKind,
    'payload_kind': options.payloadKind,
    'parser_spec_id': options.spec,
    if (options.top != null) 'top_rule': options.top,
    'result_policy': options.resultPolicy,
    if (options.into != null) 'into': options.into,
    'failure_policy': options.onError,
    'required_capabilities': List<String>.of(options.requiredCapabilities),
    'text': materialized['text'],
    'provenance': materialized['provenance'],
    'origin': origin,
  };
  return <String, Object?>{
    'kind': 'STAGED_PARSE_JOB_MARKER',
    'version': ActionStagedParseJobExpr.version,
    'sidecar_kind': ActionStagedParseJobExpr.sidecarKind,
    'effect': ActionStagedParseJobExpr.effect,
    ActionStagedParseJobExpr.sidecarKind: sidecar,
  };
}

({Span span, Map<String, Object?> detached, String sourceId, String provenance})
_typedDirectSpan(SourceAuthority authority, Object? record, String origin) {
  final object = record is Map ? record : const <Object?, Object?>{};
  final sourceId = object['source_id'] is String
      ? object['source_id']! as String
      : '<runtime>';
  final provenance = object['provenance'] is String
      ? object['provenance']! as String
      : '<invalid>';
  if (!_hasExactKeys(object, const <String>[
        'kind',
        'source_id',
        'start',
        'end',
        'provenance',
      ]) ||
      object['kind'] != 'direct_span' ||
      provenance.isEmpty ||
      object['start'] is! int ||
      object['end'] is! int) {
    throw StagedParseJobDeclarationException.provenance(
      origin: origin,
      sourceId: sourceId,
      provenance: provenance,
    );
  }
  try {
    final start = authority.position(
      sourceId: sourceId,
      offset: object['start']! as int,
      context: _context(origin),
    );
    final end = authority.position(
      sourceId: sourceId,
      offset: object['end']! as int,
      context: _context(origin),
    );
    final span = authority.directSpan(
      start: start,
      end: end,
      provenance: provenance,
      context: _context(origin),
    );
    return (
      span: span,
      detached: <String, Object?>{'kind': 'direct_span', ...span.toJson()},
      sourceId: sourceId,
      provenance: provenance,
    );
  } on SourceLocationException {
    throw StagedParseJobDeclarationException.provenance(
      origin: origin,
      sourceId: sourceId,
      provenance: provenance,
    );
  }
}

Map<String, Object?> _directRuntimeRecord({
  required SourceAuthority authority,
  required RuntimeMatchRegisters registers,
  required String origin,
  required String source,
  required int? index,
}) {
  final match = switch (source) {
    'entry_text' || 'entry_group' => registers.entryMatch,
    'match_text' || 'match_group' => registers.localMatch,
    _ => null,
  };
  final range = switch ((source, index, match)) {
    ('entry_text' || 'match_text', null, final RuntimeRegexMatch value) => (
      start: value.codeUnitStart,
      end: value.codeUnitEnd,
    ),
    (
      'entry_group' || 'match_group',
      final int captureIndex,
      final RuntimeRegexMatch value,
    ) =>
      stagedCaptureCodeUnitSpan(value, captureIndex),
    _ => null,
  };
  if (range == null) {
    throw StagedParseJobDeclarationException.provenance(
      origin: origin,
      sourceId: _sourceId,
      provenance: source,
    );
  }
  try {
    final start = authority.positionFromCodeUnit(
      sourceId: _sourceId,
      codeUnitOffset: range.start,
      context: _context(origin),
    );
    final end = authority.positionFromCodeUnit(
      sourceId: _sourceId,
      codeUnitOffset: range.end,
      context: _context(origin),
    );
    final span = authority.directSpan(
      start: start,
      end: end,
      provenance: source,
      context: _context(origin),
    );
    return <String, Object?>{'kind': 'direct_span', ...span.toJson()};
  } on SourceLocationException {
    throw StagedParseJobDeclarationException.provenance(
      origin: origin,
      sourceId: _sourceId,
      provenance: source,
    );
  }
}

bool _hasExactKeys(Map<Object?, Object?> object, List<String> expected) {
  return object.length == expected.length && expected.every(object.containsKey);
}

SourceLocationContext _context(String origin) => SourceLocationContext(
  ruleRole: origin,
  invocationRole: ActionStagedParseJobExpr.effect,
);
