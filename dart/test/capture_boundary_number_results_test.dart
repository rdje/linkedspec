// TYPE-REFERENCE-BOOK.1.2.23.3.33.3 — readonly capture Number method flow.
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
      'capture-boundary-number.spec',
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
  print('CAPTURE_NUMBER ${jsonEncode(observed)}');
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
  print('CAPTURE_NUMBER_FENCE ${jsonEncode(observed)}');
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

String action(String body) =>
    'Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>αβ)/\n /:/\n /cat/\n -> Value[2] {$body}\n';
void main() {
  test('unchanged frozen readonly capture Number target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/capture_boundary_number_values.$extension',
      ),
    ).readAsStringSync();
    check(fixture('spec'), 'αβ:cat', jsonDecode(fixture('json')));
  });
  test('original six getters and three aliases retain snapshot values', () {
    check(
      action(r'''order="";
original=[capture_slice_len(),capture_slice_pos(),capture_slice_line(),capture_slice_col(),capture_slice_until_cursor_len(),capture_rest_len(),capture_slice_length(),capture_len_from_rule_start(),capture_rest_length()];
width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});start_capture_slice();
return([original,snapshot,capture_slice_pos(),order]);'''),
      'αβ:cat',
      [
        [
          [1, 2, 1, 3, 4, 4, 1, 1, 4],
          '4!',
          6,
          'S',
        ],
      ],
    );
  });
  test('defined capture-boundary position zero skips a lazy fallback', () {
    // The missing local-match endpoint width is diagnostic-only under40.
    check(
      r'''Top:: I {order="";primitive=[capture_slice_pos(),capture_slice_line(),capture_slice_col(),capture_slice_until_cursor_len(),capture_rest_len()];zero=capture_slice_pos().coalesce({order=cat(order,"F");7}).add(1);return([primitive,zero,order])}''',
      'x',
      [
        [0, 1, 1, 0, 1],
        1,
        '',
      ],
    );
  });
  test(
    'legacy direct first consumers retain actual values and operand effects',
    () {
      check(
        action(
          r'''order="";a=capture_rest_len().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=capture_rest_len().take({order=cat(order,"T");1});return([a,b,order]);''',
        ),
        'αβ:cat',
        [
          [4, <Object?>[], 'KVT'],
        ],
      );
    },
  );
  test(
    'all readonly sources retain specific function-state fences under consumers',
    () {
      for (final helper in [
        'capture_slice_len',
        'capture_slice_pos',
        'capture_slice_line',
        'capture_slice_col',
        'capture_slice_until_cursor_len',
        'capture_rest_len',
        'capture_slice_length',
        'capture_len_from_rule_start',
        'capture_rest_length',
      ]) {
        functionFence(
          'fn forbidden(){return($helper().coalesce(0).cat("!").split("!")[0].uppercase())}\nTop:: I {return(forbidden())}',
          helper,
        );
      }
    },
  );
  test(
    'callback parser context and pure-function invocation context remain distinct',
    () {
      check(
        r'''Top:: I {cb={||return(capture_rest_len().coalesce(0).cat("!"))};return(cb())}''',
        'x',
        '1!',
      );
      functionFence(
        r'''fn apply(callback: codeblock){return(callback())}
Top:: I {return(apply(){return(capture_rest_len().coalesce(0).cat("!"))})}''',
        'capture_rest_len',
      );
    },
  );
}
