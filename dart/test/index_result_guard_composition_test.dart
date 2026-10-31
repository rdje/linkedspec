// TYPE-REFERENCE-BOOK.1.2.23.3.72.3 — index_of source/prefix guards.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object? Function()> routes(String source, String input) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  return {
    'native': () => LinkedSpecRuntimeEngine(compiled).execute(input).value,
    'restored': () =>
        LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input).value,
    'plan': () => executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      input,
      'index-result-guard-composition.spec',
    ),
  };
}

void check(String label, String source, String input, Object? expected) {
  final observed = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      observed[route.key] = {'ok': route.value()};
    } catch (error) {
      observed[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('INDEX_GUARD_VALUE $label ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    expect(row.value, {'ok': expected}, reason: row.key);
  }
}

Map<String, Object?> errorRows(String source, String input) {
  final actual = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      actual[route.key] = {'value': route.value()};
    } catch (error) {
      actual[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
        if (error is RuntimeInterpreterException)
          'diagnostic': error.diagnostic?.toJson(),
      };
    }
  }
  return actual;
}

void main() {
  final root = Directory.current.parent.uri;
  final cases = <Map<String, dynamic>>[];
  for (final fixture in <String>[
    'tests/fixtures/index_result_guard_cases.json',
    'tests/fixtures/index_null_prefix_guard_cases.json',
    'tests/fixtures/index_null_with_guard_cases.json',
  ]) {
    cases.addAll(
      (jsonDecode(File.fromUri(root.resolve(fixture)).readAsStringSync())
              as List)
          .cast<Map<String, dynamic>>(),
    );
  }
  for (final row in cases) {
    final id = row['id'] as String;
    test(id, () {
      final expectedError = row['expected_error'] as String?;
      if (expectedError == null) {
        check(
          id,
          row['source'] as String,
          row['input'] as String,
          row.containsKey('expected_nonperl')
              ? row['expected_nonperl']
              : row['expected'],
        );
      } else {
        final actual = errorRows(
          row['source'] as String,
          row['input'] as String,
        );
        print('INDEX_GUARD_ERROR $id ${jsonEncode(actual)}');
        expect(actual.keys.toSet(), {'native', 'restored', 'plan'});
        for (final route in actual.entries) {
          expect(
            (route.value as Map)['error'],
            contains(expectedError),
            reason: route.key,
          );
        }
      }
    });
  }
  test('excluded public source shapes stay current', () {
    final rows =
        jsonDecode(
              File.fromUri(
                root.resolve(
                  'tests/fixtures/index_result_guard_excluded_ast.json',
                ),
              ).readAsStringSync(),
            )
            as List;
    final observed = <Object?>[];
    for (final row in rows) {
      final source = (row as Map)['source'] as String;
      try {
        observed.add({
          'source': source,
          'ast': parseActionExpression(source).toJson(),
        });
      } catch (error) {
        observed.add({
          'source': source,
          'error': error.toString(),
          'class': error.runtimeType.toString(),
        });
      }
    }
    expect(observed, hasLength(18));
    print('INDEX_GUARD_SHAPES ${jsonEncode(observed)}');
  });
}
