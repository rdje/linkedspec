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
      'numeric-comparison-results.spec',
    ),
    expected,
  );
}

void main() {
  test('numeric comparison producers keep numeric kinds and strict domains', () {
    assertConsumers(
      r'Top:: I { raw=[num_eq(2,2),num_ne(2,3),num_gt(3,2),num_ge(2,2),num_lt(2,3),num_le(2,2),num_eq(2,3),num_ne(2,2),num_gt(2,3),num_ge(2,3),num_lt(3,2),num_le(3,2)];boundaries=[num_eq("02","2"),num_eq("-.5",-0.5),num_eq(undef,0),num_eq(false,0),num_eq(true,1),num_eq("",0),num_eq("x",0),num_eq([],0),num_eq({},0),num_eq(2),num_eq(2,2,2)];aliases=[eq(2,2),ne(2,2),gt(2,1),ge(2,2),lt(2,3),le(2,2),==(2,2),!=(2,2),>(2,1),>=(2,2),<(2,3),<=(2,2)];nested=[cat(num_eq(2,2),"!"),cat(coalesce_nonempty(num_eq(2,3),"late"),"!"),num_add(num_eq(2,3),2),uppercase(last(split(cat(num_eq(2,2),",x"),",")))];source=2;order="";effected=cat(num_eq({order=cat(order,"S");source},{order=cat(order,"O");source=3;2}),{order=cat(order,"C");source=undef;"!"});return({"raw":raw,"boundaries":boundaries,"aliases":aliases,"nested":nested,"effected":effected,"order":order,"source":source}); }'
      '',
      jsonDecode(
        r'{"raw":[1,1,1,1,1,1,0,0,0,0,0,0],"boundaries":[1,1,null,null,null,null,null,null,null,null,null],"aliases":[1,0,1,1,1,1,1,0,1,1,1,1],"nested":["1!","0!",2,"X"],"effected":"1!","order":"SOC","source":null}'
        '',
      ),
    );
  });
  test('numeric comparison results retain kinds shapes and operand order', () {
    assertConsumers(
      fixture('numeric_comparison_result_receiver_values', 'spec'),
      jsonDecode(fixture('numeric_comparison_result_receiver_values', 'json')),
    );
  });
  test('numeric comparison flags remain Array write indexes', () {
    assertConsumers(
      r'''Top:: I { score=2;values=["zero","one"];values[score.eq(2)]="updated";return(values) }''',
      ['zero', 'updated'],
    );
  });
}
