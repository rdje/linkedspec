import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  final parserSpecSource = File(
    '../$userFunctionDefinitionSpecRelativePath',
  ).readAsStringSync();
  final source = [
    'fn normalize(value) { return(trim(value)) }',
    'Top::',
    ' /x/ -> Done { return(normalize(" value ")) }',
    '',
    'Done:',
    ' /[a-z]+/',
  ].join('\n');

  test('propagates one emitter through function shell and staged jobs', () {
    final expected = parseSpecWithStagedUserFunctionDefinitions(
      source,
      parserSpecSource: parserSpecSource,
    );
    final output = StringBuffer();
    final trace = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
      stdoutWriter: output.write,
    );

    final actual = parseSpecWithStagedUserFunctionDefinitions(
      source,
      parserSpecSource: parserSpecSource,
      trace: trace,
    );

    expect(actual.toJson(), expected.toJson());
    expect(actual.functions.single.bodyAst, isNotNull);
    expect(
      trace.events.map((event) => event.topic),
      containsAll({
        'dart_frontend:parse_spec_with_functions',
        'dart_frontend:function_parser_spec',
        'dart_frontend:function_parser_execute',
        'dart_frontend:function_parser_execute:definitions',
        'dart_frontend:function_shell_spec',
        'dart_frontend:function_projection',
        'dart_frontend:function_projection:definition',
        'dart_staged:parse_spec_with_function_asts',
        'dart_staged:function_body_dispatch',
        'dart_staged:function_body_dispatch:job',
        'dart_staged:execute_jobs',
        'dart_staged:execute_jobs:queue',
        'dart_staged:job',
        'dart_staged:job:resolve',
        'dart_staged:job:load',
        'dart_staged:job:compile',
        'dart_staged:job:execute',
        'dart_staged:function_body_dispatch:stitch',
        'dart_runtime:parse',
      }),
    );
    _expectBalancedScopes(trace.events);
    expect(output.toString(), contains('dart_staged:job:execute'));
  });

  test('disabled function and staged tracing remains quiet and identical', () {
    final expected = parseSpecWithStagedUserFunctionDefinitions(
      source,
      parserSpecSource: parserSpecSource,
    );
    final output = StringBuffer();
    final trace = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.disabled(),
      stdoutWriter: output.write,
    );

    final actual = parseSpecWithStagedUserFunctionDefinitions(
      source,
      parserSpecSource: parserSpecSource,
      trace: trace,
    );

    expect(actual.toJson(), expected.toJson());
    expect(trace.events, isEmpty);
    expect(trace.lines, isEmpty);
    expect(output.toString(), isEmpty);
  });

  test('staged resolve failures close job and queue scopes unchanged', () {
    final badJob = StagedParseJob(
      jobId: 'parse_job:function_body:functions.0.body_source:missing',
      parentAstPath: const ['functions', '0', 'body_source'],
      nodeKind: 'function_definition',
      payloadKind: 'function_body',
      functionName: 'bad',
      params: const [],
      arity: 0,
      text: 'return("bad")',
      sourceSpan: const StagedSourceSpan(
        start: 10,
        end: 23,
        lineStart: 1,
        lineEnd: 1,
      ),
      parserSpecId: 'missing.spec',
      topRule: actionIrBodyTopRule,
      resultPolicy: 'replace_field',
      resultField: 'body_ast',
      failurePolicy: 'fail',
      diagnosticOwner: 'function_body',
    );
    final expectedError = _stagedError(badJob);
    final trace = _debugTrace();
    final actualError = _stagedError(badJob, trace: trace);

    expect(actualError.runtimeType, expectedError.runtimeType);
    expect(actualError.toString(), expectedError.toString());
    expect(trace.events.map((event) => '${event.kind.name}:${event.topic}'), [
      'enter:dart_staged:execute_jobs',
      'decision:dart_staged:execute_jobs:queue',
      'enter:dart_staged:job',
      'exit:dart_staged:job',
      'exit:dart_staged:execute_jobs',
    ]);
    expect(trace.events[3].details, contains('error='));
    expect(trace.events[4].details, contains('error='));
    _expectBalancedScopes(trace.events);
  });

  test('function projection failures retain their original diagnostic', () {
    const badSource = 'fn bad(value\nTop::\n /x/\n';
    final badNode = <String, Object?>{
      'type': 'function_definition_error',
      'kind': 'user_function_definition_error',
      'message': 'invalid user function definition',
      'source_text': 'fn bad(value',
      'source_span': <String, Object?>{
        'start': 0,
        'end': 12,
        'line_start': 1,
        'line_end': 1,
      },
    };
    final expectedError = _shellError(badSource, [badNode]);
    final trace = _debugTrace();
    final actualError = _shellError(badSource, [badNode], trace: trace);

    expect(actualError.runtimeType, expectedError.runtimeType);
    expect(actualError.toString(), expectedError.toString());
    expect(
      actualError.toString(),
      isNot(contains('rule parse after function extraction failed')),
    );
    _expectBalancedScopes(trace.events);
  });
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

LinkedSpecTraceEmitter _debugTrace() {
  return LinkedSpecTraceEmitter(
    LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
    stdoutWriter: (_) {},
  );
}

Object _stagedError(StagedParseJob job, {LinkedSpecTraceEmitter? trace}) {
  try {
    executeStagedParseJobs([job], trace: trace);
  } on Object catch (error) {
    return error;
  }
  throw StateError('expected staged execution to fail');
}

Object _shellError(
  String source,
  Iterable<Object?> nodes, {
  LinkedSpecTraceEmitter? trace,
}) {
  try {
    parseSpecWithUserFunctionDefinitionAsts(source, nodes, trace: trace);
  } on Object catch (error) {
    return error;
  }
  throw StateError('expected function shell projection to fail');
}
