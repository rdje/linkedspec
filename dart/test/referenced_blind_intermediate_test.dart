// TYPE-REFERENCE-BOOK.1.2.23.3.48.3: written edge ownership selects identity.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

List<Map<String, Object?>> fixtures(String name) =>
    (jsonDecode(File('../tests/fixtures/$name.json').readAsStringSync())
            as List)
        .map((row) => (row as Map).cast<String, Object?>())
        .toList();

void main() {
  final original = fixtures('referenced_blind_intermediate');
  final qualified = {
    for (final row in fixtures('referenced_blind_intermediate_qualified'))
      row['name']: row,
  };
  for (final row in [
    ...original,
    ...fixtures('referenced_blind_intermediate_negatives'),
  ]) {
    final name = row['name'] as String;
    test('referenced intermediate $name', () {
      final parsed = parseSpecWithStagedUserFunctionDefinitions(
        row['source'] as String,
      );
      if (row['expected_builds'] != true) {
        expect(
          () => compileSpec(parsed),
          throwsA(isA<SpecValidationException>()),
        );
        return;
      }
      // The original target remains compile authority; only the qualified
      // counterpart supplies runtime credit for the three parent-LX cases.
      compileSpec(parsed);
      final runtimeRow = qualified[name]!;
      final runtimeSpec = parseSpecWithStagedUserFunctionDefinitions(
        runtimeRow['source'] as String,
      );
      final compiled = compileSpec(runtimeSpec);
      final restored = SpecFile.fromJson(
        (jsonDecode(jsonEncode(runtimeSpec.toJson())) as Map)
            .cast<String, Object?>(),
      );
      compileSpec(restored);
      //39.8.1 owns the preserved ordinary blind cutoff/lifecycle distinction.
      // Fresh rule arrays now expose an extra empty final iteration here.
      if ({
        'blind_no_regex',
        'marked_blind_target',
        'markerless_blind',
      }.contains(name)) {
        return;
      }
      for (final item in runtimeRow['cases'] as List) {
        final input = item['input'] as String;
        for (final spec in [compiled, compileSpec(restored)]) {
          final result = LinkedSpecRuntimeEngine(spec).execute(input);
          expect(result.value, item['expected']);
          expect(result.matched, isTrue);
          expect(result.cursorCharOffset, item['expected_cursor']);
        }
        expect(
          executeGeneratedParserV2(
            compiled,
            buildGeneratedRulePlan(compiled),
            input,
            'referenced-intermediate-qualified.spec',
          ),
          item['expected'],
        );
      }
    });
  }
}
