// FUTURE-PARITY-BACKLOG.10.5.0.2.2 — exact downstream Dart label identity.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/cli/primary_cli.dart';
import 'package:test/test.dart';

final Map<String, Object?> _contract =
    jsonDecode(
          File(
            '../capability_conformance/unicode_rule_label_contract.json',
          ).readAsStringSync(),
        )
        as Map<String, Object?>;

final List<Map<String, Object?>> _positiveFixtures = [
  for (final fixture
      in (_contract['positive_fixtures']! as List).cast<Map<String, Object?>>())
    Map<String, Object?>.from(fixture),
];

final List<String> _positiveLabels = [
  for (final fixture in _positiveFixtures) fixture['label']! as String,
];

final List<Map<String, Object?>> _distinctFixtures = [
  for (final fixture
      in (_contract['distinct_fixtures']! as List).cast<Map<String, Object?>>())
    Map<String, Object?>.from(fixture),
];

final List<String> _allLabels = <String>{
  ..._positiveLabels,
  for (final fixture in _distinctFixtures) fixture['left']! as String,
  for (final fixture in _distinctFixtures) fixture['right']! as String,
}.toList(growable: false);

final String _source = _sourceForLabels(_allLabels);

void main() {
  test('every positive and distinct label survives compiled artifacts', () {
    expect(_positiveLabels, hasLength(9));
    expect(_distinctFixtures, hasLength(2));

    final parsed = parseSpec(_source);
    validateSpec(parsed);
    final compiled = compileSpec(parsed);
    final compiledJson = compiled.toJson();
    final descriptor = compiled.toDescriptorJson();
    final plan = buildGeneratedRulePlan(compiled);

    expect(parsed.rules.map((rule) => rule.header.label), _allLabels);
    expect(compiled.definitionOrder, _allLabels);
    expect(compiled.compiledRuleOrder, _allLabels);
    expect(compiled.rulesByLabel.keys, _allLabels);
    expect(
      (compiledJson['rules_by_label']! as Map<String, Object?>).keys,
      _allLabels,
    );
    expect((descriptor['spec']! as Map<String, Object?>).keys, _allLabels);
    final descriptorMeta = descriptor['meta']! as Map<String, Object?>;
    expect(descriptorMeta['definition_order'], _allLabels);
    expect(descriptorMeta['compiled_rule_order'], _allLabels);
    expect(plan.map((row) => row.label), _allLabels);

    final reconstructed = compileSpec(
      SpecFile.fromJson(
        Map<String, Object?>.from(
          jsonDecode(jsonEncode(parsed.toJson())) as Map,
        ),
      ),
    );
    expect(reconstructed.toJson(), compiledJson);
    expect(reconstructed.toDescriptorJson(), descriptor);

    for (final label in _allLabels) {
      expect(compiled.rule(label)?.label, label);
      expect(
        LinkedSpecRuntimeEngine(
          reconstructed,
        ).execute('x', topRule: label).value,
        label,
      );
      expect(
        executeGeneratedParserV2(
          compiled,
          plan,
          'x',
          'unicode-label/direct-plan.spec',
          topRule: label,
        ),
        label,
      );
    }

    for (final fixture in _distinctFixtures) {
      final left = fixture['left']! as String;
      final right = fixture['right']! as String;
      expect(left, isNot(right), reason: fixture['id']! as String);
      expect(compiled.rule(left), isNotNull);
      expect(compiled.rule(right), isNotNull);
      expect(compiled.rule(left), isNot(same(compiled.rule(right))));
    }
  });

  test(
    'emitted source reconstructs and executes every exact label',
    () async {
      const identity = 'unicode-label/emitted-規則-𐐀.spec';
      final compiled = compileSpec(parseSpec(_source));
      final emitted = emitDartSourceV2(compiled, identity);
      final encodedPayload = RegExp(
        "const _compiledSpecJsonBase64 = '([^']+)';",
      ).firstMatch(emitted)![1]!;
      final payload =
          jsonDecode(
                utf8.decode(
                  base64Decode(encodedPayload),
                  allowMalformed: false,
                ),
              )
              as Map<String, Object?>;
      final reconstructed = compileSpec(SpecFile.fromJson(payload));
      expect(reconstructed.compiledRuleOrder, _allLabels);
      expect(
        buildGeneratedRulePlan(reconstructed).map((row) => row.label),
        _allLabels,
      );

      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-unicode-label-emitted-',
      );
      final packageRoot = Directory.current.absolute;
      final pubCache = Directory('${scratch.path}/pub-cache')..createSync();
      addTearDown(() {
        if (scratch.existsSync()) {
          scratch.deleteSync(recursive: true);
        }
      });

      Directory('${scratch.path}/lib').createSync();
      Directory('${scratch.path}/bin').createSync();
      File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_unicode_label_emitted_probe
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ${jsonEncode(packageRoot.path)}
''');
      File('${scratch.path}/lib/generated.dart').writeAsStringSync(emitted);
      File('${scratch.path}/bin/main.dart').writeAsStringSync('''
import 'dart:convert';

import 'package:linkedspec_unicode_label_emitted_probe/generated.dart'
    as generated;

void main() {
  final labels = <String>[${_allLabels.map(jsonEncode).join(', ')}];
  final plan = generated.plan();
  generated.validatePlan(plan);
  final values = <Object?>[
    for (final label in labels) generated.execute('x', topRule: label),
  ];
  print(jsonEncode({
    'identity': generated.metadata().sourceIdentity,
    'labels': labels,
    'plan': [for (final row in plan) row.label],
    'values': values,
  }));
}
''');

      final environment = {...Platform.environment, 'PUB_CACHE': pubCache.path};
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
      expect(jsonDecode((run.stdout as String).trim()), {
        'identity': identity,
        'labels': _allLabels,
        'plan': _allLabels,
        'values': _allLabels,
      });
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test('strict loading and primary commands preserve every exact label', () {
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-unicode-label-primary-',
    );
    addTearDown(() {
      if (scratch.existsSync()) {
        scratch.deleteSync(recursive: true);
      }
    });
    final specFile = File('${scratch.path}/unicode.spec')
      ..writeAsBytesSync(utf8.encode(_source));
    final loaded = loadAndCompileSpec(
      SpecRequest.path(specFile.path),
      SpecLoadOptions(cwd: scratch),
    );

    expect(loaded.loaded.sourceText, _source);
    expect(loaded.compiled.compiledRuleOrder, _allLabels);
    for (final label in _allLabels) {
      expect(loaded.createEngine().execute('x', topRule: label).value, label);
      final inline = runLinkedSpecDartPrimaryCli([
        '--inline-spec',
        _source,
        '--input',
        'x',
        '--top-rule',
        label,
      ]);
      expect(inline.exitCode, 0, reason: label);
      expect(inline.stderrBytes, isEmpty, reason: label);
      expect(
        inline.stdoutBytes,
        utf8.encode('${jsonEncode(label)}\n'),
        reason: label,
      );
    }

    final supplementary =
        _positiveFixtures.singleWhere(
              (fixture) => fixture['id'] == 'supplementary',
            )['label']!
            as String;
    final fileRoute = runLinkedSpecDartPrimaryCli(
      [
        '--spec-file',
        specFile.path,
        '--input',
        'x',
        '--top-rule',
        supplementary,
      ],
      workingDirectory: scratch,
      repositoryRoot: Directory('..'),
    );
    expect(fileRoute.exitCode, 0);
    expect(fileRoute.stderrBytes, isEmpty);
    expect(
      fileRoute.stdoutBytes,
      utf8.encode('${jsonEncode(supplementary)}\n'),
    );
  });

  test('selectors diagnostics and traces retain exact Unicode identity', () {
    final selected =
        _distinctFixtures.singleWhere(
              (fixture) => fixture['id'] == 'normalization_sensitive',
            )['right']!
            as String;
    const missing = '規則Missing𐐀';
    const identity = 'unicode-label/diagnostic-規則.spec';
    final compiled = compileSpec(parseSpec(_source));
    final engine = LinkedSpecRuntimeEngine(compiled);
    final plan = buildGeneratedRulePlan(compiled);
    final stdout = StringBuffer();
    final trace = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
      stdoutWriter: stdout.write,
    );

    expect(
      engine.execute('x', topRule: selected, trace: trace).value,
      selected,
    );
    expect(
      trace.events.any(
        (event) =>
            event.topic == 'dart_runtime:entry_rule_selection' &&
            event.details.contains('requested=$selected') &&
            event.details.contains('effective=$selected') &&
            event.details.contains('basis=explicit_selector'),
      ),
      isTrue,
    );
    expect(trace.lines.join(), contains('top_rule=$selected'));
    expect(stdout.toString(), contains(selected));

    final nativeFailure = _runtimeFailure(
      () => engine.execute('x', topRule: missing, trace: trace),
    );
    expect(nativeFailure.diagnostic?.toJson(), {
      'type': 'runtime_parser',
      'stage': 'select_entry_rule',
      'owner_stage': 'dart_runtime',
      'summary': 'Dart runtime entry-rule selection failed',
      'detail': "entry rule '$missing' is not defined",
      'code': 'entry_rule_not_found',
      'top_rule': missing,
      'entry_rule': missing,
      'rule_label': missing,
      'handler_source_label': 'dart_runtime:rule:$missing',
    });
    expect(trace.lines.join(), contains('requested=$missing'));

    expect(
      () => executeGeneratedParserV2(
        compiled,
        plan,
        'x',
        identity,
        topRule: missing,
      ),
      throwsA(
        isA<GeneratedSourceException>().having(
          (error) => error.toJson(),
          'portable generated selector diagnostic',
          {
            'type': 'generated_source_error',
            'stage': 'select_entry_rule',
            'code': 'entry_rule_not_found',
            'summary': 'Generated Dart parser entry-rule selection failed',
            'source_identity': identity,
            'entry_rule': missing,
            'rule_label': missing,
            'detail': "entry rule '$missing' is not defined",
          },
        ),
      ),
    );

    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-unicode-label-trace-',
    );
    addTearDown(() {
      if (scratch.existsSync()) {
        scratch.deleteSync(recursive: true);
      }
    });
    final traceFile = File('${scratch.path}/generated.trace');
    expect(
      executeGeneratedParserWithTraceV2(
        compiled,
        plan,
        'x',
        LinkedSpecTraceConfig(
          level: LinkedSpecTraceLevel.debug,
          traceFile: traceFile.path,
          sinkMode: LinkedSpecTraceSinkMode.route,
          resetFile: true,
        ),
        identity,
        topRule: selected,
      ),
      selected,
    );
    final generatedTrace = traceFile.readAsStringSync();
    expect(generatedTrace, contains('requested=$selected'));
    expect(generatedTrace, contains('effective=$selected'));
    expect(generatedTrace, contains('top_rule=$selected'));
    expect(generatedTrace, contains(identity));
  });
}

String _sourceForLabels(List<String> labels) {
  final source = StringBuffer();
  for (var index = 0; index < labels.length; index += 1) {
    final label = labels[index];
    source
      ..writeln('$label${index == 0 ? '::' : ':'}')
      ..writeln(' /x/')
      ..writeln(' E { return(${jsonEncode(label)}) }')
      ..writeln();
  }
  return source.toString();
}

RuntimeInterpreterException _runtimeFailure(Object? Function() operation) {
  try {
    operation();
  } on RuntimeInterpreterException catch (error) {
    return error;
  }
  throw StateError('expected runtime failure');
}

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
        'dart ${arguments.join(' ')} failed\n'
        'stdout:\n${result.stdout}\n'
        'stderr:\n${result.stderr}',
  );
  return result;
}
