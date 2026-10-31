// TYPE-REFERENCE-BOOK.1.2.23.3.61.3 — retained constructor result guards.
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
      'constructor-result-composition.spec',
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
  print('CONSTRUCTOR_VALUE $label ${jsonEncode(observed)}');
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
  test('primitive_array', () {
    check(
      'primitive_array',
      r'''Value::
 I {return(array("tail",0,false,undef,["nested"],{"k":1}))}
''',
      'x',
      jsonDecode(r'''["tail",0,false,null,["nested"],{"k":1}]'''),
    );
  });
  test('primitive_hash', () {
    check(
      'primitive_hash',
      r'''Value::
 I {return(hash("k",["head","tail"],"flag",false,"zero",0,"missing",undef))}
''',
      'x',
      jsonDecode(
        r'''{"flag":false,"k":["head","tail"],"missing":null,"zero":0}''',
      ),
    );
  });
  test('empty_and_compatible', () {
    check(
      'empty_and_compatible',
      r'''Value::
 I {a=array(3,1).sorted().last().add(4);b=hash("k","tail").sorted_keys().last().uppercase();return([array().count(),hash().count_keys(),a,b])}
''',
      'x',
      jsonDecode(r'''[0,0,7,"K"]'''),
    );
  });
  test('direct_reads', () {
    check(
      'direct_reads',
      r'''Value::
 I {a=array("head","tail")[-1].uppercase();b=hash("k",["head","tail"])["k"][-1].uppercase();return([a,b])}
''',
      'x',
      jsonDecode(r'''["TAIL","TAIL"]'''),
    );
  });
  test('array_hash_guard', () {
    check(
      'array_hash_guard',
      r'''Value::
 I {order="";out=array("tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,order])}
''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('hash_array_guard', () {
    check(
      'hash_array_guard',
      r'''Value::
 I {order="";out=hash("k","tail").take({order=cat(order,"A");1});return([out,order])}
''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('selected_guards', () {
    check(
      'selected_guards',
      r'''Value::
 I {order="";a=array(false,"tail")[0].take({order=cat(order,"A");1});b=hash("k","tail")["k"].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,b,order])}
''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('completed_bound_guards', () {
    check(
      'completed_bound_guards',
      r'''Value::
 I {order="";items=array("tail");meta=hash("k","tail");a=items.coalesce(undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=meta.coalesce(undef).take({order=cat(order,"A");1});return([a,b,items,meta,order])}
''',
      'x',
      jsonDecode(r'''[null,null,["tail"],{"k":"tail"},""]'''),
    );
  });
  test('source_order_snapshot', () {
    check(
      'source_order_snapshot',
      r'''Value::
 I {order="";items=["head","tail"];out=array({order=cat(order,"S");return(items)},["old"])[{items=["new"];order=cat(order,"I");0}][{order=cat(order,"J");-1}].cat({order=cat(order,"C");"!"}).uppercase();return([out,items,order])}
''',
      'x',
      jsonDecode(r'''["TAIL!",["new"],"SIJC"]'''),
    );
  });
  test('with_kinds', () {
    check(
      'with_kinds',
      r'''Value::
 I {value="outer";order="";a=array("head","tail").with(){return(hash("k",[value,"tail"]))}["k"][-1].uppercase();bad=hash("k","tail").with(){return(false)}.take({order=cat(order,"A");1});return([a,bad,value,order])}
''',
      'x',
      jsonDecode(r'''["TAIL",null,"outer",""]'''),
    );
  });
  test('function_scope', () {
    check(
      'function_scope',
      r'''fn pick(){items=["tail"];return(array(items,"other")[0][-1].uppercase())}
Value::
 I {items=["caller"];return([pick(),items])}
''',
      'x',
      jsonDecode(r'''["TAIL",["caller"]]'''),
    );
  });
  test('array_payload_order', () {
    check(
      'array_payload_order',
      r'''Value::
 I {order="";out=array({order=cat(order,"A");"first"},{order=cat(order,"B");"tail"}).last().uppercase();return([out,order])}
''',
      'x',
      jsonDecode(r'''["TAIL","AB"]'''),
    );
  });
  test('guard_before_with', () {
    check(
      'guard_before_with',
      r'''Value::
 I {order="";out=array("tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}
''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('valid_empty_with', () {
    check(
      'valid_empty_with',
      r'''Value::
 I {order="";out=hash().with(){order=cat(order,"W");return([value.count_keys(),"tail"])};return([out,order])}
''',
      'x',
      jsonDecode(r'''[[0,"tail"],"W"]'''),
    );
  });
  test('hash_rejection_source_once_with', () {
    check(
      'hash_rejection_source_once_with',
      r'''Value:: I {order="";out=hash({order=cat(order,"S");return("k")},"tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('array_prefix_rejection_skips_with', () {
    check(
      'array_prefix_rejection_skips_with',
      r'''Value:: I {order="";out=array("head","tail").take(1).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('valid_empty_array_prefix_with', () {
    check(
      'valid_empty_array_prefix_with',
      r'''Value:: I {order="";out=array("tail").take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}''',
      'x',
      jsonDecode(r'''[[0,"tail"],"W"]'''),
    );
  });
  test('valid_null_result_with', () {
    check(
      'valid_null_result_with',
      r'''Value:: I {order="";out=array("tail").with(){order=cat(order,"N");return(undef)}.with(){order=cat(order,"W");return("recovered")};return([out,order])}''',
      'x',
      jsonDecode(r'''["recovered","NW"]'''),
    );
  });
  test('computed_key_forms', () {
    check(
      'computed_key_forms',
      r'''Value:: I {names=["idx"];meta={"key":"field"};return([hash("k".cat("x"),1),hash(names[0],2),hash(meta["key"],3),hash({return("block")},4),hash(cat("c","all"),5)])}''',
      'x',
      jsonDecode(
        r'''[{"kx":1},{"idx":2},{"field":3},{"block":4},{"call":5}]''',
      ),
    );
  });
  test('hash_block_key_value_order_snapshot', () {
    check(
      'hash_block_key_value_order_snapshot',
      r'''Value:: I {name="old";order="";out=hash({order=cat(order,"K");return(name)},{name="new";order=cat(order,"V");return([false,0,"tail"])});return([out,name,order])}''',
      'x',
      jsonDecode(r'''[{"old":[false,0,"tail"]},"new","KV"]'''),
    );
  });
  test('hash_block_key_function_scope', () {
    check(
      'hash_block_key_function_scope',
      r'''fn build(key){return(hash({return(key)},array("tail",false)))} Value:: I {key="caller";return([build("inside"),key])}''',
      'x',
      jsonDecode(r'''[{"inside":["tail",false]},"caller"]'''),
    );
  });
  test('needed argument error precedes consumer', () {
    final observed = errorRows(
      r'''Value:: I {return(array({items="text";push(items,"x")},"tail").last().coalesce("masked"))}''',
      'x',
    );
    print('CONSTRUCTOR_ARGUMENT_ERROR ${jsonEncode(observed)}');
    for (final route in observed.entries) {
      expect(
        (route.value! as Map)['error'],
        contains('binding_kind_mismatch'),
        reason: route.key,
      );
    }
  });
  test('needed key error precedes consumer', () {
    final observed = errorRows(
      r'''Value:: I {return(hash({items="text";push(items,"x")},"tail").take(1))}''',
      'x',
    );
    print('CONSTRUCTOR_KEY_ERROR ${jsonEncode(observed)}');
    for (final route in observed.entries) {
      expect(
        (route.value! as Map)['error'],
        contains('binding_kind_mismatch'),
        reason: route.key,
      );
    }
  });
  test('public excluded source shapes stay current', () {
    final observed = <Object?>[];
    for (final source in [
      'array(items).take(1)',
      'hash(meta).take(1)',
      'hash("odd").take(1)',
      'hash(flat_array(["k",1])).take(1)',
      'array(flat_array([1,2])).set_key("k",1)',
      'array(flat_hash({"k":1})).set_key("k",1)',
      'flat_array([1,2]).set_key("k",1)',
      'custom_constructor("tail").set_key("k",1)',
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
    expect(observed, hasLength(8));
    print('CONSTRUCTOR_SHAPES ${jsonEncode(observed)}');
  });
}
