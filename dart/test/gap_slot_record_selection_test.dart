// TYPE-REFERENCE-BOOK.1.2.23.3.55.3 — detached gap/slot record reads.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object? Function()> routes(String source, String input) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  return {
    'native': () => LinkedSpecRuntimeEngine(compiled).execute(input).value,
    'restored': () =>
        LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input).value,
    'plan': () => executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      input,
      'gap-slot-selection.spec',
    ),
  };
}

void check(String source, String input, Object? expected) {
  final observed = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      observed[route.key] = {'ok': route.value()};
    } catch (error) {
      observed[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('GAP_SLOT_SELECTION ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    expect(row.value, {'ok': expected}, reason: row.key);
  }
}

void functionFence(String source, String helper) {
  final observed = <String, Object?>{};
  for (final route in routes(source, 'x').entries) {
    try {
      observed[route.key] = {'unexpected_value': route.value()};
    } catch (error) {
      observed[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
      };
    }
  }
  print('GAP_SLOT_SELECTION_FENCE ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    final value = row.value! as Map<String, Object?>;
    expect(value.keys, containsAll(['error', 'class']), reason: row.key);
    expect(
      value['error'],
      allOf(
        contains('parser-state helper'),
        contains('not supported in user functions'),
        contains("'$helper'"),
      ),
      reason: row.key,
    );
    expect(
      value['class'],
      row.key == 'plan'
          ? 'GeneratedSourceException'
          : 'RuntimeInterpreterException',
    );
  }
}

String gapSource(String definitions, String action, String item) =>
    '$definitions\nList::\n @capture_gaps\n I {rows=[]}\n -> Item[word] {$action}\n LX {return(rows)}\nItem:\n word=/[^,;]+/\n I {$item}\n';

void contextFailure(String source) {
  final observed = <String, Object?>{};
  for (final route in routes(source, 'x').entries) {
    try {
      observed[route.key] = {'unexpected_value': route.value()};
    } catch (error) {
      observed[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
        if (error is RuntimeInterpreterException)
          'diagnostic': error.diagnostic?.toJson(),
      };
    }
  }
  print('GAP_SLOT_CONTEXT ${jsonEncode(observed)}');
  for (final route in observed.entries) {
    final value = route.value! as Map<String, Object?>;
    expect(value, contains('error'), reason: route.key);
    expect(value['error'], contains('gap_capture_context_unavailable'));
    expect(
      value['class'],
      route.key == 'plan'
          ? 'GeneratedSourceException'
          : 'RuntimeInterpreterException',
    );
    if (route.key != 'plan') {
      final diagnostic = value['diagnostic']! as Map;
      expect(diagnostic['code'], 'gap_capture_context_unavailable');
      expect(diagnostic['stage'], 'access_gap_context');
      expect(diagnostic['helper_name'], 'gap_span');
    }
  }
}

void main() {
  test('frozen gap slot record selection target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/gap_slot_record_selection_values.$extension',
      ),
    ).readAsStringSync();
    check(fixture('spec'), 'a,b', jsonDecode(fixture('json')));
  });
  test('primitive records and bound fields preserve named provenance', () {
    final source = gapSource(
      '',
      'push(rows,[gap_span(),call(Item)])',
      'return(entry_slot())',
    );
    final slot = {
      'target_rule': 'Item',
      'regex_index': 0,
      'slot_id': 'word',
      'selector_kind': 'named',
      'authored_selector': 'word',
    };
    check(source, 'a,b', [
      [
        {'source_id': 'input', 'start': 0, 'end': 0, 'provenance': 'gap'},
        slot,
      ],
      [
        {'source_id': 'input', 'start': 1, 'end': 2, 'provenance': 'gap'},
        slot,
      ],
    ]);
    check(
      gapSource(
        '',
        'span=gap_span();push(rows,[span["start"].add(1),call(Item)])',
        'entry_record=entry_slot();return(entry_record["slot_id"].uppercase())',
      ),
      'a,b',
      [
        [1, 'WORD'],
        [2, 'WORD'],
      ],
    );
  });
  test('compatible direct fields preserve zero and skip defaults', () {
    check(
      gapSource(
        '',
        'push(rows,[gap_span()["end"].coalesce(99).cat("!"),call(Item)])',
        'return([entry_slot()["regex_index"].coalesce(99).add(1),entry_slot()["slot_id"].uppercase()])',
      ),
      'a,b',
      [
        [
          '0!',
          [1, 'WORD'],
        ],
        [
          '2!',
          [1, 'WORD'],
        ],
      ],
    );
  });
  test(
    'direct slot absence recovers distinct kinds and signed Array selection',
    () {
      check(
        r'''Top:: I {return([entry_slot(),entry_slot()["missing"].coalesce("M"),entry_slot()["missing"].coalesce(false),entry_slot()["missing"].coalesce(0),entry_slot()["missing"].coalesce(["a","tail"])[-1].uppercase()])}''',
        'x',
        [null, 'M', false, 0, 'TAIL'],
      );
    },
  );
  test('unavailable gap errors precede selected field defaults', () {
    contextFailure('Top:: I {return(gap_span())}');
    contextFailure('Top:: I {return(gap_span()["start"].coalesce(99))}');
  });
  test('pure function state fence and explicit records stay distinct', () {
    for (final entry in {
      'gap_span': 'start',
      'entry_slot': 'slot_id',
    }.entries) {
      final definition =
          'fn selected(){return(${entry.key}()["${entry.value}"].coalesce("M"))}';
      functionFence(
        gapSource(definition, 'push(rows,selected())', 'return(entry_text())'),
        entry.key,
      );
    }
    check(
      gapSource(
        'fn selected(span,item){return([span["start"].add(1),item])}\nfn identify(slot){return(slot["slot_id"].uppercase())}',
        'push(rows,selected(gap_span(),call(Item)))',
        'return(identify(entry_slot()))',
      ),
      'a,b',
      [
        [1, 'WORD'],
        [2, 'WORD'],
      ],
    );
  });
}
