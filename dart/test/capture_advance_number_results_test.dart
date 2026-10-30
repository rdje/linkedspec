// TYPE-REFERENCE-BOOK.1.2.23.3.52.3 — advancing capture Number composition.
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
      'capture-advance-number.spec',
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
  print('CAPTURE_ADVANCE_NUMBER ${jsonEncode(observed)}');
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
  print('CAPTURE_ADVANCE_NUMBER_FENCE ${jsonEncode(observed)}');
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
  test('frozen advancing capture Number target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/capture_advance_number_values.$extension',
      ),
    ).readAsStringSync();
    check(fixture('spec'), 'αβ:catTAIL', jsonDecode(fixture('json')));
  });
  test('bound sources retain distinct width and origin endpoints', () {
    for (final (helper, width, origin) in const [
      ('capture_take_len', 1, 6),
      ('capture_take_until_cursor_len', 4, 6),
      ('capture_take_rest_len', 8, 10),
    ]) {
      check(
        action(
          'part=$helper();return([part.coalesce(99).add(1).cat("!"),capture_slice_pos(),cursor_pos()])',
        ),
        'αβ:catTAIL',
        [
          ['${width + 1}!', origin, 6],
        ],
      );
    }
  });
  test('missing zero reversed and snapshot preserve native effect order', () {
    check(
      r"""Top:: I {return([capture_take_len().coalesce(99).cat("!"),capture_slice_pos(),cursor_pos()])}""",
      'x',
      ['99!', 0, 0],
    );
    check(
      action(
        r"""first=capture_take_until_cursor_len();order="";zero=capture_take_until_cursor_len().coalesce({order=cat(order,"F");99}).add(1);missing=capture_take_len().coalesce(99).cat("!");return([first,zero,missing,capture_slice_pos(),cursor_pos(),order])""",
      ),
      'αβ:catTAIL',
      [
        [4, 1, '99!', 6, 6, ''],
      ],
    );
    check(
      action(
        r"""width=capture_take_rest_len().coalesce(0);snapshot=width.cat({start_capture_slice();"!"});return([width,snapshot,capture_slice_pos(),cursor_pos()])""",
      ),
      'αβ:catTAIL',
      [
        [8, '8!', 6, 6],
      ],
    );
  });
  test('named width source retains separate mark effects', () {
    check(
      action(
        r"""mark_capture_slice(begin);out=capture_take_len_from(begin).coalesce(99).add(1).cat("!");return([out,mark_pos(begin),capture_slice_pos(),cursor_pos()])""",
      ),
      'αβ:catTAIL',
      [
        ['2!', 6, 2, 6],
      ],
    );
  });
  test('all advancing Number sources retain specific pure function errors', () {
    for (final helper in [
      'capture_take_len',
      'capture_take_until_cursor_len',
      'capture_take_rest_len',
    ]) {
      functionFence(
        'fn forbidden(){return($helper().coalesce(99).add(1))} Top:: I {return(forbidden())}',
        helper,
      );
    }
  });
  test('callbacks retain caller origin update and function invocation fence', () {
    check(
      r"""Top:: I {cb={||return(capture_take_rest_len().coalesce(99).add(1))};out=cb();return([out,capture_slice_pos(),cursor_pos()])}""",
      'abc',
      [4, 3, 0],
    );
    functionFence(
      r"""fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_take_rest_len().coalesce(99).add(1))})}""",
      'capture_take_rest_len',
    );
  });
}
