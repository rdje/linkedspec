// FUTURE-PARITY-BACKLOG.10.5.4.1 — typed record/source query kernel.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/src/semantic/semantic_index.dart';
import 'package:linkedspec_dart/src/semantic/sha256.dart';
import 'package:test/test.dart';

void main() {
  test('typed record source kernel matches nine exact neutral digests', () {
    for (final id in [
      'capabilities',
      'graph_list_rules',
      'graph_duplicate_regex_text',
      'graph_explain_entry',
      'calls_symbols_and_shapes',
      'failed_diagnostic',
      'privacy_none',
      'privacy_text_and_digest',
      'source_ceiling_forbidden',
    ]) {
      final queryCase = _queryCase(id);
      final request = _typedRequest(
        queryCase['request']! as Map<String, Object?>,
      );
      final index = _indexFor(queryCase['snapshot']! as String);
      final response = id == 'capabilities'
          ? index.semanticCapabilitiesForTesting()
          : index.semanticQueryKernelForTesting(request);
      final expected = queryCase['expected']! as Map<String, Object?>;

      expect(response.ok, expected['ok'], reason: '$id status');
      expect(
        response.records.map((record) => record.id),
        expected['record_ids'],
        reason: '$id records',
      );
      expect(
        response.relations.map((relation) => relation.id),
        expected['relation_ids'],
        reason: '$id relations',
      );
      expect(
        response.diagnostics.map((diagnostic) => diagnostic.code),
        expected['diagnostic_codes'],
        reason: '$id diagnostics',
      );
      expect(response.page.complete, expected['complete'], reason: id);
      expect(
        _canonicalDigest(response.toJson()),
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
    final first = index.semanticCapabilitiesForTesting();

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

    final second = index.semanticCapabilitiesForTesting();
    expect(second, isNot(same(first)));
    expect(_canonicalDigest(second.toJson()), expected);
    expect(index.compilationAuthority.compiled, isTrue);
    expect(index.snapshot.hasExecution, isFalse);
  });

  test('source privacy and structural redaction are monotonic', () {
    final privacy = _indexFor('privacy');
    final none = privacy.semanticQueryKernelForTesting(
      _typedRequest(_requestFor('privacy_none')),
    );
    expect(none.records.single.source, isNull);
    expect(none.records.single.facts['pattern'], isNull);
    expect(none.records.single.redactions, ['/facts/pattern']);

    final text = privacy.semanticQueryKernelForTesting(
      _typedRequest(_requestFor('privacy_text_and_digest')),
    );
    expect(text.records.single.facts['pattern'], 'é');
    expect(text.records.single.redactions, isEmpty);
    expect(text.records.single.source?.excerpt, '/é/');
    expect(
      text.records.single.source?.contentDigest,
      allOf(startsWith('sha256:'), hasLength(71)),
    );

    final limited = _indexFor('privacy_limited').semanticQueryKernelForTesting(
      _typedRequest(_requestFor('source_ceiling_forbidden')),
    );
    expect(limited.ok, isFalse);
    expect(limited.diagnostics.single.fields, {
      'requested': 'span',
      'ceiling': 'identity',
    });
  });

  test('kernel is deterministic projection-only and not publicly exported', () {
    final index = _indexFor('graph');
    final explain = _typedRequest(_requestFor('graph_explain_entry'));
    final list = _typedRequest(_requestFor('graph_list_rules'));
    final first = index.semanticQueryKernelForTesting(explain);
    final middle = index.semanticQueryKernelForTesting(list);
    final second = index.semanticQueryKernelForTesting(explain);

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
    for (final omitted in [
      'SemanticQueryOperation',
      'SemanticQueryResponse',
      'SemanticIndexQueryKernelTestAccess',
    ]) {
      expect(publicLibrary, isNot(contains(omitted)), reason: omitted);
    }
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
