import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('v1 metadata and structured emission failure are exact', () {
    const identity = 'generated-source/dart-unicode-λ.spec';
    const metadata = GeneratedSourceMetadata(sourceIdentity: identity);

    expect(metadata.toJson(), {
      'contract_id': 'linkedspec-generated-source-v1',
      'format_version': 1,
      'source_identity': identity,
    });

    expect(
      () => emitDartSourceV1(_compileProbe(), ''),
      throwsA(
        isA<GeneratedSourceException>()
            .having((error) => error.toJson(), 'portable JSON', {
              'type': 'generated_source_error',
              'stage': 'emit_source',
              'code': 'generated_source_emit_failed',
              'summary': 'Generated Dart source identity must not be empty',
              'source_identity': '',
              'detail': 'source_identity is required',
            })
            .having(
              (error) => error.toString(),
              'display',
              'Generated Dart source identity must not be empty: '
                  'source_identity is required',
            ),
      ),
    );

    expect(
      GeneratedSourceException.compileFailed(
        identity,
        'dart analyze failed',
      ).toJson(),
      {
        'type': 'generated_source_error',
        'stage': 'compile_or_load_generated_source',
        'code': 'generated_source_compile_failed',
        'summary': 'Generated Dart source failed to compile or load',
        'source_identity': identity,
        'detail': 'dart analyze failed',
      },
    );
    expect(
      GeneratedSourceException.executionFailed(
        identity,
        'unknown rule',
        ruleLabel: 'Missing',
      ).toJson(),
      {
        'type': 'generated_source_error',
        'stage': 'execute_generated',
        'code': 'generated_execution_failed',
        'summary': 'Generated Dart parser execution failed',
        'source_identity': identity,
        'rule_label': 'Missing',
        'detail': 'unknown rule',
      },
    );
  });

  test('emits deterministic source from effective compiled state', () {
    const identity = r'generated-source/dart-$-λ.spec';
    final compiled = _compileProbe();

    final first = emitDartSourceV1(compiled, identity);
    final second = emitDartSourceV1(compiled, identity);

    expect(first, second);
    expect(first, contains('linkedspec-generated-source-v1'));
    expect(first, contains('linkedspecGeneratedSourceFormat = 1'));
    expect(first, contains(r'generated-source/dart-\$-λ.spec'));
    expect(first, contains('Object? execute(String input'));
    expect(first, contains('Object? executeWithTrace('));
    expect(first, isNot(contains('Top::')));
  });

  test('classifies and rejects contract-v1 plans exactly', () {
    const identity = 'generated-source/dart-plan.spec';
    final compiled = _compileProbe();
    final plan = buildGeneratedRulePlan(compiled);

    expect(plan.map((row) => row.toJson()), [
      {'label': 'Top', 'family': 'default'},
    ]);
    validateGeneratedRulePlanV1(compiled, plan, identity);

    _expectPlanFailure(
      () => validateGeneratedRulePlanV1(compiled, const [], identity),
      GeneratedSourceCode.generatedPlanRowCountMismatch,
    );
    _expectPlanFailure(
      () => validateGeneratedRulePlanV1(compiled, const [
        GeneratedPlanRow(label: 'Wrong', family: 'default'),
      ], identity),
      GeneratedSourceCode.generatedPlanLabelMismatch,
    );
    _expectPlanFailure(
      () => validateGeneratedRulePlanV1(compiled, const [
        GeneratedPlanRow(label: 'Top', family: 'or_acode'),
      ], identity),
      GeneratedSourceCode.generatedPlanFamilyMismatch,
    );
    _expectPlanFailure(
      () => validateGeneratedRulePlanV1(compiled, const [
        GeneratedPlanRow(label: 'Top', family: 'invented_family'),
      ], identity),
      GeneratedSourceCode.generatedPlanUnknownFamily,
    );
  });

  test(
    'generated source analyzes and runs in an isolated caller package',
    () async {
      const identity = 'generated-source/dart-isolated.spec';
      final generated = emitDartSourceV1(_compileProbe(), identity);
      final packageRoot = Directory.current.absolute;
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-generated-source-',
      );
      final pubCache = Directory('${scratch.path}/pub-cache')..createSync();

      try {
        Directory('${scratch.path}/lib').createSync();
        Directory('${scratch.path}/bin').createSync();
        File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_generated_source_probe
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ${jsonEncode(packageRoot.path)}
''');
        File('${scratch.path}/lib/generated.dart').writeAsStringSync(generated);
        File('${scratch.path}/bin/main.dart').writeAsStringSync(r'''
import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_generated_source_probe/generated.dart' as generated;

void main() {
  final metadata = generated.metadata().toJson();
  if (metadata['contract_id'] != 'linkedspec-generated-source-v1' ||
      metadata['format_version'] != 1 ||
      metadata['source_identity'] !=
          'generated-source/dart-isolated.spec') {
    throw StateError('unexpected generated metadata: $metadata');
  }
  final value = generated.execute('x');
  if (value != r'λ:$') {
    throw StateError('unexpected generated result: $value');
  }
  Object? failure;
  try {
    generated.execute('x', topRule: 'Missing');
    throw StateError('missing rule unexpectedly executed');
  } on GeneratedSourceException catch (error) {
    failure = error.toJson();
  }
  final plan = generated.plan();
  generated.validatePlan(plan);
  generated.executeWithTrace(
    'x',
    const LinkedSpecTraceConfig(
      level: LinkedSpecTraceLevel.low,
      traceFile: 'generated.trace',
      sinkMode: LinkedSpecTraceSinkMode.route,
      resetFile: true,
    ),
  );
  print(jsonEncode({
    'metadata': metadata,
    'value': value,
    'plan': [for (final row in plan) row.toJson()],
    'failure': failure,
  }));
}
''');

        final environment = {
          ...Platform.environment,
          'PUB_CACHE': pubCache.path,
        };
        await _expectProcessSuccess(scratch, environment, const [
          'pub',
          'get',
          '--offline',
        ]);
        await _expectProcessSuccess(scratch, environment, const [
          'analyze',
          '--fatal-infos',
          '--fatal-warnings',
        ]);
        final run = await _expectProcessSuccess(scratch, environment, const [
          'run',
          'bin/main.dart',
        ]);
        expect(jsonDecode((run.stdout as String).trim()), {
          'metadata': {
            'contract_id': 'linkedspec-generated-source-v1',
            'format_version': 1,
            'source_identity': identity,
          },
          'value': r'λ:$',
          'plan': [
            {'label': 'Top', 'family': 'default'},
          ],
          'failure': {
            'type': 'generated_source_error',
            'stage': 'execute_generated',
            'code': 'generated_execution_failed',
            'summary': 'Generated Dart parser execution failed',
            'source_identity': identity,
            'rule_label': 'Missing',
            'detail': contains("rule 'Missing' is not compiled"),
          },
        });
        final trace = File(
          '${scratch.path}/generated.trace',
        ).readAsStringSync();
        expect(trace, contains('generated_rule_enter'));
        expect(trace, contains('generated_family_decision'));
        expect(trace, contains('generated_rule_exit'));
        expect(trace, contains(identity));
        expect(trace, contains('family=default'));
      } finally {
        scratch.deleteSync(recursive: true);
      }

      expect(scratch.existsSync(), isFalse);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'generated package compiles and runs every structural family',
    () async {
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-generated-family-matrix-',
      );
      final pubCache = Directory('${scratch.path}/pub-cache')..createSync();
      final packageRoot = Directory.current.absolute;
      final expectedValues = <String, Object?>{};
      final expectedFamilies = <String, String>{};
      final imports = StringBuffer('import \'dart:convert\';\n\n');
      final body = StringBuffer('''
void main() {
  final values = <String, Object?>{};
  final families = <String, String>{};
''');

      try {
        Directory('${scratch.path}/lib').createSync();
        Directory('${scratch.path}/bin').createSync();
        File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_generated_family_matrix
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ${jsonEncode(packageRoot.path)}
''');

        for (final item in _familyCases) {
          final compiled = compileSpec(parseSpec(item.spec));
          final interpreterValue = LinkedSpecRuntimeEngine(
            compiled,
          ).execute(item.input).value;
          final plan = buildGeneratedRulePlan(compiled);
          final topFamily = plan.first.family;
          expect(topFamily, item.family, reason: item.name);
          expectedValues[item.name] = interpreterValue;
          expectedFamilies[item.name] = item.family;

          final identity = 'generated-source/dart-family-${item.name}.spec';
          File(
            '${scratch.path}/lib/${item.name}.dart',
          ).writeAsStringSync(emitDartSourceV1(compiled, identity));
          imports.writeln(
            "import 'package:linkedspec_generated_family_matrix/"
            "${item.name}.dart' as ${item.name};",
          );
          body
            ..writeln('  final ${item.name}Plan = ${item.name}.plan();')
            ..writeln('  ${item.name}.validatePlan(${item.name}Plan);')
            ..writeln(
              "  values[${jsonEncode(item.name)}] = ${item.name}.execute("
              '${jsonEncode(item.input)});',
            )
            ..writeln(
              "  families[${jsonEncode(item.name)}] = "
              '${item.name}Plan.first.family;',
            );
        }
        body.writeln(
          "  print(jsonEncode({'values': values, 'families': families}));\n}",
        );
        File(
          '${scratch.path}/bin/main.dart',
        ).writeAsStringSync('$imports\n$body');

        final environment = {
          ...Platform.environment,
          'PUB_CACHE': pubCache.path,
        };
        await _expectProcessSuccess(scratch, environment, const [
          'pub',
          'get',
          '--offline',
        ]);
        await _expectProcessSuccess(scratch, environment, const [
          'analyze',
          '--fatal-infos',
          '--fatal-warnings',
        ]);
        final run = await _expectProcessSuccess(scratch, environment, const [
          'run',
          'bin/main.dart',
        ]);
        expect(jsonDecode((run.stdout as String).trim()), {
          'values': expectedValues,
          'families': expectedFamilies,
        });
        expect(expectedFamilies.values.toSet(), {
          for (final family in GeneratedRuleFamily.values) family.wireName,
        });
      } finally {
        scratch.deleteSync(recursive: true);
      }

      expect(scratch.existsSync(), isFalse);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

void _expectPlanFailure(
  void Function() operation,
  GeneratedSourceCode expectedCode,
) {
  expect(
    operation,
    throwsA(
      isA<GeneratedSourceException>()
          .having(
            (error) => error.stage,
            'stage',
            GeneratedSourceStage.validateGeneratedPlan,
          )
          .having((error) => error.code, 'code', expectedCode),
    ),
  );
}

final _familyCases = <_FamilyCase>[
  const _FamilyCase(
    name: 'default_case',
    family: 'default',
    input: 'hello one hello two',
    spec: r'''
Top::
 I { set(array(words), []) }
 /hello[ \t]+(\w+)/
 LE { push(array(words), match_group(0)) }
 E { return(copy(array(words))) }
''',
  ),
  const _FamilyCase(
    name: 'or_acode_case',
    family: 'or_acode',
    input: 'go',
    spec: r'''
Top::OR
 /go/ -> Done { return(cat("or-acode:", call(Done))) }
Done: /go/ E { return(entry_text()) }
''',
  ),
  const _FamilyCase(
    name: 'and_single_acode_case',
    family: 'and_single_acode',
    input: 'one',
    spec: r'''
Top::AND
 /one/ -> Done { return("and-single") }
Done: /one/
''',
  ),
  const _FamilyCase(
    name: 'and_acode_seq_case',
    family: 'and_acode_seq',
    input: 'a b',
    spec: r'''
Top::AND
 /a/ -> First
 /[ \t]+b/ -> Second { return("and-seq") }
First: /a/
Second: /[ \t]+b/
''',
  ),
  const _FamilyCase(
    name: 'and_bcode_case',
    family: 'and_bcode',
    input: 'a b',
    spec: r'''
Top::AND
 => ChildA
 => ChildB
ChildA: /a/ E { return("A") }
ChildB: /[ \t]+b/ E { return("B") }
''',
  ),
  const _FamilyCase(
    name: 'or_bcode_case',
    family: 'or_bcode',
    input: 'a',
    spec: r'''
Top::OR
 => ChildA
 => ChildB
 E { return(cat("or-bcode:", retv)) }
ChildA: /a/ E { return("A") }
ChildB: /b/ E { return("B") }
''',
  ),
  const _FamilyCase(
    name: 'rep_acode_case',
    family: 'rep_acode',
    input: 'abab',
    spec: r'''
Top::OR{2,3}
 I { set(array(out), []) }
 /a/ -> A { push(array(out), match_text()) }
 /b/ -> B { push(array(out), match_text()) }
 E { return(copy(array(out))) }
A: /a/
B: /b/
''',
  ),
  const _FamilyCase(
    name: 'rep_bcode_case',
    family: 'rep_bcode',
    input: 'abab',
    spec: r'''
Top::OR{2,3}
 I { set(array(out), []) }
 => A
 => B
 LE { push(array(out), retv) }
 E { return(copy(array(out))) }
A:& /a/ LE { return("A") }
B:& /b/ LE { return("B") }
''',
  ),
  const _FamilyCase(
    name: 'rep_and_acode_case',
    family: 'rep_and_acode',
    input: 'abab',
    spec: r'''
Top::AND{2}
 I { set(array(pairs), []); set(array(pair), []) }
 /a/ -> A { push(array(pair), match_text()) }
 /b/ -> B { push(array(pair), match_text()) }
 IT { push(array(pairs), copy(array(pair))); set(array(pair), []) }
 E { return(copy(array(pairs))) }
A: /a/
B: /b/
''',
  ),
  const _FamilyCase(
    name: 'rep_and_bcode_case',
    family: 'rep_and_bcode',
    input: 'abab',
    spec: r'''
Top::AND{2}
 I { set(array(groups), []); set(array(group), []) }
 => A { push(array(group), retv) }
 => B { push(array(group), retv) }
 IT { push(array(groups), copy(array(group))); set(array(group), []) }
 E { return(copy(array(groups))) }
A:& /a/ LE { return("A") }
B:& /b/ LE { return("B") }
''',
  ),
];

final class _FamilyCase {
  const _FamilyCase({
    required this.name,
    required this.family,
    required this.input,
    required this.spec,
  });

  final String name;
  final String family;
  final String input;
  final String spec;
}

CompiledSpec _compileProbe() {
  return compileSpec(
    parseSpec(r'''
Top::
 /x/
 E { return("λ:$") }
'''),
  );
}

Future<ProcessResult> _expectProcessSuccess(
  Directory workingDirectory,
  Map<String, String> environment,
  List<String> arguments,
) async {
  final result = await Process.run(
    Platform.resolvedExecutable,
    arguments,
    workingDirectory: workingDirectory.path,
    environment: environment,
  );
  expect(
    result.exitCode,
    0,
    reason:
        'dart ${arguments.join(' ')} failed\n'
        'stdout:\n${result.stdout}\n'
        'stderr:\n${result.stderr}',
  );
  return result;
}
