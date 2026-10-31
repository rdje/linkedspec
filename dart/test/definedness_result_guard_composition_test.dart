// TYPE-REFERENCE-BOOK.1.2.23.3.67.3 — definedness source/prefix guards.
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
      'definedness-result-guard-composition.spec',
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
  print('DEFINEDNESS_GUARD_VALUE $label ${jsonEncode(observed)}');
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
  test('primitive_definedness', () {
    check(
      'primitive_definedness',
      r'''Value:: I {return([[is_defined(0),is_defined(undef),is_undefined(undef),is_undefined(0)],[0.is_defined(),undef.is_defined(),undef.is_undefined(),0.is_undefined()]])}''',
      'x',
      jsonDecode(r'''[[true,false,true,false],[true,false,true,false]]'''),
    );
  });
  test('defined_domains', () {
    check(
      'defined_domains',
      r'''Value:: I {return([is_defined(false),is_defined(0),is_defined(""),is_defined([]),is_defined({}),is_undefined(false),is_undefined(0),is_undefined(""),is_undefined([]),is_undefined({})])}''',
      'x',
      jsonDecode(
        r'''[true,true,true,true,true,false,false,false,false,false]''',
      ),
    );
  });
  test('compatible_values', () {
    check(
      'compatible_values',
      r'''Value:: I {return([is_defined(0).cat("!"),is_defined(undef).coalesce_nonempty("late").cat("!"),0.is_undefined().cat("!"),is_defined(undef).coalesce("late").cat("!")])}''',
      'x',
      jsonDecode(r'''["1!","0!","0!","0!"]'''),
    );
  });
  test('value_kinds', () {
    check(
      'value_kinds',
      r'''Value:: I {return([is_defined(undef).copy(),undef.is_defined().copy(),is_defined(undef).add(1),is_defined(0).add(1)])}''',
      'x',
      jsonDecode(r'''[false,false,null,null]'''),
    );
  });
  test('free_container_guards', () {
    check(
      'free_container_guards',
      r'''Value:: I {order="";left=is_defined(undef).take({order=cat(order,"A");1});right=is_undefined(undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('receiver_container_guards', () {
    check(
      'receiver_container_guards',
      r'''Value:: I {order="";left=undef.is_defined().take({order=cat(order,"A");1});right=undef.is_undefined().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('free_guard_before_with', () {
    check(
      'free_guard_before_with',
      r'''Value:: I {order="";out=is_defined({order=cat(order,"S");return(false)}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('receiver_guard_before_with', () {
    check(
      'receiver_guard_before_with',
      r'''Value:: I {order="";out={order=cat(order,"S");return(false)}.is_defined().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('free_bridge_rejection', () {
    check(
      'free_bridge_rejection',
      r'''Value:: I {order="";out=is_defined(undef).cat("x").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('receiver_bridge_rejection', () {
    check(
      'receiver_bridge_rejection',
      r'''Value:: I {order="";out=undef.is_defined().cat("x").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('valid_array_bridges', () {
    check(
      'valid_array_bridges',
      r'''Value:: I {return([is_defined(undef).cat(",x").split(",").last().uppercase(),undef.is_undefined().cat(",x").split(",").last().uppercase()])}''',
      'x',
      jsonDecode(r'''["X","X"]'''),
    );
  });
  test('source_snapshot', () {
    check(
      'source_snapshot',
      r'''Value:: I {value=0;order="";out=is_defined({order=cat(order,"S");return(value)}).cat({value=undef;order=cat(order,"C");"!"});return([out,value,order])}''',
      'x',
      jsonDecode(r'''["1!",null,"SC"]'''),
    );
  });
  test('valid_false_and_true_with', () {
    check(
      'valid_false_and_true_with',
      r'''Value:: I {order="";left=is_defined(undef).with(){order=cat(order,"F");return([value,value.copy()])};right=0.is_defined().with(){order=cat(order,"R");return(value)};return([left,right,order])}''',
      'x',
      jsonDecode(r'''[[false,false],true,"FR"]'''),
    );
  });
  test('valid_null_with', () {
    check(
      'valid_null_with',
      r'''Value:: I {order="";left=is_defined(undef).add("bad").with(){order=cat(order,"F");return("free")};right=undef.is_defined().add("bad").with(){order=cat(order,"R");return("receiver")};return([left,right,order])}''',
      'x',
      jsonDecode(r'''["free","receiver","FR"]'''),
    );
  });
  test('valid_empty_with', () {
    check(
      'valid_empty_with',
      r'''Value:: I {order="";out=is_defined(undef).add("bad").coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}''',
      'x',
      jsonDecode(r'''[0,"W"]'''),
    );
  });
  test('with_result_array', () {
    check(
      'with_result_array',
      r'''Value:: I {order="";out=is_defined(undef).with(){order=cat(order,"W");return(["ok"])}.first().uppercase();return([out,order])}''',
      'x',
      jsonDecode(r'''["OK","W"]'''),
    );
  });
  test('all_canonical_free_with_guards', () {
    check(
      'all_canonical_free_with_guards',
      r'''Value:: I {order="";out=[is_defined(0).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},is_defined(undef).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},is_undefined(undef).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},is_undefined(0).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null],""]'''),
    );
  });
  test('all_short_receiver_with_guards', () {
    check(
      'all_short_receiver_with_guards',
      r'''Value:: I {order="";out=[0.is_defined().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},undef.is_defined().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},undef.is_undefined().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},0.is_undefined().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null],""]'''),
    );
  });
  test('function_scope', () {
    check(
      'function_scope',
      r'''fn build(){order="";left=is_defined(undef).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right=0.is_defined().take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}''',
      'x',
      jsonDecode(r'''[[null,null,""],"caller"]'''),
    );
  });
  test('needed_source_error', () {
    final actual = errorRows(
      r'''Value:: I {return(is_defined({items="text";push(items,"x")}).coalesce("masked"))}''',
      'x',
    );
    print('DEFINEDNESS_GUARD_ERROR needed_source_error ${jsonEncode(actual)}');
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
      r'''Value:: I {order="";out=[is_defined(0).take({order=cat(order,"A");1}),is_defined(undef).take({order=cat(order,"A");1}),is_undefined(undef).take({order=cat(order,"A");1}),is_undefined(0).take({order=cat(order,"A");1})];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null],""]'''),
    );
  });
  test('excluded public definedness source shapes stay current', () {
    final observed = <Object?>[];
    for (final source in [
      r'''is_defined().take(1).with(){return("x")}''',
      r'''is_defined(undef,0).take(1).with(){return("x")}''',
      r'''is_defined(value:undef).take(1)''',
      r'''is_undefined().take(1)''',
      r'''is_undefined(0,undef).take(1)''',
      r'''is_undefined(value:0).take(1)''',
      r'''undef.is_defined(1).with(){return("x")}''',
      r'''0.is_undefined(1).with(){return("x")}''',
      r'''undef.is_defined(value:1).with(){return("x")}''',
      r'''is_defined(undef){return("x")}''',
      r'''undef.is_defined(){return("x")}''',
      r'''is_defined(undef).map_leaves(){return(value)}''',
      r'''undef.is_defined().map_leaves(){return(value)}''',
      r'''{|| return(is_defined(undef).take(1).with(){return("x")}) }''',
      r'''is_defined(undef).custom_definedness().with(){return("x")}''',
      r'''undef.is_defined().custom_definedness().with(){return("x")}''',
      r'''str_eq("a","a").take(1).with(){return("x")}''',
      r'''and(false).take(1).with(){return("x")}''',
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
    print('DEFINEDNESS_GUARD_SHAPES ${jsonEncode(observed)}');
  });
}
