// TYPE-REFERENCE-BOOK.1.2.23.3.72.6.3 — copied-null index composition.
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
      'copied-null-index-composition.spec',
    ),
  };
}

void check(String label, String source, String input, Object? expected) {
  final observed = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      observed[route.key] = {'ok': route.value()};
    } catch (error) {
      observed[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('COPIED_NULL_VALUE $label ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    expect(row.value, {'ok': expected}, reason: row.key);
  }
}

Map<String, Object?> errorRows(String source, String input) {
  final actual = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      actual[route.key] = {'value': route.value()};
    } catch (error) {
      actual[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
        if (error is RuntimeInterpreterException)
          'diagnostic': error.diagnostic?.toJson(),
      };
    }
  }
  return actual;
}

void main() {
  final cases =
      (jsonDecode(
                File.fromUri(
                  Directory.current.parent.uri.resolve(
                    'tests/fixtures/copied_null_index_cases.json',
                  ),
                ).readAsStringSync(),
              )
              as List)
          .cast<Map<String, dynamic>>();
  cases.addAll(
    (jsonDecode(
              r'''[{"id":"copied_null_needle_policy","body":"order=\"\";out=[{undef}.copy().index_of({order=cat(order,\"A\");\"a\"}),copy({undef}).index_of({order=cat(order,\"B\");\"a\"}),index_of(copy({undef}),{order=cat(order,\"C\");\"a\"})];return([out,order])","source":"Value:: I {order=\"\";out=[{undef}.copy().index_of({order=cat(order,\"A\");\"a\"}),copy({undef}).index_of({order=cat(order,\"B\");\"a\"}),index_of(copy({undef}),{order=cat(order,\"C\");\"a\"})];return([out,order])}","rule":"Value","input":"x","input_characters":1,"leading_codepoint":120,"component":"null_diagnostic","observation_only":true,"expected":[[null,null,null],"ABC"]},{"id":"null_source_needle_policy","body":"order=\"\";out=[index_of(undef,{order=cat(order,\"F\");\"a\"}),{undef}.index_of({order=cat(order,\"R\");\"a\"}),[].first().index_of({order=cat(order,\"S\");\"a\"})];return([out,order])","source":"Value:: I {order=\"\";out=[index_of(undef,{order=cat(order,\"F\");\"a\"}),{undef}.index_of({order=cat(order,\"R\");\"a\"}),[].first().index_of({order=cat(order,\"S\");\"a\"})];return([out,order])}","rule":"Value","input":"x","input_characters":1,"leading_codepoint":120,"component":"null_diagnostic","observation_only":true,"expected":[[null,null,null],"FRS"]}]''',
            )
            as List)
        .cast<Map<String, dynamic>>(),
  );
  for (final row in cases) {
    final id = row['id'] as String;
    test(id, () {
      final expectedError = row['expected_error'] as String?;
      if (expectedError == null) {
        check(
          id,
          row['source'] as String,
          row['input'] as String,
          row['expected'],
        );
      } else {
        final actual = errorRows(
          row['source'] as String,
          row['input'] as String,
        );
        print('COPIED_NULL_ERROR $id ${jsonEncode(actual)}');
        expect(actual.keys.toSet(), {'native', 'restored', 'plan'});
        for (final route in actual.entries) {
          expect(
            (route.value as Map)['error'],
            contains(expectedError),
            reason: route.key,
          );
        }
      }
    });
  }
}
