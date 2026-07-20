// FUTURE-PARITY-BACKLOG.9.1.10.3 — Dart explicit-repetition result admission.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/cli/primary_cli.dart';
import 'package:test/test.dart';

final Map<String, Object?> _contract = _object(
  jsonDecode(
    File(
      '../capability_conformance/repeated_action_result_contract.json',
    ).readAsStringSync(),
  ),
);

const _contractId = 'linkedspec-explicit-repetition-action-result-v1';
const _generatedIdentity = 'repeated-action-result/dart-admission.spec';

typedef _AdmissionRole = void Function(Map<String, Object?> contract);

void main() {
  test('bare OR metadata and family are repetition', () {
    final row = _case(_contract, 'explicit_or_two_hits');
    final rule = _compileRow(row).rule('Top')!;
    expect(rule.modeMetadata.isRepetition, isTrue);
    expect(rule.modeMetadata.repMin, 1);
    expect(classifyGeneratedRuleFamily(rule).wireName, 'rep_acode');
  });

  test('repeated action returns are collected per hit', () {
    expect(_execute(_case(_contract, 'explicit_or_two_hits')).value, [
      'A',
      'B',
    ]);
  });

  test('contract-declared Dart roles execute once and only once', () {
    final roleMap = <String, _AdmissionRole>{
      'neutral_contract': role_neutral_contract,
      'ast_metadata': role_ast_metadata,
      'native_mode_matrix': role_native_mode_matrix,
      'native_special_cases': role_native_special_cases,
      'loaded': role_loaded,
      'reconstructed': role_reconstructed,
      'descriptor': role_descriptor,
      'emitted_source': role_emitted_source,
      'generated_direct': role_generated_direct,
      'native_trace': role_native_trace,
      'generated_trace': role_generated_trace,
      'primary_command': role_primary_command,
      'corpus_bundle': role_corpus_bundle,
      'lifecycle_authority': role_lifecycle_authority,
      'bounds_and_progress': role_bounds_and_progress,
    };
    final admission = _object(_object(_contract['admissions'])['dart']);
    final declaredRoles = _strings(admission['roles']);
    expect(declaredRoles.toSet(), hasLength(declaredRoles.length));
    expect(roleMap.keys.toSet(), declaredRoles.toSet());

    final completed = <String>{};
    for (final role in declaredRoles) {
      expect(completed.add(role), isTrue, reason: 'role $role repeated');
      roleMap[role]!(_contract);
    }
    expect(completed, roleMap.keys.toSet());
  });
}

void role_neutral_contract(Map<String, Object?> contract) {
  expect(contract['contract_id'], _contractId);
  expect(_object(contract['scope'])['explicit_repetition_modes'], [
    'Star',
    'Plus',
    'Optional',
    'Or',
    'OrPlus',
    'OrBounded',
  ]);
  expect(_objects(contract['mode_cases']).map((row) => row['id']).toList(), [
    'compact_star_two_hits',
    'compact_plus_two_hits',
    'compact_optional_one_hit',
    'explicit_or_two_hits',
    'explicit_or_plus_two_hits',
    'bounded_exact_two_hits',
    'bounded_up_to_two_hits',
    'pipe_distinct_scalar',
  ]);
  expect(
    _object(contract['semantics'])['lifecycle_return'],
    'whole_rule_return',
  );
  expect(_object(contract['generated_source_v2'])['format_version'], 2);
}

void role_ast_metadata(Map<String, Object?> contract) {
  for (final row in _objects(contract['mode_cases'])) {
    final rule = _compileRow(row).rule('Top')!;
    expect(
      rule.modeMetadata.isRepetition,
      row['is_repetition'],
      reason: '${row['id']} authored repetition predicate',
    );
    expect(
      rule.modeMetadata.repMin,
      row['rep_min'],
      reason: '${row['id']} rep_min',
    );
    expect(
      rule.modeMetadata.repMax,
      row['rep_max'],
      reason: '${row['id']} rep_max',
    );
    expect(
      classifyGeneratedRuleFamily(rule).wireName,
      row['generated_family'],
      reason: '${row['id']} generated family',
    );
  }

  final blind = _compileRow(_case(contract, 'blind_or_repeats')).rule('Top')!;
  expect(blind.modeMetadata.repMin, 1);
  expect(classifyGeneratedRuleFamily(blind).wireName, 'rep_bcode');
}

void role_native_mode_matrix(Map<String, Object?> contract) {
  for (final row in _objects(contract['mode_cases'])) {
    _expectNative(row);
  }
}

void role_native_special_cases(Map<String, Object?> contract) {
  for (final row in _objects(contract['special_cases'])) {
    if (row['edge_surface'] == 'blind') {
      continue;
    }
    _expectNative(row);
  }
}

void role_loaded(Map<String, Object?> contract) {
  final row = _case(contract, 'explicit_or_two_hits');
  final scratch = Directory.systemTemp.createTempSync(
    'linkedspec-dart-repeated-result-loaded-',
  );
  try {
    final path = '${scratch.path}${Platform.pathSeparator}explicit-or.spec';
    File(path).writeAsStringSync(row['source']! as String);
    final loaded = loadAndCompileSpec(
      SpecRequest.path(path),
      SpecLoadOptions(cwd: scratch),
    );
    expect(
      loaded.createEngine().parse(row['input']! as String).value,
      row['expected_result'],
    );
  } finally {
    scratch.deleteSync(recursive: true);
  }
  expect(scratch.existsSync(), isFalse);
}

void role_reconstructed(Map<String, Object?> contract) {
  final row = _case(contract, 'explicit_or_two_hits');
  final parsed = _parse(row['source']! as String);
  final reconstructed = SpecFile.fromJson(
    _object(jsonDecode(jsonEncode(parsed.toJson()))),
  );
  expect(
    LinkedSpecRuntimeEngine(
      compileSpec(reconstructed),
    ).parse(row['input']! as String).value,
    row['expected_result'],
  );
}

void role_descriptor(Map<String, Object?> contract) {
  final descriptorContract = _object(contract['descriptor_contract']);
  for (final id in ['explicit_or_two_hits', 'pipe_distinct_scalar']) {
    final row = _case(contract, id);
    final descriptor = _compileRow(row).toDescriptorJson();
    final meta = _object(_object(_object(descriptor['spec'])['Top'])['meta']);
    final mode = _object(meta['mode']);
    expect(meta['family'], descriptorContract['family'], reason: id);
    expect(
      meta['cursor_policy'],
      descriptorContract['cursor_policy'],
      reason: id,
    );
    expect(mode['is_repetition'], row['is_repetition'], reason: id);
    expect(mode['rep_min'], row['rep_min'], reason: id);
    expect(mode['rep_max'], row['rep_max'], reason: id);
  }
}

void role_emitted_source(Map<String, Object?> contract) {
  final row = _case(contract, 'explicit_or_two_hits');
  final compiled = _compileRow(row);
  final emitted = emitDartSourceV2(compiled, _generatedIdentity);
  expect(emitted, contains(linkedSpecGeneratedSourceContract));
  expect(emitted, contains('family: "rep_acode"'));
  expect(emitted, contains('Object? execute('));
  expect(emitted, contains('Object? executeWithTrace('));

  final packageRoot = Directory.current.absolute;
  final scratch = Directory.systemTemp.createTempSync(
    'linkedspec-dart-repeated-result-emitted-',
  );
  final pubCache = Directory('${scratch.path}/pub-cache')..createSync();
  try {
    Directory('${scratch.path}/lib').createSync();
    Directory('${scratch.path}/bin').createSync();
    File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_repeated_result_emitted_probe
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

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_repeated_result_emitted_probe/generated.dart'
    as generated;

void main() {
  final direct = generated.execute('ab');
  final traced = generated.executeWithTrace(
    'ab',
    const LinkedSpecTraceConfig(
      level: LinkedSpecTraceLevel.debug,
      traceFile: 'generated.trace',
      sinkMode: LinkedSpecTraceSinkMode.route,
      resetFile: true,
    ),
  );
  print(jsonEncode({'direct': direct, 'traced': traced}));
}
''');

    final environment = {...Platform.environment, 'PUB_CACHE': pubCache.path};
    _expectDartProcessSuccess(scratch, environment, const [
      'pub',
      'get',
      '--offline',
    ]);
    final run = _expectDartProcessSuccess(scratch, environment, const [
      'run',
      'bin/main.dart',
    ]);
    expect(jsonDecode((run.stdout as String).trim()), {
      'direct': row['expected_result'],
      'traced': row['expected_result'],
    });
    final trace = File('${scratch.path}/generated.trace').readAsStringSync();
    expect('regex_slot_selected'.allMatches(trace), hasLength(2));
    expect(trace, contains('target_rule=Top regex_index=0'));
    expect(trace, contains('target_rule=Top regex_index=1'));
  } finally {
    scratch.deleteSync(recursive: true);
  }
  expect(scratch.existsSync(), isFalse);

  expect(
    () => validateGeneratedRulePlanV2(compiled, const [
      GeneratedPlanRow(label: 'Top', family: 'or_acode'),
    ], _generatedIdentity),
    throwsA(
      isA<GeneratedSourceException>()
          .having(
            (error) => error.stage,
            'stage',
            GeneratedSourceStage.validateGeneratedPlan,
          )
          .having(
            (error) => error.code,
            'code',
            GeneratedSourceCode.generatedPlanFamilyMismatch,
          ),
    ),
  );
}

ProcessResult _expectDartProcessSuccess(
  Directory workingDirectory,
  Map<String, String> environment,
  List<String> arguments,
) {
  final result = Process.runSync(
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
  expect(result.stderr, isEmpty, reason: 'dart ${arguments.join(' ')} stderr');
  return result;
}

void role_generated_direct(Map<String, Object?> contract) {
  for (final row in _objects(contract['mode_cases'])) {
    final compiled = _compileRow(row);
    expect(
      executeGeneratedParserV2(
        compiled,
        buildGeneratedRulePlan(compiled),
        row['input']! as String,
        _generatedIdentity,
      ),
      row['expected_result'],
      reason: '${row['id']} generated direct',
    );
  }
}

void role_native_trace(Map<String, Object?> contract) {
  final row = _case(contract, 'explicit_or_two_hits');
  final trace = LinkedSpecTraceEmitter(
    LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
    stdoutWriter: (_) {},
  );
  expect(
    LinkedSpecRuntimeEngine(
      _compileRow(row),
    ).parse(row['input']! as String, trace: trace).value,
    row['expected_result'],
  );
  _expectSelectedTrace(trace.events);
}

void role_generated_trace(Map<String, Object?> contract) {
  final row = _case(contract, 'explicit_or_two_hits');
  final compiled = _compileRow(row);
  final scratch = Directory.systemTemp.createTempSync(
    'linkedspec-dart-repeated-result-trace-',
  );
  try {
    final tracePath = '${scratch.path}${Platform.pathSeparator}generated.trace';
    expect(
      executeGeneratedParserWithTraceV2(
        compiled,
        buildGeneratedRulePlan(compiled),
        row['input']! as String,
        LinkedSpecTraceConfig(
          level: LinkedSpecTraceLevel.debug,
          traceFile: tracePath,
          sinkMode: LinkedSpecTraceSinkMode.route,
          resetFile: true,
        ),
        _generatedIdentity,
      ),
      row['expected_result'],
    );
    final trace = File(tracePath).readAsStringSync();
    expect('regex_slot_selected'.allMatches(trace), hasLength(2));
    expect(trace, contains('target_rule=Top regex_index=0'));
    expect(trace, contains('target_rule=Top regex_index=1'));
  } finally {
    scratch.deleteSync(recursive: true);
  }
  expect(scratch.existsSync(), isFalse);
}

void role_primary_command(Map<String, Object?> contract) {
  for (final id in ['explicit_or_two_hits', 'pipe_distinct_scalar']) {
    final row = _case(contract, id);
    final output = runLinkedSpecDartPrimaryCli([
      '--inline-spec',
      row['source']! as String,
      '--input',
      row['input']! as String,
    ]);
    expect(output.exitCode, 0, reason: '$id primary exit');
    expect(output.stderrBytes, isEmpty, reason: '$id primary stderr');
    expect(
      jsonDecode(utf8.decode(output.stdoutBytes)),
      row['expected_result'],
      reason: '$id primary result',
    );
  }
}

void role_corpus_bundle(Map<String, Object?> contract) {
  final row = _case(contract, 'explicit_or_two_hits');
  final bundle = _object(contract['corpus_bundle']);
  final source = File('../${bundle['source']}').readAsStringSync();
  final input = File('../${bundle['input']}').readAsStringSync();
  final expected = jsonDecode(
    File('../${bundle['expected']}').readAsStringSync(),
  );
  expect(source, row['source']);
  expect(input, 'ab\n');
  expect(expected, row['expected_result']);
  expect(
    LinkedSpecRuntimeEngine(_compile(source)).parse(input.trimRight()).value,
    expected,
  );
}

void role_lifecycle_authority(Map<String, Object?> contract) {
  for (final id in [
    'exit_lifecycle_overrides_collection',
    'loop_end_lifecycle_exits_rule',
  ]) {
    _expectNative(_case(contract, id));
  }
}

void role_bounds_and_progress(Map<String, Object?> contract) {
  for (final id in [
    'compact_optional_one_hit',
    'bounded_exact_two_hits',
    'bounded_up_to_two_hits',
    'zero_permitted_hits_empty',
    'below_minimum_is_null',
  ]) {
    _expectNative(_case(contract, id));
  }

  const zeroProgress = '''
Top::OR{,3}
 /x*/ -> Top[0] { return("Z") }
''';
  expect(
    LinkedSpecRuntimeEngine(_compile(zeroProgress)).parse('').value,
    ['Z'],
    reason: 'one accepted zero-width hit is retained before repetition stops',
  );
}

void _expectSelectedTrace(List<LinkedSpecTraceEvent> events) {
  final selected = events
      .where((event) => event.topic == 'dart_runtime:regex_slot_selected')
      .toList(growable: false);
  expect(selected, hasLength(2));
  expect(selected[0].details, contains('target_rule=Top regex_index=0'));
  expect(selected[1].details, contains('target_rule=Top regex_index=1'));
}

void _expectNative(Map<String, Object?> row) {
  final result = _execute(row);
  expect(result.value, row['expected_result'], reason: '${row['id']} result');
  expect(
    result.cursorCodeUnit,
    row['expected_position'],
    reason: '${row['id']} cursor',
  );
}

RuntimeParseResult _execute(Map<String, Object?> row) {
  return LinkedSpecRuntimeEngine(
    _compileRow(row),
  ).parse(row['input']! as String);
}

CompiledSpec _compileRow(Map<String, Object?> row) {
  return _compile(row['source']! as String);
}

CompiledSpec _compile(String source) {
  final parsed = _parse(source);
  validateSpec(parsed);
  return compileSpec(parsed, validateSource: false);
}

SpecFile _parse(String source) {
  return parseSpecWithStagedUserFunctionDefinitions(source);
}

Map<String, Object?> _case(Map<String, Object?> contract, String id) {
  return [
    ..._objects(contract['mode_cases']),
    ..._objects(contract['special_cases']),
  ].singleWhere((row) => row['id'] == id);
}

List<Map<String, Object?>> _objects(Object? value) {
  return (value! as List).map((item) => _object(item)).toList(growable: false);
}

List<String> _strings(Object? value) => (value! as List).cast<String>();

Map<String, Object?> _object(Object? value) {
  return Map<String, Object?>.from(value! as Map);
}
