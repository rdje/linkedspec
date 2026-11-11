// TYPE-REFERENCE-BOOK.1.2.23.3.79.3 — guard Dart ordinary Array-pipeline results and preserve own source profiles.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object? Function()> routes(
  String source,
  String input,
  String functionGrammarSource,
) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(
    source,
    parserSpecSource: functionGrammarSource,
  );
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
      'array-pipeline-result-guard-assessment.spec',
    ),
  };
}

Map<String, Object?> observe(Object? Function() operation) {
  try {
    return {'value': operation()};
  } catch (error) {
    return {
      'error': error.toString(),
      'class': error.runtimeType.toString(),
      if (error is RuntimeInterpreterException)
        'diagnostic': error.diagnostic?.toJson(),
    };
  }
}

void main() {
  final root = Directory.current.parent.uri;
  final functionGrammarSource = File.fromUri(
    root.resolve(userFunctionDefinitionSpecRelativePath),
  ).readAsStringSync();
  print(
    'ARRAY_PIPELINE_DART_NORMAL_GRAMMAR ${jsonEncode({'path': userFunctionDefinitionSpecRelativePath, 'source': functionGrammarSource})}',
  );
  final cases =
      (jsonDecode(
                File.fromUri(
                  root.resolve(
                    'docs/checkpoints/array-pipeline-result-guard-dart-2026-11-11/cases.json',
                  ),
                ).readAsStringSync(),
              )
              as List)
          .cast<Map<String, dynamic>>();
  final profiles =
      jsonDecode(
            File.fromUri(
              root.resolve(
                'tests/fixtures/array_pipeline_result_guard_dart_profiles.json',
              ),
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  for (final row in cases) {
    final id = row['id'] as String;
    test(id, () {
      final actual = <String, Map<String, Object?>>{};
      for (final route in routes(
        row['source'] as String,
        row['input'] as String,
        functionGrammarSource,
      ).entries) {
        actual[route.key] = observe(route.value);
      }
      print('ARRAY_PIPELINE_DART_NORMAL $id ${jsonEncode(actual)}');
      final profile = profiles[id] as Map<String, dynamic>?;
      for (final route in actual.entries) {
        if (profile != null) {
          expect(
            profile['source'],
            row['source'],
            reason: 'frozen source identity',
          );
          expect(
            route.value,
            profile[route.key],
            reason: '${route.key} independent Dart profile',
          );
        } else {
          expect(route.value, {'value': row['expected']}, reason: route.key);
        }
        final error = row['expected_error'] as String?;
        if (error != null) {
          expect(
            route.value['error'],
            contains(error),
            reason: 'required argument error remains visible',
          );
        }
      }
    });
  }
}
