import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

const _source = '''fn normalize(value) { return(trim(value)) }

Top::
 /x/
 E { return(normalize(" value ")) }
''';

void main() {
  test('system temporary root follows routed project storage', () {
    final configured = Platform.environment['TMPDIR'];
    expect(configured, isNotNull);
    expect(
      Directory.systemTemp.resolveSymbolicLinksSync(),
      Directory(configured!).resolveSymbolicLinksSync(),
    );
  });

  test('one routed emitter spans native loading compilation and runtime', () {
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-native-pipeline-trace-',
    );
    addTearDown(() {
      if (scratch.existsSync()) {
        scratch.deleteSync(recursive: true);
      }
    });
    final specFile = File(
      '${scratch.path}${Platform.pathSeparator}pipeline.spec',
    )..writeAsStringSync(_source);
    final request = SpecRequest.path(specFile.path);
    final options = SpecLoadOptions(cwd: scratch);
    final expectedLoaded = loadAndCompileSpec(request, options);
    final expectedResult = expectedLoaded.createEngine().execute('x');
    final traceFile = File(
      '${scratch.path}${Platform.pathSeparator}pipeline.trace.log',
    );
    final stdout = StringBuffer();
    final trace = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(
        LinkedSpecTraceLevel.debug,
      ).withTraceFile(traceFile.path).withResetFile(true),
      stdoutWriter: stdout.write,
    );

    final actualLoaded = loadAndCompileSpec(request, options, trace: trace);
    final actualResult = actualLoaded.createEngine().execute('x', trace: trace);

    expect(actualLoaded.loaded.sourceText, expectedLoaded.loaded.sourceText);
    expect(actualLoaded.compiled.toJson(), expectedLoaded.compiled.toJson());
    expect(actualResult.toJson(), expectedResult.toJson());
    expect(actualResult.value, 'value');
    expect(actualLoaded.createEngine().specPath, specFile.path);
    expect(stdout.toString(), isEmpty);
    _expectBalancedScopes(trace.events);

    final topics = trace.events.map((event) => event.topic).toSet();
    expect(
      topics,
      containsAll({
        'dart_io:load_and_compile_spec',
        'dart_io:load_and_compile_spec:loaded',
        'dart_frontend:parse_spec_with_functions',
        'dart_frontend:function_parser_execute',
        'dart_frontend:function_projection',
        'dart_staged:execute_jobs',
        'dart_staged:job:resolve',
        'dart_staged:job:load',
        'dart_staged:job:compile',
        'dart_staged:job:execute',
        'dart_frontend:validate_spec',
        'dart_compiler:compile_spec',
        'dart_compiler:function_registry',
        'dart_runtime:parse',
      }),
    );
    final routed = traceFile.readAsStringSync();
    expect(routed, contains('dart_io:load_and_compile_spec'));
    expect(routed, contains('dart_staged:job:execute'));
    expect(routed, contains('dart_runtime:parse'));
  });

  test('disabled native pipeline tracing is quiet and identical', () {
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-native-pipeline-quiet-',
    );
    addTearDown(() {
      if (scratch.existsSync()) {
        scratch.deleteSync(recursive: true);
      }
    });
    final specFile = File(
      '${scratch.path}${Platform.pathSeparator}pipeline.spec',
    )..writeAsStringSync(_source);
    final request = SpecRequest.path(specFile.path);
    final options = SpecLoadOptions(cwd: scratch);
    final expected = loadAndCompileSpec(request, options);
    final stdout = StringBuffer();
    final trace = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.disabled(),
      stdoutWriter: stdout.write,
    );

    final actual = loadAndCompileSpec(request, options, trace: trace);
    final result = actual.createEngine().execute('x', trace: trace);

    expect(actual.compiled.toJson(), expected.compiled.toJson());
    expect(result.value, 'value');
    expect(trace.events, isEmpty);
    expect(trace.lines, isEmpty);
    expect(stdout.toString(), isEmpty);
  });

  test(
    'native validation failures retain exact structured errors and balance',
    () {
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-native-pipeline-failure-',
      );
      addTearDown(() {
        if (scratch.existsSync()) {
          scratch.deleteSync(recursive: true);
        }
      });
      final specFile = File(
        '${scratch.path}${Platform.pathSeparator}invalid.spec',
      )..writeAsStringSync('# no rules\n');
      final request = SpecRequest.path(specFile.path);
      final options = SpecLoadOptions(cwd: scratch);
      final expected = _pipelineError(request, options);
      final trace = LinkedSpecTraceEmitter(
        LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
        stdoutWriter: (_) {},
      );
      final actual = _pipelineError(request, options, trace: trace);

      expect(actual.toJson(), expected.toJson());
      expect(actual.stage, SpecPipelineStage.validateSpec);
      expect(trace.events.last.kind, LinkedSpecTraceEventKind.exit);
      expect(trace.events.last.topic, 'dart_io:load_and_compile_spec');
      expect(trace.events.last.details, contains('error='));
      _expectBalancedScopes(trace.events);
    },
  );
}

SpecPipelineException _pipelineError(
  SpecRequest request,
  SpecLoadOptions options, {
  LinkedSpecTraceEmitter? trace,
}) {
  try {
    loadAndCompileSpec(request, options, trace: trace);
  } on SpecPipelineException catch (error) {
    return error;
  }
  throw StateError('expected native pipeline failure');
}

void _expectBalancedScopes(List<LinkedSpecTraceEvent> events) {
  final topics = <String>[];
  for (final event in events) {
    switch (event.kind) {
      case LinkedSpecTraceEventKind.enter:
        topics.add(event.topic);
      case LinkedSpecTraceEventKind.exit:
        expect(
          topics,
          isNotEmpty,
          reason: 'exit without enter: ${event.topic}',
        );
        expect(topics.removeLast(), event.topic);
      default:
        break;
    }
  }
  expect(topics, isEmpty, reason: 'unclosed trace scopes: $topics');
}
