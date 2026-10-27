// TYPE-REFERENCE-BOOK.1.2.23.3.31.3 — ordinary eager with result composition.
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
      'with-hash-results.spec',
    ),
  };
}

void check(String source, String input, Object? expected) {
  for (final route in routes(source, input).entries) {
    final actual = route.value();
    print('WITH_RESULT ${route.key} ${jsonEncode(actual)}');
    expect(actual, expected, reason: route.key);
  }
}

String action(String action) =>
    'Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {$action}\n';
void main() {
  test('distinct nested Hash results preserve value scopes', () {
    check(
      action(r'''
value="outer";order="";
result="outside".with(){inner="inside".with(){order=cat(order,"I");return({"k":[value]})}.sorted_values().first().first();order=cat(order,"O");return({"k":[value,inner]});}.sorted_values().first();
return([result,value,order]);
'''),
      'name=Alpha',
      [
        [
          ['outside', 'inside'],
          'outer',
          'IO',
        ],
      ],
    );
  });

  test('unchanged frozen with Hash target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/with_hash_result_values.$extension',
      ),
    ).readAsStringSync();
    check(fixture('spec'), 'name=Alpha', jsonDecode(fixture('json')));
  });
  test('helper and receiver actual kinds skip incompatible operands', () {
    check(
      action(r'''
order="";value="outer";
a={order=cat(order,"S");"source"}.with(){order=cat(order,"W");return(3)}.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
b="source".with(){return("text")}.take({order=cat(order,"A");1});
c="source".with(){return(["a","b"])}.last().uppercase();
d="source".with(){return(false)}.coalesce({order=cat(order,"F");true});
e="source".with(){return(null)}.coalesce({order=cat(order,"N");7}).add(1);
f=with("source"){return(3)}.set_key({order=cat(order,"J");"k"},{order=cat(order,"L");1});
g=with("source"){return("text")}.take({order=cat(order,"T");1});
return([a,b,c,d,e,f,g,order,value]);
'''),
      'name=Alpha',
      [
        [null, null, 'B', false, 8, null, null, 'SWN', 'outer'],
      ],
    );
  });
  test('pure function keeps scoped with value', () {
    check(
      'fn pure(text){return(text.with(){return({"n":[value.uppercase()]})}.sorted_values().first().first())}\nTop:: I {return(pure("ok"))}',
      'x',
      'OK',
    );
  });
  test('indexed with body retains specific function fence', () {
    for (final route in routes(
      'fn forbidden(){return("x".with(){return({"n":[entry_len()]})}.sorted_values().first()[0].uppercase())}\nTop:: I {return(forbidden())}',
      'x',
    ).entries) {
      expect(
        route.value,
        throwsA(
          predicate<Object>(
            (error) =>
                error.toString().contains('parser-state helper') &&
                error.toString().contains('entry_len'),
          ),
        ),
        reason: route.key,
      );
    }
  });
}
