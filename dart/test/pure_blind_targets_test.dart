// TYPE-REFERENCE-BOOK.1.2.23.3.48.3.3: a blind call need not have regex slots.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  final rows = [
    ...(jsonDecode(
          File('../tests/fixtures/pure_blind_targets.json').readAsStringSync(),
        )
        as List),
    ...(jsonDecode(
          File(
            '../tests/fixtures/referenced_blind_intermediate_negatives.json',
          ).readAsStringSync(),
        )
        as List),
  ];
  for (final row in rows) {
    test('pure blind target ${row['name']}', () {
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
      final compiled = compileSpec(parsed);
      expect(compiled.rule('Child')!.regexPatterns, isEmpty);
      expect(compiled.rule('Child')!.regexSlots, isEmpty);
      final regexEntry =
          compiled.dependencyRegexState.dependencyRegexMap['Top'];
      final regexRefs = row['expected_regex_refs'] as List? ?? const [];
      if (regexRefs.isEmpty) {
        expect(regexEntry, isNull);
      } else {
        expect(regexEntry!.dependencyRefs.map((ref) => ref.label), regexRefs);
        expect(regexEntry.patterns, ['x']);
        expect(
          () => regexEntry.dependencyRefs[0] = regexEntry.dependencyRefs[0],
          throwsUnsupportedError,
        );
      }
      if (row['name'] != 'direct_control') {
        expect(
          compiled.rule('Top')!.dependencyRefs.map((ref) => ref.label),
          row['expected_call_refs'] ?? ['Child'],
        );
      }
      final restored = SpecFile.fromJson(
        (jsonDecode(jsonEncode(parsed.toJson())) as Map)
            .cast<String, Object?>(),
      );
      for (final spec in [compiled, compileSpec(restored)]) {
        final result = LinkedSpecRuntimeEngine(
          spec,
        ).execute(row['input'] as String);
        expect(result.value, row['expected']);
        expect(result.matched, isTrue);
        expect(result.cursorCharOffset, row['expected_cursor']);
      }
      expect(
        executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          row['input'] as String,
          'pure-blind-target.spec',
        ),
        row['expected'],
      );
    });
  }
  test('mixed bypass-validation action reference remains strict', () {
    final parsed = parseSpec(
      'Top::AND\n -> Child\n => Child\nChild:\n I{return("C")}\n',
    );
    expect(
      () => compileSpec(parsed, validateSource: false),
      throwsA(isA<CompiledSpecException>()),
    );
  });
  test('parent regex cannot hide a missing action slot in mixed bypass', () {
    final parsed = parseSpec(
      'Top::AND\n /x/ -> Child\n => Child\nChild:\n I{return("C")}\n',
    );
    expect(
      () => compileSpec(parsed, validateSource: false),
      throwsA(isA<CompiledSpecException>()),
    );
  });
  test('unknown blind target remains strict without source validation', () {
    final parsed = parseSpec('Top::AND\n => Missing\n');
    expect(
      () => compileSpec(parsed, validateSource: false),
      throwsA(isA<CompiledSpecException>()),
    );
  });
}
