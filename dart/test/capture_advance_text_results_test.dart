// TYPE-REFERENCE-BOOK.1.2.23.3.51.3 — advancing capture String composition.
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
      'capture-advance-text.spec',
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
  print('CAPTURE_ADVANCE_TEXT ${jsonEncode(observed)}');
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
  print('CAPTURE_ADVANCE_TEXT_FENCE ${jsonEncode(observed)}');
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

String action(String body, [String tail = 'cat']) =>
    'Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>αβ)/\n /:/\n /$tail/\n -> Value[2] {$body}\n';

void main() {
  test('frozen advancing capture String target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/capture_advance_text_values.$extension',
      ),
    ).readAsStringSync();
    check(fixture('spec'), 'αβ:catTAIL', jsonDecode(fixture('json')));
  });
  test('native and bound sources retain distinct capture origin endpoints', () {
    for (final (helper, text, origin) in const [
      ('capture_take', ':', 6),
      ('capture_take_until_cursor', ':cat', 6),
      ('capture_take_rest', ':catTAIL', 10),
    ]) {
      check(
        action(
          'part=$helper();return([part.coalesce("M").cat("!"),capture_slice_pos(),cursor_pos()])',
        ),
        'αβ:catTAIL',
        [
          ['$text!', origin, 6],
        ],
      );
    }
  });
  test('missing empty String zero and Number links preserve effect order', () {
    check(
      r"""Top:: I {return([capture_take().coalesce("M").cat("!"),capture_slice_pos(),cursor_pos()])}""",
      'x',
      ['M!', 0, 0],
    );
    check(
      action(
        r"""first=capture_take_until_cursor();order="";empty=capture_take_until_cursor().coalesce({order=cat(order,"F");"fallback"}).cat("!");missing=capture_take().coalesce("M").cat("!");return([first,empty,missing,capture_slice_pos(),cursor_pos(),order])""",
      ),
      'αβ:catTAIL',
      [
        [':cat', '!', 'M!', 6, 6, ''],
      ],
    );
    check(
      action(
        r"""return([capture_take_until_cursor().coalesce("M").split(":")[-1].coalesce("bad"),capture_slice_pos(),cursor_pos()])""",
        '0',
      ),
      'αβ:0TAIL',
      [
        ['0', 4, 4],
      ],
    );
    check(
      action(
        r"""return([capture_take_rest().coalesce("M").length().add(1),capture_slice_pos(),cursor_pos()])""",
      ),
      'αβ:catTAIL',
      [
        [9, 10, 6],
      ],
    );
  });
  test('named overload retains its separate mark effect', () {
    check(
      action(
        r"""mark_capture_slice(begin);out=capture_take(begin).coalesce("M").cat("!");return([out,mark_pos(begin),capture_slice_pos(),cursor_pos()])""",
      ),
      'αβ:catTAIL',
      [
        [':!', 6, 2, 6],
      ],
    );
  });
  test('all advancing sources retain specific pure function errors', () {
    for (final helper in [
      'capture_take',
      'capture_take_until_cursor',
      'capture_take_rest',
    ]) {
      functionFence(
        'fn forbidden(){return($helper().coalesce("M").cat("!"))} Top:: I {return(forbidden())}',
        helper,
      );
    }
  });
  test('callbacks keep caller effects and function invocation fence', () {
    check(
      r"""Top:: I {cb={||return(capture_take_rest().coalesce("M").cat("!"))};out=cb();return([out,capture_slice_pos(),cursor_pos()])}""",
      'abc',
      ['abc!', 3, 0],
    );
    functionFence(
      r"""fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_take_rest().coalesce("M").cat("!"))})}""",
      'capture_take_rest',
    );
  });
}
