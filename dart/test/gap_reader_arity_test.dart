// TYPE-REFERENCE-BOOK.1.2.23.3.55.0 — strict existing gap/slot reader arity.
import 'dart:convert';
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
      'gap-reader-arity.spec',
    ),
  };
}

void check(String source, String input, Object? expected) {
  final observed = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      observed[route.key] = {'ok': route.value()};
    } catch (error) {
      observed[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('GAP_READER_ARITY ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    expect(row.value, {'ok': expected}, reason: row.key);
  }
}

void functionFence(String source, String helper) {
  final observed = <String, Object?>{};
  for (final route in routes(source, 'x').entries) {
    try {
      observed[route.key] = {'unexpected_value': route.value()};
    } catch (error) {
      observed[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
      };
    }
  }
  print('GAP_READER_ARITY_FENCE ${jsonEncode(observed)}');
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

String gapSource(String definitions, String action, String item) =>
    '$definitions\nList::\n @capture_gaps\n I {rows=[]}\n -> Item[word] {$action}\n LX {return(rows)}\nItem:\n word=/[^,;]+/\n I {$item}\n';

Map<String, Object?> errorRows(String source, String input) {
  final observed = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      observed[route.key] = {'value': route.value()};
    } catch (error) {
      observed[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
        if (error is RuntimeInterpreterException)
          'diagnostic': error.diagnostic?.toJson(),
      };
    }
  }
  return observed;
}

void requireArity(Map<String, Object?> observed, String helper, int actual) {
  for (final route in observed.entries) {
    final row = route.value! as Map<String, Object?>;
    expect(row, contains('error'), reason: route.key);
    expect(
      row['error'],
      allOf(contains('helper_arity_mismatch'), contains('helper_name=$helper')),
      reason: route.key,
    );
    expect(
      row['class'],
      route.key == 'plan'
          ? 'GeneratedSourceException'
          : 'RuntimeInterpreterException',
    );
    if (route.key != 'plan') {
      final diagnostic = row['diagnostic']! as Map;
      expect(diagnostic['code'], 'helper_arity_mismatch');
      expect(diagnostic['stage'], 'helper_arity_mismatch');
      expect(diagnostic['helper_name'], helper);
      expect(diagnostic['actual_arity'], actual);
      expect(diagnostic['expected_arity'], 'exactly 0 positional arguments');
    }
  }
}

void main() {
  const readers = ['entry_slot', 'gap_span', 'gap_text', 'gap_kind'];
  for (final helper in readers) {
    test(
      'rejects positional and keyword surplus on $helper before context or operands',
      () {
        final definitions = 'fn trap(){return(gap_text())}';
        final forms = <Map<String, Object>>[
          {'expression': '$helper(1)', 'count': 1},
          {'expression': '$helper(extra:1)', 'count': 1},
          {'expression': '$helper(1,2)', 'count': 2},
          {'expression': '$helper(trap())', 'count': 1},
        ];
        final observed = <Map<String, Object?>>[
          for (final form in forms)
            {
              'expression': form['expression'],
              'count': form['count'],
              'routes': errorRows(
                gapSource(
                  definitions,
                  'push(rows,${form['expression']})',
                  'return(entry_text())',
                ),
                'a,b',
              ),
            },
          {
            'expression': 'outside-context $helper(1)',
            'count': 1,
            'routes': errorRows('Top:: I {return($helper(1))}', 'x'),
          },
          {
            'expression': 'field-default $helper(1)',
            'count': 1,
            'routes': errorRows(
              gapSource(
                '',
                'push(rows,$helper(1)["missing"].coalesce("M"))',
                'return(entry_text())',
              ),
              'a,b',
            ),
          },
        ];
        print(
          'GAP_READER_ARITY_INVALID ${jsonEncode({'helper': helper, 'cases': observed})}',
        );
        for (final row in observed) {
          requireArity(
            (row['routes']! as Map).cast<String, Object?>(),
            helper,
            row['count']! as int,
          );
        }
      },
    );
  }
  test(
    'zero argument readers retain full records kinds and direct slot absence',
    () {
      final slot = {
        'target_rule': 'Item',
        'regex_index': 0,
        'slot_id': 'word',
        'selector_kind': 'named',
        'authored_selector': 'word',
      };
      check(
        gapSource(
          '',
          'push(rows,[entry_slot(),gap_span(),gap_text(),gap_kind(),call(Item)])',
          'return(entry_slot())',
        ),
        'a,b',
        [
          [
            null,
            {'source_id': 'input', 'start': 0, 'end': 0, 'provenance': 'gap'},
            '',
            'prefix',
            slot,
          ],
          [
            null,
            {'source_id': 'input', 'start': 1, 'end': 2, 'provenance': 'gap'},
            ',',
            'interstitial',
            slot,
          ],
        ],
      );
      check('Top:: I {return(entry_slot())}', 'x', null);
    },
  );
  test(
    'valid zero argument gap calls retain typed unavailable context errors',
    () {
      for (final helper in readers.skip(1)) {
        final observed = errorRows('Top:: I {return($helper())}', 'x');
        print(
          'GAP_READER_CONTEXT ${jsonEncode({'helper': helper, 'routes': observed})}',
        );
        for (final route in observed.entries) {
          final row = route.value! as Map<String, Object?>;
          expect(row['error'], contains('gap_capture_context_unavailable'));
          if (route.key != 'plan') {
            final diagnostic = row['diagnostic']! as Map;
            expect(diagnostic['code'], 'gap_capture_context_unavailable');
            expect(diagnostic['stage'], 'access_gap_context');
            expect(diagnostic['helper_name'], helper);
          }
        }
      }
    },
  );
  test('pure function state fence still precedes gap reader arity', () {
    for (final helper in readers) {
      functionFence(
        'fn selected(){return($helper(1))}\nTop:: I {return(selected())}',
        helper,
      );
    }
  });
  test('trailing codeblocks retain existing compile contract rejection', () {
    for (final helper in readers) {
      final expression = '$helper() {return(1)}';
      final ast = parseActionExpression(expression) as ActionCallExpr;
      expect(ast.trailingBlockArg, isTrue);
      Object? observed;
      try {
        routes(
          gapSource('', 'push(rows,$expression)', 'return(entry_text())'),
          'a,b',
        );
      } catch (error) {
        observed = {
          'error': error.toString(),
          'class': error.runtimeType.toString(),
        };
      }
      print(
        'GAP_READER_TRAILING ${jsonEncode({'helper': helper, 'observation': observed})}',
      );
      expect(observed, isNotNull);
      final row = observed! as Map;
      expect(
        row['error'],
        allOf(
          contains('callable_contract_rejected'),
          contains("helper '$helper'"),
          contains('does not declare a final codeblock parameter'),
        ),
      );
    }
  });
  test('ordinary registered function arguments and own arity remain intact', () {
    check(
      'fn identity(value){return(value)}\nTop:: I {return([identity(false),identity(0),identity("x")])}',
      'x',
      [false, 0, 'x'],
    );
    final observed = errorRows(
      'fn identity(value){return(value)}\nTop:: I {return(identity())}',
      'x',
    );
    print('GAP_READER_FUNCTION_ARITY ${jsonEncode(observed)}');
    for (final row in observed.values) {
      expect(
        (row! as Map)['error'],
        allOf(
          contains("user function 'identity' expects 1 argument"),
          isNot(contains('helper_arity_mismatch')),
        ),
      );
    }
  });
}
