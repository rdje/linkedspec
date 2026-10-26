import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

String fixture(String name) {
  final repositoryRoot = Directory.current.parent;
  return File.fromUri(
    repositoryRoot.uri.resolve('tests/fixtures/$name.spec'),
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
      'index-result-receivers.spec',
    ),
    expected,
  );
}

void main() {
  test('index results retain scalar kinds, shapes and operand order', () {
    assertConsumers(
      fixture('index_result_receiver_values'),
      jsonDecode(
        r'''[2,2,1,null,null,null,2,2,2,2,2,2,"1!","X",8,null,null,null,2,"SNA",["a","b","c","d"],null,"N",["a","b"],null,"SN",["a","b"],["zero","old"],null,null,0,["a","b"],{"a":"a","b":"b"}]''',
      ),
    );
  });
  test('null index results cannot revive an Array', () {
    assertConsumers(
      r'''Top:: I { return([].first().index_of("a").sorted()); }''',
      null,
    );
  });
}
