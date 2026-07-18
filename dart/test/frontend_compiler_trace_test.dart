import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  const source = r'''
Top::
 /x/ -> Child

Child:
 /x/
 E { return(match_text()) }
''';

  test('propagates one emitter through parse validation and compile', () {
    final expectedSpec = parseSpec(source);
    final expectedCompiled = compileSpec(expectedSpec);
    final output = StringBuffer();
    final trace = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
      stdoutWriter: output.write,
    );

    final tracedSpec = parseSpec(source, trace: trace);
    final tracedCompiled = compileSpec(tracedSpec, trace: trace);

    expect(tracedSpec.toJson(), expectedSpec.toJson());
    expect(tracedCompiled.toJson(), expectedCompiled.toJson());
    expect(trace.events.map((event) => '${event.kind.name}:${event.topic}'), [
      'enter:dart_frontend:parse_spec',
      'decision:dart_frontend:parse_spec:rules',
      'exit:dart_frontend:parse_spec',
      'enter:dart_compiler:compile_spec',
      'enter:dart_frontend:validate_spec',
      'decision:dart_frontend:validate_spec:checks',
      'exit:dart_frontend:validate_spec',
      'enter:dart_compiler:function_registry',
      'exit:dart_compiler:function_registry',
      'decision:dart_compiler:compile_spec:rule',
      'decision:dart_compiler:compile_spec:rule',
      'decision:dart_compiler:compile_spec:dependency_regex',
      'exit:dart_compiler:compile_spec',
    ]);
    expect(output.toString(), contains('dart_frontend:parse_spec'));
    expect(output.toString(), contains('dart_frontend:validate_spec'));
    expect(output.toString(), contains('dart_compiler:compile_spec'));
    expect(output.toString(), contains('dart_compiler:function_registry'));
  });

  test('omitted and disabled tracing remain quiet and identical', () {
    final expected = compileSpec(parseSpec(source));
    final output = StringBuffer();
    final trace = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.disabled(),
      stdoutWriter: output.write,
    );

    final actual = compileSpec(parseSpec(source, trace: trace), trace: trace);

    expect(actual.toJson(), expected.toJson());
    expect(trace.events, isEmpty);
    expect(trace.lines, isEmpty);
    expect(output.toString(), isEmpty);
  });

  test('parse and validation failures close every emitted scope', () {
    final parseTrace = _debugTrace();
    expect(
      () => parseSpec('not a rule', trace: parseTrace),
      throwsA(isA<SpecParseException>()),
    );
    expect(parseTrace.events.map((event) => event.kind), [
      LinkedSpecTraceEventKind.enter,
      LinkedSpecTraceEventKind.exit,
    ]);
    expect(parseTrace.events.last.details, contains('error='));

    final invalidSpec = parseSpec('# no rules\n');
    final expectedError = _compileError(invalidSpec);
    final compileTrace = _debugTrace();
    final actualError = _compileError(invalidSpec, trace: compileTrace);

    expect(actualError.runtimeType, expectedError.runtimeType);
    expect(actualError.toString(), expectedError.toString());
    expect(
      compileTrace.events.map((event) => '${event.kind.name}:${event.topic}'),
      [
        'enter:dart_compiler:compile_spec',
        'enter:dart_frontend:validate_spec',
        'exit:dart_frontend:validate_spec',
        'exit:dart_compiler:compile_spec',
      ],
    );
    expect(compileTrace.events[2].details, contains('error='));
    expect(compileTrace.events[3].details, contains('error='));
  });
}

LinkedSpecTraceEmitter _debugTrace() {
  return LinkedSpecTraceEmitter(
    LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
    stdoutWriter: (_) {},
  );
}

Object _compileError(SpecFile spec, {LinkedSpecTraceEmitter? trace}) {
  try {
    compileSpec(spec, trace: trace);
  } on Object catch (error) {
    return error;
  }
  throw StateError('expected compileSpec to fail');
}
