import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

final Map<String, Object?> _contract =
    jsonDecode(
          File(
            '../capability_conformance/rule_local_cursor_contract.json',
          ).readAsStringSync(),
        )
        as Map<String, Object?>;

void main() {
  test('classifies all contract families by exact authored identity', () {
    for (final row in _rows('family_cases')) {
      final id = row['id']! as String;
      final source = '${row['header']}\n /x/\n';
      final parsed = parseSpec(source);
      final expectedAnd = row['family'] == 'and';

      expect(parsed.rules.single.header.mode.isAnd, expectedAnd, reason: id);
      final compiled = compileSpec(parsed, validateSource: false).rule('Top')!;
      expect(compiled.modeMetadata.isAnd, expectedAnd, reason: id);
    }

    expect(RuleMode.pipe.isAnd, isFalse);
    expect(RuleMode.single.isAnd, isTrue);
  });

  test('parses validates and lowers every contract edge exactly', () {
    final diagnosticRows = {
      for (final row in _rows('diagnostics')) row['code']! as String: row,
    };

    for (final row in _rows('edge_resolution_cases')) {
      final id = row['id']! as String;
      final declared = _strings(row['declared_rules']);
      final source = _edgeSource(row['parent_family']! as String, [
        row['source']! as String,
      ], declared);
      final expectedError = row['expected_error'];

      if (expectedError is String) {
        final diagnostic = _diagnosticFor(source);
        final contractDiagnostic = diagnosticRows[expectedError]!;
        expect(diagnostic.code, expectedError, reason: id);
        expect(diagnostic.stage, contractDiagnostic['stage'], reason: id);
        expect(
          diagnostic.fields.keys.toSet(),
          _strings(contractDiagnostic['fields']).toSet(),
          reason: '$id diagnostic fields',
        );
        expect(diagnostic.field('rule_label'), 'Top', reason: id);
        if (diagnostic.fields.containsKey('target')) {
          expect(
            diagnostic.field('target'),
            expectedError == 'bare_edge_target_undefined' ? 'Missing' : 'Child',
            reason: id,
          );
        }
        if (diagnostic.fields.containsKey('regex_index')) {
          expect(diagnostic.field('regex_index'), 0, reason: id);
        }
        if (diagnostic.fields.containsKey('targets')) {
          expect(diagnostic.field('targets'), declared, reason: id);
        }

        final roundtrip = SpecPortableDiagnostic.fromJson(
          _jsonObject(jsonDecode(jsonEncode(diagnostic.toJson()))),
        );
        expect(roundtrip.toJson(), diagnostic.toJson(), reason: '$id JSON');
        continue;
      }

      final parsed = parseSpec(source);
      validateSpec(parsed);
      final expected = _jsonObject(row['expected']);
      if (expected['kind'] == 'lifecycle') {
        expect(
          parsed.rules.first.body.first.kind,
          isA<LifecycleMarkerBodyElementKind>(),
          reason: id,
        );
        continue;
      }

      if (expected['source_form'] == 'bare') {
        final kind = parsed.rules.first.body.first.kind;
        expect(kind, isA<BareEdgeBodyElementKind>(), reason: id);
        final bare = kind as BareEdgeBodyElementKind;
        final expectedTargets = _objects(expected['targets']);
        expect(bare.targets, hasLength(expectedTargets.length), reason: id);
        expect(bare.code != null, expected['has_block'], reason: id);
        final expectedFluent = expectedTargets.first['fluent'];
        expect(
          bare.fluentChain.firstOrNull == null
              ? null
              : _fluentText(bare.fluentChain.first),
          expectedFluent,
          reason: id,
        );
        expect(
          parsed.rules.first.body
              .map((element) => element.kind)
              .whereType<RawBodyElementKind>(),
          isEmpty,
          reason: '$id must not fall back to raw syntax',
        );

        final roundtrip = SpecFile.fromJson(
          _jsonObject(jsonDecode(jsonEncode(parsed.toJson()))),
        );
        expect(roundtrip.toJson(), parsed.toJson(), reason: '$id AST JSON');
      }

      final compiled = compileSpec(parsed).rule('Top')!;
      final expectedTargets = _objects(expected['targets']);
      if (expected['ownership'] == 'action') {
        expect(
          compiled.actionEdges,
          hasLength(expectedTargets.length),
          reason: id,
        );
        expect(compiled.blindEdges, isEmpty, reason: id);
        for (var index = 0; index < expectedTargets.length; index += 1) {
          final actual = compiled.actionEdges[index].targets.single;
          final target = expectedTargets[index];
          expect(actual.label, target['label'], reason: id);
          expect(actual.index, target['index'] ?? 0, reason: id);
        }
      } else {
        expect(
          compiled.blindEdges,
          hasLength(expectedTargets.length),
          reason: id,
        );
        expect(compiled.actionEdges, isEmpty, reason: id);
        for (var index = 0; index < expectedTargets.length; index += 1) {
          expect(
            compiled.blindEdges[index].target.label,
            expectedTargets[index]['label'],
            reason: id,
          );
        }
      }
    }
  });

  test('validates normalized ownership for all contract edge sets', () {
    for (final row in _rows('rule_edge_set_cases')) {
      final id = row['id']! as String;
      final source = _edgeSource(
        row['parent_family']! as String,
        _strings(row['sources']),
        _strings(row['declared_rules']),
      );
      final expectedError = row['expected_error'];
      if (expectedError is String) {
        final diagnostic = _diagnosticFor(source);
        expect(diagnostic.code, expectedError, reason: id);
        expect(diagnostic.stage, 'validate_rule', reason: id);
        expect(diagnostic.fields.keys.toSet(), {
          'ownerships',
          'rule_label',
        }, reason: id);
        expect(diagnostic.field('ownerships'), ['action', 'blind'], reason: id);
        continue;
      }

      final compiled = compileSpec(parseSpec(source)).rule('Top')!;
      if (row['expected_ownership'] == 'action') {
        expect(compiled.actionEdges, isNotEmpty, reason: id);
        expect(compiled.blindEdges, isEmpty, reason: id);
      } else {
        expect(compiled.blindEdges, isNotEmpty, reason: id);
        expect(compiled.actionEdges, isEmpty, reason: id);
      }
    }
  });

  test('retains only complete-line and header-rest bare candidates', () {
    for (final source in [
      'Top::\n Child\n\nChild:\n /x/\n',
      'Top:: Child\n\nChild:\n /x/\n',
      'Top::AND\n Child {\n  return(child_result)\n }\n\nChild:\n /x/\n',
    ]) {
      final parsed = parseSpec(source);
      expect(
        parsed.rules.first.body.first.kind,
        isA<BareEdgeBodyElementKind>(),
      );
      expect(
        parsed.rules.first.body
            .map((element) => element.kind)
            .whereType<RawBodyElementKind>(),
        isEmpty,
      );
    }

    final suffix = parseSpec('Top:: /x/ Child\n\nChild:\n /x/\n');
    expect(
      suffix.rules.first.body
          .map((element) => element.kind)
          .whereType<BareEdgeBodyElementKind>(),
      isEmpty,
      reason: 'bare recognition is physical-line scoped',
    );
  });

  test(
    'keeps runtime-family and generated-v1 boundaries explicitly staged',
    () {
      final pipe = compileSpec(parseSpec('Top::|\n /x/\n')).rule('Top')!;
      expect(pipe.modeMetadata.isAnd, isFalse);
      expect(pipe.modeMetadata.usesLegacyAndInterpretation, isTrue);
      expect(
        classifyGeneratedRuleFamily(pipe),
        GeneratedRuleFamily.andSingleAcode,
        reason: 'generated-source v1 migration is owned by .9.1.5.4',
      );
    },
  );
}

List<Map<String, Object?>> _rows(String name) {
  return _objects(_contract[name]);
}

List<Map<String, Object?>> _objects(Object? value) {
  return (value! as List)
      .map((item) => Map<String, Object?>.from(item! as Map))
      .toList(growable: false);
}

List<String> _strings(Object? value) {
  return (value! as List).cast<String>();
}

Map<String, Object?> _jsonObject(Object? value) {
  return Map<String, Object?>.from(value! as Map);
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

SpecPortableDiagnostic _diagnosticFor(String source) {
  try {
    validateSpec(parseSpec(source));
  } on SpecValidationException catch (error) {
    final diagnostic = error.diagnostic;
    if (diagnostic == null) {
      fail('expected portable diagnostic, got: ${error.message}');
    }
    return diagnostic;
  }
  fail('expected spec validation to fail');
}

String _fluentText(FluentCall call) {
  return call.args.isEmpty ? call.method : '${call.method}(${call.args})';
}
