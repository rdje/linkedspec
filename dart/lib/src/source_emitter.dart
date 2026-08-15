import 'dart:convert';

import 'ast/spec_ast.dart';
import 'compiler/compiled_spec.dart';
import 'runtime/generated_plan.dart';
import 'runtime/interpreter.dart';
import 'runtime/semantic_observation.dart';
import 'trace/trace.dart';
import 'validation/spec_validator.dart';

/// Backend-neutral generated-source contract implemented by this emitter.
const linkedSpecGeneratedSourceContract = 'linkedspec-generated-source-v2';

/// Version of the generated Dart source scaffold.
const linkedSpecGeneratedSourceFormatVersion = 2;

final class _GeneratedDiagnosticOutputSinkFailure implements Exception {
  const _GeneratedDiagnosticOutputSinkFailure(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}

RuntimeDiagnosticOutputSink? _generatedDiagnosticOutputSink(
  RuntimeDiagnosticOutputSink? sink,
) {
  if (sink == null) {
    return null;
  }
  return (event) {
    try {
      sink(event);
    } on Object catch (error, stackTrace) {
      throw _GeneratedDiagnosticOutputSinkFailure(error, stackTrace);
    }
  };
}

final class _GeneratedSemanticObservationSinkFailure implements Exception {
  const _GeneratedSemanticObservationSinkFailure(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}

RuntimeSemanticObservationSink? _generatedSemanticObservationSink(
  RuntimeSemanticObservationSink? sink,
) {
  if (sink == null) {
    return null;
  }
  return (event) {
    try {
      sink(event);
    } on Object catch (error, stackTrace) {
      throw _GeneratedSemanticObservationSinkFailure(error, stackTrace);
    }
  };
}

/// Stable stage in the generated-source pipeline.
enum GeneratedSourceStage {
  emitSource('emit_source'),
  compileOrLoadGeneratedSource('compile_or_load_generated_source'),
  validateGeneratedPlan('validate_generated_plan'),
  validateCompiledRule('validate_compiled_rule'),
  validateSpec('validate_spec'),
  selectEntryRule('select_entry_rule'),
  executeRule('execute_rule'),
  executeGenerated('execute_generated');

  const GeneratedSourceStage(this.wireName);

  final String wireName;
}

/// Stable machine-readable generated-source failure code.
enum GeneratedSourceCode {
  generatedSourceEmitFailed('generated_source_emit_failed'),
  generatedSourceCompileFailed('generated_source_compile_failed'),
  generatedPlanRowCountMismatch('generated_plan_row_count_mismatch'),
  generatedPlanLabelMismatch('generated_plan_label_mismatch'),
  generatedPlanFamilyMismatch('generated_plan_family_mismatch'),
  generatedPlanUnknownFamily('generated_plan_unknown_family'),
  generatedSourceContractVersionMismatch(
    'generated_source_contract_version_mismatch',
  ),
  regexSlotIdentityInvalid('regex_slot_identity_invalid'),
  orderedRegexSlotIdentityLost('ordered_regex_slot_identity_lost'),
  noRulesDefined('no_rules_defined'),
  entryRuleNotFound('entry_rule_not_found'),
  generatedExecutionFailed('generated_execution_failed');

  const GeneratedSourceCode(this.wireName);

  final String wireName;
}

/// Portable generated-source failure with stable source attribution.
final class GeneratedSourceException implements Exception {
  const GeneratedSourceException({
    required this.stage,
    required this.code,
    required this.summary,
    required this.sourceIdentity,
    this.entryRule,
    this.ruleLabel,
    this.handlerFamily,
    this.detail,
    this.expectedContract,
    this.actualContract,
    this.targetRule,
    this.regexIndex,
    this.expectedRegexIndex,
    this.actualRegexIndex,
  });

  factory GeneratedSourceException.emitFailed(
    String sourceIdentity,
    String summary, {
    String? detail,
  }) {
    return GeneratedSourceException(
      stage: GeneratedSourceStage.emitSource,
      code: GeneratedSourceCode.generatedSourceEmitFailed,
      summary: summary,
      sourceIdentity: sourceIdentity,
      detail: detail,
    );
  }

  factory GeneratedSourceException.compileFailed(
    String sourceIdentity,
    Object detail,
  ) {
    return GeneratedSourceException(
      stage: GeneratedSourceStage.compileOrLoadGeneratedSource,
      code: GeneratedSourceCode.generatedSourceCompileFailed,
      summary: 'Generated Dart source failed to compile or load',
      sourceIdentity: sourceIdentity,
      detail: detail.toString(),
    );
  }

  factory GeneratedSourceException.executionFailed(
    String sourceIdentity,
    Object detail, {
    String? ruleLabel,
    String? handlerFamily,
  }) {
    return GeneratedSourceException(
      stage: GeneratedSourceStage.executeGenerated,
      code: GeneratedSourceCode.generatedExecutionFailed,
      summary: 'Generated Dart parser execution failed',
      sourceIdentity: sourceIdentity,
      ruleLabel: ruleLabel,
      handlerFamily: handlerFamily,
      detail: detail.toString(),
    );
  }

  final GeneratedSourceStage stage;
  final GeneratedSourceCode code;
  final String summary;
  final String sourceIdentity;
  final String? entryRule;
  final String? ruleLabel;
  final String? handlerFamily;
  final String? detail;
  final String? expectedContract;
  final String? actualContract;
  final String? targetRule;
  final int? regexIndex;
  final int? expectedRegexIndex;
  final int? actualRegexIndex;

  JsonObject toJson() {
    return {
      'type': 'generated_source_error',
      'stage': stage.wireName,
      'code': code.wireName,
      'summary': summary,
      'source_identity': sourceIdentity,
      if (entryRule != null) 'entry_rule': entryRule,
      if (ruleLabel != null) 'rule_label': ruleLabel,
      if (handlerFamily != null) 'handler_family': handlerFamily,
      if (detail != null) 'detail': detail,
      if (expectedContract != null) 'expected_contract': expectedContract,
      if (actualContract != null) 'actual_contract': actualContract,
      if (targetRule != null) 'target_rule': targetRule,
      if (regexIndex != null) 'regex_index': regexIndex,
      if (expectedRegexIndex != null)
        'expected_regex_index': expectedRegexIndex,
      if (actualRegexIndex != null) 'actual_regex_index': actualRegexIndex,
    };
  }

  @override
  String toString() {
    if (detail == null) {
      return summary;
    }
    return '$summary: $detail';
  }
}

/// Public metadata embedded in and returned by generated Dart libraries.
final class GeneratedSourceMetadata {
  const GeneratedSourceMetadata({required this.sourceIdentity});

  final String sourceIdentity;

  String get contractId => linkedSpecGeneratedSourceContract;

  int get formatVersion => linkedSpecGeneratedSourceFormatVersion;

  String get regexSlotIdentityContract => linkedSpecRegexSlotIdentityContract;

  JsonObject toJson() {
    return {
      'contract_id': contractId,
      'format_version': formatVersion,
      'source_identity': sourceIdentity,
    };
  }
}

/// Classify one compiled rule into the exact contract-v2 structural family.
GeneratedRuleFamily classifyGeneratedRuleFamily(CompiledRule rule) {
  final mode = rule.modeMetadata.name;
  final isRepetition = switch (mode) {
    'Plus' ||
    'Star' ||
    'Optional' ||
    'Or' ||
    'OrPlus' ||
    'AndPlus' ||
    'OrBounded' ||
    'AndBounded' => true,
    _ => false,
  };

  if (isRepetition) {
    if (rule.blindEdges.isNotEmpty) {
      return rule.modeMetadata.isAnd
          ? GeneratedRuleFamily.repAndBcode
          : GeneratedRuleFamily.repBcode;
    }
    return rule.modeMetadata.isAnd
        ? GeneratedRuleFamily.repAndAcode
        : GeneratedRuleFamily.repAcode;
  }

  if (rule.blindEdges.isNotEmpty) {
    return rule.modeMetadata.isAnd
        ? GeneratedRuleFamily.andBcode
        : GeneratedRuleFamily.orBcode;
  }

  return switch (mode) {
    'Default' => GeneratedRuleFamily.defaultFamily,
    'Pipe' => GeneratedRuleFamily.orAcode,
    'Single' => GeneratedRuleFamily.andSingleAcode,
    'And' =>
      rule.regexPatterns.length <= 1 && rule.actionEdges.length <= 1
          ? GeneratedRuleFamily.andSingleAcode
          : GeneratedRuleFamily.andAcodeSeq,
    _ => throw StateError('unsupported generated rule mode $mode'),
  };
}

/// Build the ordered backend-neutral plan for one compiled specification.
List<GeneratedPlanRow> buildGeneratedRulePlan(CompiledSpec compiled) {
  return List<GeneratedPlanRow>.unmodifiable([
    for (final label in compiled.compiledRuleOrder)
      GeneratedPlanRow(
        label: label,
        family: classifyGeneratedRuleFamily(
          compiled.rulesByLabel[label]!,
        ).wireName,
      ),
  ]);
}

/// Validate the artifact contract before payload reconstruction or execution.
void validateGeneratedSourceContractV2(
  String actualContract,
  String sourceIdentity,
) {
  if (actualContract == linkedSpecGeneratedSourceContract) {
    return;
  }
  throw GeneratedSourceException(
    stage: GeneratedSourceStage.validateGeneratedPlan,
    code: GeneratedSourceCode.generatedSourceContractVersionMismatch,
    summary: 'Generated source contract does not match the active validator',
    sourceIdentity: sourceIdentity,
    detail: 'regenerate the generated artifact from its .spec source',
    expectedContract: linkedSpecGeneratedSourceContract,
    actualContract: actualContract,
  );
}

/// Validate an exposed contract-v2 plan before generated execution.
void validateGeneratedRulePlanV2(
  CompiledSpec compiled,
  List<GeneratedPlanRow> generatedPlan,
  String sourceIdentity, {
  String actualContract = linkedSpecGeneratedSourceContract,
}) {
  validateGeneratedSourceContractV2(actualContract, sourceIdentity);
  _validatedGeneratedRulePlanV2(compiled, generatedPlan, sourceIdentity);
}

/// Execute through a validated generated structural-family plan.
Object? executeGeneratedParserV2(
  CompiledSpec compiled,
  List<GeneratedPlanRow> generatedPlan,
  String input,
  String sourceIdentity, {
  String? topRule,
  String actualContract = linkedSpecGeneratedSourceContract,
  RuntimeDiagnosticOutputSink? diagnosticOutputSink,
  RuntimeSemanticObservationSink? semanticObservationSink,
}) {
  validateGeneratedSourceContractV2(actualContract, sourceIdentity);
  final validated = _validatedGeneratedRulePlanV2(
    compiled,
    generatedPlan,
    sourceIdentity,
  );
  try {
    return LinkedSpecRuntimeEngine(compiled)
        .executeGeneratedWithPlan(
          input,
          validated,
          sourceIdentity,
          topRule: topRule,
          diagnosticOutputSink: _generatedDiagnosticOutputSink(
            diagnosticOutputSink,
          ),
          semanticObservationSink: _generatedSemanticObservationSink(
            semanticObservationSink,
          ),
        )
        .value;
  } on GeneratedSourceException {
    rethrow;
  } on _GeneratedDiagnosticOutputSinkFailure catch (failure) {
    Error.throwWithStackTrace(failure.error, failure.stackTrace);
  } on _GeneratedSemanticObservationSinkFailure catch (failure) {
    Error.throwWithStackTrace(failure.error, failure.stackTrace);
  } on RuntimeExitNow {
    rethrow;
  } on RuntimeInterpreterException catch (error) {
    throw _generatedExecutionFailure(
      compiled,
      validated,
      sourceIdentity,
      error,
      topRule: topRule,
      ruleLabel: error.diagnostic?.ruleLabel,
    );
  } on Object catch (error) {
    throw _generatedExecutionFailure(
      compiled,
      validated,
      sourceIdentity,
      error,
      topRule: topRule,
    );
  }
}

/// Execute through a validated plan while emitting native and portable trace.
Object? executeGeneratedParserWithTraceV2(
  CompiledSpec compiled,
  List<GeneratedPlanRow> generatedPlan,
  String input,
  LinkedSpecTraceConfig traceConfig,
  String sourceIdentity, {
  String? topRule,
  String actualContract = linkedSpecGeneratedSourceContract,
  RuntimeDiagnosticOutputSink? diagnosticOutputSink,
  RuntimeSemanticObservationSink? semanticObservationSink,
}) {
  validateGeneratedSourceContractV2(actualContract, sourceIdentity);
  final validated = _validatedGeneratedRulePlanV2(
    compiled,
    generatedPlan,
    sourceIdentity,
  );
  try {
    return LinkedSpecRuntimeEngine(compiled)
        .executeGeneratedWithPlan(
          input,
          validated,
          sourceIdentity,
          topRule: topRule,
          trace: LinkedSpecTraceEmitter(traceConfig),
          diagnosticOutputSink: _generatedDiagnosticOutputSink(
            diagnosticOutputSink,
          ),
          semanticObservationSink: _generatedSemanticObservationSink(
            semanticObservationSink,
          ),
        )
        .value;
  } on GeneratedSourceException {
    rethrow;
  } on _GeneratedDiagnosticOutputSinkFailure catch (failure) {
    Error.throwWithStackTrace(failure.error, failure.stackTrace);
  } on _GeneratedSemanticObservationSinkFailure catch (failure) {
    Error.throwWithStackTrace(failure.error, failure.stackTrace);
  } on RuntimeExitNow {
    rethrow;
  } on RuntimeInterpreterException catch (error) {
    throw _generatedExecutionFailure(
      compiled,
      validated,
      sourceIdentity,
      error,
      topRule: topRule,
      ruleLabel: error.diagnostic?.ruleLabel,
    );
  } on Object catch (error) {
    throw _generatedExecutionFailure(
      compiled,
      validated,
      sourceIdentity,
      error,
      topRule: topRule,
    );
  }
}

/// Emit a generated Dart library for [compiled] using the compatibility identity.
String emitDartSource(CompiledSpec compiled) {
  return emitDartSourceV2(compiled, '<inline>');
}

/// Emit a deterministic contract-v2 Dart library from compiled parser state.
///
/// The generated library reconstructs a normalized effective specification from
/// the compiled state. Its embedded payload is strict UTF-8 represented as
/// Base64, so arbitrary Unicode and Dart interpolation characters are safe.
String emitDartSourceV2(CompiledSpec compiled, String sourceIdentity) {
  if (sourceIdentity.isEmpty) {
    throw GeneratedSourceException.emitFailed(
      sourceIdentity,
      'Generated Dart source identity must not be empty',
      detail: 'source_identity is required',
    );
  }

  try {
    validateCompiledRegexSlotIdentities(compiled);
    validateNoRemovedAggregateSelectors(compiled);
  } on SpecValidationException catch (error) {
    throw _generatedRegexSlotIdentityInvalid(sourceIdentity, error);
  } on CompiledSpecException catch (error) {
    throw GeneratedSourceException.emitFailed(
      sourceIdentity,
      'Failed to emit generated Dart source from invalid compiled spec',
      detail: error.message,
    );
  }

  try {
    final normalizedSpec = SpecFile(
      sourceId: sourceIdentity,
      functions: [
        for (final function in compiled.functions) function.definition,
      ],
      rules: [
        for (final label in compiled.compiledRuleOrder)
          Rule(
            header: compiled.rulesByLabel[label]!.header,
            body: compiled.rulesByLabel[label]!.bodyElements,
          ),
      ],
    );
    final specJson = jsonEncode(normalizedSpec.toJson());
    final specJsonBase64 = base64Encode(utf8.encode(specJson));
    final identityLiteral = _dartStringLiteral(sourceIdentity);
    final planSource = StringBuffer();
    for (final row in buildGeneratedRulePlan(compiled)) {
      planSource
        ..write('  GeneratedPlanRow(label: ')
        ..write(_dartStringLiteral(row.label))
        ..write(', family: ')
        ..write(_dartStringLiteral(row.family))
        ..writeln('),');
    }

    return '''// Generated LinkedSpec parser library.
// Contract id: linkedspec-generated-source-v2.
// Source format: linkedspec_dart source_emitter v2.
// Source identity: linkedspecGeneratedSourceIdentity.

import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';

const linkedspecGeneratedSourceContract =
    'linkedspec-generated-source-v2';
const linkedspecGeneratedSourceFormat = 2;
const linkedspecRegexSlotIdentityContract =
    'linkedspec-duplicate-regex-slot-identity-v1';
const linkedspecGeneratedSourceIdentity = $identityLiteral;
const _compiledSpecJsonBase64 = '$specJsonBase64';
const _generatedPlan = <GeneratedPlanRow>[
$planSource];

GeneratedSourceMetadata metadata() {
  return const GeneratedSourceMetadata(
    sourceIdentity: linkedspecGeneratedSourceIdentity,
  );
}

CompiledSpec _loadCompiledSpec() {
  try {
    final decoded = jsonDecode(
      utf8.decode(base64Decode(_compiledSpecJsonBase64), allowMalformed: false),
    );
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('generated spec payload must be an object');
    }
    return compileSpec(SpecFile.fromJson(decoded));
  } on GeneratedSourceException {
    rethrow;
  } on Object catch (error) {
    throw GeneratedSourceException.compileFailed(
      linkedspecGeneratedSourceIdentity,
      error,
    );
  }
}

final _compiledSpec = _loadCompiledSpec();

List<GeneratedPlanRow> plan() => _generatedPlan;

void validatePlan(List<GeneratedPlanRow> actual) {
  validatePlanForContract(actual, linkedspecGeneratedSourceContract);
}

void validatePlanForContract(
  List<GeneratedPlanRow> actual,
  String actualContract,
) {
  validateGeneratedSourceContractV2(
    actualContract,
    linkedspecGeneratedSourceIdentity,
  );
  validateGeneratedRulePlanV2(
    _compiledSpec,
    actual,
    linkedspecGeneratedSourceIdentity,
    actualContract: actualContract,
  );
}

Object? execute(
  String input, {
  String? topRule,
  RuntimeDiagnosticOutputSink? diagnosticOutputSink,
  RuntimeSemanticObservationSink? semanticObservationSink,
}) {
  validateGeneratedSourceContractV2(
    linkedspecGeneratedSourceContract,
    linkedspecGeneratedSourceIdentity,
  );
  return executeGeneratedParserV2(
    _compiledSpec,
    _generatedPlan,
    input,
    linkedspecGeneratedSourceIdentity,
    topRule: topRule,
    actualContract: linkedspecGeneratedSourceContract,
    diagnosticOutputSink: diagnosticOutputSink,
    semanticObservationSink: semanticObservationSink,
  );
}

Object? executeWithTrace(
  String input,
  LinkedSpecTraceConfig traceConfig, {
  String? topRule,
  RuntimeDiagnosticOutputSink? diagnosticOutputSink,
  RuntimeSemanticObservationSink? semanticObservationSink,
}) {
  validateGeneratedSourceContractV2(
    linkedspecGeneratedSourceContract,
    linkedspecGeneratedSourceIdentity,
  );
  return executeGeneratedParserWithTraceV2(
    _compiledSpec,
    _generatedPlan,
    input,
    traceConfig,
    linkedspecGeneratedSourceIdentity,
    topRule: topRule,
    actualContract: linkedspecGeneratedSourceContract,
    diagnosticOutputSink: diagnosticOutputSink,
    semanticObservationSink: semanticObservationSink,
  );
}
''';
  } on GeneratedSourceException {
    rethrow;
  } on Object catch (error) {
    throw GeneratedSourceException.emitFailed(
      sourceIdentity,
      'Failed to serialize compiled spec for generated Dart source',
      detail: error.toString(),
    );
  }
}

Map<String, GeneratedRuleFamily> _validatedGeneratedRulePlanV2(
  CompiledSpec compiled,
  List<GeneratedPlanRow> generatedPlan,
  String sourceIdentity,
) {
  try {
    validateCompiledRegexSlotIdentities(compiled);
    validateNoRemovedAggregateSelectors(compiled);
  } on SpecValidationException catch (error) {
    throw _generatedRegexSlotIdentityInvalid(sourceIdentity, error);
  } on CompiledSpecException catch (error) {
    throw GeneratedSourceException.compileFailed(sourceIdentity, error.message);
  }

  if (compiled.compiledRuleOrder.length != generatedPlan.length) {
    throw GeneratedSourceException(
      stage: GeneratedSourceStage.validateGeneratedPlan,
      code: GeneratedSourceCode.generatedPlanRowCountMismatch,
      summary: 'Generated rule plan row count does not match compiled rules',
      sourceIdentity: sourceIdentity,
      detail:
          'expected=${compiled.compiledRuleOrder.length} '
          'actual=${generatedPlan.length}',
    );
  }

  final validated = <String, GeneratedRuleFamily>{};
  for (var index = 0; index < generatedPlan.length; index += 1) {
    final expectedLabel = compiled.compiledRuleOrder[index];
    final row = generatedPlan[index];
    if (row.label != expectedLabel) {
      throw GeneratedSourceException(
        stage: GeneratedSourceStage.validateGeneratedPlan,
        code: GeneratedSourceCode.generatedPlanLabelMismatch,
        summary: 'Generated rule plan label does not match compiled rule',
        sourceIdentity: sourceIdentity,
        ruleLabel: expectedLabel,
        detail: 'row=$index expected=$expectedLabel actual=${row.label}',
      );
    }

    final actualFamily = GeneratedRuleFamily.fromWireName(row.family);
    if (actualFamily == null) {
      throw GeneratedSourceException(
        stage: GeneratedSourceStage.validateGeneratedPlan,
        code: GeneratedSourceCode.generatedPlanUnknownFamily,
        summary: 'Generated rule plan contains an unknown family',
        sourceIdentity: sourceIdentity,
        ruleLabel: expectedLabel,
        handlerFamily: row.family,
        detail: 'row=$index',
      );
    }

    final expectedFamily = classifyGeneratedRuleFamily(
      compiled.rulesByLabel[expectedLabel]!,
    );
    if (actualFamily != expectedFamily) {
      throw GeneratedSourceException(
        stage: GeneratedSourceStage.validateGeneratedPlan,
        code: GeneratedSourceCode.generatedPlanFamilyMismatch,
        summary: 'Generated rule plan family does not match compiled rule',
        sourceIdentity: sourceIdentity,
        ruleLabel: expectedLabel,
        handlerFamily: row.family,
        detail:
            'row=$index expected=${expectedFamily.wireName} '
            'actual=${row.family}',
      );
    }
    validated[expectedLabel] = actualFamily;
  }
  return Map<String, GeneratedRuleFamily>.unmodifiable(validated);
}

GeneratedSourceException _generatedExecutionFailure(
  CompiledSpec compiled,
  Map<String, GeneratedRuleFamily> validatedPlan,
  String sourceIdentity,
  Object error, {
  String? topRule,
  String? ruleLabel,
}) {
  if (error is RuntimeInterpreterException) {
    final diagnostic = error.diagnostic;
    if (diagnostic?.code == 'ordered_regex_slot_identity_lost') {
      return GeneratedSourceException(
        stage: GeneratedSourceStage.executeRule,
        code: GeneratedSourceCode.orderedRegexSlotIdentityLost,
        summary: 'Generated ordered regex-slot identity invariant failed',
        sourceIdentity: sourceIdentity,
        ruleLabel: diagnostic?.ruleLabel,
        targetRule: diagnostic?.targetRule,
        expectedRegexIndex: diagnostic?.expectedRegexIndex,
        actualRegexIndex: diagnostic?.actualRegexIndex,
        detail: diagnostic?.detail,
      );
    }
    if (diagnostic?.code == 'no_rules_defined' ||
        diagnostic?.code == 'entry_rule_not_found') {
      return GeneratedSourceException(
        stage: diagnostic!.stage == 'validate_spec'
            ? GeneratedSourceStage.validateSpec
            : GeneratedSourceStage.selectEntryRule,
        code: diagnostic.code == 'no_rules_defined'
            ? GeneratedSourceCode.noRulesDefined
            : GeneratedSourceCode.entryRuleNotFound,
        summary: 'Generated Dart parser entry-rule selection failed',
        sourceIdentity: sourceIdentity,
        entryRule: diagnostic.entryRule,
        ruleLabel: diagnostic.ruleLabel,
        detail: diagnostic.detail,
      );
    }
  }
  String? effectiveRule = ruleLabel;
  if (effectiveRule == null) {
    try {
      effectiveRule = compiled.resolveEntryRule(topRule).rule.label;
    } on EntryRuleSelectionException {
      effectiveRule = topRule;
    }
  }
  return GeneratedSourceException.executionFailed(
    sourceIdentity,
    error,
    ruleLabel: effectiveRule,
    handlerFamily: effectiveRule == null
        ? null
        : validatedPlan[effectiveRule]?.wireName,
  );
}

GeneratedSourceException _generatedRegexSlotIdentityInvalid(
  String sourceIdentity,
  SpecValidationException error,
) {
  final diagnostic = error.diagnostic;
  return GeneratedSourceException(
    stage: GeneratedSourceStage.validateCompiledRule,
    code: GeneratedSourceCode.regexSlotIdentityInvalid,
    summary: 'Generated compiled regex-slot identity validation failed',
    sourceIdentity: sourceIdentity,
    ruleLabel: diagnostic?.field('rule_label') as String?,
    targetRule: diagnostic?.field('target_rule') as String?,
    regexIndex: diagnostic?.field('regex_index') as int?,
    detail: error.message,
  );
}

String _dartStringLiteral(String value) {
  return jsonEncode(value).replaceAll(r'$', r'\$');
}
