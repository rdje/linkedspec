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
      'default-selected-receivers.spec',
    ),
    expected,
  );
}

void main() {
  test('default selections keep actual kinds, laziness and snapshots', () {
    assertConsumers(
      fixture('default_selected_receiver_values'),
      jsonDecode(
        r'''["A-B","A-B","A-B","X:Y","KEPT",null,null,null,"A-B",null,1,1,3,"0!","A-B","SDJ",["a","b","c"],"KEPT","",["a","b"],{"a":"x","b":"y"},"X:Y"]''',
      ),
    );
  });
  test('direct scalar selections reject container-only consumers', () {
    assertConsumers(
      r'''Top:: I { return(["kept".coalesce_nonempty(["a"]).sorted(), "".coalesce_nonempty("kept").sorted(), "kept".coalesce_nonempty({"k":1}).sorted_values()]); }''',
      [null, null, null],
    );
  });
  test(
    'existing default receiver values and lazy effects remain unchanged',
    () {
      assertConsumers(fixture('coalesce_receiver_values'), [
        'first',
        'CHOSEN',
        'SELECTED',
        'empty',
        0,
        false,
        null,
        'A',
        'ABCDEF',
      ]);
    },
  );
}
