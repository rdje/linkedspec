import 'dart:convert';

import 'ast/spec_ast.dart';
import 'compiler/compiled_spec.dart';

/// Backend-neutral generated-source contract implemented by this emitter.
const linkedSpecGeneratedSourceContract = 'linkedspec-generated-source-v1';

/// Version of the generated Dart source scaffold.
const linkedSpecGeneratedSourceFormatVersion = 1;

/// Stable stage in the generated-source pipeline.
enum GeneratedSourceStage {
  emitSource('emit_source'),
  compileOrLoadGeneratedSource('compile_or_load_generated_source'),
  validateGeneratedPlan('validate_generated_plan'),
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
    this.ruleLabel,
    this.handlerFamily,
    this.detail,
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
  final String? ruleLabel;
  final String? handlerFamily;
  final String? detail;

  JsonObject toJson() {
    return {
      'type': 'generated_source_error',
      'stage': stage.wireName,
      'code': code.wireName,
      'summary': summary,
      'source_identity': sourceIdentity,
      if (ruleLabel != null) 'rule_label': ruleLabel,
      if (handlerFamily != null) 'handler_family': handlerFamily,
      if (detail != null) 'detail': detail,
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

  JsonObject toJson() {
    return {
      'contract_id': contractId,
      'format_version': formatVersion,
      'source_identity': sourceIdentity,
    };
  }
}

/// Emit a generated Dart library for [compiled] using the compatibility identity.
String emitDartSource(CompiledSpec compiled) {
  return emitDartSourceV1(compiled, '<inline>');
}

/// Emit a deterministic contract-v1 Dart library from compiled parser state.
///
/// The generated library reconstructs a normalized effective specification from
/// the compiled state. Its embedded payload is strict UTF-8 represented as
/// Base64, so arbitrary Unicode and Dart interpolation characters are safe.
String emitDartSourceV1(CompiledSpec compiled, String sourceIdentity) {
  if (sourceIdentity.isEmpty) {
    throw GeneratedSourceException.emitFailed(
      sourceIdentity,
      'Generated Dart source identity must not be empty',
      detail: 'source_identity is required',
    );
  }

  try {
    final normalizedSpec = SpecFile(
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

    return '''// Generated LinkedSpec parser library.
// Contract id: linkedspec-generated-source-v1.
// Source format: linkedspec_dart source_emitter v1.
// Source identity: linkedspecGeneratedSourceIdentity.

import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';

const linkedspecGeneratedSourceContract =
    'linkedspec-generated-source-v1';
const linkedspecGeneratedSourceFormat = 1;
const linkedspecGeneratedSourceIdentity = $identityLiteral;
const _compiledSpecJsonBase64 = '$specJsonBase64';

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

Object? execute(String input, {String? topRule}) {
  try {
    return LinkedSpecRuntimeEngine(_compiledSpec)
        .execute(input, topRule: topRule)
        .value;
  } on GeneratedSourceException {
    rethrow;
  } on Object catch (error) {
    throw GeneratedSourceException.executionFailed(
      linkedspecGeneratedSourceIdentity,
      error,
      ruleLabel: topRule,
    );
  }
}

Object? executeWithTrace(
  String input,
  LinkedSpecTraceConfig traceConfig, {
  String? topRule,
}) {
  try {
    return LinkedSpecRuntimeEngine(_compiledSpec)
        .executeWithTrace(input, traceConfig, topRule: topRule)
        .value;
  } on GeneratedSourceException {
    rethrow;
  } on Object catch (error) {
    throw GeneratedSourceException.executionFailed(
      linkedspecGeneratedSourceIdentity,
      error,
      ruleLabel: topRule,
    );
  }
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

String _dartStringLiteral(String value) {
  return jsonEncode(value).replaceAll(r'$', r'\$');
}
