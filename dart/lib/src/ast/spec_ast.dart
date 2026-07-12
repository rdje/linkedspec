typedef JsonObject = Map<String, Object?>;

final class SpecFile {
  const SpecFile({this.functions = const [], required this.rules});

  final List<FunctionDefinition> functions;
  final List<Rule> rules;

  factory SpecFile.fromJson(JsonObject json) {
    return SpecFile(
      functions: _objectList(
        json,
        'functions',
        FunctionDefinition.fromJson,
        defaultValue: const [],
      ),
      rules: _objectList(json, 'rules', Rule.fromJson),
    );
  }

  JsonObject toJson() {
    return {
      'functions': [for (final function in functions) function.toJson()],
      'rules': [for (final rule in rules) rule.toJson()],
    };
  }

  Rule? get topRule {
    for (final rule in rules) {
      if (rule.header.isTop) {
        return rule;
      }
    }
    return null;
  }

  Rule? findRule(String label) {
    for (final rule in rules) {
      if (rule.header.label == label) {
        return rule;
      }
    }
    return null;
  }
}

final class FunctionDefinition {
  const FunctionDefinition({
    required this.name,
    required this.params,
    required this.arity,
    this.signature,
    required this.bodySource,
    this.bodyPayload,
    this.bodyParseJob,
    this.bodyAst,
    required this.source,
    required this.sourceSpan,
    required this.bodySpan,
  });

  final String name;
  final List<String> params;
  final int arity;
  final CallableSignature? signature;
  final String bodySource;
  final Object? bodyPayload;
  final StagedParseJob? bodyParseJob;
  final Object? bodyAst;
  final String source;
  final SourceSpan sourceSpan;
  final SourceSpan bodySpan;

  factory FunctionDefinition.fromJson(JsonObject json) {
    final parseJob = json['body_parse_job'];
    final signatureValue = json['signature'];
    final signature = signatureValue == null
        ? null
        : CallableSignature.fromJson(_jsonObject(signatureValue, 'signature'));
    return FunctionDefinition(
      name: _stringField(json, 'name'),
      params: signature?.positionalParams ?? _stringList(json, 'params'),
      arity: signature?.minArity ?? _intField(json, 'arity'),
      signature: signature,
      bodySource: _stringField(json, 'body_source'),
      bodyPayload: json['body_payload'],
      bodyParseJob: parseJob == null
          ? null
          : StagedParseJob.fromJson(_jsonObject(parseJob, 'body_parse_job')),
      bodyAst: json['body_ast'],
      source: _stringField(json, 'source'),
      sourceSpan: SourceSpan.fromJson(_objectField(json, 'source_span')),
      bodySpan: SourceSpan.fromJson(_objectField(json, 'body_span')),
    );
  }

  JsonObject toJson() {
    return {
      'name': name,
      if (signature == null) 'params': params,
      if (signature == null) 'arity': arity,
      if (signature != null) 'signature': signature!.toJson(),
      'body_source': bodySource,
      if (bodyPayload != null) 'body_payload': bodyPayload,
      if (bodyParseJob != null) 'body_parse_job': bodyParseJob!.toJson(),
      if (bodyAst != null) 'body_ast': bodyAst,
      'source': source,
      'source_span': sourceSpan.toJson(),
      'body_span': bodySpan.toJson(),
    };
  }
}

final class CallableSignature {
  const CallableSignature({
    required this.kind,
    required this.version,
    required this.positionalParams,
    required this.restParam,
    required this.minArity,
    required this.maxArity,
  });

  final String kind;
  final int version;
  final List<String> positionalParams;
  final String restParam;
  final int minArity;
  final int? maxArity;

  factory CallableSignature.fromJson(JsonObject json) {
    return CallableSignature(
      kind: _stringField(json, 'kind'),
      version: _intField(json, 'version'),
      positionalParams: _stringList(json, 'positional_params'),
      restParam: _stringField(json, 'rest_param'),
      minArity: _intField(json, 'min_arity'),
      maxArity: _optionalIntField(json, 'max_arity'),
    );
  }

  JsonObject toJson() {
    return {
      'kind': kind,
      'version': version,
      'positional_params': positionalParams,
      'rest_param': restParam,
      'min_arity': minArity,
      'max_arity': maxArity,
    };
  }
}

final class SourceSpan {
  const SourceSpan({required this.lineStart, required this.lineEnd});

  final int lineStart;
  final int lineEnd;

  factory SourceSpan.fromJson(JsonObject json) {
    return SourceSpan(
      lineStart: _intField(json, 'line_start'),
      lineEnd: _intField(json, 'line_end'),
    );
  }

  JsonObject toJson() {
    return {'line_start': lineStart, 'line_end': lineEnd};
  }
}

final class StagedSourceSpan {
  const StagedSourceSpan({
    required this.start,
    required this.end,
    required this.lineStart,
    required this.lineEnd,
  });

  final int start;
  final int end;
  final int lineStart;
  final int lineEnd;

  factory StagedSourceSpan.fromJson(JsonObject json) {
    return StagedSourceSpan(
      start: _intField(json, 'start'),
      end: _intField(json, 'end'),
      lineStart: _intField(json, 'line_start'),
      lineEnd: _intField(json, 'line_end'),
    );
  }

  JsonObject toJson() {
    return {
      'start': start,
      'end': end,
      'line_start': lineStart,
      'line_end': lineEnd,
    };
  }
}

final class StagedParseJob {
  const StagedParseJob({
    this.version,
    required this.jobId,
    required this.parentAstPath,
    required this.nodeKind,
    required this.payloadKind,
    this.functionName,
    this.params,
    this.arity,
    this.signature,
    required this.text,
    required this.sourceSpan,
    required this.parserSpecId,
    required this.topRule,
    required this.resultPolicy,
    required this.resultField,
    required this.failurePolicy,
    this.diagnosticOwner,
  });

  final int? version;
  final String jobId;
  final List<String> parentAstPath;
  final String nodeKind;
  final String payloadKind;
  final String? functionName;
  final List<String>? params;
  final int? arity;
  final CallableSignature? signature;
  final String text;
  final StagedSourceSpan sourceSpan;
  final String parserSpecId;
  final String topRule;
  final String resultPolicy;
  final String resultField;
  final String failurePolicy;
  final String? diagnosticOwner;

  String get kind => 'parse_job';

  factory StagedParseJob.fromJson(JsonObject json) {
    final kind = _stringField(json, 'kind');
    if (kind != 'parse_job') {
      throw FormatException(
        'staged parse job kind must be parse_job, got $kind',
      );
    }
    return StagedParseJob(
      version: _optionalIntField(json, 'version'),
      jobId: _stringField(json, 'job_id'),
      parentAstPath: _stringList(json, 'parent_ast_path'),
      nodeKind: _stringField(json, 'node_kind'),
      payloadKind: _stringField(json, 'payload_kind'),
      functionName: _optionalStringField(json, 'function_name'),
      params: _optionalStringList(json, 'params'),
      arity: _optionalIntField(json, 'arity'),
      signature: json['signature'] == null
          ? null
          : CallableSignature.fromJson(
              _jsonObject(json['signature'], 'signature'),
            ),
      text: _stringField(json, 'text'),
      sourceSpan: StagedSourceSpan.fromJson(_objectField(json, 'source_span')),
      parserSpecId: _stringField(json, 'parser_spec_id'),
      topRule: _stringField(json, 'top_rule'),
      resultPolicy: _stringField(json, 'result_policy'),
      resultField: _stringField(json, 'result_field'),
      failurePolicy: _stringField(json, 'failure_policy'),
      diagnosticOwner: _optionalStringField(json, 'diagnostic_owner'),
    );
  }

  JsonObject toJson() {
    return {
      'kind': 'parse_job',
      if (version != null) 'version': version,
      'job_id': jobId,
      'parent_ast_path': parentAstPath,
      'node_kind': nodeKind,
      'payload_kind': payloadKind,
      if (functionName != null) 'function_name': functionName,
      if (params != null) 'params': params,
      if (arity != null) 'arity': arity,
      if (signature != null) 'signature': signature!.toJson(),
      'text': text,
      'source_span': sourceSpan.toJson(),
      'parser_spec_id': parserSpecId,
      'top_rule': topRule,
      'result_policy': resultPolicy,
      'result_field': resultField,
      'failure_policy': failurePolicy,
      if (diagnosticOwner != null) 'diagnostic_owner': diagnosticOwner,
    };
  }
}

final class Rule {
  const Rule({required this.header, required this.body});

  final RuleHeader header;
  final List<BodyElement> body;

  factory Rule.fromJson(JsonObject json) {
    return Rule(
      header: RuleHeader.fromJson(_objectField(json, 'header')),
      body: _objectList(json, 'body', BodyElement.fromJson),
    );
  }

  JsonObject toJson() {
    return {
      'header': header.toJson(),
      'body': [for (final element in body) element.toJson()],
    };
  }
}

final class RuleHeader {
  const RuleHeader({
    required this.label,
    required this.isTop,
    required this.mode,
    required this.rest,
    required this.line,
  });

  final String label;
  final bool isTop;
  final RuleMode mode;
  final String rest;
  final int line;

  factory RuleHeader.fromJson(JsonObject json) {
    return RuleHeader(
      label: _stringField(json, 'label'),
      isTop: _boolField(json, 'is_top'),
      mode: RuleMode.fromJson(json['mode']),
      rest: _stringField(json, 'rest'),
      line: _intField(json, 'line'),
    );
  }

  JsonObject toJson() {
    return {
      'label': label,
      'is_top': isTop,
      'mode': mode.toJson(),
      'rest': rest,
      'line': line,
    };
  }
}

final class RuleMode {
  const RuleMode._(this.name, {this.min, this.max});

  static const defaultMode = RuleMode._('Default');
  static const and = RuleMode._('And');
  static const andPlus = RuleMode._('AndPlus');
  static const or = RuleMode._('Or');
  static const orPlus = RuleMode._('OrPlus');
  static const single = RuleMode._('Single');
  static const pipe = RuleMode._('Pipe');
  static const plus = RuleMode._('Plus');
  static const star = RuleMode._('Star');
  static const optional = RuleMode._('Optional');

  factory RuleMode.andBounded({required int min, int? max}) {
    return RuleMode._('AndBounded', min: min, max: max);
  }

  factory RuleMode.orBounded({required int min, int? max}) {
    return RuleMode._('OrBounded', min: min, max: max);
  }

  final String name;
  final int? min;
  final int? max;

  factory RuleMode.fromJson(Object? json) {
    if (json is String) {
      return switch (json) {
        'Default' => defaultMode,
        'And' => and,
        'AndPlus' => andPlus,
        'Or' => or,
        'OrPlus' => orPlus,
        'Single' => single,
        'Pipe' => pipe,
        'Plus' => plus,
        'Star' => star,
        'Optional' => optional,
        _ => throw FormatException('unsupported rule mode $json'),
      };
    }

    final object = _jsonObject(json, 'mode');
    if (object.length != 1) {
      throw const FormatException(
        'bounded rule mode must have exactly one key',
      );
    }
    final entry = object.entries.single;
    final bounds = _jsonObject(entry.value, entry.key);
    final min = _intField(bounds, 'min');
    final max = _optionalIntField(bounds, 'max');
    return switch (entry.key) {
      'AndBounded' => RuleMode.andBounded(min: min, max: max),
      'OrBounded' => RuleMode.orBounded(min: min, max: max),
      _ => throw FormatException('unsupported bounded rule mode ${entry.key}'),
    };
  }

  Object toJson() {
    if (name == 'AndBounded' || name == 'OrBounded') {
      return {
        name: {'min': min, 'max': max},
      };
    }
    return name;
  }

  bool get isAnd {
    return name == 'And' ||
        name == 'AndPlus' ||
        name == 'AndBounded' ||
        name == 'Pipe' ||
        name == 'Single';
  }

  bool get isRepetition {
    return name == 'Default' ||
        name == 'Star' ||
        name == 'Plus' ||
        name == 'OrPlus' ||
        name == 'AndPlus' ||
        name == 'Optional' ||
        name == 'OrBounded' ||
        name == 'AndBounded';
  }

  int? get repMin {
    return switch (name) {
      'Default' || 'Star' || 'Optional' => 0,
      'Plus' || 'OrPlus' || 'AndPlus' => 1,
      'OrBounded' || 'AndBounded' => min,
      _ => null,
    };
  }

  int? get repMax {
    return switch (name) {
      'Optional' => 1,
      'OrBounded' || 'AndBounded' => max,
      _ => null,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is RuleMode &&
        other.name == name &&
        other.min == min &&
        other.max == max;
  }

  @override
  int get hashCode => Object.hash(name, min, max);
}

final class BodyElement {
  const BodyElement({
    required this.kind,
    required this.source,
    required this.line,
  });

  final BodyElementKind kind;
  final String source;
  final int line;

  factory BodyElement.fromJson(JsonObject json) {
    return BodyElement(
      kind: BodyElementKind.fromJson(_objectField(json, 'kind')),
      source: _stringField(json, 'source'),
      line: _intField(json, 'line'),
    );
  }

  JsonObject toJson() {
    return {'kind': kind.toJson(), 'source': source, 'line': line};
  }
}

sealed class BodyElementKind {
  const BodyElementKind(this.kind);

  final String kind;

  factory BodyElementKind.fromJson(JsonObject json) {
    final kind = _stringField(json, 'kind');
    return switch (kind) {
      'regex' => RegexBodyElementKind(pattern: _stringField(json, 'pattern')),
      'action_edge' => ActionEdgeBodyElementKind(
        targets: _objectList(json, 'targets', EdgeTarget.fromJson),
        code: _optionalStringField(json, 'code'),
        fluentChain: _objectList(
          json,
          'fluent_chain',
          FluentCall.fromJson,
          defaultValue: const [],
        ),
      ),
      'blind_edge' => BlindEdgeBodyElementKind(
        target: _stringField(json, 'target'),
        code: _optionalStringField(json, 'code'),
        fluentChain: _objectList(
          json,
          'fluent_chain',
          FluentCall.fromJson,
          defaultValue: const [],
        ),
      ),
      'code_block' => CodeBlockBodyElementKind(
        lifecycle: _stringField(json, 'lifecycle'),
        code: _stringField(json, 'code'),
      ),
      'plain_block' => PlainBlockBodyElementKind(
        code: _stringField(json, 'code'),
      ),
      'split_marker' => SplitMarkerBodyElementKind(
        marker: _stringField(json, 'marker'),
      ),
      'lifecycle_marker' => LifecycleMarkerBodyElementKind(
        marker: _stringField(json, 'marker'),
      ),
      'fluent_chain' => FluentChainBodyElementKind(
        calls: _objectList(json, 'calls', FluentCall.fromJson),
      ),
      'conditional' => ConditionalBodyElementKind(
        word: _stringField(json, 'word'),
      ),
      'raw' => RawBodyElementKind(text: _stringField(json, 'text')),
      _ => throw FormatException('unsupported body element kind $kind'),
    };
  }

  JsonObject toJson();
}

final class RegexBodyElementKind extends BodyElementKind {
  const RegexBodyElementKind({required this.pattern}) : super('regex');

  final String pattern;

  @override
  JsonObject toJson() => {'kind': kind, 'pattern': pattern};
}

final class ActionEdgeBodyElementKind extends BodyElementKind {
  const ActionEdgeBodyElementKind({
    required this.targets,
    this.code,
    this.fluentChain = const [],
  }) : super('action_edge');

  final List<EdgeTarget> targets;
  final String? code;
  final List<FluentCall> fluentChain;

  @override
  JsonObject toJson() {
    return {
      'kind': kind,
      'targets': [for (final target in targets) target.toJson()],
      'code': code,
      'fluent_chain': [for (final call in fluentChain) call.toJson()],
    };
  }
}

final class BlindEdgeBodyElementKind extends BodyElementKind {
  const BlindEdgeBodyElementKind({
    required this.target,
    this.code,
    this.fluentChain = const [],
  }) : super('blind_edge');

  final String target;
  final String? code;
  final List<FluentCall> fluentChain;

  @override
  JsonObject toJson() {
    return {
      'kind': kind,
      'target': target,
      'code': code,
      'fluent_chain': [for (final call in fluentChain) call.toJson()],
    };
  }
}

final class CodeBlockBodyElementKind extends BodyElementKind {
  const CodeBlockBodyElementKind({required this.lifecycle, required this.code})
    : super('code_block');

  final String lifecycle;
  final String code;

  @override
  JsonObject toJson() => {'kind': kind, 'lifecycle': lifecycle, 'code': code};
}

final class PlainBlockBodyElementKind extends BodyElementKind {
  const PlainBlockBodyElementKind({required this.code}) : super('plain_block');

  final String code;

  @override
  JsonObject toJson() => {'kind': kind, 'code': code};
}

final class SplitMarkerBodyElementKind extends BodyElementKind {
  const SplitMarkerBodyElementKind({required this.marker})
    : super('split_marker');

  final String marker;

  @override
  JsonObject toJson() => {'kind': kind, 'marker': marker};
}

final class LifecycleMarkerBodyElementKind extends BodyElementKind {
  const LifecycleMarkerBodyElementKind({required this.marker})
    : super('lifecycle_marker');

  final String marker;

  @override
  JsonObject toJson() => {'kind': kind, 'marker': marker};
}

final class FluentChainBodyElementKind extends BodyElementKind {
  const FluentChainBodyElementKind({required this.calls})
    : super('fluent_chain');

  final List<FluentCall> calls;

  @override
  JsonObject toJson() {
    return {
      'kind': kind,
      'calls': [for (final call in calls) call.toJson()],
    };
  }
}

final class ConditionalBodyElementKind extends BodyElementKind {
  const ConditionalBodyElementKind({required this.word}) : super('conditional');

  final String word;

  @override
  JsonObject toJson() => {'kind': kind, 'word': word};
}

final class RawBodyElementKind extends BodyElementKind {
  const RawBodyElementKind({required this.text}) : super('raw');

  final String text;

  @override
  JsonObject toJson() => {'kind': kind, 'text': text};
}

final class EdgeTarget {
  const EdgeTarget({required this.label, this.index = 0});

  final String label;
  final int index;

  factory EdgeTarget.fromJson(JsonObject json) {
    return EdgeTarget(
      label: _stringField(json, 'label'),
      index: _intField(json, 'index'),
    );
  }

  JsonObject toJson() => {'label': label, 'index': index};
}

final class FluentCall {
  const FluentCall({required this.method, required this.args});

  final String method;
  final String args;

  factory FluentCall.fromJson(JsonObject json) {
    return FluentCall(
      method: _stringField(json, 'method'),
      args: _stringField(json, 'args'),
    );
  }

  JsonObject toJson() => {'method': method, 'args': args};
}

JsonObject _jsonObject(Object? value, String context) {
  if (value is! Map) {
    throw FormatException('$context must be a JSON object');
  }
  return value.cast<String, Object?>();
}

JsonObject _objectField(JsonObject json, String field) {
  return _jsonObject(json[field], field);
}

String _stringField(JsonObject json, String field) {
  final value = json[field];
  if (value is! String) {
    throw FormatException('$field must be a string');
  }
  return value;
}

String? _optionalStringField(JsonObject json, String field) {
  final value = json[field];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw FormatException('$field must be a string when present');
  }
  return value;
}

int _intField(JsonObject json, String field) {
  final value = json[field];
  if (value is! int) {
    throw FormatException('$field must be an integer');
  }
  return value;
}

int? _optionalIntField(JsonObject json, String field) {
  final value = json[field];
  if (value == null) {
    return null;
  }
  if (value is! int) {
    throw FormatException('$field must be an integer when present');
  }
  return value;
}

bool _boolField(JsonObject json, String field) {
  final value = json[field];
  if (value is! bool) {
    throw FormatException('$field must be a boolean');
  }
  return value;
}

List<String> _stringList(JsonObject json, String field) {
  final value = json[field];
  if (value is! List) {
    throw FormatException('$field must be an array');
  }
  return [for (final item in value) _stringListItem(item, field)];
}

List<String>? _optionalStringList(JsonObject json, String field) {
  final value = json[field];
  if (value == null) {
    return null;
  }
  if (value is! List) {
    throw FormatException('$field must be an array when present');
  }
  return [for (final item in value) _stringListItem(item, field)];
}

String _stringListItem(Object? value, String field) {
  if (value is! String) {
    throw FormatException('$field must contain only strings');
  }
  return value;
}

List<T> _objectList<T>(
  JsonObject json,
  String field,
  T Function(JsonObject json) build, {
  List<T>? defaultValue,
}) {
  final value = json[field];
  if (value == null && defaultValue != null) {
    return defaultValue;
  }
  if (value is! List) {
    throw FormatException('$field must be an array');
  }
  return [for (final item in value) build(_jsonObject(item, field))];
}
