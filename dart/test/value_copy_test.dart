import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

String fixture(String extension) => File.fromUri(
  Directory.current.parent.uri.resolve(
    'tests/fixtures/value_copy_values.$extension',
  ),
).readAsStringSync();

void assertCopy(String source, Object? expected, {String input = 'x'}) {
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
      'value-copy.spec',
    ),
  }.entries) {
    try {
      observations[route.key] = route.value();
    } catch (error) {
      observations[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('COPY_OBSERVATIONS ${jsonEncode(observations)}');
  for (final route in observations.entries) {
    expect(
      route.value,
      expected,
      reason: '${route.key}: ${jsonEncode(route.value)}',
    );
  }
}

void main() {
  test('primitive value-copy kinds sources scopes and continuations', () {
    assertCopy(fixture('spec'), jsonDecode(fixture('json')));
  });
  test('copied containers guard actual kind before operands', () {
    assertCopy(
      r'''Top:: I {
      order="";
      a=copy({"a":1}).take({order=cat(order,"A");1});
      b=copy([1]).set_key({order=cat(order,"K");"a"},{order=cat(order,"V");2});
      return([a,b,order]);
    }''',
      [null, null, ''],
    );
  });
  test('copy method shape rejects before source and operands', () {
    assertCopy(
      r'''Top:: I {
      order="";
      a={order=cat(order,"S");false}.copy({order=cat(order,"A");1});
      b={order=cat(order,"R");[1]}.copy(fail("must-not-run"));
      return([a,b,order]);
    }''',
      [null, null, ''],
    );
  });
  test('legacy rule accumulator and String payload stay distinct', () {
    assertCopy(
      'Top::\n -> Item .push\n LX.return([copy(Top),copy("Top")])\n\nItem: /x/ I.return("x")\n',
      [
        ['x', 'x'],
        'Top',
      ],
      input: 'xx',
    );
  });
}
