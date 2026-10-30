// TYPE-REFERENCE-BOOK.1.2.23.3.57.3 — existing gap Strings as guarded sources.
import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object? Function()> routes(String source, String input) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  return {
    'native': () => LinkedSpecRuntimeEngine(compiled).execute(input).value,
    'restored': () =>
        LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input).value,
    'plan': () => executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      input,
      'gap-string-result.spec',
    ),
  };
}

void check(String label, String source, String input, Object? expected) {
  final observed = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      observed[route.key] = {'ok': route.value()};
    } catch (error) {
      observed[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('GAP_STRING_RESULT $label ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    expect(row.value, {'ok': expected}, reason: row.key);
  }
}

void functionFence(String source, String helper) {
  final observed = <String, Object?>{};
  for (final route in routes(source, 'a,b;').entries) {
    try {
      observed[route.key] = {'unexpected_value': route.value()};
    } catch (error) {
      observed[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
      };
    }
  }
  print('GAP_STRING_RESULT_FENCE $helper ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    final value = row.value! as Map<String, Object?>;
    expect(value.keys, containsAll(['error', 'class']), reason: row.key);
    expect(
      value['error'],
      allOf(
        contains('parser-state helper'),
        contains('not supported in user functions'),
        contains("'$helper'"),
      ),
      reason: row.key,
    );
    expect(
      value['class'],
      row.key == 'plan'
          ? 'GeneratedSourceException'
          : 'RuntimeInterpreterException',
    );
  }
}

String carrier(
  String action, [
  String definitions = '',
  String pattern = '[^,;]+',
]) =>
    '$definitions\nList::\n @capture_gaps\n I {rows=[];order=""}\n -> Item[word] {$action}\n LX {return([rows,gap_text(),gap_kind(),order,cursor_pos()])}\nItem:\n word=/$pattern/\n I {return(entry_text())}\n';

Map<String, Object?> errorRows(String source, String input) {
  final actual = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      actual[route.key] = {'value': route.value()};
    } catch (error) {
      actual[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
        if (error is RuntimeInterpreterException)
          'diagnostic': error.diagnostic?.toJson(),
      };
    }
  }
  return actual;
}

void main() {
  test('frozen guarded gap String target', () {
    String fixture(String ext) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/gap_string_result_values.$ext',
      ),
    ).readAsStringSync();
    check('shared', fixture('spec'), 'a,b;', jsonDecode(fixture('json')));
  });
  test('primitive and bound direct compatible String methods stay healthy', () {
    check(
      'primitive',
      carrier('push(rows,[gap_text(),gap_kind(),call(Item)])'),
      'a,b;',
      [
        [
          ['', 'prefix', 'a'],
          [',', 'interstitial', 'b'],
        ],
        ';',
        'tail',
        '',
        3,
      ],
    );
    check(
      'compatible',
      carrier(
        r'''text=gap_text();kind=gap_kind();push(rows,[text.coalesce("F").cat("!"),gap_text().coalesce("F").cat("!"),kind.uppercase(),gap_kind().uppercase(),call(Item)])''',
      ),
      'a,b;',
      [
        [
          ['!', '!', 'PREFIX', 'PREFIX', 'a'],
          [',!', ',!', 'INTERSTITIAL', 'INTERSTITIAL', 'b'],
        ],
        ';',
        'tail',
        '',
        3,
      ],
    );
  });
  test('incompatible consumers return null before their operands', () {
    check(
      'guards',
      carrier(
        r'''a=gap_text().take({order=cat(order,"A");1});b=gap_kind().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});push(rows,[a,b,call(Item)])''',
      ),
      'a,b;',
      [
        [
          [null, null, 'a'],
          [null, null, 'b'],
        ],
        ';',
        'tail',
        '',
        3,
      ],
    );
  });
  test('both noncontainer reads recover Array Bool Number and String', () {
    check(
      'recovery',
      carrier(
        r'''push(rows,[gap_text()[0].coalesce(["a","tail"])[-1].uppercase(),gap_kind()["missing"].coalesce(false),gap_kind()[0].coalesce(0).add(1),gap_text()[0].coalesce("").cat("!"),call(Item)])''',
      ),
      'a,b;',
      [
        [
          ['TAIL', false, 1, '!', 'a'],
          ['TAIL', false, 1, '!', 'b'],
        ],
        ';',
        'tail',
        '',
        3,
      ],
    );
  });
  test('with returns actual container Bool kinds and restores outer value', () {
    check(
      'with_kinds',
      carrier(
        r'''value="outer";a=gap_text().with(){return([value,"tail"])}[-1].uppercase();b=gap_kind().with(){return({"k":[false]})}["k"][-1];push(rows,[a,b,value,call(Item)])''',
      ),
      'a,b;',
      [
        [
          ['TAIL', false, 'outer', 'a'],
          ['TAIL', false, 'outer', 'b'],
        ],
        ';',
        'tail',
        '',
        3,
      ],
    );
  });
  test('Unicode gap text retains character length', () {
    check(
      'unicode',
      carrier(
        r'''push(rows,[gap_text().length(),gap_text().cat("!"),call(Item)])''',
        '',
        '[ab]',
      ),
      'a🙂b;',
      [
        [
          [0, '!', 'a'],
          [1, '🙂!', 'b'],
        ],
        ';',
        'tail',
        '',
        3,
      ],
    );
  });
  test('unavailable context errors precede defaults', () {
    final observed = <Map<String, Object?>>[
      for (final helper in ['gap_text', 'gap_kind'])
        for (final suffix in ['', '.coalesce("M")'])
          {
            'helper': helper,
            'suffix': suffix,
            'routes': errorRows('Top:: I {return($helper()$suffix)}', 'x'),
          },
    ];
    print('GAP_STRING_CONTEXT ${jsonEncode(observed)}');
    for (final item in observed) {
      for (final route in (item['routes']! as Map).entries) {
        final row = route.value as Map;
        expect(row['error'], contains('gap_capture_context_unavailable'));
        expect(
          row['class'],
          route.key == 'plan'
              ? 'GeneratedSourceException'
              : 'RuntimeInterpreterException',
        );
        if (route.key != 'plan') {
          final diagnostic = row['diagnostic'] as Map;
          expect(diagnostic['code'], 'gap_capture_context_unavailable');
          expect(diagnostic['stage'], 'access_gap_context');
          expect(diagnostic['helper_name'], item['helper']);
        }
      }
    }
  });
  test('pure function primitive and computed reads stay forbidden', () {
    for (final helper in ['gap_text', 'gap_kind']) {
      for (final suffix in ['', '[0]']) {
        functionFence(
          carrier(
            'push(rows,[denied(),call(Item)])',
            'fn denied(){return($helper()$suffix.coalesce("M"))}',
          ),
          helper,
        );
      }
    }
    check(
      'explicit_args',
      carrier(
        'push(rows,[selected(gap_text(),gap_kind()),call(Item)])',
        r'''fn selected(text,kind){return([text.cat("!"),kind.uppercase()])}''',
      ),
      'a,b;',
      [
        [
          [
            ['!', 'PREFIX'],
            'a',
          ],
          [
            [',!', 'INTERSTITIAL'],
            'b',
          ],
        ],
        ';',
        'tail',
        '',
        3,
      ],
    );
  });
  test('malformed counts retain typed zero arity before context', () {
    final observed = <Map<String, Object?>>[
      for (final helper in ['gap_text', 'gap_kind'])
        for (final argument in ['1', 'extra:1'])
          {
            'helper': helper,
            'argument': argument,
            'routes': errorRows(
              'Top:: I {return($helper($argument)[0].coalesce("M"))}',
              'x',
            ),
          },
    ];
    print('GAP_STRING_ARITY ${jsonEncode(observed)}');
    for (final item in observed) {
      for (final route in (item['routes']! as Map).entries) {
        final row = route.value as Map;
        expect(
          row['error'],
          allOf(
            contains('helper_arity_mismatch'),
            contains('helper_name=${item['helper']}'),
            contains('actual_arity=1'),
          ),
        );
        if (route.key != 'plan') {
          final diagnostic = row['diagnostic'] as Map;
          expect(diagnostic['code'], 'helper_arity_mismatch');
          expect(diagnostic['helper_name'], item['helper']);
          expect(diagnostic['actual_arity'], 1);
          expect(
            diagnostic['expected_arity'],
            'exactly 0 positional arguments',
          );
        }
      }
    }
  });
}
