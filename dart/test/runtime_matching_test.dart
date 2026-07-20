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

  test(
    'matches one required duplicate alternative with its authored index',
    () {
      final alternation = RuntimeRegexAlternation.compile(['(a)', '(a)']);

      final first = alternation.matchAlternative(
        0,
        'aa',
        0,
        parseMode: LinkedSpecParseMode.consume,
      );
      final second = alternation.matchAlternative(
        1,
        'aa',
        1,
        parseMode: LinkedSpecParseMode.consume,
      );

      expect(first?.alternativeIndex, 0);
      expect(first?.captures, ['a']);
      expect(second?.alternativeIndex, 1);
      expect(second?.captures, ['a']);
      expect(second?.codeUnitStart, 1);
    },
  );

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

  test('normalizes shipped regex dialect forms for Dart RegExp', () {
    final portmap = RuntimeRegexAlternation.compile([
      r"([[:alpha:]]\w*)|(?i)(0x[0-9a-f]+|\d+\'\d+)",
    ]);
    expect(portmap.consumeMatch('0XFA', 0)!.text, '0XFA');
    expect(portmap.consumeMatch('Signal_1', 0)!.text, 'Signal_1');

    final ebnf = RuntimeRegexAlternation.compile([
      r'(?m)^\s*([[:alpha:]_]\w*)\s*:{,2}=',
    ]);
    final rule = ebnf.seekMatch('ignored\n_rule := value', 0)!;
    expect(rule.text, '_rule :=');
    expect(rule.captures, ['_rule']);

    final libReader = RuntimeRegexAlternation.compile([
      r'\b(\w+)\s*\(\s*((?s:.*?))\s*\)\s*\{',
    ]);
    final group = libReader.consumeMatch('group(first\nsecond){', 0)!;
    expect(group.captures, ['group', 'first\nsecond']);

    final possessive = RuntimeRegexAlternation.compile([r'(\w++)\s+[^}]++']);
    expect(possessive.consumeMatch('name value', 0)!.captures, ['name']);

    final escapedLiteral = RuntimeRegexAlternation.compile([r'\++']);
    expect(escapedLiteral.consumeMatch('+++', 0)!.text, '+++');

    final literalPosixText = RuntimeRegexAlternation.compile([r'\[:alpha:\]']);
    expect(literalPosixText.consumeMatch('[:alpha:]', 0)!.text, '[:alpha:]');
  });

  test('matches shipped structural PCRE forms with bounded parsers', () {
    final square = RuntimeRegexAlternation.compile([
      r'(\[(?:[^\[\]]++|(?R))+\])',
    ]);
    final bracket = square.consumeMatch('[x [y] z]', 0)!;
    expect(bracket.text, '[x [y] z]');
    expect(bracket.captures, ['[x [y] z]']);

    final ebnfArray = RuntimeRegexAlternation.compile([
      r'->\s*\K(?&array_structure)(?(DEFINE)(?<array_structure>\[(?&content)\])(?<object_structure>\{(?&content)\})(?<content>(?:[^{}\[\]]*|(?&array_structure)|(?&object_structure))*))',
    ]);
    final array = ebnfArray.seekMatch('rule -> [a {b [c]}]', 0)!;
    expect(array.text, '[a {b [c]}]');
    expect(array.codeUnitStart, 'rule -> '.length);

    final actionBlock = RuntimeRegexAlternation.compile([
      r'''->[ \t]*((?:\w+[ \t]*(?:\[[ \t]*\d+[ \t]*\][ \t]*)?)(?:[ \t]*\|[ \t]*\w+[ \t]*(?:\[[ \t]*\d+[ \t]*\][ \t]*)?)*)[ \t]*(?<blkAB>\{(?:[^{}"']++|"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|(?&blkAB))*\})''',
    ]);
    final action = actionBlock.consumeMatch(
      r'''-> Done { return("{not a brace}") }''',
      0,
    )!;
    expect(action.captures, ['Done ', r'''{ return("{not a brace}") }''']);
    expect(action.namedCapture('blkAB'), r'''{ return("{not a brace}") }''');

    final function = RuntimeRegexAlternation.compile([
      r'''fn[ \t]+([A-Za-z_]\w*)\s*\(([A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)?\)\s*(?<blkFN>\{(?:[^{}"']++|"(?:\\.|[^"])*+"|'(?:\\.|[^'])*+'|(?&blkFN))*+\})''',
    ]);
    final fn = function.consumeMatch(
      r'''fn norm(value) { return(trim(value)) }''',
      0,
    )!;
    expect(fn.captures, ['norm', 'value', '{ return(trim(value)) }']);

    final zero = function.consumeMatch(r'''fn zero() { return("zero") }''', 0)!;
    expect(zero.captures, ['zero', '', r'''{ return("zero") }''']);
    expect(zero.namedCapture('blkFN'), r'''{ return("zero") }''');

    final variadicFunction = RuntimeRegexAlternation.compile([
      r'''fn[ \t]+([A-Za-z_]\w*)\s*\((?:([A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)\s*,\s*)?\.\.\.([A-Za-z_]\w*)\)\s*(?<blkVFN>\{(?:[^{}"']+|"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|(?&blkVFN))*\})''',
    ]);
    final variadic = variadicFunction.consumeMatch(
      r'''fn collect(prefix, ...items) { return(items) }''',
      0,
    )!;
    expect(variadic.captures, [
      'collect',
      'prefix',
      'items',
      '{ return(items) }',
    ]);
    expect(variadic.namedCapture('blkVFN'), '{ return(items) }');

    final restOnly = variadicFunction.consumeMatch(
      r'''fn gather(...items) { return(items) }''',
      0,
    )!;
    expect(restOnly.captures, ['gather', '', 'items', '{ return(items) }']);
    expect(restOnly.namedCapture('blkVFN'), '{ return(items) }');
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
