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
