// TYPE-REFERENCE-BOOK.1.2.23.3.66.3 — lexical comparison source/prefix guards.
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
      'lexical-result-guard-composition.spec',
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
  print('LEXICAL_GUARD_VALUE $label ${jsonEncode(observed)}');
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
  test('primitive_comparisons', () {
    check(
      'primitive_comparisons',
      r'''Value:: I {return([[str_eq("a","a"),str_ne("a","b"),str_gt("b","a"),str_ge("a","a"),str_lt("a","b"),str_le("a","a"),str_eq("a","b"),str_ne("a","a"),str_gt("a","b"),str_ge("a","b"),str_lt("b","a"),str_le("b","a")],["a".str_eq("a"),"a".str_ne("b"),"b".str_gt("a"),"a".str_ge("a"),"a".str_lt("b"),"a".str_le("a"),"a".str_eq("b"),"a".str_ne("a"),"a".str_gt("b"),"a".str_ge("b"),"b".str_lt("a"),"b".str_le("a")]])}''',
      'x',
      jsonDecode(
        r'''[[true,true,true,true,true,true,false,false,false,false,false,false],[true,true,true,true,true,true,false,false,false,false,false,false]]''',
      ),
    );
  });
  test('compatible_values', () {
    check(
      'compatible_values',
      r'''Value:: I {return([str_eq("a","a").cat("!"),str_eq("a","b").coalesce_nonempty(9).cat("!"),str_lt("a","b").cat(",tail").split(",").last().uppercase(),"a".str_eq("b").cat("!")])}''',
      'x',
      jsonDecode(r'''["1!","0!","TAIL","0!"]'''),
    );
  });
  test('value_kinds', () {
    check(
      'value_kinds',
      r'''Value:: I {return([str_eq("a","b").copy(),"a".str_eq("b").copy(),str_eq("a","b").add(1),"a".str_eq("a").add(1)])}''',
      'x',
      jsonDecode(r'''[false,false,null,null]'''),
    );
  });
  test('free_container_guards', () {
    check(
      'free_container_guards',
      r'''Value:: I {order="";left=str_eq("a","b").take({order=cat(order,"A");1});right=str_gt("b","a").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('receiver_container_guards', () {
    check(
      'receiver_container_guards',
      r'''Value:: I {order="";left="a".str_eq("b").take({order=cat(order,"A");1});right="b".str_gt("a").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('free_guard_before_with', () {
    check(
      'free_guard_before_with',
      r'''Value:: I {order="";out=str_eq({order=cat(order,"S");return("a")},{order=cat(order,"O");return("b")}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"SO"]'''),
    );
  });
  test('receiver_guard_before_with', () {
    check(
      'receiver_guard_before_with',
      r'''Value:: I {order="";out={order=cat(order,"S");return("a")}.str_eq({order=cat(order,"O");return("b")}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"SO"]'''),
    );
  });
  test('free_bridge_rejection', () {
    check(
      'free_bridge_rejection',
      r'''Value:: I {order="";out=str_eq("a","b").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('receiver_bridge_rejection', () {
    check(
      'receiver_bridge_rejection',
      r'''Value:: I {order="";out="a".str_eq("b").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('valid_array_bridges', () {
    check(
      'valid_array_bridges',
      r'''Value:: I {return([str_eq("a","b").split(",").first().cat("!"),"a".str_eq("a").split(",").first().cat("!")])}''',
      'x',
      jsonDecode(r'''["0!","1!"]'''),
    );
  });
  test('source_operand_snapshot', () {
    check(
      'source_operand_snapshot',
      r'''Value:: I {word="a";order="";out=str_eq({order=cat(order,"S");return(word)},{word="zzz";order=cat(order,"O");return("b")}).cat({order=cat(order,"C");"!"});return([out,word,order])}''',
      'x',
      jsonDecode(r'''["0!","zzz","SOC"]'''),
    );
  });
  test('valid_false_and_true_with', () {
    check(
      'valid_false_and_true_with',
      r'''Value:: I {order="";left=str_eq("a","b").with(){order=cat(order,"F");return([value,value.copy()])};right="a".str_eq("a").with(){order=cat(order,"R");return(value)};return([left,right,order])}''',
      'x',
      jsonDecode(r'''[[false,false],true,"FR"]'''),
    );
  });
  test('valid_null_with', () {
    check(
      'valid_null_with',
      r'''Value:: I {order="";left=str_eq("a","a").add("bad").with(){order=cat(order,"F");return("free")};right="a".str_eq("a").add("bad").with(){order=cat(order,"R");return("receiver")};return([left,right,order])}''',
      'x',
      jsonDecode(r'''["free","receiver","FR"]'''),
    );
  });
  test('valid_empty_with', () {
    check(
      'valid_empty_with',
      r'''Value:: I {order="";out=str_eq("a","b").add("bad").coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}''',
      'x',
      jsonDecode(r'''[0,"W"]'''),
    );
  });
  test('with_result_array', () {
    check(
      'with_result_array',
      r'''Value:: I {order="";out=str_eq("a","b").with(){order=cat(order,"W");return(["ok"])}.first().uppercase();return([out,order])}''',
      'x',
      jsonDecode(r'''["OK","W"]'''),
    );
  });
  test('all_canonical_free_with_guards', () {
    check(
      'all_canonical_free_with_guards',
      r'''Value:: I {order="";out=[str_eq("a","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_ne("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_gt("b","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_ge("a","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_lt("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_le("a","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_eq("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_ne("a","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_gt("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_ge("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_lt("b","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_le("b","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(
        r'''[[null,null,null,null,null,null,null,null,null,null,null,null],""]''',
      ),
    );
  });
  test('all_short_receiver_with_guards', () {
    check(
      'all_short_receiver_with_guards',
      r'''Value:: I {order="";out=["a".str_eq("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_ne("b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"b".str_gt("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_ge("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_lt("b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_le("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_eq("b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_ne("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_gt("b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_ge("b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"b".str_lt("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"b".str_le("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(
        r'''[[null,null,null,null,null,null,null,null,null,null,null,null],""]''',
      ),
    );
  });
  test('function_scope', () {
    check(
      'function_scope',
      r'''fn build(){order="";left=str_eq("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right="a".str_eq("a").take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}''',
      'x',
      jsonDecode(r'''[[null,null,""],"caller"]'''),
    );
  });
  test('needed_source_error', () {
    final actual = errorRows(
      r'''Value:: I {return(str_eq({items="text";push(items,"x")},"a").coalesce("masked"))}''',
      'x',
    );
    print('LEXICAL_GUARD_ERROR needed_source_error ${jsonEncode(actual)}');
    for (final route in actual.entries) {
      final error = route.value! as Map;
      expect(
        error['error'],
        contains('binding_kind_mismatch'),
        reason: route.key,
      );
    }
  });
  test('all_canonical_free_guards', () {
    check(
      'all_canonical_free_guards',
      r'''Value:: I {order="";out=[str_eq("a","a").take({order=cat(order,"A");1}),str_ne("a","b").take({order=cat(order,"A");1}),str_gt("b","a").take({order=cat(order,"A");1}),str_ge("a","a").take({order=cat(order,"A");1}),str_lt("a","b").take({order=cat(order,"A");1}),str_le("a","a").take({order=cat(order,"A");1}),str_eq("a","b").take({order=cat(order,"A");1}),str_ne("a","a").take({order=cat(order,"A");1}),str_gt("a","b").take({order=cat(order,"A");1}),str_ge("a","b").take({order=cat(order,"A");1}),str_lt("b","a").take({order=cat(order,"A");1}),str_le("b","a").take({order=cat(order,"A");1})];return([out,order])}''',
      'x',
      jsonDecode(
        r'''[[null,null,null,null,null,null,null,null,null,null,null,null],""]''',
      ),
    );
  });
  test('excluded public lexical source shapes stay current', () {
    final observed = <Object?>[];
    for (final source in [
      r'''str_eq().take(1).with(){return("x")}''',
      r'''str_eq("a").take(1).with(){return("x")}''',
      r'''str_eq("a","a","a").take(1)''',
      r'''str_eq(left:"a",right:"a").take(1)''',
      r'''eq("a","a").take(1)''',
      r'''==("a","a").take(1)''',
      r'''num_eq(1,1).take(1).with(){return("x")}''',
      r'''and(false).take(1).with(){return("x")}''',
      r'''"a".str_eq().with(){return("x")}''',
      r'''"a".str_eq("a","a").with(){return("x")}''',
      r'''"a".str_eq(right:"a").with(){return("x")}''',
      r'''str_eq("a","a"){return("x")}''',
      r'''"a".str_eq("a"){return("x")}''',
      r'''str_eq("a","a").map_leaves(){return(value)}''',
      r'''"a".str_eq("a").map_leaves(){return(value)}''',
      r'''{|| return(str_eq("a","a").take(1).with(){return("x")}) }''',
      r'''str_eq("a","a").custom_compare().with(){return("x")}''',
      r'''"a".str_eq("a").custom_compare().with(){return("x")}''',
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
    expect(observed, hasLength(18));
    print('LEXICAL_GUARD_SHAPES ${jsonEncode(observed)}');
  });
}
