// FUTURE-PARITY-BACKLOG.10.5.3.1 — exact typed call/binding core.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/src/semantic/semantic_index.dart';
import 'package:test/test.dart';

void main() {
  test('typed call and binding core deep-equals the neutral subset', () {
    final actual = _materializeSources(_projection(_callsSource));
    final wanted = _callsCoreExpected();
    expect(actual, _materializeSources(wanted));
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

Map<String, Object?> _callsCoreExpected() {
  final snapshots = _model['snapshots']! as List<Object?>;
  final wanted = _copy(
    snapshots.cast<Map<String, Object?>>().singleWhere(
      (snapshot) => snapshot['id'] == 'calls',
    ),
  );
  wanted.remove('id');
  wanted.remove('fixture');
  final records = (wanted['records']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .where(
        (record) =>
            record['kind'] != 'staged_artifact' &&
            record['kind'] != 'generated_artifact',
      )
      .toList();
  final retainedIds = records.map((record) => record['id']).toSet();
  wanted['records'] = records;
  wanted['relations'] = (wanted['relations']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .where(
        (relation) =>
            retainedIds.contains(relation['from_id']) &&
            retainedIds.contains(relation['to_id']),
      )
      .toList();
  return wanted;
}

void _expectPlainProjection(Object? value) {
  const forbiddenKeys = {
    'host_path',
    'file_path',
    'source_text',
    'source_bytes',
    'ast',
    'action_ir',
    'descriptor',
    'compiled_regex',
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
