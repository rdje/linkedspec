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
  print(jsonEncode({
    'metadata': metadata,
    'value': value,
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
      } finally {
        scratch.deleteSync(recursive: true);
      }

      expect(scratch.existsSync(), isFalse);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
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
