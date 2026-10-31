// TYPE-REFERENCE-BOOK.1.2.23.3.60.3 — canonical free-default actual-kind result guards.
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
      'free-default-result-composition.spec',
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
  print('FREE_DEFAULT_VALUE $label ${jsonEncode(observed)}');
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
  test('scalar_primitives', () {
    check(
      'scalar_primitives',
      r'''Value::
 I {return([coalesce(undef,"tail"),coalesce("","late"),coalesce(0,7),coalesce(false,true),coalesce(undef,undef),coalesce_nonempty("",0,"late"),coalesce_nonempty(undef,false,"late"),coalesce_nonempty(undef,"")])}
''',
      'x',
      jsonDecode(r'''["tail","",0,false,null,0,false,null]'''),
    );
  });
  test('scalar_compatible', () {
    check(
      'scalar_compatible',
      r'''Value::
 I {return([coalesce(undef," tail ").trim().uppercase(),coalesce_nonempty("",0).add(1),coalesce(false,true).not(),coalesce_nonempty(undef,"tail").cat("!")])}
''',
      'x',
      jsonDecode(r'''["TAIL",1,true,"tail!"]'''),
    );
  });
  test('scalar_string_guards', () {
    check(
      'scalar_string_guards',
      r'''Value::
 I {order="";a=coalesce(undef,"tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=coalesce_nonempty("","tail").take({order=cat(order,"A");1});return([a,b,order])}
''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('scalar_number_bool_guards', () {
    check(
      'scalar_number_bool_guards',
      r'''Value::
 I {order="";a=coalesce(undef,0).take({order=cat(order,"A");1});b=coalesce_nonempty(undef,false).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,b,order])}
''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('container_compatible', () {
    check(
      'container_compatible',
      r'''Value::
 I {return([coalesce(undef,["head","tail"])[-1].uppercase(),coalesce_nonempty(undef,{"k":"tail"}).sorted_keys().last().uppercase(),coalesce([],"late").count(),coalesce_nonempty({},"late").count_keys()])}
''',
      'x',
      jsonDecode(r'''["TAIL","K",0,0]'''),
    );
  });
  test('container_guards', () {
    check(
      'container_guards',
      r'''Value::
 I {order="";a=coalesce(["tail"],undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=coalesce_nonempty({"k":"tail"},undef).take({order=cat(order,"A");1});return([a,b,order])}
''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('completed_bound_guards', () {
    check(
      'completed_bound_guards',
      r'''Value::
 I {order="";saved=coalesce(undef,["tail"]);meta=coalesce_nonempty("",{"k":"tail"});a=saved.coalesce(undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=meta.coalesce(undef).take({order=cat(order,"A");1});return([a,b,saved,meta,order])}
''',
      'x',
      jsonDecode(r'''[null,null,["tail"],{"k":"tail"},""]'''),
    );
  });
  test('selected_guard', () {
    check(
      'selected_guard',
      r'''Value::
 I {order="";a=coalesce(undef,["tail"])[0].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,order])}
''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('lazy_order_and_snapshot', () {
    check(
      'lazy_order_and_snapshot',
      r'''Value::
 I {order="";items=["head","tail"];out=coalesce({order=cat(order,"S");undef},{order=cat(order,"D");items},{order=cat(order,"L");"late"})[{items=["new"];order=cat(order,"I");-1}].cat({order=cat(order,"C");"!"}).uppercase();return([out,items,order])}
''',
      'x',
      jsonDecode(r'''["TAIL!",["new"],"SDIC"]'''),
    );
  });
  test('skip_unused_failure', () {
    check(
      'skip_unused_failure',
      r'''Value::
 I {order="";a=coalesce("",{items="text";push(items,"x")}).cat("!");b=coalesce_nonempty(0,{items="text";push(items,"x")}).add(1);return([a,b,order])}
''',
      'x',
      jsonDecode(r'''["!",1,""]'''),
    );
  });
  test('with_kinds_and_outer_scope', () {
    check(
      'with_kinds_and_outer_scope',
      r'''Value::
 I {value="outer";order="";a=coalesce(undef,"tail").with(){return({"k":[value,"tail"]})}["k"][-1].uppercase();bad=coalesce_nonempty("","tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([a,bad,value,order])}
''',
      'x',
      jsonDecode(r'''["TAIL",null,"outer",""]'''),
    );
  });
  test('function_scope', () {
    check(
      'function_scope',
      r'''fn pick(){order="";items=["head","tail"];out=coalesce({order=cat(order,"S");undef},{order=cat(order,"D");items},{order=cat(order,"L");"late"})[{items=["new"];order=cat(order,"I");-1}].cat({order=cat(order,"C");"!"}).uppercase();return([out,items,order])}
Value::
 I {items=["caller"];order="outer";return([pick(),items,order])}
''',
      'x',
      jsonDecode(r'''[["TAIL!",["new"],"SDIC"],["caller"],"outer"]'''),
    );
  });
  test('valid_null_with_runs', () {
    check(
      'valid_null_with_runs',
      r'''Value:: I {order="";out=coalesce(undef,undef).with(){order=cat(order,"W");return("recovered")};return([out,order])}''',
      'x',
      jsonDecode(r'''["recovered","W"]'''),
    );
  });
  test('valid_empty_array_with_runs', () {
    check(
      'valid_empty_array_with_runs',
      r'''Value:: I {order="";out=coalesce(["tail"],undef).take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}''',
      'x',
      jsonDecode(r'''[[0,"tail"],"W"]'''),
    );
  });
  test('rejection_skips_with_after_source_once', () {
    check(
      'rejection_skips_with_after_source_once',
      r'''Value:: I {order="";out=coalesce_nonempty({order=cat(order,"S");""},"tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('valid_with_preserves_outer_value', () {
    check(
      'valid_with_preserves_outer_value',
      r'''Value:: I {value="outer";out=coalesce(undef,"tail").with(){return(value.cat("!"))};return([out,value])}''',
      'x',
      jsonDecode(r'''["tail!","outer"]'''),
    );
  });
  test('named_nonempty_container_guards', () {
    check(
      'named_nonempty_container_guards',
      r'''Value:: I {order="";items=["tail"];meta={"k":"tail"};a=items.coalesce_nonempty({order=cat(order,"F");"late"}).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=meta.coalesce_nonempty({order=cat(order,"F");"late"}).take({order=cat(order,"A");1});return([a,b,items,meta,order])}''',
      'x',
      jsonDecode(r'''[null,null,["tail"],{"k":"tail"},""]'''),
    );
  });
  test('needed default failure precedes recovery', () {
    final observed = errorRows(
      r'''Value:: I {return(coalesce(undef,{items="text";push(items,"x")}).coalesce("masked"))}''',
      'x',
    );
    print('FREE_DEFAULT_ERROR ${jsonEncode(observed)}');
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
      'coalesce().take(1)',
      'coalesce("tail").take(1)',
      'coalesce(first:"tail",second:undef).take(1)',
      'coalesce_nonempty("","tail"){return("x")}.take(1)',
      '(coalesce(undef,"tail")).take(1)',
      'thunk().take(1)',
      'coalesce(undef,["tail"])[-1]="x"',
      '{|| return(coalesce(undef,"tail").take(1)) }',
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
    print('FREE_DEFAULT_SHAPES ${jsonEncode(observed)}');
  });
}
