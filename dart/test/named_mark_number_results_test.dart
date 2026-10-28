// TYPE-REFERENCE-BOOK.1.2.23.3.34.3 — named Number values and caller mark scope.
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
      'named-mark-number.spec',
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
  print('NAMED_MARK_NUMBER ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    expect(row.value, {'ok': expected}, reason: row.key);
  }
}

void functionFence(String source, String helper) {
  final observed = <String, Object?>{};
  for (final route in routes(source, 'αβ:cat').entries) {
    try {
      observed[route.key] = {'unexpected_value': route.value()};
    } catch (error) {
      observed[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
      };
    }
  }
  print('NAMED_MARK_NUMBER_FENCE ${jsonEncode(observed)}');
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

Map<String, ({String source, String input})> cases() => {
  "shared": (
    source: File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/named_mark_number_values.spec',
      ),
    ).readAsStringSync(),
    input: "αβ:cat",
  ),
  "producers": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(finish),mark_line(finish),mark_col(finish),capture_len_from(begin),capture_rest_len_from(begin),capture_until_cursor_len_from(begin),capture_len_between(begin,finish)])}
''',
    input: "αβ:cat",
  ),
  "missing_producers": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(absent),mark_line(absent),mark_col(absent),capture_len_from(absent),capture_rest_len_from(absent),capture_until_cursor_len_from(absent),capture_len_between(absent,finish),capture_len_between(begin,absent)])}
''',
    input: "αβ:cat",
  ),
  "symbolic_shadow": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);begin="finish";finish="begin";return([capture_len_between(begin,finish),mark_pos(begin),mark_pos(finish)])}
''',
    input: "αβ:cat",
  ),
  "quoted_names": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos("finish"),capture_len_between("begin","finish")])}
''',
    input: "αβ:cat",
  ),
  "evaluated_name": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_pos(cat("fin","ish")))}
''',
    input: "αβ:cat",
  ),
  "legacy_bound": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);p=mark_pos(finish);order="";a=p.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=p.take({order=cat(order,"T");1});c=p.add(0).set_key({order=cat(order,"X");"k"},{order=cat(order,"Y");1});return([a,b,c,order])}
''',
    input: "αβ:cat",
  ),
  "snapshot_bound": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";p=mark_pos(finish);snapshot=p.cat({order=cat(order,"S");"!"});clear_mark(finish);return([snapshot,mark_pos(finish),mark_pos(begin),order])}
''',
    input: "αβ:cat",
  ),
  "direct_mark_pos": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_pos(finish).coalesce(0).cat("!"))}
''',
    input: "αβ:cat",
  ),
  "direct_mark_line": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_line(finish).coalesce(0).cat("!"))}
''',
    input: "αβ:cat",
  ),
  "direct_mark_col": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_col(finish).coalesce(0).cat("!"))}
''',
    input: "αβ:cat",
  ),
  "direct_capture_len_from": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_len_from(begin).coalesce(0).cat("!"))}
''',
    input: "αβ:cat",
  ),
  "direct_capture_until_cursor_len_from": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_until_cursor_len_from(begin).coalesce(0).cat("!"))}
''',
    input: "αβ:cat",
  ),
  "direct_capture_rest_len_from": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_rest_len_from(begin).coalesce(0).cat("!"))}
''',
    input: "αβ:cat",
  ),
  "direct_capture_len_between": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_len_between(begin,finish).coalesce(0).cat("!"))}
''',
    input: "αβ:cat",
  ),
  "direct_legacy": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";a=mark_pos(finish).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=mark_pos(finish).take({order=cat(order,"T");1});return([a,b,order])}
''',
    input: "αβ:cat",
  ),
  "other_label": (
    source: r'''Top::
 -> Other .push
 LX {return(copy(Top))}
Other:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Other[2] {mark_input_start(left);mark_input_end(right);return([mark_pos(right).coalesce(0).sub(1),mark_line(right).coalesce(0).add(1),mark_col(right).coalesce(0).cat("!"),capture_len_from(left).coalesce(0).cat(":tail").split(":")[-1].uppercase(),capture_rest_len_from(left).coalesce(0).add(1),capture_until_cursor_len_from(left).coalesce(0).sub(1),capture_len_between(left,right).coalesce(0).add(1)])}
''',
    input: "αβ:cat",
  ),
  "partial_shared": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(finish).coalesce(0).sub(1),mark_line(finish).coalesce(0).add(1),mark_col(finish).coalesce(0).cat("!"),capture_len_from(begin).coalesce(0).cat(":tail").split(":")[-1].uppercase(),capture_rest_len_from(begin).coalesce(0).add(1),capture_until_cursor_len_from(begin).coalesce(0).sub(1),capture_len_between(begin,finish).coalesce(0).add(1)])}
''',
    input: "αβ:catTAIL",
  ),
  "zero_missing_reversed": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";a=mark_pos(begin).coalesce({order=cat(order,"Z");9}).add(1);b=capture_len_between(begin,begin).coalesce({order=cat(order,"E");9}).add(1);c=mark_pos(absent).coalesce({order=cat(order,"F");7}).add(1);d=capture_len_between(finish,begin).coalesce(9).add(1);return([a,b,c,d,order])}
''',
    input: "αβ:cat",
  ),
  "function_mark_pos": (
    source: r'''fn forbidden(){return(mark_pos(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
''',
    input: "αβ:cat",
  ),
  "function_mark_line": (
    source: r'''fn forbidden(){return(mark_line(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
''',
    input: "αβ:cat",
  ),
  "function_mark_col": (
    source: r'''fn forbidden(){return(mark_col(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
''',
    input: "αβ:cat",
  ),
  "function_capture_len_from": (
    source:
        r'''fn forbidden(){return(capture_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
''',
    input: "αβ:cat",
  ),
  "function_capture_until_cursor_len_from": (
    source:
        r'''fn forbidden(){return(capture_until_cursor_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
''',
    input: "αβ:cat",
  ),
  "function_capture_rest_len_from": (
    source:
        r'''fn forbidden(){return(capture_rest_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
''',
    input: "αβ:cat",
  ),
  "function_capture_len_between": (
    source:
        r'''fn forbidden(){return(capture_len_between(begin,finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
''',
    input: "αβ:cat",
  ),
  "literal_callback_all": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);cb={||return([mark_pos(finish).coalesce(0).cat("!"),mark_line(finish).coalesce(0).cat("!"),mark_col(finish).coalesce(0).cat("!"),capture_len_from(begin).coalesce(0).cat("!"),capture_until_cursor_len_from(begin).coalesce(0).cat("!"),capture_rest_len_from(begin).coalesce(0).cat("!"),capture_len_between(begin,finish).coalesce(0).cat("!")])};return(cb())}
''',
    input: "αβ:cat",
  ),
  "registered_callback": (
    source: r'''fn apply(callback: codeblock){return(callback())}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(apply(){return(mark_pos(finish).coalesce(0).cat("!"))})}
''',
    input: "αβ:cat",
  ),
  "callback_write_read_scope": (
    source: r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);cb={||mark_input_end(inside);return([mark_pos(inside),mark_pos(finish)])};result=cb();return([result,mark_pos(inside),mark_pos(finish)])}
''',
    input: "αβ:cat",
  ),
  "callback_cross_rule_scope": (
    source: r'''Top:: I {a=call(First);b=call(Second);return([a,b])}
First:: I {cb={||mark_input_end(shared);return(mark_pos(shared))};a=cb();return([a,mark_pos(shared)])}
Second:: I {cb={||return(mark_pos(shared))};a=cb();return([a,mark_pos(shared)])}
''',
    input: "x",
  ),
  "dynamic_invocation": (
    source: r'''Top::
 I {reader=call(First);mark_input_start(shared);a=reader();mark_input_end(shared);b=reader();return([a,b])}
First::
 I {mark_input_end(shared);return({||return(mark_pos(shared))})}
''',
    input: "αβ:cat",
  ),
};
void main() {
  test(
    "named sources preserve coordinates names snapshots roots and callback scopes",
    () {
      final expected = <String, Object?>{
        "shared": jsonDecode(
          File.fromUri(
            Directory.current.parent.uri.resolve(
              'tests/fixtures/named_mark_number_values.json',
            ),
          ).readAsStringSync(),
        ),
        "producers": [
          [6, 1, 7, 3, 6, 6, 6],
        ],
        "missing_producers": [
          [null, null, null, null, null, null, null, null],
        ],
        "symbolic_shadow": [
          [6, 0, 6],
        ],
        "quoted_names": [
          [6, 6],
        ],
        "evaluated_name": [6],
        "legacy_bound": [
          [
            {"k": 1},
            <Object?>[],
            null,
            "KVT",
          ],
        ],
        "snapshot_bound": [
          ["6!", null, 0, "S"],
        ],
        "direct_legacy": [
          [6, <Object?>[], "KVT"],
        ],
        "other_label": [
          [5, 2, "7!", "TAIL", 7, 5, 7],
        ],
        "partial_shared": [
          [9, 2, "11!", "TAIL", 11, 5, 11],
        ],
        "zero_missing_reversed": [
          [1, 1, 8, 10, "F"],
        ],
        "literal_callback_all": [
          ["6!", "1!", "7!", "3!", "6!", "6!", "6!"],
        ],
        "callback_write_read_scope": [
          [
            [6, 6],
            6,
            6,
          ],
        ],
        "callback_cross_rule_scope": [
          [1, 1],
          [null, null],
        ],
        "dynamic_invocation": [0, 6],
        "direct_mark_pos": ["6!"],
        "direct_mark_line": ["1!"],
        "direct_mark_col": ["7!"],
        "direct_capture_len_from": ["3!"],
        "direct_capture_until_cursor_len_from": ["6!"],
        "direct_capture_rest_len_from": ["6!"],
        "direct_capture_len_between": ["6!"],
      };
      for (final row in cases().entries) {
        if (expected.containsKey(row.key))
          check(row.value.source, row.value.input, expected[row.key]);
      }
    },
  );
  test(
    "seven named readers and registered callbacks retain pure function fences",
    () {
      for (final row in cases().entries) {
        final helper = row.key.startsWith('function_')
            ? row.key.substring(9)
            : row.key == 'registered_callback'
            ? 'mark_pos'
            : null;
        if (helper != null) functionFence(row.value.source, helper);
      }
    },
  );
}
