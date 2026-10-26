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
  test('complete grouped operands retain exact AST and source spans', () {
    final call = parseActionExpression(r'matches("abc",/(/)');
    expect(call, isA<ActionCallExpr>());
    final pattern = (call as ActionCallExpr).args[1].value;
    expect(pattern, isA<ActionRegexLiteralExpr>());
    expect((pattern as ActionRegexLiteralExpr).pattern, '(');
    expect(pattern.source, '/(/');
    expect(pattern.toJson()['source_span'], {'start': 14, 'end': 17});
    for (final expression in ['/(8,2)', '/ (8,2)']) {
      final division = parseActionExpression(expression);
      expect(division, isA<ActionCallExpr>());
      expect((division as ActionCallExpr).name, '/');
    }
  });
  final cases = <(String, String, Object?)>[
    ('invalid grouped helper', r'matches("abc",/(/)', false),
    ('invalid grouped receiver', r'"abc".matches(/(/).cat("!")', '0!'),
    ('invalid grouped split', r'split("abc",/(/)', <Object?>[]),
    ('invalid grouped filter', r'["abc"].filter_match(/(/)', <Object?>[]),
    ('grouped escaped delimiter', r'matches("a/b",/(a\/b)/)', true),
    ('grouped class punctuation', r'matches("(",/([()])/)', true),
    ('whitespace pattern parentheses', r'matches("ab",/ (a b) $/x)', true),
    (
      'division nested and continued',
      r'[/(8,2),/ (8,2),/(8,/(4,2)),/(8,2).add(1),num_div(8,2)]',
      [4, 4, 4, 5, 4],
    ),
    (
      'ordinary and quoted parentheses',
      r'[matches("(","\\("),"a.b".uppercase()]',
      [true, 'A.B'],
    ),
  ];
  for (final (label, expression, expected) in cases) {
    test(
      label,
      () => assertConsumers('Top:: I { return($expression) }', expected),
    );
  }
}
