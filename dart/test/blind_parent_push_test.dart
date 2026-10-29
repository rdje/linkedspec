// TYPE-REFERENCE-BOOK.1.2.23.3.48.3.1: blind push calls its parent.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final target in ['blind_parent_push', 'blind_parent_push_repeated']) {
    final rows =
        jsonDecode(File('../tests/fixtures/$target.json').readAsStringSync())
            as List;
    for (final row in rows) {
      test('$target ${row['name']}', () {
        final parsed = parseSpecWithStagedUserFunctionDefinitions(
          row['source'] as String,
        );
        final compiled = compileSpec(parsed);
        final restored = SpecFile.fromJson(
          (jsonDecode(jsonEncode(parsed.toJson())) as Map)
              .cast<String, Object?>(),
        );
        final input = row['input'] as String;
        for (final spec in [compiled, compileSpec(restored)]) {
          final result = LinkedSpecRuntimeEngine(spec).execute(input);
          expect(result.value, row['expected']);
          expect(result.cursorCharOffset, input.length);
        }
        expect(
          executeGeneratedParserV2(
            compiled,
            buildGeneratedRulePlan(compiled),
            input,
            'blind-parent-push.spec',
          ),
          row['expected'],
        );
      });
    }
  }
}
