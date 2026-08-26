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
import 'package:linkedspec_dart/src/runtime/source_location.dart';
import 'package:linkedspec_dart/src/runtime/staged_parse_job.dart';
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
 /([^;]+);/ -> Top { job_marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail")); return(job_marker) }
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

  test('exclusive assignment lowers to one typed dedicated ActionIR node', () {
    final compiled = _compile(_authoredSource);
    final encoded = jsonEncode(compiled.toJson());
    final declarations = _allMaps(compiled.toJson())
        .where(
          (node) =>
              node['kind'] == 'staged_parse_job_marker' &&
              node['target'] == 'job_marker',
        )
        .toList(growable: false);
    final calls = _allMaps(compiled.toJson())
        .where((node) => node['kind'] == 'call' && node['name'] == 'parse_job')
        .toList(growable: false);

    expect(declarations, hasLength(1));
    expect(calls, isEmpty);
    expect(declarations.single['version'], 2);
    expect(declarations.single['sidecar_kind'], 'staged_parse_job_v2');
    expect(declarations.single['effect'], 'staged_parse_job_declaration');
    expect(declarations.single['text_plan'], <String, Object?>{
      'kind': 'direct_span',
      'source': 'match_group',
      'index': 0,
    });
    expect(declarations.single['options'], <String, Object?>{
      'node_kind': 'expression',
      'payload_kind': 'embedded_expression',
      'spec': 'expr-v1',
      'top': 'Expr',
      'result_policy': 'sibling_field',
      'into': 'expression_ast',
      'on_error': 'fail',
      'required_capabilities': <String>[],
    });
    expect(_occurrences(encoded, '"name":"parse_job"'), 0);
    expect(_occurrences(encoded, '"kind":"staged_parse_job_marker"'), 1);
  });

  test(
    'native reconstructed and generated-plan routes preserve one marker',
    () {
      final parsed = parseSpecWithStagedUserFunctionDefinitions(
        _authoredSource,
      );
      final compiled = compileSpec(parsed);
      expect(
        LinkedSpecRuntimeEngine(compiled).parse('1+2;').value,
        _expectedMarker(),
      );

      final reconstructed = SpecFile.fromJson(
        _object(jsonDecode(jsonEncode(parsed.toJson()))),
      );
      validateSpec(reconstructed);
      expect(
        LinkedSpecRuntimeEngine(compileSpec(reconstructed)).parse('1+2;').value,
        _expectedMarker(),
      );

      expect(
        executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          '1+2;',
          _sourceIdentity,
        ),
        _expectedMarker(),
      );
    },
  );

  test(
    'independently analyzed emitted source preserves the logical marker',
    () async {
      final emitted = emitDartSourceV2(
        _compile(_authoredSource),
        _sourceIdentity,
      );
      expect(emitted, contains('executeGeneratedParserV2'));
      expect(emitted, isNot(contains('STAGED_PARSE_JOB_MARKER')));

      final packageRoot = Directory.current.absolute;
      final scratch = Directory(
        '${packageRoot.path}/.dart_tool/linkedspec-dart-staged-ast-marker-'
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
          reason: 'emitted staged-AST marker failed:\n${run.stderr}',
        );
        expect(_object(jsonDecode('${run.stdout}'.trim())), _expectedMarker());
      } finally {
        scratch.deleteSync(recursive: true);
      }
    },
  );

  test('neutral provenance accepts exact records and rejects smuggling', () {
    final sources = <String, String>{
      for (final row in _list(contract['sources']).map(_object))
        row['source_id']! as String: row['text']! as String,
    };
    final authority = SourceAuthority(sources: sources);
    for (final row in _list(contract['provenance_cases']).map(_object)) {
      if (row['accepted'] == true) {
        final result = validateAndMaterializeStagedProvenance(
          authority: authority,
          record: row['provenance'],
          origin: 'contract:parse_job',
        );
        expect(
          result['text'],
          row['materialized_text'],
          reason: '${row['id']}',
        );
        expect(result['provenance'], row['provenance'], reason: '${row['id']}');
      } else {
        expect(
          () => validateAndMaterializeStagedProvenance(
            authority: authority,
            record: row['provenance'],
            origin: 'contract:parse_job',
          ),
          throwsA(
            isA<StagedParseJobDeclarationException>().having(
              (error) => error.toJson()['code'],
              '${row['id']} code',
              row['diagnostic'],
            ),
          ),
        );
      }
    }
  });

  test('runtime materializes Unicode direct and ordered-derived spans', () {
    const directSource = r'''
Top::
 /(é🙂)(B);/ -> Top { job_marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail")); return(job_marker) }
''';
    final direct = _object(
      LinkedSpecRuntimeEngine(_compile(directSource)).parse('Aé🙂B;C').value,
    );
    final directSidecar = _object(direct['staged_parse_job_v2']);
    expect(directSidecar['text'], 'é🙂');
    expect(directSidecar['provenance'], <String, Object?>{
      'kind': 'direct_span',
      'source_id': 'input',
      'start': 1,
      'end': 3,
      'provenance': 'match_group',
    });

    const derivedSource = r'''
Top::
 /(a)(a);/ -> Top { job_marker = parse_job(cat(match_group(0), match_group(1)), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "keep_text", "required_capabilities", array("typed-source-location-v1", "actionir-v1"))); return(job_marker) }
''';
    final derived = _object(
      LinkedSpecRuntimeEngine(_compile(derivedSource)).parse('aa;').value,
    );
    final derivedSidecar = _object(derived['staged_parse_job_v2']);
    expect(derivedSidecar['text'], 'aa');
    expect(derivedSidecar['required_capabilities'], <String>[
      'actionir-v1',
      'typed-source-location-v1',
    ]);
    expect(derivedSidecar['provenance'], <String, Object?>{
      'kind': 'derived_text',
      'policy': 'concatenate_in_order',
      'segments': <Object?>[
        <String, Object?>{
          'kind': 'direct_span',
          'source_id': 'input',
          'start': 0,
          'end': 1,
          'provenance': 'match_group',
        },
        <String, Object?>{
          'kind': 'direct_span',
          'source_id': 'input',
          'start': 1,
          'end': 2,
          'provenance': 'match_group',
        },
      ],
    });
    expect(
      _forbiddenKeyHits(derived),
      isEmpty,
      reason: 'logical marker must retain no live execution authority',
    );
  });

  test('invalid annotations and recognition-reachable markers fail closed', () {
    const validOptions =
        'hash("node_kind", "expression", "payload_kind", '
        '"embedded_expression", "spec", "expr-v1", "result_policy", '
        '"replace_marker", "on_error", "fail")';
    final invalidForms = <(String, String)>[
      (
        'parse_job(match_group(0), options)',
        'staged_parse_job_options_required',
      ),
      (
        'parse_job(match_group(0), hash("node_kind", "expression", '
            '"payload_kind", "embedded_expression", "spec", "expr-v1", '
            '"result_policy", "replace_marker", "on_error", "fail", '
            '"loader", "ambient"))',
        'staged_parse_job_option_unknown',
      ),
      (
        'parse_job(match_group(0), hash("node_kind", "expression", '
            '"node_kind", "expression", "payload_kind", '
            '"embedded_expression", "spec", "expr-v1", '
            '"result_policy", "replace_marker", "on_error", "fail"))',
        'staged_parse_job_options_required',
      ),
      (
        'parse_job(match_group(0), hash("node_kind", "expression", '
            '"payload_kind", "embedded_expression", "spec", "expr-v1", '
            '"result_policy", "replace_marker"))',
        'staged_parse_job_options_required',
      ),
      (
        'parse_job(match_group(0), hash("node_kind", node_kind, '
            '"payload_kind", "embedded_expression", "spec", "expr-v1", '
            '"result_policy", "replace_marker", "on_error", "fail"))',
        'staged_parse_job_options_required',
      ),
      (
        'parse_job(trim(match_group(0)), $validOptions)',
        'staged_source_provenance_invalid',
      ),
      (
        'parse_job("copied", $validOptions)',
        'staged_source_provenance_invalid',
      ),
      (
        'parse_job(match_group(index), $validOptions)',
        'staged_source_provenance_invalid',
      ),
      (
        'parse_job(match_group(0), hash("node_kind", "expression", '
            '"payload_kind", "embedded_expression", "spec", "../expr", '
            '"result_policy", "replace_marker", "on_error", "fail"))',
        'staged_parser_identity_invalid',
      ),
      (
        'parse_job(match_group(0), hash("node_kind", "expression", '
            '"payload_kind", "embedded_expression", "spec", "expr-v1", '
            '"top", "Expr/Bad", "result_policy", "replace_marker", '
            '"on_error", "fail"))',
        'staged_top_rule_invalid',
      ),
      (
        'parse_job(match_group(0), hash("node_kind", "expression", '
            '"payload_kind", "embedded_expression", "spec", "expr-v1", '
            '"result_policy", "replace", "on_error", "fail"))',
        'staged_result_policy_invalid',
      ),
      (
        'parse_job(match_group(0), hash("node_kind", "expression", '
            '"payload_kind", "embedded_expression", "spec", "expr-v1", '
            '"result_policy", "replace_marker", "on_error", "retry"))',
        'staged_failure_policy_invalid',
      ),
      (
        'parse_job(match_group(0), hash("node_kind", "expression", '
            '"payload_kind", "embedded_expression", "spec", "expr-v1", '
            '"result_policy", "replace_marker", "into", "wrong", '
            '"on_error", "fail"))',
        'staged_result_target_invalid',
      ),
      (
        'parse_job(match_group(0), hash("node_kind", "expression", '
            '"payload_kind", "embedded_expression", "spec", "expr-v1", '
            '"result_policy", "sibling_field", "on_error", "fail"))',
        'staged_result_target_invalid',
      ),
      (
        'parse_job(match_group(0), hash("node_kind", "expression", '
            '"payload_kind", "embedded_expression", "spec", "expr-v1", '
            '"result_policy", "replace_marker", "on_error", "fail", '
            '"required_capabilities", array("actionir-v1", '
            '"actionir-v1")))',
        'staged_parse_job_options_required',
      ),
    ];
    for (final (call, code) in invalidForms) {
      final source =
          'Top::\n /(x);/ -> Top { marker = $call; '
          'return(marker) }\n';
      expect(
        () => _compile(source),
        throwsA(predicate<Object>((error) => '$error'.contains(code))),
        reason: call,
      );
    }
    final residual =
        'Top::\n /(x);/ -> Top { return('
        'parse_job(match_group(0), $validOptions)) }\n';
    expect(
      () => _compile(residual),
      throwsA(
        predicate<Object>(
          (error) => '$error'.contains('staged_parse_job_options_required'),
        ),
      ),
    );

    const transactionSource = r'''
Top::
 I { tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); recognition_rollback(tx); return(matched) }
 /never/
Child::
 I { marker = parse_job(entry_text(), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail")); return(marker) }
 /never/
''';
    expect(
      () => _compile(transactionSource),
      throwsA(
        predicate<Object>(
          (error) => '$error'.contains(
            'recognition_effect_forbidden:parser_registry_or_staged_dispatch',
          ),
        ),
      ),
    );
  });

  test('RED advances exclusively to registry and result-policy authority', () {
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
      'authority=[pre_registered_resolution,immutable_cache,'
      'result_failure_policies]; marker=[STAGED_PARSE_JOB_MARKER] and typed '
      'provenance=[staged_parse_job_v2] are available',
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

_JsonObject _expectedMarker() => <String, Object?>{
  'kind': 'STAGED_PARSE_JOB_MARKER',
  'version': 2,
  'sidecar_kind': 'staged_parse_job_v2',
  'effect': 'staged_parse_job_declaration',
  'staged_parse_job_v2': <String, Object?>{
    'kind': 'staged_parse_job_v2',
    'version': 2,
    'state': 'declared',
    'effect': 'staged_parse_job_declaration',
    'node_kind': 'expression',
    'payload_kind': 'embedded_expression',
    'parser_spec_id': 'expr-v1',
    'top_rule': 'Expr',
    'result_policy': 'sibling_field',
    'into': 'expression_ast',
    'failure_policy': 'fail',
    'required_capabilities': <String>[],
    'text': '1+2',
    'provenance': <String, Object?>{
      'kind': 'direct_span',
      'source_id': 'input',
      'start': 0,
      'end': 3,
      'provenance': 'match_group',
    },
    'origin': 'Top:parse_job',
  },
};

List<String> _forbiddenKeyHits(Object? value) {
  const forbidden = <String>{
    'path',
    'spec_path',
    'source_authority',
    'match',
    'match_object',
    'parser',
    'registry',
    'compiled_authority',
    'callback',
    'host_handle',
    'cancellation_token',
    'deadline',
    'mutable_queue',
  };
  final hits = <String>[];
  void visit(Object? current) {
    if (current is Map) {
      for (final entry in current.entries) {
        final key = '${entry.key}';
        if (forbidden.contains(key)) {
          hits.add(key);
        }
        visit(entry.value);
      }
    } else if (current is List) {
      for (final item in current) {
        visit(item);
      }
    }
  }

  visit(value);
  return hits..sort();
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
import 'dart:convert';

import 'generated.dart' as generated;

void main() {
  print(jsonEncode(generated.execute('1+2;')));
}
''';
