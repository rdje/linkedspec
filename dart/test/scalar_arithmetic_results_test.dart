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
      'scalar-arithmetic-results.spec',
    ),
    expected,
  );
}

void main() {
  test('scalar arithmetic producers preserve kinds domains and snapshots', () {
    assertConsumers(
      r'''Top:: I { raw=[num_abs(-3),num_floor(3.7),num_ceil(3.2),num_round(2.5),num_add(2,3),num_sub(5,2),num_mul(2,3),num_div(7,2),num_mod(7,3),num_clamp(12,0,10),num_min(8,3),num_max(2,5)];aliases=[abs(-3),floor(3.7),ceil(3.2),round(2.5),add(2,3),sub(5,2),mul(2,3),div(7,2),mod(7,3),clamp(12,0,10),min(8,3),max(2,5)];symbols=[+(2,3),-(5,2),*(2,3),/(7,2),%(7,3)];invalid=[num_div(2,0),num_mod(2.5,2),num_clamp(2,3,1),num_add(false,1),num_add(undef,1),num_add("x",1),num_add([],1),num_add({},1)];text=[cat(num_add(2,3),"!"),cat(coalesce_nonempty(num_add(0,0),"late"),"!"),num_add(coalesce_nonempty(num_div(2,0),7),1),num_add("-.5",1)];source=2;order="";effected=cat(num_add({order=cat(order,"S");source},{order=cat(order,"O");source=9;3}),{order=cat(order,"C");source=undef;"!"});return({"raw":raw,"aliases":aliases,"symbols":symbols,"invalid":invalid,"text":text,"effected":effected,"order":order,"source":source}); }''',
      jsonDecode(
        r'''{"raw":[3,3,4,3,5,3,6,3.5,1,10,3,5],"aliases":[3,3,4,3,5,3,6,3.5,1,10,3,5],"symbols":[5,3,6,3.5,1],"invalid":[null,null,null,null,null,null,null,null],"text":["5!","0!",8,0.5],"effected":"5!","order":"SOC","source":null}''',
      ),
    );
  });
  test(
    'scalar arithmetic results preserve shapes bridges and operand order',
    () {
      assertConsumers(
        fixture('scalar_arithmetic_result_receiver_values', 'spec'),
        jsonDecode(fixture('scalar_arithmetic_result_receiver_values', 'json')),
      );
    },
  );
  test('scalar arithmetic and scalar min results remain Array write indexes', () {
    assertConsumers(
      r'''Top:: I { values=["zero","one","two","three"];values[2.add(1)]="first";values[8.min("3")]="updated";return(values) }''',
      ['zero', 'one', 'two', 'updated'],
    );
  });
  test('numeric String prefixes preserve arithmetic and comparison domains', () {
    assertConsumers(
      r'''Top:: I { return([" 2 ".trim().add(3).cat("!")," 2 ".trim().eq(2).cat("!")," X ".trim().eq(2).coalesce_nonempty(7).add(1)]) }''',
      ['5!', '1!', 8],
    );
  });
}
