import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

String _source(String body) => 'Top::\n I { $body }\n';

void main() {
  test(
    'standalone transforms rebind while stored/receiver forms stay pure',
    () {
      final parsed = parseSpec(
        _source(r'''
      items=["a:b","a:a"]; saved=copy(items); calls=0;
      split_each(items,{ calls=num_add(calls,1); ":" }); split_snapshot=copy(items);
      filter_match(items,{ calls=num_add(calls,1); "^a$" }); filter_snapshot=copy(items);
      uniq(items); unique_snapshot=copy(items); items[0]="z";
      source=["b:b","a:a","b:b"];
      pure_split=split_each(source,":"); pure_filter=filter_match(source,/^a/);
      pure_unique=uniq(source); chain=source.split_each(":").filter_match(/^a$/).uniq();
      typed=[2,"2","x"]; filter_match(typed,/^2$/); uniq(typed);
      split_each(absent_split,":"); filter_match(absent_filter,/x/); uniq(absent_unique);
      return([items,saved,split_snapshot,filter_snapshot,unique_snapshot,calls,
        source,pure_split,pure_filter,pure_unique,chain,typed,
        absent_split,absent_filter,absent_unique]);
    '''),
      );
      const expected = [
        ['z'],
        ['a:b', 'a:a'],
        ['a', 'b', 'a', 'a'],
        ['a', 'a', 'a'],
        ['a'],
        2,
        ['b:b', 'a:a', 'b:b'],
        ['b', 'b', 'a', 'a', 'b', 'b'],
        ['a:a'],
        ['b:b', 'a:a'],
        ['a'],
        [2],
        <Object?>[],
        <Object?>[],
        <Object?>[],
      ];
      final compiled = compileSpec(parsed);
      expect(LinkedSpecRuntimeEngine(compiled).execute('x').value, expected);
      final restored = SpecFile.fromJson(
        (jsonDecode(jsonEncode(parsed.toJson())) as Map)
            .cast<String, Object?>(),
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
          'transform-writeback.spec',
        ),
        expected,
      );
    },
  );

  test('standalone transforms reject existing wrong-kind targets', () {
    for (final statement in [
      'split_each(target,":")',
      'filter_match(target,/x/)',
      'uniq(target)',
    ]) {
      final compiled = compileSpec(
        parseSpec(_source('target=7; $statement; return(target)')),
      );
      expect(
        () => LinkedSpecRuntimeEngine(compiled).execute('x'),
        throwsA(
          isA<RuntimeInterpreterException>().having(
            (error) => error.message,
            'typed target mismatch',
            contains(
              'binding_kind_mismatch identifier=target expected_kind=array actual_kind=scalar',
            ),
          ),
        ),
        reason: statement,
      );
    }
  });
}
