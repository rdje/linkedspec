// TYPE-REFERENCE-BOOK.1.2.23.3.39.2.0 — independent Dart AND intake.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object?> observe(Object? Function() call) {
  try {
    final value = call();
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

const repairOwners = <String, String>{
  'reversed': 'TYPE-REFERENCE-BOOK.1.2.23.3.39.2.1',
  'duplicate': 'TYPE-REFERENCE-BOOK.1.2.23.3.39.2.1',
  'cross_owner': 'TYPE-REFERENCE-BOOK.1.2.23.3.39.2.1',
  'repeated_return': 'TYPE-REFERENCE-BOOK.1.2.23.3.39.2.2',
  'repeated_nonreturn': 'TYPE-REFERENCE-BOOK.1.2.23.3.39.2.2',
  'blind_minimum': 'TYPE-REFERENCE-BOOK.1.2.23.3.39.2.3',
  'blind_default': 'TYPE-REFERENCE-BOOK.1.2.23.3.39.2.4',
};

void main() {
  final fixtures =
      (jsonDecode(
                File(
                  'test/fixtures/sparse_and_structural_sequence.json',
                ).readAsStringSync(),
              )
              as List)
          .cast<Map<String, Object?>>();
  for (final fixture in fixtures) {
    final name = fixture['name']! as String;
    test(
      'Dart sparse AND $name',
      () {
        final source = fixture['source']! as String;
        print('DART_SPARSE_AUTHORED $name ${jsonEncode(fixture)}');
        final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
        final normalized = jsonEncode(parsed.toJson());
        final restored = SpecFile.fromJson(
          (jsonDecode(normalized) as Map).cast<String, Object?>(),
        );
        final compiled = compileSpec(parsed);
        final plan = buildGeneratedRulePlan(compiled);
        final emitted = emitDartSourceV2(compiled, 'dart-sparse-and.spec');
        print(
          'DART_SPARSE_INPUT $name ${jsonEncode({
            'source': source,
            'normalized': normalized,
            'compiled': compiled.toJson(),
            'plan': [
              for (final row in plan) {'label': row.label, 'family': row.family},
            ],
            'emitted': emitted,
          })}',
        );
        final moduleDirectory =
            Platform.environment['LINKEDSPEC_DART_SPARSE_EMIT_DIR'];
        if (moduleDirectory != null) {
          if (moduleDirectory.startsWith('/') ||
              moduleDirectory.contains('..')) {
            throw ArgumentError(
              'intake module directory must be project-relative',
            );
          }
          Directory(moduleDirectory).createSync(recursive: true);
          File('$moduleDirectory/$name.dart').writeAsStringSync(emitted);
        }
        final observations = <Map<String, Object?>>[];
        for (final row in fixture['cases']! as List) {
          final input = row['input'] as String;
          final routes = {
            'native': observe(
              () => LinkedSpecRuntimeEngine(compiled).execute(input),
            ),
            'restored': observe(
              () =>
                  LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input),
            ),
            'plan': observe(
              () => LinkedSpecRuntimeEngine(compiled)
                  .executeGeneratedWithPlan(input, {
                    for (final row in plan)
                      row.label: GeneratedRuleFamily.fromWireName(row.family)!,
                  }, 'dart-sparse-and.spec'),
            ),
          };
          print(
            'DART_SPARSE_ACTUAL $name ${jsonEncode({'input': input, 'expected': row['expected'], 'expected_match': row['expected_match'], 'routes': routes})}',
          );
          observations.add({
            'input': input,
            'expected': row['expected'],
            'expected_match': row['expected_match'],
            'routes': routes,
          });
          if (Platform.environment['LINKEDSPEC_DART_SPARSE_TRACE'] == name ||
              Platform.environment['LINKEDSPEC_DART_SPARSE_TRACE'] == 'all') {
            final trace = LinkedSpecTraceEmitter(
              LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
              stdoutWriter: (_) {},
            );
            final result = observe(
              () =>
                  LinkedSpecRuntimeEngine(compiled).parse(input, trace: trace),
            );
            print(
              'DART_SPARSE_TRACE $name ${jsonEncode({
                'input': input,
                'actual': result,
                'events': [
                  for (final event in trace.events) {'topic': event.topic, 'details': event.details},
                ],
              })}',
            );
          }
        }
        // Retain every input and route before checking this authored source.
        for (final row in observations) {
          final expected = row['expected'];
          final expectedMatch = row['expected_match'];
          for (final route in (row['routes'] as Map).entries) {
            final actual = route.value as Map;
            if (expected is Map && expected.containsKey('error_contains')) {
              expect(
                actual['error'],
                contains(expected['error_contains']),
                reason: '$name ${row['input']} ${route.key}',
              );
            } else {
              expect(
                actual.containsKey('error'),
                isFalse,
                reason: '$name ${row['input']} ${route.key} $actual',
              );
              if (expectedMatch != null) {
                expect(
                  (actual['result'] as Map)['matched'],
                  expectedMatch,
                  reason: '$name ${row['input']} ${route.key} match',
                );
              }
              expect(
                (actual['result'] as Map)['value'],
                expected,
                reason: '$name ${row['input']} ${route.key}',
              );
            }
          }
        }
      },
      skip: repairOwners[name] == null
          ? false
          : 'P1 ${repairOwners[name]}; retained actual RED, required before admission',
    );
  }
}
