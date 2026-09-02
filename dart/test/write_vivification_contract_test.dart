// FUTURE-PARITY-BACKLOG.19.4.1 — Dart nested-write vivification contract.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/cli/primary_cli.dart';
import 'package:test/test.dart';

Map<String, Object?> _contract() {
  return (jsonDecode(
        File(
          '../capability_conformance/write_vivification_contract.json',
        ).readAsStringSync(),
      )
      as Map<String, Object?>);
}

String _expressionKind(String neutralKind) {
  return switch (neutralKind) {
    'identifier' => 'variable',
    'integer_literal' => 'number',
    'string_literal' => 'string',
    _ => neutralKind,
  };
}

LinkedSpecRuntimeEngine _engineForAction(String action) {
  return _engineForSource('''
Top::
 -> Done { $action }

Done::
 /[a-z]+/
''');
}

LinkedSpecRuntimeEngine _engineForSource(String source) {
  return LinkedSpecRuntimeEngine(
    compileSpec(parseSpecWithStagedUserFunctionDefinitions(source)),
  );
}

List<Map<String, Object?>> _objects(Object? value) {
  return [
    for (final item in value! as List<Object?>)
      (item! as Map).cast<String, Object?>(),
  ];
}

String _dslLiteral(Object? value) {
  return switch (value) {
    null => 'undef',
    bool() || num() => value.toString(),
    String() => jsonEncode(value),
    List() => '[${value.map(_dslLiteral).join(', ')}]',
    Map() =>
      '{ ${value.entries.map((entry) => '${jsonEncode(entry.key)} : ${_dslLiteral(entry.value)}').join(', ')} }',
    _ => throw StateError('unsupported fixture literal $value'),
  };
}

bool _isIdentifier(String source) {
  return RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(source);
}

String _instrumented(String marker, String expression) {
  return '{ say(${jsonEncode(marker)}); $expression }';
}

String _ordinaryCaseAction(
  Map<String, Object?> fixture, {
  required bool includeResult,
}) {
  final statements = <String>[];
  final initial = (fixture['initial_binding']! as Map).cast<String, Object?>();
  if (initial['present'] == true) {
    statements.add('document = ${_dslLiteral(initial['value'])}');
  }

  final segmentExpressions = <String>[];
  final segments = _objects(fixture['segments']);
  for (final (index, segment) in segments.indexed) {
    final source = segment['source']! as String;
    if (_isIdentifier(source) &&
        !const {'true', 'false', 'null', 'undef'}.contains(source)) {
      final value = segment['kind'] == 'codeblock'
          ? r'{|value| return(value) }'
          : _dslLiteral(segment['value']);
      statements.add('$source = $value');
    }
    segmentExpressions.add(_instrumented('segment:$index', source));
  }

  final rhs = (fixture['rhs']! as Map).cast<String, Object?>();
  final rhsSource = rhs['source']! as String;
  if (_isIdentifier(rhsSource)) {
    statements.add('$rhsSource = ${_dslLiteral(rhs['value'])}');
  }
  final lvalue = StringBuffer(fixture['binding']! as String);
  for (final expression in segmentExpressions) {
    lvalue.write('[$expression]');
  }
  final assignment = '$lvalue = ${_instrumented('rhs', rhsSource)}';
  if (includeResult) {
    statements
      ..add('result = ($assignment)')
      ..add('return(array(document, result))');
  } else {
    statements.add(assignment);
  }
  return statements.join('; ');
}

List<String> _effects(List<RuntimeDiagnosticOutputEvent> events) {
  return [for (final event in events) event.message.trimRight()];
}

ActionAssignNestedAccessExpr _nestedWriteInAction(String action) {
  final block = parseActionBlock(action);
  for (final statement in block.statements) {
    final expression = statement.expr;
    if (expression is ActionAssignNestedAccessExpr) {
      return expression;
    }
    if (expression is ActionAssignScalarExpr &&
        expression.value is ActionAssignNestedAccessExpr) {
      return expression.value as ActionAssignNestedAccessExpr;
    }
  }
  throw StateError('action did not contain a top-level nested write: $action');
}

String _expectedStructuralMessage(Map<String, Object?> expected) {
  final segment = expected['segment_index'];
  return switch (expected['code']) {
    'nested_write_segment_invalid' =>
      "nested write segment $segment for binding 'document' must evaluate "
          'to a string or nonnegative integer; got '
          '${expected['actual_kind']} (${expected['reason']})',
    'nested_write_kind_conflict' =>
      "nested write segment $segment for binding 'document' requires "
          '${expected['expected_kind']}; found ${expected['actual_kind']}',
    'nested_write_array_gap' =>
      "nested write segment $segment for binding 'document' cannot create "
          'array index ${expected['index']} at length ${expected['length']}',
    _ => throw StateError('unknown structural diagnostic ${expected['code']}'),
  };
}

CompiledSpec _compiledWithEmptyNestedWriteSegments() {
  final compiled = compileSpec(
    parseSpec('''
Top::
 -> Done { document["x"] = "y"; return(document) }

Done::
 /[a-z]+/
'''),
  );
  final top = compiled.rulesByLabel['Top']!;
  final edge = top.actionEdges.single;
  final payload = edge.actionPayload!;
  final statement = payload.actionAst.statements.first;
  final write = statement.expr as ActionAssignNestedAccessExpr;
  final corruptedBlock = ActionBlock(
    source: payload.actionAst.source,
    sourceSpan: payload.actionAst.sourceSpan,
    statements: [
      ActionStatement(
        source: statement.source,
        sourceSpan: statement.sourceSpan,
        expr: ActionAssignNestedAccessExpr(
          source: write.source,
          sourceSpan: write.sourceSpan,
          base: write.base,
          segments: const [],
          value: write.value,
        ),
        dropsValue: statement.dropsValue,
      ),
      ...payload.actionAst.statements.skip(1),
    ],
  );
  final corruptedPayload = CompiledActionPayload(
    role: payload.role,
    line: payload.line,
    source: payload.source,
    code: payload.code,
    actionAst: corruptedBlock,
    contracts: payload.contracts,
    lifecycle: payload.lifecycle,
  );
  final corruptedEdge = CompiledActionEdge(
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
    actionPayload: corruptedPayload,
  );
  final corruptedTop = CompiledRule(
    label: top.label,
    header: top.header,
    modeMetadata: top.modeMetadata,
    regexPatterns: top.regexPatterns,
    regexSlots: top.regexSlots,
    captureGaps: top.captureGaps,
    dependencyRefs: top.dependencyRefs,
    actionEdges: [corruptedEdge],
    blindEdges: top.blindEdges,
    lifecycleActionPayloads: top.lifecycleActionPayloads,
    plainActionPayloads: top.plainActionPayloads,
    bodyElements: top.bodyElements,
  );
  return CompiledSpec(
    definitionOrder: compiled.definitionOrder,
    compiledRuleOrder: compiled.compiledRuleOrder,
    rulesByLabel: {...compiled.rulesByLabel, 'Top': corruptedTop},
    redefinedRuleLabels: compiled.redefinedRuleLabels,
    functionRegistry: compiled.functionRegistry,
    dependencyRegexState: compiled.dependencyRegexState,
  );
}

void main() {
  final contract = _contract();

  test('projects the frozen AST and syntax inventory', () {
    expect(contract['contract_id'], 'linkedspec-write-vivification-v1');
    final valid = contract['valid_syntax_cases']! as List<Object?>;
    final invalid = contract['invalid_syntax_cases']! as List<Object?>;
    final excluded = contract['excluded_syntax_cases']! as List<Object?>;
    expect(valid, hasLength(5));
    expect(invalid, hasLength(7));
    expect(excluded, hasLength(4));

    for (final rawCase in valid) {
      final fixture = rawCase! as Map<String, Object?>;
      final expected = fixture['expected_ast']! as Map<String, Object?>;
      final expression = parseActionExpression(fixture['source']! as String);
      expect(
        expression,
        isA<ActionAssignNestedAccessExpr>(),
        reason: fixture['id']! as String,
      );
      final actual = expression.toJson();
      expect(actual['kind'], 'assign_nested_access');
      expect(actual['source'], fixture['source']);
      expect(actual['source_span'], expected['source_span']);
      expect(actual['base'], expected['base']);
      final actualSegments = actual['segments']! as List<Object?>;
      final expectedSegments = expected['segments']! as List<Object?>;
      expect(actualSegments, hasLength(expectedSegments.length));
      for (var index = 0; index < expectedSegments.length; index += 1) {
        final actualSegment = actualSegments[index]! as Map<String, Object?>;
        final expectedSegment =
            expectedSegments[index]! as Map<String, Object?>;
        final expectedExpression =
            expectedSegment['expression']! as Map<String, Object?>;
        final actualExpression =
            actualSegment['expression']! as Map<String, Object?>;
        expect(actualSegment['kind'], 'path_segment');
        expect(actualSegment['source'], expectedSegment['source']);
        expect(actualSegment['source_span'], expectedSegment['source_span']);
        expect(
          actualExpression['kind'],
          _expressionKind(expectedExpression['kind']! as String),
        );
        expect(actualExpression['source'], expectedExpression['source']);
        expect(
          actualExpression['source_span'],
          expectedExpression['source_span'],
        );
      }
      final actualValue = actual['value']! as Map<String, Object?>;
      final expectedValue = expected['value']! as Map<String, Object?>;
      expect(
        actualValue['kind'],
        _expressionKind(expectedValue['kind']! as String),
      );
      expect(actualValue['source'], expectedValue['source']);
      expect(actualValue['source_span'], expectedValue['source_span']);
    }

    for (final rawCase in invalid) {
      final fixture = rawCase! as Map<String, Object?>;
      final expected = fixture['diagnostic']! as Map<String, Object?>;
      late final ActionParseException failure;
      try {
        parseActionExpression(fixture['source']! as String);
        fail('${fixture['id']} unexpectedly parsed');
      } on ActionParseException catch (error) {
        failure = error;
      }
      final actual = failure.toJson();
      expect(actual['code'], expected['code']);
      expect(actual['stage'], expected['stage']);
      final actualSpan = actual['source_span']! as Map<String, Object?>;
      final expectedSpan = expected['source_span']! as Map<String, Object?>;
      expect(actualSpan['start'], expectedSpan['start']);
      expect(actualSpan['end'], expectedSpan['end']);
      expect(actualSpan['unit'], expectedSpan['unit']);
      expect(actualSpan['provenance'], expectedSpan['provenance']);
      expect(actual['message'], expected['message']);
    }

    for (final fixture in _objects(excluded)) {
      final expression = parseActionExpression(fixture['source']! as String);
      switch (fixture['classification']) {
        case 'not_nested_write':
          expect(expression, isA<ActionAssignScalarExpr>());
        case 'read_only':
          expect(expression, isA<ActionNestedAccessExpr>());
        case 'unsupported_helper':
          expect(
            expression,
            isA<ActionCallExpr>().having(
              (value) => value.name,
              'name',
              'vivify',
            ),
          );
        case 'unsupported_operator':
          expect(expression, isNot(isA<ActionAssignNestedAccessExpr>()));
        default:
          fail('unknown exclusion ${fixture['classification']}');
      }
    }

    final astral =
        parseActionExpression('document["🙂"][position] = "值"')
            as ActionAssignNestedAccessExpr;
    expect(astral.sourceSpan.toJson(), {'start': 0, 'end': 29});
    expect(astral.segments[0].sourceSpan.toJson(), {'start': 9, 'end': 12});
    expect(astral.segments[0].expression.sourceSpan.toJson(), {
      'start': 9,
      'end': 12,
    });
    expect(astral.segments[1].sourceSpan.toJson(), {'start': 14, 'end': 22});
    expect(astral.segments[1].expression.sourceSpan.toJson(), {
      'start': 14,
      'end': 22,
    });
    expect(astral.value.sourceSpan.toJson(), {'start': 26, 'end': 29});
  });

  test('executes all frozen successes in exact evaluation order', () {
    final cases = _objects(contract['success_cases']);
    expect(cases, hasLength(11));
    for (final fixture in cases) {
      final action = switch (fixture['id']) {
        'rhs_same_binding_side_effect_composes' =>
          'document = { "audit" : [] }; '
              'result = (document[${_instrumented('segment:0', '"value"')}] = '
              '{ say("rhs"); document = { "audit" : ["rhs"] }; "done" }); '
              'return(array(document, result))',
        'segment_same_binding_side_effect_composes' =>
          'result = (document[{ say("segment:0"); '
              'document = { "seed" : 1 }; "value" }] = '
              '${_instrumented('rhs', '"done"')}); '
              'return(array(document, result))',
        _ => _ordinaryCaseAction(fixture, includeResult: true),
      };
      final events = <RuntimeDiagnosticOutputEvent>[];
      final result = _engineForAction(
        action,
      ).parse('xhello', diagnosticOutputSink: events.add);
      expect(result.value, [
        fixture['expected_binding'],
        fixture['expected_result'],
      ], reason: fixture['id']! as String);
      expect(
        _effects(events),
        fixture['expected_effects'],
        reason: '${fixture['id']} effects',
      );
    }
  });

  test('returns every exact typed structural failure after RHS evaluation', () {
    final cases = _objects(contract['failure_cases']);
    expect(cases, hasLength(16));
    for (final fixture in cases) {
      final action = fixture['id'] == 'rhs_side_effect_survives_outer_gap'
          ? 'document = []; '
                'document[${_instrumented('segment:0', '2')}] = '
                '{ say("rhs"); document = ["rhs"]; "outer" }'
          : _ordinaryCaseAction(fixture, includeResult: false);
      final events = <RuntimeDiagnosticOutputEvent>[];
      late final RuntimeInterpreterException failure;
      try {
        _engineForAction(
          action,
        ).parse('xhello', diagnosticOutputSink: events.add);
        fail('${fixture['id']} unexpectedly succeeded');
      } on RuntimeInterpreterException catch (error) {
        failure = error;
      }

      final expected = (fixture['expected_error']! as Map)
          .cast<String, Object?>();
      final actual = failure.diagnostic!.toJson();
      expect(actual['code'], expected['code'], reason: '${fixture['id']} code');
      expect(actual['operation'], 'nested_write_vivification');
      expect(actual['binding'], fixture['binding']);
      for (final field in [
        'segment_index',
        'path',
        'actual_kind',
        'reason',
        'expected_kind',
        'index',
        'length',
      ]) {
        if (expected.containsKey(field)) {
          expect(
            actual[field],
            expected[field],
            reason: '${fixture['id']} $field',
          );
        }
      }
      expect(failure.message, _expectedStructuralMessage(expected));
      expect(_effects(events), fixture['expected_effects']);

      final write = _nestedWriteInAction(action);
      final target = expected['source_target']! as String;
      final segmentIndex = int.parse(target.substring('segment:'.length));
      expect(actual['source_span'], {
        ...write.segments[segmentIndex].sourceSpan.toJson(),
        'unit': 'unicode_scalar',
        'provenance': 'authored',
      }, reason: '${fixture['id']} authored span');
    }
  });

  test('propagates expression failures unchanged and stops later evaluation', () {
    final cases = _objects(contract['evaluation_failure_cases']);
    expect(cases, hasLength(3));
    for (final fixture in cases) {
      final initial = (fixture['initial_binding']! as Map)
          .cast<String, Object?>();
      final statements = <String>[
        if (initial['present'] == true)
          'document = ${_dslLiteral(initial['value'])}',
      ];
      final segmentExpressions = <String>[];
      String? failingMarker;
      Map<String, Object?>? expectedFailure;
      for (final (index, segment) in _objects(fixture['segments']).indexed) {
        final marker = 'segment:$index';
        final evaluationError = segment['evaluation_error'];
        if (evaluationError != null) {
          failingMarker = marker;
          expectedFailure = (evaluationError as Map).cast<String, Object?>();
        }
        segmentExpressions.add(
          _instrumented(marker, _dslLiteral(segment['value'] ?? 'unreached')),
        );
      }
      final rhs = (fixture['rhs']! as Map).cast<String, Object?>();
      if (rhs['evaluation_error'] case final Map<Object?, Object?> error) {
        failingMarker = 'rhs';
        expectedFailure = error.cast<String, Object?>();
      }
      final lvalue = StringBuffer('document');
      for (final expression in segmentExpressions) {
        lvalue.write('[$expression]');
      }
      statements.add(
        '$lvalue = ${_instrumented('rhs', _dslLiteral(rhs['value'] ?? 'unreached'))}',
      );

      final injected = RuntimeInterpreterException(
        expectedFailure!['message']! as String,
        diagnostic: RuntimeDiagnostic(
          type: 'runtime',
          stage: 'user_function_call',
          summary: 'injected user function failure',
          detail: expectedFailure['message']! as String,
          code: expectedFailure['code']! as String,
        ),
      );
      final events = <RuntimeDiagnosticOutputEvent>[];
      try {
        _engineForAction(statements.join('; ')).parse(
          'xhello',
          diagnosticOutputSink: (event) {
            events.add(event);
            if (event.message.trimRight() == failingMarker) {
              throw injected;
            }
          },
        );
        fail('${fixture['id']} unexpectedly succeeded');
      } on RuntimeInterpreterException catch (error) {
        expect(
          identical(error, injected),
          isTrue,
          reason: fixture['id']! as String,
        );
        expect(error.message, expectedFailure['message']);
        expect(error.diagnostic!.code, expectedFailure['code']);
      }
      expect(_effects(events), fixture['expected_effects']);
    }
  });

  test('keeps all frozen read exclusions non-creating', () {
    final cases = _objects(contract['read_exclusion_cases']);
    expect(cases, hasLength(3));
    for (final fixture in cases) {
      final initial = (fixture['initial_binding']! as Map)
          .cast<String, Object?>();
      final statements = <String>[
        if (initial['present'] == true)
          'document = ${_dslLiteral(initial['value'])}',
      ];
      final access = StringBuffer('document');
      for (final segment in _objects(fixture['segments'])) {
        access.write('[${_dslLiteral(segment['value'])}]');
      }
      statements
        ..add('observed = $access')
        ..add('return(array(document, observed))');
      final result = _engineForAction(statements.join('; ')).parse('xhello');
      final expected = (fixture['expected_binding']! as Map)
          .cast<String, Object?>();
      expect(result.value, [
        expected['value'],
        fixture['expected_result'],
      ], reason: fixture['id']! as String);
    }
  });

  test('detaches initial, RHS, committed binding, and returned result', () {
    final fixture = (contract['detachment_case']! as Map)
        .cast<String, Object?>();
    final expected = (fixture['expected']! as Map).cast<String, Object?>();
    final result = _engineForAction(r'''
initial = { "existing" : ["keep"] };
document = initial;
rhs = ["a"];
result = (document["payload"] = rhs);
rhs[0] = "rhs-mutated";
result["payload"][0] = "result-mutated";
document["existing"][0] = "binding-mutated";
initial["existing"][0] = "initial-mutated";
return(array(initial, rhs, document, result))
''').parse('xhello');
    expect(result.value, [
      expected['initial'],
      expected['rhs'],
      expected['binding'],
      expected['result'],
    ]);
  });

  test(
    'fresh function locals vivify while a bound null parameter conflicts',
    () {
      final fresh = _engineForSource(r'''
fn build_document() {
 document["items"][0] = "value";
 return(document)
}

Top::
 -> Done { return(array(build_document(), build_document())) }

Done::
 /[a-z]+/
''').parse('xhello');
      expect(fresh.value, [
        {
          'items': ['value'],
        },
        {
          'items': ['value'],
        },
      ]);

      late final RuntimeInterpreterException failure;
      try {
        _engineForSource(r'''
fn write_document(document) {
 document["key"] = "value";
 return(document)
}

Top::
 -> Done { return(write_document(undef)) }

Done::
 /[a-z]+/
''').parse('xhello');
        fail('bound null parameter unexpectedly vivified');
      } on RuntimeInterpreterException catch (error) {
        failure = error;
      }
      final diagnostic = failure.diagnostic!.toJson();
      expect(diagnostic['code'], 'nested_write_kind_conflict');
      expect(diagnostic['binding'], 'document');
      expect(diagnostic['segment_index'], 0);
      expect(diagnostic['expected_kind'], 'harray');
      expect(diagnostic['actual_kind'], 'null');
    },
  );

  test('rejects a malformed typed nested-write carrier before execution', () {
    final corrupted = _compiledWithEmptyNestedWriteSegments();
    late final RuntimeInterpreterException runtimeFailure;
    try {
      LinkedSpecRuntimeEngine(corrupted).parse('xhello');
      fail('malformed nested-write carrier unexpectedly executed');
    } on RuntimeInterpreterException catch (error) {
      runtimeFailure = error;
    }
    expect(
      runtimeFailure.diagnostic!.code,
      'nested_write_serialized_state_invalid',
    );
    expect(
      () => emitDartSourceV2(corrupted, 'write-vivification/corrupt.spec'),
      throwsA(
        isA<GeneratedSourceException>().having(
          (error) => error.detail,
          'detail',
          contains('nested_write_serialized_state_invalid'),
        ),
      ),
    );
    expect(
      () => validateGeneratedRulePlanV2(
        corrupted,
        buildGeneratedRulePlan(corrupted),
        'write-vivification/corrupt.spec',
      ),
      throwsA(
        isA<GeneratedSourceException>().having(
          (error) => error.detail,
          'detail',
          contains('nested_write_serialized_state_invalid'),
        ),
      ),
    );
  });

  test(
    'typed state survives reconstruction, generated plan, source, and CLI',
    () async {
      const identity = 'write-vivification/dart.spec';
      const expected = {
        'sections': [
          {'title': 'Intro'},
        ],
      };
      final source = '''
Top::
 -> Done { key_name = "sections"; document[key_name][0]["title"] = "Intro"; return(document) }

Done::
 /[a-z]+/
''';
      final parsed = parseSpec(source);
      final reconstructed = SpecFile.fromJson(
        (jsonDecode(jsonEncode(parsed.toJson())) as Map)
            .cast<String, Object?>(),
      );
      final compiled = compileSpec(reconstructed);
      final compiledJson = jsonEncode(compiled.toJson());
      expect(compiledJson, contains('"kind":"assign_nested_access"'));
      expect(compiledJson, contains('"kind":"path_segment"'));
      expect(compiledJson, contains('"source":"key_name"'));
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
      final packageRoot = Directory.current.absolute;
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-write-vivification-emitted-',
      );
      final pubCache = Directory('${scratch.path}/pub-cache')..createSync();
      try {
        Directory('${scratch.path}/lib').createSync();
        Directory('${scratch.path}/bin').createSync();
        File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_write_vivification_emitted_probe
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

import 'package:linkedspec_write_vivification_emitted_probe/generated.dart'
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
