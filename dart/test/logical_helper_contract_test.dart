import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/cli/primary_cli.dart';
import 'package:linkedspec_dart/src/runtime/interpreter.dart'
    show runtimeLogicalTruth;
import 'package:test/test.dart';

Map<String, Object?> _contract() {
  return (jsonDecode(
            File(
              '../capability_conformance/logical_helper_contract.json',
            ).readAsStringSync(),
          )
          as Map)
      .cast<String, Object?>();
}

Map<String, Object?> _fixture(Map<String, Object?> contract, String id) {
  final fixtures = (contract['fixtures']! as Map).cast<String, Object?>();
  return (fixtures[id]! as Map).cast<String, Object?>();
}

List<Map<String, Object?>> _invalidCases(Map<String, Object?> contract) {
  return (contract['invalid_arity_cases']! as List)
      .cast<Map<Object?, Object?>>()
      .map((row) => row.cast<String, Object?>())
      .toList(growable: false);
}

List<Map<String, Object?>> _invalidFixtures(Map<String, Object?> contract) {
  final fixtures = (contract['fixtures']! as Map).cast<String, Object?>();
  return (fixtures['invalid_arity']! as List)
      .cast<Map<Object?, Object?>>()
      .map((row) => row.cast<String, Object?>())
      .toList(growable: false);
}

CompiledSpec _compileSource(String source) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  validateSpec(parsed);
  return compileSpec(parsed);
}

CompiledSpec _reconstructFromEmittedPayload(
  CompiledSpec compiled,
  String identity,
) {
  final emitted = emitDartSourceV1(compiled, identity);
  final encoded = RegExp(
    "const _compiledSpecJsonBase64 = '([^']+)';",
  ).firstMatch(emitted)![1]!;
  final normalized = (jsonDecode(utf8.decode(base64Decode(encoded))) as Map)
      .cast<String, Object?>();
  return compileSpec(SpecFile.fromJson(normalized));
}

Map<String, Object?> _caseFor(List<Map<String, Object?>> cases, String id) {
  return cases.singleWhere((row) => row['id'] == id);
}

Object? _runtimeValue(Map<String, Object?> value) {
  return switch (value['kind']) {
    'null' => null,
    'boolean' || 'number' || 'string' => value['value'],
    'array' => [
      for (final item in value['items']! as List)
        _runtimeValue((item as Map).cast<String, Object?>()),
    ],
    'harray' => {
      for (final entry
          in (value['entries']! as Map).cast<String, Object?>().entries)
        entry.key: _runtimeValue((entry.value! as Map).cast<String, Object?>()),
    },
    'codeblock' => parseActionBlock('fail("codeblock must not run")'),
    final kind => throw StateError('unsupported logical value kind $kind'),
  };
}

void _expectArityDiagnostic(
  RuntimeInterpreterException error,
  Map<String, Object?> row,
) {
  final diagnostic = error.diagnostic?.toJson();
  expect(diagnostic, isNotNull, reason: row['id']! as String);
  expect(diagnostic!['stage'], 'helper_arity_mismatch');
  expect(diagnostic['code'], row['expected_code']);
  expect(diagnostic['helper_name'], row['helper_name']);
  expect(diagnostic['actual_arity'], row['actual_arity']);
  expect(diagnostic['expected_arity'], row['expected_arity']);
  expect(diagnostic['rule_label'], 'Top');
  expect(error.message, contains('helper_arity_mismatch'));
  expect(error.message, contains('helper_name=${row['helper_name']}'));
  expect(error.message, contains('actual_arity=${row['actual_arity']}'));
  expect(error.message, isNot(contains('must not run')));
}

void _expectGeneratedArityDiagnostic(
  GeneratedSourceException error,
  Map<String, Object?> row,
  String identity,
) {
  final diagnostic = error.toJson();
  expect(diagnostic['stage'], 'execute_generated');
  expect(diagnostic['code'], 'generated_execution_failed');
  expect(diagnostic['source_identity'], identity);
  expect(diagnostic['rule_label'], 'Top');
  expect(diagnostic['handler_family'], 'default');
  expect(diagnostic['detail'], contains('helper_arity_mismatch'));
  expect(diagnostic['detail'], contains('helper_name=${row['helper_name']}'));
  expect(diagnostic['detail'], contains('actual_arity=${row['actual_arity']}'));
  expect(diagnostic['detail'], isNot(contains('must not run')));
}

Future<ProcessResult> _expectDartSuccess(
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

void main() {
  final contract = _contract();

  test('loads the exact logical-helper authority', () {
    expect(contract['format'], 1);
    expect(contract['contract_id'], 'linkedspec-logical-helper-v1');
    expect((contract['truthiness_cases']! as List), hasLength(17));
    expect((contract['helper_cases']! as List), hasLength(10));
  });

  test('every typed truth row uses the one Dart runtime seam', () {
    final rows = (contract['truthiness_cases']! as List)
        .cast<Map<Object?, Object?>>();

    for (final rawRow in rows) {
      final row = rawRow.cast<String, Object?>();
      final value = (row['value']! as Map).cast<String, Object?>();
      expect(
        runtimeLogicalTruth(_runtimeValue(value)),
        row['expected'],
        reason: row['id']! as String,
      );
    }
  });

  for (final fixtureId in ['values', 'effects', 'receiver_and_lazy_control']) {
    test('$fixtureId matches native and normalized execution', () {
      final fixture = _fixture(contract, fixtureId);
      final source = fixture['spec_source']! as String;
      final expected = fixture['expected'];
      final compiled = _compileSource(source);

      expect(
        LinkedSpecRuntimeEngine(compiled).parse('x').value,
        expected,
        reason: 'native $fixtureId',
      );

      final reconstructed = _reconstructFromEmittedPayload(
        compiled,
        'logical-helper/$fixtureId-normalized.spec',
      );
      expect(
        LinkedSpecRuntimeEngine(reconstructed).parse('x').value,
        expected,
        reason: 'normalized $fixtureId',
      );
    });

    test('$fixtureId matches generated-plan execution', () {
      final fixture = _fixture(contract, fixtureId);
      final source = fixture['spec_source']! as String;
      final compiled = _compileSource(source);

      final plan = buildGeneratedRulePlan(compiled);
      final identity = 'logical-helper/$fixtureId-generated.spec';
      final direct = executeGeneratedParserV1(compiled, plan, 'x', identity);
      expect(direct, fixture['expected']);
      expect(
        executeGeneratedParserWithTraceV1(
          compiled,
          plan,
          'x',
          LinkedSpecTraceConfig.disabled(),
          identity,
        ),
        direct,
      );
    });

    test('$fixtureId matches the primary Dart CLI', () {
      final fixture = _fixture(contract, fixtureId);
      final output = runLinkedSpecDartPrimaryCli([
        '--inline-spec',
        fixture['spec_source']! as String,
        '--input',
        'x',
      ]);

      expect(output.exitCode, 0);
      expect(output.stderrBytes, isEmpty);
      expect(jsonDecode(utf8.decode(output.stdoutBytes)), fixture['expected']);
    });
  }

  for (final fixture in _invalidFixtures(contract)) {
    final id = fixture['id']! as String;

    test('$id fails natively before operand effects', () {
      final row = _caseFor(_invalidCases(contract), id);
      final engine = LinkedSpecRuntimeEngine(
        _compileSource(fixture['spec_source']! as String),
      );

      try {
        engine.parse('x');
        fail('$id accepted invalid logical-helper arity');
      } on RuntimeInterpreterException catch (error) {
        _expectArityDiagnostic(error, row);
      } on Object catch (error) {
        fail('$id evaluated an operand or threw $error');
      }
    });

    test('$id fails through normalized and generated-plan execution', () {
      final row = _caseFor(_invalidCases(contract), id);
      final compiled = _compileSource(fixture['spec_source']! as String);
      final reconstructed = _reconstructFromEmittedPayload(
        compiled,
        'logical-helper/$id-normalized.spec',
      );

      try {
        LinkedSpecRuntimeEngine(reconstructed).parse('x');
        fail('$id normalized state accepted invalid arity');
      } on RuntimeInterpreterException catch (error) {
        _expectArityDiagnostic(error, row);
      } on Object catch (error) {
        fail('$id normalized state evaluated an operand or threw $error');
      }

      final identity = 'logical-helper/$id-generated.spec';
      final plan = buildGeneratedRulePlan(compiled);
      try {
        executeGeneratedParserV1(compiled, plan, 'x', identity);
        fail('$id generated plan accepted invalid arity');
      } on GeneratedSourceException catch (error) {
        _expectGeneratedArityDiagnostic(error, row, identity);
      } on Object catch (error) {
        fail('$id generated plan evaluated an operand or threw $error');
      }

      try {
        executeGeneratedParserWithTraceV1(
          compiled,
          plan,
          'x',
          LinkedSpecTraceConfig.disabled(),
          identity,
        );
        fail('$id traced generated plan accepted invalid arity');
      } on GeneratedSourceException catch (error) {
        _expectGeneratedArityDiagnostic(error, row, identity);
      } on Object catch (error) {
        fail('$id traced generated plan evaluated an operand or threw $error');
      }
    });

    test('$id keeps the primary Dart CLI failure projection', () {
      final output = runLinkedSpecDartPrimaryCli([
        '--inline-spec',
        fixture['spec_source']! as String,
        '--input',
        'x',
      ]);

      expect(output.exitCode, 1);
      expect(output.stdoutBytes, isEmpty);
      expect(
        output.stderrBytes,
        utf8.encode('linkedspec: parser invocation failed\n'),
      );
    });
  }

  test(
    'standalone emitted libraries preserve values effects controls and arity',
    () async {
      final packageRoot = Directory.current.absolute;
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-logical-helper-',
      );
      final pubCache = Directory('${scratch.path}/pub-cache')..createSync();

      try {
        final libraryDirectory = Directory('${scratch.path}/lib')..createSync();
        final binDirectory = Directory('${scratch.path}/bin')..createSync();
        File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_logical_helper_probe
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ${jsonEncode(packageRoot.path)}
''');

        for (final fixtureId in [
          'values',
          'effects',
          'receiver_and_lazy_control',
        ]) {
          final source =
              _fixture(contract, fixtureId)['spec_source']! as String;
          File('${libraryDirectory.path}/$fixtureId.dart').writeAsStringSync(
            emitDartSourceV1(
              _compileSource(source),
              'logical-helper/$fixtureId-emitted.spec',
            ),
          );
        }
        final invalid = _invalidFixtures(
          contract,
        ).singleWhere((row) => row['id'] == 'not_many');
        File('${libraryDirectory.path}/invalid.dart').writeAsStringSync(
          emitDartSourceV1(
            _compileSource(invalid['spec_source']! as String),
            'logical-helper/not_many-emitted.spec',
          ),
        );
        File('${binDirectory.path}/main.dart').writeAsStringSync(r'''
import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_logical_helper_probe/effects.dart' as effects;
import 'package:linkedspec_logical_helper_probe/invalid.dart' as invalid;
import 'package:linkedspec_logical_helper_probe/receiver_and_lazy_control.dart'
    as receiver;
import 'package:linkedspec_logical_helper_probe/values.dart' as values;

void main() {
  Object? invalidFailure;
  try {
    invalid.execute('x');
    throw StateError('not_many unexpectedly executed');
  } on GeneratedSourceException catch (error) {
    invalidFailure = error.toJson();
  }
  Object? invalidTracedFailure;
  try {
    invalid.executeWithTrace('x', LinkedSpecTraceConfig.disabled());
    throw StateError('traced not_many unexpectedly executed');
  } on GeneratedSourceException catch (error) {
    invalidTracedFailure = error.toJson();
  }
  print(jsonEncode({
    'values': {
      'direct': values.execute('x'),
      'traced': values.executeWithTrace('x', LinkedSpecTraceConfig.disabled()),
      'source_identity': values.metadata().sourceIdentity,
    },
    'effects': {
      'direct': effects.execute('x'),
      'traced': effects.executeWithTrace('x', LinkedSpecTraceConfig.disabled()),
      'source_identity': effects.metadata().sourceIdentity,
    },
    'receiver_and_lazy_control': {
      'direct': receiver.execute('x'),
      'traced': receiver.executeWithTrace('x', LinkedSpecTraceConfig.disabled()),
      'source_identity': receiver.metadata().sourceIdentity,
    },
    'invalid': invalidFailure,
    'invalid_traced': invalidTracedFailure,
  }));
}
''');

        final environment = {
          ...Platform.environment,
          'PUB_CACHE': pubCache.path,
        };
        await _expectDartSuccess(scratch, environment, const [
          'pub',
          'get',
          '--offline',
        ]);
        await _expectDartSuccess(scratch, environment, const [
          'analyze',
          '--fatal-infos',
          '--fatal-warnings',
        ]);
        final run = await _expectDartSuccess(scratch, environment, const [
          'run',
          'bin/main.dart',
        ]);
        final observed = (jsonDecode((run.stdout as String).trim()) as Map)
            .cast<String, Object?>();
        for (final fixtureId in [
          'values',
          'effects',
          'receiver_and_lazy_control',
        ]) {
          final roles = (observed[fixtureId]! as Map).cast<String, Object?>();
          expect(
            roles['direct'],
            _fixture(contract, fixtureId)['expected'],
            reason: '$fixtureId direct',
          );
          expect(roles['traced'], roles['direct'], reason: '$fixtureId traced');
          expect(
            roles['source_identity'],
            'logical-helper/$fixtureId-emitted.spec',
          );
        }
        final failure = (observed['invalid']! as Map).cast<String, Object?>();
        expect(failure['stage'], 'execute_generated');
        expect(failure['code'], 'generated_execution_failed');
        expect(failure['detail'], contains('helper_arity_mismatch'));
        expect(failure['detail'], contains('helper_name=not'));
        expect(failure['detail'], contains('actual_arity=2'));
        expect(failure['detail'], isNot(contains('must not run')));
        expect(
          failure['source_identity'],
          'logical-helper/not_many-emitted.spec',
        );
        final tracedFailure = (observed['invalid_traced']! as Map)
            .cast<String, Object?>();
        expect(tracedFailure, failure);
      } finally {
        scratch.deleteSync(recursive: true);
      }

      expect(scratch.existsSync(), isFalse);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
