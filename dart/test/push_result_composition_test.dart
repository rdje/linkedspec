// TYPE-REFERENCE-BOOK.1.2.23.3.58.3 — explicit push snapshots as guarded sources.
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
      'push-result-composition.spec',
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
  print('PUSH_SNAPSHOT_VALUE $label ${jsonEncode(observed)}');
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
  test('full frozen twelve-result target', () {
    String fixture(String ext) => File(
      '../tests/fixtures/push_result_selection_values.$ext',
    ).readAsStringSync();
    check('shared', fixture('spec'), 'x', jsonDecode(fixture('json')));
  });
  test('primitive_saved', () {
    check(
      'primitive_saved',
      r'''Value:: I {items=[];saved=push(items,"a");items.push_back("later");return([saved,items])}''',
      'x',
      jsonDecode(r'''[["a"],["a","later"]]'''),
    );
  });
  test('absent_empty', () {
    check(
      'absent_empty',
      r'''Value:: I {empty=push(created,"").last().coalesce("F").cat("!");missing=push(nulls,undef).last().coalesce(["a","tail"])[-1].uppercase();array=push(empties,[]).last().count().add(1);return([empty,missing,array,created,nulls,empties])}''',
      'x',
      jsonDecode(r'''["!","TAIL",1,[""],[null],[[]]]'''),
    );
  });
  test('transitions', () {
    check(
      'transitions',
      r'''Value:: I {items=[];number=push(items,[3,1]).last().sorted().last().add(4);hash=push(items,{"k":"tail"}).last().sorted_keys().last().uppercase();count=push(items,"tail").count().add(1);text=push(items,"tail").copy().last().uppercase();boolean=push(items,false).last().not();logical=push(items,"tail").is_nonempty().and(false);return([number,hash,count,text,boolean,logical,items])}''',
      'x',
      jsonDecode(
        r'''[7,"K",4,"TAIL",true,false,[[3,1],{"k":"tail"},"tail","tail",false,"tail"]]''',
      ),
    );
  });
  test('direct_guard', () {
    check(
      'direct_guard',
      r'''Value:: I {items=[];order="";out=push(items,"tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}''',
      'x',
      jsonDecode(r'''[null,["tail"],""]'''),
    );
  });
  test('selected_recovery', () {
    check(
      'selected_recovery',
      r'''Value:: I {items=[];order="";bad=push(items,false)[-1].take({order=cat(order,"A");1});out=push(items,"tail")[-1][0].coalesce(["a","tail"])[-1].uppercase();empty=push(items,"")[-1].coalesce({order=cat(order,"F");"bad"}).cat("!");return([bad,out,empty,items,order])}''',
      'x',
      jsonDecode(r'''[null,"TAIL","!",[false,"tail",""],""]'''),
    );
  });
  test('with_kinds', () {
    check(
      'with_kinds',
      r'''Value:: I {items=[];value="outer";order="";array=push(items,"a").with(){return([value,"tail"])}[-1].uppercase();hash=push(items,"b").with(){return({"k":["head","tail"]})}["k"][-1].uppercase();bad=push(items,"c").with(){return(false)}.take({order=cat(order,"A");1});boolean=push(items,"d").with(){return(false)}.coalesce(true);return([array,hash,bad,boolean,value,order,items])}''',
      'x',
      jsonDecode(
        r'''["TAIL","TAIL",null,false,"outer","",["a","b","c","d"]]''',
      ),
    );
  });
  test('source_once', () {
    check(
      'source_once',
      r'''Value:: I {items=[];order="";out=push(items,{order=cat(order,"S");return("tail")}).last().cat({items=["new"];order=cat(order,"C");return("!")}).uppercase();return([out,items,order])}''',
      'x',
      jsonDecode(r'''["TAIL!",["new"],"SC"]'''),
    );
  });
  test('function_local', () {
    check(
      'function_local',
      r'''fn pick(){items=[];out=push(items,"tail").last().uppercase();return([out,items])} Value:: I {items=["caller"];return([pick(),items])}''',
      'x',
      jsonDecode(r'''[["TAIL",["tail"]],["caller"]]'''),
    );
  });
  test('static_child', () {
    check(
      'static_child',
      r'''Top::
 I { items = ["unchanged"]; outputs = [] }
 /x/ -> Done { pushed = push(items, outputs); return([items, outputs, pushed]) }
items::
 /x/ I { return("child-result") }
Done::
 /x/
''',
      'x',
      jsonDecode(r'''[["unchanged"],["child-result"],["child-result"]]'''),
    );
  });
  test('selected String incompatible Hash consumer', () {
    check(
      'selected_string_guard',
      r'''Value:: I {items=[];order="";out=push(items,"tail")[-1].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}''',
      'x',
      [
        null,
        ['tail'],
        '',
      ],
    );
  });
  test('binding source errors precede fluent defaults', () {
    for (final entry in <String, String>{
      'primitive': 'Value:: I {items="text";return(push(items,"x"))}',
      'fluent':
          'Value:: I {items="text";return(push(items,"x").last().coalesce("masked"))}',
    }.entries) {
      final observed = errorRows(entry.value, 'x');
      print('PUSH_SNAPSHOT_ERROR ${entry.key} ${jsonEncode(observed)}');
      for (final route in observed.entries) {
        expect(
          (route.value! as Map)['error'],
          contains('binding_kind_mismatch'),
          reason: route.key,
        );
      }
    }
  });
}
