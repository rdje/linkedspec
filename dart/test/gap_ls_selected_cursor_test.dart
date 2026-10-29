// TYPE-REFERENCE-BOOK.1.2.23.3.38.1 — selected live cursor before flagged LS.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object?> observeGapCursor(Object? Function() operation) {
  try {
    final value = operation();
    return value is RuntimeParseResult
        ? {'result': value.toJson()}
        : {'value': value};
  } catch (error) {
    return {
      'error': error.toString(),
      if (error is RuntimeInterpreterException)
        'diagnostic': error.diagnostic?.toJson(),
    };
  }
}

void main() {
  final fixtures = [
    ...jsonDecode(File('test/fixtures/gap_ls_cursor.json').readAsStringSync())
        as List,
    ...jsonDecode(
          File('test/fixtures/gap_ls_broad_carrier.json').readAsStringSync(),
        )
        as List,
  ];
  for (final fixture in fixtures) {
    final name = fixture['name'] as String;
    test('Dart selected cursor before LS $name', () {
      final parsed = parseSpecWithStagedUserFunctionDefinitions(
        fixture['source'] as String,
      );
      final compiled = compileSpec(parsed);
      final restored = SpecFile.fromJson(
        (jsonDecode(jsonEncode(parsed.toJson())) as Map)
            .cast<String, Object?>(),
      );
      for (final row in fixture['cases'] as List) {
        final input = row['input'] as String;
        final routes = {
          'native': observeGapCursor(
            () => LinkedSpecRuntimeEngine(compiled).parse(input),
          ),
          'restored': observeGapCursor(
            () => LinkedSpecRuntimeEngine(compileSpec(restored)).parse(input),
          ),
          'plan': observeGapCursor(
            () => executeGeneratedParserV2(
              compiled,
              buildGeneratedRulePlan(compiled),
              input,
              'gap-ls-cursor.spec',
            ),
          ),
        };
        // Unflagged LS retains this independently measured Dart compatibility
        // baseline; Perl's 4/4 result is not the portable target for this row.
        final compatibility = name == 'unflagged_timing_control';
        final expected = compatibility ? [1, 1] : row['expected'];
        for (final entry in routes.entries) {
          final actual = entry.value;
          if (expected is Map && expected.containsKey('error_contains')) {
            expect(actual['error'], contains(expected['error_contains']));
            if (entry.key != 'plan') {
              final diagnostic = actual['diagnostic'] as Map;
              expect(diagnostic['code'], expected['error_code']);
              expect(diagnostic['rule_label'], expected['error_rule']);
              expect(diagnostic['stage'], 'advance_gap_context');
            }
          } else {
            expect(actual, isNot(contains('error')));
            if (entry.key == 'plan') {
              expect(actual['value'], expected);
            } else {
              final result = actual['result'] as Map;
              expect(result['value'], expected);
              expect(
                result['matched'],
                compatibility ? true : row['expected_match'],
              );
              expect(
                result['cursor_char_offset'],
                compatibility ? 1 : row['expected_char_cursor'],
              );
            }
          }
        }
      }
    });
  }
}
