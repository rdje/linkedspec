// TYPE-REFERENCE-BOOK.1.2.23.3.27.3 — readonly input/cursor result composition.
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
      'input-cursor-results.spec',
    ),
  }.entries) {
    try {
      observations[route.key] = route.value();
    } catch (error) {
      observations[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('INPUT_CURSOR_OBSERVATIONS ${jsonEncode(observations)}');
  for (final route in observations.entries) {
    expect(route.value, expected, reason: route.key);
  }
}

void assertAction(String action, Object? expected) {
  final source =
      'Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /name/\n /=/\n /Alpha/\n -> Value[2] {$action}\n';
  assertSelection(source, 'name=Alpha', expected);
}

void main() {
  test('unchanged frozen reader target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/input_cursor_result_values.$extension',
      ),
    ).readAsStringSync();
    assertSelection(fixture('spec'), 'name=Alpha', jsonDecode(fixture('json')));
  });
  test('with returns actual kinds and restores scope', () {
    assertAction(
      r'''
 order="";value="outer";
 a=input_text().with() {return(value)}.take({order=cat(order,"A");1});
 b=input_len().with() {return(value)}.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
 c=input_text().with() {order=cat(order,"W");return(["a","b"])}.last().uppercase();
 d=input_len().with() {return({"k":[false]})}.sorted_values().first().first();
 return([a,b,c,d,order,value]);
''',
      [
        [null, null, "B", false, "W", "outer"],
      ],
    );
  });
  test('source operands defaults Number indices and named controls', () {
    assertAction(
      r'''
 order="";start=5;width=5;
 result=input_slice({order=cat(order,"S");start},{order=cat(order,"W");width}).coalesce({order=cat(order,"F");"bad"}).cat({order=cat(order,"C");start=0;width=4;"!"});
 items=["zero","one"];index=input_len().coalesce({order=cat(order,"F");7}).sub(10);items[index]="updated";
 a=input_text();b=input_len();c=cursor_rest();d=cursor_rest_len();
 return([result,order,start,width,items,input_slice(0,0).coalesce("late").cat("!"),a.coalesce("late").split("=")[-1].uppercase(),b.coalesce(0).add(1),c.coalesce("late").cat("!"),d.coalesce(7).add(1)]);
''',
      [
        [
          "Alpha!",
          "SWC",
          0,
          4,
          ["updated", "one"],
          "!",
          "ALPHA",
          11,
          "!",
          1,
        ],
      ],
    );
  });
  test('reader counts and legacy bound flat source shapes', () {
    assertAction(
      r'''
 thunk={|| return([false,["tail"]])};
 return([input_text().count(),input_len().count_keys(),input_text().with() {return(value)}.count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),flat([1])[9].count(),input_text("ignored").count(),input_slice(0).count()]);
''',
      [
        [null, null, null, false, "TAIL", 0, 0, 0, 0, 0],
      ],
    );
  });
}
