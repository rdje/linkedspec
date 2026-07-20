import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

final Map<String, Object?> _cursorContract = _loadJson(
  '../capability_conformance/rule_local_cursor_contract.json',
);
final Map<String, Object?> _descriptorContract = _loadJson(
  '../capability_conformance/outward_descriptor_contract.json',
);

void main() {
  test('projects descriptor v1 for every family and reconstructed state', () {
    final cursorDescriptor = _object(_cursorContract['descriptor_contract']);
    final outwardVariants = _object(
      _descriptorContract['meta_contract_variants'],
    );
    final outwardCursorVariant = _object(
      outwardVariants['rule_local_cursor_v1'],
    );
    final legacyVariant = _object(outwardVariants['legacy_global_v0']);
    final expectedMetaKeys =
        {..._strings(_descriptorContract['required_meta_keys'])}
          ..removeAll(_strings(legacyVariant['required_keys']))
          ..addAll(_strings(outwardCursorVariant['required_keys']))
          ..addAll({'entry_rule_contract', 'regex_slot_identity_contract'});

    for (final row in _rows('family_cases')) {
      final id = row['id']! as String;
      final header = row['header']! as String;
      final source = header.startsWith('Top::')
          ? '$header\n /x/\n'
          : 'Root::\n /root/\n\n$header\n /x/\n';
      final parsed = parseSpec(source);
      final reconstructed = _roundtrip(parsed);
      final direct = compileSpec(parsed).toDescriptorJson();
      final rebuilt = compileSpec(reconstructed).toDescriptorJson();

      expect(rebuilt, direct, reason: '$id normalized JSON identity');
      expect(
        direct.keys.toSet(),
        _strings(_descriptorContract['top_level_keys']).toSet(),
        reason: '$id outward keys',
      );

      final rootMeta = _object(direct['meta']);
      expect(rootMeta.keys.toSet(), expectedMetaKeys, reason: '$id meta keys');
      expect(
        rootMeta['cursor_contract'],
        cursorDescriptor['meta'] is Map
            ? _object(cursorDescriptor['meta'])['cursor_contract']
            : outwardCursorVariant['cursor_contract'],
        reason: id,
      );
      expect(
        rootMeta['entry_rule_contract'],
        linkedSpecRootRuleSelectionContract,
        reason: '$id root selection contract',
      );
      expect(
        rootMeta['regex_slot_identity_contract'],
        linkedSpecRegexSlotIdentityContract,
        reason: '$id regex-slot identity contract',
      );
      for (final field in _strings(outwardCursorVariant['forbidden_keys'])) {
        expect(rootMeta, isNot(contains(field)), reason: '$id root $field');
      }

      final topRule = parsed.rules.singleWhere(
        (rule) => rule.header.label == 'Top',
      );
      final ruleDescriptor = _object(_object(direct['spec'])['Top']);
      final handler = _object(ruleDescriptor['handler']);
      final ruleMeta = _object(ruleDescriptor['meta']);
      expect(handler['label'], 'Top', reason: '$id handler identity');
      expect(ruleMeta['label'], 'Top', reason: '$id rule identity');
      expect(ruleMeta['line'], topRule.header.line, reason: '$id source line');
      expect(
        ruleMeta['is_top'],
        topRule.header.isTop,
        reason: '$id top marker',
      );
      expect(ruleMeta['family'], row['family'], reason: id);
      expect(ruleMeta['cursor_policy'], row['cursor_policy'], reason: id);
      expect(ruleMeta, isNot(contains('parse_mode')), reason: id);
      expect(_object(ruleMeta['mode'])['is_and'], row['family'] == 'and');
    }
  });

  test('projects every valid normalized edge in deterministic order', () {
    final descriptorContract = _object(_cursorContract['descriptor_contract']);
    final semanticFields = _strings(
      descriptorContract['resolved_edge_fields'],
    ).toSet();

    for (final row in _rows('edge_resolution_cases')) {
      final expectedValue = row['expected'];
      if (expectedValue is! Map || expectedValue['kind'] != 'edge') {
        continue;
      }
      final id = row['id']! as String;
      final expected = _object(expectedValue);
      final source = _edgeSource(row['parent_family']! as String, [
        row['source']! as String,
      ], _strings(row['declared_rules']));
      final parsed = parseSpec(source);
      final direct = compileSpec(parsed).toDescriptorJson();
      final rebuilt = compileSpec(_roundtrip(parsed)).toDescriptorJson();
      expect(rebuilt, direct, reason: '$id normalized JSON identity');

      final meta = _object(_object(_object(direct['spec'])['Top'])['meta']);
      final rows = _objects(meta['resolved_edges']);
      final expectedTargets = _objects(expected['targets']);
      expect(meta['edge_ownership'], expected['ownership'], reason: id);
      expect(rows, hasLength(expectedTargets.length), reason: id);

      for (var index = 0; index < rows.length; index += 1) {
        final actual = rows[index];
        final target = expectedTargets[index];
        expect(actual.keys.toSet(), semanticFields, reason: '$id fields');
        expect(actual['ownership'], expected['ownership'], reason: id);
        expect(actual['target'], target['label'], reason: id);
        expect(
          actual['regex_index'],
          expected['ownership'] == 'action' ? target['index'] ?? 0 : null,
          reason: id,
        );
        expect(actual['block'], expected['has_block'], reason: id);
        expect(actual['fluent'], target['fluent'], reason: id);
        expect(actual, isNot(contains('source_form')), reason: id);
      }
    }
  });

  test('loaded descriptor and live execution spend the same family state', () {
    const source = '''
Top::AND
 /x/
 -> Top { return("hit") }
''';
    final direct = compileSpec(parseSpec(source));
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-cursor-descriptor-',
    );
    try {
      final specFile = File('${scratch.path}/descriptor.spec')
        ..writeAsStringSync(source);
      final loaded = loadAndCompileSpec(
        SpecRequest.path(specFile.path),
        SpecLoadOptions(cwd: scratch),
      );

      expect(loaded.compiled.toDescriptorJson(), direct.toDescriptorJson());
      final descriptor = loaded.compiled.toDescriptorJson();
      final ruleMeta = _object(
        _object(_object(descriptor['spec'])['Top'])['meta'],
      );
      expect(ruleMeta['family'], 'and');
      expect(ruleMeta['cursor_policy'], 'consume');
      expect(loaded.createEngine().parse('prefix x').value, isNull);
      expect(loaded.createEngine().parse('x').value, 'hit');
    } finally {
      scratch.deleteSync(recursive: true);
    }
    expect(scratch.existsSync(), isFalse);
  });

  test('reconstructed invalid state keeps every portable edge failure', () {
    final diagnostics = {
      for (final row in _rows('diagnostics')) row['code']! as String: row,
    };
    final invalidRows = [
      ..._rows(
        'edge_resolution_cases',
      ).where((row) => row['expected_error'] is String),
      ..._rows(
        'rule_edge_set_cases',
      ).where((row) => row['expected_error'] is String),
    ];

    for (final row in invalidRows) {
      final id = row['id']! as String;
      final expectedCode = row['expected_error']! as String;
      final sources = row['sources'] == null
          ? [row['source']! as String]
          : _strings(row['sources']);
      final source = _edgeSource(
        row['parent_family']! as String,
        sources,
        _strings(row['declared_rules']),
      );
      final diagnostic = _descriptorFailure(_roundtrip(parseSpec(source)));
      final contractDiagnostic = diagnostics[expectedCode]!;

      expect(diagnostic.code, expectedCode, reason: id);
      expect(diagnostic.stage, contractDiagnostic['stage'], reason: id);
      expect(
        diagnostic.fields.keys.toSet(),
        _strings(contractDiagnostic['fields']).toSet(),
        reason: '$id fields',
      );
    }
  });
}

Map<String, Object?> _loadJson(String path) {
  return _object(jsonDecode(File(path).readAsStringSync()));
}

List<Map<String, Object?>> _rows(String name) {
  return _objects(_cursorContract[name]);
}

List<Map<String, Object?>> _objects(Object? value) {
  return (value! as List).map((item) => _object(item)).toList(growable: false);
}

List<String> _strings(Object? value) {
  return (value! as List).cast<String>();
}

Map<String, Object?> _object(Object? value) {
  return Map<String, Object?>.from(value! as Map);
}

SpecFile _roundtrip(SpecFile spec) {
  return SpecFile.fromJson(_object(jsonDecode(jsonEncode(spec.toJson()))));
}

String _edgeSource(
  String parentFamily,
  List<String> sources,
  List<String> declaredRules,
) {
  final buffer = StringBuffer(parentFamily == 'and' ? 'Top::AND\n' : 'Top::\n');
  for (final source in sources) {
    buffer.writeln(' $source');
  }
  for (final label in declaredRules) {
    buffer.write('\n$label:\n /x/ /y/\n');
  }
  return buffer.toString();
}

SpecPortableDiagnostic _descriptorFailure(SpecFile spec) {
  try {
    compileSpec(spec).toDescriptorJson();
  } on SpecValidationException catch (error) {
    final diagnostic = error.diagnostic;
    if (diagnostic == null) {
      fail('expected portable diagnostic, got: ${error.message}');
    }
    return diagnostic;
  }
  fail('expected descriptor construction to fail');
}
