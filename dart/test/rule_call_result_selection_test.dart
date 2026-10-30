// TYPE-REFERENCE-BOOK.1.2.23.3.54.3 — static child-return typed reads.
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
      'rule-call-selection.spec',
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
  print('RULE_CALL_SELECTION ${jsonEncode(observed)}');
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
  print('RULE_CALL_SELECTION_FENCE ${jsonEncode(observed)}');
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

void main() {
  test('frozen rule-call result selection target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/rule_call_selection_values.$extension',
      ),
    ).readAsStringSync();
    check(fixture('spec'), 'αβ:ENDTAIL', jsonDecode(fixture('json')));
  });
  test('selected child values preserve every ordinary kind', () {
    check(
      r'''
Top:: I {return([call(Child)[0],call(Child)[1],call(Child)[2],call(Child)[3],call(Child)[4],call(Child)[5]])}
Child: I {return([false,0,"0",undef,["a"],hash("name","b")])}
''',
      'x',
      [
        false,
        0,
        '0',
        null,
        ['a'],
        {'name': 'b'},
      ],
    );
  });
  test('scalar null empty and missing child results keep typed null reads', () {
    check(
      r'''
Top:: I {return([call(Text)[-1].coalesce("M"),call(Nothing)[0].coalesce("N"),call(Empty)[-1].coalesce("E"),call(Object)["missing"].coalesce("K")])}
Text: I {return("red:tail")}
Nothing: I {return(undef)}
Empty: I {return([])}
Object: I {return(hash())}
''',
      'x',
      ['M', 'N', 'E', 'K'],
    );
  });
  test('existing bound and method rule-call controls stay healthy', () {
    check(
      r'''
Top:: I {part=call(Child);return([part[-1].uppercase(),call(Child).last().uppercase()])}
Child: I {return(["red","tail"])}
''',
      'x',
      ['TAIL', 'TAIL'],
    );
  });
  test('bare child label keeps static lookup and signed read', () {
    check(
      r'''
Top:: I {Child="Wrong";return(call(Child)[-1].uppercase())}
Child: I {return(["red","tail"])}
Wrong: I {return(["wrong"])}
''',
      'x',
      'TAIL',
    );
  });
  test(
    'pure function call fence and explicit value arguments stay distinct',
    () {
      functionFence(r'''
fn forbidden(){return(call(Child)[-1].uppercase())}
Top:: I {return(forbidden())}
Child: I {return(["tail"])}
''', 'call');
      check(
        r'''
fn upper(text){return(text.uppercase())}
Top:: I {return(upper(call(Child)[-1]))}
Child: I {return(["red","tail"])}
''',
        'x',
        'TAIL',
      );
    },
  );
}
