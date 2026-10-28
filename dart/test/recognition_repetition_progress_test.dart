// TYPE-REFERENCE-BOOK.1.2.23.3.39.2.6 — actual recognition progress.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/runtime/recognition_transaction.dart';
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
      if (error is RecognitionTransactionException)
        'error_record': error.toJson(),
      if (error is RuntimeInterpreterException)
        'diagnostic': error.diagnostic?.toJson(),
    };
  }
}

void main() {
  final fixtures =
      (jsonDecode(
                File(
                  'test/fixtures/recognition_repetition_progress.json',
                ).readAsStringSync(),
              )
              as List)
          .cast<Map<String, Object?>>();
  for (final fixture in fixtures) {
    final name = fixture['name']! as String;
    test('Dart live progress $name', () {
      final source = fixture['source']! as String;
      print('DART_LIVE_PROGRESS_AUTHORED $name ${jsonEncode(fixture)}');
      final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
      final normalized = jsonEncode(parsed.toJson());
      final restored = SpecFile.fromJson(
        (jsonDecode(normalized) as Map).cast<String, Object?>(),
      );
      final compiled = compileSpec(parsed);
      final plan = buildGeneratedRulePlan(compiled);
      final emitted = emitDartSourceV2(compiled, 'dart-live-progress.spec');
      print(
        'DART_LIVE_PROGRESS_INPUT $name ${jsonEncode({
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
          Platform.environment['LINKEDSPEC_DART_LIVE_PROGRESS_EMIT_DIR'];
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
        final expected = row['expected'];
        final trace = expected is Map && expected.containsKey('error_record')
            ? LinkedSpecTraceEmitter(
                LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.low),
                stdoutWriter: (_) {},
              )
            : null;
        final native = observe(
          () => LinkedSpecRuntimeEngine(compiled).execute(input, trace: trace),
        );
        if (trace != null) {
          native['progress_trace'] = [
            for (final event in trace.events)
              if (event.topic ==
                  'dart_runtime:recognition_repetition_progress_failure')
                event.details,
          ];
        }
        final routes = {
          'native': native,
          'restored': observe(
            () => LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input),
          ),
          'plan': observe(
            () => LinkedSpecRuntimeEngine(compiled)
                .executeGeneratedWithPlan(input, {
                  for (final row in plan)
                    row.label: GeneratedRuleFamily.fromWireName(row.family)!,
                }, 'dart-live-progress.spec'),
          ),
        };
        print(
          'DART_LIVE_PROGRESS_ACTUAL $name ${jsonEncode({'input': input, 'expected': row['expected'], 'expected_match': row['expected_match'], 'routes': routes})}',
        );
        observations.add({
          'input': input,
          'expected': row['expected'],
          'expected_match': row['expected_match'],
          'routes': routes,
        });
        if (Platform.environment['LINKEDSPEC_DART_LIVE_PROGRESS_TRACE'] ==
                name ||
            Platform.environment['LINKEDSPEC_DART_LIVE_PROGRESS_TRACE'] ==
                'all') {
          final trace = LinkedSpecTraceEmitter(
            LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
            stdoutWriter: (_) {},
          );
          final result = observe(
            () => LinkedSpecRuntimeEngine(compiled).parse(input, trace: trace),
          );
          print(
            'DART_LIVE_PROGRESS_TRACE $name ${jsonEncode({
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
          if (expected is Map && expected.containsKey('error_record')) {
            final record = expected['error_record'] as Map;
            expect(actual['error'], contains(record['code']));
            final diagnostic = actual['diagnostic'] as Map?;
            expect(diagnostic, isNotNull);
            expect(diagnostic?['code'], record['code']);
            expect(diagnostic?['rule_label'], record['rule']);
            expect(diagnostic?['stage'], 'runtime_execution');
            if (route.key == 'native') {
              expect(actual['progress_trace'], [
                'code=${record['code']} rule=${record['rule']} '
                    'origin=${record['origin']} start_offset=${record['start_offset']} '
                    'end_offset=${record['end_offset']}',
              ]);
            }
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
    });
  }
}
