import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('dispatches staged function-body jobs in stable queue order', () {
    final later = _job(
      index: 1,
      name: 'later',
      bodySource: 'return("b")',
      start: 40,
      end: 51,
      line: 3,
    );
    final earlier = _job(
      index: 0,
      name: 'earlier',
      bodySource: 'return("a")',
      start: 10,
      end: 21,
      line: 1,
    );

    final results = executeStagedParseJobs([later, earlier]);

    expect(results.map((result) => result.jobId), [
      'parse_job:function_body:functions.0.body_source:'
          'actionir-body.spec:action_block:10-21',
      'parse_job:function_body:functions.1.body_source:'
          'actionir-body.spec:action_block:40-51',
    ]);
    expect(results.map((result) => result.queueIndex), [0, 1]);

    final encoded = results.first.toJson();
    expect(encoded['kind'], 'staged_parse_result');
    expect(encoded['phases'], ['resolve', 'load', 'compile', 'execute']);
    expect(encoded['resolved_spec_id'], actionIrBodyResolvedSpecId);
    expect(encoded['registry_provider'], 'builtin');
    expect(
      (encoded['compiled_parser']! as Map<String, Object?>)['top_rule'],
      'action_block',
    );

    final cacheKey = encoded['cache_key']! as Map<String, Object?>;
    expect(cacheKey['kind'], 'staged_parser_cache_key');
    expect(cacheKey['normalized_spec_identity'], actionIrBodyResolvedSpecId);
    expect(cacheKey['content_digest'], actionIrBodyAdapterDigest);
    expect(
      cacheKey['fingerprint'],
      [
        actionIrBodyResolvedSpecId,
        actionIrBodyAdapterDigest,
        'none',
        actionIrBodyTopRule,
        'spec-language-v1',
        'actionir-v1',
        'staged-parsing-v1',
        'actionir_ast_v1',
      ].join('|'),
    );

    final result = encoded['result']! as Map<String, Object?>;
    expect(result['kind'], 'action_block');
    final statements = result['statements']! as List<Object?>;
    final statement = statements.single! as Map<String, Object?>;
    expect(statement['kind'], 'action_stmt');
    expect((statement['expr']! as Map<String, Object?>)['name'], 'return');
  });

  test('stitches dispatched body_ast back into function definitions', () {
    final spec = SpecFile(
      functions: [
        _function(
          index: 0,
          name: 'zero',
          params: const [],
          bodySource: 'return("zero")',
          start: 11,
          end: 25,
          line: 1,
        ),
        _function(
          index: 1,
          name: 'after',
          params: const ['value'],
          bodySource: 'return(value)',
          start: 56,
          end: 69,
          line: 4,
        ),
      ],
      rules: const [],
    );

    final dispatch = dispatchFunctionBodyParseJobs(spec);

    expect(dispatch.results.map((result) => result.queueIndex), [0, 1]);
    expect(dispatch.spec.functions.map((function) => function.name), [
      'zero',
      'after',
    ]);
    final zeroAst =
        dispatch.spec.functions.first.bodyAst! as Map<String, Object?>;
    expect(zeroAst['kind'], 'action_block');
    expect(
      (((zeroAst['statements']! as List<Object?>).single!
              as Map<String, Object?>)['expr']!
          as Map<String, Object?>)['name'],
      'return',
    );
    expect(dispatch.spec.functions.first.bodyParseJob!.resultField, 'body_ast');
    expect(spec.functions.first.bodyAst, isNull);
  });

  test('parses spec with staged user-function body dispatch', () {
    final source = [
      'fn zero() {return("zero")}',
      'Top::',
      ' /x/ -> Done { return(zero()) }',
      '',
      'Done:',
      ' /[a-z]+/',
    ].join('\n');
    final nodes = [_definitionNode(source, 'zero', const [], 'return("zero")')];

    final spec = parseSpecWithStagedUserFunctionDefinitionAsts(source, nodes);

    expect(spec.functions, hasLength(1));
    expect(spec.functions.single.bodyParseJob!.parentAstPath, [
      'functions',
      '0',
      'body_source',
    ]);
    final bodyAst = spec.functions.single.bodyAst! as Map<String, Object?>;
    expect(bodyAst['kind'], 'action_block');
    expect(spec.rules.map((rule) => rule.header.label), ['Top', 'Done']);
  });

  test('diagnoses unsupported parser specs with staged dispatch context', () {
    final bad = _job(
      index: 0,
      name: 'bad',
      bodySource: 'return("a")',
      start: 10,
      end: 21,
      line: 1,
      parserSpecId: 'missing.spec',
    );

    expect(
      () => executeStagedParseJobs([bad]),
      throwsA(
        isA<StagedParserRegistryException>()
            .having(
              (error) => error.message,
              'message',
              contains('phase=resolve'),
            )
            .having(
              (error) => error.message,
              'message',
              contains('parser_spec_id=missing.spec'),
            )
            .having(
              (error) => error.message,
              'message',
              contains('source_span=10-21'),
            )
            .having(
              (error) => error.message,
              'message',
              contains('failure_policy=fail'),
            ),
      ),
    );
  });

  test('diagnoses function-body stitching contract drift', () {
    final function = _function(
      index: 0,
      name: 'zero',
      params: const [],
      bodySource: 'return("zero")',
      start: 11,
      end: 25,
      line: 1,
      resultField: 'wrong_field',
    );

    expect(
      () => dispatchFunctionBodyParseJobs(
        SpecFile(functions: [function], rules: const []),
      ),
      throwsA(
        isA<StagedParserRegistryException>().having(
          (error) => error.message,
          'message',
          contains('result_field must be'),
        ),
      ),
    );
  });
}

FunctionDefinition _function({
  required int index,
  required String name,
  required List<String> params,
  required String bodySource,
  required int start,
  required int end,
  required int line,
  String parserSpecId = actionIrBodySpecId,
  String resultField = 'body_ast',
}) {
  return FunctionDefinition(
    name: name,
    params: params,
    arity: params.length,
    bodySource: bodySource,
    bodyPayload: {
      'kind': 'staged_payload',
      'version': 1,
      'node_kind': 'function_definition',
      'payload_kind': 'function_body',
      'parent_ast_path': ['functions', '$index', 'body_source'],
      'function_name': name,
      'params': params,
      'arity': params.length,
      'text': bodySource,
      'source_span': {
        'start': start,
        'end': end,
        'line_start': line,
        'line_end': line,
      },
    },
    bodyParseJob: _job(
      index: index,
      name: name,
      params: params,
      bodySource: bodySource,
      start: start,
      end: end,
      line: line,
      parserSpecId: parserSpecId,
      resultField: resultField,
    ),
    source: 'fn $name(${params.join(", ")}) { $bodySource }',
    sourceSpan: SourceSpan(lineStart: line, lineEnd: line),
    bodySpan: SourceSpan(lineStart: line, lineEnd: line),
  );
}

StagedParseJob _job({
  required int index,
  required String name,
  List<String> params = const [],
  required String bodySource,
  required int start,
  required int end,
  required int line,
  String parserSpecId = actionIrBodySpecId,
  String resultField = 'body_ast',
}) {
  return StagedParseJob(
    version: 1,
    jobId:
        'parse_job:function_body:functions.$index.body_source:'
        '$parserSpecId:action_block:$start-$end',
    parentAstPath: ['functions', '$index', 'body_source'],
    nodeKind: 'function_definition',
    payloadKind: 'function_body',
    functionName: name,
    params: params,
    arity: params.length,
    text: bodySource,
    sourceSpan: StagedSourceSpan(
      start: start,
      end: end,
      lineStart: line,
      lineEnd: line,
    ),
    parserSpecId: parserSpecId,
    topRule: actionIrBodyTopRule,
    resultPolicy: 'replace_field',
    resultField: resultField,
    failurePolicy: 'fail',
    diagnosticOwner: 'function_body',
  );
}

Map<String, Object?> _definitionNode(
  String source,
  String name,
  List<String> params,
  String bodySource,
) {
  final sourceStart = source.indexOf('fn $name');
  if (sourceStart < 0) {
    throw StateError('missing function $name');
  }
  final bodyStart = source.indexOf(bodySource, sourceStart);
  if (bodyStart < 0) {
    throw StateError('missing body for $name');
  }
  final bodyEnd = bodyStart + bodySource.length;
  final sourceEnd = source.indexOf('}', bodyEnd) + 1;
  final sourceText = source.substring(sourceStart, sourceEnd);
  final sourceSpan = _span(source, sourceStart, sourceEnd);
  final bodySpan = _span(source, bodyStart, bodyEnd);

  return {
    'type': 'function_definition',
    'kind': 'user_function_definition',
    'version': 1,
    'name': name,
    'params': params,
    'arity': params.length,
    'source_text': sourceText,
    'source_span': sourceSpan,
    'body_source': bodySource,
    'body_span': bodySpan,
    'body_payload': {
      'kind': 'staged_payload',
      'version': 1,
      'node_kind': 'function_definition',
      'payload_kind': 'function_body',
      'parent_ast_path': [
        'functions',
        '__pending_source_order__',
        'body_source',
      ],
      'function_name': name,
      'params': params,
      'arity': params.length,
      'text': bodySource,
      'source_span': bodySpan,
      'provenance': [
        {'kind': 'source_slice', 'source_span': bodySpan},
      ],
    },
    'body_parse_job': {
      'kind': 'parse_job',
      'version': 1,
      'job_id': 'parse_job:function_body:$name:actionir-body.spec:action_block',
      'parent_ast_path': [
        'functions',
        '__pending_source_order__',
        'body_source',
      ],
      'node_kind': 'function_definition',
      'payload_kind': 'function_body',
      'function_name': name,
      'params': params,
      'arity': params.length,
      'text': bodySource,
      'source_span': bodySpan,
      'parser_spec_id': actionIrBodySpecId,
      'top_rule': actionIrBodyTopRule,
      'result_policy': 'replace_field',
      'result_field': 'body_ast',
      'failure_policy': 'fail',
      'diagnostic_owner': 'function_body',
    },
  };
}

Map<String, Object?> _span(String source, int start, int end) {
  return {
    'start': start,
    'end': end,
    'line_start': _lineAt(source, start),
    'line_end': _lineAt(source, end),
  };
}

int _lineAt(String source, int offset) {
  var line = 1;
  for (var index = 0; index < offset && index < source.length; index += 1) {
    if (source.codeUnitAt(index) == 10) {
      line += 1;
    }
  }
  return line;
}
