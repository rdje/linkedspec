// TYPE-REFERENCE-BOOK.1.2.23.3.40.3 — unavailable versus empty capture endpoints.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  final fixtures =
      jsonDecode(
            File(
              '../tests/fixtures/capture_endpoint_absence.json',
            ).readAsStringSync(),
          )
          as List;
  for (final fixture in fixtures) {
    final name = fixture['name'] as String;
    test('Dart capture endpoint $name', () {
      final source = fixture['source'] as String;
      final input = fixture['input'] as String;
      final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
      final compiled = compileSpec(parsed);
      final restored = SpecFile.fromJson(
        (jsonDecode(jsonEncode(parsed.toJson())) as Map)
            .cast<String, Object?>(),
      );
      final results = {
        'native': LinkedSpecRuntimeEngine(compiled).execute(input),
        'restored': LinkedSpecRuntimeEngine(
          compileSpec(restored),
        ).execute(input),
      };
      for (final route in results.entries) {
        expect(route.value.value, fixture['expected'], reason: route.key);
        expect(route.value.matched, isTrue, reason: route.key);
        expect(
          route.value.cursorCharOffset,
          fixture['expected_cursor'],
          reason: route.key,
        );
      }
      expect(
        executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          input,
          'capture-endpoint-absence.spec',
        ),
        fixture['expected'],
        reason: 'plan',
      );
    });
  }
}
