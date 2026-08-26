// FUTURE-PARITY-BACKLOG.14.7.5.0 — dormant Dart staged-AST enrichment RED.
//
// Ordinary `dart test` discovery and canonical CI omit test_dormant/. Before
// admission, run this exact repository-local consumer from dart/:
//
//   bash ../tools/run_dart_project_data.sh test --reporter failures-only \
//     test_dormant/staged_ast_enrichment_contract_test.dart
//
// The contract freezes the neutral inventory, unchanged function-body v1
// compatibility, and all four current Dart observation routes without changing
// production behavior. Its sole intentional failure is the missing dedicated
// `STAGED_PARSE_JOB_MARKER` plus typed `staged_parse_job_v2` provenance; the
// current generic `parse_job(...)` call and `unknown_helper` rejection are not
// an implementation.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

typedef _JsonObject = Map<String, Object?>;

const _contractPath =
    '../capability_conformance/staged_ast_enrichment_contract.json';
const _ciDriverPath = '../tools/run_ci_local.sh';
const _contractId = 'linkedspec-staged-ast-enrichment-v1';
const _sourceIdentity = 'staged-ast-enrichment/dart-red.spec';
const _finalConsumerPath = 'test/staged_ast_enrichment_contract_test.dart';
const _dormantConsumerPath =
    'test_dormant/staged_ast_enrichment_contract_test.dart';
const _authoredSource = r'''
Top::
 /([^;]+);/
 I {
  job_marker = parse_job(entry_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail"))
  return(job_marker)
 }
''';

void main() {
  final contract = _object(jsonDecode(File(_contractPath).readAsStringSync()));

  test('freezes neutral authority and unchanged function-body v1', () {
    expect(contract['contract_id'], _contractId);
    expect(contract['format'], 1);
    expect(
      contract['status'],
      'neutral_perl_and_rust_complete_dart_dormant_red_'
      'later_backends_pending',
    );
    expect(contract['expected_counts'], <String, Object?>{
      'registry_entries': 4,
      'sources': 2,
      'provenance_cases': 8,
      'job_id_cases': 3,
      'resolution_cases': 8,
      'authority_cases': 6,
      'cache_cases': 10,
      'queue_cases': 4,
      'isolation_cases': 3,
      'stitch_cases': 4,
      'failure_cases': 3,
      'chain_cases': 10,
      'detachment_cases': 5,
      'carrier_requirements': 4,
      'backend_consumers': 5,
      'runtime_routes': 6,
      'outward_guard_paths': 10,
      'diagnostics': 37,
      'rollout_legs': 9,
      'ownership_rows': 35,
      'mutations': 85,
    });

    final expectedIds = <String, List<String>>{
      'provenance_cases': <String>[
        'direct_unicode',
        'direct_empty',
        'derived_ordered',
        'direct_reversed',
        'direct_out_of_bounds',
        'derived_empty',
        'derived_segment_invalid',
        'copied_text_smuggling',
      ],
      'job_id_cases': <String>[
        'direct_identity',
        'derived_identity',
        'default_top_normalized_before_identity',
      ],
      'resolution_cases': <String>[
        'alias_first',
        'declaring_relative_second',
        'search_root_order',
        'provider_order',
        'missing',
        'same_priority_ambiguous',
        'alias_relative_collision',
        'path_traversal_rejected',
      ],
      'authority_cases': <String>[
        'intersection_and_minima',
        'entry_cannot_elevate_caller',
        'required_capability_missing',
        'policy_denied',
        'source_detail_denied',
        'helper_version_mismatch',
      ],
      'cache_cases': <String>[
        'base',
        'identical',
        'content_changed',
        'graph_changed',
        'top_changed',
        'spec_version_changed',
        'helper_version_changed',
        'staged_version_changed',
        'capability_order_normalized',
        'capability_set_changed',
      ],
      'queue_cases': <String>[
        'parent_then_provenance',
        'job_id_tie_break',
        'derived_order_key',
        'breadth_first_recursive_enqueue',
      ],
      'isolation_cases': <String>[
        'siblings_receive_fresh_runtime_contexts',
        'falsey_child_state_does_not_escape',
        'shared_budget_spans_next_depth',
      ],
      'stitch_cases': <String>[
        'replace_marker',
        'replace_field',
        'sibling_field',
        'append_child',
      ],
      'failure_cases': <String>[
        'fail_aborts_composed_parse',
        'keep_text_continues',
        'diagnostic_node_uses_result_target',
      ],
      'chain_cases': <String>[
        'direct_strictly_smaller',
        'derived_strictly_smaller',
        'exact_tuple_cycle',
        'same_extent_non_decreasing',
        'derived_not_contained',
        'depth_exceeded',
        'call_limit_exceeded',
        'cancelled',
        'deadline_exceeded',
        'budget_exhausted',
      ],
      'detachment_cases': <String>[
        'plain_nested',
        'falsey_scalar',
        'live_parser_handle',
        'reference_cycle_marker',
        'node_limit',
      ],
    };
    for (final MapEntry(:key, :value) in expectedIds.entries) {
      expect(_ids(contract, key), value, reason: key);
    }

    final consumers = _list(
      contract['backend_consumers'],
    ).map(_object).toList(growable: false);
    expect(consumers.map((row) => row['status']), <String>[
      'complete',
      'complete',
      'dormant_red',
      'pending_absent',
      'pending_absent',
    ]);
    expect(consumers[2], <String, Object?>{
      'backend': 'dart',
      'owner': 'FUTURE-PARITY-BACKLOG.14.7.5.0',
      'path': 'dart/$_finalConsumerPath',
      'dormant_path': 'dart/$_dormantConsumerPath',
      'status': 'dormant_red',
    });
    expect(
      _list(contract['rollout']).map((row) => _object(row)['status']),
      <String>[
        'complete',
        'complete',
        'complete',
        'pending',
        'pending',
        'pending',
        'pending',
        'pending',
        'pending',
      ],
    );
    expect(contract['compatibility_v1'], <String, Object?>{
      'status': 'current_unchanged',
      'record_version': 1,
      'parser_spec_id': 'actionir-body.spec',
      'resolved_spec_id': 'builtin:actionir-body.spec',
      'top_rule': 'action_block',
      'result_policy': 'replace_field',
      'result_field': 'body_ast',
      'failure_policy': 'fail',
      'source_provenance':
          'legacy copied exact text plus numeric offset and line span',
      'general_authoring': false,
      'upgrade_to_v2': 'explicit_only',
    });

    final v1Job = _v1Job();
    final result = executeStagedParseJobs(<StagedParseJob>[
      v1Job,
    ]).single.toJson();
    expect(result['phases'], <String>['resolve', 'load', 'compile', 'execute']);
    expect(result['resolved_spec_id'], actionIrBodyResolvedSpecId);
    expect(result['registry_provider'], 'builtin');
    expect(result['result_policy'], 'replace_field');
    expect(result['result_field'], 'body_ast');
    expect(result['failure_policy'], 'fail');
    expect(_object(result['result'])['kind'], 'action_block');

    expect(
      () => executeStagedParseJob(_v1Job(topRule: 'missing_top')),
      throwsA(
        isA<StagedParserRegistryException>().having(
          (error) => error.message,
          'complete v1 context',
          allOf(<Matcher>[
            contains('phase=compile'),
            contains('parent_ast_path=functions.0.body_source'),
            contains('parser_spec_id=actionir-body.spec'),
            contains('resolved_spec_id=builtin:actionir-body.spec'),
            contains('top_rule=missing_top'),
            contains('payload_kind=function_body'),
            contains('source_span=10-29'),
            contains('failure_policy=fail'),
          ]),
        ),
      ),
    );

    final generalJob = StagedParseJob(
      version: 2,
      jobId: 'parse_job:v2:sha256:dormant-red',
      parentAstPath: const <String>['Top', 'job_marker'],
      nodeKind: 'expression',
      payloadKind: 'embedded_expression',
      text: '1+2',
      sourceSpan: const StagedSourceSpan(
        start: 0,
        end: 3,
        lineStart: 1,
        lineEnd: 1,
      ),
      parserSpecId: 'expr-v1',
      topRule: 'Expr',
      resultPolicy: 'sibling_field',
      resultField: 'expression_ast',
      failurePolicy: 'fail',
    );
    expect(
      () => executeStagedParseJob(generalJob),
      throwsA(
        isA<StagedParserRegistryException>().having(
          (error) => error.message,
          'general v2 rejection',
          allOf(<Matcher>[
            contains('phase=resolve'),
            contains('parser_spec_id=expr-v1'),
            contains("unsupported parser spec id 'expr-v1'"),
          ]),
        ),
      ),
    );
  });

  test('current authored syntax remains exactly one generic helper call', () {
    final compiled = _compile(_authoredSource);
    final encoded = jsonEncode(compiled.toJson());
    final assignments = _allMaps(compiled.toJson())
        .where(
          (node) =>
              node['kind'] == 'assign_scalar' && node['name'] == 'job_marker',
        )
        .toList(growable: false);
    final calls = _allMaps(compiled.toJson())
        .where((node) => node['kind'] == 'call' && node['name'] == 'parse_job')
        .toList(growable: false);

    expect(assignments, hasLength(1));
    expect(calls, hasLength(1));
    expect(_list(calls.single['args']), hasLength(2));
    expect(_occurrences(encoded, '"name":"parse_job"'), 1);
    for (final missing in <String>[
      'staged_parse_job_marker',
      'STAGED_PARSE_JOB_MARKER',
      'staged_parse_job_v2',
    ]) {
      expect(encoded, isNot(contains(missing)));
    }
  });

  test(
    'native reconstructed and generated-plan routes reject generic call',
    () {
      final parsed = parseSpecWithStagedUserFunctionDefinitions(
        _authoredSource,
      );
      final compiled = compileSpec(parsed);
      _expectUnknownHelper(
        () => LinkedSpecRuntimeEngine(compiled).parse('1+2;'),
        'native',
      );

      final reconstructed = SpecFile.fromJson(
        _object(jsonDecode(jsonEncode(parsed.toJson()))),
      );
      validateSpec(reconstructed);
      _expectUnknownHelper(
        () => LinkedSpecRuntimeEngine(compileSpec(reconstructed)).parse('1+2;'),
        'normalized reconstructed',
      );

      expect(
        () => executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          '1+2;',
          _sourceIdentity,
        ),
        throwsA(
          isA<GeneratedSourceException>()
              .having(
                (error) => error.code,
                'code',
                GeneratedSourceCode.generatedExecutionFailed,
              )
              .having((error) => error.ruleLabel, 'rule label', 'Top')
              .having(
                (error) => error.detail,
                'generic helper detail',
                allOf(<Matcher>[
                  contains('unknown_helper'),
                  contains('name="parse_job"'),
                  contains('rule_label="Top"'),
                ]),
              ),
        ),
      );
    },
  );

  test(
    'independently analyzed emitted source preserves current rejection',
    () async {
      final emitted = emitDartSourceV2(
        _compile(_authoredSource),
        _sourceIdentity,
      );
      for (final missing in <String>[
        'staged_parse_job_marker',
        'STAGED_PARSE_JOB_MARKER',
        'staged_parse_job_v2',
      ]) {
        expect(emitted, isNot(contains(missing)));
      }

      final packageRoot = Directory.current.absolute;
      final scratch = Directory(
        '${packageRoot.path}/.dart_tool/linkedspec-dart-staged-ast-red-'
        '$pid-${DateTime.now().microsecondsSinceEpoch}',
      )..createSync(recursive: true);
      try {
        final generatedPath = '${scratch.path}/generated.dart';
        final mainPath = '${scratch.path}/main.dart';
        File(generatedPath).writeAsStringSync(emitted);
        File(mainPath).writeAsStringSync(_emittedMain);
        await _expectProcessSuccess(packageRoot, <String>[
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
          reason: 'emitted staged-AST RED failed:\n${run.stderr}',
        );
        expect(
          '${run.stdout}'.trim(),
          allOf(<Matcher>[
            contains('Generated Dart parser execution failed'),
            contains('unknown_helper'),
            contains('name="parse_job"'),
            contains('rule_label="Top"'),
          ]),
        );
      } finally {
        scratch.deleteSync(recursive: true);
      }
    },
  );

  test('RED requires one dedicated marker with typed provenance', () {
    expect(File(_dormantConsumerPath).existsSync(), isTrue);
    expect(File(_finalConsumerPath).existsSync(), isFalse);
    final ci = File(_ciDriverPath).readAsStringSync();
    expect(ci, isNot(contains('dart/$_dormantConsumerPath')));
    expect(ci, isNot(contains('dart/$_finalConsumerPath')));
    final umbrella = File('lib/linkedspec_dart.dart').readAsStringSync();
    for (final privateToken in <String>[
      'parse_job(text_expr',
      'STAGED_PARSE_JOB_MARKER',
      _contractId,
    ]) {
      expect(umbrella, isNot(contains(privateToken)));
    }

    fail(
      'LINKEDSPEC_STAGED_AST_ENRICHMENT_DART_RED: missing '
      'node=[STAGED_PARSE_JOB_MARKER]; typed provenance '
      'sidecar=[staged_parse_job_v2] unavailable; generic parse_job helper '
      'rejection is not an implementation',
    );
  });
}

StagedParseJob _v1Job({String topRule = actionIrBodyTopRule}) {
  const bodySource = 'return(trim(value))';
  return StagedParseJob(
    version: 1,
    jobId:
        'parse_job:function_body:functions.0.body_source:'
        'actionir-body.spec:action_block:10-29',
    parentAstPath: const <String>['functions', '0', 'body_source'],
    nodeKind: 'function_definition',
    payloadKind: 'function_body',
    functionName: 'normalize',
    params: const <String>['value'],
    arity: 1,
    text: bodySource,
    sourceSpan: const StagedSourceSpan(
      start: 10,
      end: 29,
      lineStart: 1,
      lineEnd: 1,
    ),
    parserSpecId: actionIrBodySpecId,
    topRule: topRule,
    resultPolicy: 'replace_field',
    resultField: 'body_ast',
    failurePolicy: 'fail',
    diagnosticOwner: 'function_body',
  );
}

void _expectUnknownHelper(Object? Function() execute, String route) {
  expect(
    execute,
    throwsA(
      isA<RuntimeInterpreterException>()
          .having(
            (error) => error.message,
            '$route message',
            'unknown_helper name="parse_job" rule_label="Top"',
          )
          .having(
            (error) => error.diagnostic?.code,
            '$route diagnostic code',
            'unknown_helper',
          )
          .having(
            (error) => error.diagnostic?.name,
            '$route helper name',
            'parse_job',
          )
          .having(
            (error) => error.diagnostic?.ruleLabel,
            '$route rule label',
            'Top',
          ),
    ),
  );
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

Future<ProcessResult> _expectProcessSuccess(
  Directory workingDirectory,
  List<String> arguments,
) async {
  final result = await Process.run(
    Platform.resolvedExecutable,
    arguments,
    workingDirectory: workingDirectory.path,
    environment: Platform.environment,
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

const _emittedMain = r'''
import 'generated.dart' as generated;

void main() {
  try {
    generated.execute('1+2;');
    print('unexpected-success');
  } on Object catch (error) {
    print(error);
  }
}
''';
