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
      'string-predicate-result-receivers.spec',
    ),
    expected,
  );
}

void main() {
  test(
    'string_predicate results retain scalar kinds, shapes and operand order',
    () {
      assertConsumers(
        fixture('string_predicate_result_receiver_values', 'spec'),
        jsonDecode(fixture('string_predicate_result_receiver_values', 'json')),
      );
    },
  );
  test('literal i/m/s modes survive action and contextual helper operands', () {
    assertConsumers(
      r'''Top:: I { return([matches("ABC",/^a/i),matches("ABC",/^a/),matches("ABC",/(?i)^a/),matches(input_text(),/^b/m),matches(input_text(),/^b/),matches(input_text(),/(?m)^b/),matches(input_text(),/^a.b$/s),matches(input_text(),/^a.b$/),matches("ABC",/^a/ii),split("AXB",/x/i),["A","b"].filter_match(/a/i)]) }''',
      [
        true,
        false,
        true,
        true,
        false,
        true,
        true,
        false,
        true,
        ['A', 'B'],
        ['A'],
      ],
      input: 'a\nb',
    );
  });
  test('complete grouped regex literals precede fluent dot splitting', () {
    final literal = parseActionExpression(r'/(?s)^a.b$/');
    expect(literal, isA<ActionRegexLiteralExpr>());
    expect((literal as ActionRegexLiteralExpr).pattern, r'(?s)^a.b$');
    final division = parseActionExpression('/(8, 2)');
    expect(division, isA<ActionCallExpr>());
    expect((division as ActionCallExpr).name, '/');
    expect(
      parseActionExpression('"a.b".uppercase()'),
      isA<ActionFluentChainExpr>(),
    );
    assertConsumers(
      r'''Top:: I { return([matches(input_text(),/(?s)^a.b$/),input_text().matches(/(?s)^a.b$/).cat("!"),matches("AbC",/(Ab.C|AbC)/),/(8,2),"a.b".uppercase()]) }''',
      [true, '1!', true, 4, 'A.B'],
      input: 'a\nb',
    );
  });
}
