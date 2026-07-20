import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/cli/primary_cli.dart';
import 'package:test/test.dart';

final Map<String, Object?> _contract = _object(
  jsonDecode(
    File(
      '../capability_conformance/rule_local_cursor_contract.json',
    ).readAsStringSync(),
  ),
);

const _defaultSource = '''
Top::
 /x/
 -> Top { return("hit") }
''';

const _andSource = '''
Top::AND
 /x/
 -> Top { return("hit") }
''';

const _mixedSource = '''
Top::AND
 => Child
Child:
 /x/
 -> Child { return("hit") }
''';

const _recursionSource = '''
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:OR
 /x/ -> Child[0] { return(call(Top)) }
 /z/ -> Child[1] { return("done") }
''';

const _orderedSource = '''
Top::AND
 => Header
 => Body
Header:
 /h/
 -> Header { return("header") }
Body:
 /b/
 -> Body { return("body") }
''';

const _anchoredSource = '''
Top::|
 => X
 => Y
X:AND
 /x/
 -> X { return("x") }
Y:AND
 /y/
 -> Y { return("y") }
''';

const _generatedIdentity = 'rule-local-cursor/dart-admission.spec';

typedef _AdmissionRole =
    void Function(Map<String, Object?> contract, _AdmissionState state);

void main() {
  test('contract-declared Dart cursor roles execute once and only once', () {
    final roleMap = <String, _AdmissionRole>{
      'native_default_family': role_native_default_family,
      'native_and_family': role_native_and_family,
      'ordinary_normalized': role_ordinary_normalized,
      'loaded_spec': role_loaded_spec,
      'descriptor_v1': role_descriptor_v1,
      'emitted_source_v2': role_emitted_source_v2,
      'generated_direct': role_generated_direct,
      'generated_trace': role_generated_trace,
      'mixed_parent_child': role_mixed_parent_child,
      'recursion': role_recursion,
      'structural_ordered_landmarks': role_structural_ordered_landmarks,
      'structural_anchored_choice': role_structural_anchored_choice,
      'static_option_removal': role_static_option_removal,
      'primary_command': role_primary_command,
      'portable_diagnostics': role_portable_diagnostics,
    };
    final admission = _object(_contract['dart_backend_admission']);
    final declaredRoles = _strings(admission['roles']);
    expect(declaredRoles.toSet(), roleMap.keys.toSet());
    expect(declaredRoles.toSet(), hasLength(declaredRoles.length));

    final completed = <String>{};
    final state = _AdmissionState();
    for (final role in declaredRoles) {
      expect(completed.add(role), isTrue, reason: 'role $role repeated');
      roleMap[role]!(_contract, state);
    }
    expect(completed, roleMap.keys.toSet());
  });
}

void role_native_default_family(
  Map<String, Object?> contract,
  _AdmissionState _,
) {
  expect(_object(contract['policy'])['or_default_cursor'], 'seek');
  final compiled = _compile(_defaultSource);
  expect(_engine(compiled).parse('prefix x').value, 'hit');
  expect(compiled.rule('Top')!.modeMetadata.cursorPolicy, 'seek');
}

void role_native_and_family(Map<String, Object?> contract, _AdmissionState _) {
  expect(_object(contract['policy'])['and_cursor'], 'consume');
  final compiled = _compile(_andSource);
  expect(_engine(compiled).parse('prefix x').value, isNull);
  expect(_engine(compiled).parse('x').value, 'hit');
  expect(compiled.rule('Top')!.modeMetadata.cursorPolicy, 'consume');
}

void role_ordinary_normalized(
  Map<String, Object?> contract,
  _AdmissionState _,
) {
  final parsed = parseSpec(_mixedSource);
  final encoded = jsonEncode(parsed.toJson());
  for (final option in _strings(
    _object(contract['option_retirement'])['dynamic_option_names'],
  )) {
    expect(encoded, isNot(contains(option)));
  }
  final normalized = SpecFile.fromJson(_object(jsonDecode(encoded)));
  expect(_engine(compileSpec(normalized)).parse('prefix x').value, ['hit']);
}

void role_loaded_spec(Map<String, Object?> _, _AdmissionState __) {
  _withScratch('loaded', (scratch) {
    final specFile = File('${scratch.path}/loaded.spec')
      ..writeAsStringSync(_mixedSource);
    final loaded = loadAndCompileSpec(
      SpecRequest.path(specFile.path),
      SpecLoadOptions(cwd: scratch),
    );
    expect(loaded.createEngine().parse('prefix x').value, ['hit']);
  });
}

void role_descriptor_v1(Map<String, Object?> contract, _AdmissionState _) {
  final compiled = _compile(
    '$_defaultSource\n$_andSource'.replaceFirst('Top::AND', 'Consume:AND'),
  );
  final descriptor = compiled.toDescriptorJson();
  final descriptorContract = _object(contract['descriptor_contract']);
  final meta = _object(descriptor['meta']);
  expect(
    meta['cursor_contract'],
    _object(descriptorContract['meta'])['cursor_contract'],
  );
  final spec = _object(descriptor['spec']);
  expect(_object(_object(spec['Top'])['meta'])['cursor_policy'], 'seek');
  expect(_object(_object(spec['Consume'])['meta'])['cursor_policy'], 'consume');
  expect(jsonEncode(descriptor), isNot(contains('"parse_mode"')));
}

void role_emitted_source_v2(Map<String, Object?> contract, _AdmissionState _) {
  final compiled = _compile(_mixedSource);
  final generated = _object(contract['generated_source_v2']);
  final emitted = emitDartSourceV2(compiled, _generatedIdentity);
  expect(emitted, contains(generated['contract_id']));
  expect(
    emitted,
    contains(
      'linkedspecGeneratedSourceFormat = ${generated['format_version']}',
    ),
  );
  expect(emitted, contains(_generatedIdentity));
  expect(emitted, contains('Object? execute('));
  expect(emitted, contains('Object? executeWithTrace('));
  expect(emitted, isNot(contains('"cursor_policy"')));
  for (final option in _strings(
    _object(contract['option_retirement'])['dynamic_option_names'],
  )) {
    expect(emitted, isNot(contains(option)));
  }
}

void role_generated_direct(
  Map<String, Object?> contract,
  _AdmissionState state,
) {
  final compiled = _compile(_defaultSource);
  final plan = buildGeneratedRulePlan(compiled);
  expect(plan.map((row) => row.toJson()), [
    {'label': 'Top', 'family': 'default'},
  ]);
  expect(
    executeGeneratedParserV2(compiled, plan, 'prefix x', _generatedIdentity),
    'hit',
  );
  final generated = _object(contract['generated_source_v2']);
  try {
    executeGeneratedParserV2(
      compiled,
      plan,
      'x',
      _generatedIdentity,
      actualContract: 'linkedspec-generated-source-v1',
    );
    fail('stale generated contract must fail');
  } on GeneratedSourceException catch (error) {
    expect(error.toJson()['code'], generated['v1_reconstruction_error']);
    state.observe(error.toJson()['code']! as String);
  }
}

void role_generated_trace(Map<String, Object?> _, _AdmissionState __) {
  _withScratch('trace', (scratch) {
    final traceFile = File('${scratch.path}/generated.trace');
    final compiled = _compile(_defaultSource);
    expect(
      executeGeneratedParserWithTraceV2(
        compiled,
        buildGeneratedRulePlan(compiled),
        'prefix x',
        LinkedSpecTraceConfig(
          level: LinkedSpecTraceLevel.debug,
          traceFile: traceFile.path,
          sinkMode: LinkedSpecTraceSinkMode.route,
          resetFile: true,
        ),
        _generatedIdentity,
      ),
      'hit',
    );
    final trace = traceFile.readAsStringSync();
    expect(trace, contains('dart_runtime:rule'));
    expect(trace, contains('label=Top'));
    expect(trace, contains('cursor_policy=seek'));
  });
}

void role_mixed_parent_child(Map<String, Object?> _, _AdmissionState __) {
  expect(_engine(_compile(_mixedSource)).parse('prefix x').value, ['hit']);
}

void role_recursion(Map<String, Object?> _, _AdmissionState __) {
  expect(_engine(_compile(_recursionSource)).parse('p junk xp junk z').value, [
    ['done'],
  ]);
}

void role_structural_ordered_landmarks(
  Map<String, Object?> _,
  _AdmissionState __,
) {
  expect(_engine(_compile(_orderedSource)).parse('junk h junk b').value, [
    'header',
    'body',
  ]);
}

void role_structural_anchored_choice(
  Map<String, Object?> _,
  _AdmissionState __,
) {
  expect(_engine(_compile(_anchoredSource)).parse('prefix x').value, isNull);
}

void role_static_option_removal(
  Map<String, Object?> contract,
  _AdmissionState _,
) {
  final retired = _strings(
    _object(contract['option_retirement'])['dynamic_option_names'],
  );
  final option = retired.singleWhere((item) => item.contains('M'));
  final forbidden = <String, List<String>>{
    'lib/src/runtime/interpreter.dart': [
      'this.$option =',
      'required this.$option',
    ],
    'lib/src/io/spec_loader.dart': ['LinkedSpecParseMode $option'],
    'lib/src/corpus/manifest_runner.dart': ['LinkedSpecParseMode $option'],
    'lib/src/parser/user_function_definition_parser.dart': ['$option:'],
    'lib/src/cli/primary_cli.dart': ['${retired.first}=', '--parse-mode MODE'],
  };
  for (final entry in forbidden.entries) {
    final path = entry.key;
    final source = File(path).readAsStringSync();
    for (final pattern in entry.value) {
      expect(
        source,
        isNot(contains(pattern)),
        reason: '$path retains $pattern',
      );
    }
  }
}

void role_primary_command(
  Map<String, Object?> contract,
  _AdmissionState state,
) {
  final success = runLinkedSpecDartPrimaryCli(const [
    '--inline-spec',
    _defaultSource,
    '--input',
    'prefix x',
  ]);
  expect(success.exitCode, 0);
  expect(success.stdoutBytes, utf8.encode('"hit"\n'));
  expect(success.stderrBytes, isEmpty);

  final cli = _object(_object(contract['option_retirement'])['cli']);
  final removed = runLinkedSpecDartPrimaryCli([
    '--inline-spec',
    _defaultSource,
    '--input',
    'x',
    cli['flag']! as String,
    'seek',
  ]);
  expect(removed.exitCode, cli['exit']);
  expect(removed.stdoutBytes, isEmpty);
  expect(
    utf8.decode(removed.stderrBytes),
    startsWith('linkedspec: ${cli['stderr']}\n\nUsage:\n'),
  );
  expect(linkedspecDartPrimaryCliHelp(), isNot(contains(cli['flag'])));
  final code =
      _objects(
            contract['diagnostics'],
          ).singleWhere((row) => row['stage'] == 'prepare_options')['code']!
          as String;
  state.observe(code);
}

void role_portable_diagnostics(
  Map<String, Object?> contract,
  _AdmissionState state,
) {
  final diagnostics = {
    for (final row in _objects(contract['diagnostics']))
      row['code']! as String: row,
  };
  final invalidRows = [
    ..._objects(
      contract['edge_resolution_cases'],
    ).where((row) => row['expected_error'] is String),
    ..._objects(
      contract['rule_edge_set_cases'],
    ).where((row) => row['expected_error'] is String),
  ];
  for (final row in invalidRows) {
    final id = row['id']! as String;
    final expectedCode = row['expected_error']! as String;
    final sources = row['sources'] == null
        ? [row['source']! as String]
        : _strings(row['sources']);
    final diagnostic = _diagnosticFor(
      _edgeSource(
        row['parent_family']! as String,
        sources,
        _strings(row['declared_rules']),
      ),
    );
    final expected = diagnostics[expectedCode]!;
    expect(diagnostic.code, expectedCode, reason: id);
    expect(diagnostic.stage, expected['stage'], reason: id);
    expect(
      diagnostic.fields.keys.toSet(),
      _strings(expected['fields']).toSet(),
      reason: id,
    );
    state.observe(expectedCode);
  }
  expect(state.observedDiagnostics, diagnostics.keys.toSet());
}

CompiledSpec _compile(String source) {
  final parsed = parseSpec(source);
  validateSpec(parsed);
  return compileSpec(parsed, validateSource: false);
}

LinkedSpecRuntimeEngine _engine(CompiledSpec compiled) =>
    LinkedSpecRuntimeEngine(compiled);

SpecPortableDiagnostic _diagnosticFor(String source) {
  final parsed = parseSpec(source);
  final normalized = SpecFile.fromJson(
    _object(jsonDecode(jsonEncode(parsed.toJson()))),
  );
  try {
    compileSpec(normalized).toDescriptorJson();
  } on SpecValidationException catch (error) {
    final diagnostic = error.diagnostic;
    if (diagnostic != null) {
      return diagnostic;
    }
    fail('expected portable diagnostic, got: ${error.message}');
  }
  fail('expected contract-invalid edge state to fail');
}

String _edgeSource(
  String parentFamily,
  List<String> sources,
  List<String> declaredRules,
) {
  final buffer = StringBuffer(parentFamily == 'and' ? 'Top::AND\n' : 'Top::\n');
  for (final source in sources) {
    buffer.writeln(' $source');
  }
  for (final label in declaredRules) {
    buffer.write('\n$label:\n /x/ /y/\n');
  }
  return buffer.toString();
}

T _withScratch<T>(String label, T Function(Directory scratch) body) {
  final scratch = Directory.systemTemp.createTempSync(
    'linkedspec-dart-cursor-admission-$label-',
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

final class _AdmissionState {
  final Set<String> observedDiagnostics = {};

  void observe(String code) {
    observedDiagnostics.add(code);
  }
}
