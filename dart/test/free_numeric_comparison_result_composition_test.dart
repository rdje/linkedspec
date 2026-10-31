// TYPE-REFERENCE-BOOK.1.2.23.3.64.3 — canonical numeric comparison source and Number-prefix result guards.
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
      'free-numeric-comparison-result-composition.spec',
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
  print('FREE_NUMERIC_COMPARISON_VALUE $label ${jsonEncode(observed)}');
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
      r'''Value:: I {return([[num_eq(2,2),num_ne(2,3),num_gt(3,2),num_ge(2,2),num_lt(2,3),num_le(2,2),num_eq(2,3),num_ne(2,2),num_gt(2,3),num_ge(2,3),num_lt(3,2),num_le(3,2)],[2.eq(2),2.ne(3),3.gt(2),2.ge(2),2.lt(3),2.le(2),2.eq(3),2.ne(2),2.gt(3),2.ge(3),3.lt(2),3.le(2)]])}''',
      'x',
      jsonDecode(r'''[[1,1,1,1,1,1,0,0,0,0,0,0],[1,1,1,1,1,1,0,0,0,0,0,0]]'''),
    );
  });
  test('strict_numeric_domains', () {
    check(
      'strict_numeric_domains',
      r'''Value:: I {return([num_eq("02",2),num_lt("-.5",0),num_eq(false,0),num_eq(undef,0),num_eq([],0),num_eq({},0),num_eq(" 2",2),"02".eq(2),false.eq(0),"bad".eq(0)])}''',
      'x',
      jsonDecode(r'''[1,1,null,null,null,null,null,1,null,null]'''),
    );
  });
  test('compatible_values', () {
    check(
      'compatible_values',
      r'''Value:: I {return([num_eq(2,2).cat("!"),num_eq(2,3).coalesce_nonempty(9).cat("!"),num_lt(2,3).cat(",tail").split(",").last().uppercase(),2.eq(3).add(2)])}''',
      'x',
      jsonDecode(r'''["1!","0!","TAIL",2]'''),
    );
  });
  test('free_container_guards', () {
    check(
      'free_container_guards',
      r'''Value:: I {order="";left=num_eq(2,3).take({order=cat(order,"A");1});right=num_gt(3,2).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('receiver_container_guards', () {
    check(
      'receiver_container_guards',
      r'''Value:: I {order="";left=2.eq(3).take({order=cat(order,"A");1});right=3.gt(2).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('free_guard_before_with', () {
    check(
      'free_guard_before_with',
      r'''Value:: I {order="";out=num_eq({order=cat(order,"S");return(2)},2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('receiver_guard_before_with', () {
    check(
      'receiver_guard_before_with',
      r'''Value:: I {order="";out={order=cat(order,"S");return(2)}.eq(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('free_bridge_rejection', () {
    check(
      'free_bridge_rejection',
      r'''Value:: I {order="";out=num_eq(2,3).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('receiver_bridge_rejection', () {
    check(
      'receiver_bridge_rejection',
      r'''Value:: I {order="";out=2.eq(3).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('valid_array_bridges', () {
    check(
      'valid_array_bridges',
      r'''Value:: I {return([num_eq(2,2).split(",").first().cat("!"),2.eq(3).split(",").first().cat("!")])}''',
      'x',
      jsonDecode(r'''["1!","0!"]'''),
    );
  });
  test('source_operand_snapshot', () {
    check(
      'source_operand_snapshot',
      r'''Value:: I {value=2;order="";out=num_eq({order=cat(order,"S");return(value)},{value=99;order=cat(order,"O");return(2)}).cat({order=cat(order,"C");"!"});return([out,value,order])}''',
      'x',
      jsonDecode(r'''["1!",99,"SOC"]'''),
    );
  });
  test('zero_typed_indices', () {
    check(
      'zero_typed_indices',
      r'''Value:: I {slots=["old"];index=num_eq(2,3).copy();slots[index]="free";other=2.eq(3).copy();slots[other]="receiver";return([index,other,slots])}''',
      'x',
      jsonDecode(r'''[0,0,["receiver"]]'''),
    );
  });
  test('valid_null_with', () {
    check(
      'valid_null_with',
      r'''Value:: I {order="";left=num_eq("bad",2).with(){order=cat(order,"F");return("free")};right="bad".eq(2).with(){order=cat(order,"R");return("receiver")};return([left,right,order])}''',
      'x',
      jsonDecode(r'''["free","receiver","FR"]'''),
    );
  });
  test('valid_empty_with', () {
    check(
      'valid_empty_with',
      r'''Value:: I {order="";out=num_eq("bad",2).coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}''',
      'x',
      jsonDecode(r'''[0,"W"]'''),
    );
  });
  test('all_canonical_free_guards', () {
    check(
      'all_canonical_free_guards',
      r'''Value:: I {order="";out=[num_eq(2,2).take({order=cat(order,"A");1}),num_ne(2,3).take({order=cat(order,"A");1}),num_gt(3,2).take({order=cat(order,"A");1}),num_ge(2,2).take({order=cat(order,"A");1}),num_lt(2,3).take({order=cat(order,"A");1}),num_le(2,2).take({order=cat(order,"A");1}),num_eq(2,3).take({order=cat(order,"A");1}),num_ne(2,2).take({order=cat(order,"A");1}),num_gt(2,3).take({order=cat(order,"A");1}),num_ge(2,3).take({order=cat(order,"A");1}),num_lt(3,2).take({order=cat(order,"A");1}),num_le(3,2).take({order=cat(order,"A");1})];return([out,order])}''',
      'x',
      jsonDecode(
        r'''[[null,null,null,null,null,null,null,null,null,null,null,null],""]''',
      ),
    );
  });
  test('all_short_receiver_with_guards', () {
    check(
      'all_short_receiver_with_guards',
      r'''Value:: I {order="";out=[2.eq(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.ne(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.gt(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.ge(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.lt(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.le(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.eq(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.ne(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.gt(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.ge(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.lt(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.le(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(
        r'''[[null,null,null,null,null,null,null,null,null,null,null,null],""]''',
      ),
    );
  });
  test('function_scope', () {
    check(
      'function_scope',
      r'''fn build(){order="";left=num_eq(2,3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right=2.eq(3).take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}''',
      'x',
      jsonDecode(r'''[[null,null,""],"caller"]'''),
    );
  });
  test('valid_zero_and_one_with', () {
    check(
      'valid_zero_and_one_with',
      r'''Value:: I {order="";zero=num_eq(2,3).with(){order=cat(order,"F");return(value.add(2))};one=2.eq(2).with(){order=cat(order,"R");return(value.add(2))};return([zero,one,order])}''',
      'x',
      jsonDecode(r'''[2,3,"FR"]'''),
    );
  });
  test('needed source error precedes recovery', () {
    final actual = errorRows(
      r'''Value:: I {return(num_eq({items="text";push(items,"x")},2).coalesce("masked"))}''',
      'x',
    );
    print('FREE_NUMERIC_COMPARISON_ERROR ${jsonEncode(actual)}');
    for (final route in actual.entries) {
      expect(
        (route.value! as Map)['error'],
        contains('binding_kind_mismatch'),
        reason: route.key,
      );
    }
  });
  test('public excluded numeric comparison source shapes stay current', () {
    final observed = <Object?>[];
    for (final source in [
      r'''num_eq().take(1).with(){return("x")}''',
      r'''num_eq(1).take(1).with(){return("x")}''',
      r'''num_eq(1,1,1).take(1)''',
      r'''num_eq(left:1,right:1).take(1)''',
      r'''eq(1,1).take(1)''',
      r'''==(1,1).take(1)''',
      r'''num_min([1,2]).take(1)''',
      r'''[1,2].min().with(){return(value)}''',
      r'''str_eq("a","a").take(1).with(){return("x")}''',
      r'''"a".str_eq("a").take(1).with(){return("x")}''',
      r'''1.eq().with(){return("x")}''',
      r'''1.eq(2){return("x")}''',
      r'''{|| return(num_eq(1,1).take(1)) }''',
      r'''num_eq(1,1).map_leaves(){return(value)}''',
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
    expect(observed, hasLength(14));
    print('FREE_NUMERIC_COMPARISON_SHAPES ${jsonEncode(observed)}');
  });
}
