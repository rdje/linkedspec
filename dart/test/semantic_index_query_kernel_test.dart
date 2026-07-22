// FUTURE-PARITY-BACKLOG.10.5.4.1-.3 — exact public typed/raw query.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/semantic/sha256.dart';
import 'package:test/test.dart';

void main() {
  test('public typed and neutral paths match all nineteen static digests', () {
    final queryCases = (_contract['query_cases']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .where((queryCase) => queryCase['id'] != 'runtime_events')
        .toList();
    expect(queryCases, hasLength(19));

    for (final queryCase in queryCases) {
      final id = queryCase['id']! as String;
      final requestValue = queryCase['request']! as Map<String, Object?>;
      final requestBefore = _cloneMap(requestValue);
      final request = _typedRequest(requestValue);
      final index = _indexFor(queryCase['snapshot']! as String);
      final typed = id == 'capabilities'
          ? index.capabilities
          : index.query(request);
      final neutral = index.queryNeutral(requestValue);
      final expected = queryCase['expected']! as Map<String, Object?>;

      expect(requestValue, requestBefore, reason: '$id input isolation');
      expect(typed, neutral, reason: '$id typed/neutral identity');
      expect(typed.ok, expected['ok'], reason: '$id status');
      expect(
        typed.records.map((record) => record.id),
        expected['record_ids'],
        reason: '$id records',
      );
      expect(
        typed.relations.map((relation) => relation.id),
        expected['relation_ids'],
        reason: '$id relations',
      );
      expect(
        typed.diagnostics.map((diagnostic) => diagnostic.code),
        expected['diagnostic_codes'],
        reason: '$id diagnostics',
      );
      expect(typed.page.complete, expected['complete'], reason: id);
      expect(
        _canonicalDigest(typed.toJson()),
        expected['response_sha256'],
        reason: '$id full response digest',
      );
    }
  });

  test('capabilities and response values are immutable fresh clones', () {
    final queryCase = _queryCase('capabilities');
    final expected =
        (queryCase['expected']! as Map<String, Object?>)['response_sha256'];
    final index = _indexFor('graph');
    final first = index.capabilities;

    expect(
      () => first.records.add(first.records.single),
      throwsUnsupportedError,
    );
    expect(
      () => first.records.single.facts['model_ids'] = ['host-private'],
      throwsUnsupportedError,
    );
    final detached = first.toJson();
    final records = detached['records']! as List<Object?>;
    final capability = records.single as Map<String, Object?>;
    final facts = capability['facts']! as Map<String, Object?>;
    (facts['record_kinds']! as List<Object?>)[0] = 'host-private';

    final second = index.capabilities;
    expect(second, isNot(same(first)));
    expect(_canonicalDigest(second.toJson()), expected);
    expect(index.compilationAuthority.compiled, isTrue);
    expect(index.snapshot.hasExecution, isFalse);
  });

  test('source privacy and structural redaction are monotonic', () {
    final privacy = _indexFor('privacy');
    final none = privacy.query(_typedRequest(_requestFor('privacy_none')));
    expect(none.records.single.source, isNull);
    expect(none.records.single.facts['pattern'], isNull);
    expect(none.records.single.redactions, ['/facts/pattern']);

    final text = privacy.query(
      _typedRequest(_requestFor('privacy_text_and_digest')),
    );
    expect(text.records.single.facts['pattern'], 'é');
    expect(text.records.single.redactions, isEmpty);
    expect(text.records.single.source?.excerpt, '/é/');
    expect(
      text.records.single.source?.contentDigest,
      allOf(startsWith('sha256:'), hasLength(71)),
    );

    final limited = _indexFor(
      'privacy_limited',
    ).query(_typedRequest(_requestFor('source_ceiling_forbidden')));
    expect(limited.ok, isFalse);
    expect(limited.diagnostics.single.fields, {
      'requested': 'span',
      'ceiling': 'identity',
    });
    expect(
      _canonicalDigest(limited.toJson()),
      (_queryCase('source_ceiling_forbidden')['expected']!
          as Map<String, Object?>)['response_sha256'],
    );
  });

  test('raw neutral validation rejects all twenty-six boundaries', () {
    final cases = _invalidQueryCases();
    expect(cases, hasLength(26));
    final index = _indexFor('graph');

    for (final queryCase in cases) {
      final before = _cloneJson(queryCase.request);
      final response = index.queryNeutral(queryCase.request);

      expect(queryCase.request, before, reason: queryCase.label);
      expect(response.ok, isFalse, reason: queryCase.label);
      expect(
        response.diagnostics.single.code,
        queryCase.code,
        reason: queryCase.label,
      );
      if (queryCase.reason != null) {
        expect(
          response.diagnostics.single.fields['reason'],
          queryCase.reason,
          reason: queryCase.label,
        );
      }
      expect(response.records, isEmpty, reason: queryCase.label);
      expect(response.relations, isEmpty, reason: queryCase.label);
    }
  });

  test('both-direction traversal is breadth-first and depth bounded', () {
    final response = _indexFor('graph').query(
      SemanticQuery(
        operation: SemanticQueryOperation.relations,
        subjects: const ['rule:Top'],
        direction: SemanticQueryDirection.both,
        budget: const SemanticQueryBudget(maxDepth: 1),
      ),
    );

    expect(response.records, isEmpty);
    expect(response.relations.map((relation) => relation.id), [
      'relation:declares:spec:0:rule:Top:0',
      'relation:contains:rule:Top:edge:rule:Top:0:0',
      'relation:contains:rule:Top:edge:rule:Top:1:1',
      'relation:contains:rule:Top:lifecycle:rule:Top:E:0:2',
    ]);
    expect(
      response.cost,
      const SemanticQueryCost(
        recordsExamined: 0,
        relationsExamined: 4,
        depthReached: 1,
      ),
    );
    expect(response.page.complete, isFalse);
    expect(response.page.nextAfterId, isNull);
    expect(response.diagnostics.single.fields, {'limit': 'max_depth'});
  });

  test('public query is deterministic projection-only and host clean', () {
    final index = _indexFor('graph');
    final explain = _typedRequest(_requestFor('graph_explain_entry'));
    final list = _typedRequest(_requestFor('graph_list_rules'));
    final first = index.query(explain);
    final middle = index.query(list);
    final second = index.query(explain);

    expect(first, second);
    expect(first, isNot(middle));
    final encoded = jsonEncode(first.toJson());
    for (final forbidden in [
      '/tmp/',
      '/Users/',
      'CompiledSpec',
      'ActionIR',
      'Regex(',
      '0x',
      'generated source',
    ]) {
      expect(encoded, isNot(contains(forbidden)), reason: forbidden);
    }

    final implementation = File(
      'lib/src/semantic/semantic_query.dart',
    ).readAsStringSync();
    for (final forbidden in [
      '_sourceText',
      '_sourceBytes',
      '_sourceMap',
      '_compilationOutcome',
      'parseSpecWithStagedUserFunctionDefinitions(',
      'compileSpec(',
      'emitDartSource(',
      'executeGeneratedParser',
      'LinkedSpecRuntimeEngine',
      'Platform.environment',
      'File(',
    ]) {
      expect(implementation, isNot(contains(forbidden)), reason: forbidden);
    }

    final publicLibrary = File('lib/linkedspec_dart.dart').readAsStringSync();
    for (final exposed in ['SemanticQueryOperation', 'SemanticQueryResponse']) {
      expect(publicLibrary, contains(exposed), reason: exposed);
    }
    expect(
      publicLibrary,
      isNot(contains('SemanticIndexQueryKernelTestAccess')),
    );
  });
}

final Map<String, Object?> _contract =
    jsonDecode(
          File(
            '../capability_conformance/semantic_introspection_contract.json',
          ).readAsStringSync(),
        )!
        as Map<String, Object?>;

Map<String, Object?> _queryCase(String id) =>
    (_contract['query_cases']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .singleWhere((queryCase) => queryCase['id'] == id);

Map<String, Object?> _requestFor(String id) =>
    _queryCase(id)['request']! as Map<String, Object?>;

Map<String, Object?> _cloneMap(Map<String, Object?> value) =>
    jsonDecode(jsonEncode(value))! as Map<String, Object?>;

Object? _cloneJson(Object? value) => jsonDecode(jsonEncode(value));

typedef _InvalidQueryCase = ({
  String label,
  Object? request,
  String code,
  String? reason,
});

List<_InvalidQueryCase> _invalidQueryCases() {
  Map<String, Object?> request() => _cloneMap(_requestFor('graph_list_rules'));

  final cases = <_InvalidQueryCase>[
    (
      label: 'request_not_object',
      request: <Object?>[],
      code: 'semantic_query_invalid',
      reason: 'request_not_object',
    ),
  ];
  void add(
    String label,
    Object? value, {
    String code = 'semantic_query_invalid',
    String? reason,
  }) {
    cases.add((label: label, request: value, code: code, reason: reason));
  }

  var value = request();
  value['contract'] = 'linkedspec-semantic-query-v0';
  add(
    'unsupported_contract',
    value,
    code: 'semantic_query_contract_unsupported',
  );

  value = request()..remove('direction');
  add('request_fields', value, reason: 'request_fields');

  value = request();
  (value['page']! as Map<String, Object?>).remove('limit');
  add('page_fields', value, reason: 'page_fields');

  value = request();
  (value['budget']! as Map<String, Object?>).remove('max_depth');
  add('budget_fields', value, reason: 'budget_fields');

  value = request();
  (value['source']! as Map<String, Object?>).remove('detail');
  add('source_fields', value, reason: 'source_fields');

  value = request()..['operation'] = 'search';
  add('operation', value, reason: 'operation');

  value = request()..['subjects'] = 'rule:Top';
  add('subjects_type', value, reason: 'subjects_type');

  value = request()
    ..['operation'] = 'get'
    ..['subjects'] = ['rule:Top', 'rule:Top']
    ..['record_kinds'] = <Object?>[];
  add('subjects_duplicate', value, reason: 'subjects_duplicate');

  value = request()..['record_kinds'] = ['host_ast'];
  add('record_kind', value, reason: 'record_kind');

  var relation = request()
    ..['operation'] = 'relations'
    ..['subjects'] = ['rule:Top']
    ..['record_kinds'] = <Object?>[]
    ..['relation_kinds'] = ['host_edge'];
  add('relation_kind', relation, reason: 'relation_kind');

  value = request()..['record_kinds'] = ['regex_slot', 'rule'];
  add('record_kind_order', value, reason: 'record_kind_order');

  relation = request()
    ..['operation'] = 'relations'
    ..['subjects'] = ['rule:Top']
    ..['record_kinds'] = <Object?>[]
    ..['relation_kinds'] = ['contains', 'declares'];
  add('relation_kind_order', relation, reason: 'relation_kind_order');

  value = request()..['direction'] = 'sideways';
  add('direction', value, reason: 'direction');

  value = request();
  (value['page']! as Map<String, Object?>)['after_id'] = 7;
  add('after_id', value, reason: 'after_id');

  value = request();
  (value['page']! as Map<String, Object?>)['limit'] = 0;
  add('page_limit', value, reason: 'page_limit');

  for (final (field, invalid) in [
    ('max_records', 0),
    ('max_relations', 0),
    ('max_depth', 9),
  ]) {
    value = request();
    (value['budget']! as Map<String, Object?>)[field] = invalid;
    add(field, value, reason: field);
  }

  value = request();
  (value['source']! as Map<String, Object?>)['detail'] = 'full';
  add('source_policy', value, reason: 'source_policy');

  value = request();
  (value['source']! as Map<String, Object?>)['include_content_digest'] = 0;
  add('numeric_boolean', value, reason: 'source_policy');

  value = request();
  (value['source']! as Map<String, Object?>)['include_content_digest'] = true;
  add('digest_requires_text', value, reason: 'digest_requires_text');

  value = request()..['subjects'] = ['rule:Top'];
  add('operation_combination', value, reason: 'operation_combination');

  value = request()
    ..['operation'] = 'get'
    ..['subjects'] = ['rule:Unknown']
    ..['record_kinds'] = <Object?>[];
  add('unknown_subject', value, reason: 'unknown_subject');

  value = request();
  (value['page']! as Map<String, Object?>)['after_id'] = 'rule:Unknown';
  add(
    'after_id_not_in_primary_stream',
    value,
    reason: 'after_id_not_in_primary_stream',
  );

  value = request()
    ..['operation'] = 'explain'
    ..['subjects'] = ['rule:Child']
    ..['record_kinds'] = <Object?>[];
  add('not_explainable', value, reason: 'not_explainable');

  return cases;
}

SemanticIndex _indexFor(String snapshot) {
  final (fixture, ceiling) = switch (snapshot) {
    'graph' => ('graph', SemanticSourceDetail.text),
    'calls' => ('calls_and_staging', SemanticSourceDetail.text),
    'failed' => ('failed', SemanticSourceDetail.span),
    'privacy' => ('privacy', SemanticSourceDetail.text),
    'privacy_limited' => ('privacy', SemanticSourceDetail.identity),
    _ => throw StateError('Unexpected static snapshot: $snapshot'),
  };
  return SemanticIndex.fromUtf8(
    File(
      '../capability_conformance/semantic_introspection/$fixture.spec',
    ).readAsBytesSync(),
    options: SemanticIndexOptions(
      logicalName: '$fixture.spec',
      sourceDetailCeiling: ceiling,
    ),
  );
}

SemanticQuery _typedRequest(Map<String, Object?> value) {
  final page = value['page']! as Map<String, Object?>;
  final budget = value['budget']! as Map<String, Object?>;
  final source = value['source']! as Map<String, Object?>;
  return SemanticQuery(
    contract: value['contract']! as String,
    operation: switch (value['operation']) {
      'capabilities' => SemanticQueryOperation.capabilities,
      'list' => SemanticQueryOperation.list,
      'get' => SemanticQueryOperation.get,
      'relations' => SemanticQueryOperation.relations,
      'explain' => SemanticQueryOperation.explain,
      final operation => throw StateError('Unexpected operation: $operation'),
    },
    subjects: (value['subjects']! as List<Object?>).cast<String>(),
    recordKinds: (value['record_kinds']! as List<Object?>).cast<String>(),
    relationKinds: (value['relation_kinds']! as List<Object?>).cast<String>(),
    direction: switch (value['direction']) {
      'outgoing' => SemanticQueryDirection.outgoing,
      'incoming' => SemanticQueryDirection.incoming,
      'both' => SemanticQueryDirection.both,
      final direction => throw StateError('Unexpected direction: $direction'),
    },
    page: SemanticQueryPage(
      afterId: page['after_id'] as String?,
      limit: page['limit']! as int,
    ),
    budget: SemanticQueryBudget(
      maxRecords: budget['max_records']! as int,
      maxRelations: budget['max_relations']! as int,
      maxDepth: budget['max_depth']! as int,
    ),
    source: SemanticQuerySource(
      detail: switch (source['detail']) {
        'none' => SemanticSourceDetail.none,
        'identity' => SemanticSourceDetail.identity,
        'span' => SemanticSourceDetail.span,
        'text' => SemanticSourceDetail.text,
        final detail => throw StateError('Unexpected source detail: $detail'),
      },
      includeContentDigest: source['include_content_digest']! as bool,
    ),
  );
}

String _canonicalDigest(Map<String, Object?> value) =>
    sha256Hex(utf8.encode(jsonEncode(_canonicalValue(value))));

Object? _canonicalValue(Object? value) {
  if (value case Map<Object?, Object?>()) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return <String, Object?>{
      for (final key in keys) key: _canonicalValue(value[key]),
    };
  }
  if (value case List<Object?>()) {
    return [for (final item in value) _canonicalValue(item)];
  }
  return value;
}
