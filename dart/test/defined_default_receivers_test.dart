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
      'defined-default-receivers.spec',
    ),
    expected,
  );
}

void main() {
  test('existing defined defaults retain kinds laziness copies and indices', () {
    assertConsumers(
      r'''Top:: I { raw=[coalesce(undef,"fallback"),coalesce("","late"),coalesce(0,7),coalesce(false,true),coalesce(undef,undef),coalesce(undef,[2,3]),coalesce(undef,{"a":"a","b":"b"})];nested=[uppercase(trim(coalesce(undef," chosen "))),cat(coalesce(false,true),"!")];hits=0;lazy=coalesce("",{hits=num_add(hits,1);"late"},{target=1;target[0]=2;"bad"});items=["a","b"];chosen=coalesce(undef,items);items[0]="z";values=["zero","one"];values[coalesce(undef,1)]="updated";return([raw,nested,lazy,hits,chosen,items,values]); }''',
      jsonDecode(
        r'''[["fallback","",0,false,null,[2,3],{"a":"a","b":"b"}],["CHOSEN","0!"],"",0,["a","b"],["z","b"],["zero","updated"]]''',
      ),
    );
  });
  test(
    'defined default receivers preserve actual kinds lazy snapshots and boundaries',
    () {
      assertConsumers(
        fixture('defined_default_receiver_values', 'spec'),
        jsonDecode(fixture('defined_default_receiver_values', 'json')),
      );
    },
  );
  test(
    'selected scalar defaults and malformed shapes skip forbidden effects',
    () {
      assertConsumers(
        r'''Top:: I { order="";named=undef;flag=false;return([named.coalesce("kept").sorted(),[].first().coalesce("kept").sorted_values(),flag.coalesce(true).take({order=cat(order,"A");1}),{order=cat(order,"S");true}.coalesce().cat({order=cat(order,"C");"!"}),order]); }''',
        [null, null, null, null, ''],
      );
    },
  );
}
