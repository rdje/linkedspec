// INTER-MATCH-GAP-CAPTURE.4.3 — dormant Dart generated-carrier stage.
//
// This final consumer path now proves authored/static metadata plus native gap
// state, lifecycle, entry identity, rollback, recursion, ordinary normalized
// reconstruction, compatible descriptors, and generated-plan execution.
// Emitted source, primary routing, and admission remain owned by `.4.4-.4.5`.

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

RuntimeParseResult executeNative(String source, String input) {
  return LinkedSpecRuntimeEngine(compileMetadata(source)).parse(input);
}

RuntimeInterpreterException nativeError(String source, String input) {
  try {
    executeNative(source, input);
  } on RuntimeInterpreterException catch (error) {
    return error;
  }
  throw StateError('fixture must fail at private native runtime execution');
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

  test('private native gap state lifecycle and rollback stage', () {
    expect(
      executeNative('''
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[head] { push(gaps, array(gap_kind(), gap_text())) }
 LX { push(gaps, array(gap_kind(), gap_text())); return(copy(gaps)) }
Part:
 head=/H/
 I.return(entry_text())
''', 'αHω').value,
      [
        ['prefix', 'α'],
        ['tail', 'ω'],
      ],
    );

    expect(
      executeNative('''
Top::
 @capture_gaps
 -> Part { return("unexpected") }
 LS { return(array(gap_kind(), gap_text(), match_text())) }
Part: /H/
''', 'αH').value,
      ['prefix', 'α', 'H'],
      reason: 'capture-enabled selection and local match precede LS',
    );

    expect(
      executeNative('''
Top::
 I { segments = [] }
 @capture_gaps
 -> Part[header]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[section] { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[footer]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 LX { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span())); return(copy(segments)) }
Part:
 header=/H/
 section=/S/
 footer=/F/
 I { return(hash("slot", entry_slot(), "text", entry_text(), "falsey", 0)) }
''', 'αHβ\nS🙂Fω').value,
      [
        {
          'kind': 'prefix',
          'text': 'α',
          'span': {
            'source_id': 'input',
            'start': 0,
            'end': 1,
            'provenance': 'gap',
          },
          'child': {
            'slot': {
              'target_rule': 'Part',
              'regex_index': 0,
              'slot_id': 'header',
              'selector_kind': 'named',
              'authored_selector': 'header',
            },
            'text': 'H',
            'falsey': 0,
          },
        },
        {
          'kind': 'interstitial',
          'text': 'β\n',
          'span': {
            'source_id': 'input',
            'start': 2,
            'end': 4,
            'provenance': 'gap',
          },
          'child': {
            'slot': {
              'target_rule': 'Part',
              'regex_index': 1,
              'slot_id': 'section',
              'selector_kind': 'named',
              'authored_selector': 'section',
            },
            'text': 'S',
            'falsey': 0,
          },
        },
        {
          'kind': 'interstitial',
          'text': '🙂',
          'span': {
            'source_id': 'input',
            'start': 5,
            'end': 6,
            'provenance': 'gap',
          },
          'child': {
            'slot': {
              'target_rule': 'Part',
              'regex_index': 2,
              'slot_id': 'footer',
              'selector_kind': 'named',
              'authored_selector': 'footer',
            },
            'text': 'F',
            'falsey': 0,
          },
        },
        {
          'kind': 'tail',
          'text': 'ω',
          'span': {
            'source_id': 'input',
            'start': 7,
            'end': 8,
            'provenance': 'gap',
          },
        },
      ],
      reason: 'Unicode spans, falsey values, and named entry slots are exact',
    );

    expect(
      executeNative('''
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[s] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[f] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 LX { push(gaps, array(gap_kind(), gap_text(), gap_span())); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 f=/F/
 I.return(entry_text())
''', 'HSF').value,
      [
        [
          'prefix',
          '',
          {'source_id': 'input', 'start': 0, 'end': 0, 'provenance': 'gap'},
        ],
        [
          'interstitial',
          '',
          {'source_id': 'input', 'start': 1, 'end': 1, 'provenance': 'gap'},
        ],
        [
          'interstitial',
          '',
          {'source_id': 'input', 'start': 2, 'end': 2, 'provenance': 'gap'},
        ],
        [
          'tail',
          '',
          {'source_id': 'input', 'start': 3, 'end': 3, 'provenance': 'gap'},
        ],
      ],
    );

    expect(
      executeNative('''
Top::
 I { gaps = [] }
 @capture_gaps
 -> Container[open] { push(gaps, array(gap_text(), call(Container))) }
 -> Bang { push(gaps, array(gap_text(), call(Bang))) }
 LX { push(gaps, array(gap_text(), gap_kind())); return(copy(gaps)) }
Container:
 open=/\\{/
 -> Close { return(call(Close)) }
Close:
 /\\}/
 I.return(entry_text())
Bang:
 /!/
 I.return(entry_text())
''', 'p{abc}gap!').value,
      [
        ['p', '}'],
        ['gap', '!'],
        ['', 'tail'],
      ],
      reason: 'the accepted child exit cursor becomes the next boundary',
    );

    expect(
      executeNative('''
Top::
 @capture_gaps
 -> Container[open] { return(array(gap_text(), call(Container), gap_text())) }
Container:
 open=/\\{/
 I { inner = [] }
 @capture_gaps
 -> Atom { push(inner, gap_text()) }
 LX { push(inner, gap_text()); return(copy(inner)) }
Atom:
 /x/
 I.return(entry_text())
''', 'p{axtail').value,
      [
        'p',
        ['a', 'tail'],
        'p',
      ],
      reason: 'nested gap owners hide and restore the parent candidate',
    );

    expect(
      executeNative('''
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] {
  tx = recognition_checkpoint();
  matched = recognize_once(tx, call(Probe));
  recognition_rollback(tx);
  push(gaps, gap_text())
 }
 -> Part[s] { push(gaps, gap_text()) }
 LX { push(gaps, gap_text()); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 I.return(entry_text())
Probe:
 /X/
 I.return(0)
''', 'aHXbS').value,
      ['a', 'Xb', ''],
      reason: 'rollback restores the invocation gap snapshot and cursor',
    );

    final terminalCases = <(String, String, Object?)>[
      (
        '''
Top::
 @capture_gaps
 -> Part { return(gap_text()) }
 LX { return(array(gap_kind(), gap_text(), gap_span())) }
Part: /H/
''',
        'abc',
        [
          'tail',
          'abc',
          {'source_id': 'input', 'start': 0, 'end': 3, 'provenance': 'gap'},
        ],
      ),
      (
        '''
Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
''',
        'aHtail',
        ['a', 'tail'],
      ),
      (
        '''
Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
''',
        'whole',
        ['whole'],
      ),
      (
        '''
Top::OR{1}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 E { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
''',
        'aHtail',
        ['a', 'tail'],
      ),
    ];
    for (final fixture in terminalCases) {
      expect(executeNative(fixture.$1, fixture.$2).value, fixture.$3);
    }

    final unavailable = nativeError(
      'Direct::\n /H/\n I { return(gap_text()) }\n',
      'H',
    );
    expect(
      unavailable.message,
      'LINKEDSPEC_INTER_MATCH_GAP_ERROR:gap_capture_context_unavailable',
    );
    expect(unavailable.diagnostic?.code, 'gap_capture_context_unavailable');
    expect(unavailable.diagnostic?.stage, 'access_gap_context');

    final postCommit = nativeError(
      'Top::OR{1}\n @capture_gaps\n -> Part { return(0) }\n IT { return(gap_kind()) }\nPart: /H/\n',
      'H',
    );
    expect(postCommit.diagnostic?.code, 'gap_capture_context_unavailable');

    final regression = nativeError(
      'Top::OR{1}\n @capture_gaps\n -> Part { rewind_match_start() }\nPart: /H/\n',
      'aH',
    );
    expect(
      regression.message,
      'LINKEDSPEC_SOURCE_LOCATION_ERROR:source_location_cursor_regression',
    );
    expect(regression.diagnostic?.code, 'source_location_cursor_regression');
    expect(regression.diagnostic?.stage, 'advance_gap_context');

    expect(
      executeNative(
        'Top::OR{2}\n @capture_gaps\n -> Part { return(gap_text()) }\n EX { return("unexpected-ex") }\n E { return("unexpected-e") }\nPart: /H/\n',
        'H',
      ).value,
      isNull,
      reason: 'failed minimum exposes no tail or terminal hooks',
    );
    expect(
      executeNative('Part::\n /H/\n I { return(entry_slot()) }\n', 'H').value,
      isNull,
      reason: 'direct entry has no action-edge slot identity',
    );
    expect(
      executeNative('Top::\n /H/\n E { return("legacy") }\n', 'H').value,
      'legacy',
      reason: 'unflagged lifecycle behavior remains unchanged',
    );
  });

  test('ordinary reconstruction descriptor and generated plan stage', () {
    const source = '''
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[head] { push(gaps, array(gap_kind(), gap_text())) }
 LX { push(gaps, array(gap_kind(), gap_text())); return(copy(gaps)) }
Part:
 head=/H/
 I.return(entry_text())
''';
    const sourceIdentity = 'dart-gap-carrier.spec';
    const expected = <Object?>[
      <Object?>['prefix', 'α'],
      <Object?>['tail', 'ω'],
    ];

    final authored = parseSpec(source, sourceId: sourceIdentity);
    final encoded = jsonEncode(authored.toJson());
    final reconstructed = SpecFile.fromJson(
      (jsonDecode(encoded)! as Map).cast<String, Object?>(),
    );
    expect(reconstructed.toJson(), authored.toJson());
    final compiled = compileSpec(reconstructed);
    expect(LinkedSpecRuntimeEngine(compiled).parse('αHω').value, expected);

    final descriptor = compiled.toDescriptorJson();
    final descriptorSpec = descriptor['spec']! as Map<String, Object?>;
    final topMeta =
        (descriptorSpec['Top']! as JsonObject)['meta']! as JsonObject;
    final partMeta =
        (descriptorSpec['Part']! as JsonObject)['meta']! as JsonObject;
    expect(partMeta['regex_slots'], [
      {
        'regex_index': 0,
        'slot_id': 'head',
        'source_id': sourceIdentity,
        'line': 7,
      },
    ]);
    expect(topMeta['capture_gaps'], {
      'enabled': true,
      'directive': '@capture_gaps',
      'source_id': sourceIdentity,
      'line': 3,
    });
    expect(topMeta['resolved_slot_edges'], [
      {
        'selector_kind': 'named',
        'authored_selector': 'head',
        'target_rule': 'Part',
        'regex_index': 0,
        'target_slot_id': 'head',
      },
    ]);
    expect(topMeta['resolved_edges'], [
      {
        'ownership': 'action',
        'target': 'Part',
        'regex_index': 0,
        'block': true,
        'fluent': null,
      },
    ]);
    expect((descriptorSpec['Top']! as JsonObject)['dependency_refs'], [
      {'label': 'Part', 'idx': 0},
    ]);

    final plan = buildGeneratedRulePlan(compiled);
    expect(plan.map((row) => row.toJson()), [
      {'label': 'Top', 'family': 'default'},
      {'label': 'Part', 'family': 'default'},
    ]);
    expect(
      executeGeneratedParserV2(compiled, plan, 'αHω', sourceIdentity),
      expected,
    );
    expect(
      executeGeneratedParserWithTraceV2(
        compiled,
        plan,
        'αHω',
        LinkedSpecTraceConfig.disabled(),
        sourceIdentity,
      ),
      expected,
    );

    for (final traced in [false, true]) {
      final unavailable = compileMetadata(
        'Direct::\n /H/\n I { return(gap_text()) }\n',
      );
      final unavailablePlan = buildGeneratedRulePlan(unavailable);
      expect(
        () => traced
            ? executeGeneratedParserWithTraceV2(
                unavailable,
                unavailablePlan,
                'H',
                LinkedSpecTraceConfig.disabled(),
                sourceIdentity,
              )
            : executeGeneratedParserV2(
                unavailable,
                unavailablePlan,
                'H',
                sourceIdentity,
              ),
        throwsA(
          isA<GeneratedSourceException>()
              .having(
                (error) => error.code.wireName,
                'portable code',
                'generated_execution_failed',
              )
              .having(
                (error) => error.detail,
                'typed detail',
                contains(
                  'LINKEDSPEC_INTER_MATCH_GAP_ERROR:'
                  'gap_capture_context_unavailable',
                ),
              ),
        ),
        reason: traced
            ? 'traced unavailable context'
            : 'direct unavailable context',
      );

      final regression = compileMetadata(
        'Top::OR{1}\n @capture_gaps\n -> Part { rewind_match_start() }\nPart: /H/\n',
      );
      final regressionPlan = buildGeneratedRulePlan(regression);
      expect(
        () => traced
            ? executeGeneratedParserWithTraceV2(
                regression,
                regressionPlan,
                'aH',
                LinkedSpecTraceConfig.disabled(),
                sourceIdentity,
              )
            : executeGeneratedParserV2(
                regression,
                regressionPlan,
                'aH',
                sourceIdentity,
              ),
        throwsA(
          isA<GeneratedSourceException>().having(
            (error) => error.detail,
            'typed detail',
            contains(
              'LINKEDSPEC_SOURCE_LOCATION_ERROR:'
              'source_location_cursor_regression',
            ),
          ),
        ),
        reason: traced
            ? 'traced cursor regression'
            : 'direct cursor regression',
      );
    }
  });
}
