import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

const _userFunctionSpec = '''fn label() {return("hit")}

Top::
 /x/
 E { return(label()) }
''';

void main() {
  final contract =
      jsonDecode(
            File(
              '../capability_conformance/native_spec_resolution_contract.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;

  test('consumes every neutral name-validation case', () {
    for (final rawCase in contract['name_validation_cases'] as List<dynamic>) {
      final testCase = rawCase as Map<String, dynamic>;
      final expected = testCase['expect'] as Map<String, dynamic>;
      final request = SpecRequest.named(testCase['value'] as String);
      SpecPipelineException? failure;
      try {
        validateSpecRequest(request);
      } on SpecPipelineException catch (error) {
        failure = error;
      }

      if (expected['status'] == 'ok') {
        expect(failure, isNull, reason: testCase['id'] as String);
      } else {
        expect(failure, isNotNull, reason: testCase['id'] as String);
        expect(failure!.stage.contractName, expected['stage']);
        expect(failure.code.contractName, expected['code']);
      }
    }
  });

  test('consumes every neutral resolution and file-kind case', () {
    for (final rawCase in contract['resolution_cases'] as List<dynamic>) {
      final testCase = rawCase as Map<String, dynamic>;
      final expected = testCase['expect'] as Map<String, dynamic>;
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-spec-resolution-',
      );
      try {
        for (final rawEntry in testCase['entries'] as List<dynamic>) {
          _writeEntry(scratch, rawEntry as Map<String, dynamic>);
        }
        final cwd = _fixtureDirectory(scratch, testCase['cwd'] as String)
          ..createSync(recursive: true);
        final options = SpecLoadOptions(
          cwd: cwd,
          searchRoots: [
            for (final root in testCase['search_roots'] as List<dynamic>)
              _fixtureDirectory(scratch, root as String),
          ],
        );
        final requestMap = testCase['request'] as Map<String, dynamic>;
        final request = requestMap['kind'] == 'name'
            ? SpecRequest.named(requestMap['value'] as String)
            : SpecRequest.path(requestMap['value'] as String);

        ResolvedSpec? resolved;
        SpecPipelineException? failure;
        try {
          resolved = resolveSpec(request, options);
        } on SpecPipelineException catch (error) {
          failure = error;
        }
        if (expected['status'] == 'ok') {
          expect(failure, isNull, reason: testCase['id'] as String);
          expect(
            resolved!.file.path,
            _fixtureFile(scratch, expected['path'] as String).path,
            reason: testCase['id'] as String,
          );
          expect(resolved.origin.contractName, expected['origin']);
        } else {
          expect(failure, isNotNull, reason: testCase['id'] as String);
          expect(failure!.stage.contractName, expected['stage']);
          expect(failure.code.contractName, expected['code']);
          expect(
            failure.resolvedPath,
            expected['resolved_path'] == null
                ? isNull
                : _fixtureFile(
                    scratch,
                    expected['resolved_path'] as String,
                  ).path,
          );
        }
      } finally {
        scratch.deleteSync(recursive: true);
      }
    }
  });

  test('consumes every neutral strict-UTF-8 case', () {
    for (final rawCase in contract['text_cases'] as List<dynamic>) {
      final testCase = rawCase as Map<String, dynamic>;
      final expected = testCase['expect'] as Map<String, dynamic>;
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-spec-text-',
      );
      try {
        File(
          '${scratch.path}${Platform.pathSeparator}source.spec',
        ).writeAsBytesSync(_bytesFromHex(testCase['bytes_hex'] as String));
        LoadedSpec? loaded;
        SpecPipelineException? failure;
        try {
          loaded = loadSpec(
            const SpecRequest.path('source.spec'),
            SpecLoadOptions(cwd: scratch),
          );
        } on SpecPipelineException catch (error) {
          failure = error;
        }

        if (expected['status'] == 'ok') {
          expect(failure, isNull, reason: testCase['id'] as String);
          expect(loaded!.sourceText, expected['text']);
        } else {
          expect(failure, isNotNull, reason: testCase['id'] as String);
          expect(failure!.stage.contractName, expected['stage']);
          expect(failure.code.contractName, expected['code']);
        }
      } finally {
        scratch.deleteSync(recursive: true);
      }
    }
  });

  test('composes full parsing, validation, compilation, and identity', () {
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-spec-pipeline-',
    );
    try {
      final specs = Directory('${scratch.path}${Platform.pathSeparator}specs')
        ..createSync();
      final specFile = File('${specs.path}${Platform.pathSeparator}Demo.spec')
        ..writeAsStringSync(_userFunctionSpec);
      final loaded = loadAndCompileSpec(
        const SpecRequest.named('Demo'),
        SpecLoadOptions(
          cwd: Directory('${scratch.path}${Platform.pathSeparator}cwd'),
          searchRoots: [specs],
        ),
      );

      expect(loaded.loaded.sourceText, _userFunctionSpec);
      expect(loaded.loaded.resolved.file.path, specFile.path);
      expect(loaded.compiled.functions, hasLength(1));
      final engine = loaded.createEngine();
      expect(engine.specName, 'Demo');
      expect(engine.specPath, specFile.path);
      expect(engine.execute('x').value, 'hit');
    } finally {
      scratch.deleteSync(recursive: true);
    }
  });

  test('projects parse and validation failures as structured JSON', () {
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-spec-errors-',
    );
    try {
      File(
        '${scratch.path}${Platform.pathSeparator}parse.spec',
      ).writeAsStringSync('not a spec\n');
      File(
        '${scratch.path}${Platform.pathSeparator}validation.spec',
      ).writeAsStringSync('Only:\n /x/\n');

      final parseFailure = _pipelineFailure(
        () => loadAndCompileSpec(
          const SpecRequest.path('parse.spec'),
          SpecLoadOptions(cwd: scratch),
        ),
      );
      expect(parseFailure.stage, SpecPipelineStage.parseSpec);
      expect(parseFailure.code, SpecPipelineCode.specParseFailed);

      final validationFailure = _pipelineFailure(
        () => loadAndCompileSpec(
          const SpecRequest.path('validation.spec'),
          SpecLoadOptions(cwd: scratch),
        ),
      );
      expect(validationFailure.stage, SpecPipelineStage.validateSpec);
      expect(validationFailure.code, SpecPipelineCode.specValidationFailed);

      final missing = _pipelineFailure(
        () => resolveSpec(
          const SpecRequest.named('Missing'),
          SpecLoadOptions(cwd: scratch),
        ),
      );
      expect(missing.toJson(), {
        'type': 'spec_pipeline_error',
        'stage': 'resolve_spec_path',
        'code': 'spec_path_not_found',
        'summary': 'Spec path not found',
        'request_kind': 'name',
        'requested': 'Missing',
      });
    } finally {
      scratch.deleteSync(recursive: true);
    }
  });
}

SpecPipelineException _pipelineFailure(Object? Function() operation) {
  try {
    operation();
  } on SpecPipelineException catch (error) {
    return error;
  }
  throw StateError('operation unexpectedly succeeded');
}

Directory _fixtureDirectory(Directory root, String portablePath) =>
    Directory(_fixturePath(root.path, portablePath));

File _fixtureFile(Directory root, String portablePath) =>
    File(_fixturePath(root.path, portablePath));

String _fixturePath(String root, String portablePath) => portablePath
    .split('/')
    .fold(
      root,
      (path, component) => '$path${Platform.pathSeparator}$component',
    );

void _writeEntry(Directory root, Map<String, dynamic> entry) {
  final path = _fixturePath(root.path, entry['path'] as String);
  switch (entry['kind']) {
    case 'file':
      final file = File(path);
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('fixture');
    case 'directory':
    case 'non_regular':
      Directory(path).createSync(recursive: true);
    default:
      throw StateError('unsupported fixture kind ${entry['kind']}');
  }
}

List<int> _bytesFromHex(String hex) => [
  for (var index = 0; index < hex.length; index += 2)
    int.parse(hex.substring(index, index + 2), radix: 16),
];
