import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

String fixture(String name, String extension) {
  final repositoryRoot = Directory.current.parent;
  return File.fromUri(
    repositoryRoot.uri.resolve('tests/fixtures/$name.$extension'),
  ).readAsStringSync();
}

void assertConsumers(String source, Object? expected) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final actual = LinkedSpecRuntimeEngine(compiled).execute('x').value;
  expect(actual, expected, reason: 'native: ${jsonEncode(actual)}');
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  expect(
    LinkedSpecRuntimeEngine(compileSpec(restored)).execute('x').value,
    expected,
  );
  expect(
    executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      'x',
      'string-comparison-result-receivers.spec',
    ),
    expected,
  );
}

void main() {
  test('free comparisons retain Boolean, null and text domains', () {
    assertConsumers(
      r'''Top:: I { word="abc"; zero_text="0"; raw=[str_eq(word,"abc"),str_ne(word,"z"),str_gt(word,"aaa"),str_ge(word,"abc"),str_lt(word,"zzz"),str_le(word,"abc"),str_eq(word,"z"),str_ne(word,"abc"),str_gt(word,"zzz"),str_ge(word,"zzz"),str_lt(word,"aaa"),str_le(word,"aaa")]; order=""; null_result=str_eq({order=cat(order,"S");undef},{order=cat(order,"O");"a"});return({"raw":raw,"boundaries":[str_eq(undef,""),str_eq("",undef),str_eq("",""),str_eq("0",zero_text),str_eq(zero_text,"0")],"text":[cat(str_eq("a","b"),"!"),cat(coalesce_nonempty(str_eq("a","b"),"late"),"!")],"null_result":null_result,"order":order}) }''',
      {
        'raw': [
          true,
          true,
          true,
          true,
          true,
          true,
          false,
          false,
          false,
          false,
          false,
          false,
        ],
        'boundaries': [null, null, true, true, true],
        'text': ['0!', '0!'],
        'null_result': null,
        'order': 'SO',
      },
    );
  });
  test('comparison results retain kinds, shapes and operand order', () {
    assertConsumers(
      fixture('string_comparison_result_receiver_values', 'spec'),
      jsonDecode(
        fixture('string_comparison_result_receiver_values', 'null.json'),
      ),
    );
  });
}
