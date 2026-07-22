import 'dart:convert';
import 'dart:typed_data';

import '../action/action_ast.dart'
    show
        ActionArrayLiteralExpr,
        ActionAssignScalarExpr,
        ActionBlock,
        ActionBlockValueExpr,
        ActionBooleanLiteralExpr,
        ActionCallExpr,
        ActionExpr,
        ActionFluentChainExpr,
        ActionHashLiteralExpr,
        ActionNumberLiteralExpr,
        ActionStringLiteralExpr,
        ActionUndefExpr,
        ActionVariableExpr;
import '../action/action_parser.dart' show parseActionBlock;
import '../action/action_contracts.dart' show resolveActionBlockContracts;
import '../action/function_registry.dart'
    show UserFunctionEntry, UserFunctionRegistry;
import '../ast/spec_ast.dart'
    show
        ActionEdgeBodyElementKind,
        BareEdgeBodyElementKind,
        BlindEdgeBodyElementKind,
        BodyElement,
        CodeBlockBodyElementKind,
        LifecycleMarkerBodyElementKind,
        RegexBodyElementKind,
        Rule,
        RuleMode,
        SpecFile;
import '../compiler/compiled_spec.dart'
    show
        CompiledActionEdge,
        CompiledActionPayload,
        CompiledBlindEdge,
        CompiledRule,
        CompiledSpec,
        CompiledSpecException,
        EntryRuleSelectionException,
        compileSpec;
import '../parser/spec_parser.dart' show SpecParseException;
import '../parser/unicode_rule_label.dart' show isRuleLabel;
import '../parser/user_function_definition_parser.dart'
    show parseSpecWithStagedUserFunctionDefinitions;
import '../source_emitter.dart'
    show
        buildGeneratedRulePlan,
        linkedSpecGeneratedSourceContract,
        linkedSpecGeneratedSourceFormatVersion;
import '../validation/spec_validator.dart'
    show SpecPortableDiagnostic, SpecValidationException, validateSpec;
import 'sha256.dart' show sha256Hex;

part 'semantic_static_projection.dart';
part 'semantic_call_projection.dart';

const _semanticSnapshotId = 'snapshot:0';
const _semanticSourceId = 'source:0';

/// Maximum caller-selected source detail that this index may disclose.
enum SemanticSourceDetail {
  none('none'),
  identity('identity'),
  span('span'),
  text('text');

  const SemanticSourceDetail(this.wireName);

  final String wireName;
}

/// Required caller-owned policy for one immutable semantic snapshot.
final class SemanticIndexOptions {
  const SemanticIndexOptions({
    required this.logicalName,
    required this.sourceDetailCeiling,
    this.entryRule,
  });

  final String logicalName;
  final SemanticSourceDetail sourceDetailCeiling;
  final String? entryRule;
}

/// Stable constructor or source-map failure before semantic projection.
final class SemanticIndexError implements Exception {
  SemanticIndexError({
    required this.stage,
    required this.code,
    required this.message,
    Map<String, Object?> fields = const {},
  }) : fields = _immutableFields(fields);

  final String stage;
  final String code;
  final String message;
  final Map<String, Object?> fields;

  Map<String, Object?> toJson() => <String, Object?>{
    'stage': stage,
    'code': code,
    'message': message,
    'fields': _detachedFields(fields),
  };

  @override
  String toString() => '$code at $stage: $message';
}

/// Caller-registered source identity with no implicit filesystem path.
final class SemanticSourceIdentity {
  const SemanticSourceIdentity({
    required this.sourceId,
    required this.logicalName,
    required this.byteLength,
    required this.scalarLength,
    required this.contentDigest,
  });

  final String sourceId;
  final String logicalName;
  final int byteLength;
  final int scalarLength;
  final String? contentDigest;

  Map<String, Object?> toJson() => {
    'source_id': sourceId,
    'logical_name': logicalName,
    'byte_length': byteLength,
    'scalar_length': scalarLength,
    'content_digest': contentDigest,
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticSourceIdentity &&
      other.sourceId == sourceId &&
      other.logicalName == logicalName &&
      other.byteLength == byteLength &&
      other.scalarLength == scalarLength &&
      other.contentDigest == contentDigest;

  @override
  int get hashCode => Object.hash(
    sourceId,
    logicalName,
    byteLength,
    scalarLength,
    contentDigest,
  );
}

/// Exact zero-based byte / one-based line-and-scalar-column span.
final class SemanticSourceSpan {
  const SemanticSourceSpan({
    required this.startByte,
    required this.endByte,
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
  });

  final int startByte;
  final int endByte;
  final int startLine;
  final int startColumn;
  final int endLine;
  final int endColumn;

  Map<String, Object?> toJson() => {
    'start_byte': startByte,
    'end_byte': endByte,
    'start_line': startLine,
    'start_column': startColumn,
    'end_line': endLine,
    'end_column': endColumn,
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticSourceSpan &&
      other.startByte == startByte &&
      other.endByte == endByte &&
      other.startLine == startLine &&
      other.startColumn == startColumn &&
      other.endLine == endLine &&
      other.endColumn == endColumn;

  @override
  int get hashCode => Object.hash(
    startByte,
    endByte,
    startLine,
    startColumn,
    endLine,
    endColumn,
  );
}

/// Immutable compilation state for one semantic snapshot.
enum SemanticSnapshotState {
  compiled('compiled'),
  failedCompilation('failed_compilation');

  const SemanticSnapshotState(this.wireName);

  final String wireName;
}

/// Clone-safe foundation metadata; this is not a query response.
final class SemanticSnapshot {
  const SemanticSnapshot({
    required this.id,
    required this.state,
    required this.hasExecution,
    required this.sourceDetailCeiling,
    required this.contentDigestAvailable,
  });

  final String id;
  final SemanticSnapshotState state;
  final bool hasExecution;
  final SemanticSourceDetail sourceDetailCeiling;
  final bool contentDigestAvailable;

  Map<String, Object?> toJson() => {
    'id': id,
    'state': state.wireName,
    'has_execution': hasExecution,
    'source_detail_ceiling': sourceDetailCeiling.wireName,
    'content_digest_available': contentDigestAvailable,
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticSnapshot &&
      other.id == id &&
      other.state == state &&
      other.hasExecution == hasExecution &&
      other.sourceDetailCeiling == sourceDetailCeiling &&
      other.contentDigestAvailable == contentDigestAvailable;

  @override
  int get hashCode => Object.hash(
    id,
    state,
    hasExecution,
    sourceDetailCeiling,
    contentDigestAvailable,
  );
}

/// Presence-only view of private parser/compiler authority.
final class SemanticCompilationAuthority {
  const SemanticCompilationAuthority({
    required this.parsed,
    required this.validated,
    required this.compiled,
  });

  final bool parsed;
  final bool validated;
  final bool compiled;

  Map<String, Object?> toJson() => {
    'parsed': parsed,
    'validated': validated,
    'compiled': compiled,
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticCompilationAuthority &&
      other.parsed == parsed &&
      other.validated == validated &&
      other.compiled == compiled;

  @override
  int get hashCode => Object.hash(parsed, validated, compiled);
}

/// Detached portable failure retained when language construction fails.
final class SemanticCompilationDiagnostic {
  SemanticCompilationDiagnostic({
    required this.code,
    required this.stage,
    required this.message,
    Map<String, Object?> fields = const {},
  }) : fields = _immutableFields(fields);

  final String code;
  final String stage;
  final String message;
  final Map<String, Object?> fields;

  Map<String, Object?> toJson() => {
    'code': code,
    'stage': stage,
    'message': message,
    'fields': _detachedFields(fields),
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticCompilationDiagnostic &&
      other.code == code &&
      other.stage == stage &&
      other.message == message &&
      _plainValuesEqual(other.fields, fields);

  @override
  int get hashCode =>
      Object.hash(code, stage, message, _plainValueHash(fields));
}

/// Effective entry selection retained as identity, not compiled rule state.
final class SemanticEntrySelection {
  const SemanticEntrySelection({required this.label, required this.basis});

  final String label;
  final String basis;

  Map<String, Object?> toJson() => {'label': label, 'basis': basis};

  @override
  bool operator ==(Object other) =>
      other is SemanticEntrySelection &&
      other.label == label &&
      other.basis == basis;

  @override
  int get hashCode => Object.hash(label, basis);
}

/// One immutable generated-source-v2 plan row.
final class SemanticGeneratedPlanRow {
  const SemanticGeneratedPlanRow({required this.label, required this.family});

  final String label;
  final String family;

  Map<String, Object?> toJson() => {'label': label, 'family': family};

  @override
  bool operator ==(Object other) =>
      other is SemanticGeneratedPlanRow &&
      other.label == label &&
      other.family == family;

  @override
  int get hashCode => Object.hash(label, family);
}

/// Shared generated-v2 input retained without generated implementation source.
final class SemanticGeneratedPlanInput {
  SemanticGeneratedPlanInput({
    required this.contractId,
    required this.formatVersion,
    required this.sourceIdentity,
    required List<SemanticGeneratedPlanRow> rows,
  }) : rows = List.unmodifiable(rows);

  final String contractId;
  final int formatVersion;
  final String sourceIdentity;
  final List<SemanticGeneratedPlanRow> rows;

  Map<String, Object?> toJson() => {
    'contract_id': contractId,
    'format_version': formatVersion,
    'source_identity': sourceIdentity,
    'rows': [for (final row in rows) row.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticGeneratedPlanInput &&
      other.contractId == contractId &&
      other.formatVersion == formatVersion &&
      other.sourceIdentity == sourceIdentity &&
      _listsEqual(other.rows, rows);

  @override
  int get hashCode => Object.hash(
    contractId,
    formatVersion,
    sourceIdentity,
    Object.hashAll(rows),
  );
}

/// Opaque immutable semantic source and compiled-or-failed foundation.
///
/// Construction copies caller input, normalizes it to canonical strict UTF-8,
/// builds exact byte/scalar coordinates, and retains one private staged
/// parse/validation/compilation outcome. It performs no target execution, path
/// resolution, semantic query, or host-state capture.
final class SemanticIndex {
  SemanticIndex._({
    required String sourceText,
    required Uint8List sourceBytes,
    required String logicalName,
    required SemanticSourceDetail sourceDetailCeiling,
    required List<int> scalars,
    required _SemanticCompilationOutcome compilationOutcome,
  }) : _sourceText = sourceText,
       _sourceBytes = sourceBytes,
       _logicalName = logicalName,
       _sourceDetailCeiling = sourceDetailCeiling,
       _sourceMap = _SemanticSourceMap(scalars),
       _contentDigest = 'sha256:${sha256Hex(sourceBytes)}',
       _compilationOutcome = compilationOutcome {
    _staticProjection = _buildSemanticStaticProjection(
      sourceText: _sourceText,
      sourceMap: _sourceMap,
      logicalName: _logicalName,
      contentDigest: _contentDigest,
      snapshot: snapshot,
      outcome: _compilationOutcome,
    );
  }

  /// Capture already decoded Unicode text and copy its canonical UTF-8 form.
  factory SemanticIndex.fromSource(
    String source, {
    required SemanticIndexOptions options,
  }) {
    _validateOptions(options);
    final scalars = _strictScalars(
      source,
      stage: 'decode_source',
      code: 'semantic_index_invalid_unicode',
      message: 'Semantic index source is not valid Unicode scalar text',
    );
    final copiedText = String.fromCharCodes(scalars);
    final copiedBytes = Uint8List.fromList(utf8.encode(copiedText));
    return SemanticIndex._(
      sourceText: copiedText,
      sourceBytes: copiedBytes,
      logicalName: options.logicalName,
      sourceDetailCeiling: options.sourceDetailCeiling,
      scalars: scalars,
      compilationOutcome: _compileSemanticSource(copiedText, options),
    );
  }

  /// Strictly decode and copy UTF-8 bytes before any language parsing.
  factory SemanticIndex.fromUtf8(
    List<int> source, {
    required SemanticIndexOptions options,
  }) {
    _validateOptions(options);
    for (var index = 0; index < source.length; index += 1) {
      final byte = source[index];
      if (byte < 0 || byte > 0xFF) {
        throw SemanticIndexError(
          stage: 'validate_source',
          code: 'semantic_index_invalid_source',
          message: 'Semantic index byte input contains a value outside 0..255',
          fields: {'byte_index': index, 'value': byte},
        );
      }
    }
    final copiedBytes = Uint8List.fromList(source);
    final String sourceText;
    try {
      sourceText = utf8.decode(copiedBytes, allowMalformed: false);
    } on FormatException catch (error) {
      throw SemanticIndexError(
        stage: 'decode_source',
        code: 'semantic_index_invalid_utf8',
        message: 'Semantic index source is not valid UTF-8',
        fields: {if (error.offset != null) 'offset': error.offset},
      );
    }
    final scalars = _strictScalars(
      sourceText,
      stage: 'decode_source',
      code: 'semantic_index_invalid_utf8',
      message: 'Semantic index source is not valid UTF-8',
    );
    return SemanticIndex._(
      sourceText: sourceText,
      sourceBytes: copiedBytes,
      logicalName: options.logicalName,
      sourceDetailCeiling: options.sourceDetailCeiling,
      scalars: scalars,
      compilationOutcome: _compileSemanticSource(sourceText, options),
    );
  }

  final String _sourceText;
  final Uint8List _sourceBytes;
  final String _logicalName;
  final SemanticSourceDetail _sourceDetailCeiling;
  final _SemanticSourceMap _sourceMap;
  final String _contentDigest;
  final _SemanticCompilationOutcome _compilationOutcome;
  late final _SemanticStaticProjection _staticProjection;

  /// Return fresh foundation metadata without semantic records or queries.
  SemanticSnapshot get snapshot => SemanticSnapshot(
    id: _semanticSnapshotId,
    state: _compilationOutcome.compiled == null
        ? SemanticSnapshotState.failedCompilation
        : SemanticSnapshotState.compiled,
    hasExecution: false,
    sourceDetailCeiling: _sourceDetailCeiling,
    contentDigestAvailable: _sourceDetailCeiling == SemanticSourceDetail.text,
  );

  /// Return only presence bits for the retained private compiler authority.
  SemanticCompilationAuthority get compilationAuthority =>
      SemanticCompilationAuthority(
        parsed: _compilationOutcome.parsed != null,
        validated: _compilationOutcome.validated,
        compiled: _compilationOutcome.compiled != null,
      );

  /// Return a detached portable language failure, when construction failed.
  SemanticCompilationDiagnostic? get compilationDiagnostic {
    final diagnostic = _compilationOutcome.diagnostic;
    if (diagnostic == null) {
      return null;
    }
    return SemanticCompilationDiagnostic(
      code: diagnostic.code,
      stage: diagnostic.stage,
      message: diagnostic.message,
      fields: diagnostic.fields,
    );
  }

  /// Return resolved entry identity without exposing a compiled rule.
  SemanticEntrySelection? get entrySelection => _compilationOutcome.entry;

  /// Return the shared generated-v2 plan without compiled host state.
  SemanticGeneratedPlanInput? get generatedPlan {
    _requireSourceDetail(SemanticSourceDetail.identity);
    final plan = _compilationOutcome.generatedPlan;
    if (plan == null) {
      return null;
    }
    return SemanticGeneratedPlanInput(
      contractId: plan.contractId,
      formatVersion: plan.formatVersion,
      sourceIdentity: plan.sourceIdentity,
      rows: plan.rows,
    );
  }

  /// Return copied caller identity and exact source sizes without a host path.
  SemanticSourceIdentity get sourceIdentity {
    _requireSourceDetail(SemanticSourceDetail.identity);
    return SemanticSourceIdentity(
      sourceId: _semanticSourceId,
      logicalName: _logicalName,
      byteLength: _sourceBytes.length,
      scalarLength: _sourceMap.scalarLength,
      contentDigest: _sourceDetailCeiling == SemanticSourceDetail.text
          ? _contentDigest
          : null,
    );
  }

  /// Map an exact strict-UTF-8 byte range.
  SemanticSourceSpan sourceSpanForBytes(int start, int end) {
    _requireSourceDetail(SemanticSourceDetail.span);
    return _sourceMap.spanForByteRange(start, end);
  }

  /// Map an exact Unicode-scalar range.
  SemanticSourceSpan sourceSpanForScalars(int start, int end) {
    _requireSourceDetail(SemanticSourceDetail.span);
    return _sourceMap.spanForScalarRange(start, end);
  }

  /// Return exact decoded source text for one strict byte range.
  String sourceExcerptForBytes(int start, int end) {
    _requireSourceDetail(SemanticSourceDetail.text);
    final scalarRange = _sourceMap.scalarRangeForBytes(start, end);
    return _sourceText.substring(
      _sourceMap.codeUnitAtScalar(scalarRange.$1),
      _sourceMap.codeUnitAtScalar(scalarRange.$2),
    );
  }

  /// Locate one exact decoded occurrence at or after an exact byte boundary.
  SemanticSourceSpan? locateExact(String needle, {int afterByte = 0}) {
    _requireSourceDetail(SemanticSourceDetail.span);
    if (needle.isEmpty) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_needle_invalid',
        message: 'Source lookup needle must not be empty',
      );
    }
    final needleScalars = _strictScalars(
      needle,
      stage: 'map_source',
      code: 'semantic_source_needle_invalid',
      message: 'Source lookup needle must be valid Unicode scalar text',
    );
    _sourceMap.spanForByteRange(afterByte, afterByte);
    final needleBytes = utf8.encode(String.fromCharCodes(needleScalars));
    final start = _indexOfBytes(_sourceBytes, needleBytes, afterByte);
    if (start == null) {
      return null;
    }
    return _sourceMap.spanForByteRange(start, start + needleBytes.length);
  }

  void _requireSourceDetail(SemanticSourceDetail required) {
    if (_sourceDetailCeiling.index >= required.index) {
      return;
    }
    throw SemanticIndexError(
      stage: 'apply_source_ceiling',
      code: 'semantic_source_detail_forbidden',
      message: 'Requested source detail exceeds the semantic index ceiling',
      fields: {
        'ceiling': _sourceDetailCeiling.wireName,
        'required': required.wireName,
      },
    );
  }

  @override
  String toString() =>
      'SemanticIndex(sourceId: $_semanticSourceId, '
      'state: ${snapshot.state.wireName}, '
      'sourceDetailCeiling: ${_sourceDetailCeiling.wireName})';
}

final class _SemanticCompilationOutcome {
  const _SemanticCompilationOutcome({
    required this.parsed,
    required this.validated,
    required this.compiled,
    required this.diagnostic,
    required this.entry,
    required this.generatedPlan,
  });

  final SpecFile? parsed;
  final bool validated;
  final CompiledSpec? compiled;
  final SemanticCompilationDiagnostic? diagnostic;
  final SemanticEntrySelection? entry;
  final SemanticGeneratedPlanInput? generatedPlan;
}

_SemanticCompilationOutcome _compileSemanticSource(
  String source,
  SemanticIndexOptions options,
) {
  final SpecFile parsed;
  try {
    parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  } on Object catch (error) {
    return _failedCompilation(
      diagnostic: _languageDiagnostic(
        error,
        fallbackCode: 'semantic_index_parse_failed',
        fallbackStage: 'parse_source',
      ),
    );
  }

  try {
    validateSpec(parsed);
  } on Object catch (error) {
    return _failedCompilation(
      parsed: parsed,
      diagnostic: _languageDiagnostic(
        error,
        fallbackCode: 'semantic_index_validation_failed',
        fallbackStage: 'validate_source',
      ),
    );
  }

  final CompiledSpec candidate;
  try {
    candidate = compileSpec(parsed, validateSource: false);
  } on Object catch (error) {
    return _failedCompilation(
      parsed: parsed,
      validated: true,
      diagnostic: _languageDiagnostic(
        error,
        fallbackCode: 'semantic_index_compilation_failed',
        fallbackStage: 'compile_source',
      ),
    );
  }

  final SemanticEntrySelection entry;
  try {
    final selected = candidate.resolveEntryRule(options.entryRule);
    entry = SemanticEntrySelection(
      label: selected.rule.label,
      basis: selected.basis.contractName,
    );
  } on Object catch (error) {
    return _failedCompilation(
      parsed: parsed,
      validated: true,
      diagnostic: _languageDiagnostic(
        error,
        fallbackCode: 'semantic_index_entry_selection_failed',
        fallbackStage: 'select_entry_rule',
      ),
    );
  }

  final SemanticGeneratedPlanInput generatedPlan;
  try {
    final rows = buildGeneratedRulePlan(candidate);
    generatedPlan = SemanticGeneratedPlanInput(
      contractId: linkedSpecGeneratedSourceContract,
      formatVersion: linkedSpecGeneratedSourceFormatVersion,
      sourceIdentity: options.logicalName,
      rows: [
        for (final row in rows)
          SemanticGeneratedPlanRow(label: row.label, family: row.family),
      ],
    );
  } on Object catch (error) {
    return _failedCompilation(
      parsed: parsed,
      validated: true,
      diagnostic: _languageDiagnostic(
        error,
        fallbackCode: 'semantic_index_generated_plan_failed',
        fallbackStage: 'build_generated_plan',
      ),
    );
  }

  return _SemanticCompilationOutcome(
    parsed: parsed,
    validated: true,
    compiled: candidate,
    diagnostic: null,
    entry: entry,
    generatedPlan: generatedPlan,
  );
}

_SemanticCompilationOutcome _failedCompilation({
  SpecFile? parsed,
  bool validated = false,
  required SemanticCompilationDiagnostic diagnostic,
}) => _SemanticCompilationOutcome(
  parsed: parsed,
  validated: validated,
  compiled: null,
  diagnostic: diagnostic,
  entry: null,
  generatedPlan: null,
);

SemanticCompilationDiagnostic _languageDiagnostic(
  Object error, {
  required String fallbackCode,
  required String fallbackStage,
}) {
  if (error is SpecValidationException && error.diagnostic != null) {
    return _semanticDiagnostic(error.diagnostic!);
  }
  if (error is EntryRuleSelectionException) {
    return SemanticCompilationDiagnostic(
      code: error.code,
      stage: error.stage,
      message: error.message,
      fields: {if (error.entryRule != null) 'entry_rule': error.entryRule},
    );
  }

  final fields = <String, Object?>{};
  final String message;
  if (error is SpecParseException) {
    fields['line'] = error.line;
    message = error.message;
  } else if (error is SpecValidationException) {
    message = error.message;
  } else if (error is CompiledSpecException) {
    message = error.message;
  } else if (error is FormatException) {
    message = error.message;
    if (error.offset != null) {
      fields['offset'] = error.offset;
    }
  } else {
    message = error.toString();
  }
  return SemanticCompilationDiagnostic(
    code: fallbackCode,
    stage: fallbackStage,
    message: message,
    fields: fields,
  );
}

SemanticCompilationDiagnostic _semanticDiagnostic(
  SpecPortableDiagnostic diagnostic,
) => SemanticCompilationDiagnostic(
  code: diagnostic.code,
  stage: diagnostic.stage,
  message: diagnostic.message,
  fields: diagnostic.fields,
);

final class _SemanticSourceMap {
  _SemanticSourceMap(List<int> scalars) {
    final byteAtScalar = <int>[0];
    final codeUnitAtScalar = <int>[0];
    final lineAtScalar = <int>[1];
    final columnAtScalar = <int>[1];
    var byteOffset = 0;
    var codeUnitOffset = 0;
    var line = 1;
    var column = 1;

    for (final scalar in scalars) {
      byteOffset += _utf8Width(scalar);
      codeUnitOffset += scalar > 0xFFFF ? 2 : 1;
      if (scalar == 0x0A) {
        line += 1;
        column = 1;
      } else {
        column += 1;
      }
      byteAtScalar.add(byteOffset);
      codeUnitAtScalar.add(codeUnitOffset);
      lineAtScalar.add(line);
      columnAtScalar.add(column);
    }

    _byteAtScalar = List.unmodifiable(byteAtScalar);
    _codeUnitAtScalar = List.unmodifiable(codeUnitAtScalar);
    _lineAtScalar = List.unmodifiable(lineAtScalar);
    _columnAtScalar = List.unmodifiable(columnAtScalar);
  }

  late final List<int> _byteAtScalar;
  late final List<int> _codeUnitAtScalar;
  late final List<int> _lineAtScalar;
  late final List<int> _columnAtScalar;

  int get scalarLength => _byteAtScalar.length - 1;

  int codeUnitAtScalar(int scalar) => _codeUnitAtScalar[scalar];

  SemanticSourceSpan spanForScalarRange(int start, int end) {
    if (start < 0 || start > end || end > scalarLength) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_range_invalid',
        message: 'Source scalar range is outside the captured source',
        fields: {'start_scalar': start, 'end_scalar': end},
      );
    }
    return _spanForScalarBoundaries(start, end);
  }

  SemanticSourceSpan spanForByteRange(int start, int end) {
    final scalarRange = scalarRangeForBytes(start, end);
    return _spanForScalarBoundaries(scalarRange.$1, scalarRange.$2);
  }

  SemanticSourceSpan spanForCodeUnitRange(int start, int end) {
    final scalarRange = scalarRangeForCodeUnits(start, end);
    return _spanForScalarBoundaries(scalarRange.$1, scalarRange.$2);
  }

  (int, int) scalarRangeForBytes(int start, int end) {
    if (start < 0 || start > end || end > _byteAtScalar.last) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_range_invalid',
        message: 'Source byte range is outside the captured source',
        fields: {'start_byte': start, 'end_byte': end},
      );
    }
    final startScalar = _boundaryIndex(_byteAtScalar, start);
    if (startScalar == null) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_boundary_invalid',
        message: 'Source byte range starts inside a UTF-8 scalar',
        fields: {'start_byte': start},
      );
    }
    final endScalar = _boundaryIndex(_byteAtScalar, end);
    if (endScalar == null) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_boundary_invalid',
        message: 'Source byte range ends inside a UTF-8 scalar',
        fields: {'end_byte': end},
      );
    }
    return (startScalar, endScalar);
  }

  (int, int) scalarRangeForCodeUnits(int start, int end) {
    if (start < 0 || start > end || end > _codeUnitAtScalar.last) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_range_invalid',
        message: 'Source code-unit range is outside the captured source',
        fields: {'start_code_unit': start, 'end_code_unit': end},
      );
    }
    final startScalar = _boundaryIndex(_codeUnitAtScalar, start);
    final endScalar = _boundaryIndex(_codeUnitAtScalar, end);
    if (startScalar == null || endScalar == null) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_boundary_invalid',
        message: 'Source code-unit range splits a Unicode scalar',
        fields: {
          if (startScalar == null) 'start_code_unit': start,
          if (endScalar == null) 'end_code_unit': end,
        },
      );
    }
    return (startScalar, endScalar);
  }

  SemanticSourceSpan _spanForScalarBoundaries(int start, int end) {
    return SemanticSourceSpan(
      startByte: _byteAtScalar[start],
      endByte: _byteAtScalar[end],
      startLine: _lineAtScalar[start],
      startColumn: _columnAtScalar[start],
      endLine: _lineAtScalar[end],
      endColumn: _columnAtScalar[end],
    );
  }
}

Map<String, Object?> _immutableFields(Map<String, Object?> fields) =>
    Map.unmodifiable(
      Map.fromEntries(
        (fields.entries.toList()
              ..sort((left, right) => left.key.compareTo(right.key)))
            .map(
              (entry) => MapEntry(entry.key, _immutablePlainValue(entry.value)),
            ),
      ),
    );

Map<String, Object?> _detachedFields(Map<String, Object?> fields) => {
  for (final entry in fields.entries)
    entry.key: _detachedPlainValue(entry.value),
};

Object? _immutablePlainValue(Object? value) {
  if (value is Map) {
    return Map<String, Object?>.unmodifiable({
      for (final entry in value.entries)
        entry.key.toString(): _immutablePlainValue(entry.value),
    });
  }
  if (value is List) {
    return List<Object?>.unmodifiable([
      for (final item in value) _immutablePlainValue(item),
    ]);
  }
  return value;
}

Object? _detachedPlainValue(Object? value) {
  if (value is Map) {
    return <String, Object?>{
      for (final entry in value.entries)
        entry.key.toString(): _detachedPlainValue(entry.value),
    };
  }
  if (value is List) {
    return <Object?>[for (final item in value) _detachedPlainValue(item)];
  }
  return value;
}

bool _plainValuesEqual(Object? left, Object? right) {
  if (identical(left, right)) {
    return true;
  }
  if (left is Map && right is Map) {
    if (left.length != right.length) {
      return false;
    }
    for (final entry in left.entries) {
      if (!right.containsKey(entry.key) ||
          !_plainValuesEqual(entry.value, right[entry.key])) {
        return false;
      }
    }
    return true;
  }
  if (left is List && right is List) {
    return _listsEqual(left, right, equals: _plainValuesEqual);
  }
  return left == right;
}

int _plainValueHash(Object? value) {
  if (value is Map) {
    final entries = value.entries.toList()
      ..sort(
        (left, right) => left.key.toString().compareTo(right.key.toString()),
      );
    return Object.hashAll([
      for (final entry in entries)
        Object.hash(entry.key, _plainValueHash(entry.value)),
    ]);
  }
  if (value is List) {
    return Object.hashAll(value.map(_plainValueHash));
  }
  return value.hashCode;
}

bool _listsEqual<T>(
  List<T> left,
  List<T> right, {
  bool Function(T left, T right)? equals,
}) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (!(equals?.call(left[index], right[index]) ??
        left[index] == right[index])) {
      return false;
    }
  }
  return true;
}

void _validateOptions(SemanticIndexOptions options) {
  final nameScalars = _strictScalars(
    options.logicalName,
    stage: 'validate_options',
    code: 'semantic_index_invalid_option',
    message: 'Semantic index logical name must be valid Unicode scalar text',
    fieldName: 'option',
    fieldValue: 'logical_name',
  );
  if (nameScalars.isEmpty || nameScalars.any(_isControlScalar)) {
    throw SemanticIndexError(
      stage: 'validate_options',
      code: 'semantic_index_invalid_option',
      message:
          'Semantic index logical name must be nonempty and contain no '
          'control characters',
      fields: {'option': 'logical_name'},
    );
  }
  final entryRule = options.entryRule;
  if (entryRule != null && !isRuleLabel(entryRule)) {
    throw SemanticIndexError(
      stage: 'validate_options',
      code: 'semantic_index_invalid_option',
      message: 'Semantic index entry rule must be a valid rule label',
      fields: {'option': 'entry_rule'},
    );
  }
}

List<int> _strictScalars(
  String value, {
  required String stage,
  required String code,
  required String message,
  String fieldName = 'code_unit_offset',
  Object? fieldValue,
}) {
  final scalars = <int>[];
  var index = 0;
  while (index < value.length) {
    final first = value.codeUnitAt(index);
    if (first >= 0xD800 && first <= 0xDBFF) {
      if (index + 1 >= value.length) {
        throw SemanticIndexError(
          stage: stage,
          code: code,
          message: message,
          fields: {fieldName: fieldValue ?? index},
        );
      }
      final second = value.codeUnitAt(index + 1);
      if (second < 0xDC00 || second > 0xDFFF) {
        throw SemanticIndexError(
          stage: stage,
          code: code,
          message: message,
          fields: {fieldName: fieldValue ?? index},
        );
      }
      scalars.add(0x10000 + ((first - 0xD800) << 10) + (second - 0xDC00));
      index += 2;
      continue;
    }
    if (first >= 0xDC00 && first <= 0xDFFF) {
      throw SemanticIndexError(
        stage: stage,
        code: code,
        message: message,
        fields: {fieldName: fieldValue ?? index},
      );
    }
    scalars.add(first);
    index += 1;
  }
  return List.unmodifiable(scalars);
}

bool _isControlScalar(int scalar) =>
    scalar <= 0x1F || (scalar >= 0x7F && scalar <= 0x9F);

int _utf8Width(int scalar) {
  if (scalar <= 0x7F) {
    return 1;
  }
  if (scalar <= 0x7FF) {
    return 2;
  }
  if (scalar <= 0xFFFF) {
    return 3;
  }
  return 4;
}

int? _boundaryIndex(List<int> boundaries, int target) {
  var low = 0;
  var high = boundaries.length - 1;
  while (low <= high) {
    final middle = low + ((high - low) ~/ 2);
    final value = boundaries[middle];
    if (value == target) {
      return middle;
    }
    if (value < target) {
      low = middle + 1;
    } else {
      high = middle - 1;
    }
  }
  return null;
}

int? _indexOfBytes(List<int> haystack, List<int> needle, int start) {
  final lastStart = haystack.length - needle.length;
  for (var candidate = start; candidate <= lastStart; candidate += 1) {
    var matched = true;
    for (var offset = 0; offset < needle.length; offset += 1) {
      if (haystack[candidate + offset] != needle[offset]) {
        matched = false;
        break;
      }
    }
    if (matched) {
      return candidate;
    }
  }
  return null;
}
