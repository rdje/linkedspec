// FUTURE-PARITY-BACKLOG.10.5.5.3 — generated and emitted observation routes.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/semantic/sha256.dart';
import 'package:test/test.dart';

const _input = 'ab\n';
const _responseDigest =
    '36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887';
const _identity = 'semantic-introspection/runtime.spec';

void main() {
  late String source;
  late CompiledSpec compiled;
  late List<GeneratedPlanRow> plan;
  late SemanticIndex base;

  setUpAll(() {
    source = File(
      '../capability_conformance/semantic_introspection/runtime.spec',
    ).readAsStringSync();
    final parsed = parseSpec(source);
    validateSpec(parsed);
    compiled = compileSpec(parsed);
    plan = buildGeneratedRulePlan(compiled);
    base = SemanticIndex.fromSource(
      source,
      options: const SemanticIndexOptions(
        logicalName: 'runtime.spec',
        sourceDetailCeiling: SemanticSourceDetail.text,
      ),
    );
  });

  test('public generated helpers preserve exact observations and outputs', () {
    final baselineDiagnostics = <RuntimeDiagnosticOutputEvent>[];
    final baseline = executeGeneratedParserV2(
      compiled,
      plan,
      _input,
      _identity,
      diagnosticOutputSink: baselineDiagnostics.add,
    );
    final events = <RuntimeSemanticObservationEvent>[];
    final observedDiagnostics = <RuntimeDiagnosticOutputEvent>[];
    final observed = executeGeneratedParserV2(
      compiled,
      plan,
      _input,
      _identity,
      diagnosticOutputSink: observedDiagnostics.add,
      semanticObservationSink: events.add,
    );

    expect(observed, baseline);
    expect(_eventJson(events), _eventJson(_expectedEvents));
    expect(
      _diagnosticJson(observedDiagnostics),
      _diagnosticJson(baselineDiagnostics),
    );
    _expectTwentiethDigest(base, events);

    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-semantic-generated-trace-',
    );
    try {
      final baselineTrace = '${scratch.path}/baseline.trace';
      final observedTrace = '${scratch.path}/observed.trace';
      final tracedBaseline = executeGeneratedParserWithTraceV2(
        compiled,
        plan,
        _input,
        LinkedSpecTraceConfig(
          level: LinkedSpecTraceLevel.debug,
          traceFile: baselineTrace,
          sinkMode: LinkedSpecTraceSinkMode.route,
          resetFile: true,
        ),
        _identity,
      );
      final tracedEvents = <RuntimeSemanticObservationEvent>[];
      final tracedObserved = executeGeneratedParserWithTraceV2(
        compiled,
        plan,
        _input,
        LinkedSpecTraceConfig(
          level: LinkedSpecTraceLevel.debug,
          traceFile: observedTrace,
          sinkMode: LinkedSpecTraceSinkMode.route,
          resetFile: true,
        ),
        _identity,
        semanticObservationSink: tracedEvents.add,
      );

      expect(tracedObserved, tracedBaseline);
      expect(
        File(observedTrace).readAsStringSync(),
        File(baselineTrace).readAsStringSync(),
      );
      expect(_eventJson(tracedEvents), _eventJson(_expectedEvents));
      _expectTwentiethDigest(base, tracedEvents);
    } finally {
      scratch.deleteSync(recursive: true);
    }

    for (final route in <void Function(RuntimeSemanticObservationSink sink)>[
      (sink) => executeGeneratedParserV2(
        compiled,
        plan,
        _input,
        _identity,
        semanticObservationSink: sink,
      ),
      (sink) => executeGeneratedParserWithTraceV2(
        compiled,
        plan,
        _input,
        LinkedSpecTraceConfig.disabled(),
        _identity,
        semanticObservationSink: sink,
      ),
    ]) {
      final failure = _CallerObservationFailure();
      final failureStack = StackTrace.current;
      try {
        route((_) => Error.throwWithStackTrace(failure, failureStack));
        fail('generated observation sink returned normally');
      } on Object catch (error, stackTrace) {
        expect(identical(error, failure), isTrue);
        expect(identical(stackTrace, failureStack), isTrue);
      }
    }

    final exitCompiled = _compile('''
Top::
 /x/
 E { exit_now(7) }
''');
    final exitEvents = <RuntimeSemanticObservationEvent>[];
    expect(
      () => executeGeneratedParserV2(
        exitCompiled,
        buildGeneratedRulePlan(exitCompiled),
        'x',
        'semantic-introspection/exit.spec',
        semanticObservationSink: exitEvents.add,
      ),
      throwsA(
        isA<RuntimeExitNow>().having((error) => error.status, 'status', 7),
      ),
    );
    expect(exitEvents, hasLength(1));
    expect(
      exitEvents.single.eventKind,
      RuntimeSemanticObservationEventKind.regexSlotSelected,
    );
  });

  test(
    'standalone emitted direct and traced APIs preserve exact observations',
    () async {
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-semantic-emitted-',
      );
      final pubCache = Directory('${scratch.path}/pub-cache')..createSync();
      final packageRoot = Directory.current.absolute;
      try {
        Directory('${scratch.path}/lib').createSync();
        Directory('${scratch.path}/bin').createSync();
        File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_semantic_emitted_probe
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ${jsonEncode(packageRoot.path)}
''');
        File(
          '${scratch.path}/lib/generated.dart',
        ).writeAsStringSync(emitDartSourceV2(compiled, _identity));
        final exitCompiled = _compile('''
Top::
 /x/
 E { exit_now(7) }
''');
        File('${scratch.path}/lib/exit_generated.dart').writeAsStringSync(
          emitDartSourceV2(
            exitCompiled,
            'semantic-introspection/emitted-exit.spec',
          ),
        );
        File('${scratch.path}/bin/main.dart').writeAsStringSync(r'''
import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_semantic_emitted_probe/exit_generated.dart'
    as exit_generated;
import 'package:linkedspec_semantic_emitted_probe/generated.dart' as generated;

final class CallerObservationFailure implements Exception {}

bool preservesFailure(
  void Function(RuntimeSemanticObservationSink sink) invoke,
) {
  final failure = CallerObservationFailure();
  final failureStack = StackTrace.current;
  try {
    invoke((_) => Error.throwWithStackTrace(failure, failureStack));
  } on Object catch (error, stackTrace) {
    return identical(error, failure) && identical(stackTrace, failureStack);
  }
  return false;
}

void main() {
  const input = 'ab\n';
  final directEvents = <RuntimeSemanticObservationEvent>[];
  final baselineDiagnostics = <RuntimeDiagnosticOutputEvent>[];
  final observedDiagnostics = <RuntimeDiagnosticOutputEvent>[];
  final baseline = generated.execute(
    input,
    diagnosticOutputSink: baselineDiagnostics.add,
  );
  final observed = generated.execute(
    input,
    diagnosticOutputSink: observedDiagnostics.add,
    semanticObservationSink: directEvents.add,
  );

  final tracedEvents = <RuntimeSemanticObservationEvent>[];
  final tracedBaseline = generated.executeWithTrace(
    input,
    const LinkedSpecTraceConfig(
      level: LinkedSpecTraceLevel.debug,
      traceFile: 'baseline.trace',
      sinkMode: LinkedSpecTraceSinkMode.route,
      resetFile: true,
    ),
  );
  final tracedObserved = generated.executeWithTrace(
    input,
    const LinkedSpecTraceConfig(
      level: LinkedSpecTraceLevel.debug,
      traceFile: 'observed.trace',
      sinkMode: LinkedSpecTraceSinkMode.route,
      resetFile: true,
    ),
    semanticObservationSink: tracedEvents.add,
  );

  final directFailureIdentity = preservesFailure(
    (sink) => generated.execute(input, semanticObservationSink: sink),
  );
  final tracedFailureIdentity = preservesFailure(
    (sink) => generated.executeWithTrace(
      input,
      LinkedSpecTraceConfig.disabled(),
      semanticObservationSink: sink,
    ),
  );

  final exitEvents = <RuntimeSemanticObservationEvent>[];
  int? exitStatus;
  try {
    exit_generated.execute('x', semanticObservationSink: exitEvents.add);
  } on RuntimeExitNow catch (error) {
    exitStatus = error.status;
  }

  print(jsonEncode({
    'contract': generated.linkedspecGeneratedSourceContract,
    'format': generated.linkedspecGeneratedSourceFormat,
    'baseline': baseline,
    'observed': observed,
    'traced_baseline': tracedBaseline,
    'traced_observed': tracedObserved,
    'direct_events': [for (final event in directEvents) event.toJson()],
    'traced_events': [for (final event in tracedEvents) event.toJson()],
    'diagnostics_equal': jsonEncode([
      for (final event in baselineDiagnostics) event.toJson(),
    ]) == jsonEncode([
      for (final event in observedDiagnostics) event.toJson(),
    ]),
    'trace_equal': File('baseline.trace').readAsStringSync() ==
        File('observed.trace').readAsStringSync(),
    'direct_failure_identity': directFailureIdentity,
    'traced_failure_identity': tracedFailureIdentity,
    'exit_status': exitStatus,
    'exit_events': [for (final event in exitEvents) event.toJson()],
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
        final output = (jsonDecode((run.stdout as String).trim()) as Map)
            .cast<String, Object?>();

        expect(output['contract'], linkedSpecGeneratedSourceContract);
        expect(output['format'], linkedSpecGeneratedSourceFormatVersion);
        expect(output['observed'], output['baseline']);
        expect(output['traced_observed'], output['traced_baseline']);
        expect(output['diagnostics_equal'], isTrue);
        expect(output['trace_equal'], isTrue);
        expect(output['direct_failure_identity'], isTrue);
        expect(output['traced_failure_identity'], isTrue);
        expect(output['exit_status'], 7);

        final directEvents = _eventsFromJson(output['direct_events']);
        final tracedEvents = _eventsFromJson(output['traced_events']);
        expect(_eventJson(directEvents), _eventJson(_expectedEvents));
        expect(_eventJson(tracedEvents), _eventJson(_expectedEvents));
        _expectTwentiethDigest(base, directEvents);
        _expectTwentiethDigest(base, tracedEvents);

        final exitEvents = _eventsFromJson(output['exit_events']);
        expect(exitEvents, hasLength(1));
        expect(
          exitEvents.single.eventKind,
          RuntimeSemanticObservationEventKind.regexSlotSelected,
        );
      } finally {
        scratch.deleteSync(recursive: true);
      }
      expect(scratch.existsSync(), isFalse);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

CompiledSpec _compile(String source) {
  final parsed = parseSpec(source);
  validateSpec(parsed);
  return compileSpec(parsed);
}

List<Map<String, Object?>> _eventJson(
  List<RuntimeSemanticObservationEvent> events,
) => [for (final event in events) event.toJson()];

List<Map<String, Object?>> _diagnosticJson(
  List<RuntimeDiagnosticOutputEvent> events,
) => [for (final event in events) event.toJson()];

List<RuntimeSemanticObservationEvent> get _expectedEvents => [
  RuntimeSemanticObservationEvent.regexSlotSelected(
    ruleLabel: 'Top',
    targetRule: 'Top',
    regexIndex: 0,
    position: 1,
  ),
  RuntimeSemanticObservationEvent.regexSlotSelected(
    ruleLabel: 'Top',
    targetRule: 'Top',
    regexIndex: 1,
    position: 2,
  ),
  RuntimeSemanticObservationEvent.ruleResult(
    ruleLabel: 'Top',
    position: 2,
    input: _input,
  ),
];

List<RuntimeSemanticObservationEvent> _eventsFromJson(Object? value) => [
  for (final raw in (value! as List<Object?>))
    _eventFromJson((raw! as Map).cast<String, Object?>()),
];

RuntimeSemanticObservationEvent _eventFromJson(Map<String, Object?> value) =>
    RuntimeSemanticObservationEvent(
      contractId: value['contract_id']! as String,
      eventKind: RuntimeSemanticObservationEventKind.values.singleWhere(
        (kind) => kind.wireName == value['event_kind'],
      ),
      ruleLabel: value['rule_label']! as String,
      targetRule: value['target_rule'] as String?,
      regexIndex: value['regex_index'] as int?,
      position: value['position']! as int,
      inputIdentity: value['input_identity'] as String?,
      status: value['status'] as String?,
    );

void _expectTwentiethDigest(
  SemanticIndex base,
  List<RuntimeSemanticObservationEvent> events,
) {
  final response = base
      .withExecutionObservation(events)
      .query(
        SemanticQuery(
          operation: SemanticQueryOperation.list,
          recordKinds: const ['execution', 'event'],
          source: const SemanticQuerySource(
            detail: SemanticSourceDetail.identity,
          ),
        ),
      );
  expect(_canonicalDigest(response.toJson()), _responseDigest);
}

String _canonicalDigest(Map<String, Object?> value) =>
    sha256Hex(utf8.encode(jsonEncode(_canonicalValue(value))));

Object? _canonicalValue(Object? value) {
  if (value case Map<Object?, Object?>()) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return <String, Object?>{
      for (final key in keys) key: _canonicalValue(value[key]),
    };
  }
  if (value case List<Object?>()) {
    return [for (final item in value) _canonicalValue(item)];
  }
  return value;
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

final class _CallerObservationFailure implements Exception {}
