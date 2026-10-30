// TYPE-REFERENCE-BOOK.1.2.23.3.50.3 — readonly capture String composition.
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
      'capture-boundary-text.spec',
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
  print('CAPTURE_TEXT ${jsonEncode(observed)}');
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
  print('CAPTURE_TEXT_FENCE ${jsonEncode(observed)}');
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
  test('frozen readonly capture String target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/capture_boundary_text_values.$extension',
      ),
    ).readAsStringSync();
    check(fixture('spec'), 'αβ:cat', jsonDecode(fixture('json')));
  });
  test(
    'four native readers default and String zero selection keep their values',
    () {
      check(
        action(
          r"""return([capture_slice().coalesce("bad").cat("!"),capture_slice_until_cursor().coalesce("bad").cat("!"),capture_rest().coalesce("bad").cat("!"),capture_from_rule_start().coalesce("bad").cat("!"),[capture_slice(),capture_slice_until_cursor(),capture_rest(),capture_from_rule_start()]])""",
        ),
        'αβ:cat',
        [
          [
            ":!",
            ":cat!",
            ":cat!",
            ":!",
            [":", ":cat", ":cat", ":"],
          ],
        ],
      );
      check(
        action(
          r"""tail=capture_rest();return([tail.split(":")[-1].uppercase(),capture_rest().coalesce("bad").split(":")[-1].coalesce("bad")])""",
          '0',
        ),
        'αβ:0',
        [
          ['0', '0'],
        ],
      );
    },
  );
  test(
    'initial missing defined empty and reversed spans retain getter policies',
    () {
      check(
        r"""Top:: I {return([capture_slice().coalesce("missing").cat("!"),capture_from_rule_start().coalesce("alias").uppercase(),capture_rest().coalesce("bad").cat("!"),capture_slice_until_cursor().coalesce("bad").cat("!")])}""",
        'x',
        ['missing!', 'ALIAS', 'x!', '!'],
      );
      check(
        action(
          r"""start_capture_slice();return([capture_slice().coalesce("reversed").cat("!"),capture_slice_pos()])""",
        ),
        'αβ:cat',
        [
          ['reversed!', 6],
        ],
      );
    },
  );
  test('legacy direct consumer and with retain actual Dart policy', () {
    check(
      action(
        r"""order="";a=capture_rest().take({order=cat(order,"T");1});b=capture_rest().with() {return(["ok"])}.first().uppercase();return([a,b,order]);""",
      ),
      'αβ:cat',
      [
        [<Object?>[], 'OK', 'T'],
      ],
    );
  });
  test(
    'four sources preserve specific function-state errors under consumers',
    () {
      for (final helper in [
        'capture_slice',
        'capture_slice_until_cursor',
        'capture_rest',
        'capture_from_rule_start',
      ]) {
        functionFence(
          'fn forbidden(){return($helper().coalesce("M").cat("!"))} Top:: I {return(forbidden())}',
          helper,
        );
      }
    },
  );
  test('callbacks keep caller state and function invocation restrictions', () {
    check(
      r"""Top:: I {cb={||return(capture_rest().coalesce("bad").cat("!"))};return(cb())}""",
      'x',
      'x!',
    );
    functionFence(
      r"""fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_rest().coalesce("bad").cat("!"))})}""",
      'capture_rest',
    );
  });
}
