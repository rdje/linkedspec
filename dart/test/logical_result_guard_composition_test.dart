// TYPE-REFERENCE-BOOK.1.2.23.3.65.3 — eager logical Boolean source/prefix guards.
import 'dart:convert';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object? Function()> routes(String source, String input) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  return {
    'native': () => LinkedSpecRuntimeEngine(compiled).execute(input).value,
    'restored': () =>
        LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input).value,
    'plan': () => executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      input,
      'logical-result-guard-composition.spec',
    ),
  };
}

void check(String label, String source, String input, Object? expected) {
  final observed = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      observed[route.key] = {'ok': route.value()};
    } catch (error) {
      observed[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('LOGICAL_GUARD_VALUE $label ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    expect(row.value, {'ok': expected}, reason: row.key);
  }
}

Map<String, Object?> errorRows(String source, String input) {
  final actual = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      actual[route.key] = {'value': route.value()};
    } catch (error) {
      actual[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
        if (error is RuntimeInterpreterException)
          'diagnostic': error.diagnostic?.toJson(),
      };
    }
  }
  return actual;
}

void main() {
  test('primitive_logical', () {
    check(
      'primitive_logical',
      r'''Value:: I {return([[and(true),and(false),or(true),or(false),not(false),not(true)],[true.and(true),true.and(false),false.or(true),false.or(false),false.not(),true.not()]])}''',
      'x',
      jsonDecode(
        r'''[[true,false,true,false,true,false],[true,false,true,false,true,false]]''',
      ),
    );
  });
  test('typed_truth_domains', () {
    check(
      'typed_truth_domains',
      r'''Value:: I {return([and("0"),and("false"),and(""),and(0),and(undef),and([]),and({}),and([false]),and({"k":false})])}''',
      'x',
      jsonDecode(r'''[true,true,false,false,false,false,false,true,true]'''),
    );
  });
  test('compatible_values', () {
    check(
      'compatible_values',
      r'''Value:: I {return([and(false).coalesce_nonempty(9).cat("!"),not(false).cat("!"),or(false).add(1).coalesce_nonempty(["a","b"]).last().uppercase(),false.not().and(true).cat("!")])}''',
      'x',
      jsonDecode(r'''["0!","1!","B","1!"]'''),
    );
  });
  test('free_container_guards', () {
    check(
      'free_container_guards',
      r'''Value:: I {order="";left=and(false).take({order=cat(order,"A");1});right=not(false).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('receiver_container_guards', () {
    check(
      'receiver_container_guards',
      r'''Value:: I {order="";left=true.and(false).take({order=cat(order,"A");1});right=false.not().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('free_guard_before_with', () {
    check(
      'free_guard_before_with',
      r'''Value:: I {order="";out=and({order=cat(order,"S");return(false)},{order=cat(order,"O");return(true)}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"SO"]'''),
    );
  });
  test('receiver_guard_before_with', () {
    check(
      'receiver_guard_before_with',
      r'''Value:: I {order="";out={order=cat(order,"S");return(false)}.and({order=cat(order,"O");return(true)}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"SO"]'''),
    );
  });
  test('free_bridge_rejection', () {
    check(
      'free_bridge_rejection',
      r'''Value:: I {order="";out=and(false).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('receiver_bridge_rejection', () {
    check(
      'receiver_bridge_rejection',
      r'''Value:: I {order="";out=false.and(true).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('valid_array_bridges', () {
    check(
      'valid_array_bridges',
      r'''Value:: I {return([and(false).split(",").first().cat("!"),false.or(true).split(",").first().cat("!")])}''',
      'x',
      jsonDecode(r'''["0!","1!"]'''),
    );
  });
  test('source_operand_snapshot', () {
    check(
      'source_operand_snapshot',
      r'''Value:: I {value=false;order="";out=and({order=cat(order,"S");return(value)},{value=true;order=cat(order,"O");return(true)}).cat({order=cat(order,"C");"!"});return([out,value,order])}''',
      'x',
      jsonDecode(r'''["0!",true,"SOC"]'''),
    );
  });
  test('bool_value_copies', () {
    check(
      'bool_value_copies',
      r'''Value:: I {return([and(false).copy(),false.and(true).copy(),copy(false)])}''',
      'x',
      jsonDecode(r'''[false,false,false]'''),
    );
  });
  test('valid_false_and_true_with', () {
    check(
      'valid_false_and_true_with',
      r'''Value:: I {order="";left=and(false).with(){order=cat(order,"F");return([value,value.copy()])};right=true.or(false).with(){order=cat(order,"R");return(value)};return([left,right,order])}''',
      'x',
      jsonDecode(r'''[[false,false],true,"FR"]'''),
    );
  });
  test('valid_null_with', () {
    check(
      'valid_null_with',
      r'''Value:: I {order="";left=and(false).add(1).with(){order=cat(order,"F");return("free")};right=false.and(true).add(1).with(){order=cat(order,"R");return("receiver")};return([left,right,order])}''',
      'x',
      jsonDecode(r'''["free","receiver","FR"]'''),
    );
  });
  test('valid_empty_with', () {
    check(
      'valid_empty_with',
      r'''Value:: I {order="";out=and(false).add(1).coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}''',
      'x',
      jsonDecode(r'''[0,"W"]'''),
    );
  });
  test('with_result_array', () {
    check(
      'with_result_array',
      r'''Value:: I {order="";out=and(false).with(){order=cat(order,"W");return(["ok"])}.first().uppercase();return([out,order])}''',
      'x',
      jsonDecode(r'''["OK","W"]'''),
    );
  });
  test('all_canonical_free_with_guards', () {
    check(
      'all_canonical_free_with_guards',
      r'''Value:: I {order="";out=[and(true).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},and(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},or(true).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},or(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},not(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},not(true).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null,null,null],""]'''),
    );
  });
  test('all_short_receiver_with_guards', () {
    check(
      'all_short_receiver_with_guards',
      r'''Value:: I {order="";out=[true.and(true).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},true.and(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},false.or(true).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},false.or(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},false.not().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},true.not().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null,null,null],""]'''),
    );
  });
  test('function_scope', () {
    check(
      'function_scope',
      r'''fn build(){order="";left=and(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right=false.and(true).take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}''',
      'x',
      jsonDecode(r'''[[null,null,""],"caller"]'''),
    );
  });
  test('needed_source_error', () {
    final actual = errorRows(
      r'''Value:: I {return(and({items="text";push(items,"x")},true).coalesce("masked"))}''',
      'x',
    );
    print('LOGICAL_GUARD_ERROR needed_source_error ${jsonEncode(actual)}');
    for (final route in actual.entries) {
      final error = route.value! as Map;
      expect(
        error['error'],
        contains('binding_kind_mismatch'),
        reason: route.key,
      );
    }
  });
  test('typed_arity_source_error', () {
    final actual = errorRows(
      r'''Value:: I {return(not({fail("must-not-run")},false).cat("!"))}''',
      'x',
    );
    print('LOGICAL_GUARD_ERROR typed_arity_source_error ${jsonEncode(actual)}');
    for (final route in actual.entries) {
      final error = route.value! as Map;
      expect(
        error['error'],
        contains('helper_arity_mismatch'),
        reason: route.key,
      );
      if (route.key == 'plan') {
        expect(error['error'], contains('helper_name=not'));
        expect(error['error'], contains('actual_arity=2'));
      } else {
        final diagnostic = error['diagnostic'] as Map;
        expect(diagnostic['code'], 'helper_arity_mismatch');
        expect(diagnostic['helper_name'], 'not');
        expect(diagnostic['actual_arity'], 2);
        expect(diagnostic['rule_label'], 'Value');
      }
      expect(error['error'], isNot(contains('must-not-run')));
    }
  });
  test('decisive_eager_args', () {
    check(
      'decisive_eager_args',
      r'''Value:: I {order="";left=and({order=cat(order,"L");return(false)},{order=cat(order,"R");return(true)}).cat({order=cat(order,"C");"!"});right=or({order=cat(order,"A");return(true)},{order=cat(order,"B");return(false)}).cat({order=cat(order,"D");"!"});return([left,right,order])}''',
      'x',
      jsonDecode(r'''["0!","1!","LRCABD"]'''),
    );
  });
  test('excluded public logical source shapes stay current', () {
    final observed = <Object?>[];
    for (final source in [
      r'''and().take(1).with(){return("x")}''',
      r'''or().take(1).with(){return("x")}''',
      r'''not().take(1)''',
      r'''not(true,false).take(1)''',
      r'''and(value:true).take(1).with(){return("x")}''',
      r'''false.and().with(){return("x")}''',
      r'''false.or().with(){return("x")}''',
      r'''false.not(true).with(){return("x")}''',
      r'''false.and(right:true).with(){return("x")}''',
      r'''and(true){return("x")}''',
      r'''false.and(true){return("x")}''',
      r'''and(true).map_leaves(){return(value)}''',
      r'''false.and(true).map_leaves(){return(value)}''',
      r'''{|| return(and(false).take(1).with(){return("x")}) }''',
      r'''and(false).custom_logical().with(){return("x")}''',
      r'''false.not().custom_logical().with(){return("x")}''',
    ]) {
      try {
        observed.add({
          'source': source,
          'ast': parseActionExpression(source).toJson(),
        });
      } catch (error) {
        observed.add({
          'source': source,
          'error': error.toString(),
          'class': error.runtimeType.toString(),
        });
      }
    }
    expect(observed, hasLength(16));
    print('LOGICAL_GUARD_SHAPES ${jsonEncode(observed)}');
  });
}
