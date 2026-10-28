// TYPE-REFERENCE-BOOK.1.2.23.3.39.2.3 — ordinary minimum misses.
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

void main() {
  final fixtures =
      (jsonDecode(
                File(
                  'test/fixtures/minimum_miss_routes.json',
                ).readAsStringSync(),
              )
              as List)
          .cast<Map<String, Object?>>();
  for (final fixture in fixtures) {
    final name = fixture['name']! as String;
    test('Dart ordinary minimum $name', () {
      final source = fixture['source']! as String;
      print('DART_MINIMUM_AUTHORED $name ${jsonEncode(fixture)}');
      final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
      final normalized = jsonEncode(parsed.toJson());
      final restored = SpecFile.fromJson(
        (jsonDecode(normalized) as Map).cast<String, Object?>(),
      );
      final compiled = compileSpec(parsed);
      final plan = buildGeneratedRulePlan(compiled);
      final emitted = emitDartSourceV2(compiled, 'dart-minimum.spec');
      print(
        'DART_MINIMUM_INPUT $name ${jsonEncode({
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
          Platform.environment['LINKEDSPEC_DART_MINIMUM_EMIT_DIR'];
      if (moduleDirectory != null) {
        if (moduleDirectory.startsWith('/') || moduleDirectory.contains('..')) {
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
            () => LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input),
          ),
          'plan': observe(
            () => LinkedSpecRuntimeEngine(compiled)
                .executeGeneratedWithPlan(input, {
                  for (final row in plan)
                    row.label: GeneratedRuleFamily.fromWireName(row.family)!,
                }, 'dart-minimum.spec'),
          ),
        };
        print(
          'DART_MINIMUM_ACTUAL $name ${jsonEncode({'input': input, 'expected': row['expected'], 'expected_match': row['expected_match'], 'expected_cursor': row['expected_cursor'], 'routes': routes})}',
        );
        observations.add({
          'input': input,
          'expected': row['expected'],
          'expected_match': row['expected_match'],
          'expected_cursor': row['expected_cursor'],
          'routes': routes,
        });
        if (Platform.environment['LINKEDSPEC_DART_MINIMUM_TRACE'] == name ||
            Platform.environment['LINKEDSPEC_DART_MINIMUM_TRACE'] == 'all') {
          final trace = LinkedSpecTraceEmitter(
            LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
            stdoutWriter: (_) {},
          );
          final result = observe(
            () => LinkedSpecRuntimeEngine(compiled).parse(input, trace: trace),
          );
          print(
            'DART_MINIMUM_TRACE $name ${jsonEncode({
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
            expect(
              (actual['diagnostic'] as Map)['code'],
              expected['error_code'],
            );
            expect(
              (actual['diagnostic'] as Map)['rule_label'],
              expected['error_rule'],
            );
          } else {
            expect(
              actual.containsKey('error'),
              isFalse,
              reason: '$name ${row['input']} ${route.key} $actual',
            );
            expect(
              (actual['result'] as Map)['cursor_code_unit'],
              row['expected_cursor'],
              reason: '$name ${row['input']} ${route.key} cursor',
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
    });
  }
}
