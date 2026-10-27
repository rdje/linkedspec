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

void assertMethods(String source, Object? expected) {
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
      'logical-receiver-methods.spec',
    ),
    expected,
  );
}

void main() {
  test('existing scalar Boolean copy policy is preserved', () {
    assertMethods(
      r'''Top:: I { return([and(true).copy(),true.copy(),copy(false)]); }''',
      [true, true, false],
    );
  });
  test('existing producers keep real Bool and typed truth', () {
    assertMethods(
      r'''Top:: I { return([and(true,false),or(false,true),not(false),not("0"),not(0),not([]),not([null]),not({}),not({"key":null})]); }''',
      [false, true, true, false, true, true, false, true, false],
    );
  });
  test('logical methods use actual sources RHS and result kinds', () {
    assertMethods(
      fixture('logical_receiver_method_values', 'spec'),
      jsonDecode(fixture('logical_receiver_method_values', 'json')),
    );
  });
  test('new method shape preflight skips all effects', () {
    assertMethods(
      r'''Top:: I { order="";a={order=cat(order,"S");true}.and().cat({order=cat(order,"C");"!"});b={order=cat(order,"S");false}.or().cat({order=cat(order,"C");"!"});c={order=cat(order,"S");false}.not({order=cat(order,"A");true}).cat({order=cat(order,"C");"!"});d={order=cat(order,"S");false}.not(fail("must-not-run"));return([a,b,c,d,order]); }''',
      [null, null, null, null, ''],
    );
  });
  test('logical prefixes retain effects and skip incompatible consumers', () {
    assertMethods(
      r'''Top:: I { order="";a={order=cat(order,"S");false}.and({order=cat(order,"R");true}).take({order=cat(order,"A");1});first=[a,order];order="";b={order=cat(order,"S");false}.or({order=cat(order,"R");true}).cat({order=cat(order,"C");"!"}).set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});return([first,[b,order]]); }''',
      [
        [null, 'SR'],
        [null, 'SRC'],
      ],
    );
  });
  test('existing with scope restores before logical result rejection', () {
    assertMethods(
      r'''Top:: I { value="outer";order="";a="x".with() {order=cat(order,"W");return(false)}.not();return([a,order,value]); }''',
      [true, 'W', 'outer'],
    );
    assertMethods(
      r'''Top:: I { value="outer";order="";a="x".with() {order=cat(order,"W");return(false)}.not().take({order=cat(order,"A");1});return([a,order,value]); }''',
      [null, 'W', 'outer'],
    );
  });
  test('existing with prefix keeps value copy and container recovery bounds', () {
    assertMethods(
      r'''Top:: I { scalar="x".with() {return(false)}.not().copy();hash="x".with() {return(false)}.not().add(1).coalesce({"key":7}).copy().sorted_values().first().add(1);array="x".with() {return(false)}.not().add(1).coalesce([7]).copy().first().add(1);return([scalar,hash,array]); }''',
      [true, 8, 8],
    );
  });
  for (final row in <(String, int, String)>[
    ('and', 0, 'and().not()'),
    ('not', 2, 'not({fail("must-not-run")},{fail("must-not-run")}).or(true)'),
  ]) {
    test(
      '${row.$1} source arity ${row.$2} retains typed errors for ${row.$3}',
      () {
        final source = 'Top:: I { return(${row.$3}) }';
        final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
        final restored = SpecFile.fromJson(
          (jsonDecode(jsonEncode(parsed.toJson())) as Map)
              .cast<String, Object?>(),
        );
        for (final spec in [parsed, restored]) {
          try {
            LinkedSpecRuntimeEngine(compileSpec(spec)).execute('x');
            fail('accepted invalid logical source arity');
          } on RuntimeInterpreterException catch (error) {
            final diagnostic = error.diagnostic?.toJson();
            expect(diagnostic, isNotNull);
            expect(diagnostic!['code'], 'helper_arity_mismatch');
            expect(diagnostic['helper_name'], row.$1);
            expect(diagnostic['actual_arity'], row.$2);
            expect(diagnostic['rule_label'], 'Top');
          }
        }
        final compiled = compileSpec(parsed);
        try {
          executeGeneratedParserV2(
            compiled,
            buildGeneratedRulePlan(compiled),
            'x',
            'logical-result-receivers.spec',
          );
          fail('generated plan accepted invalid logical source arity');
        } on GeneratedSourceException catch (error) {
          final diagnostic = error.toJson();
          expect(diagnostic['stage'], 'execute_generated');
          expect(diagnostic['detail'], contains('helper_arity_mismatch'));
          expect(diagnostic['detail'], contains('helper_name=${row.$1}'));
          expect(diagnostic['detail'], contains('actual_arity=${row.$2}'));
        }
      },
    );
  }
}
