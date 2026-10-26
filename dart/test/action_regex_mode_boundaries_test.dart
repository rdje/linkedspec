import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

String fixture(String name, String extension) {
  final repositoryRoot = Directory.current.parent;
  return File.fromUri(
    repositoryRoot.uri.resolve('tests/fixtures/$name.$extension'),
  ).readAsStringSync();
}

void assertConsumers(String source, Object? expected, {String input = 'x'}) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final actual = LinkedSpecRuntimeEngine(compiled).execute(input).value;
  expect(actual, expected, reason: 'native: ${jsonEncode(actual)}');
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  expect(
    LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input).value,
    expected,
  );
  expect(
    executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      input,
      'action-regex-mode-boundaries.spec',
    ),
    expected,
  );
}

void main() {
  final cases = <(String, String, Object?)>[
    ('extended suffix', r'matches("ab",/^ a b $/x)', true),
    ('no extended suffix', r'matches("ab",/^ a b $/)', false),
    ('combined duplicate modes', r'matches("AB",/^ a b $/ixxi)', true),
    ('class space', r'matches("a b",/^ a [ ] b $/x)', true),
    ('escaped space', r'matches("a b",/^ a\ b $/x)', true),
    ('escaped hash', r'matches("a#b",/^ a\# b $/x)', true),
    ('non-ASCII space stays literal', 'matches("a b",/^ a\u00a0b \$/x)', false),
    ('supplementary escaped space', r'matches("🙂 #",/^ 🙂\ [#] $/x)', true),
    ('class hash', r'matches("a#b",/^ a [#] b $/x)', true),
    ('extended line comment', 'matches("ab",/^ a # ignored\n b \$/x)', true),
    ('operation modes are no-ops', r'matches("abc",/^abc$/go)', true),
    ('unknown mode fails closed', r'matches("abc",/^abc$/q)', false),
    ('mixed unknown fails closed', r'matches("ABC",/^abc$/iq)', false),
    ('invalid repeated quantifier', r'matches("abc",/a**/)', false),
    ('invalid text pattern', r'matches("abc","(")', false),
    ('unknown receiver keeps false', r'"abc".matches(/^abc$/q).cat("!")', '0!'),
    (
      'invalid receiver keeps false',
      r'"abc".matches(/a**/).coalesce_nonempty("late").cat("!")',
      '0!',
    ),
    ('extended split', r'split("aXb",/ x /ix)', ['a', 'b']),
    ('extended filter', r'["a b","ab"].filter_match(/^ a b $/x)', ['ab']),
    ('unknown split', r'split("abc",/b/q)', <Object?>[]),
    ('unknown filter', r'["abc"].filter_match(/a/q)', <Object?>[]),
    ('invalid split', r'split("abc",/a**/)', <Object?>[]),
    ('invalid filter', r'["abc"].filter_match(/a**/)', <Object?>[]),
  ];
  for (final (label, expression, expected) in cases) {
    test(label, () {
      assertConsumers('Top:: I { return($expression) }', expected);
    });
  }
  test('invalid patterns preserve source and operand effects', () {
    assertConsumers(
      r'''Top:: I { order=""; result=matches({order=cat(order,"S");"abc"},{order=cat(order,"O");"("}); return([result,order]) }''',
      [false, 'SO'],
    );
  });
}
