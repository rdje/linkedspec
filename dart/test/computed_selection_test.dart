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
      'computed-selection.spec',
    ),
  }.entries) {
    try {
      observations[route.key] = route.value();
    } catch (error) {
      observations[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('COMPUTED_SELECTION_OBSERVATIONS ${jsonEncode(observations)}');
  for (final route in observations.entries) {
    expect(route.value, expected, reason: route.key);
  }
}

void main() {
  test(
    'postfix parser retains invalid terminal named and grouped boundaries',
    () {
      expect(parseActionExpression('"x".?'), isA<ActionRawExpr>());
      final rawReceiver =
          parseActionExpression('@host.trim()') as ActionFluentChainExpr;
      expect(rawReceiver.receiver, isA<ActionRawExpr>());
      expect(parseActionExpression('items[0]'), isA<ActionIndexedVarExpr>());
      expect(parseActionExpression('(array("a"))[0]'), isA<ActionRawExpr>());
      const source = '["🙂","b"][-1].uppercase()';
      final chain = parseActionExpression(source) as ActionFluentChainExpr;
      final read = chain.receiver as ActionValueAccessExpr;
      expect(read.source, '["🙂","b"][-1]');
      expect(read.sourceSpan.start, 0);
      expect(read.sourceSpan.end, read.source.length);
    },
  );
  test('unchanged complete computed-selection target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/computed_selection_values.$extension',
      ),
    ).readAsStringSync();
    assertSelection(fixture('spec'), jsonDecode(fixture('json')));
  });
  test('existing call results reject incompatible container operands', () {
    assertSelection(
      r'''Top:: I {
      order="";
      a=array(false)[0].take({order=cat(order,"A");1});
      b=array([1])[0].set_key({order=cat(order,"K");"a"},{order=cat(order,"V");2});
      c={order=cat(order,"S");"a,b"}.split(",").copy({order=cat(order,"A");1});
      return([a,b,c,order]);
    }''',
      [null, null, null, ''],
    );
  });
  test('function scopes snapshots and repeated selected bridges', () {
    assertSelection(
      r'''fn echo(value) {return(value)}
fn select(text) {position=-1;return(echo(text.split(","))[position].uppercase())}
Top:: I {
    position=9;order="";source=["old","tail"];
    selected=echo({order=cat(order,"S");source})[{order=cat(order,"I");source=["new"];-1}].uppercase().cat({order=cat(order,"C");"!"});
    return([selected,order,source,select("a,b"),position,
        [undef][0].coalesce([{"items":["a","b"]}])[0]["items"][-1].uppercase()]);
}''',
      [
        'TAIL!',
        'SIC',
        ['new'],
        'B',
        9,
        'B',
      ],
    );
  });
  test('scoped with retains selected kind through later consumers', () {
    assertSelection(
      r'''Top:: I {
      order="";
      a=array(false)[0].with() {return(value)}.take({order=cat(order,"A");1});
      b=array([2,1])[0].with() {return(value)}.sorted()[0].add(2);
      return([a,b,order]);
    }''',
      [null, 3, ''],
    );
  });
  test('bound-call signed reads kinds and missing counts remain', () {
    assertSelection(
      r'''Top:: I {
      thunk={|| return([false,["tail"]])};
      return([thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count()]);
    }''',
      [false, 'TAIL', 0, 0],
    );
  });
  test('regex split index and String methods preserve Unicode', () {
    assertSelection(
      r'''Top:: I {return(["αXβ".split(/[x]/i)[-1].uppercase(),split("aXb",/[x]/i)[1].uppercase()])}''',
      ['Β', 'B'],
    );
  });
}
