import 'dart:convert';

import '../ast/spec_ast.dart';

final class SpecParseException implements Exception {
  const SpecParseException({required this.line, required this.message});

  final int line;
  final String message;

  @override
  String toString() {
    return 'SpecParseException(line $line): $message';
  }
}

SpecFile parseSpec(String source) {
  final lines = const LineSplitter().convert(source);
  final rules = <Rule>[];
  var index = _skipBlanksAndComments(lines, 0);

  while (index < lines.length) {
    final parsedHeader = _parseRuleHeader(lines, index);
    if (parsedHeader != null) {
      final header = parsedHeader.header;
      final rest = header.rest.trim();
      var bodyStartIndex = parsedHeader.nextIndex;
      var inlineElements = <BodyElement>[];

      if (rest.isNotEmpty) {
        final inlineCursor = _LineCursor(header.line - 1);
        final parsedInline = _parseInlineBody(
          rest,
          header.line,
          lines,
          inlineCursor,
        );
        if (parsedInline != null) {
          inlineElements = parsedInline;
          if (inlineCursor.index > bodyStartIndex) {
            bodyStartIndex = inlineCursor.index;
          }
        }
      }

      final collected = _collectBody(lines, bodyStartIndex);
      final body = <BodyElement>[...inlineElements, ...collected.body];
      rules.add(Rule(header: header, body: body));
      index = collected.nextIndex;
      continue;
    }

    if (rules.isEmpty) {
      throw SpecParseException(
        line: index + 1,
        message:
            'expected rule definition to start with a rule label '
            '(Word: or Word::), got: ${lines[index].trim()}',
      );
    }
    index += 1;
  }

  if (rules.isEmpty) {
    throw const SpecParseException(
      line: 1,
      message: 'no rule definitions found in spec',
    );
  }

  return SpecFile(rules: rules);
}

final class _LineCursor {
  _LineCursor(this.index);

  int index;
}

final class _ParsedHeader {
  const _ParsedHeader({required this.header, required this.nextIndex});

  final RuleHeader header;
  final int nextIndex;
}

final class _CollectedBody {
  const _CollectedBody({required this.body, required this.nextIndex});

  final List<BodyElement> body;
  final int nextIndex;
}

final class _ParsedElement {
  const _ParsedElement({
    required this.element,
    required this.remainder,
    required this.advanced,
  });

  final BodyElement element;
  final String remainder;
  final bool advanced;
}

final class _ConsumedBlock {
  const _ConsumedBlock({required this.code, required this.remainder});

  final String code;
  final String remainder;
}

final class _AttachedCode {
  const _AttachedCode({required this.code, required this.remainder});

  final String code;
  final String remainder;
}

final class _LifecycleFluentCode {
  const _LifecycleFluentCode({
    required this.code,
    required this.remainder,
    required this.advanced,
  });

  final String code;
  final String remainder;
  final bool advanced;
}

final class _FluentParse {
  const _FluentParse({required this.calls, required this.remainder});

  final List<FluentCall> calls;
  final String remainder;
}

final class _ParenContent {
  const _ParenContent({required this.content, required this.closeIndex});

  final String content;
  final int closeIndex;
}

final class _BoundedMode {
  const _BoundedMode({
    required this.base,
    required this.min,
    required this.max,
  });

  final String base;
  final int min;
  final int? max;
}

final _headerPattern = RegExp(r'^(\w+)[ \t]*(::|:)[ \t]*([^\s/]*)[ \t]*(.*)');
final _bodyHeaderPattern = RegExp(r'^\w+[ \t]*(::|:)[ \t]*\S*');
final _regexPattern = RegExp(r'^/([^/\\]*(?:\\.[^/\\]*)*)/');
final _actionPattern = RegExp(
  r'^->[ \t]*(\w+(?:[ \t]*\|[ \t]*\w+)*)((?:\[(\d+)\])?)',
);
final _blindPattern = RegExp(r'^=>[ \t]*(\w+)');
final _lifecyclePattern = RegExp(r'^(I|LS|LE|LX|E|EX|IT)\b');
final _splitPattern = RegExp(
  r'^@[ \t]*(capture_slice|capture_from_here|move_pos|mark[ \t]*\([ \t]*\w+[ \t]*\))',
);
final _conditionalPattern = RegExp(r'^-\?[ \t]+\w+');
final _fluentPattern = RegExp(r'^\.[ \t]*\w+');
final _boundedModePattern = RegExp(r'^(AND|OR)\{(\d*)(?:,(\d*))?\}$');

int _skipBlanksAndComments(List<String> lines, int index) {
  var next = index;
  while (next < lines.length) {
    final trimmed = lines[next].trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      next += 1;
    } else {
      break;
    }
  }
  return next;
}

_ParsedHeader? _parseRuleHeader(List<String> lines, int index) {
  if (index >= lines.length) {
    return null;
  }

  final trimmed = lines[index].trim();
  final match = _headerPattern.firstMatch(trimmed);
  if (match == null) {
    return null;
  }

  final label = match[1]!;
  final colon = match[2]!;
  final modeRaw = match[3]!;
  final restRaw = match[4]!;
  final parsedMode = _parseModeSuffixStrict(modeRaw);
  final RuleMode mode;
  final String rest;
  if (parsedMode == null) {
    rest = restRaw.isEmpty ? modeRaw : '$modeRaw $restRaw';
    mode = RuleMode.defaultMode;
  } else {
    rest = restRaw;
    mode = parsedMode;
  }

  return _ParsedHeader(
    header: RuleHeader(
      label: label,
      isTop: colon == '::',
      mode: mode,
      rest: rest,
      line: index + 1,
    ),
    nextIndex: index + 1,
  );
}

RuleMode? _parseModeSuffixStrict(String raw) {
  if (raw.isEmpty) {
    return RuleMode.defaultMode;
  }

  final bounded = _parseBounded(raw);
  if (bounded != null) {
    return switch (bounded.base) {
      'AND' => RuleMode.andBounded(min: bounded.min, max: bounded.max),
      'OR' => RuleMode.orBounded(min: bounded.min, max: bounded.max),
      _ => null,
    };
  }

  return switch (raw) {
    'AND' => RuleMode.and,
    'AND+' => RuleMode.andPlus,
    'OR' => RuleMode.or,
    'OR+' => RuleMode.orPlus,
    '&' => RuleMode.single,
    '|' => RuleMode.pipe,
    '+' => RuleMode.plus,
    '*' => RuleMode.star,
    '?' => RuleMode.optional,
    _ => null,
  };
}

_BoundedMode? _parseBounded(String raw) {
  final match = _boundedModePattern.firstMatch(raw);
  if (match == null) {
    return null;
  }

  final minText = match[2]!;
  final maxText = match[3];
  final min = minText.isEmpty ? 0 : int.tryParse(minText);
  if (min == null) {
    return null;
  }

  final int? max;
  if (maxText == null) {
    max = min;
  } else if (maxText.isEmpty) {
    max = null;
  } else {
    final parsedMax = int.tryParse(maxText);
    if (parsedMax == null || parsedMax < min) {
      return null;
    }
    max = parsedMax;
  }

  return _BoundedMode(base: match[1]!, min: min, max: max);
}

List<BodyElement>? _parseInlineBody(
  String rest,
  int lineNumber,
  List<String> lines,
  _LineCursor cursor,
) {
  final elements = <BodyElement>[];
  var remaining = rest.trim();

  while (remaining.isNotEmpty) {
    final trimmed = remaining.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      break;
    }

    final before = trimmed;
    final parsed = _parseSingleElement(trimmed, lines, cursor, lineNumber);
    if (parsed == null) {
      break;
    }
    elements.add(parsed.element);
    remaining = parsed.remainder;
    if (remaining.trim() == before) {
      break;
    }
  }

  return elements.isEmpty ? null : elements;
}

_CollectedBody _collectBody(List<String> lines, int start) {
  final body = <BodyElement>[];
  final cursor = _LineCursor(start);

  while (cursor.index < lines.length) {
    final trimmed = lines[cursor.index].trim();
    final lineNumber = cursor.index + 1;

    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      cursor.index += 1;
      continue;
    }

    if (_bodyHeaderPattern.hasMatch(trimmed)) {
      break;
    }

    final elements = _parseBodyElements(lines, cursor);
    _collectActionEdgeFluentContinuationLines(lines, cursor, elements);
    if (elements.isEmpty) {
      body.add(
        BodyElement(
          kind: RawBodyElementKind(text: trimmed),
          source: trimmed,
          line: lineNumber,
        ),
      );
      cursor.index += 1;
    } else {
      body.addAll(elements);
    }
  }

  return _CollectedBody(body: body, nextIndex: cursor.index);
}

void _collectActionEdgeFluentContinuationLines(
  List<String> lines,
  _LineCursor cursor,
  List<BodyElement> elements,
) {
  if (elements.isEmpty) {
    return;
  }

  final lastKind = elements.last.kind;
  if (lastKind is! ActionEdgeBodyElementKind) {
    return;
  }

  while (cursor.index < lines.length) {
    final trimmed = lines[cursor.index].trim();
    if (trimmed.isEmpty ||
        trimmed.startsWith('#') ||
        !trimmed.startsWith('.')) {
      break;
    }

    final parsed = _parseFluentChainWithRemainder(trimmed);
    final remainder = parsed.remainder.trim();
    if (parsed.calls.isEmpty ||
        (remainder.isNotEmpty && !remainder.startsWith('#'))) {
      break;
    }

    lastKind.fluentChain.addAll(parsed.calls);
    cursor.index += 1;
  }
}

List<BodyElement> _parseBodyElements(List<String> lines, _LineCursor cursor) {
  final elements = <BodyElement>[];
  final line = lines[cursor.index];
  final lineNumber = cursor.index + 1;
  var remaining = line.trim();
  var advancedPastCurrentLine = false;

  while (true) {
    final trimmed = remaining.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      break;
    }

    final parsed = _parseSingleElement(trimmed, lines, cursor, lineNumber);
    if (parsed == null) {
      break;
    }

    elements.add(parsed.element);
    remaining = parsed.remainder;
    if (parsed.advanced) {
      advancedPastCurrentLine = true;
    }
    if (remaining.trim().isEmpty) {
      break;
    }
  }

  if (elements.isNotEmpty && !advancedPastCurrentLine) {
    cursor.index += 1;
  }

  return elements;
}

_ParsedElement? _parseSingleElement(
  String trimmed,
  List<String> lines,
  _LineCursor cursor,
  int lineNumber,
) {
  final regexMatch = _regexPattern.firstMatch(trimmed);
  if (regexMatch != null) {
    final fullMatch = regexMatch[0]!;
    return _ParsedElement(
      element: BodyElement(
        kind: RegexBodyElementKind(pattern: regexMatch[1]!),
        source: fullMatch,
        line: lineNumber,
      ),
      remainder: trimmed.substring(fullMatch.length),
      advanced: false,
    );
  }

  final actionMatch = _actionPattern.firstMatch(trimmed);
  if (actionMatch != null) {
    final fullMatch = actionMatch[0]!;
    final targetsText = actionMatch[1]!;
    final index = int.tryParse(actionMatch[3] ?? '') ?? 0;
    final targets = [
      for (final target in targetsText.split('|').map((value) => value.trim()))
        if (target.isNotEmpty) EdgeTarget(label: target, index: index),
    ];
    final rest = trimmed.substring(fullMatch.length).trimLeft();
    final savedIndex = cursor.index;

    final attached = _parseAttachedFluentWhenChain(lines, cursor, rest);
    if (attached != null) {
      return _ParsedElement(
        element: BodyElement(
          kind: ActionEdgeBodyElementKind(
            targets: targets,
            code: attached.code,
          ),
          source: fullMatch,
          line: lineNumber,
        ),
        remainder: attached.remainder,
        advanced: cursor.index > savedIndex,
      );
    }

    if (rest.startsWith('{')) {
      final block = _consumeBlockFromRest(lines, cursor, rest);
      if (block == null) {
        return null;
      }
      return _ParsedElement(
        element: BodyElement(
          kind: ActionEdgeBodyElementKind(targets: targets, code: block.code),
          source: fullMatch,
          line: lineNumber,
        ),
        remainder: block.remainder,
        advanced: cursor.index > savedIndex,
      );
    }

    final fluent = _parseFluentChainWithRemainder(rest);
    return _ParsedElement(
      element: BodyElement(
        kind: ActionEdgeBodyElementKind(
          targets: targets,
          fluentChain: fluent.calls,
        ),
        source: fullMatch,
        line: lineNumber,
      ),
      remainder: fluent.remainder,
      advanced: false,
    );
  }

  final blindMatch = _blindPattern.firstMatch(trimmed);
  if (blindMatch != null) {
    final fullMatch = blindMatch[0]!;
    final target = blindMatch[1]!;
    final rest = trimmed.substring(fullMatch.length).trimLeft();
    final savedIndex = cursor.index;
    String? code;
    List<FluentCall> fluentChain;
    String remainder;

    if (rest.startsWith('{')) {
      final block = _consumeBlockFromRest(lines, cursor, rest);
      if (block == null) {
        return null;
      }
      code = block.code;
      fluentChain = <FluentCall>[];
      remainder = block.remainder;
    } else {
      final fluent = _parseFluentChainWithRemainder(rest);
      code = null;
      fluentChain = fluent.calls;
      remainder = fluent.remainder;
    }

    return _ParsedElement(
      element: BodyElement(
        kind: BlindEdgeBodyElementKind(
          target: target,
          code: code,
          fluentChain: fluentChain,
        ),
        source: fullMatch,
        line: lineNumber,
      ),
      remainder: remainder,
      advanced: cursor.index > savedIndex,
    );
  }

  final lifecycleMatch = _lifecyclePattern.firstMatch(trimmed);
  if (lifecycleMatch != null) {
    final fullMatch = lifecycleMatch[0]!;
    final marker = lifecycleMatch[1]!;
    final rest = trimmed.substring(fullMatch.length).trimLeft();
    final savedIndex = cursor.index;

    final attached = _parseAttachedFluentWhenChain(lines, cursor, rest);
    if (attached != null) {
      return _ParsedElement(
        element: BodyElement(
          kind: CodeBlockBodyElementKind(
            lifecycle: marker,
            code: attached.code,
          ),
          source: fullMatch,
          line: lineNumber,
        ),
        remainder: attached.remainder,
        advanced: cursor.index > savedIndex,
      );
    }

    if (rest.startsWith('{')) {
      final block = _consumeBlockFromRest(lines, cursor, rest);
      if (block == null) {
        return null;
      }
      return _ParsedElement(
        element: BodyElement(
          kind: CodeBlockBodyElementKind(lifecycle: marker, code: block.code),
          source: fullMatch,
          line: lineNumber,
        ),
        remainder: block.remainder,
        advanced: cursor.index > savedIndex,
      );
    }

    final fluent = _parseLifecycleFluentChainStatementCode(lines, cursor, rest);
    if (fluent != null) {
      return _ParsedElement(
        element: BodyElement(
          kind: CodeBlockBodyElementKind(lifecycle: marker, code: fluent.code),
          source: fullMatch,
          line: lineNumber,
        ),
        remainder: fluent.remainder,
        advanced: fluent.advanced,
      );
    }

    return _ParsedElement(
      element: BodyElement(
        kind: LifecycleMarkerBodyElementKind(marker: marker),
        source: fullMatch,
        line: lineNumber,
      ),
      remainder: rest,
      advanced: false,
    );
  }

  final splitMatch = _splitPattern.firstMatch(trimmed);
  if (splitMatch != null) {
    final fullMatch = splitMatch[0]!;
    return _ParsedElement(
      element: BodyElement(
        kind: SplitMarkerBodyElementKind(marker: fullMatch),
        source: fullMatch,
        line: lineNumber,
      ),
      remainder: trimmed.substring(fullMatch.length),
      advanced: false,
    );
  }

  final conditionalMatch = _conditionalPattern.firstMatch(trimmed);
  if (conditionalMatch != null) {
    final fullMatch = conditionalMatch[0]!;
    return _ParsedElement(
      element: BodyElement(
        kind: ConditionalBodyElementKind(word: fullMatch.substring(2).trim()),
        source: fullMatch,
        line: lineNumber,
      ),
      remainder: trimmed.substring(fullMatch.length),
      advanced: false,
    );
  }

  final fluentMatch = _fluentPattern.firstMatch(trimmed);
  if (fluentMatch != null) {
    final fullMatch = fluentMatch[0]!;
    return _ParsedElement(
      element: BodyElement(
        kind: FluentChainBodyElementKind(
          calls: _parseFluentChainWithRemainder(trimmed).calls,
        ),
        source: fullMatch,
        line: lineNumber,
      ),
      remainder: '',
      advanced: false,
    );
  }

  if (trimmed.startsWith('{')) {
    final savedIndex = cursor.index;
    final block = _consumeBlockFromRest(lines, cursor, trimmed);
    if (block == null) {
      return null;
    }
    return _ParsedElement(
      element: BodyElement(
        kind: PlainBlockBodyElementKind(code: block.code),
        source: trimmed,
        line: lineNumber,
      ),
      remainder: block.remainder,
      advanced: cursor.index > savedIndex,
    );
  }

  return null;
}

_ConsumedBlock? _consumeBlockFromRest(
  List<String> lines,
  _LineCursor cursor,
  String rest,
) {
  final startBrace = rest.indexOf('{');
  if (startBrace < 0) {
    return null;
  }

  final remainder = rest.substring(startBrace + 1);
  var depth = 1;
  var content = '';
  final firstScan = _scanLineForBraces(remainder, depth);
  depth = firstScan.depth;

  if (depth == 0) {
    final blockContent = firstScan.text.endsWith('}')
        ? firstScan.text.substring(0, firstScan.text.length - 1).trim()
        : firstScan.text.trim();
    return _ConsumedBlock(
      code: blockContent,
      remainder: remainder.substring(firstScan.text.length).trim(),
    );
  }

  if (firstScan.text.trim().isNotEmpty) {
    content = firstScan.text.trim();
  }

  cursor.index += 1;
  while (cursor.index < lines.length && depth > 0) {
    final line = lines[cursor.index];
    final scanned = _scanLineForBraces(line, depth);
    depth = scanned.depth;

    if (depth == 0) {
      final withoutClose = scanned.text.endsWith('}')
          ? scanned.text.substring(0, scanned.text.length - 1)
          : scanned.text;
      if (withoutClose.trim().isNotEmpty) {
        if (content.isNotEmpty) {
          content += '\n';
        }
        content += withoutClose.trim();
      }
      cursor.index += 1;
      return _ConsumedBlock(
        code: content.trim(),
        remainder: line.substring(scanned.text.length).trim(),
      );
    }

    if (content.isNotEmpty) {
      content += '\n';
    }
    content += line.trim();
    cursor.index += 1;
  }

  return _ConsumedBlock(code: content.trim(), remainder: '');
}

_AttachedCode? _parseAttachedFluentWhenChain(
  List<String> lines,
  _LineCursor cursor,
  String rest,
) {
  final afterWhen = _stripRequiredDotKeyword(rest, 'when');
  if (afterWhen == null) {
    return null;
  }

  var remaining = afterWhen.trimLeft();
  if (!remaining.startsWith('(')) {
    return null;
  }

  final condition = _extractParenContentWithEnd(remaining);
  if (condition == null) {
    return null;
  }
  remaining = remaining.substring(condition.closeIndex + 1).trimLeft();
  if (!remaining.startsWith('{')) {
    return null;
  }

  final whenStartIndex = cursor.index;
  final whenBody = _consumeBlockFromRest(lines, cursor, remaining);
  if (whenBody == null) {
    return null;
  }
  var code = 'when(${condition.content.trim()}) { ${whenBody.code.trim()} }';
  remaining = whenBody.remainder;
  var remainingOriginIndex = _blockRemainderOrigin(
    whenStartIndex,
    cursor.index,
    remaining,
  );

  while (true) {
    final afterOtherwise = _stripOptionalDotKeyword(remaining, 'otherwise');
    if (afterOtherwise == null) {
      break;
    }

    final remainderAfterOtherwise = afterOtherwise.trimLeft();
    if (!remainderAfterOtherwise.startsWith('{')) {
      break;
    }

    final blockOriginIndex = remainingOriginIndex;
    final currentFloorIndex = cursor.index;
    final blockCursor = _LineCursor(blockOriginIndex);
    final otherwiseBody = _consumeBlockFromRest(
      lines,
      blockCursor,
      remainderAfterOtherwise,
    );
    if (otherwiseBody == null) {
      break;
    }
    code += ' otherwise { ${otherwiseBody.code.trim()} }';
    remaining = otherwiseBody.remainder;
    cursor.index = blockCursor.index > currentFloorIndex
        ? blockCursor.index
        : currentFloorIndex;
    remainingOriginIndex = remaining.trim().isEmpty
        ? cursor.index
        : _blockRemainderOrigin(blockOriginIndex, blockCursor.index, remaining);
  }

  return _AttachedCode(code: code, remainder: remaining.trimLeft());
}

int _blockRemainderOrigin(int startIndex, int endIndex, String remainder) {
  if (remainder.trim().isNotEmpty && endIndex > startIndex) {
    return endIndex - 1;
  }
  return endIndex;
}

String? _stripRequiredDotKeyword(String text, String keyword) {
  final trimmed = text.trimLeft();
  if (!trimmed.startsWith('.')) {
    return null;
  }
  return _stripKeyword(trimmed.substring(1).trimLeft(), keyword);
}

String? _stripOptionalDotKeyword(String text, String keyword) {
  final trimmed = text.trimLeft();
  final candidate = trimmed.startsWith('.')
      ? trimmed.substring(1).trimLeft()
      : trimmed;
  return _stripKeyword(candidate, keyword);
}

String? _stripKeyword(String text, String keyword) {
  final trimmed = text.trimLeft();
  if (!trimmed.startsWith(keyword)) {
    return null;
  }
  final after = trimmed.substring(keyword.length);
  if (after.isNotEmpty) {
    final code = after.codeUnitAt(0);
    if (_isAsciiAlphaNumeric(code) || code == _underscore) {
      return null;
    }
  }
  return after;
}

_LifecycleFluentCode? _parseLifecycleFluentChainStatementCode(
  List<String> lines,
  _LineCursor cursor,
  String rest,
) {
  final startIndex = cursor.index;
  var text = rest.trimLeft();
  if (!text.startsWith('.')) {
    return null;
  }

  while (!_compactFluentChainParenthesesAreComplete(text)) {
    if (cursor.index + 1 >= lines.length) {
      return null;
    }
    cursor.index += 1;
    text = '$text\n${lines[cursor.index].trim()}';
  }

  final parsed = _parseFluentChainWithRemainder(text);
  final code = _fluentCallsToStatementCode(parsed.calls);
  if (code == null) {
    return null;
  }
  final advanced = cursor.index > startIndex;
  if (advanced) {
    cursor.index += 1;
  }
  return _LifecycleFluentCode(
    code: code,
    remainder: parsed.remainder,
    advanced: advanced,
  );
}

String? _fluentCallsToStatementCode(List<FluentCall> calls) {
  if (calls.isEmpty || calls.any((call) => call.method.trim().isEmpty)) {
    return null;
  }
  return calls
      .map((call) => '${call.method.trim()}(${call.args.trim()})')
      .join('; ');
}

bool _compactFluentChainParenthesesAreComplete(String text) {
  var position = _skipAsciiWhitespace(text, 0);
  if (!_hasCodeUnitAt(text, position, _dot)) {
    return true;
  }

  while (position < text.length) {
    position = _skipAsciiWhitespace(text, position);
    if (!_hasCodeUnitAt(text, position, _dot)) {
      return true;
    }
    position += 1;
    position = _skipAsciiWhitespace(text, position);
    final methodStart = position;
    while (position < text.length) {
      final code = text.codeUnitAt(position);
      if (!_isAsciiAlphaNumeric(code) && code != _underscore) {
        break;
      }
      position += 1;
    }
    if (position == methodStart) {
      return true;
    }

    position = _skipAsciiWhitespace(text, position);
    if (!_hasCodeUnitAt(text, position, _openParen)) {
      return true;
    }
    position += 1;
    var depth = 1;
    while (position < text.length) {
      final code = text.codeUnitAt(position);
      if (code == _doubleQuote || code == _singleQuote) {
        final next = _skipDelimitedLiteral(text, position, code);
        if (next == null) {
          return false;
        }
        position = next;
      } else if (code == _slash) {
        final next = _skipRegexLiteral(text, position);
        position = next ?? position + 1;
      } else if (code == _openParen) {
        depth += 1;
        position += 1;
      } else if (code == _closeParen) {
        depth -= 1;
        position += 1;
        if (depth == 0) {
          break;
        }
      } else {
        position += 1;
      }
    }
    if (depth != 0) {
      return false;
    }

    position = _skipAsciiWhitespace(text, position);
    if (!_hasCodeUnitAt(text, position, _dot)) {
      return true;
    }
  }

  return true;
}

_ScanResult _scanLineForBraces(String text, int initialDepth) {
  var depth = initialDepth;
  int? quote;
  var escaped = false;

  for (var index = 0; index < text.length; index += 1) {
    final code = text.codeUnitAt(index);
    if (quote != null) {
      if (escaped) {
        escaped = false;
        continue;
      }
      if (code == _backslash) {
        escaped = true;
        continue;
      }
      if (code == quote) {
        quote = null;
      }
      continue;
    }

    if (code == _doubleQuote || code == _singleQuote) {
      quote = code;
    } else if (code == _openBrace) {
      depth += 1;
    } else if (code == _closeBrace) {
      depth -= 1;
      if (depth == 0) {
        return _ScanResult(text: text.substring(0, index + 1), depth: depth);
      }
    }
  }

  return _ScanResult(text: text, depth: depth);
}

final class _ScanResult {
  const _ScanResult({required this.text, required this.depth});

  final String text;
  final int depth;
}

_FluentParse _parseFluentChainWithRemainder(String text) {
  final calls = <FluentCall>[];
  var remaining = text.trim();

  while (remaining.startsWith('.')) {
    remaining = remaining.substring(1);
    var nameEnd = 0;
    while (nameEnd < remaining.length) {
      final code = remaining.codeUnitAt(nameEnd);
      if (!_isAsciiAlphaNumeric(code) && code != _underscore) {
        break;
      }
      nameEnd += 1;
    }
    final method = remaining.substring(0, nameEnd);
    remaining = remaining.substring(nameEnd);

    if (remaining.startsWith('(')) {
      final paren = _extractParenContentWithEnd(remaining);
      if (paren != null) {
        remaining = remaining.substring(paren.closeIndex + 1).trimLeft();
        calls.add(FluentCall(method: method, args: paren.content));
      } else {
        calls.add(FluentCall(method: method, args: ''));
        remaining = '';
      }
    } else {
      calls.add(FluentCall(method: method, args: ''));
    }
  }

  return _FluentParse(calls: calls, remainder: remaining);
}

_ParenContent? _extractParenContentWithEnd(String text) {
  if (!text.startsWith('(')) {
    return null;
  }

  var depth = 0;
  for (var index = 0; index < text.length; index += 1) {
    final code = text.codeUnitAt(index);
    if (code == _openParen) {
      depth += 1;
    } else if (code == _closeParen) {
      depth -= 1;
      if (depth == 0) {
        return _ParenContent(
          content: text.substring(1, index),
          closeIndex: index,
        );
      }
    }
  }

  return null;
}

int _skipAsciiWhitespace(String text, int start) {
  var position = start;
  while (position < text.length) {
    final code = text.codeUnitAt(position);
    if (code != _space &&
        code != _tab &&
        code != _lineFeed &&
        code != _carriageReturn) {
      break;
    }
    position += 1;
  }
  return position;
}

int? _skipDelimitedLiteral(String text, int start, int delimiter) {
  var position = start + 1;
  while (position < text.length) {
    final code = text.codeUnitAt(position);
    if (code == _backslash) {
      position += 2;
      continue;
    }
    if (code == delimiter) {
      return position + 1;
    }
    position += 1;
  }
  return null;
}

int? _skipRegexLiteral(String text, int start) {
  var position = start + 1;
  while (position < text.length) {
    final code = text.codeUnitAt(position);
    if (code == _backslash) {
      position += 2;
      continue;
    }
    if (code == _slash) {
      position += 1;
      while (position < text.length &&
          _isAsciiAlphabetic(text.codeUnitAt(position))) {
        position += 1;
      }
      return position;
    }
    position += 1;
  }
  return null;
}

bool _hasCodeUnitAt(String text, int position, int expected) {
  return position < text.length && text.codeUnitAt(position) == expected;
}

bool _isAsciiAlphaNumeric(int code) {
  return _isAsciiAlphabetic(code) || (code >= _zero && code <= _nine);
}

bool _isAsciiAlphabetic(int code) {
  return (code >= _uppercaseA && code <= _uppercaseZ) ||
      (code >= _lowercaseA && code <= _lowercaseZ);
}

const _space = 0x20;
const _tab = 0x09;
const _lineFeed = 0x0a;
const _carriageReturn = 0x0d;
const _dot = 0x2e;
const _slash = 0x2f;
const _backslash = 0x5c;
const _singleQuote = 0x27;
const _doubleQuote = 0x22;
const _openParen = 0x28;
const _closeParen = 0x29;
const _openBrace = 0x7b;
const _closeBrace = 0x7d;
const _zero = 0x30;
const _nine = 0x39;
const _uppercaseA = 0x41;
const _uppercaseZ = 0x5a;
const _lowercaseA = 0x61;
const _lowercaseZ = 0x7a;
const _underscore = 0x5f;
