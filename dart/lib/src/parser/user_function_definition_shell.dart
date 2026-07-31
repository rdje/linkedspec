import '../ast/spec_ast.dart';
import '../trace/trace.dart';
import 'spec_parser.dart';

final class UserFunctionDefinitionProjection {
  const UserFunctionDefinitionProjection({
    required this.functions,
    required this.strippedSource,
  });

  final List<FunctionDefinition> functions;
  final String strippedSource;
}

SpecFile parseSpecWithUserFunctionDefinitionAsts(
  String source,
  Iterable<Object?> definitionNodes, {
  LinkedSpecTraceEmitter? trace,
}) {
  final traceScope = trace?.enterScope(
    'dart_frontend:function_shell_spec',
    'source_code_units=${source.length}',
    LinkedSpecTraceLevel.high,
  );
  try {
    final projection = projectUserFunctionDefinitionAsts(
      source,
      definitionNodes,
      trace: trace,
    );
    final SpecFile ruleSpec;
    try {
      ruleSpec = parseSpec(projection.strippedSource, trace: trace);
    } on SpecParseException catch (error) {
      throw SpecParseException(
        line: error.line,
        message:
            'rule parse after function extraction failed: ${error.message}',
      );
    }
    final spec = SpecFile(
      functions: projection.functions,
      rules: ruleSpec.rules,
    );
    if (traceScope != null) {
      trace?.exitScope(
        traceScope,
        'ok functions=${spec.functions.length} rules=${spec.rules.length}',
      );
    }
    return spec;
  } on Object catch (error) {
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'error=$error');
    }
    rethrow;
  }
}

UserFunctionDefinitionProjection projectUserFunctionDefinitionAsts(
  String source,
  Iterable<Object?> definitionNodes, {
  LinkedSpecTraceEmitter? trace,
}) {
  final traceScope = trace?.enterScope(
    'dart_frontend:function_projection',
    'source_code_units=${source.length}',
    LinkedSpecTraceLevel.high,
  );
  try {
    final projection = _projectUserFunctionDefinitionAsts(
      source,
      definitionNodes,
      trace,
    );
    if (traceScope != null) {
      trace?.exitScope(
        traceScope,
        'ok function_count=${projection.functions.length}',
      );
    }
    return projection;
  } on Object catch (error) {
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'error=$error');
    }
    rethrow;
  }
}

UserFunctionDefinitionProjection _projectUserFunctionDefinitionAsts(
  String source,
  Iterable<Object?> definitionNodes,
  LinkedSpecTraceEmitter? trace,
) {
  final functions = <FunctionDefinition>[];
  final spans = <_AstSpan>[];

  var index = 0;
  for (final node in definitionNodes) {
    final object = _jsonObject(node, 'definition node $index');
    switch (_stringField(object, 'type', 'definition node')) {
      case 'function_definition':
        final projected = _functionFromAst(object, source, index);
        functions.add(projected.function);
        spans.add(projected.sourceSpan);
        trace?.traceDecision(
          'dart_frontend:function_projection:definition',
          true,
          'index=$index name=${projected.function.name} '
              'arity=${projected.function.arity}',
          LinkedSpecTraceLevel.medium,
        );
      case 'function_definition_error':
        throw _functionError(object, index);
      case final other:
        throw FormatException(
          'user_function_definition.spec returned unsupported node type '
          "'$other' at index $index",
        );
    }
    index += 1;
  }

  return UserFunctionDefinitionProjection(
    functions: functions,
    strippedSource: _stripFunctionDefinitionSpans(source, spans),
  );
}

final class _ProjectedFunction {
  const _ProjectedFunction({required this.function, required this.sourceSpan});

  final FunctionDefinition function;
  final _AstSpan sourceSpan;
}

final class _AstSpan {
  const _AstSpan({
    required this.start,
    required this.end,
    required this.lineStart,
    required this.lineEnd,
  });

  final int start;
  final int end;
  final int lineStart;
  final int lineEnd;

  @override
  bool operator ==(Object other) {
    return other is _AstSpan &&
        other.start == start &&
        other.end == end &&
        other.lineStart == lineStart &&
        other.lineEnd == lineEnd;
  }

  @override
  int get hashCode => Object.hash(start, end, lineStart, lineEnd);
}

_ProjectedFunction _functionFromAst(
  JsonObject object,
  String source,
  int index,
) {
  _assertStringField(object, 'kind', 'user_function_definition', index);
  final version = _intField(object, 'version', index);

  final name = _stringField(object, 'name', 'function_definition');
  if (!_isIdentifier(name)) {
    throw FormatException(
      "function_definition node $index has invalid name '$name'",
    );
  }

  final List<String> params;
  final int arity;
  final Map<String, String> parameterKinds;
  final CallableSignature? signature;
  switch (version) {
    case 1:
      if (object.containsKey('signature')) {
        throw FormatException(
          'function_definition node $index version 1 must not contain '
          'signature',
        );
      }
      if (object.containsKey('parameter_kinds') ||
          object.containsKey('fixed_params') ||
          object.containsKey('codeblock_param')) {
        if (object.containsKey('params') || object.containsKey('arity')) {
          throw FormatException(
            'function_definition node $index typed version 1 must derive '
            'params and arity from fixed_params plus codeblock_param',
          );
        }
        final fixedParams = _stringListField(object, 'fixed_params', index);
        final codeblockParam = _stringField(
          object,
          'codeblock_param',
          'function_definition',
        );
        parameterKinds = _stringMapField(object, 'parameter_kinds', index);
        _validateFinalCodeblockMetadata(
          fixedParams: fixedParams,
          codeblockParam: codeblockParam,
          parameterKinds: parameterKinds,
          index: index,
          context: 'definition',
        );
        params = [...fixedParams, codeblockParam];
        arity = params.length;
      } else {
        params = _stringListField(object, 'params', index);
        arity = _intField(object, 'arity', index);
        parameterKinds = const {};
      }
      signature = null;
    case 2:
      if (object.containsKey('params') || object.containsKey('arity')) {
        throw FormatException(
          'function_definition node $index version 2 must store arity only '
          'in signature',
        );
      }
      signature = _callableSignatureField(object, 'signature', index);
      params = signature.positionalParams;
      arity = signature.minArity;
      parameterKinds = const {};
    default:
      throw FormatException(
        'function_definition node $index has unsupported version $version',
      );
  }
  for (final param in params) {
    if (!_isIdentifier(param)) {
      throw FormatException(
        "function_definition node $index has invalid parameter '$param'",
      );
    }
  }

  if (arity != params.length) {
    throw FormatException(
      'function_definition node $index arity $arity does not match '
      '${params.length} params',
    );
  }

  final sourceText = _stringField(object, 'source_text', 'function_definition');
  final sourceSpan = _spanField(object, 'source_span', index);
  _validateSpanText(source, sourceSpan, sourceText, 'source_text', index);

  final bodySource = _stringField(object, 'body_source', 'function_definition');
  final bodySpan = _spanField(object, 'body_span', index);
  _validateSpanText(source, bodySpan, bodySource, 'body_source', index);
  if (sourceSpan.start > bodySpan.start ||
      bodySpan.start > bodySpan.end ||
      bodySpan.end > sourceSpan.end) {
    throw FormatException(
      'function_definition node $index body span is outside source span',
    );
  }

  final bodyPayload = _copyJson(_requiredValue(object, 'body_payload', index));
  _validateBodyPayload(
    bodyPayload,
    name,
    params,
    arity,
    parameterKinds,
    signature,
    bodySource,
    bodySpan,
    index,
  );
  _normalizeParentAstPath(bodyPayload, index, 'body_payload');

  final bodyParseJob = _copyJson(
    _requiredValue(object, 'body_parse_job', index),
  );
  _validateBodyParseJob(
    bodyParseJob,
    name,
    params,
    arity,
    parameterKinds,
    signature,
    bodySource,
    bodySpan,
    index,
  );
  _normalizeBodyParseJob(bodyParseJob, index, bodySpan);

  return _ProjectedFunction(
    function: FunctionDefinition(
      name: name,
      params: params,
      arity: arity,
      parameterKinds: parameterKinds,
      signature: signature,
      bodySource: bodySource,
      bodyPayload: bodyPayload,
      bodyParseJob: StagedParseJob.fromJson(
        _jsonObject(bodyParseJob, 'body_parse_job'),
      ),
      source: sourceText,
      sourceSpan: SourceSpan(
        lineStart: sourceSpan.lineStart,
        lineEnd: sourceSpan.lineEnd,
      ),
      bodySpan: SourceSpan(
        lineStart: bodySpan.lineStart,
        lineEnd: bodySpan.lineEnd,
      ),
    ),
    sourceSpan: sourceSpan,
  );
}

String _stripFunctionDefinitionSpans(String source, List<_AstSpan> spans) {
  if (spans.isEmpty) {
    return source;
  }

  final charLength = source.runes.length;
  final sorted = [...spans]..sort((left, right) => left.start - right.start);
  var previousEnd = 0;
  for (final span in sorted) {
    if (span.start > span.end || span.end > charLength) {
      throw FormatException(
        'function definition span ${span.start}..${span.end} is outside '
        'source length $charLength',
      );
    }
    if (span.start < previousEnd) {
      throw FormatException(
        'function definition spans overlap at ${span.start}..${span.end}',
      );
    }
    previousEnd = span.end;
  }

  final out = StringBuffer();
  var spanIndex = 0;
  var charIndex = 0;
  for (final rune in source.runes) {
    while (spanIndex < sorted.length && charIndex >= sorted[spanIndex].end) {
      spanIndex += 1;
    }
    final insideSpan =
        spanIndex < sorted.length &&
        charIndex >= sorted[spanIndex].start &&
        charIndex < sorted[spanIndex].end;
    if (insideSpan && rune != 10 && rune != 13) {
      out.write(' ');
    } else {
      out.writeCharCode(rune);
    }
    charIndex += 1;
  }
  return out.toString();
}

void _validateBodyPayload(
  Object? payload,
  String name,
  List<String> params,
  int arity,
  Map<String, String> parameterKinds,
  CallableSignature? signature,
  String bodySource,
  _AstSpan bodySpan,
  int index,
) {
  final object = _jsonObject(
    payload,
    'function_definition node $index body_payload',
  );
  _assertStringField(object, 'kind', 'staged_payload', index);
  _assertStringField(object, 'node_kind', 'function_definition', index);
  _assertStringField(object, 'payload_kind', 'function_body', index);
  _validateFunctionBodyParentPath(object, 'body_payload', index);
  if (_stringField(object, 'function_name', 'body_payload') != name) {
    throw FormatException(
      'function_definition node $index body_payload function_name does not '
      'match name',
    );
  }
  _validateStagedSignature(
    object,
    'body_payload',
    params,
    arity,
    parameterKinds,
    signature,
    index,
  );
  if (_stringField(object, 'text', 'body_payload') != bodySource) {
    throw FormatException(
      'function_definition node $index body_payload text does not match '
      'body_source',
    );
  }
  if (_spanField(object, 'source_span', index) != bodySpan) {
    throw FormatException(
      'function_definition node $index body_payload source_span does not '
      'match body_span',
    );
  }
}

void _validateBodyParseJob(
  Object? job,
  String name,
  List<String> params,
  int arity,
  Map<String, String> parameterKinds,
  CallableSignature? signature,
  String bodySource,
  _AstSpan bodySpan,
  int index,
) {
  final object = _jsonObject(
    job,
    'function_definition node $index body_parse_job',
  );
  _assertStringField(object, 'kind', 'parse_job', index);
  _assertStringField(object, 'node_kind', 'function_definition', index);
  _assertStringField(object, 'payload_kind', 'function_body', index);
  _validateFunctionBodyParentPath(object, 'body_parse_job', index);
  if (_stringField(object, 'job_id', 'body_parse_job').isEmpty) {
    throw FormatException(
      'function_definition node $index body_parse_job job_id must be '
      'non-empty',
    );
  }
  if (_stringField(object, 'function_name', 'body_parse_job') != name) {
    throw FormatException(
      'function_definition node $index body_parse_job function_name does not '
      'match name',
    );
  }
  _validateStagedSignature(
    object,
    'body_parse_job',
    params,
    arity,
    parameterKinds,
    signature,
    index,
  );
  if (_stringField(object, 'text', 'body_parse_job') != bodySource) {
    throw FormatException(
      'function_definition node $index body_parse_job text does not match '
      'body_source',
    );
  }
  if (_spanField(object, 'source_span', index) != bodySpan) {
    throw FormatException(
      'function_definition node $index body_parse_job source_span does not '
      'match body_span',
    );
  }
  if (_stringField(object, 'parser_spec_id', 'body_parse_job') !=
      'actionir-body.spec') {
    throw FormatException(
      'function_definition node $index body_parse_job parser_spec_id must be '
      'actionir-body.spec',
    );
  }
  if (_stringField(object, 'top_rule', 'body_parse_job') != 'action_block') {
    throw FormatException(
      'function_definition node $index body_parse_job top_rule must be '
      'action_block',
    );
  }
  if (_stringField(object, 'result_policy', 'body_parse_job') !=
      'replace_field') {
    throw FormatException(
      'function_definition node $index body_parse_job result_policy must be '
      'replace_field',
    );
  }
  if (_stringField(object, 'result_field', 'body_parse_job') != 'body_ast') {
    throw FormatException(
      'function_definition node $index body_parse_job result_field must be '
      'body_ast',
    );
  }
  if (_stringField(object, 'failure_policy', 'body_parse_job') != 'fail') {
    throw FormatException(
      'function_definition node $index body_parse_job failure_policy must be '
      'fail',
    );
  }
  if (_stringField(object, 'diagnostic_owner', 'body_parse_job') !=
      'function_body') {
    throw FormatException(
      'function_definition node $index body_parse_job diagnostic_owner must '
      'be function_body',
    );
  }
}

void _validateStagedSignature(
  JsonObject object,
  String context,
  List<String> params,
  int arity,
  Map<String, String> parameterKinds,
  CallableSignature? signature,
  int index,
) {
  if (parameterKinds.isNotEmpty) {
    if (object.containsKey('params') ||
        object.containsKey('arity') ||
        object.containsKey('signature')) {
      throw FormatException(
        'function_definition node $index $context typed final-codeblock '
        'metadata must use fixed_params plus codeblock_param',
      );
    }
    final fixedParams = _stringListField(object, 'fixed_params', index);
    final codeblockParam = _stringField(
      object,
      'codeblock_param',
      'function_definition $context',
    );
    final actualKinds = _stringMapField(object, 'parameter_kinds', index);
    _validateFinalCodeblockMetadata(
      fixedParams: fixedParams,
      codeblockParam: codeblockParam,
      parameterKinds: actualKinds,
      index: index,
      context: context,
    );
    if (!_stringListsEqual(fixedParams, params.sublist(0, params.length - 1)) ||
        codeblockParam != params.last ||
        !_stringMapsEqual(actualKinds, parameterKinds)) {
      throw FormatException(
        'function_definition node $index $context final-codeblock metadata '
        'does not match definition',
      );
    }
    return;
  }
  if (signature != null) {
    if (object.containsKey('params') || object.containsKey('arity')) {
      throw FormatException(
        'function_definition node $index $context version 2 must store '
        'arity only in signature',
      );
    }
    final actual = _callableSignatureField(object, 'signature', index);
    if (!_callableSignaturesEqual(actual, signature)) {
      throw FormatException(
        'function_definition node $index $context signature does not match '
        'signature',
      );
    }
    return;
  }
  if (object.containsKey('signature')) {
    throw FormatException(
      'function_definition node $index $context version 1 must not contain '
      'signature',
    );
  }
  if (!_stringListsEqual(_stringListField(object, 'params', index), params)) {
    throw FormatException(
      'function_definition node $index $context params do not match params',
    );
  }
  if (_intField(object, 'arity', index) != arity) {
    throw FormatException(
      'function_definition node $index $context arity does not match arity',
    );
  }
}

void _validateFinalCodeblockMetadata({
  required List<String> fixedParams,
  required String codeblockParam,
  required Map<String, String> parameterKinds,
  required int index,
  required String context,
}) {
  if (!_isIdentifier(codeblockParam)) {
    throw FormatException(
      "function_definition node $index $context has invalid final codeblock "
      "parameter '$codeblockParam'",
    );
  }
  if (fixedParams.contains(codeblockParam)) {
    throw FormatException(
      "function_definition node $index $context duplicates final codeblock "
      "parameter '$codeblockParam'",
    );
  }
  if (parameterKinds.length != 1 ||
      parameterKinds[codeblockParam] != 'codeblock') {
    throw FormatException(
      'function_definition node $index $context must declare exactly one '
      'final codeblock parameter kind',
    );
  }
}

void _validateFunctionBodyParentPath(
  JsonObject object,
  String context,
  int index,
) {
  final path = _stringListField(object, 'parent_ast_path', index);
  if (path.length != 3 || path[0] != 'functions' || path[2] != 'body_source') {
    throw FormatException(
      'function_definition node $index $context parent_ast_path must target '
      'functions[*].body_source',
    );
  }
}

void _normalizeParentAstPath(Object? value, int index, String context) {
  final object = _jsonObject(value, 'function_definition node $index $context');
  object['parent_ast_path'] = ['functions', '$index', 'body_source'];
}

void _normalizeBodyParseJob(Object? job, int index, _AstSpan bodySpan) {
  _normalizeParentAstPath(job, index, 'body_parse_job');
  final object = _jsonObject(
    job,
    'function_definition node $index body_parse_job',
  );
  object['job_id'] =
      'parse_job:function_body:functions.$index.body_source:'
      'actionir-body.spec:action_block:${bodySpan.start}-${bodySpan.end}';
}

void _validateSpanText(
  String source,
  _AstSpan span,
  String expected,
  String field,
  int index,
) {
  final actual = _charSlice(source, span.start, span.end);
  if (actual == null) {
    throw FormatException(
      'function_definition node $index $field span ${span.start}..'
      '${span.end} is outside source',
    );
  }
  if (actual != expected) {
    throw FormatException(
      'function_definition node $index $field does not match its source span',
    );
  }
}

String? _charSlice(String source, int start, int end) {
  if (start > end) {
    return null;
  }
  final runes = source.runes.toList();
  if (end > runes.length) {
    return null;
  }
  return String.fromCharCodes(runes.sublist(start, end));
}

_AstSpan _spanField(JsonObject object, String field, int index) {
  final span = _jsonObject(
    _requiredValue(object, field, index),
    'function_definition node $index $field',
  );
  final start = _intField(span, 'start', index);
  final end = _intField(span, 'end', index);
  final lineStart = _intField(span, 'line_start', index);
  final lineEnd = _intField(span, 'line_end', index);
  if (lineStart == 0 || lineEnd == 0 || lineStart > lineEnd) {
    throw FormatException(
      'function_definition node $index $field has invalid line span '
      '$lineStart..$lineEnd',
    );
  }
  if (start > end) {
    throw FormatException(
      'function_definition node $index $field has invalid character span '
      '$start..$end',
    );
  }
  return _AstSpan(
    start: start,
    end: end,
    lineStart: lineStart,
    lineEnd: lineEnd,
  );
}

Object? _requiredValue(JsonObject object, String field, int index) {
  if (!object.containsKey(field)) {
    throw FormatException(
      "function_definition node $index is missing field '$field'",
    );
  }
  return object[field];
}

JsonObject _jsonObject(Object? value, String context) {
  if (value is! Map) {
    throw FormatException('$context must be a JSON object');
  }
  return value.cast<String, Object?>();
}

String _stringField(JsonObject object, String field, String context) {
  final value = object[field];
  if (value is! String) {
    throw FormatException("$context is missing string field '$field'");
  }
  return value;
}

void _assertStringField(
  JsonObject object,
  String field,
  String expected,
  int index,
) {
  final actual = _stringField(object, field, 'function_definition');
  if (actual != expected) {
    throw FormatException(
      "function_definition node $index expected $field='$expected', "
      "got '$actual'",
    );
  }
}

List<String> _stringListField(JsonObject object, String field, int index) {
  final value = object[field];
  if (value is! List) {
    throw FormatException(
      "function_definition node $index is missing array field '$field'",
    );
  }
  return [
    for (var itemIndex = 0; itemIndex < value.length; itemIndex += 1)
      _stringListItem(value[itemIndex], field, index, itemIndex),
  ];
}

Map<String, String> _stringMapField(
  JsonObject object,
  String field,
  int index,
) {
  final value = object[field];
  if (value is! Map) {
    throw FormatException(
      "function_definition node $index is missing object field '$field'",
    );
  }
  final result = <String, String>{};
  for (final entry in value.entries) {
    if (entry.key is! String || entry.value is! String) {
      throw FormatException(
        "function_definition node $index field '$field' must contain only "
        'string entries',
      );
    }
    result[entry.key as String] = entry.value as String;
  }
  return Map.unmodifiable(result);
}

CallableSignature _callableSignatureField(
  JsonObject object,
  String field,
  int index,
) {
  final signature = _jsonObject(
    _requiredValue(object, field, index),
    'function_definition node $index $field',
  );
  const expectedFields = {
    'kind',
    'version',
    'positional_params',
    'rest_param',
    'min_arity',
    'max_arity',
  };
  if (signature.length != expectedFields.length ||
      signature.keys.any((key) => !expectedFields.contains(key))) {
    throw FormatException(
      "function_definition node $index field '$field' has invalid callable "
      'signature fields',
    );
  }
  _assertStringField(signature, 'kind', 'callable_signature', index);
  final version = _intField(signature, 'version', index);
  if (version != 1) {
    throw FormatException(
      "function_definition node $index field '$field' has unsupported "
      'signature version $version',
    );
  }
  final positionalParams = _stringListField(
    signature,
    'positional_params',
    index,
  );
  for (final param in positionalParams) {
    if (!_isIdentifier(param)) {
      throw FormatException(
        "function_definition node $index has invalid positional parameter "
        "'$param'",
      );
    }
  }
  final restParam = _stringField(signature, 'rest_param', 'callable_signature');
  if (!_isIdentifier(restParam)) {
    throw FormatException(
      "function_definition node $index has invalid rest parameter "
      "'$restParam'",
    );
  }
  final minArity = _intField(signature, 'min_arity', index);
  if (minArity != positionalParams.length) {
    throw FormatException(
      'function_definition node $index min_arity $minArity does not match '
      '${positionalParams.length} positional params',
    );
  }
  if (!signature.containsKey('max_arity') || signature['max_arity'] != null) {
    throw FormatException(
      "function_definition node $index field '$field' max_arity must be null",
    );
  }
  return CallableSignature(
    kind: 'callable_signature',
    version: version,
    positionalParams: List.unmodifiable(positionalParams),
    restParam: restParam,
    minArity: minArity,
    maxArity: null,
  );
}

bool _callableSignaturesEqual(CallableSignature left, CallableSignature right) {
  return left.kind == right.kind &&
      left.version == right.version &&
      _stringListsEqual(left.positionalParams, right.positionalParams) &&
      left.restParam == right.restParam &&
      left.minArity == right.minArity &&
      left.maxArity == right.maxArity;
}

String _stringListItem(Object? value, String field, int index, int itemIndex) {
  if (value is! String) {
    throw FormatException(
      "function_definition node $index field '$field' item $itemIndex is not "
      'a string',
    );
  }
  return value;
}

int _intField(JsonObject object, String field, int index) {
  final value = object[field];
  if (value is int && value >= 0) {
    return value;
  }
  throw FormatException(
    "function_definition node $index field '$field' must be a non-negative "
    'integer',
  );
}

bool _stringListsEqual(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

bool _stringMapsEqual(Map<String, String> left, Map<String, String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

Object? _copyJson(Object? value) {
  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key as String: _copyJson(entry.value),
    };
  }
  if (value is List) {
    return [for (final item in value) _copyJson(item)];
  }
  return value;
}

SpecParseException _functionError(JsonObject object, int index) {
  var line = 0;
  final spanValue = object['source_span'];
  if (spanValue is Map) {
    final span = spanValue.cast<String, Object?>();
    final lineStart = span['line_start'];
    if (lineStart is int) {
      line = lineStart;
    }
  }
  final messageValue = object['message'];
  final sourceText = object['source_text'];
  final typedCode = sourceText is String
      ? _typedDeclarationErrorCode(sourceText)
      : null;
  final message =
      typedCode ??
      (messageValue is String
          ? messageValue
          : 'invalid user function definition');
  if (line > 0) {
    return SpecParseException(
      line: line,
      message: 'user function definition parse error at line $line: $message',
    );
  }
  return SpecParseException(
    line: 1,
    message: 'user function definition parse error at node $index: $message',
  );
}

String? _typedDeclarationErrorCode(String sourceText) {
  final openBrace = sourceText.indexOf('{');
  final header = openBrace < 0
      ? sourceText
      : sourceText.substring(0, openBrace);
  if (RegExp(r':\s*codeblock\s*\(').hasMatch(header)) {
    return 'codeblock_declaration_has_no_argument_list';
  }
  if (RegExp(r':\s*codeblock\s*,').hasMatch(header)) {
    return 'codeblock_parameter_must_be_final';
  }
  if (RegExp(r'\(\s*:\s*codeblock\b').hasMatch(header)) {
    return 'invalid_codeblock_parameter_name';
  }
  final typed = RegExp(
    r'\b[A-Za-z_][A-Za-z0-9_]*\s*:\s*([A-Za-z_][A-Za-z0-9_]*)',
  ).firstMatch(header);
  if (typed != null && typed[1] != 'codeblock') {
    return 'unknown_parameter_type';
  }
  return null;
}

bool _isIdentifier(String value) {
  if (value.isEmpty) {
    return false;
  }
  final first = value.codeUnitAt(0);
  if (!_isIdentifierStart(first)) {
    return false;
  }
  for (var index = 1; index < value.length; index += 1) {
    if (!_isIdentifierContinue(value.codeUnitAt(index))) {
      return false;
    }
  }
  return true;
}

bool _isIdentifierStart(int codeUnit) {
  return (codeUnit >= 65 && codeUnit <= 90) ||
      (codeUnit >= 97 && codeUnit <= 122) ||
      codeUnit == 95;
}

bool _isIdentifierContinue(int codeUnit) {
  return _isIdentifierStart(codeUnit) || (codeUnit >= 48 && codeUnit <= 57);
}
