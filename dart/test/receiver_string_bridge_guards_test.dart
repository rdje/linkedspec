// TYPE-REFERENCE-BOOK.1.2.23.3.62.6.3 — canonical receiver String-prefix bridge guards.
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
      'receiver-string-bridge-guards.spec',
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
  print('RECEIVER_BRIDGE_VALUE $label ${jsonEncode(observed)}');
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
  test('reject_bridge_with', () {
    check(
      'reject_bridge_with',
      r'''Value:: I {order="";out=" a,b ".trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('reject_bridge_without_with', () {
    check(
      'reject_bridge_without_with',
      r'''Value:: I {order="";out=" a,b ".trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('source_once', () {
    check(
      'source_once',
      r'''Value:: I {order="";out={order=cat(order,"S");return(" a,b ")}.trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('valid_selected_with', () {
    check(
      'valid_selected_with',
      r'''Value:: I {order="";out=" a,b ".trim().split(",").last().with(){order=cat(order,"W");return(value.uppercase())};return([out,order])}''',
      'x',
      jsonDecode(r'''["B","W"]'''),
    );
  });
  test('valid_empty_with', () {
    check(
      'valid_empty_with',
      r'''Value:: I {order="";out="a".trim().split(",").take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}''',
      'x',
      jsonDecode(r'''[[0,"tail"],"W"]'''),
    );
  });
  test('valid_null_with', () {
    check(
      'valid_null_with',
      r'''Value:: I {order="";out="".trim().split(",").take(0).first().with(){order=cat(order,"W");return("recovered")};return([out,order])}''',
      'x',
      jsonDecode(r'''["recovered","W"]'''),
    );
  });
  test('all_eight_prefixes', () {
    check(
      'all_eight_prefixes',
      r'''Value:: I {order="";out=[" a,b ".trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"A,B".lowercase().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"a,b".uppercase().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"a-b".replace_substr("-",",").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"prefixa,b".rm_prefix("prefix").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"a,bsuffix".rm_suffix("suffix").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"a,b!".substr(0,3).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"a".cat(",b").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(r'''[[null,null,null,null,null,null,null,null],""]'''),
    );
  });
  test('function_scope', () {
    check(
      'function_scope',
      r'''fn build(){order="";out="a,b".trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}
Value:: I {value="caller";return([build(),value])}''',
      'x',
      jsonDecode(r'''[[null,""],"caller"]'''),
    );
  });
  test('direct_rejection_with', () {
    check(
      'direct_rejection_with',
      r'''Value:: I {order="";out="tail".trim().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
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
  test('receiver_numeric_identity_remains_an_array_index', () {
    check(
      'receiver_numeric_identity_remains_an_array_index',
      r'''Value:: I {slots=["old"];index=0.rm_prefix("x").copy();slots[index]="updated";return([index,slots,false.rm_suffix("x").copy()])}''',
      'x',
      jsonDecode(r'''[0,["updated"],false]'''),
    );
  });

  test('needed source error precedes recovery', () {
    final actual = errorRows(
      r'''Value:: I {return({items="text";push(items,"x")}.trim().split(",").with(){return("masked")})}''',
      'x',
    );
    print('RECEIVER_BRIDGE_ERROR ${jsonEncode(actual)}');
    for (final route in actual.entries) {
      expect(
        (route.value! as Map)['error'],
        contains('binding_kind_mismatch'),
        reason: route.key,
      );
    }
  });
  test('public excluded receiver source shapes stay current', () {
    final observed = <Object?>[];
    for (final source in [
      r'''"tail".trim("extra").split(",").set_key("k",1).with(){return("x")}''',
      r'''"tail".cat().with(){return("x")}''',
      r'''"tail".substr(0,1,2).with(){return("x")}''',
      r'''"tail".trim(first:"extra").with(){return("x")}''',
      r'''"tail".custom_string().with(){return("x")}''',
      r'''"tail".trim().map_leaves(){return(value)}''',
      r'''{|| return("tail".trim().split(",").set_key("k",1).with(){return("x")}) }''',
      r'''"tail".substr(/a/,"x","g")''',
      r'''"tail".trim(){return("x")}''',
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
    print('RECEIVER_BRIDGE_SHAPES ${jsonEncode(observed)}');
  });
}
