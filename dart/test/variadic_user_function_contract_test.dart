import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object?> _contract() {
  return (jsonDecode(
            File(
              '../capability_conformance/callable_signature_contract.json',
            ).readAsStringSync(),
          )
          as Map)
      .cast<String, Object?>();
}

String _fixtureSource() {
  final fixture = (_contract()['fixture']! as Map).cast<String, Object?>();
  return fixture['spec_source']! as String;
}

CompiledSpec _compileSource(String source) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  validateSpec(parsed);
  return compileSpec(parsed);
}

Object? _expectedFixtureValue() {
  final fixture = (_contract()['fixture']! as Map).cast<String, Object?>();
  return fixture['expected'];
}

void main() {
  test('definition shell emits exact v1 and v2 signature unions', () {
    final nodes = parseUserFunctionDefinitionAsts(_fixtureSource());
    expect(nodes, hasLength(3));

    final fixed = (nodes[0] as Map).cast<String, Object?>();
    expect(fixed['version'], 1);
    expect(fixed['params'], ['left', 'right']);
    expect(fixed['arity'], 2);
    expect(fixed, isNot(contains('signature')));

    for (final item in [
      (node: nodes[1], name: 'all_values', positional: <String>[], minimum: 0),
      (node: nodes[2], name: 'collect', positional: ['prefix'], minimum: 1),
    ]) {
      final node = (item.node as Map).cast<String, Object?>();
      final signature = (node['signature']! as Map).cast<String, Object?>();
      expect(node['version'], 2, reason: item.name);
      expect(node['name'], item.name);
      expect(node, isNot(contains('params')));
      expect(node, isNot(contains('arity')));
      expect(signature, {
        'kind': 'callable_signature',
        'version': 1,
        'positional_params': item.positional,
        'rest_param': 'items',
        'min_arity': item.minimum,
        'max_arity': null,
      });
      for (final staged in ['body_payload', 'body_parse_job']) {
        final record = (node[staged]! as Map).cast<String, Object?>();
        expect(record['signature'], signature);
        expect(record, isNot(contains('params')));
        expect(record, isNot(contains('arity')));
      }
    }
  });

  test('descriptor uses exact v2 keys and native fixture result', () {
    final compiled = _compileSource(_fixtureSource());
    final descriptor = compiled.descriptorState.toJson();
    final contract = _contract();
    final versions = (contract['definition_versions']! as Map)
        .cast<String, Object?>();
    final variadic = (versions['variadic']! as Map).cast<String, Object?>();
    final expectedKeys = (variadic['record_fields']! as List).cast<String>();

    final functions = (descriptor['functions']! as Map).cast<String, Object?>();
    for (final name in ['all_values', 'collect']) {
      final record = (functions[name]! as Map).cast<String, Object?>();
      expect(record.keys.toSet(), expectedKeys.toSet());
      expect(record['version'], 2);
      expect(record, isNot(contains('params')));
      expect(record, isNot(contains('arity')));
    }

    final result = LinkedSpecRuntimeEngine(compiled).parse('xx');
    expect(result.value, _expectedFixtureValue());
  });

  test('evaluates once left-to-right and allocates fresh rest arrays', () {
    final compiled = _compileSource(r'''fn gather(...items) { return(items) }
fn mutate_rest(...items) { items += "mutated"; return(items) }

Top::
 /x/ -> Done {
   order = "";
   first = gather(order = cat(order, "a"), order = cat(order, "b"), order);
   return({
     "first" : first,
     "fresh_one" : mutate_rest("a"),
     "fresh_two" : mutate_rest(),
     "order" : order
   })
 }

Done::
 /x/
''');
    expect(LinkedSpecRuntimeEngine(compiled).parse('xx').value, {
      'first': ['a', 'ab', 'ab'],
      'fresh_one': ['a', 'mutated'],
      'fresh_two': ['mutated'],
      'order': 'ab',
    });
  });

  test('fixed and variadic arity failures stay distinct', () {
    final fixed = _fixtureSource().replaceFirst(
      'pair("left", "right")',
      'pair("left", "right", "extra")',
    );
    expect(
      () => LinkedSpecRuntimeEngine(_compileSource(fixed)).parse('xx'),
      throwsA(
        isA<RuntimeInterpreterException>().having(
          (error) => error.message,
          'message',
          contains("user function 'pair' expects 2 argument(s), got 3"),
        ),
      ),
    );

    final variadic = _fixtureSource().replaceFirst('collect("p")', 'collect()');
    expect(
      () => LinkedSpecRuntimeEngine(_compileSource(variadic)).parse('xx'),
      throwsA(
        isA<RuntimeInterpreterException>().having(
          (error) => error.message,
          'message',
          contains(
            "user function 'collect' expects at least 1 argument(s), got 0",
          ),
        ),
      ),
    );
  });

  test('rejects malformed rest definitions and keyword calls', () {
    for (final params in [
      '...items, tail',
      '...left, ...right',
      '...',
      'items...',
      '... items',
    ]) {
      final source = 'fn bad($params) { return(undef) }\nTop::\n /x/\n';
      expect(
        () => parseSpecWithStagedUserFunctionDefinitions(source),
        throwsA(anything),
        reason: params,
      );
    }

    for (final params in ['item, ...item', '...return']) {
      final source = 'fn bad($params) { return(undef) }\nTop::\n /x/\n';
      expect(
        () => validateSpec(parseSpecWithStagedUserFunctionDefinitions(source)),
        throwsA(isA<SpecValidationException>()),
        reason: params,
      );
    }

    final compiled = _compileSource(_fixtureSource());
    final expression = ActionCallExpr(
      source: 'collect(prefix = "p")',
      sourceSpan: const ActionSourceSpan(start: 0, end: 21),
      name: 'collect',
      args: [
        ActionKeywordArgument(
          name: 'prefix',
          value: ActionStringLiteralExpr(
            source: '"p"',
            sourceSpan: const ActionSourceSpan(start: 17, end: 20),
            value: 'p',
            quote: '"',
          ),
        ),
      ],
    );
    final resolution = resolveActionExpressionContracts(
      expression,
      functionRegistry: compiled.functionRegistry,
    );
    expect(
      resolution.diagnostics.single.code,
      'user_function_keyword_arguments_unsupported',
    );
  });

  test('generated state preserves and executes variadic signatures', () {
    final compiled = _compileSource(_fixtureSource());
    final plan = buildGeneratedRulePlan(compiled);
    expect(
      executeGeneratedParserV2(compiled, plan, 'xx', 'variadic-contract.spec'),
      _expectedFixtureValue(),
    );

    final generated = emitDartSourceV2(compiled, 'variadic-contract.spec');
    final encoded = RegExp(
      "const _compiledSpecJsonBase64 = '([^']+)';",
    ).firstMatch(generated)![1]!;
    final normalized = (jsonDecode(utf8.decode(base64Decode(encoded))) as Map)
        .cast<String, Object?>();
    final functions = (normalized['functions']! as List).cast<Object?>();
    final allValues = (functions[1]! as Map).cast<String, Object?>();
    expect(allValues, isNot(contains('params')));
    expect(allValues, isNot(contains('arity')));
    expect((allValues['signature']! as Map)['rest_param'], 'items');

    final roundTrip = compileSpec(SpecFile.fromJson(normalized));
    expect(
      LinkedSpecRuntimeEngine(roundTrip).parse('xx').value,
      _expectedFixtureValue(),
    );
  });
}
