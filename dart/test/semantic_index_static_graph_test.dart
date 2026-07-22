// FUTURE-PARITY-BACKLOG.10.5.2.1 — exact Dart static graph projection.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/src/semantic/semantic_index.dart';
import 'package:test/test.dart';

void main() {
  test('compiled graph projection deep-equals the neutral oracle', () {
    final index = SemanticIndex.fromUtf8(
      File(
        '../capability_conformance/semantic_introspection/graph.spec',
      ).readAsBytesSync(),
      options: const SemanticIndexOptions(
        logicalName: 'graph.spec',
        sourceDetailCeiling: SemanticSourceDetail.text,
      ),
    );
    final actual = _materializeSources(
      index.semanticStaticProjectionForTesting(),
    );
    final model =
        jsonDecode(
              File(
                '../capability_conformance/semantic_introspection_model.json',
              ).readAsStringSync(),
            )!
            as Map<String, Object?>;
    final snapshots = model['snapshots']! as List<Object?>;
    final wanted = _copy(
      snapshots.cast<Map<String, Object?>>().singleWhere(
        (snapshot) => snapshot['id'] == 'graph',
      ),
    );
    wanted.remove('id');
    wanted.remove('fixture');
    expect(actual, _materializeSources(wanted));
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
