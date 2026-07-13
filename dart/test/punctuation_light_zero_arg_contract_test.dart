import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object?> _contract() {
  return (jsonDecode(
            File(
              '../capability_conformance/punctuation_light_zero_arg_contract.json',
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

Object? _semanticAst(Object? value) {
  if (value is List) {
    return [for (final item in value) _semanticAst(item)];
  }
  if (value is Map) {
    return {
      for (final entry in value.entries)
        if (!const {
          'source',
          'source_span',
          'source_method',
          'body_source_span',
          'trailing_block_source_span',
        }.contains(entry.key))
          entry.key: _semanticAst(entry.value),
    };
  }
  return value;
}

String _actionSource(String action) {
  return 'Top::\n'
      ' /x/ -> Done { values = ["a", "b"]; $action }\n'
      'Done::\n'
      ' /x/\n';
}

void main() {
  test('standalone aliases share parenthesized typed ActionIR', () {
    final contract = _contract();
    expect(contract['contract_id'], 'linkedspec-punctuation-light-zero-arg-v1');

    final cases = (contract['standalone_cases']! as List)
        .cast<Map<Object?, Object?>>();
    for (final rawCase in cases) {
      final testCase = rawCase.cast<String, Object?>();
      final bare = parseActionStatement(testCase['bare']! as String).expr;
      final parenthesized = parseActionStatement(
        testCase['parenthesized']! as String,
      ).expr;
      expect(
        _semanticAst(bare.toJson()),
        _semanticAst(parenthesized.toJson()),
        reason: testCase['id']! as String,
      );
      expect(
        bare.kind,
        ((testCase['expected_ast']! as Map<Object?, Object?>)['kind']!
            as String),
        reason: testCase['id']! as String,
      );
    }

    final valuePosition =
        parseActionExpression('return(next)') as ActionCallExpr;
    expect(valuePosition.args.single.value, isA<ActionVariableExpr>());
    expect(
      (valuePosition.args.single.value as ActionVariableExpr).name,
      'next',
    );
    expect(parseActionExpression('next'), isA<ActionVariableExpr>());
  });

  test('terminal receiver aliases share parenthesized typed ActionIR', () {
    final cases = (_contract()['receiver_cases']! as List)
        .cast<Map<Object?, Object?>>();
    for (final rawCase in cases) {
      final testCase = rawCase.cast<String, Object?>();
      final bare = parseActionExpression(testCase['bare']! as String);
      final parenthesized = parseActionExpression(
        testCase['parenthesized']! as String,
      );
      expect(bare, isA<ActionFluentChainExpr>(), reason: '${testCase['id']}');
      expect(
        _semanticAst(bare.toJson()),
        _semanticAst(parenthesized.toJson()),
        reason: testCase['id']! as String,
      );
      final chain = bare as ActionFluentChainExpr;
      expect(chain.calls.last.args, isEmpty, reason: '${testCase['id']}');
    }
  });

  test('retained identifiers and excluded forms do not broaden', () {
    final contract = _contract();
    final retained = (contract['retained_noncall_cases']! as List)
        .cast<Map<Object?, Object?>>();
    for (final rawCase in retained) {
      final testCase = rawCase.cast<String, Object?>();
      final source = testCase['source']! as String;
      final expr = parseActionExpression(source);
      expect(expr, isA<ActionVariableExpr>(), reason: '${testCase['id']}');
      expect((expr as ActionVariableExpr).name, source);
    }

    final invalid = (contract['invalid_syntax_cases']! as List)
        .cast<Map<Object?, Object?>>();
    for (final rawCase in invalid) {
      final testCase = rawCase.cast<String, Object?>();
      final id = testCase['id']! as String;
      final expr = parseActionExpression(testCase['source']! as String);
      expect(expr, isA<ActionRawExpr>(), reason: id);
      expect(
        (expr as ActionRawExpr).reason,
        id == 'intermediate_generic_receiver' ||
                id == 'receiver_trailing_block_without_call'
            ? 'invalid_fluent_chain'
            : 'unsupported_expression',
        reason: id,
      );
    }
  });

  test('terminal alias preserves existing Dart method resolution', () {
    final count = LinkedSpecRuntimeEngine(
      _compileSource(_actionSource('return(values.count)')),
    ).parse('xx');
    expect(count.value, 2);

    final bare = LinkedSpecRuntimeEngine(
      _compileSource(_actionSource('return(values.contains)')),
    ).parse('xx');
    final parenthesized = LinkedSpecRuntimeEngine(
      _compileSource(_actionSource('return(values.contains())')),
    ).parse('xx');
    expect(bare.value, parenthesized.value);
    // Dart already returns 0 for the missing contains needle. Backlog .5 owns
    // that helper-arity drift; this syntax leaf preserves the existing twin.
    expect(bare.value, 0);
  });

  test('neutral fixture matches native and generated Dart paths', () {
    final fixture = (_contract()['future_fixture']! as Map)
        .cast<String, Object?>();
    final source = fixture['spec_source']! as String;
    final input = fixture['input']! as String;
    final expected = fixture['expected'];
    final compiled = _compileSource(source);

    expect(LinkedSpecRuntimeEngine(compiled).parse(input).value, expected);

    final plan = buildGeneratedRulePlan(compiled);
    expect(
      executeGeneratedParserV1(
        compiled,
        plan,
        input,
        'punctuation-light-zero-arg.spec',
      ),
      expected,
    );

    final generated = emitDartSourceV1(
      compiled,
      'punctuation-light-zero-arg.spec',
    );
    expect(generated, contains('linkedspec-generated-source-v1'));
    final encoded = RegExp(
      "const _compiledSpecJsonBase64 = '([^']+)';",
    ).firstMatch(generated)![1]!;
    final normalized = (jsonDecode(utf8.decode(base64Decode(encoded))) as Map)
        .cast<String, Object?>();
    final reconstructed = compileSpec(SpecFile.fromJson(normalized));
    expect(LinkedSpecRuntimeEngine(reconstructed).parse(input).value, expected);
  });
}
