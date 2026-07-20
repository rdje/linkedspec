import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/cli/primary_cli.dart';
import 'package:test/test.dart';

final Map<String, Object?> _contract = _object(
  jsonDecode(
    File(
      '../capability_conformance/duplicate_regex_slot_identity_contract.json',
    ).readAsStringSync(),
  ),
);

const _generatedIdentity = 'duplicate-regex-slot/dart-admission.spec';

typedef _AdmissionRole = void Function(Map<String, Object?> contract);

void main() {
  test('contract-declared Dart roles execute once and only once', () {
    final roleMap = <String, _AdmissionRole>{
      'neutral_fixtures': role_neutral_fixtures,
      'native_ordered': role_native_ordered,
      'native_choice': role_native_choice,
      'repeated_ordered': role_repeated_ordered,
      'repeated_control': role_repeated_control,
      'cross_target': role_cross_target,
      'loaded': role_loaded,
      'reconstructed': role_reconstructed,
      'descriptor': role_descriptor,
      'emitted_source': role_emitted_source,
      'generated_direct': role_generated_direct,
      'native_trace': role_native_trace,
      'generated_trace': role_generated_trace,
      'primary_command': role_primary_command,
      'invalid_identity_diagnostics': role_invalid_identity_diagnostics,
    };
    final admission = _object(_contract['dart_admission']);
    final declaredRoles = _strings(admission['roles']);
    expect(declaredRoles.toSet().length, declaredRoles.length);
    expect(roleMap.keys.toSet(), declaredRoles.toSet());

    final completed = <String>{};
    for (final role in declaredRoles) {
      expect(completed.add(role), isTrue, reason: 'role $role repeated');
      roleMap[role]!(_contract);
    }
    expect(completed, roleMap.keys.toSet());
  });
}

void role_neutral_fixtures(Map<String, Object?> contract) {
  expect(contract['contract_id'], linkedSpecRegexSlotIdentityContract);
  expect(_fixtures(contract).map((row) => row['id']).toList(), [
    'ordered_same_rule_duplicate',
    'choice_same_rule_duplicate',
    'repeated_ordered_duplicate',
    'repeated_non_duplicate_control',
    'ordered_cross_target_duplicate',
  ]);
  expect(_object(contract['identity'])['required_fields'], [
    'target_rule',
    'regex_index',
  ]);
  expect(
    _object(_object(contract['selection'])['ordered'])['algorithm'],
    'match_only_the_required_structural_slot_and_report_that_same_identity',
  );
}

void role_native_ordered(Map<String, Object?> contract) {
  _expectFixture(_fixture(contract, 'ordered_same_rule_duplicate'));
}

void role_native_choice(Map<String, Object?> contract) {
  _expectFixture(_fixture(contract, 'choice_same_rule_duplicate'));
}

void role_repeated_ordered(Map<String, Object?> contract) {
  _expectFixture(_fixture(contract, 'repeated_ordered_duplicate'));
}

void role_repeated_control(Map<String, Object?> contract) {
  _expectFixture(_fixture(contract, 'repeated_non_duplicate_control'));
}

void role_cross_target(Map<String, Object?> contract) {
  _expectFixture(_fixture(contract, 'ordered_cross_target_duplicate'));
}

void role_loaded(Map<String, Object?> contract) {
  final scratch = Directory.systemTemp.createTempSync(
    'linkedspec-dart-duplicate-slot-loaded-',
  );
  try {
    for (final row in _fixtures(contract)) {
      final path = '${scratch.path}${Platform.pathSeparator}${row['id']}.spec';
      File(path).writeAsStringSync(row['source']! as String);
      final loaded = loadAndCompileSpec(
        SpecRequest.path(path),
        SpecLoadOptions(cwd: scratch),
      );
      expect(
        loaded.createEngine().parse(row['input']! as String).value,
        row['expected_result'],
        reason: '${row['id']} loaded',
      );
    }
  } finally {
    scratch.deleteSync(recursive: true);
  }
  expect(scratch.existsSync(), isFalse);
}

void role_reconstructed(Map<String, Object?> contract) {
  for (final row in _fixtures(contract)) {
    final parsed = _parse(row['source']! as String);
    final reconstructed = SpecFile.fromJson(
      _object(jsonDecode(jsonEncode(parsed.toJson()))),
    );
    expect(
      LinkedSpecRuntimeEngine(
        compileSpec(reconstructed),
      ).parse(row['input']! as String).value,
      row['expected_result'],
      reason: '${row['id']} reconstructed',
    );
  }
}

void role_descriptor(Map<String, Object?> contract) {
  final descriptorContract = _object(contract['descriptor_contract']);
  for (final fixtureId in [
    'ordered_same_rule_duplicate',
    'ordered_cross_target_duplicate',
  ]) {
    final descriptor = _compileFixture(
      _fixture(contract, fixtureId),
    ).toDescriptorJson();
    expect(
      _object(descriptor['meta'])[descriptorContract['meta_field']],
      descriptorContract['meta_value'],
      reason: fixtureId,
    );
    final topMeta = _object(
      _object(_object(descriptor['spec'])['Top'])['meta'],
    );
    final edges = _objects(topMeta['resolved_edges']);
    final identities = [
      for (final edge in edges) '${edge['target']}#${edge['regex_index']}',
    ];
    expect(
      identities,
      _strings(
        _fixture(contract, fixtureId)['expected_match_identities'],
      ).toSet().toList(),
      reason: '$fixtureId descriptor identities',
    );
  }
}

void role_emitted_source(Map<String, Object?> contract) {
  final row = _fixture(contract, 'ordered_same_rule_duplicate');
  final emitted = emitDartSourceV2(_compileFixture(row), _generatedIdentity);
  expect(emitted, contains('linkedspec-generated-source-v2'));
  expect(emitted, contains('linkedspecGeneratedSourceFormat = 2'));
  expect(emitted, contains('linkedspecRegexSlotIdentityContract'));
  expect(emitted, contains(linkedSpecRegexSlotIdentityContract));
  expect(emitted, contains('const _compiledSpecJsonBase64'));
  expect(emitted, isNot(contains('regex_text_identity')));
}

void role_generated_direct(Map<String, Object?> contract) {
  for (final row in _fixtures(contract)) {
    final compiled = _compileFixture(row);
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
  final ordered = _fixture(contract, 'repeated_ordered_duplicate');
  final orderedTrace = LinkedSpecTraceEmitter(
    LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.high),
    stdoutWriter: (_) {},
  );
  final orderedValue = LinkedSpecRuntimeEngine(
    _compileFixture(ordered),
  ).parse(ordered['input']! as String, trace: orderedTrace).value;
  expect(orderedValue, ordered['expected_result']);
  expect(
    _traceIdentities(orderedTrace.lines),
    _strings(ordered['expected_match_identities']),
  );
  expect(
    orderedTrace.events
        .where((event) => event.topic == 'dart_runtime:regex_slot_selected')
        .every(
          (event) => event.details.contains('selection_role=ordered_required'),
        ),
    isTrue,
  );

  final choice = _fixture(contract, 'choice_same_rule_duplicate');
  final choiceTrace = LinkedSpecTraceEmitter(
    LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.high),
    stdoutWriter: (_) {},
  );
  final choiceValue = LinkedSpecRuntimeEngine(
    _compileFixture(choice),
  ).parse(choice['input']! as String, trace: choiceTrace).value;
  expect(choiceValue, choice['expected_result']);
  expect(
    _traceIdentities(choiceTrace.lines),
    _strings(choice['expected_match_identities']),
  );
  expect(
    choiceTrace.events
        .where((event) => event.topic == 'dart_runtime:regex_slot_selected')
        .single
        .details,
    contains('selection_role=choice'),
  );
}

void role_generated_trace(Map<String, Object?> contract) {
  final row = _fixture(contract, 'ordered_cross_target_duplicate');
  final compiled = _compileFixture(row);
  final scratch = Directory.systemTemp.createTempSync(
    'linkedspec-dart-duplicate-slot-trace-',
  );
  try {
    final tracePath = '${scratch.path}${Platform.pathSeparator}trace.log';
    final value = executeGeneratedParserWithTraceV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      row['input']! as String,
      LinkedSpecTraceConfig(
        level: LinkedSpecTraceLevel.high,
        traceFile: tracePath,
        sinkMode: LinkedSpecTraceSinkMode.route,
        resetFile: true,
      ),
      _generatedIdentity,
    );
    expect(value, row['expected_result']);
    expect(
      _traceIdentities(File(tracePath).readAsLinesSync()),
      _strings(row['expected_match_identities']),
    );
  } finally {
    scratch.deleteSync(recursive: true);
  }
  expect(scratch.existsSync(), isFalse);
}

void role_primary_command(Map<String, Object?> contract) {
  for (final row in _fixtures(contract)) {
    final output = runLinkedSpecDartPrimaryCli([
      '--inline-spec',
      row['source']! as String,
      '--input',
      row['input']! as String,
    ]);
    expect(output.exitCode, 0, reason: '${row['id']} primary exit');
    expect(output.stderrBytes, isEmpty, reason: '${row['id']} primary stderr');
    expect(
      jsonDecode(utf8.decode(output.stdoutBytes)),
      row['expected_result'],
      reason: '${row['id']} primary value',
    );
  }
}

void role_invalid_identity_diagnostics(Map<String, Object?> contract) {
  final diagnostics = {
    for (final row in _objects(contract['diagnostics'])) row['code']: row,
  };

  try {
    compileSpec(_parse('Top::\n -> Missing[3]\n'));
    fail('invalid source identity was accepted');
  } on SpecValidationException catch (error) {
    final expected = diagnostics['regex_slot_identity_invalid']!;
    expect(error.diagnostic?.code, expected['code']);
    expect(error.diagnostic?.stage, expected['stage']);
    expect(error.diagnostic?.fields, {
      'regex_index': 3,
      'rule_label': 'Top',
      'target_rule': 'Missing',
    });
  }

  final row = _fixture(contract, 'ordered_same_rule_duplicate');
  final malformed = _malformedCompiled(_compileFixture(row));
  expect(
    () => validateCompiledRegexSlotIdentities(malformed),
    throwsA(
      isA<SpecValidationException>().having(
        (error) => error.diagnostic?.toJson(),
        'portable diagnostic',
        {
          'code': 'regex_slot_identity_invalid',
          'stage': 'validate_compiled_rule',
          'message':
              "rule 'Top' references rule 'Top' regex slot 9, but that structural slot does not exist",
          'fields': {
            'regex_index': 9,
            'rule_label': 'Top',
            'target_rule': 'Top',
          },
        },
      ),
    ),
  );

  try {
    LinkedSpecRuntimeEngine(malformed).parse(row['input']! as String);
    fail('runtime accepted malformed compiled identity');
  } on RuntimeInterpreterException catch (error) {
    expect(error.diagnostic?.code, 'regex_slot_identity_invalid');
    expect(error.diagnostic?.stage, 'validate_compiled_rule');
    expect(error.diagnostic?.ruleLabel, 'Top');
    expect(error.diagnostic?.targetRule, 'Top');
    expect(error.diagnostic?.regexIndex, 9);
  }

  try {
    validateGeneratedRulePlanV2(
      malformed,
      buildGeneratedRulePlan(malformed),
      _generatedIdentity,
    );
    fail('generated adapter accepted malformed compiled identity');
  } on GeneratedSourceException catch (error) {
    expect(error.stage, GeneratedSourceStage.validateCompiledRule);
    expect(error.code, GeneratedSourceCode.regexSlotIdentityInvalid);
    expect(error.ruleLabel, 'Top');
    expect(error.targetRule, 'Top');
    expect(error.regexIndex, 9);
  }

  expect(
    () => emitDartSourceV2(malformed, _generatedIdentity),
    throwsA(
      isA<GeneratedSourceException>()
          .having(
            (error) => error.stage,
            'stage',
            GeneratedSourceStage.validateCompiledRule,
          )
          .having(
            (error) => error.code,
            'code',
            GeneratedSourceCode.regexSlotIdentityInvalid,
          )
          .having((error) => error.targetRule, 'target rule', 'Top')
          .having((error) => error.regexIndex, 'regex index', 9),
    ),
  );

  try {
    assertOrderedRegexSlotIdentity(
      ruleLabel: 'Top',
      expectedTargetRule: 'First',
      expectedRegexIndex: 0,
      actualTargetRule: 'Second',
      actualRegexIndex: 0,
    );
    fail('ordered target mismatch was accepted');
  } on OrderedRegexSlotIdentityException catch (error) {
    expect(error.diagnostic.code, 'ordered_regex_slot_identity_lost');
    expect(error.diagnostic.stage, 'execute_rule');
    expect(error.diagnostic.fields.keys.toSet(), {
      'rule_label',
      'target_rule',
      'expected_regex_index',
      'actual_regex_index',
    });
    expect(
      error.toString(),
      'ordered_regex_slot_identity_lost stage=execute_rule '
      'rule_label=Top target_rule=First expected_regex_index=0 '
      'actual_regex_index=0',
    );
  }
}

void _expectFixture(Map<String, Object?> row) {
  expect(
    LinkedSpecRuntimeEngine(
      _compileFixture(row),
    ).parse(row['input']! as String).value,
    row['expected_result'],
    reason: '${row['id']} native',
  );
}

CompiledSpec _compileFixture(Map<String, Object?> row) {
  return compileSpec(_parse(row['source']! as String));
}

SpecFile _parse(String source) {
  return parseSpecWithStagedUserFunctionDefinitions(source);
}

CompiledSpec _malformedCompiled(CompiledSpec compiled) {
  final top = compiled.rulesByLabel['Top']!;
  final original = top.actionEdges[1];
  final malformedEdge = CompiledActionEdge(
    line: original.line,
    source: original.source,
    targets: const [DependencyRef(label: 'Top', index: 9)],
    regexIndex: original.regexIndex,
    childRegexIndex: 9,
    hasParentRegex: original.hasParentRegex,
    fluentChain: original.fluentChain,
    code: original.code,
    actionPayload: original.actionPayload,
  );
  final malformedTop = top.copyWith(
    actionEdges: List.unmodifiable([top.actionEdges.first, malformedEdge]),
  );
  return CompiledSpec(
    definitionOrder: compiled.definitionOrder,
    compiledRuleOrder: compiled.compiledRuleOrder,
    rulesByLabel: Map.unmodifiable({
      ...compiled.rulesByLabel,
      'Top': malformedTop,
    }),
    redefinedRuleLabels: compiled.redefinedRuleLabels,
    functionRegistry: compiled.functionRegistry,
    dependencyRegexState: compiled.dependencyRegexState,
  );
}

List<String> _traceIdentities(Iterable<String> lines) {
  final identities = <String>[];
  final target = RegExp(r'target_rule=([^ ]+)');
  final index = RegExp(r'regex_index=([0-9]+)');
  for (final line in lines) {
    if (!line.contains('dart_runtime:regex_slot_selected')) {
      continue;
    }
    identities.add(
      '${target.firstMatch(line)!.group(1)}#${index.firstMatch(line)!.group(1)}',
    );
  }
  return identities;
}

Map<String, Object?> _fixture(Map<String, Object?> contract, String id) {
  return _fixtures(contract).singleWhere((row) => row['id'] == id);
}

List<Map<String, Object?>> _fixtures(Map<String, Object?> contract) {
  return _objects(contract['fixtures']);
}

List<Map<String, Object?>> _objects(Object? value) {
  return (value! as List).map((item) => _object(item)).toList(growable: false);
}

List<String> _strings(Object? value) => (value! as List).cast<String>();

Map<String, Object?> _object(Object? value) {
  return Map<String, Object?>.from(value! as Map);
}
