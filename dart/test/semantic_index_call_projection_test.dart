// FUTURE-PARITY-BACKLOG.10.5.3.1-.2 — exact typed calls and provenance.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/src/semantic/semantic_index.dart';
import 'package:test/test.dart';

void main() {
  test(
    'calls staging and generated projection deep-equals the neutral target',
    () {
      final actual = _materializeSources(_projection(_callsSource));
      final wanted = _callsExpected();
      expect(actual, _materializeSources(wanted));
    },
  );

  test('staged roles stay distinct from the selected generated plan', () {
    final projection = _projection(_callsSource);
    final records = (projection['records']! as List<Object?>)
        .cast<Map<String, Object?>>();
    final staged = records
        .where((record) => record['kind'] == 'staged_artifact')
        .toList();
    expect(staged.map((record) => record['id']), [
      'staged:payload:function:normalize:0',
      'staged:parse_job:function:normalize:1',
      'staged:result:function:normalize:2',
    ]);
    expect(
      staged.map(
        (record) => (record['facts']! as Map<String, Object?>)['artifact_kind'],
      ),
      ['payload', 'parse_job', 'result'],
    );
    final generated = records.singleWhere(
      (record) => record['id'] == 'generated:handler_plan:0',
    );
    expect(generated['kind'], 'generated_artifact');
    expect(generated['facts'], {
      'artifact_kind': 'handler_plan',
      'contract_id': 'linkedspec-generated-source-v2',
      'format_version': 2,
      'plan_family': 'default',
    });

    final relations = (projection['relations']! as List<Object?>)
        .cast<Map<String, Object?>>();
    expect(
      relations.map((relation) => relation['id']),
      containsAll([
        'relation:consumes:staged:parse_job:function:normalize:1:'
            'staged:payload:function:normalize:0:0',
        'relation:produces:staged:parse_job:function:normalize:1:'
            'staged:result:function:normalize:2:0',
        'relation:staged_by:staged:result:function:normalize:2:'
            'staged:parse_job:function:normalize:1:0',
        'relation:generated_as:spec:0:generated:handler_plan:0:0',
      ]),
    );
  });

  test('interleaved function shells keep exact Unicode call evidence', () {
    final source = '''Top::
 /x/ -> Done {
   result = normalize(match_text())
   return(result)
 }

fn normalize(value) { return(trim("é")) }

Done:
 /x/
''';
    final projection = _projection(source);
    final records = (projection['records']! as List<Object?>)
        .cast<Map<String, Object?>>();
    final spec = records.singleWhere((record) => record['id'] == 'spec:0');
    final facts = spec['facts']! as Map<String, Object?>;
    expect(facts['definition_order'], [
      'rule:Top',
      'function:normalize',
      'rule:Done',
    ]);
    expect(
      records
          .where((record) => record['kind'] == 'edge')
          .map((record) => record['id']),
      ['edge:rule:Top:0'],
    );

    final call = records.singleWhere(
      (record) => record['id'] == 'call:function:normalize:0',
    );
    final sourceKey = call['source']! as String;
    final sourceRef =
        (projection['source_refs']! as Map<String, Object?>)[sourceKey]!
            as Map<String, Object?>;
    final span = sourceRef['span']! as Map<String, Object?>;
    expect(sourceRef['excerpt'], 'trim("é")');
    expect(
      (span['end_byte']! as int) - (span['start_byte']! as int),
      utf8.encode('trim("é")').length,
    );
    expect(
      (span['end_column']! as int) - (span['start_column']! as int),
      'trim("é")'.runes.length,
    );
  });

  test('call projection remains detached and package-internal', () {
    final index = _index(_callsSource);
    final first = index.semanticStaticProjectionForTesting();
    final calls = (first['records']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .where((record) => record['kind'] == 'call')
        .toList();
    final facts = calls.first['facts']! as Map<String, Object?>;
    facts['resolution_kind'] = 'injected';
    final second = index.semanticStaticProjectionForTesting();
    final secondCall = (second['records']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .firstWhere((record) => record['kind'] == 'call');
    expect(
      (secondCall['facts']! as Map<String, Object?>)['resolution_kind'],
      'helper',
    );
    expect(jsonDecode(jsonEncode(second)), second);
    _expectPlainProjection(second);

    final publicLibrary = File('lib/linkedspec_dart.dart').readAsStringSync();
    expect(
      publicLibrary,
      isNot(contains('SemanticIndexStaticProjectionTestAccess')),
    );
  });
}

final Map<String, Object?> _model =
    jsonDecode(
          File(
            '../capability_conformance/semantic_introspection_model.json',
          ).readAsStringSync(),
        )!
        as Map<String, Object?>;

final String _callsSource = File(
  '../capability_conformance/semantic_introspection/calls_and_staging.spec',
).readAsStringSync();

SemanticIndex _index(String source) => SemanticIndex.fromSource(
  source,
  options: const SemanticIndexOptions(
    logicalName: 'calls_and_staging.spec',
    sourceDetailCeiling: SemanticSourceDetail.text,
  ),
);

Map<String, Object?> _projection(String source) =>
    _index(source).semanticStaticProjectionForTesting();

Map<String, Object?> _callsExpected() {
  final snapshots = _model['snapshots']! as List<Object?>;
  final wanted = _copy(
    snapshots.cast<Map<String, Object?>>().singleWhere(
      (snapshot) => snapshot['id'] == 'calls',
    ),
  );
  wanted.remove('id');
  wanted.remove('fixture');
  return wanted;
}

void _expectPlainProjection(Object? value) {
  const forbiddenKeys = {
    'host_path',
    'file_path',
    'source_text',
    'source_bytes',
    'body_source',
    'body_payload',
    'body_parse_job',
    'body_ast',
    'ast',
    'action_ir',
    'descriptor',
    'compiled_regex',
    'generated_source',
    'executor',
    'trace',
    'diagnostic_sink',
    'runtime_observer',
  };
  switch (value) {
    case Map<Object?, Object?>():
      for (final entry in value.entries) {
        expect(entry.key, isA<String>());
        expect(forbiddenKeys, isNot(contains(entry.key)), reason: '$entry');
        _expectPlainProjection(entry.value);
      }
    case List<Object?>():
      for (final item in value) {
        _expectPlainProjection(item);
      }
    case null || String() || num() || bool():
      return;
    default:
      fail('projection leaked non-plain host value ${value.runtimeType}');
  }
}

Map<String, Object?> _materializeSources(Map<String, Object?> projection) {
  final copy = _copy(projection);
  final sourceRefs = copy.remove('source_refs')! as Map<String, Object?>;
  for (final group in ['records', 'relations']) {
    for (final item in copy[group]! as List<Object?>) {
      final row = item! as Map<String, Object?>;
      final source = row['source'];
      if (source is String) {
        row['source'] = _copy(sourceRefs[source]! as Map<String, Object?>);
      }
    }
  }
  return copy;
}

Map<String, Object?> _copy(Map<String, Object?> value) =>
    jsonDecode(jsonEncode(value))! as Map<String, Object?>;
