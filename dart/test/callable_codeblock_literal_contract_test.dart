// FUTURE-PARITY-BACKLOG.11.5.1 — Dart callable-codeblock construction/state.

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
}
