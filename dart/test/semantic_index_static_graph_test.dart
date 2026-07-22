// FUTURE-PARITY-BACKLOG.10.5.2.1-.2 — exact Dart static projection.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/src/semantic/semantic_index.dart';
import 'package:test/test.dart';

void main() {
  test('compiled graph projection deep-equals the neutral oracle', () {
    expect(
      _materializeSources(_projection('graph', SemanticSourceDetail.text)),
      _materializeSources(_expected('graph')),
    );
  });

  test('Unicode privacy projections are exact at both ceilings', () {
    for (final (id, ceiling) in [
      ('privacy', SemanticSourceDetail.text),
      ('privacy_limited', SemanticSourceDetail.identity),
    ]) {
      expect(
        _materializeSources(_projection('privacy', ceiling)),
        _materializeSources(_expected(id)),
        reason: id,
      );
    }
  });

  test('failed projection normalizes diagnostic and explanation exactly', () {
    final index = _index('failed', SemanticSourceDetail.span);
    expect(index.compilationDiagnostic?.code, 'bare_edge_target_undefined');
    expect(index.compilationDiagnostic?.stage, 'normalize_edges');
    expect(
      _materializeSources(index.semanticStaticProjectionForTesting()),
      _materializeSources(_expected('failed')),
    );
  });

  test('runtime fixture projects only its static half before observation', () {
    final actual = _materializeSources(
      _projection('runtime', SemanticSourceDetail.text),
    );
    final wanted = _expected('runtime');
    final records = (wanted['records']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .where(
          (record) =>
              record['kind'] != 'execution' && record['kind'] != 'event',
        )
        .toList();
    final retainedIds = records.map((record) => record['id']).toSet();
    final relations = (wanted['relations']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .where(
          (relation) =>
              retainedIds.contains(relation['from_id']) &&
              retainedIds.contains(relation['to_id']),
        )
        .toList();
    wanted['records'] = records;
    wanted['relations'] = relations;
    (wanted['snapshot']! as Map<String, Object?>)['has_execution'] = false;

    expect(actual, _materializeSources(wanted));
    expect(
      (actual['records']! as List<Object?>).cast<Map<String, Object?>>().where(
        (record) => record['kind'] == 'execution' || record['kind'] == 'event',
      ),
      isEmpty,
    );
  });

  test(
    'private projection is detached and omitted from the public umbrella',
    () {
      final index = SemanticIndex.fromSource(
        'Top::\n /x/\n',
        options: const SemanticIndexOptions(
          logicalName: 'detached.spec',
          sourceDetailCeiling: SemanticSourceDetail.text,
        ),
      );
      final first = index.semanticStaticProjectionForTesting();
      final records = first['records']! as List<Object?>;
      final spec = records.first as Map<String, Object?>;
      final facts = spec['facts']! as Map<String, Object?>;
      (facts['definition_order']! as List<Object?>)[0] = 'rule:Injected';
      final second = index.semanticStaticProjectionForTesting();
      final secondRecords = second['records']! as List<Object?>;
      final secondSpec = secondRecords.first as Map<String, Object?>;
      final secondFacts = secondSpec['facts']! as Map<String, Object?>;
      expect(secondFacts['definition_order'], ['rule:Top']);
      expect(first, isNot(same(second)));
      expect(jsonDecode(jsonEncode(second)), second);
      _expectPlainProjection(second);

      final publicLibrary = File('lib/linkedspec_dart.dart').readAsStringSync();
      expect(
        publicLibrary,
        isNot(contains('SemanticIndexStaticProjectionTestAccess')),
      );
      final implementation = File(
        'lib/src/semantic/semantic_static_projection.dart',
      ).readAsStringSync();
      for (final forbidden in [
        'parsed.toJson()',
        'compiled.toJson()',
        'descriptorState',
        'toDescriptorJson()',
        'LinkedSpecRuntimeEngine',
        'emitDartSource',
        'executeGeneratedParser',
        'LinkedSpecTraceEmitter',
        'RuntimeDiagnosticOutputSink',
        'RuntimeSemanticObservation',
        'Platform.environment',
        'DateTime.now',
        'Random(',
      ]) {
        expect(implementation, isNot(contains(forbidden)), reason: forbidden);
      }
    },
  );

  test(
    'repeated lifecycle markers retain occurrence-specific value shapes',
    () {
      final index = SemanticIndex.fromSource(
        '''Top::
 /x/
 E { return("first") }
 E { return(["second"]) }
''',
        options: const SemanticIndexOptions(
          logicalName: 'repeated-lifecycle.spec',
          sourceDetailCeiling: SemanticSourceDetail.text,
        ),
      );
      final records =
          index.semanticStaticProjectionForTesting()['records']!
              as List<Object?>;
      final lifecycles = records
          .cast<Map<String, Object?>>()
          .where((record) => record['kind'] == 'lifecycle')
          .toList();

      expect(lifecycles.map((record) => record['id']), [
        'lifecycle:rule:Top:E:0',
        'lifecycle:rule:Top:E:1',
      ]);
      expect(
        lifecycles.map(
          (record) =>
              ((record['facts']! as Map<String, Object?>)['value_shape']!
                  as Map<String, Object?>)['kind'],
        ),
        ['string', 'array'],
      );
    },
  );
}

final Map<String, Object?> _model =
    jsonDecode(
          File(
            '../capability_conformance/semantic_introspection_model.json',
          ).readAsStringSync(),
        )!
        as Map<String, Object?>;

SemanticIndex _index(String fixture, SemanticSourceDetail ceiling) =>
    SemanticIndex.fromUtf8(
      File(
        '../capability_conformance/semantic_introspection/$fixture.spec',
      ).readAsBytesSync(),
      options: SemanticIndexOptions(
        logicalName: '$fixture.spec',
        sourceDetailCeiling: ceiling,
      ),
    );

Map<String, Object?> _projection(
  String fixture,
  SemanticSourceDetail ceiling,
) => _index(fixture, ceiling).semanticStaticProjectionForTesting();

Map<String, Object?> _expected(String id) {
  final snapshots = _model['snapshots']! as List<Object?>;
  final wanted = _copy(
    snapshots.cast<Map<String, Object?>>().singleWhere(
      (snapshot) => snapshot['id'] == id,
    ),
  );
  wanted.remove('id');
  wanted.remove('fixture');
  return wanted;
}

void _expectPlainProjection(Object? value) {
  const forbiddenKeys = {
    'path',
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
