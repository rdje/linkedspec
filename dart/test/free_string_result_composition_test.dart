// TYPE-REFERENCE-BOOK.1.2.23.3.62.3 — canonical free String result guards.
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
      'free-string-result-composition.spec',
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
  print('FREE_STRING_VALUE $label ${jsonEncode(observed)}');
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
  test('primitive_values', () {
    check(
      'primitive_values',
      r'''Value:: I {return([trim(" tail "),lowercase("TAIL"),uppercase("tail"),replace_substr("a-b","-",","),rm_prefix(0,"x"),rm_suffix(false,"x"),substr("head",1,2),cat("a","b")])}''',
      'x',
      jsonDecode(r'''["tail","tail","TAIL","a,b",0,false,"ea","ab"]'''),
    );
  });
  test('compatible_values', () {
    check(
      'compatible_values',
      r'''Value:: I {return([trim(" tail ").uppercase(),replace_substr("a-b","-",",").split(",").last().uppercase(),rm_prefix(0,"x").add(1),rm_suffix(false,"x").cat("!")])}''',
      'x',
      jsonDecode(r'''["TAIL","B",1,"0!"]'''),
    );
  });
  test('free_container_guards', () {
    check(
      'free_container_guards',
      r'''Value:: I {order="";left=trim("tail").take({order=cat(order,"A");1});right=uppercase("tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('receiver_container_guards', () {
    check(
      'receiver_container_guards',
      r'''Value:: I {order="";left="tail".trim().take({order=cat(order,"A");1});right="tail".uppercase().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('bound_guarded_bridge', () {
    check(
      'bound_guarded_bridge',
      r'''Value:: I {order="";saved=trim("tail");out=saved.coalesce(undef).take({order=cat(order,"A");1});return([out,saved,order])}''',
      'x',
      jsonDecode(r'''[null,"tail",""]'''),
    );
  });
  test('valid_null_with', () {
    check(
      'valid_null_with',
      r'''Value:: I {order="";out=trim(undef).with(){order=cat(order,"W");return("recovered")};return([out,order])}''',
      'x',
      jsonDecode(r'''["recovered","W"]'''),
    );
  });
  test('guard_before_with', () {
    check(
      'guard_before_with',
      r'''Value:: I {order="";out=trim({order=cat(order,"S");return("tail")}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('source_order_snapshot', () {
    check(
      'source_order_snapshot',
      r'''Value:: I {value=" tail ";order="";out=replace_substr({order=cat(order,"S");return(value)},{value="other";order=cat(order,"O");" "},{order=cat(order,"N");"_"}).cat({order=cat(order,"C");"!"});return([out,value,order])}''',
      'x',
      jsonDecode(r'''["_tail_!","other","SONC"]'''),
    );
  });
  test('all_free_guard_sources', () {
    check(
      'all_free_guard_sources',
      r'''Value:: I {order="";out=[trim("tail").take({order=cat(order,"A");1}),lowercase("TAIL").take({order=cat(order,"A");1}),uppercase("tail").take({order=cat(order,"A");1}),replace_substr("a-b","-",",").take({order=cat(order,"A");1}),rm_prefix(0,"x").take({order=cat(order,"A");1}),rm_suffix(false,"x").take({order=cat(order,"A");1}),substr("tail",0,1).take({order=cat(order,"A");1}),cat("t","ail").take({order=cat(order,"A");1})];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null,null,null,null,null],""]'''),
    );
  });
  test('function_scope', () {
    check(
      'function_scope',
      r'''fn build(){order="";out=trim("tail").take({order=cat(order,"A");1});return([out,order])}
Value:: I {value="caller";return([build(),value])}''',
      'x',
      jsonDecode(r'''[[null,""],"caller"]'''),
    );
  });
  test('free_bridge_rejection', () {
    check(
      'free_bridge_rejection',
      r'''Value:: I {order="";out=trim(" a,b ").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('valid_empty_bridge_with', () {
    check(
      'valid_empty_bridge_with',
      r'''Value:: I {order="";out=trim(" a,b ").split(",").take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}''',
      'x',
      jsonDecode(r'''[[0,"tail"],"W"]'''),
    );
  });
  test('valid_null_after_bridge_with', () {
    check(
      'valid_null_after_bridge_with',
      r'''Value:: I {order="";out=trim("").split(",").take(0).first().with(){order=cat(order,"W");return("recovered")};return([out,order])}''',
      'x',
      jsonDecode(r'''["recovered","W"]'''),
    );
  });
  test('legacy_named_empty_fallback', () {
    check(
      'legacy_named_empty_fallback',
      r'''Value:: I {items="text";return([take(items,1),sorted_values(items)])}''',
      'x',
      jsonDecode(r'''[[],[]]'''),
    );
  });
  test('numeric_identity_remains_an_array_index', () {
    check(
      'numeric_identity_remains_an_array_index',
      r'''Value:: I {slots=["old"];index=rm_prefix(0,"x").copy();slots[index]="updated";return([index,slots,rm_suffix(false,"x").copy()])}''',
      'x',
      jsonDecode(r'''[0,["updated"],false]'''),
    );
  });

  test('needed source error precedes recovery', () {
    final observed = errorRows(
      r'''Value:: I {return(trim({items="text";push(items,"x")}).coalesce("masked"))}''',
      'x',
    );
    print('FREE_STRING_ERROR ${jsonEncode(observed)}');
    for (final route in observed.entries) {
      expect(
        (route.value! as Map)['error'],
        contains('binding_kind_mismatch'),
        reason: route.key,
      );
    }
  });
  test('receiver-only context is observed independently', () {
    final observed = errorRows(
      r'''Value:: I {order="";out=" a,b ".trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
    );
    print('FREE_STRING_CONTEXT ${jsonEncode(observed)}');
    expect(observed, hasLength(3));
    for (final route in observed.values.skip(1)) {
      expect(route, observed.values.first);
    }
  });
  test('public excluded source shapes stay current', () {
    final observed = <Object?>[];
    for (final source in [
      'trim().take(1)',
      'trim("x","y").take(1)',
      'cat("x").take(1)',
      'cat().take(1)',
      'substr("abc",0,1,2).take(1)',
      'trim(value=>"x").take(1)',
      'trim("x"){return("tail")}.take(1)',
      'custom_string("tail").take(1)',
      '{|| return(trim("tail").take(1)) }',
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
    expect(observed, hasLength(9));
    print('FREE_STRING_SHAPES ${jsonEncode(observed)}');
  });
}
