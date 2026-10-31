// TYPE-REFERENCE-BOOK.1.2.23.3.68.3 — emptiness source/prefix guards.
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
      'emptiness-result-guard-composition.spec',
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
  print('EMPTINESS_GUARD_VALUE $label ${jsonEncode(observed)}');
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
  test('primitive_emptiness', () {
    check(
      'primitive_emptiness',
      r'''Value:: I {return([[is_empty([]),is_empty([1]),is_nonempty([1]),is_nonempty([])],[[].is_empty(),[1].is_empty(),[1].is_nonempty(),[].is_nonempty()]])}''',
      'x',
      jsonDecode(r'''[[true,false,true,false],[true,false,true,false]]'''),
    );
  });
  test('empty_domains', () {
    check(
      'empty_domains',
      r'''Value:: I {return([is_empty(undef),is_empty(""),is_empty([]),is_empty({}),is_empty(0),is_empty(false),is_empty("0"),is_empty([0]),is_empty({"k":0}),is_nonempty(undef),is_nonempty(""),is_nonempty([]),is_nonempty({}),is_nonempty(0),is_nonempty(false),is_nonempty("0"),is_nonempty([0]),is_nonempty({"k":0})])}''',
      'x',
      jsonDecode(
        r'''[true,true,true,true,false,false,false,false,false,false,false,false,false,true,true,true,true,true]''',
      ),
    );
  });
  test('compatible_values', () {
    check(
      'compatible_values',
      r'''Value:: I {return([is_empty([1]).cat("!"),is_empty([1]).coalesce_nonempty("late").cat("!"),is_nonempty([]).cat("!"),is_nonempty([]).coalesce("late").cat("!")])}''',
      'x',
      jsonDecode(r'''["0!","0!","0!","0!"]'''),
    );
  });
  test('value_kinds', () {
    check(
      'value_kinds',
      r'''Value:: I {return([is_empty([1]).copy(),[1].is_empty().copy(),is_empty([1]).add(1),is_empty([]).add(1)])}''',
      'x',
      jsonDecode(r'''[false,false,null,null]'''),
    );
  });
  test('free_container_guards', () {
    check(
      'free_container_guards',
      r'''Value:: I {order="";left=is_empty([1]).take({order=cat(order,"A");1});right=is_empty([]).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('receiver_container_guards', () {
    check(
      'receiver_container_guards',
      r'''Value:: I {order="";left=[1].is_empty().take({order=cat(order,"A");1});right=[].is_empty().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('free_guard_before_with', () {
    check(
      'free_guard_before_with',
      r'''Value:: I {order="";out=is_empty({order=cat(order,"S");[1]}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('receiver_guard_before_with', () {
    check(
      'receiver_guard_before_with',
      r'''Value:: I {order="";out={order=cat(order,"S");[1]}.is_empty().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('free_bridge_rejection', () {
    check(
      'free_bridge_rejection',
      r'''Value:: I {order="";out=is_empty([1]).cat("x").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('receiver_bridge_rejection', () {
    check(
      'receiver_bridge_rejection',
      r'''Value:: I {order="";out=[1].is_empty().cat("x").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('valid_array_bridges', () {
    check(
      'valid_array_bridges',
      r'''Value:: I {return([is_empty([1]).cat(",x").split(",").last().uppercase(),[].is_empty().cat(",x").split(",").last().uppercase()])}''',
      'x',
      jsonDecode(r'''["X","X"]'''),
    );
  });
  test('source_snapshot', () {
    check(
      'source_snapshot',
      r'''Value:: I {order="";value=[];out=is_empty({order=cat(order,"S");value}).cat({value=[1];order=cat(order,"C");"!"});return([out,value.is_empty().cat("!"),order])}''',
      'x',
      jsonDecode(r'''["1!","0!","SC"]'''),
    );
  });
  test('valid_false_and_true_with', () {
    check(
      'valid_false_and_true_with',
      r'''Value:: I {order="";left=is_empty([1]).with(){order=cat(order,"F");return([value,value.copy()])};right=[].is_empty().with(){order=cat(order,"R");return(value)};return([left,right,order])}''',
      'x',
      jsonDecode(r'''[[false,false],true,"FR"]'''),
    );
  });
  test('valid_null_with', () {
    check(
      'valid_null_with',
      r'''Value:: I {order="";left=is_empty([1]).add("bad").with(){order=cat(order,"F");return("free")};right=[1].is_empty().add("bad").with(){order=cat(order,"R");return("receiver")};return([left,right,order])}''',
      'x',
      jsonDecode(r'''["free","receiver","FR"]'''),
    );
  });
  test('valid_empty_with', () {
    check(
      'valid_empty_with',
      r'''Value:: I {order="";out=is_empty([1]).add("bad").coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}''',
      'x',
      jsonDecode(r'''[0,"W"]'''),
    );
  });
  test('with_result_array', () {
    check(
      'with_result_array',
      r'''Value:: I {order="";out=is_empty([1]).with(){order=cat(order,"W");return(["ok"])}.first().uppercase();return([out,order])}''',
      'x',
      jsonDecode(r'''["OK","W"]'''),
    );
  });
  test('all_canonical_free_with_guards', () {
    check(
      'all_canonical_free_with_guards',
      r'''Value:: I {order="";out=[is_empty([]).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},is_empty([1]).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},is_nonempty([1]).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},is_nonempty([]).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null],""]'''),
    );
  });
  test('all_short_receiver_with_guards', () {
    check(
      'all_short_receiver_with_guards',
      r'''Value:: I {order="";out=[[].is_empty().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},[1].is_empty().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},[1].is_nonempty().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},[].is_nonempty().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null],""]'''),
    );
  });
  test('function_scope', () {
    check(
      'function_scope',
      r'''fn build(){order="";left=is_empty([1]).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right=[].is_empty().take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}''',
      'x',
      jsonDecode(r'''[[null,null,""],"caller"]'''),
    );
  });
  test('needed_source_error', () {
    final actual = errorRows(
      r'''Value:: I {return(is_empty({items="text";push(items,"x")}).coalesce("masked"))}''',
      'x',
    );
    print('EMPTINESS_GUARD_ERROR needed_source_error ${jsonEncode(actual)}');
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
      r'''Value:: I {order="";out=[is_empty([]).take({order=cat(order,"A");1}),is_empty([1]).take({order=cat(order,"A");1}),is_nonempty([1]).take({order=cat(order,"A");1}),is_nonempty([]).take({order=cat(order,"A");1})];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null],""]'''),
    );
  });
  test('repeated_predicates', () {
    check(
      'repeated_predicates',
      r'''Value:: I {return([is_empty([1]).is_empty().cat("!"),is_empty([1]).is_nonempty().cat("!"),[1].is_empty().is_empty().cat("!"),[].is_empty().is_nonempty().cat("!")])}''',
      'x',
      jsonDecode(r'''["0!","1!","0!","1!"]'''),
    );
  });
  test('excluded public emptiness source shapes stay current', () {
    final observed = <Object?>[];
    for (final source in [
      r'''is_empty().take(1).with(){return("x")}''',
      r'''is_empty([],[]).take(1).with(){return("x")}''',
      r'''is_empty(value:[]).take(1)''',
      r'''is_nonempty().take(1)''',
      r'''is_nonempty([1],[2]).take(1)''',
      r'''is_nonempty(value:[1]).take(1)''',
      r'''[].is_empty(1).with(){return("x")}''',
      r'''[1].is_nonempty(1).with(){return("x")}''',
      r'''[].is_empty(value:1).with(){return("x")}''',
      r'''is_empty([]){return("x")}''',
      r'''[].is_empty(){return("x")}''',
      r'''is_empty([]).map_leaves(){return(value)}''',
      r'''[].is_empty().map_leaves(){return(value)}''',
      r'''{|| return(is_empty([]).take(1).with(){return("x")}) }''',
      r'''is_empty([]).custom_empty().with(){return("x")}''',
      r'''[].is_empty().custom_empty().with(){return("x")}''',
      r'''is_defined(undef).take(1).with(){return("x")}''',
      r'''str_eq("a","b").take(1).with(){return("x")}''',
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
    print('EMPTINESS_GUARD_SHAPES ${jsonEncode(observed)}');
  });
}
