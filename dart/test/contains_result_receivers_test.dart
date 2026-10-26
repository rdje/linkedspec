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
      'contains-result-receivers.spec',
    ),
    expected,
  );
}

void main() {
  test('free contains retains numeric equality and captures source values', () {
    assertConsumers(
      r'''Top:: I { items=["a","b"]; raw=[contains(["a","b"],"a"),contains(["a","b"],"z"),contains([],"a"),contains([undef],undef),contains([undef],""),contains([""],undef),contains([""],""),contains([0],"0"),contains([false],0)]; order=""; value=contains(items,{order=cat(order,"O");items=["z"];"a"});missing=[].first(); missing_order=""; missing_value=contains(missing,{missing_order=cat(missing_order,"O");missing=["a"];"a"});return({"raw":raw,"snapshot_absent":[missing_value,missing_order,missing],"snapshot":[value,order,items],"text":[cat(contains(["a"],"z"),"!"),cat(coalesce_nonempty(contains(["a"],"z"),"late"),"!")]}) }''',
      jsonDecode(
        r'''{"raw":[1,0,0,1,0,0,1,1,1],"snapshot":[1,"O",["z"]],"snapshot_absent":[0,"O",["a"]],"text":["0!","0!"]}''',
      ),
    );
  });
  test('contains results retain kinds shapes and operand order', () {
    assertConsumers(
      fixture('contains_result_receiver_values', 'spec'),
      jsonDecode(fixture('contains_result_receiver_values', 'perl.json')),
    );
  });
}
