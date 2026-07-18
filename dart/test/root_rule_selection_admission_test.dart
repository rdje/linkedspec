import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/cli/primary_cli.dart';
import 'package:test/test.dart';

final Map<String, Object?> _contract = _object(
  jsonDecode(
    File(
      '../capability_conformance/root_rule_selection_contract.json',
    ).readAsStringSync(),
  ),
);

const _generatedIdentity = 'root-selection/dart-admission.spec';

const _markedSource = '''Earlier:
 /x/
 E { return("earlier") }

Marked::
 /x/
 E { return("marked") }

Later::
 /x/
 E { return("later") }
''';

const _markerlessSource = '''First:
 /x/
 E { return("first") }

Second:
 /x/
 E { return("second") }
''';

const _traceSource = '''Top::
 /x/ -> Done { return("trace") }

Done::
 /x/
''';

typedef _AdmissionRole = void Function(Map<String, Object?> contract);

void main() {
  test('contract-declared Dart roles execute once and only once', () {
    final roleMap = <String, _AdmissionRole>{
      'neutral_selection': role_neutral_selection,
      'neutral_failures': role_neutral_failures,
      'neutral_strict': role_neutral_strict,
      'native': role_native,
      'loaded': role_loaded,
      'reconstructed': role_reconstructed,
      'generated_direct': role_generated_direct,
      'generated_traced': role_generated_traced,
      'emitted_source_direct': role_emitted_source_direct,
      'emitted_source_traced': role_emitted_source_traced,
      'descriptor': role_descriptor,
      'diagnostic': role_diagnostic,
      'runtime_trace': role_runtime_trace,
      'primary_cli': role_primary_cli,
      'primary_request_trace': role_primary_request_trace,
    };
    final admission = _object(_contract['dart_admission']);
    final declaredRoles = _strings(admission['roles']);
    expect(
      declaredRoles.toSet().length,
      declaredRoles.length,
      reason: 'Dart admission roles must be unique',
    );
    expect(
      roleMap.keys.toSet(),
      declaredRoles.toSet(),
      reason: 'Dart consumer must implement exactly the declared roles',
    );

    final completed = <String>{};
    for (final role in declaredRoles) {
      expect(completed.add(role), isTrue, reason: 'role $role repeated');
      roleMap[role]!(_contract);
    }
    expect(
      completed,
      roleMap.keys.toSet(),
      reason: 'every declared Dart admission role must complete once',
    );
  });
}

void role_neutral_selection(Map<String, Object?> contract) {
  expect(contract['contract_id'], linkedSpecRootRuleSelectionContract);
  for (final caseValue in _objects(contract['selection_cases'])) {
    final id = caseValue['id']! as String;
    final compiled = _compiledForRows(_objects(caseValue['rules']));
    final authoredBefore = [
      for (final label in compiled.compiledRuleOrder)
        (label, compiled.rule(label)!.header.isTop),
    ];
    final selection = compiled.resolveEntryRule(
      caseValue['explicit_selector'] as String?,
    );
    expect(selection.rule.label, caseValue['expected_label'], reason: id);
    expect(
      selection.basis.contractName,
      caseValue['expected_basis'],
      reason: id,
    );
    expect(
      [
        for (final label in compiled.compiledRuleOrder)
          (label, compiled.rule(label)!.header.isTop),
      ],
      authoredBefore,
      reason: '$id rewrote authored identity',
    );
  }
}

void role_neutral_failures(Map<String, Object?> contract) {
  for (final caseValue in _objects(contract['failure_cases'])) {
    final id = caseValue['id']! as String;
    try {
      _compiledForRows(
        _objects(caseValue['rules']),
      ).resolveEntryRule(caseValue['explicit_selector'] as String?);
      fail('$id must reject selection');
    } on EntryRuleSelectionException catch (error) {
      expect(error.code, caseValue['expected_code'], reason: id);
      expect(error.stage, caseValue['expected_stage'], reason: id);
    }
  }
}

void role_neutral_strict(Map<String, Object?> contract) {
  for (final caseValue in _objects(contract['strict_cases'])) {
    final id = caseValue['id']! as String;
    final source = switch (id) {
      'explicit_selection_is_not_reference' => 'A:\n /a/\n\nB:\n /b/\n',
      'marker_selection_is_not_reference' =>
        'Top::\n /x/ -> Child\n\nChild:\n /x/ -> Child\n',
      'closed_reference_cycle_has_no_unused_rules' =>
        'A:\n /a/ -> B\n\nB:\n /b/ -> A\n',
      _ => throw StateError('unhandled strict case $id'),
    };
    final expectedUnused = _strings(caseValue['expected_unused']);
    if (expectedUnused.isEmpty) {
      expect(
        () => validateSpec(parseSpec(source), strictSyntax: true),
        returnsNormally,
        reason: id,
      );
    } else {
      expect(
        () => validateSpec(parseSpec(source), strictSyntax: true),
        throwsA(
          isA<SpecValidationException>().having(
            (error) => error.message,
            'unused labels',
            contains(expectedUnused.join(', ')),
          ),
        ),
        reason: id,
      );
    }
  }
}

void role_native(Map<String, Object?> _) {
  final marked = _engine(_markedSource);
  expect(marked.parse('x').value, 'marked');
  expect(marked.parse('x', topRule: 'Earlier').value, 'earlier');
  expect(marked.parse('x', topRule: 'Later').value, 'later');

  final markerless = _engine(_markerlessSource);
  expect(markerless.parse('x').value, 'first');
  expect(markerless.parse('x', topRule: 'Second').value, 'second');
}

void role_loaded(Map<String, Object?> _) {
  _withScratch('loaded', (scratch) {
    final file = File('${scratch.path}${Platform.pathSeparator}markerless.spec')
      ..writeAsStringSync(_markerlessSource);
    final loaded = loadAndCompileSpec(
      SpecRequest.path(file.path),
      SpecLoadOptions(cwd: scratch),
    );
    expect(loaded.createEngine().parse('x').value, 'first');
    expect(loaded.createEngine().parse('x', topRule: 'Second').value, 'second');
  });
}

void role_reconstructed(Map<String, Object?> _) {
  final normalized = SpecFile.fromJson(
    _object(jsonDecode(jsonEncode(parseSpec(_markedSource).toJson()))),
  );
  final reconstructed = compileSpec(normalized);
  expect(
    [
      for (final label in reconstructed.compiledRuleOrder)
        (label, reconstructed.rule(label)!.header.isTop),
    ],
    [('Earlier', false), ('Marked', true), ('Later', true)],
  );
  final engine = LinkedSpecRuntimeEngine(reconstructed);
  expect(engine.parse('x').value, 'marked');
  expect(engine.parse('x', topRule: 'Earlier').value, 'earlier');
}

void role_generated_direct(Map<String, Object?> _) {
  final marked = _compileSource(_markedSource);
  expect(
    executeGeneratedParserV2(
      marked,
      buildGeneratedRulePlan(marked),
      'x',
      _generatedIdentity,
      topRule: 'Earlier',
    ),
    'earlier',
  );

  final markerless = _compileSource(_markerlessSource);
  expect(
    executeGeneratedParserV2(
      markerless,
      buildGeneratedRulePlan(markerless),
      'x',
      _generatedIdentity,
    ),
    'first',
  );
}

void role_generated_traced(Map<String, Object?> _) {
  _withScratch('generated-traced', (scratch) {
    final compiled = _compileSource(_markedSource);
    final traceFile = File(
      '${scratch.path}${Platform.pathSeparator}generated.trace',
    );
    expect(
      executeGeneratedParserWithTraceV2(
        compiled,
        buildGeneratedRulePlan(compiled),
        'x',
        LinkedSpecTraceConfig(
          level: LinkedSpecTraceLevel.debug,
          traceFile: traceFile.path,
          sinkMode: LinkedSpecTraceSinkMode.route,
          resetFile: true,
        ),
        _generatedIdentity,
        topRule: 'Later',
      ),
      'later',
    );
    final trace = traceFile.readAsStringSync();
    expect(trace, contains('dart_runtime:entry_rule_selection'));
    expect(trace, contains('requested=Later'));
    expect(trace, contains('effective=Later'));
    expect(trace, contains('basis=explicit_selector'));
    expect(trace, contains('rule=Later'));
  });
}

void role_emitted_source_direct(Map<String, Object?> _) {
  final source = emitDartSourceV2(
    _compileSource(_markedSource),
    _generatedIdentity,
  );
  for (final marker in [
    'const linkedspecGeneratedSourceContract =',
    "'linkedspec-generated-source-v2'",
    'const linkedspecGeneratedSourceFormat = 2;',
    'Object? execute(',
    'String? topRule,',
    _generatedIdentity,
  ]) {
    expect(source, contains(marker), reason: 'emitted source omitted $marker');
  }
}

void role_emitted_source_traced(Map<String, Object?> _) {
  final source = emitDartSourceV2(
    _compileSource(_markedSource),
    _generatedIdentity,
  );
  for (final marker in [
    'Object? executeWithTrace(',
    'LinkedSpecTraceConfig traceConfig',
    'executeGeneratedParserWithTraceV2(',
    'topRule: topRule',
  ]) {
    expect(source, contains(marker), reason: 'emitted source omitted $marker');
  }
}

void role_descriptor(Map<String, Object?> _) {
  final compiled = _compileSource(_markedSource);
  final before = compiled.toDescriptorJson();
  expect(
    LinkedSpecRuntimeEngine(compiled).parse('x', topRule: 'Earlier').value,
    'earlier',
  );
  final after = compiled.toDescriptorJson();
  expect(after, before);
  final meta = _object(after['meta']);
  expect(meta['entry_rule_contract'], linkedSpecRootRuleSelectionContract);
  expect(meta['definition_order'], ['Earlier', 'Marked', 'Later']);
  expect(meta, isNot(contains('entry_rule')));
  expect(meta, isNot(contains('selected_entry_rule')));
  final spec = _object(after['spec']);
  expect(_object(_object(spec['Earlier'])['meta'])['is_top'], isFalse);
  expect(_object(_object(spec['Marked'])['meta'])['is_top'], isTrue);
}

void role_diagnostic(Map<String, Object?> _) {
  try {
    _engine(_markedSource).parse('x', topRule: 'Missing');
    fail('unknown selector must reject before execution');
  } on RuntimeInterpreterException catch (error) {
    expect(error.diagnostic?.code, 'entry_rule_not_found');
    expect(error.diagnostic?.stage, 'select_entry_rule');
    expect(error.diagnostic?.entryRule, 'Missing');
  }

  final empty = LinkedSpecRuntimeEngine(
    compileSpec(const SpecFile(rules: []), validateSource: false),
  );
  try {
    empty.parse('', topRule: 'Missing');
    fail('zero rules must reject before explicit selection');
  } on RuntimeInterpreterException catch (error) {
    expect(error.diagnostic?.code, 'no_rules_defined');
    expect(error.diagnostic?.stage, 'validate_spec');
  }

  final compiled = _compileSource(_markedSource);
  try {
    executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      'x',
      _generatedIdentity,
      topRule: 'Missing',
      actualContract: 'linkedspec-generated-source-v1',
    );
    fail('stale generated contract must reject before selection');
  } on GeneratedSourceException catch (error) {
    expect(error.stage, GeneratedSourceStage.validateGeneratedPlan);
    expect(
      error.code,
      GeneratedSourceCode.generatedSourceContractVersionMismatch,
    );
  }
}

void role_runtime_trace(Map<String, Object?> _) {
  const failureSource = '''Earlier:
 /x/
 E { return(not(true, false)) }

Marked::
 /x/
 E { return("marked") }
''';
  _withScratch('runtime-trace', (scratch) {
    final compiled = _compileSource(failureSource);
    final traceFile = File(
      '${scratch.path}${Platform.pathSeparator}failure.trace',
    );
    try {
      executeGeneratedParserWithTraceV2(
        compiled,
        buildGeneratedRulePlan(compiled),
        'x',
        LinkedSpecTraceConfig(
          level: LinkedSpecTraceLevel.debug,
          traceFile: traceFile.path,
          sinkMode: LinkedSpecTraceSinkMode.route,
          resetFile: true,
        ),
        _generatedIdentity,
        topRule: 'Earlier',
      );
      fail('selected rule runtime failure must retain effective identity');
    } on GeneratedSourceException catch (error) {
      expect(error.stage, GeneratedSourceStage.executeGenerated);
      expect(error.code, GeneratedSourceCode.generatedExecutionFailed);
      expect(error.ruleLabel, 'Earlier');
      expect(error.handlerFamily, 'default');
    }
    final trace = traceFile.readAsStringSync();
    expect(trace, contains('requested=Earlier'));
    expect(trace, contains('effective=Earlier'));
    expect(trace, contains('basis=explicit_selector'));
    expect(trace, contains('rule=Earlier'));
  });
}

void role_primary_cli(Map<String, Object?> _) {
  for (final route in [
    (_markedSource, <String>[], '"marked"\n'),
    (_markerlessSource, <String>[], '"first"\n'),
    (_markedSource, ['--top-rule', 'Earlier'], '"earlier"\n'),
  ]) {
    final output = runLinkedSpecDartPrimaryCli([
      '--inline-spec',
      route.$1,
      '--input',
      'x',
      ...route.$2,
    ]);
    expect(output.exitCode, 0);
    expect(output.stdoutBytes, utf8.encode(route.$3));
    expect(output.stderrBytes, isEmpty);
  }

  final unknown = runLinkedSpecDartPrimaryCli(const [
    '--inline-spec',
    _markedSource,
    '--input',
    'x',
    '--top-rule',
    'Missing',
  ]);
  expect(unknown.exitCode, 1);
  expect(unknown.stdoutBytes, isEmpty);
  expect(
    unknown.stderrBytes,
    utf8.encode('linkedspec: parser invocation failed\n'),
  );
}

void role_primary_request_trace(Map<String, Object?> _) {
  final expectedDefault = File(
    '../cli_conformance/cases/trace/medium_stdout.txt',
  ).readAsBytesSync();
  final defaultOutput = runLinkedSpecDartPrimaryCli(const [
    '--inline-spec',
    _traceSource,
    '--input',
    'x',
    '--trace',
    'medium',
  ]);
  expect(defaultOutput.exitCode, 0);
  expect(defaultOutput.stdoutBytes, expectedDefault);
  expect(defaultOutput.stderrBytes, isEmpty);

  _withScratch('primary-request-trace', (scratch) {
    final traceFile = File('${scratch.path}${Platform.pathSeparator}trace.log')
      ..writeAsStringSync('stale trace\n');
    final explicitOutput = runLinkedSpecDartPrimaryCli(
      const [
        '--inline-spec',
        _traceSource,
        '--input',
        'x',
        '--top-rule',
        'Top\nInjected',
        '--trace',
        'medium',
        '--trace-file',
        'trace.log',
        '--trace-mode',
        'route',
        '--trace-reset',
      ],
      workingDirectory: scratch,
      repositoryRoot: Directory('..'),
    );
    expect(explicitOutput.exitCode, 1);
    expect(explicitOutput.stdoutBytes, isEmpty);
    expect(
      explicitOutput.stderrBytes,
      utf8.encode('linkedspec: parser invocation failed\n'),
    );
    expect(
      traceFile.readAsBytesSync(),
      File(
        '../cli_conformance/cases/trace/failure_invoke_escaped_medium.txt',
      ).readAsBytesSync(),
    );
  });
}

CompiledSpec _compileSource(String source) {
  final parsed = parseSpec(source);
  validateSpec(parsed);
  return compileSpec(parsed, validateSource: false);
}

CompiledSpec _compiledForRows(List<Map<String, Object?>> rows) {
  if (rows.isEmpty) {
    return compileSpec(const SpecFile(rules: []), validateSource: false);
  }
  final source = rows
      .map((row) {
        final label = row['label']! as String;
        final separator = row['authored_is_top'] == true ? '::' : ':';
        return '$label$separator\n /x/\n E { return("$label") }\n';
      })
      .join('\n');
  return _compileSource(source);
}

LinkedSpecRuntimeEngine _engine(String source) =>
    LinkedSpecRuntimeEngine(_compileSource(source));

T _withScratch<T>(String label, T Function(Directory scratch) body) {
  final scratch = Directory.systemTemp.createTempSync(
    'linkedspec-dart-root-admission-$label-',
  );
  try {
    return body(scratch);
  } finally {
    if (scratch.existsSync()) {
      scratch.deleteSync(recursive: true);
    }
  }
}

Map<String, Object?> _object(Object? value) =>
    Map<String, Object?>.from(value! as Map);

List<Map<String, Object?>> _objects(Object? value) => [
  for (final row in value! as List) _object(row),
];

List<String> _strings(Object? value) => [
  for (final item in value! as List) item! as String,
];
