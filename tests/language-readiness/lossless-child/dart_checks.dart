import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/runtime/staged_ast_enrichment.dart';
import 'package:linkedspec_dart/src/semantic/sha256.dart' show sha256Hex;

import '../nested-tree/dart_checks.dart' show exactJson, require;

typedef Json = Map<String, Object?>;
typedef Parse = Object? Function(String input);
typedef Builder = Parse Function(StagedAstEnrichmentSeed? seed);
Json object(Object? value) => (value as Map).cast<String, Object?>();
Object? copy(Object? value) => jsonDecode(jsonEncode(value));
String digest(String source) => 'sha256:${sha256Hex(utf8.encode(source))}';

final class Probe {
  Probe(this.child, this.childDigest);
  final Parse child;
  final String childDigest;
  final calls = <Json>[];
  final outcomes = <Json>[];

  void clear() {
    calls.clear();
    outcomes.clear();
  }

  StagedAstEnrichmentSeed seed([String change = '']) {
    const caps = ['staged-parse-job-v2', 'typed-source-location-v1'];
    const modes = ['fail', 'sibling_field'];
    const ceilings = <String, Object?>{
      'source_detail': 'span',
      'max_steps': 100,
      'max_result_nodes': 512,
      'max_diagnostic_bytes': 4096,
    };
    final snapshot = <String, Object?>{
      'immutable': true,
      'prepared_before_authored_execution': true,
      'filesystem_access_during_dispatch': false,
      'aliases': [
        if (change != 'missing_identity')
          {
            'declaring_spec_id': 'readiness/parent.spec',
            'authored_id': 'integer',
            'resolved_spec_id': 'registry:integer-v1',
          },
      ],
      'declaring_relative': <Object?>[],
      'search_roots': <Object?>[],
      'providers': <Object?>[],
      'entries': [
        {
          'resolved_spec_id': 'registry:integer-v1',
          'compiled_authority': 'opaque:integer',
          'content_digest': childDigest,
          'import_graph_fingerprint': digest(''),
          'default_top_rule': change == 'forbidden_top' ? 'Other' : 'Number',
          'allowed_top_rules': [change == 'forbidden_top' ? 'Other' : 'Number'],
          'spec_language_version': 2,
          'helper_contract_version': 'actionir-v3',
          'staged_contract_version': 2,
          'capabilities': caps,
          'policy_modes': modes,
          'ceilings': ceilings,
        },
      ],
    };
    return StagedAstEnrichmentSeed(
      registrySnapshot: snapshot,
      compiledAuthorities: {
        'opaque:integer': (request, context) {
          calls.add({'text': request['text'], 'top': request['top_rule']});
          try {
            // The precompiled child alone recognizes the payload and builds its semantic result.
            final result = object(child(request['text'] as String));
            result['source_span'] = context.rebaseSpan(object(result['span']));
            return StagedChildExecution.success(result);
          } on RuntimeExitNow catch (error) {
            return StagedChildExecution.failure({
              'code': 'child_exit',
              'status': error.status,
            });
          }
        },
      },
      options: {
        'declaring_spec_id': 'readiness/parent.spec',
        'caller_capabilities': caps,
        'caller_policy_modes': modes,
        'caller_ceilings': ceilings,
        'required_source_detail': 'span',
        'required_versions': {
          'spec_language_version': 2,
          'helper_contract_version': 'actionir-v3',
          'staged_contract_version': 2,
        },
      },
      recursiveAuthority: () => StagedRecursiveAuthority(
        cancellationToken: 'lossless-child-readiness',
        cancelled: (_) => false,
        clock: () => 0,
        deadline: 100,
        remainingSteps: change == 'no_budget' ? 0 : 100,
        requiredSteps: 1,
        maxDepth: 4,
        maxCalls: change == 'one_call' ? 1 : 16,
      ),
      outcomeSink: outcomes.add,
    );
  }
}

Json caseById(Json cases, String id) =>
    (cases['accept'] as List).map(object).singleWhere((row) => row['id'] == id);

void segments(Object? actual, Object? expected, String input) {
  exactJson(actual, expected);
  final scalars = input.runes.toList();
  var cursor = 0;
  final reconstructed = StringBuffer();
  for (final part in (actual as List).map(object)) {
    final span = part['span'];
    final start = (span is List ? span[0] : object(span)['start']) as int;
    final end = (span is List ? span[1] : object(span)['end']) as int;
    require(
      start == cursor && start <= end && end <= scalars.length,
      'ordered scalar adjacency',
    );
    exactJson(part['text'], String.fromCharCodes(scalars.sublist(start, end)));
    reconstructed.write(part['text']);
    cursor = end;
  }
  require(cursor == scalars.length, 'complete scalar coverage');
  exactJson(reconstructed.toString(), input);
}

void segmentation(Json cases, Parse parse) {
  final accepted = (cases['accept'] as List).map(object).toList();
  require(accepted.length == 13, 'original segmentation inventory');
  for (var round = 0; round < 2; round++) {
    for (final row in accepted) {
      segments(
        parse(row['input'] as String),
        row['expected'],
        row['input'] as String,
      );
    }
  }
  final row = caseById(cases, 'unicode_edges');
  final returned = parse(row['input'] as String) as List;
  object(returned[0])['text'] = 'changed gap';
  object(object(returned[0])['span'])['start'] = 999;
  segments(
    parse(row['input'] as String),
    row['expected'],
    row['input'] as String,
  );
}

void composed(Object? result, Json outcome, Json row, List<Json> calls) {
  exactJson(outcome['ast'], result);
  final original = copy(result) as List;
  final requests = <Json>[];
  final expectedSidecars = <({Object path, Json span})>[];
  final expected = row['expected'] as List;
  for (var index = 0; index < expected.length; index++) {
    final item = object(expected[index]);
    if (item['kind'] != 'item') continue;
    final token = item['text'] as String;
    final text = token.substring(
      1,
      token.length - 1,
    ); // Authored selected items are ASCII.
    final itemSpan = item['span'] as List;
    final span = <String, Object?>{
      'kind': 'direct_span',
      'source_id': 'input',
      'provenance': 'entry_group',
      'start': (itemSpan[0] as int) + 1,
      'end': (itemSpan[1] as int) - 1,
    };
    final annotated = object(original[index]);
    exactJson(annotated['child'], text);
    exactJson(annotated['parsed'], {
      'kind': 'integer',
      'text': text,
      'span': {'start': 0, 'end': text.runes.length},
      'source_span': span,
    });
    annotated.remove('child');
    annotated.remove('parsed');
    requests.add({'text': text, 'top': 'Number'});
    expectedSidecars.add((path: [index, 'child'], span: span));
  }
  segments(original, row['expected'], row['input'] as String);
  exactJson(calls, requests);
  final sidecars = (outcome['sidecars'] as List).map(object).toList();
  require(sidecars.length == expectedSidecars.length, 'sidecar count');
  for (var i = 0; i < sidecars.length; i++) {
    exactJson(sidecars[i]['parent_ast_path'], expectedSidecars[i].path);
    exactJson(sidecars[i]['provenance'], expectedSidecars[i].span);
    exactJson(sidecars[i]['resolved_spec_id'], 'registry:integer-v1');
    exactJson(sidecars[i]['top_rule'], 'Number');
    exactJson(sidecars[i]['state'], 'succeeded');
  }
  exactJson(object(outcome['resources'])['total_calls'], requests.length);
  exactJson(object(outcome['cache'])['misses'], requests.isEmpty ? 0 : 1);
  exactJson(
    object(outcome['cache'])['hits'],
    requests.isEmpty ? 0 : requests.length - 1,
  );
  exactJson(outcome['diagnostics'], <Object?>[]);
}

void rejects(Parse parse, String input, String code) {
  Object? failure;
  try {
    parse(input);
  } on Object catch (error) {
    failure = error;
  }
  require(failure != null, 'must reject $input');
  if (failure is StagedAstEnrichmentException) {
    exactJson(failure.code, code);
    return;
  }
  final message = switch (failure) {
    RuntimeInterpreterException() => failure.message,
    GeneratedSourceException() => failure.detail,
    _ => throw StateError('unexpected staged failure: $failure'),
  };
  final match = RegExp(
    r'^(?:RuntimeInterpreterException: )?LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:(staged_[a-z_]+)$',
  ).firstMatch(message ?? '');
  require(match != null, 'exact staged diagnostic wrapper: $message');
  exactJson(match!.group(1), code);
}

List<Object?> children(
  Json cases,
  Json strict,
  Builder parentBuilder,
  Parse child,
  String childDigest,
) {
  final probe = Probe(child, childDigest);
  final parse = parentBuilder(probe.seed());
  final records = <Object?>[];
  for (var round = 0; round < 2; round++) {
    for (final row in (cases['accept'] as List).map(object)) {
      probe.clear();
      final result = parse(row['input'] as String);
      require(
        probe.outcomes.length == 1,
        'one completed outcome per successful invocation',
      );
      composed(result, probe.outcomes.single, row, probe.calls);
      records.add(copy(probe.outcomes.single));
    }
  }
  probe.clear();
  rejects(parse, '[12][00][7]', 'staged_child_failed');
  exactJson(probe.calls, [
    {'text': '12', 'top': 'Number'},
    {'text': '00', 'top': 'Number'},
  ]);
  require(
    probe.outcomes.isEmpty,
    'failed child publishes no completed outcome',
  );
  final recovery = object(copy(caseById(cases, 'single_zero')));
  recovery['input'] = '[8]';
  object((recovery['expected'] as List)[1])['text'] = '[8]';
  probe.clear();
  final recovered = parse('[8]');
  composed(recovered, probe.outcomes.single, recovery, probe.calls);
  for (final control in [
    ("missing_identity", "staged_registry_missing", 0),
    ("forbidden_top", "staged_top_rule_forbidden", 0),
    ("no_budget", "staged_budget_exhausted", 0),
    ("one_call", "staged_call_limit_exceeded", 1),
  ]) {
    final changed = parentBuilder(probe.seed(control.$1));
    probe.clear();
    rejects(changed, '[1][2]', control.$2);
    require(
      probe.calls.length == control.$3,
      'exact callback count ${control.$1}',
    );
    require(
      probe.outcomes.isEmpty,
      'authority failure publishes no completed outcome',
    );
  }
  probe.clear();
  final returned = parse('α[12]🙂') as List;
  object(object(returned[1])['parsed'])['text'] = 'changed child';
  final exposed = probe.outcomes.single;
  object(
    object(object((exposed['ast'] as List)[1])['parsed'])['source_span'],
  )['start'] = 999;
  probe.clear();
  final again = parse('α[12]🙂');
  composed(
    again,
    probe.outcomes.single,
    caseById(cases, 'unicode_edges'),
    probe.calls,
  );
  probe.clear();
  final inert = parentBuilder(null)('α[12]🙂') as List;
  final marker = object(object(inert[1])['child']);
  exactJson(marker['kind'], 'STAGED_PARSE_JOB_MARKER');
  exactJson(object(marker['staged_parse_job_v2'])['text'], '12');
  require(
    probe.calls.isEmpty && probe.outcomes.isEmpty,
    'no seed executes no child',
  );
  require(
    (strict['accept'] as List).length == 4 &&
        (strict['reject'] as List).length == 15,
    'strict child inventory',
  );
  for (final row in (strict['accept'] as List).map(object)) {
    exactJson(child(row['input'] as String), row['expected']);
  }
  for (final input in (strict['reject'] as List).cast<String>()) {
    var rejected = false;
    try {
      child(input);
    } on RuntimeExitNow catch (error) {
      rejected = true;
      exactJson(error.status, 1);
    }
    require(rejected, 'typed strict child rejection: $input');
  }
  return records;
}

void childMutation(String id, Builder parent, Parse child, String childDigest) {
  final probe = Probe(child, childDigest);
  final parse = parent(probe.seed());
  if (id == 'leading_zero') {
    final result = parse('[00]') as List;
    exactJson(object(result[1])['parsed'], {
      'kind': 'integer',
      'text': '00',
      'span': {'start': 0, 'end': 2},
      'source_span': {
        'kind': 'direct_span',
        'source_id': 'input',
        'start': 1,
        'end': 3,
        'provenance': 'entry_group',
      },
    });
  } else if (id == 'wrong_span') {
    final parsed = object(object((parse('α[12]🙂') as List)[1])['parsed']);
    exactJson(parsed['span'], {'start': 1, 'end': 2});
    exactJson(parsed['source_span'], {
      'kind': 'direct_span',
      'source_id': 'input',
      'start': 3,
      'end': 4,
      'provenance': 'entry_group',
    });
  } else if (id == 'whole_item') {
    rejects(parse, 'α[12]🙂', 'staged_child_failed');
    exactJson(probe.calls, [
      {'text': '[12]', 'top': 'Number'},
    ]);
    require(
      probe.outcomes.isEmpty,
      'wrong operand publishes no completed outcome',
    );
  } else {
    throw StateError('unknown child mutation $id');
  }
}

void segmentMutation(String id, Json cases, Parse parse) {
  final row = caseById(
    cases,
    id == 'selection'
        ? 'single_zero'
        : id == 'entry_prefix'
        ? 'leading_lf'
        : 'unicode_edges',
  );
  var expected = copy(row['expected']) as List;
  switch (id) {
    case 'selection':
      expected = [
        {
          'kind': 'tail',
          'span': {
            'source_id': 'input',
            'start': 0,
            'end': 3,
            'provenance': 'gap',
          },
          'text': '[0]',
        },
      ];
    case 'tail':
      expected.removeLast();
    case 'item_span':
      object(expected[1])['span'] = [5, 5];
    case 'entry_prefix':
      expected.removeAt(0);
    default:
      throw StateError('unknown segment mutation $id');
  }
  exactJson(parse(row['input'] as String), expected);
  require(
    jsonEncode(expected) != jsonEncode(row['expected']),
    'mutation differs from the original oracle',
  );
}
