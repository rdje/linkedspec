import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  final source = File('../specs/spec.spec').readAsStringSync();
  final parsed = parseSpec(source);
  final pattern = parsed
      .findRule('standalone_lifecycle_block')!
      .body
      .map((element) => element.kind)
      .whereType<RegexBodyElementKind>()
      .single
      .pattern;

  test('current bare-member grammar preserves cursor, captures and suffix', () {
    final matcher = RuntimeRegexAlternation.compile([pattern]);
    const prefix = 'Part:';
    const block = '{fake=/x/; text="}"; if(1) { value=2 }}';
    for (final whitespace in ['', ' ', '\t', '\r\n ', '\f']) {
      final input = '$prefix$whitespace${block}first=/a/';
      for (final mode in LinkedSpecParseMode.values) {
        final match = matcher.match(input, prefix.length, parseMode: mode)!;
        expect(match.codeUnitStart, prefix.length);
        expect(
          match.codeUnitEnd,
          prefix.length + whitespace.length + block.length,
        );
        expect(match.text, '$whitespace$block');
        expect(match.captures, [block]);
        expect(match.namedCapture('blkSLB'), block);
        expect(input.substring(match.codeUnitEnd), 'first=/a/');
      }
    }
    expect(matcher.consumeMatch('Part: {unclosed', prefix.length), isNull);
  });

  test('cursor alternative does not drift to an unrelated later brace', () {
    final matcher = RuntimeRegexAlternation.compile([pattern]);
    const blocked = 'Part: unknown {wrong=1}';
    expect(matcher.seekMatch(blocked, 5), isNull);
    expect(matcher.consumeMatch(blocked, 5), isNull);

    final input = '$blocked\r\n {right=2}next=/x/';
    final match = matcher.seekMatch(input, 5)!;
    expect(match.codeUnitStart, blocked.length + 2);
    expect(match.text, ' {right=2}');
    expect(match.captures, ['{right=2}']);
    expect(matcher.consumeMatch(input, 5), isNull);

    final raw = matcher.alternatives.single.regex;
    expect(
      raw
          .allMatches('Part: {a=1}{b=2} junk {wrong=3}\n {c=4}', 5)
          .map((match) => match.namedGroup('blkSLB')),
      ['{a=1}', '{b=2}', '{c=4}'],
    );
  });

  test(
    'current grammar retains exact same-line ASTs through Dart carriers',
    () {
      final manifest =
          jsonDecode(
                File(
                  '../docs/checkpoints/SESSION-STARTUP-READING.86.5.3-cli.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final compiled = compileSpec(parsed);
      final native = LinkedSpecRuntimeEngine(compiled);
      final reconstructed = LinkedSpecRuntimeEngine(
        compileSpec(
          SpecFile.fromJson(
            Map<String, Object?>.from(
              jsonDecode(jsonEncode(parsed.toJson())) as Map,
            ),
          ),
        ),
      );
      final plan = buildGeneratedRulePlan(compiled);
      for (final row in manifest['cases'] as List<dynamic>) {
        final input = (row['args'] as List<dynamic>).last as String;
        final expected = jsonDecode(row['expect']['stdout']['text'] as String);
        for (final text in [input, input.replaceAll('\n', '\r\n')]) {
          expect(
            native.execute(text).value,
            expected,
            reason: row['id'] as String,
          );
          expect(
            reconstructed.execute(text).value,
            expected,
            reason: row['id'] as String,
          );
          expect(
            executeGeneratedParserV2(
              compiled,
              plan,
              text,
              'same-line-grammar.spec',
            ),
            expected,
            reason: row['id'] as String,
          );
        }
      }
    },
  );
}
