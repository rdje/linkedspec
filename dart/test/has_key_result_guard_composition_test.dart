// TYPE-REFERENCE-BOOK.1.2.23.3.69.3 — has_key source/prefix guards.
import 'dart:convert';
import 'dart:io';
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
      'presence-result-guard-composition.spec',
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
  print('PRESENCE_GUARD_VALUE $label ${jsonEncode(observed)}');
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
  test('primitive_presence', () {
    check(
      'primitive_presence',
      r'''Value:: I {return([has_key({"k":false},"k"),has_key({},"k"),has_key({"k":undef},"k"),{"k":1}.has_key("k"),{}.has_key("k")])}''',
      'x',
      jsonDecode(r'''[1,0,1,1,0]'''),
    );
  });
  test('free_container_guards', () {
    check(
      'free_container_guards',
      r'''Value:: I {order="";left=has_key({},"k").take({order=cat(order,"A");1});right=has_key({"k":1},"k").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('receiver_container_guards', () {
    check(
      'receiver_container_guards',
      r'''Value:: I {order="";left={}.has_key("k").take({order=cat(order,"A");1});right={"k":1}.has_key("k").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('free_guard_before_with', () {
    check(
      'free_guard_before_with',
      r'''Value:: I {order="";out=has_key({order=cat(order,"S");{}},{order=cat(order,"K");"k"}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"SK"]'''),
    );
  });
  test('receiver_guard_before_with', () {
    check(
      'receiver_guard_before_with',
      r'''Value:: I {order="";out={order=cat(order,"S");{}}.has_key({order=cat(order,"K");"k"}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"SK"]'''),
    );
  });
  test('free_bridge_rejection', () {
    check(
      'free_bridge_rejection',
      r'''Value:: I {order="";out=has_key({},"k").cat("x").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('receiver_bridge_rejection', () {
    check(
      'receiver_bridge_rejection',
      r'''Value:: I {order="";out={}.has_key("k").cat("x").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('compatible_values', () {
    check(
      'compatible_values',
      r'''Value:: I {return([has_key({},"k").cat("!"),has_key({},"k").coalesce_nonempty("late").cat("!"),{}.has_key("k").coalesce("late").cat("!")])}''',
      'x',
      jsonDecode(r'''["0!","0!","0!"]'''),
    );
  });
  test('value_kinds', () {
    check(
      'value_kinds',
      r'''Value:: I {return([has_key({},"k").copy(),{}.has_key("k").copy(),has_key({},"k").add(1),has_key({"k":1},"k").add(1)])}''',
      'x',
      jsonDecode(r'''[0,0,1,2]'''),
    );
  });
  test('source_key_snapshot', () {
    check(
      'source_key_snapshot',
      r'''Value:: I {order="";meta={};out=has_key({order=cat(order,"S");meta},{order=cat(order,"K");meta["k"]=1;"k"}).cat({order=cat(order,"C");meta["k"]=2;"!"});return([out,meta,order])}''',
      'x',
      jsonDecode(r'''["0!",{"k":2},"SKC"]'''),
    );
  });
  test('valid_false_with', () {
    check(
      'valid_false_with',
      r'''Value:: I {order="";out=has_key({},"k").with(){order=cat(order,"W");return([value,value.copy()])};return([out,order])}''',
      'x',
      jsonDecode(r'''[[0,0],"W"]'''),
    );
  });
  test('null_source_key_effect', () {
    check(
      'null_source_key_effect',
      r'''Value:: I {order="";out=has_key(undef,{order=cat(order,"K");"k"}).cat("!");return([out,order])}''',
      'x',
      jsonDecode(r'''["0!","K"]'''),
    );
  });
  test('needed_source_error', () {
    final actual = errorRows(
      r'''Value:: I {return(has_key({items="text";push(items,"x")},"k").coalesce("masked"))}''',
      'x',
    );
    print('PRESENCE_GUARD_ERROR needed_source_error ${jsonEncode(actual)}');
    for (final route in actual.entries) {
      final error = route.value! as Map;
      expect(
        error['error'],
        contains('binding_kind_mismatch'),
        reason: route.key,
      );
    }
  });
  test('valid_array_bridges', () {
    check(
      'valid_array_bridges',
      r'''Value:: I {return([has_key({},"k").cat(",x").split(",").last().uppercase(),{"k":1}.has_key("k").cat(",x").split(",").last().uppercase()])}''',
      'x',
      jsonDecode(r'''["X","X"]'''),
    );
  });
  test('valid_null_with', () {
    check(
      'valid_null_with',
      r'''Value:: I {order="";left=has_key({},"k").add("bad").with(){order=cat(order,"F");return("free")};right={}.has_key("k").add("bad").with(){order=cat(order,"R");return("receiver")};return([left,right,order])}''',
      'x',
      jsonDecode(r'''["free","receiver","FR"]'''),
    );
  });
  test('valid_empty_with', () {
    check(
      'valid_empty_with',
      r'''Value:: I {order="";out=has_key({},"k").add("bad").coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}''',
      'x',
      jsonDecode(r'''[0,"W"]'''),
    );
  });
  test('with_result_array', () {
    check(
      'with_result_array',
      r'''Value:: I {order="";out=has_key({},"k").with(){order=cat(order,"W");return(["ok"])}.first().uppercase();return([out,order])}''',
      'x',
      jsonDecode(r'''["OK","W"]'''),
    );
  });
  test('function_scope', () {
    check(
      'function_scope',
      r'''fn build(){order="";left=has_key({},"k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right={"k":1}.has_key("k").take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}''',
      'x',
      jsonDecode(r'''[[null,null,""],"caller"]'''),
    );
  });
  test('all_canonical_free_with_guards', () {
    check(
      'all_canonical_free_with_guards',
      r'''Value:: I {order="";out=[has_key({},"k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},has_key({"k":1},"k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},has_key({"k":false},"k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},has_key({"k":undef},"k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null],""]'''),
    );
  });
  test('all_short_receiver_with_guards', () {
    check(
      'all_short_receiver_with_guards',
      r'''Value:: I {order="";out=[{}.has_key("k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},{"k":1}.has_key("k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},{"k":false}.has_key("k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},{"k":undef}.has_key("k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null],""]'''),
    );
  });
  test('all_canonical_free_guards', () {
    check(
      'all_canonical_free_guards',
      r'''Value:: I {order="";out=[has_key({},"k").take({order=cat(order,"A");1}),has_key({"k":1},"k").take({order=cat(order,"A");1}),has_key({"k":false},"k").take({order=cat(order,"A");1}),has_key({"k":undef},"k").take({order=cat(order,"A");1})];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null],""]'''),
    );
  });
  test('repeated_predicates', () {
    check(
      'repeated_predicates',
      r'''Value:: I {return([has_key({},"k").is_empty().cat("!"),has_key({},"k").is_defined().cat("!"),{}.has_key("k").is_nonempty().cat("!"),{"k":1}.has_key("k").is_undefined().cat("!")])}''',
      'x',
      jsonDecode(r'''["0!","1!","1!","0!"]'''),
    );
  });
  test('null_source_operand_snapshot', () {
    final root = Directory.current.parent.uri;
    final source = File.fromUri(
      root.resolve('tests/fixtures/has_key_null_source_operand_values.spec'),
    ).readAsStringSync();
    final expected = jsonDecode(
      File.fromUri(
        root.resolve(
          'tests/fixtures/has_key_null_source_operand_values.perl.json',
        ),
      ).readAsStringSync(),
    );
    check('null_source_operand_snapshot', source, 'x', expected);
  });
  test('excluded public emptiness source shapes stay current', () {
    final observed = <Object?>[];
    for (final source in [
      r'''has_key().take(1).with(){return("x")}''',
      r'''has_key({}).take(1)''',
      r'''has_key({},"k","x").take(1)''',
      r'''has_key(source:{},key:"k").take(1)''',
      r'''{}.has_key().with(){return("x")}''',
      r'''{}.has_key("k","x").with(){return("x")}''',
      r'''{}.has_key(key:"k").with(){return("x")}''',
      r'''has_key({},key:"k").take(1)''',
      r'''has_key({},"k"){return("x")}''',
      r'''{}.has_key("k"){return("x")}''',
      r'''has_key({},"k").map_leaves(){return(value)}''',
      r'''{}.has_key("k").map_leaves(){return(value)}''',
      r'''{|| return(has_key({},"k").take(1).with(){return("x")}) }''',
      r'''has_key({},"k").custom_presence().with(){return("x")}''',
      r'''{}.has_key("k").custom_presence().with(){return("x")}''',
      r'''is_empty([]).take(1).with(){return("x")}''',
      r'''is_defined(undef).take(1).with(){return("x")}''',
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
    print('PRESENCE_GUARD_SHAPES ${jsonEncode(observed)}');
  });
}
