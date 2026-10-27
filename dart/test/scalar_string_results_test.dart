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
      'scalar-string-results.spec',
    ),
    expected,
  );
}

void main() {
  test(
    'basic scalar String producers retain Unicode strict null and eager order',
    () {
      assertConsumers(
        r'''Top:: I { source="a-b";order="";value=replace_substr({order=cat(order,"S");source},{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});return([[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")],[lowercase("ΟΣ"),uppercase("Straße ﬃ"),substr("a🙂b",1,1)],cat(undef,"x"),value,order,source]); }''',
        jsonDecode(
          r'''[["a","ab","AB","a_b","a","a","bc","ab"],["ος","STRASSE FFI","🙂"],null,"a_b","SON","changed"]''',
        ),
      );
    },
  );
  test(
    'identity producers preserve Number Boolean String and explicit null operands',
    () {
      assertConsumers(
        r'''Top:: I { return([replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(0,"x"),rm_prefix(false,"x"),rm_suffix(false,"x"),rm_prefix("0","x"),replace_substr("abc",undef,"x"),replace_substr("abc","a",undef),rm_prefix("abc",undef),rm_suffix("abc",undef)]); }''',
        [0, 0, 0, false, false, '0', null, null, null, null],
      );
    },
  );
  test('receiver scalar and shape boundaries preserve prefix effects', () {
    assertConsumers(
      r'''Top:: I { order="";value={order=cat(order,"S");" a "}.trim().cat({order=cat(order,"C");"!"}).take({order=cat(order,"A");1});bad_order="";bad={bad_order=cat(bad_order,"S");"a"}.replace_substr({bad_order=cat(bad_order,"A");"x"}).cat({bad_order=cat(bad_order,"C");"!"});return([value,order,bad,bad_order]); }''',
      [null, 'SC', null, ''],
    );
  });

  test(
    'existing scalar String producers preserve values Unicode identity and indices',
    () {
      assertConsumers(
        r'''Top:: I { raw=[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")];identity=[replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(false,"x")];values=["zero","one"];values[rm_prefix(0,"x")]="prefix";values[rm_suffix(1,"x")]="suffix";unicode=[lowercase("ΟΣ"),uppercase("Straße ﬃ"),substr("a🙂b",1,1)];source="a-b";order="";replaced=replace_substr({order=cat(order,"S");source},{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});return([raw,identity,values,unicode,replaced,order,source,cat(undef,"x")]); }''',
        jsonDecode(
          r'''[["a","ab","AB","a_b","a","a","bc","ab"],[0,0,false],["prefix","suffix"],["ος","STRASSE FFI","🙂"],"a_b","SON","changed",null]''',
        ),
      );
    },
  );
  test(
    'scalar String results preserve kinds bridges shapes and source snapshots',
    () {
      assertConsumers(
        fixture('scalar_string_result_receiver_values', 'spec'),
        jsonDecode(fixture('scalar_string_result_receiver_values', 'json')),
      );
    },
  );
  test(
    'substring guards preserve eager operands and Dart input-domain conventions',
    () {
      assertConsumers(
        r'''Top:: I { order="";source=substr({order=cat(order,"S");undef},{order=cat(order,"I");0},{order=cat(order,"L");1});start=substr("abc",undef);return([source,start,undef.substr(0),"abc".substr(undef),substr("abc",0,undef),order,substr("abc",1.5),substr("abc",-1,1),substr("abc",0,1.5),substr("abc",0,-1),substr("abc",true)]); }''',
        [null, null, null, null, 'abc', 'SIL', 'abc', 'a', '', '', 'abc'],
      );
    },
  );
  test('named target regex mutation keeps its dedicated overload', () {
    assertConsumers(
      r'''Top:: I { text="aba";substr(text,/a/,"x","g");other="aba";regex_subst(other,/a/,"y","");return([text,other]); }''',
      ['xbx', 'yba'],
    );
  });
}
