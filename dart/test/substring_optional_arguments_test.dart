import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void assertConsumers(String source, Object? expected) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  expect(LinkedSpecRuntimeEngine(compiled).execute('x').value, expected);
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
      'substring-optional-arguments.spec',
    ),
    expected,
  );
}

void main() {
  test(
    'optional substring arguments and captured effects match the reference',
    () {
      final root = Directory.current.parent;
      String fixture(String extension) => File.fromUri(
        root.uri.resolve(
          'tests/fixtures/substring_optional_argument_values.$extension',
        ),
      ).readAsStringSync();
      assertConsumers(fixture('spec'), jsonDecode(fixture('json')));
    },
  );

  test('legacy free unary and extra argument paths retain their behavior', () {
    assertConsumers(
      r'''Top:: I { return([substr("abc"),substr("abc",true,true,"extra"),substr("abc",1,undef,"extra")]); }''',
      [null, '', 'bc'],
    );
  });
}
