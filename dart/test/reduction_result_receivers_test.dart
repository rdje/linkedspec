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
      'reduction-result-receivers.spec',
    ),
    expected,
  );
}

void main() {
  test('admitted reduction producers retain actual accumulator kinds', () {
    assertConsumers(
      r'''Top:: I { return([[1,[2,3]].reduce_leaves(0) { return(acc.add(value)) },["a",["b"]].reduce_leaves("") { return(cat(acc,value)) },[1,[2,3]].reduce_leaves([]) { return(concat_arrays(acc,[value])) },[1].reduce_leaves({}) { return({"key":"B"}) },[].reduce_leaves(false) { return(true) },[1].reduce_leaves(0) { return(undef) },[].reduce_leaves(["empty"]) { return(value) },{"b":2,"a":1}.reduce_leaves(0) { return(acc.add(value)) }]); }''',
      jsonDecode(r'''[6,"ab",[1,2,3],{"key":"B"},false,null,["empty"],3]'''),
    );
  });
  test('admitted walk map and plain reduce preserve root shape and path order', () {
    assertConsumers(
      r'''Top:: I { original=[1,[2]];seen=[];walked=original.walk_leaves() {seen+=join_values("/",path);return(99)};mapped=original.map_leaves() {return(value.add(1))};meta={"b":{"y":2},"a":1,"arr":[9]};paths=[];hash=meta.walk_leaves() {paths+=join_values("/",path);return(0)};return([original,walked,mapped,seen,hash,paths,[1,[2]].reduce_leaves(0) {return(acc.add(value))}]); }''',
      jsonDecode(
        r'''[[1,[2]],[1,[2]],[2,[3]],["0","1/0"],{"b":{"y":2},"a":1,"arr":[9]},["a","arr","b/y"],3]''',
      ),
    );
  });
  test(
    'reduction actual results immediate traversals copies scopes and effects compose',
    () {
      final root = Directory.current.parent;
      String fixture(String extension) => File.fromUri(
        root.uri.resolve(
          'tests/fixtures/reduction_result_receiver_values.$extension',
        ),
      ).readAsStringSync();
      assertConsumers(fixture('spec'), jsonDecode(fixture('json')));
    },
  );
  test(
    'source initial callbacks and consumer retain source capture and order',
    () {
      assertConsumers(
        r'''Top:: I { items=[1,2];order="";calls=0;result={order=cat(order,"S");calls=num_add(calls,1);items}.reduce_leaves({order=cat(order,"I");items=[9];0}) {order=cat(order,"L");return(acc.add(value))}.cat({order=cat(order,"C");items=undef;"!"});return([result,order,calls,items]); }''',
        ['3!', 'SILLC', 1, null],
      );
    },
  );
  test('invalid reduction roots skip initial and callback effects', () {
    assertConsumers(
      r'''Top:: I { order="";result={order=cat(order,"S");"x"}.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(value)};other=undef.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(value)};return([result,other,order]); }''',
      [null, null, 'S'],
    );
  });
  test(
    'reduction container consumers reject the other family before operands',
    () {
      assertConsumers(
        r'''Top:: I { order="";a={order=cat(order,"S");[1]}.reduce_leaves({order=cat(order,"I");[]}) {order=cat(order,"L");return(acc)}.set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});first=[a,order];order="";b={order=cat(order,"S");[1]}.reduce_leaves({order=cat(order,"I");{}}) {order=cat(order,"L");return(acc)}.take({order=cat(order,"A");1});return([first,[b,order]]); }''',
        [
          [null, 'SIL'],
          [null, 'SIL'],
        ],
      );
    },
  );
  test('malformed reduction arity keeps compile-time signature errors', () {
    for (final source in [
      r'''Top:: I { return([1].reduce_leaves() {return(value)}.cat("!")); }''',
      r'''Top:: I { return([1].reduce_leaves(0,1) {return(value)}.cat("!")); }''',
    ]) {
      expect(
        () => compileSpec(parseSpecWithStagedUserFunctionDefinitions(source)),
        throwsA(
          isA<CompiledSpecException>().having(
            (error) => error.message,
            'message',
            contains('callable_contract_arity_mismatch'),
          ),
        ),
      );
    }
  });
}
