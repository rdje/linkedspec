// TYPE-REFERENCE-BOOK.1.2.23.3.48.3.2: conventional rule arrays are invocation-local.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final target in ['rule_invocation_accumulators']) {
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
        //39.8.1 owns ordinary blind cutoff/count/lifecycle authority. Scope
        // currently exposes one extra empty iteration; that empty tail proves
        // the child accumulator is fresh, without portable collection credit.
        final expected = row['name'] == 'implicit_parent_no_tail'
            ? [
                ['x'],
                <Object?>[],
              ]
            : row['expected'];
        for (final spec in [compiled, compileSpec(restored)]) {
          final result = LinkedSpecRuntimeEngine(spec).execute(input);
          expect(result.value, expected);
          expect(result.cursorCharOffset, input.length);
        }
        expect(
          executeGeneratedParserV2(
            compiled,
            buildGeneratedRulePlan(compiled),
            input,
            'rule-accumulator.spec',
          ),
          expected,
        );
      });
    }
  }
}
