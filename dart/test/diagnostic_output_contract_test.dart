import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object?> _contract() {
  return (jsonDecode(
            File(
              '../capability_conformance/diagnostic_output_contract.json',
            ).readAsStringSync(),
          )
          as Map)
      .cast<String, Object?>();
}

LinkedSpecRuntimeEngine _engine(String source) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  validateSpec(parsed);
  return LinkedSpecRuntimeEngine(compileSpec(parsed));
}

String _programSource(Map<String, Object?> contract, String id) {
  final programs = (contract['programs']! as List)
      .cast<Map<Object?, Object?>>();
  final program = programs
      .map((row) => row.cast<String, Object?>())
      .singleWhere((row) => row['id'] == id);
  return program['spec_source']! as String;
}

Map<String, Object?> _scenario(Map<String, Object?> contract, String id) {
  final scenarios = (contract['scenarios']! as List)
      .cast<Map<Object?, Object?>>();
  return scenarios
      .map((row) => row.cast<String, Object?>())
      .singleWhere((row) => row['id'] == id);
}

List<Object?> _eventJson(List<RuntimeDiagnosticOutputEvent> events) {
  return [for (final event in events) event.toJson()];
}

String _renderExpression(Map<String, Object?> value) {
  return switch (value['kind']) {
    'string' => jsonEncode(value['value']),
    'boolean' || 'number' => '${value['value']}',
    'null' => 'undef',
    'array' => '[1]',
    'harray' => '{ "k" : 1 }',
    'codeblock' => '{ return(undef) }',
    final kind => throw StateError('unsupported scalar render kind $kind'),
  };
}

final class _CallerSinkFailure implements Exception {
  const _CallerSinkFailure(this.id);

  final String id;
}

void main() {
  final contract = _contract();

  test('consumes exact ordered Unicode and quiet scenarios', () {
    expect(contract['contract_id'], 'linkedspec-diagnostic-output-v1');
    final eventSchema = (contract['event_schema']! as Map)
        .cast<String, Object?>();
    expect(eventSchema['native_type'], 'RuntimeDiagnosticOutputEvent');

    final source = _programSource(contract, 'ordered_unicode');
    final collected = _scenario(contract, 'ordered_unicode_with_sink');
    final expected = (collected['expected']! as Map).cast<String, Object?>();
    final outcome = (expected['outcome']! as Map).cast<String, Object?>();
    final events = <RuntimeDiagnosticOutputEvent>[];
    final engine = _engine(source);

    final result = engine.parse('x', diagnosticOutputSink: events.add);
    expect(result.output, outcome['output']);
    expect(result.value, outcome['value']);
    expect(_eventJson(events), expected['events']);

    final quiet = _scenario(contract, 'ordered_unicode_quiet');
    final quietExpected = (quiet['expected']! as Map).cast<String, Object?>();
    final quietOutcome = (quietExpected['outcome']! as Map)
        .cast<String, Object?>();
    expect(engine.parse('x').output, quietOutcome['output']);
    expect(engine.execute('x').value, quietOutcome['value']);

    for (final invoke
        in <RuntimeParseResult Function(RuntimeDiagnosticOutputSink sink)>[
          (sink) => engine.execute('x', diagnosticOutputSink: sink),
          (sink) => engine.parseWithTrace(
            'x',
            LinkedSpecTraceConfig.disabled(),
            diagnosticOutputSink: sink,
          ),
          (sink) => engine.executeWithTrace(
            'x',
            LinkedSpecTraceConfig.disabled(),
            diagnosticOutputSink: sink,
          ),
        ]) {
      final aliasEvents = <RuntimeDiagnosticOutputEvent>[];
      expect(invoke(aliasEvents.add).value, outcome['value']);
      expect(_eventJson(aliasEvents), expected['events']);
    }
  });

  test('consumes every scalar render row', () {
    final rows = (contract['scalar_render_cases']! as List)
        .cast<Map<Object?, Object?>>();

    for (final rawRow in rows) {
      final row = rawRow.cast<String, Object?>();
      final value = (row['value']! as Map).cast<String, Object?>();
      final expression = _renderExpression(value);
      final events = <RuntimeDiagnosticOutputEvent>[];
      final result = _engine(
        'Top::\n /x/\n E { print($expression); return("ok") }\n',
      ).parse('x', diagnosticOutputSink: events.add);

      expect(result.value, 'ok', reason: '${row['id']} result');
      expect(events, hasLength(1), reason: '${row['id']} event count');
      expect(
        events.single.message,
        row['expected'],
        reason: '${row['id']} rendering',
      );
    }
  });

  test('rejects every invalid arity before argument evaluation', () {
    final rows = (contract['invalid_arity_cases']! as List)
        .cast<Map<Object?, Object?>>();

    for (final rawRow in rows) {
      final row = rawRow.cast<String, Object?>();
      final helper = row['helper_name']! as String;
      final actual = row['actual_arity']! as int;
      final args = [
        for (var index = 0; index < actual; index++)
          index == 0 ? 'exit_now(77)' : '"arg-$index"',
      ].join(', ');
      final engine = _engine(
        'Top::\n /x/\n E { $helper($args); return("late") }\n',
      );

      try {
        engine.parse('x');
        fail('${row['id']} accepted invalid diagnostic-output arity');
      } on RuntimeInterpreterException catch (error) {
        expect(
          error.diagnostic?.stage,
          row['expected_code'],
          reason: '${row['id']} diagnostic stage',
        );
        expect(
          error.message,
          contains(row['expected_arity']! as String),
          reason: '${row['id']} arity wording',
        );
      } on Object catch (error) {
        fail('${row['id']} evaluated an argument or threw $error');
      }
    }
  });

  test('consumes wrong-kind and immediate-exit scenarios', () {
    final wrong = _scenario(contract, 'wrong_kind_no_events');
    final wrongExpected = (wrong['expected']! as Map).cast<String, Object?>();
    final wrongOutcome = (wrongExpected['outcome']! as Map)
        .cast<String, Object?>();
    final wrongEvents = <RuntimeDiagnosticOutputEvent>[];
    final wrongResult = _engine(
      _programSource(contract, 'wrong_kind'),
    ).parse('x', diagnosticOutputSink: wrongEvents.add);
    expect(wrongResult.output, wrongOutcome['output']);
    expect(_eventJson(wrongEvents), wrongExpected['events']);

    final exit = _scenario(contract, 'event_before_immediate_exit');
    final exitExpected = (exit['expected']! as Map).cast<String, Object?>();
    final exitOutcome = (exitExpected['outcome']! as Map)
        .cast<String, Object?>();
    final exitEvents = <RuntimeDiagnosticOutputEvent>[];
    try {
      _engine(
        _programSource(contract, 'immediate_exit'),
      ).parse('x', diagnosticOutputSink: exitEvents.add);
      fail('exit_now returned normally');
    } on RuntimeExitNow catch (error) {
      expect(error.status, exitOutcome['status']);
    }
    expect(_eventJson(exitEvents), exitExpected['events']);
  });

  test('preserves synchronous caller sink failures unchanged', () {
    for (final scenarioId in [
      'print_each_sink_failure',
      'synchronous_sink_failure',
    ]) {
      final row = _scenario(contract, scenarioId);
      final sink = (row['sink']! as Map).cast<String, Object?>();
      final expected = (row['expected']! as Map).cast<String, Object?>();
      final failure = scenarioId == 'print_each_sink_failure'
          ? RuntimeInterpreterException(sink['error_id']! as String)
          : _CallerSinkFailure(sink['error_id']! as String);
      final events = <RuntimeDiagnosticOutputEvent>[];
      var invocation = 0;

      try {
        _engine(_programSource(contract, row['program_id']! as String)).parse(
          'x',
          diagnosticOutputSink: (event) {
            invocation += 1;
            events.add(event);
            if (invocation == sink['invocation']) {
              throw failure;
            }
          },
        );
        fail('$scenarioId did not propagate the caller sink failure');
      } on Object catch (error) {
        expect(identical(error, failure), isTrue, reason: scenarioId);
      }
      expect(_eventJson(events), expected['events'], reason: scenarioId);
    }
  });

  test('keeps diagnostic events separate from native trace', () {
    const marker = 'diagnostic-only-pré🙂';
    final traceText = StringBuffer();
    final trace = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
      stdoutWriter: traceText.write,
    );
    final events = <RuntimeDiagnosticOutputEvent>[];
    final engine = _engine(
      'Top::\n /x/\n E { say("$marker"); return("ok") }\n',
    );

    final result = engine.parse(
      'x',
      trace: trace,
      diagnosticOutputSink: events.add,
    );
    expect(result.value, 'ok');
    expect(events.single.message, '$marker\n');
    expect(traceText.toString(), contains('dart_runtime:parse'));
    expect(traceText.toString(), isNot(contains(marker)));
  });

  test('generated direct and traced roles preserve diagnostic outcomes', () {
    const identity = 'diagnostic-output/generated-dart.spec';
    final source = _programSource(contract, 'ordered_unicode');
    final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
    validateSpec(parsed);
    final compiled = compileSpec(parsed);
    final plan = buildGeneratedRulePlan(compiled);
    final expected =
        (_scenario(contract, 'ordered_unicode_with_sink')['expected']! as Map)
            .cast<String, Object?>();
    final outcome = (expected['outcome']! as Map).cast<String, Object?>();

    final events = <RuntimeDiagnosticOutputEvent>[];
    final value = executeGeneratedParserV2(
      compiled,
      plan,
      'x',
      identity,
      diagnosticOutputSink: events.add,
    );
    expect(value, outcome['value']);
    expect(_eventJson(events), expected['events']);

    final tracedEvents = <RuntimeDiagnosticOutputEvent>[];
    final traced = executeGeneratedParserWithTraceV2(
      compiled,
      plan,
      'x',
      LinkedSpecTraceConfig.disabled(),
      identity,
      diagnosticOutputSink: tracedEvents.add,
    );
    expect(traced, value);
    expect(_eventJson(tracedEvents), expected['events']);

    final failureScenario = _scenario(contract, 'synchronous_sink_failure');
    final failureSource = _programSource(contract, 'sink_failure');
    final failureParsed = parseSpecWithStagedUserFunctionDefinitions(
      failureSource,
    );
    validateSpec(failureParsed);
    final failureCompiled = compileSpec(failureParsed);
    final failure = _CallerSinkFailure('generated-caller-sink-failure');
    var invocation = 0;
    try {
      executeGeneratedParserV2(
        failureCompiled,
        buildGeneratedRulePlan(failureCompiled),
        'x',
        identity,
        diagnosticOutputSink: (event) {
          invocation += 1;
          if (invocation == 2) {
            throw failure;
          }
        },
      );
      fail('generated caller sink failure returned normally');
    } on Object catch (error) {
      expect(identical(error, failure), isTrue);
    }
    expect(
      ((failureScenario['expected']! as Map)['outcome']! as Map)['kind'],
      'sink_failure',
    );

    final exitSource = _programSource(contract, 'immediate_exit');
    final exitParsed = parseSpecWithStagedUserFunctionDefinitions(exitSource);
    validateSpec(exitParsed);
    final exitCompiled = compileSpec(exitParsed);
    final exitEvents = <RuntimeDiagnosticOutputEvent>[];
    try {
      executeGeneratedParserV2(
        exitCompiled,
        buildGeneratedRulePlan(exitCompiled),
        'x',
        identity,
        diagnosticOutputSink: exitEvents.add,
      );
      fail('generated exit returned normally');
    } on RuntimeExitNow catch (error) {
      expect(error.status, 23);
    }
    expect(
      _eventJson(exitEvents),
      (_scenario(contract, 'event_before_immediate_exit')['expected']!
          as Map)['events'],
    );
  });
}
