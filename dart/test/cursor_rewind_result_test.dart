// TYPE-REFERENCE-BOOK.1.2.23.3.56.3 — current cursor rewind Number results.
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
      'cursor-rewind-result.spec',
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
  print('CURSOR_REWIND $label ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    expect(row.value, {'ok': expected}, reason: row.key);
  }
}

void functionFence(String source, String helper) {
  final observed = <String, Object?>{};
  for (final route in routes(source, 'zzab:cd').entries) {
    try {
      observed[route.key] = {'unexpected_value': route.value()};
    } catch (error) {
      observed[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
      };
    }
  }
  print('CURSOR_REWIND_FENCE $helper ${jsonEncode(observed)}');
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

String carrier(String body, [String definitions = '']) =>
    '$definitions\nTop::\n -> Value[entry] {return(call(Value))}\nValue:\n entry=/ab/\n colon=/:/\n -> Value[colon] {$body}\n';

const primitiveBody =
    'save_cursor();p0=cursor_pos();v0=rewind_entry_start();p1=cursor_pos();v1=rewind_match_start();p2=cursor_pos();v2=restore_cursor();p3=cursor_pos();return([p0,v0,p1,v1,p2,v2,p3]);';

void main() {
  test('frozen qualified rewind result target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/cursor_rewind_result_values.$extension',
      ),
    ).readAsStringSync();
    check('shared', fixture('spec'), 'zzab:cd', jsonDecode(fixture('json')));
  });
  test('primitive Numbers retain live entry and local anchors', () {
    check('primitive_ascii', carrier(primitiveBody), 'zzab:cd', [
      5,
      2,
      2,
      4,
      4,
      null,
      5,
    ]);
  });
  test('primitive Numbers use character positions on Unicode input', () {
    check('primitive_unicode', carrier(primitiveBody), '🙂ab:cd', [
      4,
      1,
      1,
      3,
      3,
      null,
      4,
    ]);
  });
  test('bound and direct numeric text methods retain effects', () {
    check(
      'numeric',
      carrier(r'''
entry_value=rewind_entry_start();p1=cursor_pos();local_value=rewind_match_start();p2=cursor_pos();
return([entry_value.add(1).cat("!"),local_value.add(1),p1,p2,rewind_entry_start().add(1),rewind_match_start().add(1),cursor_pos()]);
'''),
      'zzab:cd',
      ['3!', 5, 2, 4, 3, 5, 4],
    );
  });
  test('defined zero and incompatible consumers skip operands', () {
    check(
      'zero_and_guards',
      carrier(r'''
order="";a=rewind_entry_start().coalesce({order=cat(order,"F");99}).add(1);
b=rewind_entry_start().take({order=cat(order,"A");1});
c=rewind_match_start().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");7});
return([a,b,c,order,cursor_pos()]);
'''),
      'ab:cd',
      [1, null, null, '', 2],
    );
  });
  test('pure function state fence and explicit Numbers stay distinct', () {
    for (final helper in ['rewind_entry_start', 'rewind_match_start']) {
      functionFence(
        carrier(
          'return(forbidden())',
          'fn forbidden(){return($helper().coalesce(99).add(1))}',
        ),
        helper,
      );
    }
    check(
      'explicit_number',
      carrier('return(inc(2))', 'fn inc(value){return(value.add(1))}'),
      'zzab:cd',
      3,
    );
  });
  test('physical rewinds and null save restore stay healthy', () {
    check(
      'physical',
      carrier(r'''
saved=save_cursor();rewind_entry_start();p1=cursor_pos();rewind_match_start();p2=cursor_pos();
restored=restore_cursor();return([saved,p1,p2,restored,cursor_pos()]);
'''),
      'zzab:cd',
      [null, 2, 4, null, 5],
    );
  });
  test('existing with and missing read Array bridges stay healthy', () {
    check(
      'bridges',
      carrier(r'''
return([rewind_entry_start().with(){return([value,"tail"])}[-1].uppercase(),
rewind_match_start()[0].coalesce(["a","tail"])[-1].uppercase(),cursor_pos()]);
'''),
      'zzab:cd',
      ['TAIL', 'TAIL', 4],
    );
  });
  test('absent anchors retain null and do not move', () {
    check(
      'absent',
      'Top:: I {return([rewind_entry_start(),rewind_match_start(),cursor_pos(),restore_cursor(),cursor_pos()])}',
      'x',
      [null, null, 0, null, 0],
    );
  });
  test('legacy malformed rewinds retain null pending separate arity repair', () {
    // No healthy arity credit; preserve the old producer until its owned repair.
    for (final entry in {
      'rewind_entry_start': 2,
      'rewind_match_start': 4,
    }.entries) {
      for (final argument in ['1', 'extra:1']) {
        check(
          'legacy_${entry.key}_$argument',
          carrier('return([${entry.key}($argument),cursor_pos()])'),
          'zzab:cd',
          [null, entry.value],
        );
      }
    }
  });
}
