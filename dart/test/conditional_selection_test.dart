// TYPE-REFERENCE-BOOK.1.2.23.3.26.3 — inline conditional result selection.
import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void assertSelection(String source, Object? expected) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  final observations = <String, Object?>{};
  for (final route in <String, Object? Function()>{
    'native': () => LinkedSpecRuntimeEngine(compiled).execute('x').value,
    'restored': () =>
        LinkedSpecRuntimeEngine(compileSpec(restored)).execute('x').value,
    'plan': () => executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      'x',
      'conditional-selection.spec',
    ),
  }.entries) {
    try {
      observations[route.key] = route.value();
    } catch (error) {
      observations[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('CONDITIONAL_SELECTION_OBSERVATIONS ${jsonEncode(observations)}');
  for (final route in observations.entries) {
    expect(route.value, expected, reason: route.key);
  }
}

void main() {
  test('unchanged frozen conditional target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/conditional_selection_values.$extension',
      ),
    ).readAsStringSync();
    assertSelection(fixture('spec'), jsonDecode(fixture('json')));
  });
  test('conditional with results reject incompatible operands', () {
    assertSelection(
      r'''Top:: I {
 order="";
 a=if(true,[false],[])[0].with() {return(value)}.take({order=cat(order,"A");1});
 b=switch("k",case("k",[[1]]))[0].set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});
 return([a,b,order]);
}''',
      [null, null, ''],
    );
  });
  test('lazy condition order and block local returns stay intact', () {
    assertSelection(
      r'''Top:: I {
 order="";
 selected=if({order=cat(order,"C");false},["bad"],
  elseif({order=cat(order,"E");true},{order=cat(order,"T");return([{"items":["a","b"]}]);order="bad"}),
  else({order=cat(order,"F");["bad"]}))[0]["items"][-1].uppercase().cat({order=cat(order,"M");"!"});
 return([selected,order]);
}''',
      ['B!', 'CETM'],
    );
  });
  test(
    'missing inline results versus legacy header alias bound flat counts',
    () {
      assertSelection(
        r'''Top:: I {
 thunk={|| return([false,["tail"]])};
 return([if(false,[1])[0].count(),switch("other",case("k",[1]))[0].count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),if(true)[0].count(),switch("k")[0].count(),flat([1])[9].count(),i(false,[1])[0].count()]);
}''',
        [null, null, false, 'TAIL', 0, 0, 0, 0, 0, 0],
      );
    },
  );
  test('parsed canonical header alias and attached roles remain distinct', () {
    final value =
        parseActionExpression('if(true,[1],[])[0]') as ActionValueAccessExpr;
    final call = value.receiver as ActionCallExpr;
    expect(call.name, 'if');
    expect(call.args.length, 3);
    expect(call.trailingBlockArg, isFalse);
    final header =
        parseActionExpression('if(true)[0]') as ActionValueAccessExpr;
    expect((header.receiver as ActionCallExpr).args.length, 1);
    final alias =
        parseActionExpression('i(false,[1])[0]') as ActionValueAccessExpr;
    final aliasCall = alias.receiver as ActionCallExpr;
    expect(aliasCall.sourceMethod ?? aliasCall.name, 'i');
    final attached =
        parseActionExpression('if(true) {return([1])}[0]')
            as ActionValueAccessExpr;
    expect((attached.receiver as ActionCallExpr).trailingBlockArg, isTrue);
  });
}
