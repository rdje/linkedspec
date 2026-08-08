// FUTURE-PARITY-BACKLOG.14.2.3.0.1 — Dart source-boundary alias parity.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

const _input = 'é🙂  ab';

const _aliases = <String, String>{
  'capture_from_rule_start': 'capture_slice',
  'capture_len_from_rule_start': 'capture_slice_len',
  'capture_rest_length': 'capture_rest_len',
  'capture_slice_here': 'start_capture_slice',
  'capture_slice_length': 'capture_slice_len',
  'entry_named_map': 'entry_map',
  'match_named_map': 'match_map',
};

const _aliasNormalSource = r'''
Top::OR{1,1}
 /(?<name>ab)/
 I { started = capture_slice_here() }
 E {
   return(array(
     started,
     capture_from_rule_start(),
     capture_len_from_rule_start(),
     capture_slice_length(),
     capture_rest_length(),
     entry_named_map(),
     match_named_map()
   ))
 }
''';

const _canonicalNormalSource = r'''
Top::OR{1,1}
 /(?<name>ab)/
 I { started = start_capture_slice() }
 E {
   return(array(
     started,
     capture_slice(),
     capture_slice_len(),
     capture_slice_len(),
     capture_rest_len(),
     entry_map(),
     match_map()
   ))
 }
''';

const _aliasReversedSource = r'''
Top::OR{1,1}
 /(?<name>ab)/
 E {
   started = capture_slice_here();
   return(array(
     started,
     capture_from_rule_start(),
     capture_len_from_rule_start(),
     capture_slice_length(),
     capture_rest_length(),
     entry_named_map(),
     match_named_map()
   ))
 }
''';

const _canonicalReversedSource = r'''
Top::OR{1,1}
 /(?<name>ab)/
 E {
   started = start_capture_slice();
   return(array(
     started,
     capture_slice(),
     capture_slice_len(),
     capture_slice_len(),
     capture_rest_len(),
     entry_map(),
     match_map()
   ))
 }
''';

const _normalExpected = <Object?>[
  null,
  'é🙂  ',
  4,
  4,
  6,
  <String, Object?>{'name': 'ab'},
  <String, Object?>{'name': 'ab'},
];

const _reversedExpected = <Object?>[
  null,
  null,
  null,
  null,
  0,
  <String, Object?>{'name': 'ab'},
  <String, Object?>{'name': 'ab'},
];

void main() {
  test('all seven aliases resolve to their exact canonical helpers', () {
    expect(_aliases, hasLength(7));

    for (final MapEntry(:key, :value) in _aliases.entries) {
      expect(isKnownActionIrCallName(key), isTrue, reason: key);
      expect(isKnownActionIrCallName(value), isTrue, reason: value);
      expect(canonicalActionHelperName(key), value, reason: key);

      final zeroArg = resolveActionExpressionContracts(
        parseActionExpression('$key()'),
      );
      expect(zeroArg.ok, isTrue, reason: key);
      expect(zeroArg.contracts, hasLength(1), reason: key);
      expect(zeroArg.contracts.single.sourceName, key);
      expect(zeroArg.contracts.single.canonicalName, value);
      expect(zeroArg.contracts.single.positionalArgCount, 0);
      expect(zeroArg.contracts.single.canonicalized, isTrue);

      final oneArg = resolveActionExpressionContracts(
        parseActionExpression('$key(1)'),
      );
      expect(oneArg.ok, isTrue, reason: '$key authored arity');
      expect(oneArg.contracts.single.canonicalName, value);
      expect(oneArg.contracts.single.positionalArgCount, 1);
    }
  });

  test('unknown names retain exact structured runtime diagnostics', () {
    final engine = LinkedSpecRuntimeEngine(
      _compile(r'''
Top::
 /x/
 E { invented_source_boundary_alias() }
'''),
    );

    expect(
      () => engine.parse('x'),
      throwsA(
        isA<RuntimeInterpreterException>().having(
          (error) => error.diagnostic?.toJson(),
          'structured diagnostic',
          allOf(
            containsPair('stage', 'callable_codeblock_invocation'),
            containsPair('owner_stage', 'dart_runtime'),
            containsPair('code', 'unknown_helper'),
            containsPair('name', 'invented_source_boundary_alias'),
          ),
        ),
      ),
    );
  });

  test(
    'aliases equal canonical Unicode results across native reconstructed and generated plans',
    () {
      final aliasNormal = _assertRuntimeCarriers(
        _aliasNormalSource,
        'source-boundary/dart-alias-normal.spec',
        _normalExpected,
      );
      final canonicalNormal = _assertRuntimeCarriers(
        _canonicalNormalSource,
        'source-boundary/dart-canonical-normal.spec',
        _normalExpected,
      );
      final aliasReversed = _assertRuntimeCarriers(
        _aliasReversedSource,
        'source-boundary/dart-alias-reversed.spec',
        _reversedExpected,
      );
      final canonicalReversed = _assertRuntimeCarriers(
        _canonicalReversedSource,
        'source-boundary/dart-canonical-reversed.spec',
        _reversedExpected,
      );

      expect(_execute(aliasNormal), _execute(canonicalNormal));
      expect(_execute(aliasReversed), _execute(canonicalReversed));
    },
  );

  test(
    'independently compiled emitted aliases equal canonical helpers',
    () async {
      final compiled = <String, CompiledSpec>{
        'alias_normal': _compile(_aliasNormalSource),
        'canonical_normal': _compile(_canonicalNormalSource),
        'alias_reversed': _compile(_aliasReversedSource),
        'canonical_reversed': _compile(_canonicalReversedSource),
      };
      final scratch = Directory.systemTemp.createTempSync(
        'linkedspec-dart-source-boundary-aliases-',
      );
      final packageRoot = Directory.current.absolute;
      final pubCache = Directory('${scratch.path}/pub-cache')..createSync();

      try {
        Directory('${scratch.path}/lib').createSync();
        Directory('${scratch.path}/bin').createSync();
        File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_source_boundary_aliases_emitted
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ${jsonEncode(packageRoot.path)}
''');
        for (final MapEntry(:key, :value) in compiled.entries) {
          File('${scratch.path}/lib/$key.dart').writeAsStringSync(
            emitDartSourceV2(value, 'source-boundary/$key.spec'),
          );
        }
        File('${scratch.path}/bin/main.dart').writeAsStringSync(r'''
import 'dart:convert';

import 'package:linkedspec_source_boundary_aliases_emitted/alias_normal.dart'
    as alias_normal;
import 'package:linkedspec_source_boundary_aliases_emitted/alias_reversed.dart'
    as alias_reversed;
import 'package:linkedspec_source_boundary_aliases_emitted/canonical_normal.dart'
    as canonical_normal;
import 'package:linkedspec_source_boundary_aliases_emitted/canonical_reversed.dart'
    as canonical_reversed;

void main() {
  const input = 'é🙂  ab';
  final values = [
    alias_normal.execute(input),
    canonical_normal.execute(input),
    alias_reversed.execute(input),
    canonical_reversed.execute(input),
  ];
  if (jsonEncode(values[0]) != jsonEncode(values[1]) ||
      jsonEncode(values[2]) != jsonEncode(values[3])) {
    throw StateError('alias/canonical emitted result mismatch: $values');
  }
  print(jsonEncode(values));
}
''');

        final environment = {
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
        expect(jsonDecode((run.stdout as String).trim()), [
          _normalExpected,
          _normalExpected,
          _reversedExpected,
          _reversedExpected,
        ]);
      } finally {
        scratch.deleteSync(recursive: true);
      }
    },
  );
}

CompiledSpec _compile(String source) {
  final parsed = parseSpec(source);
  validateSpec(parsed);
  return compileSpec(parsed);
}

Object? _execute(CompiledSpec compiled) {
  return LinkedSpecRuntimeEngine(compiled).parse(_input).value;
}

CompiledSpec _assertRuntimeCarriers(
  String source,
  String identity,
  Object? expected,
) {
  final compiled = _compile(source);
  expect(_execute(compiled), expected, reason: 'native $identity');

  final parsed = parseSpec(source);
  final reconstructed = SpecFile.fromJson(
    Map<String, Object?>.from(jsonDecode(jsonEncode(parsed.toJson())) as Map),
  );
  validateSpec(reconstructed);
  final reconstructedCompiled = compileSpec(reconstructed);
  expect(
    _execute(reconstructedCompiled),
    expected,
    reason: 'reconstructed $identity',
  );

  final plan = buildGeneratedRulePlan(compiled);
  expect(
    executeGeneratedParserV2(compiled, plan, _input, identity),
    expected,
    reason: 'generated plan $identity',
  );
  return compiled;
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
