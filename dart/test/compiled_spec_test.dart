import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('compiles parsed rules into descriptor-shaped state', () {
    final parsed = parseSpec(r'''
Top:: OR
 /x/ -> Child { return(normalize(entry_text())) }
 I { set(out, "start") }
 E.return(out)

Child:
 /[a-z]+/
''');
    final spec = SpecFile(
      functions: [
        _function(
          name: 'normalize',
          params: const ['value'],
          bodySource: 'return(value)',
          bodyAst: parseActionBlock('return(value)').toJson(),
        ),
      ],
      rules: parsed.rules,
    );

    final compiled = compileSpec(spec);

    expect(compiled.definitionOrder, ['Top', 'Child']);
    expect(compiled.compiledRuleOrder, ['Top', 'Child']);
    expect(compiled.redefinedRuleLabels, isEmpty);
    expect(compiled.functionRegistry.names, ['normalize']);

    final top = compiled.rule('Top')!;
    expect(top.regexPatterns, ['x']);
    expect(top.modeMetadata.name, 'Or');
    expect(top.modeMetadata.isTop, isTrue);
    expect(top.modeMetadata.isAnd, isFalse);
    expect(top.dependencyRefs.single.toJson(), {'label': 'Child', 'idx': 0});
    expect(top.lifecycleActionPayloads.map((payload) => payload.lifecycle), [
      'I',
      'E',
    ]);

    final edgePayload = top.actionEdges.single.actionPayload!;
    expect(edgePayload.actionAst.statements, hasLength(1));
    expect(
      edgePayload.contracts.contracts.any(
        (contract) =>
            contract.family == 'user_function' &&
            contract.canonicalName == 'normalize',
      ),
      isTrue,
    );

    final dependencyEntry =
        compiled.dependencyRegexState.dependencyRegexMap['Top']!;
    expect(dependencyEntry.patterns, ['[a-z]+']);
    expect(dependencyEntry.combinedPattern, '(?:[a-z]+)');

    final descriptor = compiled.toDescriptorJson();
    expect(descriptor.keys, [
      'spec',
      'functions',
      'dependency_regex_map',
      'meta',
    ]);

    final descriptorSpec = descriptor['spec']! as Map<String, Object?>;
    final descriptorTop = descriptorSpec['Top']! as Map<String, Object?>;
    expect(descriptorTop['re'], ['x']);
    expect(descriptorTop['dependency_refs'], [
      {'label': 'Child', 'idx': 0},
    ]);
    expect(descriptorTop['handler'], isA<Map<String, Object?>>());

    final functions = descriptor['functions']! as Map<String, Object?>;
    expect(functions.keys, ['normalize']);

    final dependencyMap =
        descriptor['dependency_regex_map']! as Map<String, Object?>;
    expect(dependencyMap.keys, ['Top']);

    final meta = descriptor['meta']! as Map<String, Object?>;
    expect(meta['descriptor_model'], 'compiled_descriptor_state');
    expect(meta['definition_order'], ['Top', 'Child']);
    expect(meta['compiled_rule_order'], ['Top', 'Child']);
    expect(meta['function_order'], ['normalize']);
    expect(meta['function_count'], 1);
  });

  test('preserves staged function descriptor shape through runtime', () {
    const normalizeBody = 'return(trim(value))';
    const pairBody = 'return(hash("left", left, "right", right))';
    final source = [
      'fn normalize(value) {$normalizeBody}',
      'fn pair(left, right) {$pairBody}',
      'Top::',
      ' /x/',
      ' E { return(hash("name", normalize(" x "), "pair", pair("a", "b"))) }',
    ].join('\n');
    final nodes = [
      _definitionNode(source, 'normalize', const ['value'], normalizeBody),
      _definitionNode(source, 'pair', const ['left', 'right'], pairBody),
    ];

    final spec = parseSpecWithStagedUserFunctionDefinitionAsts(source, nodes);
    final compiled = compileSpec(spec);
    final descriptor = compiled.toDescriptorJson();

    expect(spec.functions.map((function) => function.name), [
      'normalize',
      'pair',
    ]);
    expect(compiled.functionRegistry.bodyParseJobs.map((job) => job.jobId), [
      _expectedJobId(spec.functions[0].bodyParseJob!),
      _expectedJobId(spec.functions[1].bodyParseJob!),
    ]);

    final functions = descriptor['functions']! as Map<String, Object?>;
    expect(functions.keys, ['normalize', 'pair']);
    final normalize = functions['normalize']! as Map<String, Object?>;
    final pair = functions['pair']! as Map<String, Object?>;

    _expectFunctionDescriptor(
      normalize,
      index: 0,
      name: 'normalize',
      params: const ['value'],
      bodySource: normalizeBody,
      job: spec.functions[0].bodyParseJob!,
    );
    _expectFunctionDescriptor(
      pair,
      index: 1,
      name: 'pair',
      params: const ['left', 'right'],
      bodySource: pairBody,
      job: spec.functions[1].bodyParseJob!,
    );

    final meta = descriptor['meta']! as Map<String, Object?>;
    expect(meta['function_order'], ['normalize', 'pair']);
    expect(meta['function_count'], 2);

    final result = LinkedSpecRuntimeEngine(compiled).parse('x');
    expect(result.value, {
      'name': 'x',
      'pair': {'left': 'a', 'right': 'b'},
    });
  });

  test(
    'uses last-definition order when validation is deliberately skipped',
    () {
      final first = Rule(
        header: const RuleHeader(
          label: 'Top',
          isTop: true,
          mode: RuleMode.defaultMode,
          rest: '',
          line: 1,
        ),
        body: const [
          BodyElement(
            kind: RegexBodyElementKind(pattern: 'first'),
            source: '/first/',
            line: 2,
          ),
        ],
      );
      final second = Rule(
        header: const RuleHeader(
          label: 'Top',
          isTop: true,
          mode: RuleMode.defaultMode,
          rest: '',
          line: 4,
        ),
        body: const [
          BodyElement(
            kind: RegexBodyElementKind(pattern: 'second'),
            source: '/second/',
            line: 5,
          ),
        ],
      );

      final compiled = compileSpec(
        SpecFile(rules: [first, second]),
        validateSource: false,
      );

      expect(compiled.definitionOrder, ['Top', 'Top']);
      expect(compiled.compiledRuleOrder, ['Top']);
      expect(compiled.redefinedRuleLabels, ['Top']);
      expect(compiled.rule('Top')!.regexPatterns, ['second']);
    },
  );

  test('reuses source validation before building compiled state', () {
    final missing = parseSpec('Top::\n -> Ghost');

    expect(
      () => compileSpec(missing),
      throwsA(
        isA<SpecValidationException>().having(
          (error) => error.message,
          'message',
          contains('undefined rule'),
        ),
      ),
    );
  });
}

void _expectFunctionDescriptor(
  Map<String, Object?> function, {
  required int index,
  required String name,
  required List<String> params,
  required String bodySource,
  required StagedParseJob job,
}) {
  expect(function['name'], name);
  expect(function['params'], params);
  expect(function['arity'], params.length);
  expect(function['body_source'], bodySource);

  final payload = function['body_payload']! as Map<String, Object?>;
  expect(payload['kind'], 'staged_payload');
  expect(payload['node_kind'], 'function_definition');
  expect(payload['payload_kind'], 'function_body');
  expect(payload['parent_ast_path'], ['functions', '$index', 'body_source']);
  expect(payload['function_name'], name);
  expect(payload['params'], params);
  expect(payload['arity'], params.length);
  expect(payload['text'], bodySource);
  expect(payload['source_span'], job.sourceSpan.toJson());

  final jobJson = function['body_parse_job']! as Map<String, Object?>;
  expect(jobJson['kind'], 'parse_job');
  expect(jobJson['job_id'], _expectedJobId(job));
  expect(jobJson['parent_ast_path'], ['functions', '$index', 'body_source']);
  expect(jobJson['node_kind'], 'function_definition');
  expect(jobJson['payload_kind'], 'function_body');
  expect(jobJson['function_name'], name);
  expect(jobJson['params'], params);
  expect(jobJson['arity'], params.length);
  expect(jobJson['text'], bodySource);
  expect(jobJson['source_span'], job.sourceSpan.toJson());
  expect(jobJson['parser_spec_id'], actionIrBodySpecId);
  expect(jobJson['top_rule'], actionIrBodyTopRule);
  expect(jobJson['result_policy'], 'replace_field');
  expect(jobJson['result_field'], 'body_ast');
  expect(jobJson['failure_policy'], 'fail');
  expect(jobJson['diagnostic_owner'], 'function_body');

  final bodyAst = function['body_ast']! as Map<String, Object?>;
  expect(bodyAst['kind'], 'action_block');
  final statements = bodyAst['statements']! as List<Object?>;
  expect(statements, isNotEmpty);
  final firstStatement = statements.first! as Map<String, Object?>;
  final expr = firstStatement['expr']! as Map<String, Object?>;
  expect(expr['name'], 'return');
}

String _expectedJobId(StagedParseJob job) {
  return 'parse_job:function_body:${job.parentAstPath.join(".")}:'
      '${job.parserSpecId}:${job.topRule}:'
      '${job.sourceSpan.start}-${job.sourceSpan.end}';
}

FunctionDefinition _function({
  required String name,
  required List<String> params,
  required String bodySource,
  Object? bodyAst,
}) {
  return FunctionDefinition(
    name: name,
    params: params,
    arity: params.length,
    bodySource: bodySource,
    bodyPayload: {
      'kind': 'staged_payload',
      'node_kind': 'function_definition',
      'payload_kind': 'function_body',
      'parent_ast_path': ['functions', '0', 'body_source'],
      'function_name': name,
      'params': params,
      'arity': params.length,
      'text': bodySource,
    },
    bodyParseJob: StagedParseJob(
      version: 1,
      jobId: 'parse_job:function_body:functions.0.body_source',
      parentAstPath: const ['functions', '0', 'body_source'],
      nodeKind: 'function_definition',
      payloadKind: 'function_body',
      functionName: name,
      params: params,
      arity: params.length,
      text: bodySource,
      sourceSpan: const StagedSourceSpan(
        start: 0,
        end: 1,
        lineStart: 1,
        lineEnd: 1,
      ),
      parserSpecId: 'actionir-body.spec',
      topRule: 'action_block',
      resultPolicy: 'replace_field',
      resultField: 'body_ast',
      failurePolicy: 'fail',
      diagnosticOwner: 'function_body',
    ),
    bodyAst: bodyAst,
    source: 'fn $name(${params.join(", ")}) { $bodySource }',
    sourceSpan: const SourceSpan(lineStart: 1, lineEnd: 1),
    bodySpan: const SourceSpan(lineStart: 1, lineEnd: 1),
  );
}

Map<String, Object?> _definitionNode(
  String source,
  String name,
  List<String> params,
  String bodySource,
) {
  final sourceStart = source.indexOf('fn $name');
  if (sourceStart < 0) {
    throw StateError('missing function $name');
  }
  final bodyStart = source.indexOf(bodySource, sourceStart);
  if (bodyStart < 0) {
    throw StateError('missing body for $name');
  }
  final bodyEnd = bodyStart + bodySource.length;
  final sourceEnd = source.indexOf('}', bodyEnd) + 1;
  final sourceText = source.substring(sourceStart, sourceEnd);
  final sourceSpan = _span(source, sourceStart, sourceEnd);
  final bodySpan = _span(source, bodyStart, bodyEnd);

  return {
    'type': 'function_definition',
    'kind': 'user_function_definition',
    'version': 1,
    'name': name,
    'params': params,
    'arity': params.length,
    'source_text': sourceText,
    'source_span': sourceSpan,
    'body_source': bodySource,
    'body_span': bodySpan,
    'body_payload': {
      'kind': 'staged_payload',
      'version': 1,
      'node_kind': 'function_definition',
      'payload_kind': 'function_body',
      'parent_ast_path': [
        'functions',
        '__pending_source_order__',
        'body_source',
      ],
      'function_name': name,
      'params': params,
      'arity': params.length,
      'text': bodySource,
      'source_span': bodySpan,
      'provenance': [
        {'kind': 'source_slice', 'source_span': bodySpan},
      ],
    },
    'body_parse_job': {
      'kind': 'parse_job',
      'version': 1,
      'job_id': 'parse_job:function_body:$name:actionir-body.spec:action_block',
      'parent_ast_path': [
        'functions',
        '__pending_source_order__',
        'body_source',
      ],
      'node_kind': 'function_definition',
      'payload_kind': 'function_body',
      'function_name': name,
      'params': params,
      'arity': params.length,
      'text': bodySource,
      'source_span': bodySpan,
      'parser_spec_id': actionIrBodySpecId,
      'top_rule': actionIrBodyTopRule,
      'result_policy': 'replace_field',
      'result_field': 'body_ast',
      'failure_policy': 'fail',
      'diagnostic_owner': 'function_body',
    },
  };
}

Map<String, Object?> _span(String source, int start, int end) {
  return {
    'start': start,
    'end': end,
    'line_start': _lineAt(source, start),
    'line_end': _lineAt(source, end),
  };
}

int _lineAt(String source, int offset) {
  var line = 1;
  for (var index = 0; index < offset && index < source.length; index += 1) {
    if (source.codeUnitAt(index) == 10) {
      line += 1;
    }
  }
  return line;
}
