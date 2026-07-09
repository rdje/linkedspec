import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('matches alternatives in seek or consume mode with stable identity', () {
    final alternation = RuntimeRegexAlternation.compile(['cat', 'dog']);

    final seek = alternation.match(
      'xx dog cat',
      0,
      parseMode: LinkedSpecParseMode.seek,
    )!;
    expect(seek.alternativeIndex, 1);
    expect(seek.text, 'dog');
    expect(seek.codeUnitStart, 3);

    expect(
      alternation.match(
        'xx dog cat',
        0,
        parseMode: LinkedSpecParseMode.consume,
      ),
      isNull,
    );

    final consume = alternation.match(
      'dog cat',
      0,
      parseMode: LinkedSpecParseMode.consume,
    )!;
    expect(consume.alternativeIndex, 1);
    expect(consume.text, 'dog');

    final tie = RuntimeRegexAlternation.compile(['c.t', 'cat']);
    expect(tie.seekMatch('cat', 0)!.alternativeIndex, 0);
  });

  test('matches regex lists carried by compiled rules', () {
    final compiled = compileSpec(parseSpec('Top::\n /cat/ /dog/'));
    final top = compiled.rule('Top')!;
    final alternation = RuntimeRegexAlternation.compile(top.regexPatterns);

    final match = alternation.seekMatch('xx dog cat', 0)!;

    expect(match.alternativeIndex, 1);
    expect(match.pattern, 'dog');
    expect(match.text, 'dog');
  });

  test('records capture groups, named captures, and char offsets', () {
    final input = 'e🙂 abc-42';
    final alternation = RuntimeRegexAlternation.compile([
      r'(?P<word>[a-z]+)-(\d+)',
    ]);

    final match = alternation.seekMatch(input, 0)!;

    expect(match.text, 'abc-42');
    expect(match.groups, ['abc-42', 'abc', '42']);
    expect(match.captures, ['abc', '42']);
    expect(match.namedCapture('word'), 'abc');
    expect(match.codeUnitStart, 4);
    expect(match.charStart, 3);
    expect(match.charLength, 6);
    expect(match.startLineColumn.toJson(), {'line': 1, 'column': 4});
  });

  test('keeps local and entry match registers separate', () {
    final alternation = RuntimeRegexAlternation.compile(['parent', 'child']);
    final parentMatch = alternation.consumeMatch('parent child', 0)!;
    final parentState = RuntimeMatchRegisters.empty(
      'parent child',
    ).withLocalMatch(parentMatch);

    final childEntry = parentState.enterChild();
    expect(childEntry.entryMatch!.text, 'parent');
    expect(childEntry.localMatch, isNull);

    final childMatch = alternation.consumeMatch(
      'parent child',
      'parent '.length,
    )!;
    final childState = childEntry.withLocalMatch(childMatch);

    expect(childState.entryMatch!.text, 'parent');
    expect(childState.localMatch!.text, 'child');
    expect(parentState.localMatch!.text, 'parent');
  });

  test('reports cursor position and zero-progress candidates', () {
    final input = 'a\n🙂b';
    final cursor = charOffsetToCodeUnitOffset(input, 3);
    final state = RuntimeMatchRegisters.empty(input, cursorCodeUnit: cursor);
    expect(state.cursorCharOffset, 3);
    expect(state.cursorLineColumn.toJson(), {'line': 2, 'column': 2});

    final empty = RuntimeRegexAlternation.compile([
      r'',
    ]).consumeMatch(input, 1)!;
    expect(empty.isZeroWidth, isTrue);
    expect(empty.isZeroProgressFrom(1), isTrue);
    expect(empty.madeProgressFrom(1), isFalse);

    final advanced = RuntimeRegexAlternation.compile([
      '🙂',
    ]).seekMatch(input, 0)!;
    final advancedState = RuntimeMatchRegisters.empty(
      input,
    ).withLocalMatch(advanced);
    expect(advancedState.zeroProgressSince(0), isFalse);
  });
}
