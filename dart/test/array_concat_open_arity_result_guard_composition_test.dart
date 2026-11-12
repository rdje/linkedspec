// TYPE-REFERENCE-BOOK.1.2.23.3.80.3 — existing concat arity result guards.
import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';
import '../tool/callable_array_transform_observation.dart' as observation;

Object? canonical(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: canonical(value[key])};
  }
  if (value is List) {
    return value.map(canonical).toList();
  }
  return value;
}

Map<String, Object? Function()> routes(
  String id,
  String source,
  String input,
  String grammar,
  String origin,
) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(
    source,
    parserSpecSource: grammar,
  );
  final serialized = jsonEncode(parsed.toJson());
  var retained = serialized;
  final phase = Platform.environment['LINKEDSPEC_ARRAY_CONCAT_DART_CAPTURE'];
  if (phase != null) {
    if (!const {
      'before',
      'private-old',
      'private-fixed',
      'direct',
    }.contains(phase)) {
      throw StateError('unknown one-shot normal capture phase');
    }
    final target = File(
      '${Directory.current.parent.path}/.linkedspec-data/scratch/open-arity-concat-dart-normal/$phase/$id.json',
    );
    if (target.existsSync()) {
      throw StateError('normal capture input is one-shot');
    }
    target.parent.createSync(recursive: true);
    target.writeAsStringSync(serialized);
    retained = target.readAsStringSync();
    if (retained != serialized) {
      throw StateError('parsed input changed before SDK use');
    }
    print('ARRAY_CONCAT_DART_NORMAL_INPUT $id $retained');
  }
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(retained) as Map).cast<String, Object?>(),
  );
  final identityPrefix = switch (origin) {
    'legacy312' => 'array-transform-callable-result-guard',
    'ordinary4' => 'array-transform-result-guard',
    _ => 'array-concat-open-arity-result-guard',
  };
  return {
    'native': () => LinkedSpecRuntimeEngine(compiled).execute(input).value,
    'restored': () =>
        LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input).value,
    'plan': () => executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      input,
      '$identityPrefix-assessment.spec',
    ),
  };
}

void main() {
  final root = Directory.current.parent.uri;
  final grammar = File.fromUri(
    root.resolve(userFunctionDefinitionSpecRelativePath),
  ).readAsStringSync();
  print(
    'ARRAY_CONCAT_DART_NORMAL_GRAMMAR ${jsonEncode({'path': userFunctionDefinitionSpecRelativePath, 'source': grammar})}',
  );
  final cases =
      (jsonDecode(
                File.fromUri(
                  root.resolve(
                    'tests/fixtures/array_concat_open_arity_dart_cases.json',
                  ),
                ).readAsStringSync(),
              )
              as List)
          .cast<Map<String, dynamic>>();
  final profiles =
      jsonDecode(
            File.fromUri(
              root.resolve(
                'tests/fixtures/array_concat_open_arity_result_guard_dart_profiles.json',
              ),
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  for (final row in cases) {
    final id = row['id'] as String;
    test(id, () {
      final actual = <String, Map<String, Object?>>{};
      final profile = profiles[id] as Map<String, dynamic>;
      expect(
        jsonEncode(canonical(profile['case'])),
        jsonEncode(canonical(row)),
        reason: 'cold source identity',
      );
      for (final route in routes(
        id,
        row['source'] as String,
        row['input'] as String,
        grammar,
        row['origin'] as String,
      ).entries) {
        actual[route.key] = observation.observeCallableTransform(route.value);
      }
      print('ARRAY_CONCAT_DART_NORMAL $id ${jsonEncode(actual)}');
      for (final route in actual.entries) {
        expect(
          jsonEncode(canonical(route.value)),
          jsonEncode(canonical(profile[route.key])),
          reason: '${route.key} independent Dart policy/result guard',
        );
      }
    });
  }
}
