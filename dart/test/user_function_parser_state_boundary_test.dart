// TYPE-REFERENCE-BOOK.1.2.23.3.29.2.3 — accepted pure-function boundary.
import 'dart:convert';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object? Function()> routes(String source) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  return {
    'native': () =>
        LinkedSpecRuntimeEngine(compiled).execute('name=Alpha').value,
    'restored': () => LinkedSpecRuntimeEngine(
      compileSpec(restored),
    ).execute('name=Alpha').value,
    'plan': () => executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      'name=Alpha',
      'function-state-boundary.spec',
    ),
  };
}

String source(String definitions, String action) =>
    '$definitions\nTop::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {$action}\n';
void reject(String helper, String expression) {
  final spec = source(
    'fn forbidden(){return($expression)}',
    'return(forbidden())',
  );
  for (final route in routes(spec).entries) {
    expect(
      route.value,
      throwsA(
        predicate<Object>(
          (error) =>
              error.toString().contains('parser-state helper') &&
              error.toString().contains(helper),
        ),
      ),
      reason: '${route.key} $helper',
    );
  }
}

void main() {
  test('capture collection and group readers reject caller state', () {
    for (final helper in [
      'entry_groups',
      'match_groups',
      'entry_map',
      'match_map',
      'entry_named_map',
      'match_named_map',
      'entry_group',
      'match_group',
    ]) {
      reject(helper, '$helper(${helper.endsWith('group') ? '0' : ''})');
    }
  });
  test('input position mark capture and cursor roles reject', () {
    for (final entry in {
      'input_text': 'input_text()',
      'cursor_pos': 'cursor_pos()',
      'entry_start_pos': 'entry_start_pos()',
      'mark_pos': 'mark_pos(point)',
      'capture_slice': 'capture_slice()',
      'save_cursor': 'save_cursor(point)',
    }.entries) {
      reject(entry.key, entry.value);
    }
  });
  test('nested and discarded parser reads reject', () {
    final spec = source(
      'fn inner(){return(entry_groups())}\nfn outer(){match_map();return(inner())}',
      'return(outer())',
    );
    for (final route in routes(spec).entries) {
      expect(
        route.value,
        throwsA(
          predicate<Object>(
            (error) =>
                error.toString().contains('parser-state helper') &&
                error.toString().contains('match_map'),
          ),
        ),
        reason: route.key,
      );
    }
  });
  test('explicit caller values locals and prefix names remain valid', () {
    final spec = source(
      'fn entry_custom(text){local_text=text.uppercase();return(local_text)}\nfn capture_custom(text){return(entry_custom(text))}',
      'return([capture_custom(entry_group(0)),capture_custom(match_named("value")),entry_groups().last().uppercase(),match_map()["value"].uppercase()])',
    );
    for (final route in routes(spec).entries) {
      expect(route.value(), [
        ['NAME', 'ALPHA', 'NAME', 'ALPHA'],
      ], reason: route.key);
    }
  });
}
