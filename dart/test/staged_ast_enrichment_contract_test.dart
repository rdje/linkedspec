// FUTURE-PARITY-BACKLOG.14.7.5.0-.4 — admitted Dart staged-AST enrichment.
//
// Ordinary `dart test` discovery and canonical CI run this exact consumer.
// Focused execution from dart/ is:
//
//   bash ../tools/run_dart_project_data.sh test --reporter failures-only \
//     test/staged_ast_enrichment_contract_test.dart
//
// The contract freezes the neutral inventory, unchanged function-body v1,
// private marker/provenance/recursive authority, and four fresh top-level
// production routes without making general parse_job authoring public.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/runtime/source_location.dart';
import 'package:linkedspec_dart/src/runtime/staged_ast_enrichment.dart';
import 'package:linkedspec_dart/src/runtime/staged_parse_job.dart';
import 'package:test/test.dart';

typedef _JsonObject = Map<String, Object?>;

const _contractPath =
    '../capability_conformance/staged_ast_enrichment_contract.json';
const _ciDriverPath = '../tools/run_ci_local.sh';
const _contractId = 'linkedspec-staged-ast-enrichment-v1';
const _markerKind = 'STAGED_PARSE_JOB_MARKER';
const _sourceIdentity = 'staged-ast-enrichment/dart-red.spec';
const _finalConsumerPath = 'test/staged_ast_enrichment_contract_test.dart';
const _dormantConsumerPath =
    'test_dormant/staged_ast_enrichment_contract_test.dart';
const _authoredSource = r'''
Top::
 /([^;]+);/ -> Top { job_marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail")); return(job_marker) }
''';
const _carrierSource = r'''
Top::
 /([^;]+);/ -> Top { job_marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail")); return(hash("job_marker", job_marker)) }
''';

void main() {
  final contract = _object(jsonDecode(File(_contractPath).readAsStringSync()));

  test('freezes neutral authority and unchanged function-body v1', () {
    expect(contract['contract_id'], _contractId);
    expect(contract['format'], 1);
    expect(
      contract['status'],
      'neutral_perl_rust_and_dart_complete_julia_dormant_red_lua_pending',
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
      'mutations': 92,
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
      'complete',
      'dormant_red',
      'pending_absent',
    ]);
    expect(consumers[2], <String, Object?>{
      'backend': 'dart',
      'owner': 'FUTURE-PARITY-BACKLOG.14.7.5.0',
      'path': 'dart/$_finalConsumerPath',
      'dormant_path': 'dart/$_dormantConsumerPath',
      'status': 'complete',
    });
    expect(
      _list(contract['rollout']).map((row) => _object(row)['status']),
      <String>[
        'complete',
        'complete',
        'complete',
        'complete',
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

  test('frozen resolution authority and identities match neutral cases', () {
    final snapshot = _cloneObject(contract['resolution_snapshot']);
    final registry = FrozenStagedRegistry.fromSnapshot(
      snapshot: snapshot,
      compiledAuthorities: _compiledAuthorities(
        snapshot,
        (request, context) => StagedChildExecution.success(request['text']),
      ),
    );

    for (final row in _list(contract['resolution_cases']).map(_object)) {
      final resolved = row['resolved_spec_id'];
      final diagnostic = row['diagnostic'];
      if (diagnostic == null) {
        expect(
          registry.resolvePreRegistered(
            declaringSpecId: row['declaring_spec_id']! as String,
            parserSpecId: row['parser_spec_id']! as String,
            jobId: 'job:${row['id']}',
          ),
          resolved,
          reason: '${row['id']}',
        );
      } else {
        expect(
          () => registry.resolvePreRegistered(
            declaringSpecId: row['declaring_spec_id']! as String,
            parserSpecId: row['parser_spec_id']! as String,
            jobId: 'job:${row['id']}',
          ),
          throwsA(_stagedCode(diagnostic as String)),
          reason: '${row['id']}',
        );
      }
    }

    for (final row in _list(contract['job_id_cases']).map(_object)) {
      expect(
        stagedJobIdentity(<String, Object?>{
          'declaring_spec_id': row['declaring_spec_id'],
          'parent_ast_path': row['parent_ast_path'],
          'node_kind': row['node_kind'],
          'payload_kind': row['payload_kind'],
          'parser_spec_id': row['parser_spec_id'],
          'top_rule': row['top_rule'],
          'provenance': row['provenance'],
        }),
        row['expected_job_id'],
        reason: '${row['id']}',
      );
    }

    String? baseCacheKey;
    for (final row in _list(contract['cache_cases']).map(_object)) {
      final key = stagedCacheIdentity(row['fields']);
      baseCacheKey ??= key;
      expect(key == baseCacheKey, row['same_as_base'], reason: '${row['id']}');
    }

    for (final row in _list(contract['authority_cases']).map(_object)) {
      if (row['accepted'] == true) {
        expect(
          registry.evaluateAuthorityCase(
            authorityCase: row,
            jobId: 'job:${row['id']}',
          ),
          row['effective'],
          reason: '${row['id']}',
        );
      } else {
        expect(
          () => registry.evaluateAuthorityCase(
            authorityCase: row,
            jobId: 'job:${row['id']}',
          ),
          throwsA(_stagedCode(row['diagnostic']! as String)),
          reason: '${row['id']}',
        );
      }
    }

    _object(_list(snapshot['aliases']).first)['resolved_spec_id'] =
        'registry:json-v1';
    expect(
      registry.resolvePreRegistered(
        declaringSpecId: 'grammar/main.spec',
        parserSpecId: 'expr',
        jobId: 'job:frozen-after-seed-mutation',
      ),
      'registry:expr-v2',
    );
    expect(
      () => registry.register('expr'),
      throwsA(_stagedCode('staged_registry_mutation_forbidden')),
    );
    expect(
      () => registry.load('expr'),
      throwsA(_stagedCode('staged_implicit_load_forbidden')),
    );
  });

  test('one complete depth is typed-ordered isolated and plan-cached', () {
    for (final row in _list(contract['queue_cases']).map(_object)) {
      expect(
        stagedCurrentDepthOrder(row['jobs']),
        row['expected_order'],
        reason: '${row['id']}',
      );
    }
    final invalidCache = _cloneObject(
      _object(_list(contract['cache_cases']).first)['fields'],
    )..remove('top_rule');
    expect(
      () => stagedCacheIdentity(invalidCache),
      throwsA(_stagedCode('staged_cache_identity_invalid')),
    );
    final duplicateCapabilities = _cloneObject(
      _object(_list(contract['cache_cases']).first)['fields'],
    )..['backend_capabilities'] = <String>['duplicate', 'duplicate'];
    expect(
      () => stagedCacheIdentity(duplicateCapabilities),
      throwsA(_stagedCode('staged_cache_identity_invalid')),
    );

    final observations = <_JsonObject>[];
    final registry = _registry(contract, (request, context) {
      observations.add(<String, Object?>{
        'text': request['text'],
        'cursor': context.cursor,
        'marks': <String, Object?>{...context.marks},
        'captures': <String, Object?>{...context.captures},
        'variables': <String, Object?>{...context.variables},
      });
      context.cursor = 99;
      context.marks['child'] = request['text'];
      context.captures['capture'] = false;
      context.variables['value'] = 0;
      final text = request['text'];
      request['text'] = 'callback-mutated-request';
      return StagedChildExecution.success(<String, Object?>{
        'kind': 'expr',
        'text': text,
      });
    });
    final nodes = List<Object?>.filled(11, null);
    nodes[10] = _marker(text: 'ten', start: 10, end: 13);
    nodes[2] = _marker(text: 'two', start: 2, end: 5);
    final ast = <String, Object?>{'nodes': nodes};
    final before = _cloneObject(ast);

    final first = enrichStagedCurrentDepth(
      registry: registry,
      ast: ast,
      options: _enrichmentOptions(),
    );
    expect(observations.map((row) => row['text']), <String>['two', 'ten']);
    for (final row in observations) {
      expect(row, <String, Object?>{
        'text': row['text'],
        'cursor': 0,
        'marks': <String, Object?>{},
        'captures': <String, Object?>{},
        'variables': <String, Object?>{},
      });
    }
    expect(_object(_list(_object(first.ast)['nodes'])[2]), <String, Object?>{
      'kind': 'expr',
      'text': 'two',
    });
    expect(_object(_list(_object(first.ast)['nodes'])[10]), <String, Object?>{
      'kind': 'expr',
      'text': 'ten',
    });
    expect(first.sidecars.map((row) => row['text']), <String>['two', 'ten']);
    expect(first.cache.toJson(), <String, Object?>{
      'snapshot_id': startsWith('registry-snapshot:sha256:'),
      'entries': 1,
      'hits': 1,
      'misses': 1,
    });
    expect(ast, before);

    final second = enrichStagedCurrentDepth(
      registry: registry,
      ast: ast,
      options: _enrichmentOptions(),
    );
    expect(second.ast, first.ast);
    expect(second.cache.entries, 1);
    expect(second.cache.hits, 3);
    expect(second.cache.misses, 1);
    expect(observations, hasLength(4));

    var nestedCalls = 0;
    final inertRegistry = _registry(contract, (request, context) {
      nestedCalls += 1;
      return StagedChildExecution.success(
        _marker(text: 'nested', start: 0, end: 6),
      );
    });
    final inert = enrichStagedCurrentDepth(
      registry: inertRegistry,
      ast: <String, Object?>{
        'payload': _marker(text: 'parent', start: 0, end: 6),
      },
      options: _enrichmentOptions(),
    );
    expect(nestedCalls, 1);
    expect(_object(_object(inert.ast)['payload'])['kind'], _markerKind);

    final defaultTop = enrichStagedCurrentDepth(
      registry: _registry(
        contract,
        (request, context) =>
            StagedChildExecution.success(<String, Object?>{'kind': 'document'}),
      ),
      ast: <String, Object?>{
        'document': _marker(
          text: 'abcdef',
          end: 6,
          nodeKind: 'document',
          payloadKind: 'json',
          parserSpecId: 'json.spec',
          topRule: null,
          requiredCapabilities: const <String>['typed-source-location-v1'],
        ),
      },
      options: _enrichmentOptions(requiredSourceDetail: 'identity'),
    );
    expect(defaultTop.sidecars.single['top_rule'], 'Document');
    final explicitTop = enrichStagedCurrentDepth(
      registry: _registry(
        contract,
        (request, context) =>
            StagedChildExecution.success(<String, Object?>{'kind': 'document'}),
      ),
      ast: <String, Object?>{
        'document': _marker(
          text: 'abcdef',
          end: 6,
          nodeKind: 'document',
          payloadKind: 'json',
          parserSpecId: 'json.spec',
          topRule: 'Document',
          requiredCapabilities: const <String>['typed-source-location-v1'],
        ),
      },
      options: _enrichmentOptions(requiredSourceDetail: 'identity'),
    );
    expect(
      defaultTop.sidecars.single['job_id'],
      explicitTop.sidecars.single['job_id'],
      reason: 'default top must be selected before deterministic identity',
    );
  });

  test('all four result policies stitch detached plain results', () {
    for (final row in _list(contract['stitch_cases']).map(_object)) {
      final parent = _cloneObject(row['parent']);
      final markerField = row['marker_field']! as String;
      parent[markerField] = _marker(
        text: row['text']! as String,
        resultPolicy: row['result_policy']! as String,
        into: row['into'] as String?,
      );
      final child = _copyPlainForTest(row['result']);
      final registry = _registry(
        contract,
        (request, context) => StagedChildExecution.success(child),
      );
      final outcome = enrichStagedCurrentDepth(
        registry: registry,
        ast: parent,
        options: _enrichmentOptions(),
      );
      expect(outcome.ast, row['expected_parent'], reason: '${row['id']}');
      expect(outcome.sidecars.single['state'], 'succeeded');
      expect(outcome.diagnostics, isEmpty);
      if (child is Map<String, Object?>) {
        child['mutated_after_return'] = true;
        expect(
          jsonEncode(outcome.ast),
          isNot(contains('mutated_after_return')),
          reason: '${row['id']} detachment',
        );
      }
    }
  });

  test(
    'all three failure policies retain diagnostics and publish atomically',
    () {
      for (final row in _list(contract['failure_cases']).map(_object)) {
        final parent = _cloneObject(row['parent']);
        final original = _cloneObject(parent);
        final markerField = row['marker_field']! as String;
        parent[markerField] = _marker(
          text: row['text']! as String,
          resultPolicy: row['result_policy']! as String,
          into: row['into'] as String?,
          failurePolicy: row['failure_policy']! as String,
        );
        final input = _cloneObject(parent);
        final registry = _registry(
          contract,
          (request, context) => StagedChildExecution.failure(row['diagnostic']),
        );
        if (row['failure_policy'] == 'fail') {
          expect(
            () => enrichStagedCurrentDepth(
              registry: registry,
              ast: input,
              options: _enrichmentOptions(),
            ),
            throwsA(_stagedCode('staged_child_failed')),
            reason: '${row['id']}',
          );
          expect(
            input,
            parent,
            reason: '${row['id']} input remains unpublished',
          );
          expect(original[markerField], isNot(equals(parent[markerField])));
          continue;
        }
        final outcome = enrichStagedCurrentDepth(
          registry: registry,
          ast: input,
          options: _enrichmentOptions(),
        );
        expect(outcome.diagnostics, hasLength(1));
        expect(
          _object(outcome.diagnostics.single['child_diagnostic']),
          row['diagnostic'],
        );
        if (row['failure_policy'] == 'keep_text') {
          expect(_object(outcome.ast)[markerField], row['text']);
          expect(outcome.sidecars.single['state'], 'failed_keep_text');
        } else {
          final ast = _object(outcome.ast);
          expect(ast[markerField], row['text']);
          final node = _object(ast[row['into']]);
          expect(node['kind'], 'staged_parse_diagnostic');
          expect(node['diagnostic'], outcome.diagnostics.single);
          expect(outcome.sidecars.single['state'], 'failed_diagnostic_node');
        }
      }

      var calls = 0;
      final registry = _registry(contract, (request, context) {
        calls += 1;
        return request['text'] == 'bad'
            ? StagedChildExecution.failure(<String, Object?>{
                'code': 'child_bad',
              })
            : StagedChildExecution.success(<String, Object?>{'kind': 'ok'});
      });
      final input = <String, Object?>{
        'nodes': <Object?>[
          _marker(text: 'good', start: 0, end: 4),
          _marker(text: 'bad', start: 5, end: 8),
        ],
      };
      final before = _cloneObject(input);
      expect(
        () => enrichStagedCurrentDepth(
          registry: registry,
          ast: input,
          options: _enrichmentOptions(),
        ),
        throwsA(_stagedCode('staged_child_failed')),
      );
      expect(calls, 2);
      expect(input, before, reason: 'partial first result must not publish');
      expect(registry.cacheStats.entries, 1);
      expect(registry.cacheStats.misses, 1);
      expect(registry.cacheStats.hits, 1);

      var failFirst = true;
      var repeatedCalls = 0;
      final repeatedRegistry = _registry(contract, (request, context) {
        repeatedCalls += 1;
        if (failFirst) {
          failFirst = false;
          return StagedChildExecution.failure(<String, Object?>{
            'code': 'first_attempt_failed',
          });
        }
        return StagedChildExecution.success(<String, Object?>{'kind': 'fresh'});
      });
      final repeatedInput = <String, Object?>{
        'payload': _marker(text: 'repeat', end: 6),
      };
      expect(
        () => enrichStagedCurrentDepth(
          registry: repeatedRegistry,
          ast: repeatedInput,
          options: _enrichmentOptions(),
        ),
        throwsA(_stagedCode('staged_child_failed')),
      );
      final repeated = enrichStagedCurrentDepth(
        registry: repeatedRegistry,
        ast: repeatedInput,
        options: _enrichmentOptions(),
      );
      expect(_object(repeated.ast)['payload'], <String, Object?>{
        'kind': 'fresh',
      });
      expect(
        repeatedCalls,
        2,
        reason: 'failed child result must not be cached',
      );
      expect(repeatedRegistry.cacheStats.entries, 1);
      expect(repeatedRegistry.cacheStats.misses, 1);
      expect(repeatedRegistry.cacheStats.hits, 1);
    },
  );

  test('neutral detachment and stitch adversaries fail closed', () {
    for (final row in _list(contract['detachment_cases']).map(_object)) {
      final registry = _registry(
        contract,
        (request, context) => StagedChildExecution.success(row['value']),
      );
      final input = <String, Object?>{
        'payload': _marker(text: 'x', start: 0, end: 1),
      };
      final options = _enrichmentOptions(
        maxResultNodes: row['max_nodes']! as int,
      );
      if (row['accepted'] == true) {
        final outcome = enrichStagedCurrentDepth(
          registry: registry,
          ast: input,
          options: options,
        );
        expect(_object(outcome.ast)['payload'], row['value']);
      } else {
        expect(
          () => enrichStagedCurrentDepth(
            registry: registry,
            ast: input,
            options: options,
          ),
          throwsA(_stagedCode(row['diagnostic']! as String)),
          reason: '${row['id']}',
        );
      }
    }

    final cycle = <String, Object?>{};
    cycle['self'] = cycle;
    final cyclicRegistry = _registry(
      contract,
      (request, context) => StagedChildExecution.success(cycle),
    );
    expect(
      () => enrichStagedCurrentDepth(
        registry: cyclicRegistry,
        ast: <String, Object?>{'payload': _marker(text: 'x', start: 0, end: 1)},
        options: _enrichmentOptions(),
      ),
      throwsA(_stagedCode('staged_result_not_detached')),
    );

    final adversaries = <(String, Object?, String)>[
      (
        'replace_field',
        <String, Object?>{
          'payload': _marker(resultPolicy: 'replace_field', into: 'missing'),
        },
        'staged_stitch_target_missing',
      ),
      (
        'sibling_field',
        <String, Object?>{
          'payload': _marker(resultPolicy: 'sibling_field', into: 'ast'),
          'ast': null,
        },
        'staged_stitch_target_collision',
      ),
      (
        'append_child',
        <String, Object?>{
          'payload': _marker(resultPolicy: 'append_child', into: 'children'),
          'children': <String, Object?>{},
        },
        'staged_append_target_invalid',
      ),
    ];
    for (final (id, ast, code) in adversaries) {
      var calls = 0;
      final registry = _registry(contract, (request, context) {
        calls += 1;
        return StagedChildExecution.success(<String, Object?>{'kind': 'expr'});
      });
      expect(
        () => enrichStagedCurrentDepth(
          registry: registry,
          ast: ast,
          options: _enrichmentOptions(),
        ),
        throwsA(_stagedCode(code)),
        reason: id,
      );
      expect(calls, 0, reason: '$id must reject during complete-depth prepare');
    }

    var completeDepthCalls = 0;
    final completeDepthRegistry = _registry(contract, (request, context) {
      completeDepthCalls += 1;
      return StagedChildExecution.success(<String, Object?>{'kind': 'expr'});
    });
    expect(
      () => enrichStagedCurrentDepth(
        registry: completeDepthRegistry,
        ast: <String, Object?>{
          'a_valid': _marker(text: 'a', end: 1),
          'z_invalid': _marker(
            text: 'z',
            end: 1,
            resultPolicy: 'replace_field',
            into: 'missing',
          ),
        },
        options: _enrichmentOptions(),
      ),
      throwsA(_stagedCode('staged_stitch_target_missing')),
    );
    expect(
      completeDepthCalls,
      0,
      reason: 'all jobs and targets must prepare before the first callback',
    );

    final crossPlanConflicts = <(String, _JsonObject)>[
      (
        'duplicate non-append target',
        <String, Object?>{
          'a': _marker(resultPolicy: 'replace_field', into: 'slot'),
          'b': _marker(resultPolicy: 'replace_field', into: 'slot'),
          'slot': null,
        },
      ),
      (
        'target overwrites another queued marker',
        <String, Object?>{
          'a': _marker(resultPolicy: 'replace_field', into: 'z'),
          'z': _marker(),
        },
      ),
      (
        'replace and append claim the same target',
        <String, Object?>{
          'a': _marker(resultPolicy: 'replace_field', into: 'children'),
          'b': _marker(resultPolicy: 'append_child', into: 'children'),
          'children': <Object?>[],
        },
      ),
    ];
    for (final (id, conflictingAst) in crossPlanConflicts) {
      var calls = 0;
      final registry = _registry(contract, (request, context) {
        calls += 1;
        return StagedChildExecution.success(<String, Object?>{'kind': 'expr'});
      });
      expect(
        () => enrichStagedCurrentDepth(
          registry: registry,
          ast: conflictingAst,
          options: _enrichmentOptions(),
        ),
        throwsA(_stagedCode('staged_stitch_target_collision')),
        reason: id,
      );
      expect(calls, 0, reason: '$id must fail in complete-depth preflight');
    }

    final appendRegistry = _registry(
      contract,
      (request, context) => StagedChildExecution.success(<String, Object?>{
        'kind': request['text'],
      }),
    );
    final appended = enrichStagedCurrentDepth(
      registry: appendRegistry,
      ast: <String, Object?>{
        'a': _marker(
          text: 'first',
          end: 5,
          resultPolicy: 'append_child',
          into: 'children',
        ),
        'b': _marker(
          text: 'second',
          start: 6,
          end: 12,
          resultPolicy: 'append_child',
          into: 'children',
        ),
        'children': <Object?>[],
      },
      options: _enrichmentOptions(),
    );
    expect(_object(appended.ast)['children'], <Object?>[
      <String, Object?>{'kind': 'first'},
      <String, Object?>{'kind': 'second'},
    ]);
  });

  test('all ten neutral recursive chain cases use the exact predicates', () {
    for (final row in _list(contract['chain_cases']).map(_object)) {
      expect(evaluateStagedChainCase(row), <String, Object?>{
        'accepted': row['accepted'],
        'diagnostic': row['diagnostic'],
      }, reason: '${row['id']}');
    }
  });

  test('recursive execution is breadth-first with shared cache and state', () {
    final token = Object();
    final cancellationIdentities = <bool>[];
    final observations = <_JsonObject>[];
    final retainedContexts = <StagedRuntimeContext>[];
    final registry = _registry(contract, (request, context) {
      retainedContexts.add(context);
      final before = context.remainingSteps;
      final after = context.safePoint(1);
      final text = request['text']! as String;
      observations.add(<String, Object?>{
        'text': text,
        'depth': request['stage_depth'],
        'chain_length': _list(request['stage_chain']).length,
        'remaining_before': before,
        'remaining_after': after,
        'token_identity': identical(context.cancellationToken, token),
        'deadline': context.deadline,
      });
      if (text == 'root-a') {
        return StagedChildExecution.success(<String, Object?>{
          'kind': 'branch',
          'nested': _marker(text: 'suba', start: 1, end: 5),
        });
      }
      if (text == 'root-b') {
        return StagedChildExecution.success(<String, Object?>{
          'kind': 'branch',
          'nested': _marker(text: 'subb', start: 11, end: 15),
        });
      }
      return StagedChildExecution.success(<String, Object?>{
        'kind': 'leaf',
        'text': text,
      });
    });
    final outcome = enrichStagedRecursively(
      registry: registry,
      ast: <String, Object?>{
        'nodes': <Object?>[
          _marker(text: 'root-a', start: 0, end: 6),
          _marker(text: 'root-b', start: 10, end: 16),
        ],
      },
      options: _enrichmentOptions(),
      authority: _recursiveAuthority(
        cancellationToken: token,
        cancelled: (candidate) {
          cancellationIdentities.add(identical(candidate, token));
          return false;
        },
        deadline: 50,
        remainingSteps: 20,
      ),
    );

    expect(observations.map((row) => row['text']), <String>[
      'root-a',
      'root-b',
      'suba',
      'subb',
    ]);
    expect(observations.map((row) => row['depth']), <int>[1, 1, 2, 2]);
    expect(observations.map((row) => row['chain_length']), <int>[1, 1, 2, 2]);
    expect(observations.map((row) => row['remaining_before']), <int>[
      19,
      17,
      15,
      13,
    ]);
    expect(observations.map((row) => row['remaining_after']), <int>[
      18,
      16,
      14,
      12,
    ]);
    expect(observations.every((row) => row['token_identity'] == true), isTrue);
    expect(observations.every((row) => row['deadline'] == 50), isTrue);
    expect(cancellationIdentities.every((value) => value), isTrue);
    expect(outcome.sidecars.map((row) => row['stage_depth']), <int>[
      1,
      1,
      2,
      2,
    ]);
    expect(outcome.cache.entries, 1);
    expect(outcome.cache.hits, 3);
    expect(outcome.cache.misses, 1);
    expect(outcome.resources.remainingSteps, 12);
    expect(outcome.resources.totalCalls, 4);
    final nodes = _list(_object(outcome.ast)['nodes']);
    expect(_object(_object(nodes[0])['nested']), <String, Object?>{
      'kind': 'leaf',
      'text': 'suba',
    });
    expect(_object(_object(nodes[1])['nested']), <String, Object?>{
      'kind': 'leaf',
      'text': 'subb',
    });
    for (final context in retainedContexts) {
      expect(
        () => context.safePoint(0),
        throwsA(_stagedCode('staged_registry_snapshot_invalid')),
      );
      expect(
        () => context.rebasePosition(0),
        throwsA(_stagedCode('staged_registry_snapshot_invalid')),
      );
    }
  });

  test(
    'cycle non-decrease depth and call guards reject before child reuse',
    () {
      var cycleCalls = 0;
      final cycleRegistry = _registry(contract, (request, context) {
        cycleCalls += 1;
        return StagedChildExecution.success(<String, Object?>{
          'nested': _marker(text: 'same', start: 0, end: 4),
        });
      });
      expect(
        () => enrichStagedRecursively(
          registry: cycleRegistry,
          ast: <String, Object?>{
            'payload': _marker(text: 'same', start: 0, end: 4),
          },
          options: _enrichmentOptions(),
          authority: _recursiveAuthority(),
        ),
        throwsA(_stagedCode('staged_cycle')),
      );
      expect(
        cycleCalls,
        1,
        reason: 'cycle must reject in next-depth preflight',
      );

      var nonDecreaseCalls = 0;
      final nonDecreaseRegistry = _registry(contract, (request, context) {
        nonDecreaseCalls += 1;
        return StagedChildExecution.success(<String, Object?>{
          'nested': _marker(text: 'next', start: 0, end: 4),
        });
      });
      expect(
        () => enrichStagedRecursively(
          registry: nonDecreaseRegistry,
          ast: <String, Object?>{
            'payload': _marker(text: 'same', start: 0, end: 4),
          },
          options: _enrichmentOptions(),
          authority: _recursiveAuthority(),
        ),
        throwsA(_stagedCode('staged_chain_non_decreasing')),
      );
      expect(nonDecreaseCalls, 1);

      for (final (code, authority) in <(String, StagedRecursiveAuthority)>[
        ('staged_depth_exceeded', _recursiveAuthority(maxDepth: 1)),
        ('staged_call_limit_exceeded', _recursiveAuthority(maxCalls: 1)),
      ]) {
        var calls = 0;
        final registry = _registry(contract, (request, context) {
          calls += 1;
          return StagedChildExecution.success(<String, Object?>{
            'nested': _marker(text: 'sub', start: 1, end: 4),
          });
        });
        expect(
          () => enrichStagedRecursively(
            registry: registry,
            ast: <String, Object?>{
              'payload': _marker(text: 'root', start: 0, end: 4),
            },
            options: _enrichmentOptions(),
            authority: authority,
          ),
          throwsA(_stagedCode(code)),
          reason: code,
        );
        expect(calls, 1, reason: '$code must reject before second callback');
      }
    },
  );

  test(
    'entry and callback safe points share cancellation deadline and steps',
    () {
      for (final (code, authority) in <(String, StagedRecursiveAuthority)>[
        ('staged_cancelled', _recursiveAuthority(cancelled: (_) => true)),
        (
          'staged_deadline_exceeded',
          _recursiveAuthority(clock: () => 11, deadline: 10),
        ),
        ('staged_budget_exhausted', _recursiveAuthority(remainingSteps: 0)),
      ]) {
        var calls = 0;
        final registry = _registry(contract, (request, context) {
          calls += 1;
          return StagedChildExecution.success(<String, Object?>{
            'kind': 'leaf',
          });
        });
        expect(
          () => enrichStagedRecursively(
            registry: registry,
            ast: <String, Object?>{'payload': _marker(text: 'x', end: 1)},
            options: _enrichmentOptions(),
            authority: authority,
          ),
          throwsA(_stagedCode(code)),
          reason: code,
        );
        expect(calls, 0, reason: '$code must reject at dispatch entry');
      }

      var cancelled = false;
      final safePointRegistry = _registry(contract, (request, context) {
        cancelled = true;
        context.safePoint(0);
        return StagedChildExecution.success(<String, Object?>{'kind': 'never'});
      });
      expect(
        () => enrichStagedRecursively(
          registry: safePointRegistry,
          ast: <String, Object?>{'payload': _marker(text: 'x', end: 1)},
          options: _enrichmentOptions(),
          authority: _recursiveAuthority(cancelled: (_) => cancelled),
        ),
        throwsA(_stagedCode('staged_cancelled')),
      );

      final budgetRegistry = _registry(contract, (request, context) {
        context.safePoint(2);
        return StagedChildExecution.success(<String, Object?>{'kind': 'never'});
      });
      expect(
        () => enrichStagedRecursively(
          registry: budgetRegistry,
          ast: <String, Object?>{'payload': _marker(text: 'x', end: 1)},
          options: _enrichmentOptions(maxSteps: 2),
          authority: _recursiveAuthority(remainingSteps: 2),
        ),
        throwsA(_stagedCode('staged_budget_exhausted')),
      );

      var clockCalls = 0;
      final postCallbackRegistry = _registry(
        contract,
        (request, context) =>
            StagedChildExecution.success(<String, Object?>{'kind': 'never'}),
      );
      expect(
        () => enrichStagedRecursively(
          registry: postCallbackRegistry,
          ast: <String, Object?>{'payload': _marker(text: 'x', end: 1)},
          options: _enrichmentOptions(),
          authority: _recursiveAuthority(
            clock: () => clockCalls++ == 0 ? 0 : 11,
            deadline: 10,
          ),
        ),
        throwsA(_stagedCode('staged_deadline_exceeded')),
        reason: 'the post-callback safe point shares the absolute deadline',
      );
    },
  );

  test('result nodes and diagnostic bytes spend monotonically', () {
    var resultCalls = 0;
    final resultRegistry = _registry(contract, (request, context) {
      resultCalls += 1;
      return StagedChildExecution.success(<String, Object?>{'kind': 'leaf'});
    });
    expect(
      () => enrichStagedRecursively(
        registry: resultRegistry,
        ast: <String, Object?>{
          'nodes': <Object?>[
            _marker(text: 'a', end: 1),
            _marker(text: 'b', start: 1, end: 2),
          ],
        },
        options: _enrichmentOptions(maxResultNodes: 3),
        authority: _recursiveAuthority(),
      ),
      throwsA(_stagedCode('staged_result_node_limit_exceeded')),
    );
    expect(resultCalls, 2);

    final diagnosticRegistry = _registry(
      contract,
      (request, context) => StagedChildExecution.failure(<String, Object?>{
        'code': 'large_child_failure',
        'detail': 'x' * 1024,
      }),
    );
    final truncated = enrichStagedRecursively(
      registry: diagnosticRegistry,
      ast: <String, Object?>{
        'payload': _marker(text: 'x', end: 1, failurePolicy: 'keep_text'),
      },
      options: _enrichmentOptions(maxDiagnosticBytes: 64),
      authority: _recursiveAuthority(),
    );
    expect(truncated.diagnostics.single['code'], 'staged_diagnostic_truncated');
    expect(truncated.diagnostics.single['maximum_bytes'], 64);
    expect(truncated.resources.remainingDiagnosticBytes, 0);
    expect(_object(truncated.ast)['payload'], 'x');
  });

  test('direct and derived child diagnostics rebase to original sources', () {
    final directRegistry = _registry(contract, (request, context) {
      expect(context.rebasePosition(1), <String, Object?>{
        'source_id': 'ascii',
        'offset': 3,
      });
      expect(
        context.rebaseSpan(<String, Object?>{'start': 1, 'end': 3}),
        <String, Object?>{
          'kind': 'direct_span',
          'source_id': 'ascii',
          'start': 3,
          'end': 5,
          'provenance': 'capture',
        },
      );
      return StagedChildExecution.failure(<String, Object?>{
        'code': 'direct_local_failure',
        'offset': 1,
        'span': <String, Object?>{'start': 0, 'end': 2},
        'nested': <String, Object?>{
          'position': <String, Object?>{'offset': 4},
        },
      });
    });
    final direct = enrichStagedRecursively(
      registry: directRegistry,
      ast: <String, Object?>{
        'payload': _marker(
          text: 'abcd',
          start: 2,
          end: 6,
          failurePolicy: 'keep_text',
        ),
      },
      options: _enrichmentOptions(),
      authority: _recursiveAuthority(),
    );
    final directChild = _object(direct.diagnostics.single['child_diagnostic']);
    expect(directChild['offset'], <String, Object?>{
      'source_id': 'ascii',
      'offset': 3,
    });
    expect(directChild['span'], <String, Object?>{
      'kind': 'direct_span',
      'source_id': 'ascii',
      'start': 2,
      'end': 4,
      'provenance': 'capture',
    });
    expect(
      _object(_object(directChild['nested'])['position']),
      <String, Object?>{'source_id': 'ascii', 'offset': 6},
    );

    final derivedProvenance = <String, Object?>{
      'kind': 'derived_text',
      'policy': 'concatenate_in_order',
      'segments': <Object?>[
        <String, Object?>{
          'kind': 'direct_span',
          'source_id': 'ascii',
          'start': 0,
          'end': 2,
          'provenance': 'capture',
        },
        <String, Object?>{
          'kind': 'direct_span',
          'source_id': 'unicode',
          'start': 1,
          'end': 3,
          'provenance': 'capture',
        },
      ],
    };
    final derivedRegistry = _registry(contract, (request, context) {
      expect(context.rebasePosition(2), <String, Object?>{
        'source_id': 'unicode',
        'offset': 1,
      });
      return StagedChildExecution.failure(<String, Object?>{
        'code': 'derived_local_failure',
        'offset': 2,
        'span': <String, Object?>{'start': 1, 'end': 3},
      });
    });
    final derived = enrichStagedRecursively(
      registry: derivedRegistry,
      ast: <String, Object?>{
        'payload': _marker(
          text: 'abcd',
          failurePolicy: 'keep_text',
          provenance: derivedProvenance,
        ),
      },
      options: _enrichmentOptions(),
      authority: _recursiveAuthority(),
    );
    final derivedChild = _object(
      derived.diagnostics.single['child_diagnostic'],
    );
    expect(derivedChild['offset'], <String, Object?>{
      'source_id': 'unicode',
      'offset': 1,
    });
    expect(derivedChild['span'], <String, Object?>{
      'kind': 'derived_text',
      'policy': 'concatenate_in_order',
      'segments': <Object?>[
        <String, Object?>{
          'kind': 'direct_span',
          'source_id': 'ascii',
          'start': 1,
          'end': 2,
          'provenance': 'capture',
        },
        <String, Object?>{
          'kind': 'direct_span',
          'source_id': 'unicode',
          'start': 1,
          'end': 2,
          'provenance': 'capture',
        },
      ],
    });
  });

  test(
    'fresh authority carries and admits all four production routes',
    () async {
      expect(File(_dormantConsumerPath).existsSync(), isFalse);
      expect(File(_finalConsumerPath).existsSync(), isTrue);
      final ci = File(_ciDriverPath).readAsStringSync();
      expect(ci, isNot(contains('dart/$_dormantConsumerPath')));
      expect(
        _occurrences(ci, 'require_tracked_file dart/$_finalConsumerPath'),
        1,
      );
      expect(
        _occurrences(
          ci,
          'running exact Dart staged-AST enrichment admission consumer',
        ),
        1,
      );
      expect(
        _occurrences(ci, 'test --reporter failures-only $_finalConsumerPath'),
        1,
      );
      final umbrella = File('lib/linkedspec_dart.dart').readAsStringSync();
      for (final privateToken in <String>[
        'parse_job(text_expr',
        'STAGED_PARSE_JOB_MARKER',
        _contractId,
      ]) {
        expect(umbrella, isNot(contains(privateToken)));
      }

      final parsed = parseSpecWithStagedUserFunctionDefinitions(_carrierSource);
      final compiled = compileSpec(parsed);
      final compiledJson = compiled.toJson();
      expect(_forbiddenKeyHits(compiledJson), isEmpty);

      final nativeProbe = _CarrierProbe(contract);
      final nativeEngine = LinkedSpecRuntimeEngine(
        compiled,
        stagedAstEnrichmentSeed: nativeProbe.seed(),
      );
      final native = nativeProbe.record(<Object?>[
        nativeEngine.parse('1+2;').value,
        nativeEngine.parse('1+2;').value,
      ]);

      final reconstructedSpec = SpecFile.fromJson(
        _object(jsonDecode(jsonEncode(parsed.toJson()))),
      );
      validateSpec(reconstructedSpec);
      final reconstructedProbe = _CarrierProbe(contract);
      final reconstructedEngine = LinkedSpecRuntimeEngine(
        compileSpec(reconstructedSpec),
        stagedAstEnrichmentSeed: reconstructedProbe.seed(),
      );
      final reconstructed = reconstructedProbe.record(<Object?>[
        reconstructedEngine.parse('1+2;').value,
        reconstructedEngine.parse('1+2;').value,
      ]);

      final generatedProbe = _CarrierProbe(contract);
      final generatedSeed = generatedProbe.seed();
      final generated = generatedProbe.record(<Object?>[
        executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          '1+2;',
          _sourceIdentity,
          stagedAstEnrichmentSeed: generatedSeed,
        ),
        executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          '1+2;',
          _sourceIdentity,
          stagedAstEnrichmentSeed: generatedSeed,
        ),
      ]);

      expect(reconstructed, native);
      expect(generated, native);
      expect(native['values'], <Object?>[
        _expectedEnrichedAst(),
        _expectedEnrichedAst(),
      ]);

      final emitted = emitDartSourceV2(compiled, _sourceIdentity);
      expect(
        emitted,
        contains('StagedAstEnrichmentSeed? stagedAstEnrichmentSeed'),
      );
      for (final forbidden in <String>[
        'opaque:compiled:expr-v2',
        'registry:expr-v2',
        'StagedRecursiveAuthority(',
        'FrozenStagedRegistry.fromSnapshot',
        'cancellationToken:',
        'remainingSteps:',
      ]) {
        expect(emitted, isNot(contains(forbidden)), reason: forbidden);
      }

      final packageRoot = Directory.current.absolute;
      final scratch = Directory(
        '${packageRoot.path}/.dart_tool/linkedspec-dart-staged-ast-carrier-'
        '$pid-${DateTime.now().microsecondsSinceEpoch}',
      )..createSync(recursive: true);
      try {
        final generatedPath = '${scratch.path}/generated.dart';
        final mainPath = '${scratch.path}/main.dart';
        File(generatedPath).writeAsStringSync(emitted);
        File(mainPath).writeAsStringSync(_emittedCarrierMain);
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
          reason: 'emitted staged-AST carrier failed:\n${run.stderr}',
        );
        expect(_object(jsonDecode('${run.stdout}'.trim())), native);
      } finally {
        if (scratch.existsSync()) {
          scratch.deleteSync(recursive: true);
        }
      }

      expect(
        contract['status'],
        'neutral_perl_rust_and_dart_complete_julia_dormant_red_lua_pending',
      );
      expect(
        _object(_list(contract['backend_consumers'])[2])['status'],
        'complete',
      );
      expect(_object(_list(contract['rollout'])[3])['status'], 'complete');
      expect(_object(contract['expected_counts'])['mutations'], 92);
    },
  );
}

final class _CarrierProbe {
  _CarrierProbe(this.contract);

  final _JsonObject contract;
  final List<_JsonObject> outcomes = <_JsonObject>[];
  final List<Object> cancellationTokens = <Object>[];
  final List<Object> cancellationCallbacks = <Object>[];
  final List<Object> clocks = <Object>[];
  int authorityStarts = 0;
  int callbackInvocations = 0;
  int cancellationChecks = 0;
  int clockChecks = 0;

  StagedAstEnrichmentSeed seed() {
    final snapshot = _cloneObject(contract['resolution_snapshot']);
    _list(snapshot['aliases']).add(<String, Object?>{
      'declaring_spec_id': 'grammar/main.spec',
      'authored_id': 'expr-v1',
      'resolved_spec_id': 'registry:expr-v2',
    });
    final callback =
        (Map<String, Object?> request, StagedRuntimeContext context) {
          callbackInvocations += 1;
          expect(request['text'], '1+2');
          expect(request['resolved_spec_id'], 'registry:expr-v2');
          expect(request['top_rule'], 'Expr');
          expect(
            identical(context.cancellationToken, cancellationTokens.last),
            isTrue,
          );
          context.safePoint(0);
          return StagedChildExecution.success(_expectedChildAst());
        };
    return StagedAstEnrichmentSeed(
      registrySnapshot: snapshot,
      compiledAuthorities: _compiledAuthorities(snapshot, callback),
      options: _enrichmentOptions(),
      recursiveAuthority: () {
        authorityStarts += 1;
        final token = Object();
        bool cancelled(Object observed) {
          cancellationChecks += 1;
          expect(identical(observed, token), isTrue);
          return false;
        }

        int clock() {
          clockChecks += 1;
          return 0;
        }

        cancellationTokens.add(token);
        cancellationCallbacks.add(cancelled);
        clocks.add(clock);
        return StagedRecursiveAuthority(
          cancellationToken: token,
          cancelled: cancelled,
          clock: clock,
          deadline: 100,
          remainingSteps: 100,
          requiredSteps: 1,
          maxDepth: 8,
          maxCalls: 32,
        );
      },
      outcomeSink: (outcome) => outcomes.add(_cloneObject(outcome)),
    );
  }

  _JsonObject record(List<Object?> values) {
    expect(values, <Object?>[_expectedEnrichedAst(), _expectedEnrichedAst()]);
    expect(authorityStarts, 2);
    expect(callbackInvocations, 2);
    expect(outcomes, hasLength(2));
    expect(outcomes[1], outcomes[0]);
    for (final outcome in outcomes) {
      expect(_object(outcome['cache']), containsPair('entries', 1));
      expect(_object(outcome['cache']), containsPair('hits', 0));
      expect(_object(outcome['cache']), containsPair('misses', 1));
      expect(_object(outcome['resources']), containsPair('total_calls', 1));
    }
    return <String, Object?>{
      'values': _copyPlainForTest(values),
      'outcomes': _copyPlainForTest(outcomes),
      'authority_starts': authorityStarts,
      'callback_invocations': callbackInvocations,
      'cancellation_checks': cancellationChecks,
      'clock_checks': clockChecks,
      'tokens_distinct': !identical(
        cancellationTokens.first,
        cancellationTokens.last,
      ),
      'cancellation_callbacks_distinct': !identical(
        cancellationCallbacks.first,
        cancellationCallbacks.last,
      ),
      'clocks_distinct': !identical(clocks.first, clocks.last),
    };
  }
}

_JsonObject _expectedChildAst() => <String, Object?>{
  'kind': 'expression_ast',
  'text': '1+2',
  'top_rule': 'Expr',
};

_JsonObject _expectedEnrichedAst() => <String, Object?>{
  'job_marker': '1+2',
  'expression_ast': _expectedChildAst(),
};

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

FrozenStagedRegistry _registry(
  _JsonObject contract,
  StagedCompiledAuthority callback,
) {
  final snapshot = _cloneObject(contract['resolution_snapshot']);
  return FrozenStagedRegistry.fromSnapshot(
    snapshot: snapshot,
    compiledAuthorities: _compiledAuthorities(snapshot, callback),
  );
}

StagedRecursiveAuthority _recursiveAuthority({
  Object? cancellationToken,
  bool Function(Object cancellationToken)? cancelled,
  int Function()? clock,
  int deadline = 100,
  int remainingSteps = 100,
  int requiredSteps = 1,
  int maxDepth = 8,
  int maxCalls = 32,
  int totalCalls = 0,
}) => StagedRecursiveAuthority(
  cancellationToken: cancellationToken ?? Object(),
  cancelled: cancelled ?? (_) => false,
  clock: clock ?? () => 0,
  deadline: deadline,
  remainingSteps: remainingSteps,
  requiredSteps: requiredSteps,
  maxDepth: maxDepth,
  maxCalls: maxCalls,
  totalCalls: totalCalls,
);

Map<String, StagedCompiledAuthority> _compiledAuthorities(
  _JsonObject snapshot,
  StagedCompiledAuthority callback,
) => <String, StagedCompiledAuthority>{
  for (final row in _list(snapshot['entries']).map(_object))
    row['compiled_authority']! as String: callback,
};

_JsonObject _enrichmentOptions({
  int maxSteps = 1000,
  int maxResultNodes = 128,
  int maxDiagnosticBytes = 4096,
  String requiredSourceDetail = 'span',
}) => <String, Object?>{
  'declaring_spec_id': 'grammar/main.spec',
  'caller_capabilities': <String>[
    'caller-only',
    'staged-parse-job-v2',
    'structured-result-v1',
    'typed-source-location-v1',
    'xml-v1',
    'yaml-v1',
  ],
  'caller_policy_modes': <String>[
    'append_child',
    'diagnostic_node',
    'fail',
    'keep_text',
    'replace_field',
    'replace_marker',
    'sibling_field',
    'trace',
  ],
  'caller_ceilings': <String, Object?>{
    'source_detail': 'text',
    'max_steps': maxSteps,
    'max_result_nodes': maxResultNodes,
    'max_diagnostic_bytes': maxDiagnosticBytes,
  },
  'required_source_detail': requiredSourceDetail,
  'required_versions': <String, Object?>{
    'spec_language_version': 2,
    'helper_contract_version': 'actionir-v3',
    'staged_contract_version': 2,
  },
};

_JsonObject _marker({
  String text = 'abc',
  int start = 0,
  int? end,
  String nodeKind = 'expression',
  String payloadKind = 'embedded_expression',
  String parserSpecId = 'expr',
  String? topRule = 'Expr',
  String resultPolicy = 'replace_marker',
  String? into,
  String failurePolicy = 'fail',
  _JsonObject? provenance,
  List<String> requiredCapabilities = const <String>[
    'staged-parse-job-v2',
    'typed-source-location-v1',
  ],
}) {
  final sidecar = <String, Object?>{
    'kind': 'staged_parse_job_v2',
    'version': 2,
    'state': 'declared',
    'effect': 'staged_parse_job_declaration',
    'node_kind': nodeKind,
    'payload_kind': payloadKind,
    'parser_spec_id': parserSpecId,
    if (topRule != null) 'top_rule': topRule,
    'result_policy': resultPolicy,
    if (into != null) 'into': into,
    'failure_policy': failurePolicy,
    'required_capabilities': <String>[...requiredCapabilities],
    'text': text,
    'provenance':
        provenance ??
        <String, Object?>{
          'kind': 'direct_span',
          'source_id': 'ascii',
          'start': start,
          'end': end ?? start + text.runes.length,
          'provenance': 'capture',
        },
    'origin': 'contract:parse_job',
  };
  return <String, Object?>{
    'kind': _markerKind,
    'version': 2,
    'sidecar_kind': 'staged_parse_job_v2',
    'effect': 'staged_parse_job_declaration',
    'staged_parse_job_v2': sidecar,
  };
}

Matcher _stagedCode(String code) => isA<StagedAstEnrichmentException>().having(
  (error) => error.code,
  'code',
  code,
);

_JsonObject _cloneObject(Object? value) =>
    _object(jsonDecode(jsonEncode(value)));

Object? _copyPlainForTest(Object? value) => jsonDecode(jsonEncode(value));

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

const _emittedCarrierMain = r'''
import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/src/runtime/staged_ast_enrichment.dart';

import 'generated.dart' as generated;

void main() {
  final contract = jsonDecode(
    File('../capability_conformance/staged_ast_enrichment_contract.json')
        .readAsStringSync(),
  ) as Map<String, Object?>;
  final snapshot = jsonDecode(
    jsonEncode(contract['resolution_snapshot']),
  ) as Map<String, Object?>;
  (snapshot['aliases']! as List<Object?>).add(<String, Object?>{
    'declaring_spec_id': 'grammar/main.spec',
    'authored_id': 'expr-v1',
    'resolved_spec_id': 'registry:expr-v2',
  });

  final outcomes = <Map<String, Object?>>[];
  final cancellationTokens = <Object>[];
  final cancellationCallbacks = <Object>[];
  final clocks = <Object>[];
  var authorityStarts = 0;
  var callbackInvocations = 0;
  var cancellationChecks = 0;
  var clockChecks = 0;

  StagedChildExecution callback(
    Map<String, Object?> request,
    StagedRuntimeContext context,
  ) {
    callbackInvocations += 1;
    if (request['text'] != '1+2' ||
        request['resolved_spec_id'] != 'registry:expr-v2' ||
        request['top_rule'] != 'Expr' ||
        !identical(context.cancellationToken, cancellationTokens.last)) {
      throw StateError('emitted staged callback received invalid authority');
    }
    context.safePoint(0);
    return StagedChildExecution.success(<String, Object?>{
      'kind': 'expression_ast',
      'text': '1+2',
      'top_rule': 'Expr',
    });
  }

  final authorities = <String, StagedCompiledAuthority>{
    for (final entry in (snapshot['entries']! as List<Object?>))
      (entry! as Map<String, Object?>)['compiled_authority']! as String:
          callback,
  };
  final seed = StagedAstEnrichmentSeed(
    registrySnapshot: snapshot,
    compiledAuthorities: authorities,
    options: <String, Object?>{
      'declaring_spec_id': 'grammar/main.spec',
      'caller_capabilities': <String>[
        'caller-only',
        'staged-parse-job-v2',
        'structured-result-v1',
        'typed-source-location-v1',
        'xml-v1',
        'yaml-v1',
      ],
      'caller_policy_modes': <String>[
        'append_child',
        'diagnostic_node',
        'fail',
        'keep_text',
        'replace_field',
        'replace_marker',
        'sibling_field',
        'trace',
      ],
      'caller_ceilings': <String, Object?>{
        'source_detail': 'text',
        'max_steps': 1000,
        'max_result_nodes': 128,
        'max_diagnostic_bytes': 4096,
      },
      'required_source_detail': 'span',
      'required_versions': <String, Object?>{
        'spec_language_version': 2,
        'helper_contract_version': 'actionir-v3',
        'staged_contract_version': 2,
      },
    },
    recursiveAuthority: () {
      authorityStarts += 1;
      final token = Object();
      bool cancelled(Object observed) {
        cancellationChecks += 1;
        if (!identical(observed, token)) {
          throw StateError('emitted staged cancellation identity drifted');
        }
        return false;
      }

      int clock() {
        clockChecks += 1;
        return 0;
      }

      cancellationTokens.add(token);
      cancellationCallbacks.add(cancelled);
      clocks.add(clock);
      return StagedRecursiveAuthority(
        cancellationToken: token,
        cancelled: cancelled,
        clock: clock,
        deadline: 100,
        remainingSteps: 100,
        requiredSteps: 1,
        maxDepth: 8,
        maxCalls: 32,
      );
    },
    outcomeSink: (outcome) => outcomes.add(
      jsonDecode(jsonEncode(outcome)) as Map<String, Object?>,
    ),
  );

  final values = <Object?>[
    generated.execute('1+2;', stagedAstEnrichmentSeed: seed),
    generated.execute('1+2;', stagedAstEnrichmentSeed: seed),
  ];
  print(jsonEncode(<String, Object?>{
    'values': values,
    'outcomes': outcomes,
    'authority_starts': authorityStarts,
    'callback_invocations': callbackInvocations,
    'cancellation_checks': cancellationChecks,
    'clock_checks': clockChecks,
    'tokens_distinct': !identical(
      cancellationTokens.first,
      cancellationTokens.last,
    ),
    'cancellation_callbacks_distinct': !identical(
      cancellationCallbacks.first,
      cancellationCallbacks.last,
    ),
    'clocks_distinct': !identical(clocks.first, clocks.last),
  }));
}
''';
