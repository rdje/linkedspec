import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'projects spec-defined function_definition nodes into a parsed spec',
    () {
      final source = [
        'fn zero() {return("zero")}',
        'Top::',
        ' /x/ -> Done { return(zero()) }',
        '',
        'Done:',
        ' /[a-z]+/',
        '',
        'fn after(value) { return(value) }',
        '',
      ].join('\n');

      final nodes = [
        _definitionNode(source, 'zero', const [], 'return("zero")'),
        _definitionNode(source, 'after', const ['value'], ' return(value) '),
      ];

      expect(
        () => parseSpecWithUserFunctionDefinitionAsts(source, const []),
        throwsA(isA<SpecParseException>()),
        reason: 'Dart must not raw-scan leading fn shells as a fallback',
      );

      final projection = projectUserFunctionDefinitionAsts(source, nodes);
      expect(projection.functions.map((function) => function.name), [
        'zero',
        'after',
      ]);
      expect(
        projection.strippedSource.split('\n').length,
        source.split('\n').length,
      );
      expect(projection.strippedSource, isNot(contains('fn zero')));
      expect(projection.strippedSource, contains('Top::'));

      final zero = projection.functions.first;
      expect(zero.params, isEmpty);
      expect(zero.arity, 0);
      expect(zero.bodySource, 'return("zero")');
      expect((zero.bodyPayload! as Map<String, Object?>)['parent_ast_path'], [
        'functions',
        '0',
        'body_source',
      ]);
      expect(zero.bodyParseJob!.parentAstPath, [
        'functions',
        '0',
        'body_source',
      ]);
      expect(
        zero.bodyParseJob!.jobId,
        'parse_job:function_body:functions.0.body_source:'
        'actionir-body.spec:action_block:11-25',
      );
      expect(zero.bodyParseJob!.version, 1);
      expect(zero.bodyParseJob!.functionName, 'zero');
      expect(zero.bodyParseJob!.params, isEmpty);
      expect(zero.bodyParseJob!.arity, 0);
      expect(zero.bodyParseJob!.diagnosticOwner, 'function_body');
      expect(zero.bodyAst, isNull);

      final parsed = parseSpecWithUserFunctionDefinitionAsts(source, nodes);
      validateSpec(parsed);
      expect(parsed.functions.length, 2);
      expect(parsed.rules.map((rule) => rule.header.label), ['Top', 'Done']);
    },
  );

  test('diagnoses malformed spec-returned nodes before rule parsing', () {
    final source = 'fn bad(value\nTop::\n /x/\n';
    final malformed = {
      'type': 'function_definition_error',
      'kind': 'user_function_definition_error',
      'message': 'invalid user function definition',
      'source_text': 'fn bad(value',
      'source_span': {'start': 0, 'end': 12, 'line_start': 1, 'line_end': 1},
    };

    expect(
      () => projectUserFunctionDefinitionAsts(source, [malformed]),
      throwsA(
        isA<SpecParseException>().having(
          (error) => error.message,
          'message',
          contains('user function definition parse error at line 1'),
        ),
      ),
    );
  });

  test('rejects AST nodes whose staged sidecars drift from the shell', () {
    const source = 'fn zero() {return("zero")}\nTop::\n /x/\n';
    final node = _definitionNode(source, 'zero', const [], 'return("zero")');
    (node['body_parse_job']! as Map<String, Object?>)['text'] =
        'return("drift")';

    expect(
      () => projectUserFunctionDefinitionAsts(source, [node]),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('body_parse_job text does not match body_source'),
        ),
      ),
    );
  });
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
      'parser_spec_id': 'actionir-body.spec',
      'top_rule': 'action_block',
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
