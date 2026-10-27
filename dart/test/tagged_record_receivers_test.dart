import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void assertRecords(String source, Object? expected) {
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
      'tagged-record-receivers.spec',
    ),
    expected,
  );
}

void main() {
  test('eager producer retains fields and current pure split boundaries', () {
    assertRecords(
      r'''Top:: I { counter=0;records=split_tagged_records("a,b,",",","row",set(counter,num_add(counter,1)),false,null,["x"],{"key":"v"});empty=split_tagged_records("",",","row",set(counter,num_add(counter,1)));return([records,empty,counter,split("a,b,",","),split("",",")]); }''',
      jsonDecode(
        r'''[[["row","a",1,false,null,["x"],{"key":"v"}],["row","b",1,false,null,["x"],{"key":"v"}],["row","",1,false,null,["x"],{"key":"v"}]],[["row","",2]],2,["a","b",""],[""]]''',
      ),
    );
  });
  test('String to tagged records and selected value chains', () {
    final root = Directory.current.parent;
    String fixture(String extension) => File.fromUri(
      root.uri.resolve(
        'tests/fixtures/tagged_record_receiver_values.$extension',
      ),
    ).readAsStringSync();
    assertRecords(fixture('spec'), jsonDecode(fixture('json')));
  });
  test('earlier carried values and row copies survive later writes', () {
    assertRecords(
      r'''Top:: I { carried=["x"];number=7;records=split_tagged_records("a,b",",","row",carried,number,{carried+="later";number=9;number});records[0][2][0]="changed";return([records,carried,number]); }''',
      jsonDecode(
        r'''[[["row","a",["changed"],7,9],["row","b",["x"],7,9]],["x","later"],9]''',
      ),
    );
  });
  test('receiver minimum shape rejects before source and operands', () {
    assertRecords(
      r'''Top:: I { order="";bad0={order=cat(order,"S");"a,b"}.split_tagged_records().count();bad1={order=cat(order,"S");"a,b"}.split_tagged_records({order=cat(order,"D");","}).take({order=cat(order,"C");1});return([bad0,bad1,order]); }''',
      [null, null, ''],
    );
  });
  test('short free calls retain empty arrays and eager operands', () {
    assertRecords(
      r'''Top:: I { order="";short=split_tagged_records({order=cat(order,"S");"a,b"},{order=cat(order,"D");","});return([split_tagged_records(),short,order]); }''',
      [<Object?>[], <Object?>[], 'SD'],
    );
  });
}
