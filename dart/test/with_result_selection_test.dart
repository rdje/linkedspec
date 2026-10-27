// TYPE-REFERENCE-BOOK.1.2.23.3.32.3 — immediate contextual with-result reads.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object? Function()> routes(String source) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  return {
    'native': () => LinkedSpecRuntimeEngine(compiled).execute('x').value,
    'restored': () =>
        LinkedSpecRuntimeEngine(compileSpec(restored)).execute('x').value,
    'plan': () => executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      'x',
      'with-result-selection.spec',
    ),
  };
}

Map<String, Object?> observe(String source) {
  try {
    return {
      for (final route in routes(source).entries)
        route.key: capture(route.value),
    };
  } catch (error) {
    return {'compile_error': error.toString()};
  }
}

Map<String, Object?> capture(Object? Function() action) {
  try {
    return {'ok': action()};
  } catch (error) {
    return {'error': error.toString()};
  }
}

void check(String source, Object? expected) {
  final actual = observe(source);
  print('WITH_SELECTION_ACTUAL ${jsonEncode(actual)}');
  expect(actual.keys, ['native', 'restored', 'plan']);
  for (final row in actual.entries) {
    expect(row.value, {'ok': expected}, reason: row.key);
  }
}

String fixture(String extension) => File.fromUri(
  Directory.current.parent.uri.resolve(
    'tests/fixtures/with_result_selection_values.$extension',
  ),
).readAsStringSync();
const roles = <String, String>{
  'nested_pure':
      r'''fn pure(text){return(with(text){return([uppercase(value)])}[0])}
Top:: I {value="outer";nested=with("outside"){return(with("inside"){return([value])}[0])};return([nested,value,pure("ok")]);}''',
  'bound_final':
      r'''Top:: I {order="";cb={|item|return([item])};return([with("z",cb)[0],with("z",cb)[9].count(),with("z",cb)[0].take({order=cat(order,"B");1}),order]);}''',
  'literal_final':
      r'''Top:: I {return([with("z",{|item|return([item])})[0],with("z",{|item|return([item])})[9].count()]);}''',
  'callback_bodies': r'''fn apply(callback: codeblock){return(callback())}
Top:: I {cb={||return(with("x"){return(["yes"])}[0])};a=apply(){return(with("x"){return(["yes"])}[0])};return([cb(),a,"x".with(){return([false])}[0].copy()]);}''',
  'malformed_role': r'''Top:: I {return(with("x","extra"){return([1])}[0]);}''',
  'missing_source':
      r'''Top:: I {return(with(missing_source()){return([1])}[0].uppercase())}''',
  'missing_body':
      r'''Top:: I {return(with("x"){return([missing()])}[0].uppercase())}''',
  'function_state':
      'fn forbidden(){return(with("x"){return([entry_len()])}[0].uppercase())}\nTop:: I {return(forbidden())}',
};
void main() {
  test('frozen immediate with selection target', () {
    check(fixture('spec'), jsonDecode(fixture('json')));
  });
  test('nested and pure scopes restore the caller', () {
    check(roles['nested_pure']!, ['inside', 'outer', 'OK']);
  });
  test('explicit and bound final callbacks keep legacy consumer rules', () {
    check(roles['bound_final']!, ['z', 0, <Object?>[], 'B']);
    check(roles['literal_final']!, ['z', 0]);
  });
  test('existing callback body reads remain supported', () {
    check(roles['callback_bodies']!, ['yes', 'yes', false]);
  });
  test('malformed contextual arity keeps its compile diagnosis', () {
    final actual = observe(roles['malformed_role']!);
    print('WITH_SELECTION_ARITY ${jsonEncode(actual)}');
    expect(actual.keys, ['compile_error']);
    expect(
      actual['compile_error'],
      allOf(
        contains('callable_contract_arity_mismatch'),
        contains("helper 'with'"),
        contains('got 2'),
      ),
    );
  });
  test('specific function and unknown helper fences survive selection', () {
    for (final row in <String, List<String>>{
      'function_state': ['parser-state helper', 'entry_len'],
      'missing_source': ['unknown_helper', 'missing_source'],
      'missing_body': ['unknown_helper', 'name="missing"'],
    }.entries) {
      final actual = observe(roles[row.key]!);
      print('WITH_SELECTION_ERROR ${row.key} ${jsonEncode(actual)}');
      expect(actual.keys, ['native', 'restored', 'plan']);
      for (final route in actual.entries) {
        final result = route.value as Map<String, Object?>;
        expect(result.keys, ['error'], reason: route.key);
        for (final required in row.value) {
          expect(result['error'], contains(required), reason: route.key);
        }
      }
    }
  });
}
