// FUTURE-PARITY-BACKLOG.19.4.2 — Dart `map_leaves!` mutation contract.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/cli/primary_cli.dart';
import 'package:test/test.dart';

Map<String, Object?> _jsonContract(String name) {
  return (jsonDecode(File('../capability_conformance/$name').readAsStringSync())
      as Map<String, Object?>);
}

List<Map<String, Object?>> _objects(Object? value) {
  return [
    for (final item in value! as List<Object?>)
      (item! as Map).cast<String, Object?>(),
  ];
}

String _sourceForAction(String action) =>
    '''
Top::
 -> Done { $action }

Done::
 /[a-z]+/
''';

LinkedSpecRuntimeEngine _engineForAction(String action) {
  return _engineForSource(_sourceForAction(action));
}

LinkedSpecRuntimeEngine _engineForSource(String source) {
  return LinkedSpecRuntimeEngine(
    compileSpec(parseSpecWithStagedUserFunctionDefinitions(source)),
  );
}

RuntimeInterpreterException _runtimeFailure(String action) {
  try {
    _engineForAction(action).parse('xhello');
    fail('action unexpectedly succeeded: $action');
  } on RuntimeInterpreterException catch (error) {
    return error;
  }
}

String _scalarSlice(String source, int start, int end) {
  return String.fromCharCodes(source.runes.toList().sublist(start, end));
}

CompiledSpec _compiledWithCorruptReceiverMutation() {
  final compiled = compileSpec(
    parseSpec('''
Top::
 -> Done { tree = { "a" : "A" }; return(tree.map_leaves!() { return(value) }) }

Done::
 /[a-z]+/
'''),
  );
  final top = compiled.rulesByLabel['Top']!;
  final edge = top.actionEdges.single;
  final payload = edge.actionPayload!;
  final statements = payload.actionAst.statements;
  final returnCall = statements.last.expr as ActionCallExpr;
  final chain = returnCall.args.single.value as ActionReceiverMutationChainExpr;
  final corruptChain = ActionReceiverMutationChainExpr(
    source: chain.source,
    sourceSpan: chain.sourceSpan,
    receiver: ActionReceiverMutationBindingReference(
      source: 'corrupt',
      sourceSpan: chain.receiver.sourceSpan,
      name: chain.receiver.name,
    ),
    mutation: chain.mutation,
    continuation: chain.continuation,
  );
  final corruptReturn = ActionCallExpr(
    source: returnCall.source,
    sourceSpan: returnCall.sourceSpan,
    name: returnCall.name,
    sourceMethod: returnCall.sourceMethod,
    args: [ActionPositionalArgument(corruptChain)],
  );
  final corruptBlock = ActionBlock(
    source: payload.actionAst.source,
    sourceSpan: payload.actionAst.sourceSpan,
    statements: [
      ...statements.take(statements.length - 1),
      ActionStatement(
        source: statements.last.source,
        sourceSpan: statements.last.sourceSpan,
        expr: corruptReturn,
        dropsValue: statements.last.dropsValue,
      ),
    ],
  );
  final corruptPayload = CompiledActionPayload(
    role: payload.role,
    line: payload.line,
    source: payload.source,
    code: payload.code,
    actionAst: corruptBlock,
    contracts: payload.contracts,
    lifecycle: payload.lifecycle,
  );
  final corruptEdge = CompiledActionEdge(
    line: edge.line,
    source: edge.source,
    targets: edge.targets,
    regexIndex: edge.regexIndex,
    childRegexIndex: edge.childRegexIndex,
    hasParentRegex: edge.hasParentRegex,
    selectorKind: edge.selectorKind,
    authoredSelector: edge.authoredSelector,
    targetSlotId: edge.targetSlotId,
    sourceId: edge.sourceId,
    fluentChain: edge.fluentChain,
    code: edge.code,
    actionPayload: corruptPayload,
  );
  final corruptTop = CompiledRule(
    label: top.label,
    header: top.header,
    modeMetadata: top.modeMetadata,
    regexPatterns: top.regexPatterns,
    regexSlots: top.regexSlots,
    captureGaps: top.captureGaps,
    dependencyRefs: top.dependencyRefs,
    actionEdges: [corruptEdge],
    blindEdges: top.blindEdges,
    lifecycleActionPayloads: top.lifecycleActionPayloads,
    plainActionPayloads: top.plainActionPayloads,
    bodyElements: top.bodyElements,
  );
  return CompiledSpec(
    definitionOrder: compiled.definitionOrder,
    compiledRuleOrder: compiled.compiledRuleOrder,
    rulesByLabel: {...compiled.rulesByLabel, 'Top': corruptTop},
    redefinedRuleLabels: compiled.redefinedRuleLabels,
    functionRegistry: compiled.functionRegistry,
    dependencyRegexState: compiled.dependencyRegexState,
  );
}

void main() {
  final contract = _jsonContract('map_leaves_mutation_contract.json');
  final composition = _jsonContract(
    'write_map_leaves_composition_contract.json',
  );

  test('projects the exact frozen syntax and typed AST inventory', () {
    expect(contract['contract_id'], 'linkedspec-map-leaves-mutation-v1');
    final valid = _objects(contract['valid_syntax_cases']);
    final invalid = _objects(contract['invalid_syntax_cases']);
    final excluded = _objects(contract['excluded_syntax_cases']);
    expect(valid, hasLength(4));
    expect(invalid, hasLength(14));
    expect(excluded, hasLength(5));

    for (final fixture in valid) {
      final expression = parseActionExpression(fixture['source']! as String);
      expect(
        expression,
        isA<ActionReceiverMutationChainExpr>(),
        reason: fixture['id']! as String,
      );
      final chain = expression as ActionReceiverMutationChainExpr;
      expect(chain.receiver.kind, 'binding_reference');
      expect(chain.mutation.kind, 'receiver_mutation_call');
      expect(chain.mutation.method, 'map_leaves');
      expect(chain.mutation.sourceMethod, 'map_leaves!');
      expect(chain.mutation.callback.kind, 'block_value');
      expect(chain.mutation.callback.body.kind, 'action_block');
      expect(
        chain.continuation.every((call) => call.kind == 'fluent_call'),
        isTrue,
      );

      if (fixture['expected_ast']
          case final Map<Object?, Object?> expectedRaw) {
        final expected = expectedRaw.cast<String, Object?>();
        final actual = chain.toJson();
        expect(actual['kind'], expected['kind']);
        expect(actual['source'], expected['source']);
        expect(actual['source_span'], expected['source_span']);
        expect(actual['receiver'], expected['receiver']);
        final actualMutation = (actual['mutation']! as Map)
            .cast<String, Object?>();
        final expectedMutation = (expected['mutation']! as Map)
            .cast<String, Object?>();
        for (final field in [
          'kind',
          'method',
          'source_method',
          'source',
          'source_span',
          'method_span',
          'args_span',
        ]) {
          expect(
            actualMutation[field],
            expectedMutation[field],
            reason: '${fixture['id']} mutation $field',
          );
        }
        final actualCallback = (actualMutation['callback']! as Map)
            .cast<String, Object?>();
        final expectedCallback = (expectedMutation['callback']! as Map)
            .cast<String, Object?>();
        for (final field in ['kind', 'source', 'source_span']) {
          expect(actualCallback[field], expectedCallback[field]);
        }
        final actualBody = (actualCallback['body']! as Map)
            .cast<String, Object?>();
        final expectedBody = (expectedCallback['body']! as Map)
            .cast<String, Object?>();
        for (final field in ['kind', 'source', 'source_span']) {
          expect(actualBody[field], expectedBody[field]);
        }
        final actualContinuation = _objects(actual['continuation']);
        final expectedContinuation = _objects(expected['continuation']);
        expect(actualContinuation, hasLength(expectedContinuation.length));
        for (var index = 0; index < expectedContinuation.length; index += 1) {
          for (final field in [
            'kind',
            'method',
            'source_method',
            'source',
            'source_span',
            'args_source',
            'args_span',
          ]) {
            expect(
              actualContinuation[index][field],
              expectedContinuation[index][field],
              reason: '${fixture['id']} continuation $index $field',
            );
          }
        }
      } else {
        expect(chain.receiver.name, fixture['expected_receiver']);
        expect([
          for (final call in chain.continuation) call.method,
        ], fixture['expected_continuation']);
      }
    }

    const unicode =
        'tree.map_leaves!() { note = "é🙂"; return(value) }.has_key("🙂")';
    final unicodeChain =
        parseActionExpression(unicode) as ActionReceiverMutationChainExpr;
    expect(unicodeChain.sourceSpan.end, unicode.runes.length);
    expect(unicodeChain.sourceSpan.end, lessThan(unicode.length));
    expect(
      unicodeChain.continuation.single.sourceSpan.end,
      unicode.runes.length,
    );
    final unicodeArgument = unicodeChain.continuation.single.args.single.value;
    expect(
      _scalarSlice(
        unicode,
        unicodeArgument.sourceSpan.start,
        unicodeArgument.sourceSpan.end,
      ),
      '"🙂"',
    );

    for (final fixture in invalid) {
      final expected = (fixture['diagnostic']! as Map).cast<String, Object?>();
      late final ActionParseException failure;
      try {
        parseActionExpression(fixture['source']! as String);
        fail('${fixture['id']} unexpectedly parsed');
      } on ActionParseException catch (error) {
        failure = error;
      }
      final actual = failure.toJson();
      expect(
        actual['code'],
        expected['code'],
        reason: fixture['id']! as String,
      );
      expect(actual['stage'], expected['stage']);
      final actualSpan = (actual['source_span']! as Map)
          .cast<String, Object?>();
      final expectedSpan = (expected['source_span']! as Map)
          .cast<String, Object?>();
      for (final field in ['start', 'end', 'unit', 'provenance']) {
        expect(actualSpan[field], expectedSpan[field]);
      }
      expect(actual['message'], expected['message']);
    }

    for (final fixture in excluded) {
      final source = fixture['source']! as String;
      switch (fixture['classification']) {
        case 'ordinary_nonmutating_fluent_chain':
        case 'ordinary_unknown_method':
          final expression = parseActionExpression(source);
          expect(expression, isNot(isA<ActionReceiverMutationChainExpr>()));
        case 'invalid_identifier_not_receiver_mutation':
          final expression = parseActionExpression(source);
          expect(expression, isA<ActionRawExpr>());
          expect(expression, isNot(isA<ActionReceiverMutationChainExpr>()));
        default:
          fail('unknown exclusion ${fixture['classification']}');
      }
    }

    expect(
      _engineForAction(
        'tree = { "a" : "A" }; '
        'return( tree . map_leaves! ( ) { return(value) } . count_keys() )',
      ).parse('xhello').value,
      1,
    );
  });

  test('executes hash and array snapshot frames with post-commit chains', () {
    final hash = _engineForAction(r'''
tree = { "b" : { "z" : "B" }, "a" : "A", "arr" : [1, 2] };
audit = [];
result = tree.map_leaves!() {
 audit += join_values("/", path);
 return(if(str_eq(key, "arr"), ["array-leaf"], else(cat(key, "@", depth, "=", value))))
};
return(array(tree, result, audit))
''').parse('xhello');
    const expectedHash = {
      'a': 'a@1=A',
      'arr': ['array-leaf'],
      'b': {'z': 'z@2=B'},
    };
    expect(hash.value, [
      expectedHash,
      expectedHash,
      ['a', 'arr', 'b/z'],
    ]);

    final array = _engineForAction(r'''
items = ["A", ["B", "C"], { "h" : "H" }];
result = items.map_leaves!() {
 return(if(str_eq(index, 2), { "kept" : "hash-leaf" }, else(cat(join_values("/", path), "=", value))))
}.count();
return(array(items, result))
''').parse('xhello');
    expect(array.value, [
      [
        '0=A',
        ['1/0=B', '1/1=C'],
        {'kept': 'hash-leaf'},
      ],
      3,
    ]);
  });

  test('keeps callback frames detached and ordinary effects persistent', () {
    final result = _engineForAction(r'''
tree = { "b" : "B", "a" : "A" };
audit = [];
other = [];
mapped = tree.map_leaves!() {
 audit += path;
 other = [value];
 value = "local";
 path = ["changed"];
 return(cat(key, "!"))
};
return(array(tree, mapped, audit, other, value, path))
''').parse('xhello');
    expect(result.value, [
      {'a': 'a!', 'b': 'b!'},
      {'a': 'a!', 'b': 'b!'},
      [
        ['a'],
        ['b'],
      ],
      ['B'],
      null,
      null,
    ]);

    final empty = _engineForAction(r'''
tree = {};
items = [];
audit = [];
hash_result = tree.map_leaves!() { audit += "hash"; return(value) };
array_result = items.map_leaves!() { audit += "array"; return(value) };
return(array(tree, hash_result, items, array_result, audit))
''').parse('xhello');
    expect(empty.value, <Object?>[
      <String, Object?>{},
      <String, Object?>{},
      <Object?>[],
      <Object?>[],
      <Object?>[],
    ]);
  });

  test('uses binding identity instead of spelling for shadow parameters', () {
    final result = _engineForSource(r'''
fn shadow_write(tree) {
 tree[0]["local"] = "A";
 return(tree)
}

Top::
 -> Done { tree = { "leaf" : [] }; result = tree.map_leaves!() { return(shadow_write(value)) }; return(array(tree, result)) }

Done::
 /[a-z]+/
''').parse('xhello');
    expect(result.value, [
      {
        'leaf': [
          {'local': 'A'},
        ],
      },
      {
        'leaf': [
          {'local': 'A'},
        ],
      },
    ]);
  });

  test('composes with nested writes and preserves the non-bang boundary', () {
    expect(
      composition['contract_id'],
      'linkedspec-write-map-leaves-composition-v1',
    );
    expect(_objects(composition['callback_cases']), hasLength(6));
    expect(_objects(composition['continuation_cases']), hasLength(1));

    final callbackValue = _engineForAction(r'''
tree = { "leaf" : [] };
result = tree.map_leaves!() { value[0]["name"] = "A"; return(value) };
return(array(tree, result))
''').parse('xhello');
    final expected = {
      'leaf': [
        {'name': 'A'},
      ],
    };
    expect(callbackValue.value, [expected, expected]);

    final unrelated = _engineForAction(r'''
tree = { "a" : "A" };
result = tree.map_leaves!() {
 journal["seen"][0] = path;
 return(cat(value, "!"))
};
return(array(tree, result, journal))
''').parse('xhello');
    expect(unrelated.value, [
      {'a': 'A!'},
      {'a': 'A!'},
      {
        'seen': [
          ['a'],
        ],
      },
    ]);

    final nonbang = _engineForAction(r'''
tree = { "leaf" : [{ "x" : "original" }] };
result = tree.map_leaves() {
 value[0]["x"] = "changed";
 return(value)
};
return(array(tree, result))
''').parse('xhello');
    expect(nonbang.value, [
      {
        'leaf': [
          {'x': 'original'},
        ],
      },
      {
        'leaf': [
          {'x': 'changed'},
        ],
      },
    ]);
  });

  test('detaches initial, callback, committed, and returned aggregates', () {
    final result = _engineForAction(r'''
initial = { "leaf" : ["A"] };
tree = initial;
mapped = tree.map_leaves!() {
 return(array(value.first(), { "nested" : ["B"] }))
};
initial["leaf"][0] = "initial-mutated";
mapped["leaf"][0] = "returned-mutated";
tree["leaf"][1]["nested"][0] = "committed-mutated";
return(array(initial, tree, mapped))
''').parse('xhello');
    expect(result.value, [
      {
        'leaf': ['initial-mutated'],
      },
      {
        'leaf': [
          'A',
          {
            'nested': ['committed-mutated'],
          },
        ],
      },
      {
        'leaf': [
          'returned-mutated',
          {
            'nested': ['B'],
          },
        ],
      },
    ]);
  });

  test('returns exact receiver and frozen re-entrant diagnostics', () {
    for (final testCase in const [
      (
        'tree.map_leaves!() { return(value) }',
        'map_leaves_mutation_receiver_missing',
        null,
      ),
      (
        'tree = undef; tree.map_leaves!() { return(value) }',
        'map_leaves_mutation_receiver_kind_mismatch',
        'null',
      ),
      (
        'tree = "scalar"; tree.map_leaves!() { return(value) }',
        'map_leaves_mutation_receiver_kind_mismatch',
        'string',
      ),
    ]) {
      final diagnostic = _runtimeFailure(testCase.$1).diagnostic!.toJson();
      expect(diagnostic['code'], testCase.$2);
      expect(diagnostic['operation'], 'map_leaves_mutation');
      expect(diagnostic['binding'], 'tree');
      expect(diagnostic['method'], 'map_leaves');
      if (testCase.$3 != null) {
        expect(diagnostic['actual_kind'], testCase.$3);
        expect(diagnostic['expected_kinds'], ['harray', 'array']);
      }
    }

    for (final testCase in const [
      (
        'tree = { "a" : "A" }; tree.map_leaves!() { tree = {}; return(value) }',
        'assign',
        'tree',
      ),
      (
        'tree = { "a" : "A" }; tree.map_leaves!() { tree["x"] = value; return(value) }',
        'nested_write',
        'tree',
      ),
      (
        'tree = { "a" : "A" }; tree.map_leaves!() { set(tree, {}); return(value) }',
        'helper:set',
        'set(tree, {})',
      ),
      (
        'tree = { "a" : "A" }; tree.map_leaves!() { return(tree.map_leaves!() { return(value) }) }',
        'map_leaves!',
        'tree',
      ),
    ]) {
      final diagnostic = _runtimeFailure(testCase.$1).diagnostic!.toJson();
      expect(diagnostic['code'], 'receiver_mutation_reentrant');
      expect(diagnostic['operation'], 'map_leaves_mutation');
      expect(diagnostic['binding'], 'tree');
      expect(diagnostic['method'], 'map_leaves');
      expect(diagnostic['attempt'], testCase.$2);
      final span = (diagnostic['source_span']! as Map).cast<String, Object?>();
      expect(span['unit'], 'unicode_scalar');
      expect(span['provenance'], 'authored');
      expect(
        _scalarSlice(testCase.$1, span['start']! as int, span['end']! as int),
        testCase.$3,
      );
    }
  });

  test('guards every helper, array-end, and binding-pipeline write first', () {
    const cases = [
      ('tree += { say("operand"); "x" }', 'append'),
      ('tree[{ say("operand"); 0 }] = { say("rhs"); "x" }', 'nested_write'),
      ('set(tree, { say("operand"); [] })', 'helper:set'),
      ('push(tree, { say("operand"); "x" })', 'helper:push'),
      ('tree.push_back({ say("operand"); "x" })', 'push_back'),
      ('tree.push_front({ say("operand"); "x" })', 'push_front'),
      ('tree.pop_back()', 'pop_back'),
      ('tree.pop_front()', 'pop_front'),
      ('split(tree, { say("operand"); "a,b" }, ",")', 'helper:split'),
      ('split_each(tree, { say("operand"); "," })', 'helper:split_each'),
      ('trim_each(tree)', 'helper:trim_each'),
      ('filter_nonempty(tree)', 'helper:filter_nonempty'),
      ('filter_match(tree, { say("operand"); /^a/ })', 'helper:filter_match'),
      ('lowercase_each(tree)', 'helper:lowercase_each'),
      ('uppercase_each(tree)', 'helper:uppercase_each'),
      ('uniq(tree)', 'helper:uniq'),
      ('substr(tree, { say("operand"); "a" }, "b")', 'helper:substr'),
      ('regex_subst(tree, { say("operand"); /a/ }, "b")', 'helper:regex_subst'),
    ];
    for (final testCase in cases) {
      final action =
          'tree = ["seed"]; tree.map_leaves!() { ${testCase.$1}; return(value) }';
      final events = <RuntimeDiagnosticOutputEvent>[];
      late final RuntimeInterpreterException failure;
      try {
        _engineForAction(
          action,
        ).parse('xhello', diagnosticOutputSink: events.add);
        fail('${testCase.$1} unexpectedly succeeded');
      } on RuntimeInterpreterException catch (error) {
        failure = error;
      }
      final diagnostic = failure.diagnostic!.toJson();
      expect(diagnostic['code'], 'receiver_mutation_reentrant');
      expect(diagnostic['attempt'], testCase.$2);
      expect(events, isEmpty, reason: '${testCase.$1} evaluated an operand');
    }

    final setKeyEvents = <RuntimeDiagnosticOutputEvent>[];
    late final RuntimeInterpreterException setKey;
    try {
      _engineForAction(
        'tree = { "a" : "A" }; tree.map_leaves!() { '
        'set_key(tree, { say("operand"); "x" }, value); return(value) }',
      ).parse('xhello', diagnosticOutputSink: setKeyEvents.add);
      fail('set_key unexpectedly succeeded');
    } on RuntimeInterpreterException catch (error) {
      setKey = error;
    }
    expect(setKey.diagnostic!.code, 'receiver_mutation_reentrant');
    expect(setKey.diagnostic!.attempt, 'helper:set_key');
    expect(setKeyEvents, isEmpty);
  });

  test('propagates callback failures without wrapping the diagnostic', () {
    const message = 'injected callback failure';
    const injected = RuntimeInterpreterException(
      message,
      diagnostic: RuntimeDiagnostic(
        type: 'runtime',
        stage: 'action_runtime',
        summary: 'injected callback failure',
        detail: message,
        code: 'callback_failed',
      ),
    );
    try {
      _engineForAction(
        'tree = { "a" : "A" }; '
        'tree.map_leaves!() { say("fail"); return(value) }',
      ).parse('xhello', diagnosticOutputSink: (_) => throw injected);
      fail('callback unexpectedly succeeded');
    } on RuntimeInterpreterException catch (error) {
      expect(identical(error, injected), isTrue);
      expect(error.diagnostic!.code, 'callback_failed');
    }
  });

  test(
    'rejects malformed typed state before native or generated execution',
    () {
      final corrupt = _compiledWithCorruptReceiverMutation();
      expect(
        () => LinkedSpecRuntimeEngine(corrupt).parse('xhello'),
        throwsA(
          isA<RuntimeInterpreterException>()
              .having(
                (error) => error.message,
                'message',
                contains('receiver_mutation_serialized_state_invalid'),
              )
              .having(
                (error) => error.diagnostic!.code,
                'code',
                'receiver_mutation_serialized_state_invalid',
              ),
        ),
      );
      expect(
        () => emitDartSourceV2(corrupt, 'map-leaves-mutation/corrupt.spec'),
        throwsA(
          isA<GeneratedSourceException>().having(
            (error) => error.detail,
            'detail',
            contains('receiver_mutation_serialized_state_invalid'),
          ),
        ),
      );
      expect(
        () => validateGeneratedRulePlanV2(
          corrupt,
          buildGeneratedRulePlan(corrupt),
          'map-leaves-mutation/corrupt.spec',
        ),
        throwsA(
          isA<GeneratedSourceException>().having(
            (error) => error.detail,
            'detail',
            contains('receiver_mutation_serialized_state_invalid'),
          ),
        ),
      );
    },
  );

  test(
    'typed state survives reconstruction, generated source, CLI, and caller',
    () async {
      const identity = 'map-leaves-mutation/dart.spec';
      const expected = 2;
      final source = _sourceForAction(
        'tree = { "b" : "B", "a" : "A" }; '
        'return(tree.map_leaves!() { '
        'return(cat(value, "!")) }.count_keys())',
      );
      final parsed = parseSpec(source);
      final reconstructed = SpecFile.fromJson(
        (jsonDecode(jsonEncode(parsed.toJson())) as Map)
            .cast<String, Object?>(),
      );
      final compiled = compileSpec(reconstructed);
      final compiledJson = jsonEncode(compiled.toJson());
      expect(compiledJson, contains('"kind":"receiver_mutation_chain"'));
      expect(compiledJson, contains('"kind":"binding_reference"'));
      expect(compiledJson, contains('"source_method":"map_leaves!"'));
      expect(LinkedSpecRuntimeEngine(compiled).parse('xhello').value, expected);
      expect(
        executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          'xhello',
          identity,
        ),
        expected,
      );

      final cli = runLinkedSpecDartPrimaryCli([
        '--inline-spec',
        source,
        '--input',
        'xhello',
      ]);
      expect(cli.exitCode, 0);
      expect(cli.stderrBytes, isEmpty);
      expect(jsonDecode(utf8.decode(cli.stdoutBytes)), expected);

      final emitted = emitDartSourceV2(compiled, identity);
      expect(emitted, contains(linkedSpecGeneratedSourceContract));
      final encodedSpec = RegExp(
        r"const _compiledSpecJsonBase64 = '([^']+)'",
      ).firstMatch(emitted)![1]!;
      final emittedSpecJson = utf8.decode(base64Decode(encodedSpec));
      expect(emittedSpecJson, contains('map_leaves!'));
      final packageRoot = Directory.current.absolute;
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-map-leaves-mutation-emitted-',
      );
      final pubCache = Directory('${scratch.path}/pub-cache')..createSync();
      try {
        Directory('${scratch.path}/lib').createSync();
        Directory('${scratch.path}/bin').createSync();
        File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_map_leaves_mutation_emitted_probe
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ${jsonEncode(packageRoot.path)}
''');
        File('${scratch.path}/lib/generated.dart').writeAsStringSync(emitted);
        File('${scratch.path}/bin/main.dart').writeAsStringSync(r'''
import 'dart:convert';

import 'package:linkedspec_map_leaves_mutation_emitted_probe/generated.dart'
    as generated;

void main() {
  print(jsonEncode(generated.execute('xhello')));
}
''');
        final environment = {
          ...Platform.environment,
          'PUB_CACHE': pubCache.path,
        };
        for (final arguments in const [
          ['pub', 'get', '--offline'],
          ['analyze'],
          ['run', 'bin/main.dart'],
        ]) {
          final process = await Process.run(
            Platform.resolvedExecutable,
            arguments,
            workingDirectory: scratch.path,
            environment: environment,
          );
          expect(
            process.exitCode,
            0,
            reason:
                'dart ${arguments.join(' ')} failed\n'
                'stdout:\n${process.stdout}\n'
                'stderr:\n${process.stderr}',
          );
          if (arguments.first == 'run') {
            expect(jsonDecode((process.stdout as String).trim()), expected);
          }
        }
      } finally {
        scratch.deleteSync(recursive: true);
      }
      expect(scratch.existsSync(), isFalse);
    },
  );
}
