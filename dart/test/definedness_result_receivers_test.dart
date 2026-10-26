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
      'definedness-result-receivers.spec',
    ),
    expected,
  );
}

void main() {
  test('definedness results retain scalar kinds, shapes and operand order', () {
    assertConsumers(
      fixture('definedness_result_receiver_values', 'spec'),
      jsonDecode(fixture('definedness_result_receiver_values', 'json')),
    );
  });
  test('free definedness keeps Boolean and scalar text domains', () {
    assertConsumers(
      r'''Top:: I { return([is_defined([].first()),is_undefined([].first()),is_defined(""),is_defined(false),is_defined(0),is_defined([]),is_defined({}),cat(is_defined([].first()),"!"),coalesce_nonempty(is_defined([].first()),"late"),true.is_defined(),false.is_defined(),undef.is_undefined()]) }''',
      [
        false,
        true,
        true,
        true,
        true,
        true,
        true,
        '0!',
        false,
        true,
        true,
        true,
      ],
    );
  });
}
