// TYPE-REFERENCE-BOOK.1.2.23.3.29.2.6.3 — parser calls and public gap readers.
import 'dart:convert';
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
      'function-parser-context.spec',
    ),
  };
}

String gapSource(String definitions, String action, String item) =>
    '$definitions\nList::\n @capture_gaps\n I {set(rows,array())}\n -> Item[word] {$action}\n LX {return(copy(rows))}\nItem:\n word=/[^,;]+/\n I {$item}\n';
void reject(String source, String input, String helper) {
  for (final route in routes(source, input).entries) {
    expect(
      route.value,
      throwsA(
        predicate<Object>(
          (error) =>
              error.toString().contains('parser-state helper') &&
              error.toString().contains(helper),
        ),
      ),
      reason: '${route.key} $helper',
    );
  }
}

void main() {
  test('pure function cannot invoke a child parser', () {
    reject(
      'fn selected(){return(call(Child))}\nTop:: I {return(selected())}\nChild: I {return("child")}\n',
      'x',
      'call',
    );
  });
  test('pure function cannot read public gap context', () {
    for (final helper in ['gap_text', 'gap_kind', 'gap_span', 'entry_slot']) {
      reject(
        gapSource(
          'fn selected(){return($helper())}',
          'push(rows,selected())',
          'return(entry_text())',
        ),
        'a,b',
        helper,
      );
    }
  });
  test('pure function cannot read incoming child slot', () {
    reject(
      gapSource(
        'fn selected(){return(entry_slot())}',
        'push(rows,call(Item))',
        'return(selected())',
      ),
      'a,b',
      'entry_slot',
    );
  });
  test('ordinary parser values remain valid explicit function arguments', () {
    const source =
        'fn upper(text){return(text.uppercase())}\nTop:: I {return(upper(call(Child)))}\nChild: I {return("child")}\n';
    for (final route in routes(source, 'x').entries) {
      expect(route.value(), 'CHILD', reason: route.key);
    }
    final gaps = gapSource(
      'fn selected(text,kind,span){return([text.uppercase(),kind,span])}',
      'push(rows,selected(gap_text(),gap_kind(),gap_span()))',
      'return(entry_text())',
    );
    for (final route in routes(gaps, 'a,b').entries) {
      expect(route.value(), [
        [
          '',
          'prefix',
          {'source_id': 'input', 'start': 0, 'end': 0, 'provenance': 'gap'},
        ],
        [
          ',',
          'interstitial',
          {'source_id': 'input', 'start': 1, 'end': 2, 'provenance': 'gap'},
        ],
      ], reason: route.key);
    }
    final slots = gapSource(
      'fn identify(slot){return(slot)}',
      'push(rows,call(Item))',
      'return(identify(entry_slot()))',
    );
    final slot = {
      'target_rule': 'Item',
      'regex_index': 0,
      'slot_id': 'word',
      'selector_kind': 'named',
      'authored_selector': 'word',
    };
    for (final route in routes(slots, 'a,b').entries) {
      expect(route.value(), [slot, slot], reason: route.key);
    }
  });
}
