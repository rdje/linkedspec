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
      'logical-result-receivers.spec',
    ),
    expected,
  );
}

void main() {
  test(
    'logical producers retain Bool eager truth and strict numeric rejection',
    () {
      assertConsumers(
        r'''Top:: I { raw=[and(true),and(false),or(false,true),or(false,0),not(false),not(true)];nested=[cat(and(true),"!"),cat(and(false),"!"),cat(or(false,true),"!"),cat(or(false,0),"!"),cat(not(false),"!"),cat(not(true),"!")];truthiness=[and("0"),or("false"),not([]),not({}),not([undef]),not({"a":undef})];numeric=[num_add(and(true),1),num_add(or(false),1)];source=true;order="";effected=cat(and({order=cat(order,"L");source},{order=cat(order,"R");source=false;false}),{order=cat(order,"C");source=undef;"!"});return({"raw":raw,"nested":nested,"truthiness":truthiness,"numeric":numeric,"effected":effected,"order":order,"source":source}); }''',
        jsonDecode(
          r'''{"raw":[true,false,true,false,true,false],"nested":["1!","0!","1!","0!","1!","0!"],"truthiness":[true,true,true,true,false,false],"numeric":[null,null],"effected":"0!","order":"LRC","source":null}''',
        ),
      );
    },
  );
  for (final name in [
    'logical_result_receiver_values',
    'logical_rejected_consumer_effects',
  ]) {
    test('$name preserves actual kinds and effects', () {
      assertConsumers(fixture(name, 'spec'), jsonDecode(fixture(name, 'json')));
    });
  }
  test(
    'actual Boolean selections blocks and literals reject container consumers',
    () {
      assertConsumers(
        r'''Top:: I { return([[and(true)].first().sorted(),{or(false)}.sorted(),true.sorted()]) }''',
        [null, null, null],
      );
    },
  );
  for (final row in <(String, int, String)>[
    ('and', 0, 'and()'),
    ('or', 0, 'or()'),
    ('not', 0, 'not()'),
    ('not', 2, 'not({fail("must-not-run")},{fail("must-not-run")})'),
    (
      'not',
      2,
      'not({print("must-not-run");true},{print("must-not-run");false})',
    ),
  ]) {
    test(
      '${row.$1} source arity ${row.$2} retains typed errors for ${row.$3}',
      () {
        final source = 'Top:: I { return(${row.$3}.cat("!")) }';
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
