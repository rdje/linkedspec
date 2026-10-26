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
      'null-array-keys.spec',
    ),
    expected,
  );
}

void main() {
  test('null Array keys preserve positions kinds and value routes', () {
    assertConsumers(
      fixture('null_array_key_values', 'spec'),
      jsonDecode(fixture('null_array_key_values', 'json')),
    );
  });
  test('defined projections and absent free needles keep existing behavior', () {
    assertConsumers(
      r'''Top:: I { return({"membership":[contains([[]],""),contains([{}],""),contains([2],"2"),contains([false],0)],"indexes":[index_of([[]],""),index_of([{}],""),index_of([2],"2"),index_of([false],0)],"unique":uniq([[],"",{},2,"2",false,0]),"missing":[contains([undef]),index_of([undef])]}); }''',
      jsonDecode(
        r'''{"membership":[1,1,1,1],"indexes":[0,0,0,0],"unique":[[],2,false],"missing":[0,null]}''',
      ),
    );
  });
  test('null stays separate from unsupported defined projections', () {
    assertConsumers(
      r'''Top:: I { return([contains([[]],undef),contains([undef],[]),index_of([[]],undef),index_of([undef],[]),uniq([[],undef,""])]); }''',
      jsonDecode(r'''[0,0,null,null,[[],null]]'''),
    );
  });
}
