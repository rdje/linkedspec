// FUTURE-PARITY-BACKLOG.14.6.4.0 — dormant Dart progressive-dispatch RED.
//
// Ordinary `dart test` discovery ignores test_dormant/. Before admission, run
// this exact final-path consumer through repository-local project data:
//
//   cd dart
//   bash ../tools/run_dart_project_data.sh test --reporter failures-only \
//     test_dormant/progressive_span_dispatch_contract_test.dart
//
// The sole intentional failure is the absent dedicated progressive ActionIR
// node. Generic unknown-helper fallback is not an implementation.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

typedef _JsonObject = Map<String, Object?>;

const _contractPath =
    '../capability_conformance/progressive_span_dispatch_contract.json';
const _ciDriverPath = '../tools/run_ci_local.sh';
const _contractId = 'linkedspec-progressive-span-dispatch-v1';
const _sourceIdentity = 'progressive-span-dispatch/dart-red.spec';
const _authoredSource = r'''
Top::
 I {
  span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored")
  value = dispatch_span("expr-v1", "Expr", span)
  return(value)
 }
 /never/
''';

void main() {
  final contract = _object(jsonDecode(File(_contractPath).readAsStringSync()));

  test(
    'freezes the neutral inventory and separate staged-registry boundary',
    () {
      expect(contract['contract_id'], _contractId);
      expect(contract['format'], 1);
      expect(
        contract['status'],
        'perl_and_rust_complete_other_backends_pending',
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
        'backend_guard_groups': 3,
        'backend_guard_paths': 11,
        'outward_guard_paths': 10,
        'diagnostics': 26,
        'rollout_legs': 9,
        'mutations': 95,
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
        'pending',
        'pending',
        'pending',
        'pending',
        'pending',
        'pending',
      ]);
      expect(rollout[3]['paths'], isEmpty);

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

  test('authored syntax remains one generic call in compiled state', () {
    final compiled = _compile(_authoredSource);
    final encoded = jsonEncode(compiled.toJson());
    final calls = _allMaps(compiled.toJson())
        .where(
          (node) => node['kind'] == 'call' && node['name'] == 'dispatch_span',
        )
        .toList(growable: false);
    expect(calls, hasLength(1));
    expect(_list(calls.single['args']), hasLength(3));
    expect(
      _allMaps(
        compiled.toJson(),
      ).where((node) => node['kind'] == 'progressive_dispatch_span'),
      isEmpty,
    );
    expect(_occurrences(encoded, '"name":"dispatch_span"'), 1);
    expect(encoded, isNot(contains('PROGRESSIVE_DISPATCH_SPAN')));
  });

  test(
    'native reconstructed and generated-plan carriers share unknown-helper RED',
    () {
      final parsed = parseSpecWithStagedUserFunctionDefinitions(
        _authoredSource,
      );
      final compiled = compileSpec(parsed);
      _expectUnknownHelper(
        () => LinkedSpecRuntimeEngine(compiled).parse('abc'),
        'native',
      );

      final reconstructed = SpecFile.fromJson(
        _object(jsonDecode(jsonEncode(parsed.toJson()))),
      );
      validateSpec(reconstructed);
      _expectUnknownHelper(
        () => LinkedSpecRuntimeEngine(compileSpec(reconstructed)).parse('abc'),
        'reconstructed',
      );

      _expectUnknownHelper(
        () => executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          'abc',
          _sourceIdentity,
        ),
        'generated-plan',
      );
    },
  );

  test('independently analyzed emitted source reaches the same RED', () async {
    final compiled = _compile(_authoredSource);
    final emitted = emitDartSourceV2(compiled, _sourceIdentity);
    final packageRoot = Directory.current.absolute;
    final scratch = Directory(
      '${packageRoot.path}/.dart_tool/linkedspec-dart-progressive-red-'
      '${pid}-${DateTime.now().microsecondsSinceEpoch}',
    )..createSync(recursive: true);
    try {
      final generatedPath = '${scratch.path}/generated.dart';
      final mainPath = '${scratch.path}/main.dart';
      File(generatedPath).writeAsStringSync(emitted);
      File(mainPath).writeAsStringSync(r'''
import 'dart:convert';

import 'generated.dart' as generated;

void main() {
  print(jsonEncode(generated.execute('abc')));
}
''');
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
      expect(run.exitCode, isNot(0));
      expect('${run.stdout}\n${run.stderr}', contains('unknown_helper'));
      expect('${run.stdout}\n${run.stderr}', contains('dispatch_span'));
    } finally {
      scratch.deleteSync(recursive: true);
    }
  });

  test('final path stops only at the missing dedicated node', () {
    expect(
      File('test/progressive_span_dispatch_contract_test.dart').existsSync(),
      isFalse,
      reason: 'the Dart consumer must remain outside ordinary discovery',
    );
    expect(
      File(_ciDriverPath).readAsStringSync(),
      isNot(
        contains(
          'dart/test_dormant/progressive_span_dispatch_contract_test.dart',
        ),
      ),
      reason: 'the dormant Dart consumer must remain absent from canonical CI',
    );

    final progressiveNodes = _allMaps(_compile(_authoredSource).toJson())
        .where((node) => node['kind'] == 'progressive_dispatch_span')
        .toList(growable: false);
    expect(
      progressiveNodes,
      hasLength(1),
      reason:
          'LINKEDSPEC_PROGRESSIVE_SPAN_DISPATCH_RED: missing dedicated '
          'node=[PROGRESSIVE_DISPATCH_SPAN]; generic dispatch_span '
          'unknown-helper fallback is not an implementation',
    );
  });
}

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

void _expectUnknownHelper(Object? Function() operation, String carrier) {
  expect(
    operation,
    throwsA(
      predicate(
        (error) =>
            '$error'.contains('unknown_helper') &&
            '$error'.contains('dispatch_span'),
        '$carrier carrier must reject only generic dispatch_span fallback',
      ),
    ),
  );
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
