// TYPE-REFERENCE-BOOK.1.2.23.3.25.3 — readonly capture result composition.
import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void assertSelection(String source, String input, Object? expected) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  final observations = <String, Object?>{};
  for (final route in <String, Object? Function()>{
    'native': () => LinkedSpecRuntimeEngine(compiled).execute(input).value,
    'restored': () =>
        LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input).value,
    'plan': () => executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      input,
      'capture-collection-selection.spec',
    ),
  }.entries) {
    try {
      observations[route.key] = route.value();
    } catch (error) {
      observations[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('CAPTURE_SELECTION_OBSERVATIONS ${jsonEncode(observations)}');
  for (final route in observations.entries) {
    expect(route.value, expected, reason: route.key);
  }
}

void main() {
  test('unchanged frozen capture target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/capture_collection_selection_values.$extension',
      ),
    ).readAsStringSync();
    assertSelection(fixture('spec'), 'name=Alpha', jsonDecode(fixture('json')));
  });
  test('capture aliases and with reject incompatible operands', () {
    assertSelection(
      r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>name)/
 /=/
 /(?<value>Alpha)/
 -> Value[1] {separator=match_text()}
 -> Value[2] {
  order="";
  a=match_groups()[-1].with() {return(value)}.take({order=cat(order,"A");1});
  b=entry_named_map()["head"].set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});
  c=match_named_map()["value"].take({order=cat(order,"C");1});
  return([a,b,c,order]);
 }''',
      'name=Alpha',
      [
        [null, null, null, ''],
      ],
    );
  });
  test('capture Strings compaction and static helper names', () {
    assertSelection(
      r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>0)(?<empty>)(?<missing>x)?/
 /=/
 /(?<value>Alpha)(?<empty>)(?<missing>x)?/
 -> Value[1] {separator=match_text()}
 -> Value[2] {
  entry_groups={|| return(["shadow"]) };
  match_map={|| return({"value":"shadow"}) };
  return([entry_groups()[0],entry_groups()[1],entry_groups()[2].coalesce("missing"),entry_map()["empty"],match_groups()[-1],match_map()["value"],entry_named_map()["head"],match_named_map()["empty"]]);
 }''',
      '0=Alpha',
      [
        ['0', '', 'missing', '', '', 'Alpha', '0', ''],
      ],
    );
  });
  test(
    'missing capture counts are guarded and legacy sources retain counts',
    () {
      assertSelection(
        r'''Top:: I {
 thunk={|| return([false,["tail"]])};
 return([entry_groups()[0].count(),entry_map()["head"].count(),match_groups()[0].count(),match_map()["value"].count(),entry_named_map()["head"].count(),match_named_map()["value"].count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),cursor_rest()[0].count(),flat([1])[9].count()]);
}''',
        'x',
        [null, null, null, null, null, null, false, 'TAIL', 0, 0, 0, 0],
      );
    },
  );
}
