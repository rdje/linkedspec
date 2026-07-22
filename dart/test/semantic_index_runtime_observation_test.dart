// FUTURE-PARITY-BACKLOG.10.5.5.1 — typed invocation-local capture.

import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

const _runtimeInput = 'ab\n';
const _runtimeInputIdentity =
    'input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece';

void main() {
  late String source;
  late CompiledSpec compiled;

  setUpAll(() {
    source = File(
      '../capability_conformance/semantic_introspection/runtime.spec',
    ).readAsStringSync();
    expect(
      File(
        '../capability_conformance/semantic_introspection/runtime.input',
      ).readAsStringSync(),
      _runtimeInput,
    );
    compiled = _compile(source);
  });

  test('captures exact typed slot and final-result events', () {
    final events = <RuntimeSemanticObservationEvent>[];
    final result = LinkedSpecRuntimeEngine(
      compiled,
    ).parse(_runtimeInput, semanticObservationSink: events.add);

    expect(result.value, ['A', 'B']);
    expect(result.cursorCharOffset, 2);
    expect(events, _expectedEvents);
    expect(events.map((event) => event.toJson()).toList(), [
      {
        'contract_id': linkedSpecSemanticExecutionObservationContract,
        'event_kind': 'regex_slot_selected',
        'rule_label': 'Top',
        'target_rule': 'Top',
        'regex_index': 0,
        'position': 1,
        'input_identity': null,
        'status': null,
      },
      {
        'contract_id': linkedSpecSemanticExecutionObservationContract,
        'event_kind': 'regex_slot_selected',
        'rule_label': 'Top',
        'target_rule': 'Top',
        'regex_index': 1,
        'position': 2,
        'input_identity': null,
        'status': null,
      },
      {
        'contract_id': linkedSpecSemanticExecutionObservationContract,
        'event_kind': 'rule_result',
        'rule_label': 'Top',
        'target_rule': null,
        'regex_index': null,
        'position': 2,
        'input_identity': _runtimeInputIdentity,
        'status': 'succeeded',
      },
    ]);
  });

  test(
    'reuses exact capture through direct loaded and reconstructed state',
    () {
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-semantic-observation-',
      );
      try {
        File(
          '${scratch.path}${Platform.pathSeparator}runtime.spec',
        ).writeAsStringSync(source);
        final loaded = loadAndCompileSpec(
          const SpecRequest.path('runtime.spec'),
          SpecLoadOptions(cwd: scratch),
        );
        final parsed = parseSpec(source);
        final reconstructedSpec = SpecFile.fromJson(parsed.toJson());
        validateSpec(reconstructedSpec);
        final reconstructed = compileSpec(reconstructedSpec);

        final routes = <String, LinkedSpecRuntimeEngine>{
          'direct': LinkedSpecRuntimeEngine(compiled),
          'loaded': loaded.createEngine(),
          'reconstructed': LinkedSpecRuntimeEngine(reconstructed),
        };
        for (final MapEntry(:key, :value) in routes.entries) {
          final baseline = value.parse(_runtimeInput);
          final events = <RuntimeSemanticObservationEvent>[];
          final observed = value.parse(
            _runtimeInput,
            semanticObservationSink: events.add,
          );
          expect(observed.toJson(), baseline.toJson(), reason: key);
          expect(events, _expectedEvents, reason: key);
        }
      } finally {
        scratch.deleteSync(recursive: true);
      }
    },
  );

  test('threads every engine entry while preserving trace and diagnostics', () {
    final engine = LinkedSpecRuntimeEngine(compiled);
    final generatedPlan = {
      for (final row in buildGeneratedRulePlan(compiled))
        row.label: GeneratedRuleFamily.values.singleWhere(
          (family) => family.wireName == row.family,
        ),
    };
    final routes =
        <
          String,
          RuntimeParseResult Function(RuntimeSemanticObservationSink sink)
        >{
          'parse': (sink) =>
              engine.parse(_runtimeInput, semanticObservationSink: sink),
          'execute': (sink) =>
              engine.execute(_runtimeInput, semanticObservationSink: sink),
          'parseWithTrace': (sink) => engine.parseWithTrace(
            _runtimeInput,
            const LinkedSpecTraceConfig(),
            semanticObservationSink: sink,
          ),
          'executeWithTrace': (sink) => engine.executeWithTrace(
            _runtimeInput,
            const LinkedSpecTraceConfig(),
            semanticObservationSink: sink,
          ),
          'executeGeneratedWithPlan': (sink) => engine.executeGeneratedWithPlan(
            _runtimeInput,
            generatedPlan,
            'semantic-introspection/runtime.spec',
            semanticObservationSink: sink,
          ),
        };
    for (final MapEntry(:key, :value) in routes.entries) {
      final events = <RuntimeSemanticObservationEvent>[];
      expect(value(events.add).value, ['A', 'B'], reason: key);
      expect(events, _expectedEvents, reason: key);
    }

    const traceConfig = LinkedSpecTraceConfig(
      level: LinkedSpecTraceLevel.debug,
    );
    final baselineTrace = LinkedSpecTraceEmitter(
      traceConfig,
      stdoutWriter: (_) {},
    );
    final observedTrace = LinkedSpecTraceEmitter(
      traceConfig,
      stdoutWriter: (_) {},
    );
    final baselineDiagnostics = <RuntimeDiagnosticOutputEvent>[];
    final observedDiagnostics = <RuntimeDiagnosticOutputEvent>[];
    final observedEvents = <RuntimeSemanticObservationEvent>[];
    final baseline = engine.parse(
      _runtimeInput,
      trace: baselineTrace,
      diagnosticOutputSink: baselineDiagnostics.add,
    );
    final observed = engine.parse(
      _runtimeInput,
      trace: observedTrace,
      diagnosticOutputSink: observedDiagnostics.add,
      semanticObservationSink: observedEvents.add,
    );

    expect(observed.toJson(), baseline.toJson());
    expect(observedTrace.lines, baselineTrace.lines);
    expect(
      observedTrace.events.map((event) => event.toJson()),
      baselineTrace.events.map((event) => event.toJson()),
    );
    expect(
      observedDiagnostics.map((event) => event.toJson()),
      baselineDiagnostics.map((event) => event.toJson()),
    );
    expect(observedEvents, _expectedEvents);
  });

  test('uses Unicode scalar positions and exact UTF-8 input identity', () {
    final engine = LinkedSpecRuntimeEngine(
      _compile('''
Töp::
 /🙂/
 E { return("ok") }
'''),
    );
    final events = <RuntimeSemanticObservationEvent>[];
    final result = engine.parse('é🙂', semanticObservationSink: events.add);

    expect(result.cursorCodeUnit, 3);
    expect(result.cursorCharOffset, 2);
    expect(events.map((event) => event.position), [2, 2]);
    expect(events.first.ruleLabel, 'Töp');
    expect(
      events.last.inputIdentity,
      RuntimeSemanticObservationEvent.ruleResult(
        ruleLabel: 'Töp',
        position: 2,
        input: 'é🙂',
      ).inputIdentity,
    );
  });

  test('preserves caller failure identity and omits failed final results', () {
    final engine = LinkedSpecRuntimeEngine(compiled);
    for (final route
        in <RuntimeParseResult Function(RuntimeSemanticObservationSink sink)>[
          (sink) => engine.parse(_runtimeInput, semanticObservationSink: sink),
          (sink) => engine.parseWithTrace(
            _runtimeInput,
            const LinkedSpecTraceConfig(),
            semanticObservationSink: sink,
          ),
        ]) {
      final failure = _CallerObservationFailure();
      final failureStack = StackTrace.current;
      try {
        route((_) => Error.throwWithStackTrace(failure, failureStack));
        fail('semantic observation sink returned normally');
      } on Object catch (error, stackTrace) {
        expect(identical(error, failure), isTrue);
        expect(identical(stackTrace, failureStack), isTrue);
      }
    }

    final exitEvents = <RuntimeSemanticObservationEvent>[];
    final exitEngine = LinkedSpecRuntimeEngine(
      _compile('''
Top::
 /x/
 E { exit_now(7) }
'''),
    );
    expect(
      () => exitEngine.parse('x', semanticObservationSink: exitEvents.add),
      throwsA(isA<RuntimeExitNow>().having((exit) => exit.status, 'status', 7)),
    );
    expect(exitEvents, hasLength(1));
    expect(
      exitEvents.single.eventKind,
      RuntimeSemanticObservationEventKind.regexSlotSelected,
    );
  });
}

CompiledSpec _compile(String source) {
  final parsed = parseSpec(source);
  validateSpec(parsed);
  return compileSpec(parsed);
}

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
    input: _runtimeInput,
  ),
];

final class _CallerObservationFailure implements Exception {}
