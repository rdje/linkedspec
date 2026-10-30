// TYPE-REFERENCE-BOOK.1.2.23.3.56.3.0 — cursor control arity before effects.
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
      'cursor-control-arity.spec',
    ),
  };
}

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

const controls = [
  'save_cursor',
  'restore_cursor',
  'rewind_entry_start',
  'rewind_match_start',
];
String carrier(String body, [String definitions = '']) =>
    '$definitions\nTop::\n -> Value[entry] {return(call(Value))}\nValue:\n entry=/ab/\n colon=/:/\n -> Value[colon] {$body}\n';

void positive(String label, String source, String input, Object? expected) {
  final observed = errorRows(source, input);
  print('CURSOR_ARITY_POSITIVE $label ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    expect(row.value, {'value': expected}, reason: row.key);
  }
}

void main() {
  for (final helper in controls) {
    test('rejects surplus arguments on $helper before effects', () {
      final forms = <(String, int)>[
        ('$helper(1)', 1),
        ('$helper(extra:1)', 1),
        ('$helper(1,2)', 2),
        ('$helper(trap())', 1),
        ('$helper(1)[0].coalesce("M")', 1),
      ];
      // Collect every route/form before any assertion, including the RED run.
      final observed = <Map<String, Object?>>[
        for (final form in forms)
          {
            'expression': form.$1,
            'count': form.$2,
            'routes': errorRows(
              carrier(
                'save_cursor();return([${form.$1},cursor_pos()])',
                'fn trap(){return(entry_text())}',
              ),
              'zzab:cd',
            ),
          },
        {
          'expression': 'absent-anchor $helper(1)',
          'count': 1,
          'routes': errorRows('Top:: I {return($helper(1))}', 'x'),
        },
      ];
      print(
        'CURSOR_ARITY_INVALID ${jsonEncode({'helper': helper, 'cases': observed})}',
      );
      for (final row in observed) {
        requireArity(
          (row['routes']! as Map).cast<String, Object?>(),
          helper,
          row['count']! as int,
        );
      }
    });
  }
  test('valid zero calls preserve Number null Unicode stack and absence', () {
    const body =
        'saved=save_cursor();before=cursor_pos();entry=rewind_entry_start();ep=cursor_pos();local_value=rewind_match_start();lp=cursor_pos();restored=restore_cursor();return([saved,before,entry,ep,local_value,lp,restored,cursor_pos()]);';
    positive('ascii', carrier(body), 'zzab:cd', [null, 5, 2, 2, 4, 4, null, 5]);
    positive('unicode', carrier(body), '🙂ab:cd', [
      null,
      4,
      1,
      1,
      3,
      3,
      null,
      4,
    ]);
    positive(
      'absent',
      'Top:: I {return([restore_cursor(),rewind_entry_start(),rewind_match_start(),cursor_pos(),save_cursor(),restore_cursor(),cursor_pos()])}',
      'x',
      [null, null, null, 0, null, null, 0],
    );
  });
  test('pure function parser state priority remains before arity', () {
    final observations = <Map<String, Object?>>[
      for (final helper in controls)
        for (final argument in ['1', 'trap()'])
          {
            'helper': helper,
            'argument': argument,
            'routes': errorRows(
              carrier(
                'return(denied())',
                'fn trap(){return(entry_text())}\nfn denied(){return($helper($argument))}',
              ),
              'zzab:cd',
            ),
          },
    ];
    print('CURSOR_ARITY_FUNCTION ${jsonEncode(observations)}');
    for (final item in observations) {
      for (final row in (item['routes']! as Map).values) {
        expect(
          (row as Map)['error'],
          allOf(
            contains('parser-state helper'),
            contains("'${item['helper']}'"),
            isNot(contains('helper_arity_mismatch')),
          ),
        );
      }
    }
  });
  test('trailing bodies retain existing compile rejection', () {
    final observed = <Map<String, Object?>>[];
    for (final helper in controls) {
      final expression = '$helper(){return(1)}';
      expect(
        (parseActionExpression(expression) as ActionCallExpr).trailingBlockArg,
        isTrue,
      );
      Object? compilation;
      try {
        routes(carrier('return($expression)'), 'zzab:cd');
      } catch (error) {
        compilation = {
          'error': error.toString(),
          'class': error.runtimeType.toString(),
        };
      }
      observed.add({'helper': helper, 'compile': compilation});
    }
    print('CURSOR_ARITY_TRAILING ${jsonEncode(observed)}');
    for (final item in observed) {
      expect(item['compile'], isNotNull);
      expect(
        (item['compile']! as Map)['error'],
        allOf(
          contains('callable_contract_rejected'),
          contains("helper '${item['helper']}'"),
          contains('does not declare a final codeblock parameter'),
        ),
      );
    }
  });
  test('unrelated function prefix and logical arity remain distinct', () {
    positive(
      'prefix',
      carrier(
        'return(rewind_entry_custom(2))',
        'fn rewind_entry_custom(value){return(value.add(1))}',
      ),
      'zzab:cd',
      3,
    );
    final observed = errorRows(carrier('return(and())'), 'zzab:cd');
    print('CURSOR_ARITY_LOGICAL ${jsonEncode(observed)}');
    for (final row in observed.values) {
      expect(
        (row! as Map)['error'],
        allOf(
          contains('helper_arity_mismatch'),
          contains('helper_name=and'),
          contains('at least 1 positional argument'),
        ),
      );
    }
  });
}
