// INTER-MATCH-GAP-CAPTURE.4.1 — dormant Dart authored/static metadata stage.
//
// This final consumer path deliberately proves only parsing, validation,
// compiled provenance, and ordinary/staged/loaded source identity in this
// leaf. Native gap state, reconstruction/descriptor/generated projection,
// emitted source, primary routing, and admission remain owned by `.4.2-.4.5`.

@Skip('INTER-MATCH-GAP-CAPTURE.4.5 owns Dart runtime admission')
library;

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

typedef JsonObject = Map<String, Object?>;

final JsonObject contract =
    jsonDecode(
          File(
            '../capability_conformance/inter_match_gap_capture_contract.json',
          ).readAsStringSync(),
        )
        as JsonObject;

const contractId = 'linkedspec-inter-match-gap-capture-v1';

CompiledSpec compileMetadata(String source, {String sourceId = 'inline'}) {
  final parsed = parseSpec(source, sourceId: sourceId);
  validateSpec(parsed);
  return compileSpec(parsed, validateSource: false);
}

SpecPortableDiagnostic diagnostic(String source, {String sourceId = 'inline'}) {
  try {
    compileMetadata(source, sourceId: sourceId);
  } on SpecValidationException catch (error) {
    return error.diagnostic ??
        (throw StateError('expected portable diagnostic, got $error'));
  }
  throw StateError('fixture must be rejected statically');
}

JsonObject compiledRule(CompiledSpec compiled, String label) {
  final rules = compiled.toJson()['rules_by_label']! as Map<String, Object?>;
  return rules[label]! as JsonObject;
}

void main() {
  test('authored static compiled metadata stage', () {
    expect(contract['contract_id'], contractId);
    expect(contract['format'], 1);
    final rollout = (contract['rollout']! as List).cast<JsonObject>();
    expect(rollout[3], {
      'id': 'dart_runtime',
      'owner': 'INTER-MATCH-GAP-CAPTURE.4',
      'status': 'pending',
    });

    const source = '''
Top::OR
 @capture_gaps
 -> Part[head] { return("named") }
 -> Part[0] { return("numeric") }
 -> Part { return("unindexed") }
Part:
 head = /H/
 /S/
 foot=/F/
 é́=/U/
''';
    final parsed = parseSpec(source);
    final partRegexRows = parsed.rules[1].body
        .where((row) => row.kind is RegexBodyElementKind)
        .map((row) => row.kind.toJson())
        .toList(growable: false);
    expect(
      partRegexRows.map((row) => row['slot_id']),
      ['head', null, 'foot', 'é́'],
      reason: 'named and anonymous declarations share authored order',
    );
    for (final declaration in [
      'head=/H/',
      'head =/H/',
      'head= /H/',
      'head = /H/',
    ]) {
      final row = parseSpec('Top::\n $declaration\n').rules.single.body.single;
      expect(row.kind.toJson()['slot_id'], 'head', reason: declaration);
      expect(row.kind.toJson()['pattern'], 'H', reason: declaration);
    }

    validateSpec(parsed);
    final compiled = compileSpec(parsed, validateSource: false);
    expect(compiledRule(compiled, 'Part')['regex_slots'], [
      {'regex_index': 0, 'slot_id': 'head', 'source_id': 'inline', 'line': 7},
      {'regex_index': 1, 'slot_id': null, 'source_id': 'inline', 'line': 8},
      {'regex_index': 2, 'slot_id': 'foot', 'source_id': 'inline', 'line': 9},
      {'regex_index': 3, 'slot_id': 'é́', 'source_id': 'inline', 'line': 10},
    ]);
    expect(compiledRule(compiled, 'Top')['capture_gaps'], {
      'enabled': true,
      'directive': '@capture_gaps',
      'source_id': 'inline',
      'line': 2,
    });
    final edges = (compiledRule(compiled, 'Top')['action_edges']! as List)
        .cast<JsonObject>();
    expect(
      [
        for (final edge in edges)
          {
            'selector_kind': edge['selector_kind'],
            'authored_selector': edge['authored_selector'],
            'target_rule': edge['target_rule'],
            'regex_index': edge['child_regex_index'],
            'target_slot_id': edge['target_slot_id'],
          },
      ],
      [
        {
          'selector_kind': 'named',
          'authored_selector': 'head',
          'target_rule': 'Part',
          'regex_index': 0,
          'target_slot_id': 'head',
        },
        {
          'selector_kind': 'numeric',
          'authored_selector': 0,
          'target_rule': 'Part',
          'regex_index': 0,
          'target_slot_id': 'head',
        },
        {
          'selector_kind': 'unindexed',
          'authored_selector': null,
          'target_rule': 'Part',
          'regex_index': 0,
          'target_slot_id': 'head',
        },
      ],
    );

    final reordered = compileMetadata('''
Top::
 -> Part[head] { return("named") }
 -> Part[0] { return("numeric") }
Part:
 other=/H/
 head=/H/
''');
    final reorderedEdges =
        (compiledRule(reordered, 'Top')['action_edges']! as List)
            .cast<JsonObject>();
    expect(
      [
        for (final edge in reorderedEdges)
          {
            'selector_kind': edge['selector_kind'],
            'authored_selector': edge['authored_selector'],
            'regex_index': edge['child_regex_index'],
            'target_slot_id': edge['target_slot_id'],
          },
      ],
      [
        {
          'selector_kind': 'named',
          'authored_selector': 'head',
          'regex_index': 1,
          'target_slot_id': 'head',
        },
        {
          'selector_kind': 'numeric',
          'authored_selector': 0,
          'regex_index': 0,
          'target_slot_id': 'other',
        },
      ],
      reason: 'named identity survives reorder and duplicate regex text',
    );

    for (final header in [
      'Top::',
      'Top::OR',
      'Top::OR+',
      'Top::OR{1,3}',
      'Top:+',
    ]) {
      compileMetadata(
        '$header\n @capture_gaps\n -> Part { return("x") }\nPart: /H/\n',
      );
    }
    compileMetadata('''
Top::
 @capture_gaps
 @mark(gap_control)
 -> Part { return("x") }
Part: /H/
''');
    for (final fixture in <(String, String)>[
      ('Top::\n @capture_gaps\n /H/\n', 'none'),
      ('Top::\n @capture_gaps\n -> Part\n => Part\nPart: /H/\n', 'mixed'),
      (
        'Top::\n @capture_gaps\n /H/ -> Part { return("x") }\nPart: /H/\n',
        'local_adjacency',
      ),
    ]) {
      final result = diagnostic(fixture.$1);
      expect(result.code, 'capture_gaps_rule_ineligible');
      expect(result.field('edge_ownership'), fixture.$2);
    }

    final located = diagnostic(
      'Top::\n -bad=/H/\n',
      sourceId: 'contract-fixture.spec',
    );
    expect(located.field('source_id'), 'contract-fixture.spec');
    expect(located.field('line'), 2);

    final descriptor = compiled.descriptorState.toJson();
    final descriptorSpec = descriptor['spec']! as Map<String, Object?>;
    final topDescriptor = descriptorSpec['Top']! as JsonObject;
    final meta = topDescriptor['meta']! as JsonObject;
    final resolvedEdges = (meta['resolved_edges']! as List).cast<JsonObject>();
    expect(resolvedEdges.first.containsKey('selector_kind'), isFalse);
    expect(topDescriptor['dependency_refs'], [
      {'label': 'Part', 'idx': 0},
      {'label': 'Part', 'idx': 0},
      {'label': 'Part', 'idx': 0},
    ]);

    final ordinary = parseSpec('Top:: /H/\n', sourceId: 'ordinary.spec');
    expect(ordinary.sourceId, 'ordinary.spec');
    final ordinaryRoundTrip = SpecFile.fromJson(ordinary.toJson());
    expect(ordinaryRoundTrip.sourceId, 'ordinary.spec');

    final staged = parseSpecWithStagedUserFunctionDefinitions(
      'Top:: /H/\n',
      sourceId: 'staged.spec',
    );
    expect(staged.sourceId, 'staged.spec');

    final scratchParent = Directory('../.linkedspec-project-data/test')
      ..createSync(recursive: true);
    final scratch = scratchParent.createTempSync('dart-gap-metadata-');
    try {
      File(
        '${scratch.path}${Platform.pathSeparator}loaded.spec',
      ).writeAsStringSync('''
Top::
 @capture_gaps
 -> Part { return("x") }
Part:
 head=/H/
''');
      final loaded = loadAndCompileSpec(
        const SpecRequest.path('loaded.spec'),
        SpecLoadOptions(cwd: scratch),
      );
      expect(compiledRule(loaded.compiled, 'Part')['regex_slots'], [
        {
          'regex_index': 0,
          'slot_id': 'head',
          'source_id': 'loaded.spec',
          'line': 5,
        },
      ]);
      expect(
        (compiledRule(loaded.compiled, 'Top')['capture_gaps']!
            as JsonObject)['source_id'],
        'loaded.spec',
      );
    } finally {
      scratch.deleteSync(recursive: true);
    }

    final roundTrip = SpecFile.fromJson(parsed.toJson());
    expect(roundTrip.toJson(), parsed.toJson());
    final legacyJson = Map<String, Object?>.from(parsed.toJson())
      ..remove('source_id');
    final legacy = SpecFile.fromJson(legacyJson);
    expect(legacy.sourceId, 'inline');

    final cases = <(String, String, String, int, JsonObject)>[
      (
        'Top::\n -bad=/H/\n',
        'regex_slot_name_invalid',
        'parse_declaration',
        2,
        {'slot_name': '-bad'},
      ),
      (
        'Top::\n 123=/H/\n',
        'regex_slot_name_invalid',
        'parse_declaration',
        2,
        {'slot_name': '123'},
      ),
      (
        'Top::\n head=/H/\n head=/S/\n',
        'regex_slot_duplicate_name',
        'resolve_declaration',
        3,
        {'slot_name': 'head', 'first_line': 2},
      ),
      (
        'Top::\n -> Part[missing] { return("x") }\nPart:\n head=/H/\n',
        'regex_slot_unknown_name',
        'resolve_selector',
        2,
        {'target_rule': 'Part', 'authored_selector': 'missing'},
      ),
      (
        'Top::\n -> Part[2] { return("x") }\nPart:\n /H/\n',
        'regex_slot_index_out_of_range',
        'resolve_selector',
        2,
        {'target_rule': 'Part', 'regex_index': 2, 'regex_count': 1},
      ),
      (
        'Top::\n -> Part[head { return("x") }\nPart:\n head=/H/\n',
        'regex_slot_selector_invalid',
        'parse_selector',
        2,
        {'target_rule': 'Part', 'authored_selector': 'head'},
      ),
      (
        'Top::\n @capture_gaps\n @capture_gaps\n -> Part { return("x") }\nPart: /H/\n',
        'capture_gaps_duplicate_directive',
        'parse_directive',
        3,
        {'first_line': 2},
      ),
      (
        'Top::AND\n @capture_gaps\n -> Part { return("x") }\nPart: /H/\n',
        'capture_gaps_rule_ineligible',
        'validate_directive',
        2,
        {
          'family': 'and',
          'cursor_policy': 'consume',
          'edge_ownership': 'action',
          'execution_shape': 'single_match',
        },
      ),
      (
        'Top::\n @capture_gaps\n => Part\nPart: /H/\n',
        'capture_gaps_rule_ineligible',
        'validate_directive',
        2,
        {
          'family': 'or_default',
          'cursor_policy': 'seek',
          'edge_ownership': 'blind',
          'execution_shape': 'default_scan_loop',
        },
      ),
      (
        'Top::\n @capture_gaps\n @move_pos\n -> Part { return("x") }\nPart: /H/\n',
        'capture_gaps_legacy_marker_conflict',
        'validate_directive',
        2,
        {'marker': '@move_pos', 'marker_line': 3},
      ),
    ];
    for (final fixture in cases) {
      final result = diagnostic(fixture.$1);
      expect(result.code, fixture.$2);
      expect(result.stage, fixture.$3);
      expect(result.field('rule_label'), 'Top');
      expect(result.field('source_id'), 'inline');
      expect(result.field('line'), fixture.$4);
      for (final field in fixture.$5.entries) {
        expect(result.field(field.key), field.value, reason: field.key);
      }
    }
  });
}
