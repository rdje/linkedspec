// TYPE-REFERENCE-BOOK.1.2.23.3.36.2 — outgoing-edge body candidate ownership.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void check(String source, String input, Object? expected) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  final observations = <String, Object?>{};
  for (final route in <String, Object? Function()>{
    'native': () => LinkedSpecRuntimeEngine(compiled).execute(input).value,
    'restored': () =>
        LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input).value,
    'plan': () => executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      input,
      'active-edge-body.spec',
    ),
  }.entries) {
    try {
      observations[route.key] = route.value();
    } catch (error) {
      observations[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('ACTIVE_EDGE ${jsonEncode(observations)}');
  for (final route in observations.entries) {
    expect(route.value, expected, reason: route.key);
  }
}

String carrier(String head, String action) =>
    'Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>$head)/\n /:/\n /(?<token>cat)/\n -> Value[2] {$action}\n';

void main() {
  test('wildcard entry cannot preempt written body edge', () {
    check(carrier('..', 'return("BODY")'), 'αβ:cat', ['BODY']);
  });
  test('literal carrier keeps its payload', () {
    check(carrier('αβ', 'return("BODY")'), 'αβ:cat', ['BODY']);
  });
  for (final mode in ['', '|']) {
    test('reversed duplicate selectors retain authored edge order $mode', () {
      check(
        'Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:$mode\n /H/\n /a/\n /a/\n -> Value[2] {return(2)}\n -> Value[1] {return(1)}\n',
        'Ha',
        [2],
      );
    });
  }
  test('earliest start precedes authored edge order', () {
    check(
      'Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /H/\n /b/\n /a/\n -> Value[1] {return("B")}\n -> Value[2] {return("A")}\n',
      'Hab',
      ['A'],
    );
  });
  test('cross-target edges exclude parent declarations', () {
    check(
      'Top::\n /./\n -> Second {return("second")}\n -> First {return("first")}\nFirst: /a/\nSecond: /a/\n',
      'a',
      'second',
    );
  });
  test('untargeted match cannot enter selected-first gap hooks', () {
    check(
      'Top::\n /./\n @capture_gaps\n -> Value {return("edge")}\n LS {return("wrong")}\n LX {return("miss")}\nValue: /cat/\n',
      'x',
      'miss',
    );
  });
  test('selected captures and Unicode source positions retain identity', () {
    check(
      carrier(
        '..',
        'mark_match_start(begin);mark_match_end(finish);return([match_text(),match_group(0),match_named(token),mark_pos(begin),mark_pos(finish),entry_named(head)])',
      ),
      'αβ:cat',
      [
        ['cat', 'cat', 'cat', 3, 6, 'αβ'],
      ],
    );
  });
  test('boundary helper keeps untargeted catalog entries', () {
    check(
      'Top:: I {return(capture_until_boundary("Landmark"))}\nLandmark:\n /END/\n /!/\n -> Landmark[1] {return(1)}\n',
      'bodyEND!',
      'body',
    );
  });
  test('gap candidate uses the selected edge span', () {
    final source = carrier(
      '..',
      'return([gap_text(),gap_span(),match_text()])',
    ).replaceFirst(' -> Value[2]', ' @capture_gaps\n -> Value[2]');
    check(source, 'αβ:cat', [
      [
        ':',
        {'source_id': 'input', 'start': 2, 'end': 3, 'provenance': 'gap'},
        'cat',
      ],
    ]);
  });
  test('existing duplicate fixtures retain ordered and repeated results', () {
    final contract =
        jsonDecode(
              File(
                '../capability_conformance/duplicate_regex_slot_identity_contract.json',
              ).readAsStringSync(),
            )
            as Map<String, Object?>;
    for (final row
        in (contract['fixtures'] as List).cast<Map<String, Object?>>()) {
      check(
        row['source']! as String,
        row['input']! as String,
        row['expected_result'],
      );
    }
  });
  test('rule families retain seek and consume policy', () {
    check('Top:: /x/ -> Top {return("hit")}\n', 'prefix x', 'hit');
    check('Top::AND /x/ -> Top {return("hit")}\n', 'prefix x', null);
  });
  test('native and generated traces retain written structural slot', () {
    final compiled = compileSpec(
      parseSpecWithStagedUserFunctionDefinitions(
        carrier('..', 'return("BODY")'),
      ),
    );
    final trace = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.high),
      stdoutWriter: (_) {},
    );
    final native = LinkedSpecRuntimeEngine(
      compiled,
    ).parse('αβ:cat', trace: trace).value;
    final nativeSlots = trace.events
        .where(
          (event) =>
              event.topic == 'dart_runtime:regex_slot_selected' &&
              event.details.contains('rule_label=Value '),
        )
        .map((event) => event.details)
        .toList();
    final generatedTrace = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.high),
      stdoutWriter: (_) {},
    );
    final plan = buildGeneratedRulePlan(compiled);
    validateGeneratedRulePlanV2(compiled, plan, 'active-edge-body.spec');
    final generated = LinkedSpecRuntimeEngine(compiled)
        .executeGeneratedWithPlan(
          'αβ:cat',
          {
            for (final row in plan)
              row.label: GeneratedRuleFamily.fromWireName(row.family)!,
          },
          'active-edge-body.spec',
          trace: generatedTrace,
        )
        .value;
    final generatedSlots = generatedTrace.events
        .where(
          (event) =>
              event.topic == 'dart_runtime:regex_slot_selected' &&
              event.details.contains('rule_label=Value '),
        )
        .map((event) => event.details)
        .toList();
    print(
      'ACTIVE_EDGE_TRACE ${jsonEncode({'native': native, 'plan': generated, 'native_slots': nativeSlots, 'plan_slots': generatedSlots})}',
    );
    expect(native, ['BODY']);
    expect(generated, ['BODY']);
    for (final selected in [nativeSlots, generatedSlots]) {
      expect(selected, hasLength(1));
      expect(selected.single, contains('target_rule=Value regex_index=2'));
    }
  });
}
