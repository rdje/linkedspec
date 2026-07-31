// FUTURE-PARITY-BACKLOG.11.5.1-.2 — Dart callable-codeblock state/invocation.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/semantic/semantic_index.dart';
import 'package:test/test.dart';

Map<String, Object?> _contract() {
  return (jsonDecode(
            File(
              '../capability_conformance/callable_codeblock_contract.json',
            ).readAsStringSync(),
          )
          as Map)
      .cast<String, Object?>();
}

Map<String, Object?> _descriptorContract() {
  return (jsonDecode(
            File(
              '../capability_conformance/outward_descriptor_contract.json',
            ).readAsStringSync(),
          )
          as Map)
      .cast<String, Object?>();
}

CompiledSpec _compileSource(String source) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  validateSpec(parsed);
  return compileSpec(parsed);
}

ActionExpr _assignmentValue(String source) {
  final block = parseActionBlock('value = $source');
  final assignment = block.statements.single.expr as ActionAssignScalarExpr;
  return assignment.value;
}

Map<String, Object?> _record(Object? value) =>
    (value! as Map).cast<String, Object?>();

String _constructionSource(String literal) =>
    '''Top::
 /x/ -> Done {
   state = "before";
   cb = $literal;
   alias = copy(cb);
   return({ "state" : state, "cb" : alias })
 }

Done::
 /x/
''';

String _invalidCallBody(String id) => switch (id) {
  'fixed_missing' =>
    r'''cb = {|left, right| return(cat(left, right)) }; return(cb("a"))''',
  'fixed_extra' =>
    r'''cb = {|left, right| return(cat(left, right)) }; return(cb("a", "b", "c"))''',
  'rest_missing_fixed' =>
    r'''cb = {|prefix, ...items| return(items) }; return(cb())''',
  'keyword_argument' =>
    r'''cb = {|value| return(value) }; return(cb(value: "x"))''',
  'bound_non_codeblock' => r'''text = "not callable"; return(text())''',
  'unknown_call' => r'''cb = {|| return(missing()) }; return(cb())''',
  'direct_recursion' =>
    r'''reader = {|| return(reader()) }; return(reader())''',
  _ => throw StateError('unowned invalid callable-codeblock case $id'),
};

String _invalidCallSource(String id) =>
    '''Top::
 /x/
 E { ${_invalidCallBody(id)} }
''';

String _finalCodeblockEquivalenceSource() =>
    r'''fn apply(value, callback: codeblock) { return(callback()) }
fn invoke(value, callback: codeblock) { return(callback(value)) }

Top::
 /x/
 E {
   return([
     with("x") { return(cat(value, "!")) },
     with("x", { return(cat(value, "!")) }),
     with("x", {|item| return(cat(item, "!")) }),
     "x".with() { return(cat(value, "!")) },
     "x".with({ return(cat(value, "!")) }),
     "x".with({|item| return(cat(item, "!")) }),
     apply("a") { return(cat(value, "!")) },
     apply("b", { return(cat(value, "?")) }),
     invoke("c", {|item| return(cat(item, ".")) }),
     { "b" : 2, "a" : 1 }.map_leaves() { return(cat(value, "!")) },
     { "b" : 2, "a" : 1 }.map_leaves({ return(cat(value, "!")) })
   ])
 }
''';

Object? _finalArgumentJson(ActionExpr expression) {
  final encoded = expression.toJson();
  if (expression is ActionCallExpr) {
    return (encoded['args']! as List).last;
  }
  if (expression is ActionFluentChainExpr) {
    final calls = encoded['calls']! as List;
    return (_record(calls.single)['args']! as List).last;
  }
  throw StateError('expression ${expression.kind} has no callable argument');
}

List<Object?> _finalCodeblockExpected() => [
  'x!',
  'x!',
  'x!',
  'x!',
  'x!',
  'x!',
  'a!',
  'b?',
  'c.',
  {'a': '1!', 'b': '2!'},
  {'a': '1!', 'b': '2!'},
];

RuntimeInterpreterException _runtimeFailure(CompiledSpec compiled) {
  try {
    LinkedSpecRuntimeEngine(compiled).parse('x');
  } on RuntimeInterpreterException catch (error) {
    return error;
  }
  throw StateError('callable-codeblock execution unexpectedly succeeded');
}

CompiledSpec _reconstructFromEmittedPayload(
  CompiledSpec compiled,
  String identity,
) {
  final emitted = emitDartSourceV2(compiled, identity);
  final encoded = RegExp(
    "const _compiledSpecJsonBase64 = '([^']+)';",
  ).firstMatch(emitted)![1]!;
  final normalized = (jsonDecode(utf8.decode(base64Decode(encoded))) as Map)
      .cast<String, Object?>();
  return compileSpec(SpecFile.fromJson(normalized));
}

ProcessResult _expectDartSuccess(
  Directory workingDirectory,
  Map<String, String> environment,
  List<String> arguments,
) {
  final result = Process.runSync(
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

void main() {
  test('all neutral brace classes and literal records are exact', () {
    final contract = _contract();
    for (final rawCase in contract['brace_classification']! as List) {
      final item = _record(rawCase);
      final expression = _assignmentValue(item['source']! as String);
      final actual = switch (expression) {
        ActionHashLiteralExpr() => 'harray_literal',
        ActionBlockValueExpr() => 'block_value',
        ActionCodeblockLiteralExpr() => 'codeblock_literal',
        _ => expression.kind,
      };
      expect(actual, item['expected_kind'], reason: item['id']! as String);
    }

    final schema = _record(contract['ast_schema']);
    final expectedFields = (schema['fields']! as List).cast<String>().toSet();
    for (final rawLiteral in contract['literals']! as List) {
      final row = _record(rawLiteral);
      final source = row['source']! as String;
      const prefix = 'value = ';
      final literal = _assignmentValue(source) as ActionCodeblockLiteralExpr;
      final record = literal.toJson();
      expect(record.keys.toSet(), expectedFields, reason: row['id'] as String);
      expect(literal.version, 1);
      expect(literal.source, source);
      expect(literal.bodySource, row['body_source']);
      expect(literal.bodyAst.kind, 'action_block');
      expect(literal.bodyAst.source, row['body_source']);
      expect(literal.bodyAst.statements, isNotEmpty);
      expect(literal.sourceSpan.start, prefix.runes.length);
      expect(literal.sourceSpan.end, (prefix + source).runes.length);

      final bodyStart = source.indexOf('|', 2) + 1;
      expect(
        literal.bodySpan.start,
        (prefix + source.substring(0, bodyStart)).runes.length,
      );
      expect(
        literal.bodySpan.end,
        (prefix + source.substring(0, source.length - 1)).runes.length,
      );

      final signature = literal.signature;
      final signatureSource = row['signature_source']! as String;
      final parts = signatureSource.isEmpty
          ? const <String>[]
          : signatureSource.split(',').map((part) => part.trim()).toList();
      final rest = parts.where((part) => part.startsWith('...')).toList();
      final positional = parts
          .where((part) => !part.startsWith('...'))
          .toList();
      expect(signature.kind, 'callable_signature');
      expect(signature.version, 1);
      expect(signature.positionalParams, positional);
      expect(
        signature.restParam,
        rest.isEmpty ? null : rest.single.substring(3),
      );
      expect(signature.minArity, positional.length);
      expect(signature.maxArity, rest.isEmpty ? positional.length : null);
    }

    const nestedSource =
        r'{|value| return({ "marker" : "|}", "nested" : { "value" : value } }) }';
    final nested = parseActionExpression(nestedSource);
    expect(nested, isA<ActionCodeblockLiteralExpr>());
    expect((nested as ActionCodeblockLiteralExpr).source, nestedSource);
    expect(nested.bodyAst.statements.single.expr, isA<ActionCallExpr>());
  });

  test('literal spans stay in containing Unicode-character coordinates', () {
    const source = 'note = "😀"; cb = {|value| return(value) }';
    final block = parseActionBlock(source);
    final assignment = block.statements[1].expr as ActionAssignScalarExpr;
    final literal = assignment.value as ActionCodeblockLiteralExpr;
    final start = source.indexOf('{|');
    expect(literal.sourceSpan.start, source.substring(0, start).runes.length);
    expect(literal.sourceSpan.end, source.runes.length);

    const nestedSource =
        'prefix = "😀"; cb = {|| nested = {|value| return(value) } }';
    final nestedBlock = parseActionBlock(nestedSource);
    final outerAssignment =
        nestedBlock.statements[1].expr as ActionAssignScalarExpr;
    final outer = outerAssignment.value as ActionCodeblockLiteralExpr;
    final innerAssignment =
        outer.bodyAst.statements.single.expr as ActionAssignScalarExpr;
    final inner = innerAssignment.value as ActionCodeblockLiteralExpr;
    final innerStart = nestedSource.lastIndexOf('{|');
    expect(
      inner.sourceSpan.start,
      nestedSource.substring(0, innerStart).runes.length,
    );
    expect(inner.sourceSpan.end, nestedSource.runes.length - 2);
  });

  test('all malformed literals retain their neutral diagnostic codes', () {
    for (final rawCase in _contract()['invalid_literal_cases']! as List) {
      final item = _record(rawCase);
      final expression = parseActionExpression(item['source']! as String);
      expect(
        expression,
        isA<ActionCodeblockLiteralErrorExpr>(),
        reason: item['id']! as String,
      );
      final error = expression as ActionCodeblockLiteralErrorExpr;
      expect(error.code, item['expected_code'], reason: item['id'] as String);
      final resolution = resolveActionExpressionContracts(error);
      expect(resolution.diagnostics.single.code, item['expected_code']);
    }
  });

  test(
    'construction, copies, compiled JSON, plans, and emission stay inert',
    () {
      final literalRow = (_contract()['literals']! as List)
          .map(_record)
          .singleWhere((row) => row['id'] == 'mutate_dynamic');
      final source = _constructionSource(literalRow['source']! as String);
      final compiled = _compileSource(source);
      final direct = LinkedSpecRuntimeEngine(compiled).parse('xx').value;
      final result = _record(direct);
      final codeblock = _record(result['cb']);
      expect(result['state'], 'before');
      expect(codeblock['kind'], 'codeblock_literal');
      expect(codeblock['version'], 1);
      expect(codeblock['source_text'], literalRow['source']);
      expect(codeblock['body_source'], literalRow['body_source']);
      expect(_record(codeblock['body_ast'])['kind'], 'action_block');
      expect(_record(codeblock['signature'])['positional_params'], ['value']);

      final compiledJson = compiled.toJson();
      expect(jsonDecode(jsonEncode(compiledJson)), compiledJson);
      expect(jsonEncode(compiledJson), contains('codeblock_literal'));
      expect(
        executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          'xx',
          'callable-codeblock-construction.spec',
        ),
        direct,
      );

      final generated = emitDartSourceV2(
        compiled,
        'callable-codeblock-construction.spec',
      );
      final encoded = RegExp(
        "const _compiledSpecJsonBase64 = '([^']+)';",
      ).firstMatch(generated)![1]!;
      final normalized =
          jsonDecode(utf8.decode(base64Decode(encoded)))
              as Map<String, Object?>;
      expect(jsonEncode(normalized), contains('{|value|'));
      final reconstructed = compileSpec(SpecFile.fromJson(normalized));
      expect(LinkedSpecRuntimeEngine(reconstructed).parse('xx').value, direct);
    },
  );

  test('user functions transport literal arguments and results inertly', () {
    final compiled = _compileSource(r'''fn identity(value) { return(value) }
fn make() { return({|| return("never") }) }

Top::
 /x/ -> Done {
   state = "before";
   from_arg = identity({|value| state = "wrong"; return(value) });
   from_result = make();
   return({
     "state" : state,
     "from_arg" : from_arg,
     "from_result" : from_result
   })
 }

Done::
 /x/
''');
    final result = _record(LinkedSpecRuntimeEngine(compiled).parse('xx').value);
    expect(result['state'], 'before');
    expect(_record(result['from_arg'])['kind'], 'codeblock_literal');
    expect(_record(result['from_result'])['kind'], 'codeblock_literal');
    expect(
      _record(_record(result['from_arg'])['signature'])['positional_params'],
      ['value'],
    );
    expect(
      _record(_record(result['from_result'])['signature'])['max_arity'],
      0,
    );
  });

  test(
    'nullable literal signatures do not weaken user-function validation',
    () {
      final parsed = parseSpecWithStagedUserFunctionDefinitions(
        r'''fn gather(...items) { return(items) }

Top::
 /x/
''',
      );
      final json =
          jsonDecode(jsonEncode(parsed.toJson())) as Map<String, Object?>;
      final functions = (json['functions']! as List<Object?>);
      final function = _record(functions.single);
      final signature = _record(function['signature']);
      signature['rest_param'] = null;

      expect(
        () => validateSpec(SpecFile.fromJson(json)),
        throwsA(
          isA<SpecValidationException>().having(
            (error) => error.message,
            'message',
            contains('invalid variadic callable signature'),
          ),
        ),
      );
    },
  );

  test('retained bodies are excluded from eager dependency resolution', () {
    final literal = parseActionExpression(
      r'{|| state = "wrong"; missing(); call(Done); return(retv) }',
    );
    expect(literal, isA<ActionCodeblockLiteralExpr>());
    expect(resolveActionExpressionContracts(literal).diagnostics, isEmpty);

    final compiled = _compileSource(r'''Top::
 /x/ -> Done {
   state = "before";
   cb = {|| state = "wrong"; missing(); call(Done); return(retv) };
   return({ "state" : state, "cb" : cb })
 }

Done::
 /x/
''');
    final result = _record(LinkedSpecRuntimeEngine(compiled).parse('xx').value);
    expect(result['state'], 'before');
    expect(_record(result['cb'])['kind'], 'codeblock_literal');

    final dynamicCall = resolveActionExpressionContracts(
      parseActionExpression('cb()'),
    );
    expect(dynamicCall.diagnostics.single.code, 'unknown_helper');
  });

  test('semantic bindings expose the exact callable signature', () {
    const source = '''fn identity(value) { return(value) }

Top::
 /x/ -> Done {
   cb = {|left, ...items| return(items) };
   return(cb)
 }

Done::
 /x/
''';
    final index = SemanticIndex.fromSource(
      source,
      options: const SemanticIndexOptions(
        logicalName: 'callable-codeblock-semantic.spec',
        sourceDetailCeiling: SemanticSourceDetail.none,
      ),
    );
    final projection = index.semanticStaticProjectionForTesting();
    final bindings = (projection['records']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .where(
          (record) => record['kind'] == 'binding' && record['name'] == 'cb',
        )
        .toList();
    expect(bindings, isNotEmpty, reason: 'missing cb semantic binding');
    final binding = bindings.single;
    final facts = _record(binding['facts']);
    expect(facts['value_shape'], {
      'kind': 'codeblock',
      'element': null,
      'key': null,
      'value': null,
      'signature': {
        'parameters': [
          {'name': 'left', 'kind': 'value', 'required': true},
        ],
        'arity_min': 1,
        'arity_max': null,
        'rest_parameter': 'items',
        'final_codeblock': false,
      },
      'members': <Object?>[],
    });
  });

  test('call-result access and colon keywords retain typed ActionIR', () {
    final chain =
        parseActionExpression(r'''collector("p", "a", "b")["items"].length()''')
            as ActionFluentChainExpr;
    expect(chain.receiver, isA<ActionValueAccessExpr>());
    final access = chain.receiver as ActionValueAccessExpr;
    expect(access.receiver, isA<ActionCallExpr>());
    expect((access.receiver as ActionCallExpr).name, 'collector');
    expect(access.segments, hasLength(1));
    expect(access.segments.single, isA<ActionKeyAccessSegment>());
    expect(access.toJson()['kind'], 'value_access');

    final keyword =
        parseActionExpression(r'''cb(value: "x")''') as ActionCallExpr;
    expect(keyword.args.single, isA<ActionKeywordArgument>());
    expect((keyword.args.single as ActionKeywordArgument).name, 'value');

    final assignment =
        parseActionExpression(r'''cb(value = "x")''') as ActionCallExpr;
    expect(assignment.args.single, isA<ActionPositionalArgument>());
    expect(assignment.args.single.value, isA<ActionAssignScalarExpr>());
  });

  test(
    'the exact neutral fixture executes through every in-memory authority',
    () {
      final contract = _contract();
      final fixture = _record(contract['fixture']);
      final expected = _record(fixture['expected']);
      final compiled = _compileSource(fixture['spec_source']! as String);

      expect(
        (contract['call_cases']! as List)
            .map(_record)
            .map((row) => row['id'])
            .toSet(),
        {
          'construction_is_deferred',
          'fixed_exact',
          'dynamic_read_uses_call_time_state',
          'nonparameter_mutation_persists',
          'parameter_binding_restores',
          'rest_empty',
          'rest_mixed',
          'rest_result_receiver_chain',
          'block_local_return',
          'standalone_discard_keeps_effects',
          'static_name_precedence',
        },
      );
      expect(
        LinkedSpecRuntimeEngine(
          compiled,
        ).parse(fixture['input']! as String).value,
        expected,
      );

      expect(jsonDecode(jsonEncode(compiled.toJson())), compiled.toJson());
      final reconstructed = _reconstructFromEmittedPayload(
        compiled,
        'callable-codeblock-fixture.spec',
      );
      expect(
        LinkedSpecRuntimeEngine(
          reconstructed,
        ).parse(fixture['input']! as String).value,
        expected,
      );
      expect(
        executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          fixture['input']! as String,
          'callable-codeblock-fixture.spec',
        ),
        expected,
      );

      expect(
        LinkedSpecRuntimeEngine(
          _reconstructFromEmittedPayload(
            compiled,
            'callable-codeblock-fixture.spec',
          ),
        ).parse(fixture['input']! as String).value,
        expected,
      );
    },
  );

  test(
    'remaining valid calls preserve precedence, order, copies, and effects',
    () {
      final compiled = _compileSource(r'''fn choose() { return("static") }

Top::
 /x/
 E {
   state = "";
   append_state = {|value| state = cat(state, value); return(state) };
   append_state("x");
   cat = {|left, right| return("shadow") };
   choose = {|| return("shadow") };
   order = "";
   tick = {|value| order = cat(order, value); return(value) };
   joiner = {|left, right| return(cat(left, right)) };
   original = { "nested" : [{ "value" : "outer" }] };
   mutate_copy = {|copy| copy["nested"][0]["value"] = "inner"; return(copy) };
   mutated = mutate_copy(original);
   return({
     "discard_state" : state,
     "helper_precedence" : cat("a", "b"),
     "function_precedence" : choose(),
     "ordered_result" : joiner(tick("a"), tick("b")),
     "ordered_effect" : order,
     "original" : original,
     "mutated" : mutated
   })
 }
''');
      expect(LinkedSpecRuntimeEngine(compiled).parse('x').value, {
        'discard_state': 'x',
        'helper_precedence': 'ab',
        'function_precedence': 'static',
        'ordered_result': 'ab',
        'ordered_effect': 'ab',
        'original': {
          'nested': [
            {'value': 'outer'},
          ],
        },
        'mutated': {
          'nested': [
            {'value': 'inner'},
          ],
        },
      });
    },
  );

  test('all seven neutral call failures are typed across authorities', () {
    for (final rawCase in _contract()['invalid_call_cases']! as List) {
      final row = _record(rawCase);
      final id = row['id']! as String;
      final expected = _record(row['expected_error']);
      final compiled = _compileSource(_invalidCallSource(id));

      final direct = _runtimeFailure(compiled);
      final diagnostic = direct.diagnostic!.toJson();
      for (final entry in expected.entries) {
        expect(diagnostic[entry.key], entry.value, reason: '$id ${entry.key}');
      }

      final reconstructed = _runtimeFailure(
        _reconstructFromEmittedPayload(compiled, 'callable-codeblock-$id.spec'),
      );
      expect(reconstructed.diagnostic!.toJson(), diagnostic, reason: id);

      expect(
        () => executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          'x',
          'callable-codeblock-$id.spec',
        ),
        throwsA(
          isA<GeneratedSourceException>().having(
            (error) => error.detail,
            'detail',
            contains(expected['code']),
          ),
        ),
        reason: id,
      );
    }
  });

  test('mutual recursion reports the exact ordered callable cycle', () {
    final error = _runtimeFailure(
      _compileSource(r'''Top::
 /x/
 E {
   left = {|| return(right()) };
   right = {|| return(left()) };
   return(left())
 }
'''),
    );
    expect(error.diagnostic!.code, 'codeblock_recursion_unsupported');
    expect(error.diagnostic!.callableName, 'left');
    expect(error.diagnostic!.cycle, ['left', 'right', 'left']);
  });

  test('colon keywords cannot bypass registered user-function policy', () {
    final error = _runtimeFailure(
      _compileSource(r'''fn identity(value) { return(value) }

Top::
 /x/
 E { return(identity(value: "x")) }
'''),
    );
    expect(
      error.diagnostic!.code,
      'user_function_keyword_arguments_unsupported',
    );
    expect(error.diagnostic!.callableName, 'identity');
    expect(error.diagnostic!.got, 1);
  });

  test(
    'typed declaration and all neutral contextual AST cases are metadata-owned',
    () {
      final contract = _contract();
      final contextual = (contract['contextual_final_block_cases']! as List)
          .map(_record)
          .toList(growable: false);
      expect(contextual.map((row) => row['id']).toSet(), {
        'helper_attached',
        'helper_parenthesized',
        'user_function_attached',
        'user_function_parenthesized',
        'receiver_attached',
        'receiver_parenthesized',
        'explicit_literal',
        'harray_not_promoted',
      });

      final compiled = _compileSource(_finalCodeblockEquivalenceSource());
      final apply = _record(
        (compiled.toDescriptorJson()['functions']! as Map)['apply'],
      );
      final descriptorVariant = _record(
        _record(
          _descriptorContract()['function_record_variants'],
        )['final_codeblock_v3'],
      );
      expect(apply.keys, descriptorVariant['record_fields']);
      expect(apply['version'], 3);
      expect(apply['params'], ['value', 'callback']);
      expect(apply['arity'], 2);
      expect(apply['parameter_kinds'], {'callback': 'codeblock'});
      expect(_record(apply['body_payload'])['parameter_kinds'], {
        'callback': 'codeblock',
      });
      expect(_record(apply['body_parse_job'])['parameter_kinds'], {
        'callback': 'codeblock',
      });

      final payload = compiled
          .rule('Top')!
          .lifecycleActionPayloads
          .singleWhere((item) => item.lifecycle == 'E');
      final returned =
          payload.actionAst.statements.single.expr as ActionCallExpr;
      final items =
          (returned.args.single.value as ActionArrayLiteralExpr).items;
      for (final (attachedIndex, parenthesizedIndex) in const [
        (0, 1),
        (3, 4),
        (9, 10),
      ]) {
        final attached = _record(_finalArgumentJson(items[attachedIndex]));
        final parenthesized = _record(
          _finalArgumentJson(items[parenthesizedIndex]),
        );
        for (final field in const [
          'kind',
          'version',
          'signature',
          'body_source',
          'body_ast',
        ]) {
          expect(
            attached[field],
            parenthesized[field],
            reason: '$field for $attachedIndex/$parenthesizedIndex',
          );
        }
        expect(attached['kind'], 'codeblock_argument');
        expect(_record(attached['signature'])['positional_params'], isEmpty);
        expect(_record(attached['signature'])['max_arity'], 0);
      }
      expect(
        _record(_finalArgumentJson(items[6]))['kind'],
        'codeblock_argument',
      );
      expect(
        _record(_finalArgumentJson(items[7]))['kind'],
        'codeblock_argument',
      );
      expect(
        _record(_finalArgumentJson(items[2]))['kind'],
        'codeblock_literal',
      );
      expect(
        jsonEncode(compiled.toJson()),
        isNot(contains('contextual_codeblock_candidate')),
      );

      final semantic = SemanticIndex.fromSource(
        _finalCodeblockEquivalenceSource(),
        options: const SemanticIndexOptions(
          logicalName: 'callable-codeblock-final-equivalence.spec',
          sourceDetailCeiling: SemanticSourceDetail.none,
        ),
      ).semanticStaticProjectionForTesting();
      final functionRecord = (semantic['records']! as List<Object?>)
          .map(_record)
          .singleWhere(
            (record) =>
                record['kind'] == 'function' && record['name'] == 'apply',
          );
      final facts = _record(functionRecord['facts']);
      expect(facts['parameter_kinds'], ['value', 'codeblock']);
      expect(_record(facts['signature'])['final_codeblock'], isTrue);
    },
  );

  test(
    'contextual forms execute through native reconstructed and generated paths',
    () {
      final compiled = _compileSource(_finalCodeblockEquivalenceSource());
      final expected = _finalCodeblockExpected();
      expect(LinkedSpecRuntimeEngine(compiled).parse('x').value, expected);
      expect(
        LinkedSpecRuntimeEngine(
          _reconstructFromEmittedPayload(
            compiled,
            'callable-codeblock-final-equivalence.spec',
          ),
        ).parse('x').value,
        expected,
      );
      expect(
        executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          'x',
          'callable-codeblock-final-equivalence.spec',
        ),
        expected,
      );
    },
  );

  test('ordinary eager blocks and controls remain distinct', () {
    final compiled = _compileSource(r'''Top::
 /x/
 E {
   state = "before";
   eager = array({ state = "eager"; state });
   if(true) { state = cat(state, "!") };
   return([state, eager])
 }
''');
    final encoded = jsonEncode(compiled.toJson());
    expect(encoded, isNot(contains('contextual_codeblock_candidate')));
    expect(encoded, contains('block_value'));
    expect(encoded, contains('control_if'));
    expect(LinkedSpecRuntimeEngine(compiled).parse('x').value, [
      'eager!',
      ['eager'],
    ]);

    expect(
      () => _compileSource(r'''Top::
 /x/
 E { return(custom("x") { return(value) }) }
'''),
      throwsA(
        isA<CompiledSpecException>()
            .having(
              (error) => error.message,
              'message',
              contains('callable_contract_rejected'),
            )
            .having((error) => error.message, 'message', contains('custom')),
      ),
    );
  });

  test('with resolves a callback named value before installing its scope', () {
    final compiled = _compileSource(r'''Top::
 /x/
 E {
   value = {|item| return(cat(item, "!")) };
   return([with("a", value), "b".with(value)])
 }
''');
    expect(LinkedSpecRuntimeEngine(compiled).parse('x').value, ['a!', 'b!']);
  });

  test('typed sidecar drift and contextual arity mismatch fail closed', () {
    final parsed = parseSpecWithStagedUserFunctionDefinitions(
      r'''fn apply(value, callback: codeblock) { return(callback()) }

Top::
 /x/
''',
    );
    final malformedJson = _record(jsonDecode(jsonEncode(parsed.toJson())));
    final malformedFunction = _record(
      (malformedJson['functions']! as List).single,
    );
    final malformedJob = _record(malformedFunction['body_parse_job']);
    malformedJob['parameter_kinds'] = {'value': 'codeblock'};
    expect(
      () => stitchFunctionBodyParseJobs(SpecFile.fromJson(malformedJson)),
      throwsA(
        isA<StagedParserRegistryException>().having(
          (error) => error.message,
          'message',
          contains('final-codeblock metadata does not match'),
        ),
      ),
    );

    for (final (surface, expression) in const [
      ('helper', 'with("a", "b") { return(value) }'),
      ('receiver', '"a".with("b") { return(value) }'),
      ('user_function', 'apply("a", "b") { return(value) }'),
    ]) {
      expect(
        () => _compileSource(
          '''fn apply(value, callback: codeblock) { return(callback()) }

Top::
 /x/
 E { return($expression) }
''',
        ),
        throwsA(
          isA<CompiledSpecException>().having(
            (error) => error.message,
            'message',
            contains('callable_contract_arity_mismatch'),
          ),
        ),
        reason: surface,
      );
    }
  });

  test('typed declaration and final-value failures keep neutral codes', () {
    final declaration = _record(
      _contract()['final_codeblock_parameter_declaration'],
    );
    for (final rawCase in declaration['invalid']! as List) {
      final row = _record(rawCase);
      expect(
        () => parseSpecWithStagedUserFunctionDefinitions('''Top::
 /x/

fn invalid(${row['source']}) { return(undef) }
'''),
        throwsA(
          predicate<Object>(
            (error) =>
                error.toString().contains(row['expected_code']! as String),
            '${row['id']} preserves ${row['expected_code']}',
          ),
        ),
      );
    }

    for (final (name, expression) in const [
      ('typed_function', 'apply("x", { "value" : value })'),
      ('helper', 'with("x", { "value" : value })'),
      ('receiver', '"x".with({ "value" : value })'),
    ]) {
      final error = _runtimeFailure(
        _compileSource(
          '''fn apply(value, callback: codeblock) { return(callback()) }

Top::
 /x/
 E { return($expression) }
''',
        ),
      );
      expect(
        error.diagnostic!.code,
        'final_argument_not_codeblock',
        reason: name,
      );
      expect(error.diagnostic!.valueKind, 'harray', reason: name);
    }
  });

  test(
    'standalone emitted Dart executes the fixture and all invalid calls',
    () {
      final contract = _contract();
      final fixture = _record(contract['fixture']);
      final fixtureCompiled = _compileSource(fixture['spec_source']! as String);
      final contextualCompiled = _compileSource(
        _finalCodeblockEquivalenceSource(),
      );
      final invalidRows = (contract['invalid_call_cases']! as List)
          .map(_record)
          .toList(growable: false);
      final packageRoot = Directory.current.absolute;
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-callable-codeblock-emitted-',
      );
      final pubCache = Directory('${scratch.path}/pub-cache')..createSync();
      try {
        Directory('${scratch.path}/lib').createSync();
        Directory('${scratch.path}/bin').createSync();
        File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_callable_codeblock_emitted_probe
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ${jsonEncode(packageRoot.path)}
''');
        File('${scratch.path}/lib/fixture.dart').writeAsStringSync(
          emitDartSourceV2(
            fixtureCompiled,
            'callable-codeblock/neutral-fixture.spec',
          ),
        );
        File('${scratch.path}/lib/contextual.dart').writeAsStringSync(
          emitDartSourceV2(
            contextualCompiled,
            'callable-codeblock/final-equivalence.spec',
          ),
        );
        for (final row in invalidRows) {
          final id = row['id']! as String;
          File('${scratch.path}/lib/$id.dart').writeAsStringSync(
            emitDartSourceV2(
              _compileSource(_invalidCallSource(id)),
              'callable-codeblock/$id.spec',
            ),
          );
        }

        final main = StringBuffer()
          ..writeln("import 'dart:convert';")
          ..writeln(
            "import 'package:linkedspec_callable_codeblock_emitted_probe/fixture.dart' as fixture;",
          )
          ..writeln(
            "import 'package:linkedspec_callable_codeblock_emitted_probe/contextual.dart' as contextual;",
          );
        for (final row in invalidRows) {
          final id = row['id']! as String;
          main.writeln(
            "import 'package:linkedspec_callable_codeblock_emitted_probe/$id.dart' as $id;",
          );
        }
        main
          ..writeln('void main() {')
          ..writeln('  final errors = <String, String>{};');
        for (final row in invalidRows) {
          final id = row['id']! as String;
          main
            ..writeln('  try {')
            ..writeln("    $id.execute('x');")
            ..writeln('  } catch (error) {')
            ..writeln("    errors['$id'] = '\$error';")
            ..writeln('  }');
        }
        main
          ..writeln('  print(jsonEncode({')
          ..writeln(
            "    'fixture': fixture.execute(${jsonEncode(fixture['input'])}),",
          )
          ..writeln("    'contextual': contextual.execute('x'),")
          ..writeln("    'errors': errors,")
          ..writeln('  }));')
          ..writeln('}');
        File(
          '${scratch.path}/bin/main.dart',
        ).writeAsStringSync(main.toString());

        final environment = {
          ...Platform.environment,
          'PUB_CACHE': pubCache.path,
        };
        _expectDartSuccess(scratch, environment, const [
          'pub',
          'get',
          '--offline',
        ]);
        final run = _expectDartSuccess(scratch, environment, const [
          'run',
          'bin/main.dart',
        ]);
        final result = _record(jsonDecode((run.stdout as String).trim()));
        expect(result['fixture'], fixture['expected']);
        expect(result['contextual'], _finalCodeblockExpected());
        final errors = _record(result['errors']);
        for (final row in invalidRows) {
          final id = row['id']! as String;
          final expected = _record(row['expected_error']);
          expect(errors[id], contains(expected['code']), reason: id);
        }
      } finally {
        scratch.deleteSync(recursive: true);
      }
      expect(scratch.existsSync(), isFalse);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
