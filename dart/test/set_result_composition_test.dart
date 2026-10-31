// TYPE-REFERENCE-BOOK.1.2.23.3.59.3 — canonical set stored results as guarded sources.
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
      'set-result-composition.spec',
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
  print('SET_RESULT_VALUE $label ${jsonEncode(observed)}');
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
  test('full frozen twelve-result set target', () {
    String fixture(String ext) => File(
      '../tests/fixtures/set_result_selection_values.$ext',
    ).readAsStringSync();
    check('shared', fixture('spec'), 'x', jsonDecode(fixture('json')));
  });
  test('existing_primitives_and_compatible_methods', () {
    check(
      'existing_primitives_and_compatible_methods',
      r'''Value:: I {a=set(text," tail ").trim().uppercase();b=set(items,[3,1]).sorted().first();c=set(meta,{"k":"tail"});d=set(flag,false).not();e=set(number,0).add(1);f=set(absent,undef).coalesce("M");return([a,b,c,d,e,f,text,items,meta,flag,number,absent])}''',
      'x',
      jsonDecode(
        r'''["TAIL",1,{"k":"tail"},true,1,"M"," tail ",[3,1],{"k":"tail"},false,0,null]''',
      ),
    );
  });
  test('existing_completed_value_read', () {
    check(
      'existing_completed_value_read',
      r'''Value:: I {saved=set(items,["tail"]);out=saved.coalesce(undef)[-1].uppercase();return([out,items])}''',
      'x',
      jsonDecode(r'''["TAIL",["tail"]]'''),
    );
  });
  test('direct_incompatible_consumers_skip_operands', () {
    check(
      'direct_incompatible_consumers_skip_operands',
      r'''Value:: I {order="";out=set(items,["tail"]).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}''',
      'x',
      jsonDecode(r'''[null,["tail"],""]'''),
    );
  });
  test('selected_guards_empty_defaults_and_noncontainer_recovery', () {
    check(
      'selected_guards_empty_defaults_and_noncontainer_recovery',
      r'''Value:: I {order="";bad=set(flag,false)[0].coalesce(false).take({order=cat(order,"A");1});text=set(word,"tail")[0].coalesce(["a","tail"])[-1].uppercase();empty=set(blank,"").coalesce({order=cat(order,"F");"bad"}).cat("!");return([bad,text,empty,flag,word,blank,order])}''',
      'x',
      jsonDecode(r'''[null,"TAIL","!",false,"tail","",""]'''),
    );
  });
  test('source_once_before_consumer_rebinding_and_local_returns', () {
    check(
      'source_once_before_consumer_rebinding_and_local_returns',
      r'''Value:: I {order="";out=set(items,{order=cat(order,"S");return(["tail"])}).last().cat({items=["new"];order=cat(order,"C");return("!")}).uppercase();return([out,items,order])}''',
      'x',
      jsonDecode(r'''["TAIL!",["new"],"SC"]'''),
    );
  });
  test('with_actual_kinds_preserves_outer_value', () {
    check(
      'with_actual_kinds_preserves_outer_value',
      r'''Value:: I {value="outer";order="";a=set(text,"source").with(){return([value,"tail"])}[-1].uppercase();b=set(meta,{}).with(){return({"k":["head","tail"]})}["k"][-1].uppercase();bad=set(flag,false).with(){return(false)}.take({order=cat(order,"A");1});return([a,b,bad,value,order,text,meta,flag])}''',
      'x',
      jsonDecode(r'''["TAIL","TAIL",null,"outer","","source",{},false]'''),
    );
  });
  test('function_local_set_source_and_selectors_keep_caller_scope', () {
    check(
      'function_local_set_source_and_selectors_keep_caller_scope',
      r'''fn pick(){items=["old"];order="";out=set(items,["a","tail"])[{order=cat(order,"I");-1}].uppercase();return([out,items,order])} Value:: I {items=["caller"];order="outer";return([pick(),items,order])}''',
      'x',
      jsonDecode(r'''[["TAIL",["a","tail"],"I"],["caller"],"outer"]'''),
    );
  });
  test('set_preserves_existing_first_class_codeblock_values', () {
    check(
      'set_preserves_existing_first_class_codeblock_values',
      r'''Value:: I {saved=set(thunk,{|| return("tail")});return([thunk(),saved()])}''',
      'x',
      jsonDecode(r'''["tail","tail"]'''),
    );
  });
  test('selected_bool_skips_array_operand', () {
    check(
      'selected_bool_skips_array_operand',
      r'''Value:: I {order="";out=set(items,[false])[0].take({order=cat(order,"A");1});return([out,items,order])}''',
      'x',
      jsonDecode(r'''[null,[false],""]'''),
    );
  });
  test('selected_string_skips_hash_operands', () {
    check(
      'selected_string_skips_hash_operands',
      r'''Value:: I {order="";out=set(items,["tail"])[0].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}''',
      'x',
      jsonDecode(r'''[null,["tail"],""]'''),
    );
  });
  test('source RHS error precedes default', () {
    final observed = errorRows(
      r'''Value:: I {return(set(target,{items="text";push(items,"x")}).coalesce("masked"))}''',
      'x',
    );
    print('SET_RESULT_ERROR ${jsonEncode(observed)}');
    for (final route in observed.entries) {
      expect(
        (route.value! as Map)['error'],
        contains('binding_kind_mismatch'),
        reason: route.key,
      );
    }
  });
  test('public source shapes and alias provenance stay current', () {
    final alias = parseActionExpression('=(items,["tail"])') as ActionCallExpr;
    expect(alias.sourceMethod ?? alias.name, '=');
    final observed = <Object?>[alias.toJson()];
    for (final source in [
      'set()',
      'set(items)',
      'set(items,["tail"],99)',
      'set(["items"],"tail")',
      'set(items,"tail"){return("x")}[0]',
      'set(items,["tail"])[-1]="x"',
      '{|| return(set(items,["tail"])[-1])}',
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
    print('SET_RESULT_SHAPES ${jsonEncode(observed)}');
  });
}
