// TYPE-REFERENCE-BOOK.1.2.23.3.53.3 — structural-boundary result methods composition.
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
      'boundary-capture-fluent.spec',
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
  print('BOUNDARY_CAPTURE ${jsonEncode(observed)}');
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
  print('BOUNDARY_CAPTURE_FENCE ${jsonEncode(observed)}');
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

String boundarySource(String body, [String end = 'END']) =>
    'Top::\n I {$body}\nEnd:OR{1,1}\n /$end/\nFar:OR{1,1}\n /TAIL/\n';
void main() {
  test('frozen structural boundary target', () {
    String fixture(String extension) => File.fromUri(
      Directory.current.parent.uri.resolve(
        'tests/fixtures/boundary_capture_fluent_values.$extension',
      ),
    ).readAsStringSync();
    check(fixture('spec'), 'αβ:ENDTAIL', jsonDecode(fixture('json')));
  });
  test('primitive bound direct and Number retain cursor rather than origin effects', () {
    for (final (body, expected) in <(String, Object?)>[
      (
        r"""return([capture_until_boundary(End),cursor_pos(),capture_slice_pos()])""",
        ['αβ:', 3, 0],
      ),
      (
        r"""part=capture_until_boundary(End);return([part.coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])""",
        ['αβ:!', 3, 0],
      ),
      (
        r"""return([capture_until_boundary(End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])""",
        ['αβ:!', 3, 0],
      ),
      (
        r"""return([capture_until_boundary(End).coalesce("").length().add(1),cursor_pos(),capture_slice_pos()])""",
        [4, 3, 0],
      ),
    ]) {
      check(boundarySource(body), 'αβ:ENDTAIL', expected);
    }
  });
  test('empty missing and EOF retain distinct native policies', () {
    check(
      boundarySource(
        r"""first=capture_until_boundary(End);order="";empty=capture_until_boundary(End).coalesce({order=cat(order,"F");"fallback"}).cat("!");return([first,empty,cursor_pos(),capture_slice_pos(),order])""",
      ),
      'αβ:ENDTAIL',
      ['αβ:', '!', 3, 0, ''],
    );
    check(
      boundarySource(
        r"""return([capture_until_boundary(Missing).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])""",
      ),
      'αβ:ENDTAIL',
      ['M!', 0, 0],
    );
    check(
      boundarySource(
        r"""return([capture_until_boundary(End).coalesce("").length().add(1),cursor_pos(),capture_slice_pos()])""",
        'ZZZ',
      ),
      'αβ:ENDTAIL',
      [11, 10, 0],
    );
  });
  test('quoted commas and multiple labels retain atom and earliest rules', () {
    final quoted =
        boundarySource(
          r"""return([capture_until_boundary("a,b,c",End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])""",
        ) +
        '\nb:OR{1,1}\n /αβ/\n';
    check(quoted, 'αβ:ENDTAIL', ['αβ:!', 3, 0]);
    check(
      boundarySource(
        r"""return([capture_until_boundary(Far,End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])""",
      ),
      'αβ:ENDTAIL',
      ['αβ:!', 3, 0],
    );
  });
  test('boundary source retains specific pure function state error', () {
    functionFence(
      'fn forbidden(){return(capture_until_boundary(End).coalesce("M").cat("!"))} ' +
          boundarySource('return(forbidden())'),
      'capture_until_boundary',
    );
  });
  test('callbacks retain caller cursor effects and function invocation fence', () {
    check(
      boundarySource(
        r"""cb={||return(capture_until_boundary(End).coalesce("M").cat("!"))};out=cb();return([out,cursor_pos(),capture_slice_pos()])""",
      ),
      'αβ:ENDTAIL',
      ['αβ:!', 3, 0],
    );
    functionFence(
      'fn apply(callback: codeblock){return(callback())} ' +
          boundarySource(
            r"""return(apply(){return(capture_until_boundary(End).coalesce("M").cat("!"))})""",
          ),
      'capture_until_boundary',
    );
  });
}
