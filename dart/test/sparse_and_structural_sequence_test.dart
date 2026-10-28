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
  test(
    'Dart required-step observations retain one identity per actual hit',
    () {
      final observations = <String, Object?>{};
      for (final name in ['duplicate_one_slot', 'cross_distinct_indices']) {
        final row = fixtures.singleWhere((row) => row['name'] == name);
        final source = row['source']! as String;
        final input = name == 'duplicate_one_slot' ? 'aa' : 'cat';
        final compiled = compileSpec(
          parseSpecWithStagedUserFunctionDefinitions(source),
        );
        final plan = buildGeneratedRulePlan(compiled);
        for (final generated in [false, true]) {
          final events = <RuntimeSemanticObservationEvent>[];
          final trace = LinkedSpecTraceEmitter(
            LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.high),
            stdoutWriter: (_) {},
          );
          final result = generated
              ? LinkedSpecRuntimeEngine(compiled).executeGeneratedWithPlan(
                  input,
                  {
                    for (final row in plan)
                      row.label: GeneratedRuleFamily.fromWireName(row.family)!,
                  },
                  'dart-and-steps.spec',
                  trace: trace,
                  semanticObservationSink: events.add,
                )
              : LinkedSpecRuntimeEngine(compiled).execute(
                  input,
                  trace: trace,
                  semanticObservationSink: events.add,
                );
          observations['$name/$generated'] = {
            'source': source,
            'value': result.value,
            'slots': [
              for (final event in events)
                if (event.eventKind ==
                    RuntimeSemanticObservationEventKind.regexSlotSelected)
                  event.toJson(),
            ],
            'trace': [
              for (final event in trace.events)
                if (event.topic == 'dart_runtime:regex_slot_selected')
                  event.details,
            ],
          };
        }
      }
      print('DART_AND_STEPS_OBSERVATION ${jsonEncode(observations)}');
      for (final item in observations.entries) {
        final duplicate = item.key.startsWith('duplicate_one_slot/');
        final actual = item.value as Map<String, Object?>;
        expect(actual['value'], duplicate ? [2, 1] : ['cat', 'cat', 3]);
        final slots = (actual['slots'] as List).cast<Map<String, Object?>>();
        expect(
          slots.map((row) => row['position']).toList(),
          duplicate ? [1, 2] : [3],
        );
        expect(
          slots.map((row) => row['target_rule']).toList(),
          duplicate ? ['Value', 'Value'] : ['Part'],
        );
        expect(
          slots.map((row) => row['regex_index']).toList(),
          duplicate ? [0, 0] : [1],
        );
        final trace = (actual['trace'] as List).cast<String>();
        expect(trace, hasLength(duplicate ? 2 : 1));
        for (final selected in trace) {
          expect(
            selected,
            contains(
              duplicate
                  ? 'target_rule=Value regex_index=0'
                  : 'target_rule=Part regex_index=1',
            ),
          );
        }
      }
    },
  );
}
