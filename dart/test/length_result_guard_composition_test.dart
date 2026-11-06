// TYPE-REFERENCE-BOOK.1.2.23.3.74.3 — Length result/source-owner guards.
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
      'length-result-guard-composition.spec',
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
  print('LENGTH_GUARD_DART_VALUE $label ${jsonEncode(observed)}');
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
    'tests/fixtures/length_result_guard_cases.json',
    'tests/fixtures/length_count_source_ownership_cases.json',
  ]) {
    cases.addAll(
      (jsonDecode(File.fromUri(root.resolve(fixture)).readAsStringSync())
              as List)
          .cast<Map<String, dynamic>>(),
    );
  }
  final domain =
      jsonDecode(
            File.fromUri(
              root.resolve(
                'tests/fixtures/length_result_guard_dart_domain.json',
              ),
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  for (final row in cases) {
    final id = row['id'] as String;
    test(id, () {
      final expectedError = row['expected_error'] as String?;
      if (expectedError == null) {
        if (row.containsKey('perl_expected')) {
          expect(domain['id'], id);
          expect(domain['source'], row['source']);
        }
        check(
          id,
          row['source'] as String,
          row['input'] as String,
          row.containsKey('perl_expected')
              ? domain['expected']
              : row['expected'],
        );
      } else {
        final actual = errorRows(
          row['source'] as String,
          row['input'] as String,
        );
        print('LENGTH_GUARD_DART_ERROR $id ${jsonEncode(actual)}');
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
}
