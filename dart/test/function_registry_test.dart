import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('builds ordered registry entries and staged body parse jobs', () {
    final registry = UserFunctionRegistry.fromFunctions([
      _function(
        name: 'zero',
        params: const [],
        bodySource: 'return("zero")',
        bodyAst: const {'kind': 'action_block', 'statements': <Object?>[]},
      ),
      _function(
        name: 'normalize',
        params: const ['value'],
        bodySource: 'return(value.trim())',
      ),
    ]);

    expect(registry.names, ['zero', 'normalize']);
    expect(registry.bodyParseJobs.map((job) => job.jobId), [
      'parse_job:function_body:functions.0.body_source',
      'parse_job:function_body:functions.1.body_source',
    ]);

    final zero = registry.resolveCall('zero', 0);
    expect(zero.matched, isTrue);
    expect(zero.entry!.index, 0);
    expect(zero.entry!.params, isEmpty);
    expect(zero.entry!.bodyAst, isNotNull);
    expect(zero.entry!.bodyParseJob!.parentAstPath, [
      'functions',
      '0',
      'body_source',
    ]);

    final mismatch = registry.resolveCall('normalize', 2);
    expect(mismatch.nameKnown, isTrue);
    expect(mismatch.arityMismatch, isTrue);
    expect(mismatch.expectedArities, [1]);

    final missing = registry.resolveCall('missing', 0);
    expect(missing.nameKnown, isFalse);

    final encoded = registry.toJson();
    expect(encoded['functions'], isA<List<Object?>>());
    expect(encoded['body_parse_jobs'], isA<List<Object?>>());
  });

  test('rejects duplicate function names before compiled-state work', () {
    expect(
      () => UserFunctionRegistry.fromFunctions([
        _function(name: 'normalize', params: const ['value']),
        _function(name: 'normalize', params: const ['other']),
      ]),
      throwsA(isA<UserFunctionRegistryException>()),
    );
  });
}

FunctionDefinition _function({
  required String name,
  required List<String> params,
  String bodySource = 'return(value)',
  Object? bodyAst,
}) {
  final index = name == 'zero' ? 0 : 1;
  return FunctionDefinition(
    name: name,
    params: params,
    arity: params.length,
    bodySource: bodySource,
    bodyPayload: {
      'kind': 'staged_payload',
      'node_kind': 'function_definition',
      'payload_kind': 'function_body',
      'parent_ast_path': ['functions', '$index', 'body_source'],
      'function_name': name,
      'params': params,
      'arity': params.length,
      'text': bodySource,
    },
    bodyParseJob: StagedParseJob(
      version: 1,
      jobId: 'parse_job:function_body:functions.$index.body_source',
      parentAstPath: ['functions', '$index', 'body_source'],
      nodeKind: 'function_definition',
      payloadKind: 'function_body',
      functionName: name,
      params: params,
      arity: params.length,
      text: bodySource,
      sourceSpan: const StagedSourceSpan(
        start: 0,
        end: 1,
        lineStart: 1,
        lineEnd: 1,
      ),
      parserSpecId: 'actionir-body.spec',
      topRule: 'action_block',
      resultPolicy: 'replace_field',
      resultField: 'body_ast',
      failurePolicy: 'fail',
      diagnosticOwner: 'function_body',
    ),
    bodyAst: bodyAst,
    source: 'fn $name(${params.join(", ")}) { $bodySource }',
    sourceSpan: const SourceSpan(lineStart: 1, lineEnd: 1),
    bodySpan: const SourceSpan(lineStart: 1, lineEnd: 1),
  );
}
