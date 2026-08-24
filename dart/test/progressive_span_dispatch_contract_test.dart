// FUTURE-PARITY-BACKLOG.14.6.4.3 — admitted Dart progressive carriers.
//
// Ordinary `dart test` discovery and canonical CI both run this exact
// final-path consumer. Its focused repository-local command is:
//
//   cd dart
//   bash ../tools/run_dart_project_data.sh test --reporter failures-only \
//     test/progressive_span_dispatch_contract_test.dart

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/runtime/bounded_child_parse_authority.dart';
import 'package:test/test.dart';

typedef _JsonObject = Map<String, Object?>;

const _contractPath =
    '../capability_conformance/progressive_span_dispatch_contract.json';
const _ciDriverPath = '../tools/run_ci_local.sh';
const _contractId = 'linkedspec-progressive-span-dispatch-v1';
const _sourceIdentity = 'progressive-span-dispatch/dart-red.spec';
const _fingerprint =
    'sha256:1111111111111111111111111111111111111111111111111111111111111111';
const _authoredSource = r'''
Top::
 I {
  span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored")
  value = dispatch_span("expr-v1", "Expr", span)
  return(value)
 }
 /never/
''';
const _expectedValue = <String, Object?>{'kind': 'identifier', 'text': 'a'};

void main() {
  final contract = _object(jsonDecode(File(_contractPath).readAsStringSync()));

  test(
    'freezes the neutral inventory and separate staged-registry boundary',
    () {
      expect(contract['contract_id'], _contractId);
      expect(contract['format'], 1);
      expect(
        contract['status'],
        'perl_rust_dart_and_julia_complete_other_backends_pending',
      );
      expect(contract['expected_counts'], <String, Object?>{
        'registry_entries': 2,
        'sources': 2,
        'view_cases': 8,
        'authority_cases': 6,
        'cancellation_cases': 6,
        'chain_cases': 8,
        'execution_cases': 4,
        'rust_carrier_paths': 9,
        'dart_carrier_paths': 8,
        'julia_carrier_paths': 9,
        'backend_guard_groups': 1,
        'backend_guard_paths': 5,
        'outward_guard_paths': 10,
        'diagnostics': 26,
        'rollout_legs': 9,
        'mutations': 106,
      });
      expect(_ids(contract, 'view_cases'), <String>[
        'unicode_middle',
        'empty_direct_span',
        'ascii_full',
        'source_mismatch',
        'reversed',
        'outside_source',
        'copied_text_smuggling',
        'noninteger_offset',
      ]);
      expect(_ids(contract, 'authority_cases'), <String>[
        'intersection_and_minima',
        'entry_cannot_elevate_caller',
        'required_capability_missing',
        'policy_intersection_empty',
        'source_detail_cannot_elevate',
        'caller_numeric_minimum',
      ]);
      expect(_ids(contract, 'cancellation_cases'), <String>[
        'fresh_budget',
        'already_cancelled',
        'deadline_reached',
        'budget_empty',
        'cost_exceeds_remaining',
        'token_replacement',
      ]);
      expect(_ids(contract, 'chain_cases'), <String>[
        'root',
        'strictly_smaller',
        'exact_repeat',
        'shifted_equal_length',
        'larger_repeat',
        'different_identity',
        'depth_limit',
        'call_limit',
      ]);
      expect(_ids(contract, 'execution_cases'), <String>[
        'detached_success',
        'false_payload',
        'child_failure_propagates',
        'live_handle_rejected',
      ]);

      final diagnostics = _list(
        contract['diagnostics'],
      ).map((row) => _object(row)['code']).toList(growable: false);
      expect(diagnostics, <String>[
        'progressive_parser_identity_literal_required',
        'progressive_parser_identity_invalid',
        'progressive_top_rule_literal_required',
        'progressive_top_rule_invalid',
        'progressive_span_binding_required',
        'progressive_span_shape_invalid',
        'progressive_span_source_mismatch',
        'progressive_span_out_of_bounds',
        'progressive_span_reversed',
        'progressive_registry_missing',
        'progressive_registry_mutation_forbidden',
        'progressive_implicit_load_forbidden',
        'progressive_top_rule_forbidden',
        'progressive_capability_denied',
        'progressive_policy_denied',
        'progressive_source_detail_denied',
        'progressive_cancelled',
        'progressive_deadline_exceeded',
        'progressive_budget_exhausted',
        'progressive_cancellation_authority_mismatch',
        'progressive_cycle_non_decreasing',
        'progressive_depth_exceeded',
        'progressive_call_limit_exceeded',
        'progressive_child_failed',
        'progressive_transaction_forbidden',
        'progressive_result_not_detached',
      ]);

      final rollout = _list(contract['rollout']).map(_object).toList();
      expect(rollout.map((row) => row['leg']), <String>[
        'neutral',
        'perl',
        'rust',
        'dart',
        'julia',
        'puc_lua',
        'luajit',
        'recurring',
        'public_no_drift',
      ]);
      expect(rollout.map((row) => row['status']), <String>[
        'complete',
        'complete',
        'complete',
        'complete',
        'complete',
        'pending',
        'pending',
        'pending',
        'pending',
      ]);
      expect(rollout[3]['paths'], <String>[
        'dart/test/progressive_span_dispatch_contract_test.dart',
      ]);
      expect(rollout[4]['paths'], <String>[
        'julia/test/progressive_span_dispatch_contract_test.jl',
      ]);

      final stagedJob = StagedParseJob(
        version: 1,
        jobId: 'progressive-dart-red',
        parentAstPath: const <String>['Top'],
        nodeKind: 'progressive_span_dispatch',
        payloadKind: 'source_span',
        text: 'a',
        sourceSpan: const StagedSourceSpan(
          start: 0,
          end: 1,
          lineStart: 1,
          lineEnd: 1,
        ),
        parserSpecId: 'expr-v1',
        topRule: 'Expr',
        resultPolicy: 'replace_field',
        resultField: 'value',
        failurePolicy: 'fail_only',
        diagnosticOwner: 'progressive_span_dispatch',
      );
      expect(
        () => executeStagedParseJob(stagedJob),
        throwsA(
          isA<StagedParserRegistryException>()
              .having(
                (error) => error.message,
                'message',
                contains('phase=resolve'),
              )
              .having(
                (error) => error.message,
                'message',
                contains('parser_spec_id=expr-v1'),
              )
              .having(
                (error) => error.message,
                'message',
                contains("unsupported parser spec id 'expr-v1'"),
              ),
        ),
      );
    },
  );

  test(
    'authored syntax compiles to one exclusive logical-only ActionIR node',
    () {
      final compiled = _compile(_authoredSource);
      final encoded = jsonEncode(compiled.toJson());
      final calls = _allMaps(compiled.toJson())
          .where(
            (node) => node['kind'] == 'call' && node['name'] == 'dispatch_span',
          )
          .toList(growable: false);
      final progressiveNodes = _allMaps(compiled.toJson())
          .where((node) => node['kind'] == 'progressive_dispatch_span')
          .toList(growable: false);
      expect(calls, isEmpty);
      expect(progressiveNodes, hasLength(1));
      expect(progressiveNodes.single, containsPair('target', 'value'));
      expect(progressiveNodes.single, containsPair('parser_id', 'expr-v1'));
      expect(progressiveNodes.single, containsPair('top_rule', 'Expr'));
      expect(progressiveNodes.single, containsPair('span', 'span'));
      expect(_occurrences(encoded, '"name":"dispatch_span"'), 0);
      expect(_occurrences(encoded, '"kind":"progressive_dispatch_span"'), 1);
      expect(encoded, isNot(contains('PROGRESSIVE_DISPATCH_SPAN')));
      expect(encoded, isNot(contains(_fingerprint)));
      expect(encoded, isNot(contains('ProgressiveExecutionSeed')));
      expect(encoded, isNot(contains('ProgressiveRegistryEntry')));
    },
  );

  test('malformed and residual generic dispatch forms fail statically', () {
    for (final (source, code) in <(String, String)>[
      (
        r'''Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span(parser_id, "Expr", span) } /never/''',
        'progressive_parser_identity_literal_required',
      ),
      (
        r'''Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("Expr/V1", "Expr", span) } /never/''',
        'progressive_parser_identity_invalid',
      ),
      (
        r'''Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", top_rule, span) } /never/''',
        'progressive_top_rule_literal_required',
      ),
      (
        r'''Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", "Bad-Rule", span) } /never/''',
        'progressive_top_rule_invalid',
      ),
      (
        r'''Top:: I { value = dispatch_span("expr-v1", "Expr", hash("source_id", "input")) } /never/''',
        'progressive_span_binding_required',
      ),
      (
        r'''Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); return(cat(dispatch_span("expr-v1", "Expr", span))) } /never/''',
        'progressive_span_binding_required',
      ),
      (
        r'''Top:: I { tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); recognition_rollback(tx); return(matched) }
Child:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", "Expr", span); return(value) } /never/''',
        'recognition_effect_forbidden:parser_registry_or_staged_dispatch',
      ),
    ]) {
      expect(
        () => _compile(source),
        throwsA(predicate((error) => '$error'.contains(code), code)),
      );
    }
  });

  test('live recognition transaction is rejected defensively', () {
    const source = r'''
Top:: I {
 tx = recognition_checkpoint()
 span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored")
 value = dispatch_span("expr-v1", "Expr", span)
 recognition_rollback(tx)
 return(value)
}
/never/
''';
    expect(
      () => LinkedSpecRuntimeEngine(
        _compile(source),
        boundedChildParseAuthority: _executionSeed('abc'),
      ).parse('abc'),
      throwsA(
        predicate(
          (error) => '$error'.contains('progressive_transaction_forbidden'),
          'live recognition transaction rejection',
        ),
      ),
    );
  });

  test('four_routes share one carrier and fresh opaque host authority', () {
    final parsed = parseSpecWithStagedUserFunctionDefinitions(_authoredSource);
    final compiled = compileSpec(parsed);
    final seed = _executionSeed('abc');
    expect(seed.toString(), 'ProgressiveExecutionSeed(<opaque>)');
    expect(identical(seed.start(), seed.start()), isFalse);
    expect(
      () => LinkedSpecRuntimeEngine(compiled).parse('abc'),
      throwsA(
        predicate(
          (error) => '$error'.contains('progressive_registry_missing'),
          'missing private authority rejection',
        ),
      ),
    );

    final native = LinkedSpecRuntimeEngine(
      compiled,
      boundedChildParseAuthority: seed,
    );
    final nativeResult = native.parse('abc');
    expect(nativeResult.value, _expectedValue);
    expect(nativeResult.cursorCharOffset, 0);
    expect(
      native.parse('abc').value,
      _expectedValue,
      reason: 'each top-level parse must start a fresh invocation budget',
    );

    final reconstructed = SpecFile.fromJson(
      _object(jsonDecode(jsonEncode(parsed.toJson()))),
    );
    validateSpec(reconstructed);
    expect(
      LinkedSpecRuntimeEngine(
        compileSpec(reconstructed),
        boundedChildParseAuthority: _executionSeed('abc'),
      ).parse('abc').value,
      _expectedValue,
    );

    expect(
      executeGeneratedParserV2(
        compiled,
        buildGeneratedRulePlan(compiled),
        'abc',
        _sourceIdentity,
        boundedChildParseAuthority: _executionSeed('abc'),
      ),
      _expectedValue,
    );
  });

  test(
    'independently analyzed emitted source carries only logical state',
    () async {
      final compiled = _compile(_authoredSource);
      final emitted = emitDartSourceV2(compiled, _sourceIdentity);
      expect(emitted, isNot(contains(_fingerprint)));
      expect(emitted, isNot(contains('ProgressiveCompiledAuthority')));
      expect(emitted, isNot(contains('ProgressiveRegistryEntry(')));
      expect(emitted, isNot(contains('ProgressiveCancellationToken(')));
      expect(emitted, isNot(contains('PROGRESSIVE_DISPATCH_SPAN')));

      final packageRoot = Directory.current.absolute;
      final scratch = Directory(
        '${packageRoot.path}/.dart_tool/linkedspec-dart-progressive-carrier-'
        '$pid-${DateTime.now().microsecondsSinceEpoch}',
      )..createSync(recursive: true);
      try {
        final generatedPath = '${scratch.path}/generated.dart';
        final mainPath = '${scratch.path}/main.dart';
        File(generatedPath).writeAsStringSync(emitted);
        File(mainPath).writeAsStringSync(_emittedMain);
        await _expectProcessSuccess(packageRoot, Platform.environment, <String>[
          'analyze',
          '--fatal-infos',
          '--fatal-warnings',
          generatedPath,
          mainPath,
        ]);
        final run = await Process.run(
          Platform.resolvedExecutable,
          <String>['run', mainPath],
          workingDirectory: packageRoot.path,
          environment: Platform.environment,
        );
        expect(
          run.exitCode,
          0,
          reason: 'emitted progressive carrier failed:\n${run.stderr}',
        );
        expect(_object(jsonDecode('${run.stdout}'.trim())), _expectedValue);
      } finally {
        scratch.deleteSync(recursive: true);
      }
    },
  );

  test('consumer is admitted once while the authority stays private', () {
    expect(
      File('test/progressive_span_dispatch_contract_test.dart').existsSync(),
      isTrue,
      reason: 'ordinary discovery must own the exact admitted consumer',
    );
    expect(
      File(
        'test_dormant/progressive_span_dispatch_contract_test.dart',
      ).existsSync(),
      isFalse,
      reason: 'admission must not retain a duplicate dormant consumer',
    );
    final ci = File(_ciDriverPath).readAsStringSync();
    expect(
      _occurrences(
        ci,
        'require_tracked_file '
        'dart/test/progressive_span_dispatch_contract_test.dart',
      ),
      1,
    );
    expect(
      _occurrences(
        ci,
        'running exact Dart progressive span-dispatch admission consumer',
      ),
      1,
    );
    expect(
      _occurrences(
        ci,
        '(cd dart && bash ../tools/run_dart_project_data.sh test '
        '--reporter failures-only '
        'test/progressive_span_dispatch_contract_test.dart)',
      ),
      1,
    );
    final umbrella = File('lib/linkedspec_dart.dart').readAsStringSync();
    for (final token in <String>[
      'dispatch_span',
      'PROGRESSIVE_DISPATCH_SPAN',
      'progressive_span_dispatch',
      'ProgressiveExecutionSeed',
    ]) {
      expect(umbrella, isNot(contains(token)));
    }
  });
}

ProgressiveExecutionSeed _executionSeed(String input) {
  final ceilings = ProgressiveCeilings(
    sourceDetail: ProgressiveSourceDetail.text,
    policyModes: const <String>['deterministic', 'fail-only'],
    maxSteps: 100,
    maxResultNodes: 100,
    maxDiagnosticBytes: 4096,
  );
  final registry = ProgressiveRegistry(
    entries: <ProgressiveRegistryEntry>[
      ProgressiveRegistryEntry(
        parserId: 'expr-v1',
        compiledAuthority: (request) => <String, Object?>{
          'kind': 'identifier',
          'text': request.sourceView.text,
        },
        fingerprint: _fingerprint,
        allowedTopRules: const <String>['Expr'],
        capabilities: const <String>['parse'],
        ceilings: ceilings,
      ),
    ],
  );
  return ProgressiveExecutionSeed(
    registry: registry,
    invocation: ProgressiveInvocationConfig(
      sources: <String, String>{'input': input},
      sourceId: 'input',
      cancellationToken: ProgressiveCancellationToken(),
      clock: const ProgressiveClock(_zeroClock),
      deadlineTick: 100,
      remainingSteps: 100,
      maxDepth: 8,
      maxCalls: 16,
    ),
    callerCapabilities: const <String>['parse'],
    requiredCapabilities: const <String>['parse'],
    callerCeilings: ceilings,
    requiredSourceDetail: ProgressiveSourceDetail.none,
    dispatchCost: 1,
  );
}

int _zeroClock() => 0;

const _emittedMain = r'''
import 'dart:convert';

import 'package:linkedspec_dart/src/runtime/bounded_child_parse_authority.dart';

import 'generated.dart' as generated;

int zeroClock() => 0;

ProgressiveExecutionSeed executionSeed(String input) {
  final ceilings = ProgressiveCeilings(
    sourceDetail: ProgressiveSourceDetail.text,
    policyModes: const <String>['deterministic', 'fail-only'],
    maxSteps: 100,
    maxResultNodes: 100,
    maxDiagnosticBytes: 4096,
  );
  return ProgressiveExecutionSeed(
    registry: ProgressiveRegistry(
      entries: <ProgressiveRegistryEntry>[
        ProgressiveRegistryEntry(
          parserId: 'expr-v1',
          compiledAuthority: (request) => <String, Object?>{
            'kind': 'identifier',
            'text': request.sourceView.text,
          },
          fingerprint:
              'sha256:1111111111111111111111111111111111111111111111111111111111111111',
          allowedTopRules: const <String>['Expr'],
          capabilities: const <String>['parse'],
          ceilings: ceilings,
        ),
      ],
    ),
    invocation: ProgressiveInvocationConfig(
      sources: <String, String>{'input': input},
      sourceId: 'input',
      cancellationToken: ProgressiveCancellationToken(),
      clock: const ProgressiveClock(zeroClock),
      deadlineTick: 100,
      remainingSteps: 100,
      maxDepth: 8,
      maxCalls: 16,
    ),
    callerCapabilities: const <String>['parse'],
    requiredCapabilities: const <String>['parse'],
    callerCeilings: ceilings,
    requiredSourceDetail: ProgressiveSourceDetail.none,
    dispatchCost: 1,
  );
}

void main() {
  print(
    jsonEncode(
      generated.execute(
        'abc',
        boundedChildParseAuthority: executionSeed('abc'),
      ),
    ),
  );
}
''';

CompiledSpec _compile(String source) =>
    compileSpec(parseSpecWithStagedUserFunctionDefinitions(source));

List<String> _ids(_JsonObject contract, String field) => _list(
  contract[field],
).map((row) => _object(row)['id']! as String).toList(growable: false);

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
        'dart ${arguments.join(' ')} failed:\nstdout:\n${result.stdout}'
        '\nstderr:\n${result.stderr}',
  );
  return result;
}

int _occurrences(String haystack, String needle) =>
    RegExp(RegExp.escape(needle)).allMatches(haystack).length;

_JsonObject _object(Object? value) => (value! as Map).cast<String, Object?>();

List<Object?> _list(Object? value) => (value! as List).cast<Object?>();
