// TYPE-REFERENCE-BOOK.1.2.23.3.30.3 — frozen Number reader composition.
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
      'entry-match-number-results.spec',
    ),
  };
}

void check(String source, String input, Object? expected) {
  for (final route in routes(source, input).entries) {
    final actual = route.value();
    print('NUMBER_READER ${route.key} ${jsonEncode(actual)}');
    expect(actual, expected, reason: route.key);
  }
}

String action(String action) =>
    'Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {$action}\n';
void main() {
  test('unchanged frozen Number target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/entry_match_number_result_values.$extension',
      ),
    ).readAsStringSync();
    check(fixture('spec'), 'name=Alpha', jsonDecode(fixture('json')));
  });
  test('absent match uses one lazy fallback', () {
    check(
      'Top:: I {order="";return([match_len().coalesce({order=cat(order,"F");7}).add(1),order])}',
      'x',
      [8, 'F'],
    );
  });
  test('Number getter function fence stays specific', () {
    for (final route in routes(
      'fn forbidden(){return(entry_len())}\nTop:: I {return(forbidden())}',
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
  test('legacy first consumers and normalized prefixes retain their policy', () {
    final source = action(
      'order="";result=match_len().add(0).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([match_len().set_key("k",1),entry_len().take(1),result,order]);',
    );
    check(source, 'name=Alpha', [
      [5, <Object?>[], null, ''],
    ]);
  });
}
