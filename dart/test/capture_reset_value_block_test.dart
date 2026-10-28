// TYPE-REFERENCE-BOOK.1.2.23.3.35.3 — ordinary capture reset block flow.
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
      'capture-reset-value-block.spec',
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
  print('CAPTURE_RESET ${jsonEncode(observed)}');
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
  print('CAPTURE_RESET_FENCE ${jsonEncode(observed)}');
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

Map<String, String> cases() => {
  "without_reset": r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
''',
  "standalone": r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});start_capture_slice();order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
''',
  "inside": File.fromUri(
    Directory.current.parent.uri.resolve(
      'tests/fixtures/capture_reset_value_block_values.spec',
    ),
  ).readAsStringSync(),
  "alias_inside": r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");capture_slice_here();"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
''',
  "return_before": r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");return("!");start_capture_slice();order=cat(order,"T");"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
''',
  "return_after": r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");start_capture_slice();return("!");order=cat(order,"T");"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
''',
  "lazy_skip": r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.coalesce({order=cat(order,"S");start_capture_slice();"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
''',
  "direct_source": r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";snapshot=capture_rest_len().cat({order=cat(order,"S");start_capture_slice();"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
''',
  "function_start_capture_slice":
      r'''fn forbidden(){return("x".cat({start_capture_slice();"!"}))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=forbidden();return([result,capture_slice_pos()])}
''',
  "literal_start_capture_slice": r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {cb={||return("x".cat({start_capture_slice();"!"}))};result=cb();return([result,capture_slice_pos()])}
''',
  "registered_start_capture_slice":
      r'''fn apply(callback: codeblock){return(callback())}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=apply(){return("x".cat({start_capture_slice();"!"}))};return([result,capture_slice_pos()])}
''',
  "function_capture_slice_here":
      r'''fn forbidden(){return("x".cat({capture_slice_here();"!"}))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=forbidden();return([result,capture_slice_pos()])}
''',
  "literal_capture_slice_here": r'''Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {cb={||return("x".cat({capture_slice_here();"!"}))};result=cb();return([result,capture_slice_pos()])}
''',
  "registered_capture_slice_here":
      r'''fn apply(callback: codeblock){return(callback())}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=apply(){return("x".cat({capture_slice_here();"!"}))};return([result,capture_slice_pos()])}
''',
};
void main() {
  test('ordinary blocks preserve snapshot, lazy order and local returns', () {
    final expected = <String, Object?>{
      'without_reset': [
        ['4!', 2, 4, 'SA'],
      ],
      'standalone': [
        ['4!', 6, 0, 'SA'],
      ],
      'inside': jsonDecode(
        File.fromUri(
          Directory.current.parent.uri.resolve(
            'tests/fixtures/capture_reset_value_block_values.json',
          ),
        ).readAsStringSync(),
      ),
      'alias_inside': [
        ['4!', 6, 0, 'SA'],
      ],
      'return_before': [
        ['4!', 2, 4, 'SA'],
      ],
      'return_after': [
        ['4!', 6, 0, 'SA'],
      ],
      'lazy_skip': [
        [4, 2, 4, 'A'],
      ],
      'direct_source': [
        ['4!', 6, 0, 'SA'],
      ],
    };
    for (final row in cases().entries) {
      if (expected.containsKey(row.key))
        check(row.value, 'αβ:cat', expected[row.key]);
    }
  });
  test(
    'literal callbacks keep existing caller parser context for both aliases',
    () {
      for (final row in cases().entries) {
        if (row.key.startsWith('literal_'))
          check(row.value, 'αβ:cat', [
            ['x!', 6],
          ]);
      }
    },
  );
  test(
    'pure functions and registered callbacks retain authored helper fences',
    () {
      for (final row in cases().entries) {
        if (row.key.startsWith('function_') ||
            row.key.startsWith('registered_')) {
          functionFence(row.value, row.key.substring(row.key.indexOf('_') + 1));
        }
      }
    },
  );
}
