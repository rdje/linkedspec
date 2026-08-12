// FUTURE-PARITY-BACKLOG.14.4.4 — admitted Dart recursive observation.
//
// Ordinary Dart discovery and canonical CI execute this exact consumer through
// project-local data routing:
//
//   cd dart
//   bash ../tools/run_dart_project_data.sh test --reporter failures-only \
//     test/recursive_observation_contract_test.dart
//
// The implementation remains package-private and adds no Dart facade export.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

typedef _JsonObject = Map<String, Object?>;

const _authoredSource = r'''
Top::
 I {
  value = observe_recognition(observation, call(Child))
  return(array(value, observation))
 }

Child::AND
 /😀/
 E { return(false) }
''';

void main() {
  test(
    'authored form lowers once to a dedicated non-eager node and rejects static drift',
    () {
      final compiled = _compile(_authoredSource);
      final action = compiled
          .rule('Top')!
          .lifecycleActionPayloads
          .single
          .actionAst
          .toJson();
      final observation = _mapsWithKind(action, 'observe_recognition').single;
      expect(observation, containsPair('target', 'observation'));
      expect(observation, containsPair('rule', 'Child'));
      expect(
        _allMaps(
          action,
        ).where((node) => node['kind'] == 'call' && node['name'] == 'Child'),
        isEmpty,
        reason: 'call(Child) remains unevaluated observation structure',
      );
      expect(
        RegExp(
          r'"kind":"observe_recognition"',
        ).allMatches(jsonEncode(compiled.toJson())),
        hasLength(1),
        reason: 'serialized compiled form contains one dedicated node',
      );

      for (final fixture in <(String, String)>[
        (
          r'''Top:: I { value = observe_recognition(observation["nested"], call(Child)) } Child::AND /x/''',
          'source_location_recursive_observation_target',
        ),
        (
          r'''Top:: I { value = observe_recognition(observation, dynamic_child) } Child::AND /x/''',
          'source_location_recursive_observation_operand',
        ),
        (
          r'''Top:: I { value = observe_recognition(observation, call(Missing)) }''',
          'source_location_recursive_observation_operand',
        ),
        (
          r'''
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Observer))
  recognition_rollback(tx)
  return(matched)
 }
Observer:
 I { value = observe_recognition(observation, call(Child)); return(value) }
Child::AND
 /x/
''',
          'recognition_effect_forbidden:binding_write',
        ),
        (
          r'''
fn inspect() {
 value = observe_recognition(observation, call(Child))
 return(value)
}
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Observer))
  recognition_rollback(tx)
  return(matched)
 }
Observer: I { return(inspect()) }
Child::AND
 /x/
''',
          'recognition_effect_forbidden:binding_write',
        ),
      ]) {
        expect(
          () => _compile(fixture.$1),
          throwsA(predicate((error) => '$error'.contains(fixture.$2))),
          reason: 'static observation failure ${fixture.$2}',
        );
      }
    },
  );

  test(
    'native and reconstructed execution preserve false payloads and detached scalar records',
    () {
      final compiled = _compile(_authoredSource);
      final expected = <Object?>[
        false,
        _expectedObservation(
          ruleLabel: 'Child',
          invocationId: 2,
          parentInvocationId: 1,
          entryOffset: 0,
          selectedMatch: (0, 1),
          acceptedExit: 1,
          outcome: 'accepted',
        ),
      ];
      final engine = LinkedSpecRuntimeEngine(compiled);
      final first = _list(engine.parse('😀').value);
      expect(first, expected);

      final detached = _object(first[1]);
      _object(detached['entry_position'])['offset'] = 99;
      _object(detached['selected_match'])['start'] = 99;
      expect(
        engine.parse('😀').value,
        expected,
        reason: 'fresh parses restart ids and do not retain detached mutation',
      );

      final parsed = parseSpec(_authoredSource);
      final reconstructed = SpecFile.fromJson(
        _object(jsonDecode(jsonEncode(parsed.toJson()))),
      );
      validateSpec(reconstructed);
      expect(
        LinkedSpecRuntimeEngine(compileSpec(reconstructed)).parse('😀').value,
        expected,
      );
    },
  );

  test(
    'failed zero-regex and child-owned action-edge cursor semantics are exact',
    () {
      final failed = _compile(r'''
Top::
 I { value = observe_recognition(observation, call(Missing)); return(array(value, observation)) }
Missing::AND
 /z/
''');
      expect(LinkedSpecRuntimeEngine(failed).parse('x').value, <Object?>[
        null,
        _expectedObservation(
          ruleLabel: 'Missing',
          invocationId: 2,
          parentInvocationId: 1,
          entryOffset: 0,
          outcome: 'failed',
        ),
      ]);

      final zero = _compile(r'''
Top::
 I { value = observe_recognition(observation, call(Coordinator)); return(array(value, observation)) }
Coordinator:
 I { return("coordinated") }
''');
      expect(LinkedSpecRuntimeEngine(zero).parse('').value, <Object?>[
        'coordinated',
        _expectedObservation(
          ruleLabel: 'Coordinator',
          invocationId: 2,
          parentInvocationId: 1,
          entryOffset: 0,
          acceptedExit: 0,
          outcome: 'accepted',
        ),
      ]);

      final edge = _compile(r'''
Top::
 /a/ -> Top {
  value = observe_recognition(observation, call(Child))
  return(array(value, observation))
 }
Child::AND
 /b/
 /c/
 -> Child[0] { first = match_text() }
 -> Child[1] { return(array(entry_text(), entry_start_pos())) }
''');
      expect(LinkedSpecRuntimeEngine(edge).parse('abc').value, <Object?>[
        <Object?>['a', 0],
        _expectedObservation(
          ruleLabel: 'Child',
          invocationId: 2,
          parentInvocationId: 1,
          entryOffset: 1,
          selectedMatch: (2, 3),
          acceptedExit: 3,
          outcome: 'accepted',
        ),
      ]);
    },
  );

  test('direct and mutual nonprogress observations keep typed diagnostics', () {
    final nestedOrdinary = _compile(r'''
Top:: I { value = observe_recognition(observation, call(Child)); return(array(value, observation)) }
Child: I { nested = call(Child); return("guarded") }
''');
    expect(
      LinkedSpecRuntimeEngine(nestedOrdinary).parse('').value,
      <Object?>[
        'guarded',
        _expectedObservation(
          ruleLabel: 'Child',
          invocationId: 2,
          parentInvocationId: 1,
          entryOffset: 0,
          acceptedExit: 0,
          outcome: 'accepted',
        ),
      ],
      reason: 'only the pending observed entry may become a rejection',
    );

    final direct = _compile(r'''
Top:: I { value = observe_recognition(top_observation, call(DirectRecur)); return(value) }
DirectRecur: I { value = observe_recognition(observation, call(DirectRecur)); return(value) }
''');
    expect(
      () => LinkedSpecRuntimeEngine(direct).parse('x'),
      throwsA(
        predicate(
          (error) =>
              '$error'.contains('source_location_nonprogress_direct_recursion'),
        ),
      ),
    );

    final mutual = _compile(r'''
Top:: I { value = observe_recognition(top_observation, call(MutualA)); return(value) }
MutualA: I { value = observe_recognition(observation_a, call(MutualB)); return(value) }
MutualB: I { value = observe_recognition(observation_b, call(MutualA)); return(value) }
''');
    expect(
      () => LinkedSpecRuntimeEngine(mutual).parse('x'),
      throwsA(
        predicate(
          (error) =>
              '$error'.contains('source_location_nonprogress_mutual_recursion'),
        ),
      ),
    );
  });

  test('aborted observation propagates the original runtime diagnostic', () {
    final aborted = _compile(r'''
Top::
 I { value = observe_recognition(observation, call(AbortChild)); return(value) }
AbortChild:
 I { recognition_commit(missing) }
''');
    expect(
      () => LinkedSpecRuntimeEngine(aborted).parse(''),
      throwsA(
        predicate((error) => '$error'.contains('recognition_token_expected')),
      ),
    );
  });

  test('generated plan executes the same private observation runtime', () {
    final compiled = _compile(_authoredSource);
    expect(
      executeGeneratedParserV2(
        compiled,
        buildGeneratedRulePlan(compiled),
        '😀',
        'recursive-observation/dart.spec',
      ),
      <Object?>[
        false,
        _expectedObservation(
          ruleLabel: 'Child',
          invocationId: 2,
          parentInvocationId: 1,
          entryOffset: 0,
          selectedMatch: (0, 1),
          acceptedExit: 1,
          outcome: 'accepted',
        ),
      ],
    );
  });

  test(
    'independently analyzed emitted source uses the same private runtime',
    () async {
      final compiled = _compile(_authoredSource);
      final emitted = emitDartSourceV2(
        compiled,
        'recursive-observation/dart.spec',
      );
      final packageRoot = Directory.current.absolute;
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-recursive-observation-',
      );
      final pubCache = Directory('${scratch.path}/pub-cache')..createSync();
      try {
        Directory('${scratch.path}/lib').createSync();
        Directory('${scratch.path}/bin').createSync();
        File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_recursive_observation_probe
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ${jsonEncode(packageRoot.path)}
''');
        File('${scratch.path}/lib/generated.dart').writeAsStringSync(emitted);
        File('${scratch.path}/bin/main.dart').writeAsStringSync(r'''
import 'dart:convert';

import 'package:linkedspec_recursive_observation_probe/generated.dart'
    as generated;

void main() {
  print(jsonEncode(generated.execute('😀')));
}
''');
        final environment = <String, String>{
          ...Platform.environment,
          'PUB_CACHE': pubCache.path,
        };
        await _expectProcessSuccess(scratch, environment, const [
          'pub',
          'get',
          '--offline',
        ]);
        await _expectProcessSuccess(scratch, environment, const [
          'analyze',
          '--fatal-infos',
          '--fatal-warnings',
        ]);
        final run = await _expectProcessSuccess(scratch, environment, const [
          'run',
          'bin/main.dart',
        ]);
        expect(jsonDecode((run.stdout as String).trim()), <Object?>[
          false,
          _expectedObservation(
            ruleLabel: 'Child',
            invocationId: 2,
            parentInvocationId: 1,
            entryOffset: 0,
            selectedMatch: (0, 1),
            acceptedExit: 1,
            outcome: 'accepted',
          ),
        ]);
      } finally {
        scratch.deleteSync(recursive: true);
      }
    },
  );
}

_JsonObject _expectedObservation({
  required String ruleLabel,
  required int invocationId,
  required int? parentInvocationId,
  required int entryOffset,
  (int, int)? selectedMatch,
  int? acceptedExit,
  required String outcome,
  String? diagnostic,
}) => <String, Object?>{
  'source_id': 'input',
  'rule_label': ruleLabel,
  'invocation_id': invocationId,
  'parent_invocation_id': parentInvocationId,
  'entry_position': <String, Object?>{
    'source_id': 'input',
    'offset': entryOffset,
  },
  'selected_match': selectedMatch == null
      ? null
      : <String, Object?>{
          'source_id': 'input',
          'start': selectedMatch.$1,
          'end': selectedMatch.$2,
          'provenance': 'match',
        },
  'accepted_exit': acceptedExit == null
      ? null
      : <String, Object?>{'source_id': 'input', 'offset': acceptedExit},
  'outcome': outcome,
  'diagnostic': diagnostic,
};

Iterable<_JsonObject> _allMaps(Object? value) sync* {
  if (value is Map) {
    final object = value.cast<String, Object?>();
    yield object;
    for (final child in object.values) {
      yield* _allMaps(child);
    }
  } else if (value is List) {
    for (final child in value) {
      yield* _allMaps(child);
    }
  }
}

List<_JsonObject> _mapsWithKind(Object? value, String kind) => _allMaps(
  value,
).where((node) => node['kind'] == kind).toList(growable: false);

CompiledSpec _compile(String source) =>
    compileSpec(parseSpecWithStagedUserFunctionDefinitions(source));

Future<ProcessResult> _expectProcessSuccess(
  Directory workingDirectory,
  Map<String, String> environment,
  List<String> arguments,
) async {
  final result = await Process.run(
    Platform.resolvedExecutable,
    arguments,
    workingDirectory: workingDirectory.path,
    environment: environment,
  );
  expect(
    result.exitCode,
    0,
    reason:
        'dart ${arguments.join(' ')} failed:\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}',
  );
  return result;
}

_JsonObject _object(Object? value) => (value! as Map).cast<String, Object?>();

List<Object?> _list(Object? value) => (value! as List).cast<Object?>();
