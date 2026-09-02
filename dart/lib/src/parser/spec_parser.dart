import 'dart:convert';

import '../ast/spec_ast.dart';
import '../trace/trace.dart';
import 'unicode_rule_label.dart';

final class SpecParseException implements Exception {
  const SpecParseException({required this.line, required this.message});

  final int line;
  final String message;

  @override
  String toString() {
    return 'SpecParseException(line $line): $message';
  }
}

SpecFile parseSpec(
  String source, {
  String sourceId = 'inline',
  LinkedSpecTraceEmitter? trace,
}) {
  final traceScope = trace?.enterScope(
    'dart_frontend:parse_spec',
    'source_code_units=${source.length}',
    LinkedSpecTraceLevel.high,
  );
  try {
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

    trace?.traceDecision(
      'dart_frontend:parse_spec:rules',
      true,
      'rule_count=${rules.length}',
      LinkedSpecTraceLevel.medium,
    );
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'ok rule_count=${rules.length}');
    }
    return SpecFile(sourceId: sourceId, rules: rules);
  } on Object catch (error) {
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'error=$error');
    }
    rethrow;
  }
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
  const _ConsumedBlock({
    required this.code,
    required this.remainder,
    required this.source,
  });

  final String code;
  final String remainder;
  final String source;
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

final _regexPattern = RegExp(r'^/([^/\\]*(?:\\.[^/\\]*)*)/');
final _namedRegexPattern = RegExp(
  r'^([^/=]+?)[ \t]*=[ \t]*/([^/\\]*(?:\\.[^/\\]*)*)/',
);
final _lifecyclePattern = RegExp(r'^(I|LS|LE|LX|E|EX|IT)\b');
final _splitPattern = RegExp(
  r'^@[ \t]*(capture_slice|capture_from_here|move_pos|mark[ \t]*\([ \t]*\w+[ \t]*\))',
);
final _captureGapsPattern = RegExp(r'^@capture_gaps\b');
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
  final fields = _parseRuleHeaderFields(trimmed);
  if (fields == null) {
    return null;
  }

  final (:label, :isTop, :modeRaw, :restRaw) = fields;
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
      isTop: isTop,
      mode: mode,
      rest: rest,
      line: index + 1,
    ),
    nextIndex: index + 1,
  );
}

({String label, bool isTop, String modeRaw, String restRaw})?
_parseRuleHeaderFields(String input) {
  final scan = takeRuleLabelPrefix(input);
  if (scan == null) {
    return null;
  }
  var offset = scan.label.length;
  offset = _skipHorizontalSpace(input, offset);

  final bool isTop;
  if (input.startsWith('::', offset)) {
    isTop = true;
    offset += 2;
  } else if (input.startsWith(':', offset)) {
    isTop = false;
    offset += 1;
  } else {
    return null;
  }
  if (input.startsWith(':', offset)) {
    return null;
  }

  offset = _skipHorizontalSpace(input, offset);
  final modeStart = offset;
  while (offset < input.length) {
    final codeUnit = input.codeUnitAt(offset);
    if (_isHorizontalSpace(codeUnit) || codeUnit == _slash) {
      break;
    }
    offset += 1;
  }
  final modeRaw = input.substring(modeStart, offset);
  offset = _skipHorizontalSpace(input, offset);
  return (
    label: scan.label,
    isTop: isTop,
    modeRaw: modeRaw,
    restRaw: input.substring(offset),
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
    final parsed = _parseSingleElement(
      trimmed,
      lines,
      cursor,
      lineNumber,
      allowBareEdge: elements.isEmpty,
    );
    if (parsed == null) {
      if (elements.isEmpty ||
          _startsWithEdgeToken(trimmed) ||
          _isUnsupportedLifecycleRemainder(elements, trimmed)) {
        elements.add(
          BodyElement(
            kind: RawBodyElementKind(text: trimmed),
            source: trimmed,
            line: lineNumber,
          ),
        );
      }
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

    if (_parseRuleHeaderFields(trimmed) != null) {
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

    final parsed = _parseSingleElement(
      trimmed,
      lines,
      cursor,
      lineNumber,
      allowBareEdge: elements.isEmpty,
    );
    if (parsed == null) {
      if (elements.isEmpty ||
          _startsWithEdgeToken(trimmed) ||
          _isUnsupportedLifecycleRemainder(elements, trimmed)) {
        elements.add(
          BodyElement(
            kind: RawBodyElementKind(text: trimmed),
            source: trimmed,
            line: lineNumber,
          ),
        );
      }
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

bool _isUnsupportedLifecycleRemainder(
  List<BodyElement> elements,
  String remainder,
) {
  if (elements.isEmpty) {
    return false;
  }
  final kind = elements.last.kind;
  return kind is CodeBlockBodyElementKind &&
      kind.lifecycle == 'I' &&
      _parseRuleHeaderFields(remainder) == null;
}

_ParsedElement? _parseSingleElement(
  String trimmed,
  List<String> lines,
  _LineCursor cursor,
  int lineNumber, {
  required bool allowBareEdge,
}) {
  final namedRegexMatch = _namedRegexPattern.firstMatch(trimmed);
  if (namedRegexMatch != null) {
    final fullMatch = namedRegexMatch[0]!;
    return _ParsedElement(
      element: BodyElement(
        kind: RegexBodyElementKind(
          pattern: namedRegexMatch[2]!,
          slotId: namedRegexMatch[1]!.trim(),
        ),
        source: fullMatch,
        line: lineNumber,
      ),
      remainder: trimmed.substring(fullMatch.length),
      advanced: false,
    );
  }

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

  final actionPrefix = _parseActionEdgePrefix(trimmed);
  if (actionPrefix != null) {
    final fullMatch = trimmed.substring(0, actionPrefix.end);
    final targets = actionPrefix.targets;
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

  final blindPrefix = _parseBlindEdgePrefix(trimmed);
  if (blindPrefix != null) {
    final fullMatch = trimmed.substring(0, blindPrefix.end);
    final target = blindPrefix.target;
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
          index: blindPrefix.index,
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
      final suffix = trimmed.substring(fullMatch.length);
      final braceOffset = suffix.indexOf('{');
      return _ParsedElement(
        element: BodyElement(
          kind: CodeBlockBodyElementKind(lifecycle: marker, code: block.code),
          source:
              '$fullMatch${suffix.substring(0, braceOffset)}${block.source}',
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

  final captureGapsMatch = _captureGapsPattern.firstMatch(trimmed);
  if (captureGapsMatch != null) {
    final fullMatch = captureGapsMatch[0]!;
    return _ParsedElement(
      element: BodyElement(
        kind: const CaptureGapsDirectiveBodyElementKind(),
        source: fullMatch,
        line: lineNumber,
      ),
      remainder: trimmed.substring(fullMatch.length),
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
        kind: CodeBlockBodyElementKind(lifecycle: 'I', code: block.code),
        source: block.source,
        line: lineNumber,
      ),
      remainder: block.remainder,
      advanced: cursor.index > savedIndex,
    );
  }

  if (allowBareEdge) {
    final bare = _parseBareEdge(trimmed, lines, cursor, lineNumber);
    if (bare != null) {
      return bare;
    }
  }

  return null;
}

_ParsedElement? _parseBareEdge(
  String trimmed,
  List<String> lines,
  _LineCursor cursor,
  int lineNumber,
) {
  final prefix = _parseBareEdgePrefix(trimmed);
  if (prefix == null) {
    return null;
  }

  final fullMatch = trimmed.substring(0, prefix.end);
  final targets = prefix.targets;
  final rest = trimmed.substring(fullMatch.length).trimLeft();
  final savedIndex = cursor.index;

  if (rest.isEmpty || rest.startsWith('#')) {
    return _ParsedElement(
      element: BodyElement(
        kind: BareEdgeBodyElementKind(targets: targets),
        source: fullMatch,
        line: lineNumber,
      ),
      remainder: rest,
      advanced: false,
    );
  }

  if (rest.startsWith('{')) {
    final block = _consumeBlockFromRest(lines, cursor, rest);
    if (block == null) {
      return null;
    }
    return _ParsedElement(
      element: BodyElement(
        kind: BareEdgeBodyElementKind(targets: targets, code: block.code),
        source: fullMatch,
        line: lineNumber,
      ),
      remainder: block.remainder,
      advanced: cursor.index > savedIndex,
    );
  }

  if (rest.startsWith('.')) {
    final fluent = _parseFluentChainWithRemainder(rest);
    final remainder = fluent.remainder.trim();
    if (fluent.calls.isEmpty ||
        (remainder.isNotEmpty && !remainder.startsWith('#'))) {
      return null;
    }
    return _ParsedElement(
      element: BodyElement(
        kind: BareEdgeBodyElementKind(
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

  return null;
}

({List<EdgeTarget> targets, int end})? _parseActionEdgePrefix(String input) {
  if (!input.startsWith('->')) {
    return null;
  }
  var offset = _skipHorizontalSpace(input, 2);
  final labels = <String>[];
  while (true) {
    final target = _takeRuleLabelAt(input, offset);
    if (target == null) {
      return null;
    }
    labels.add(target.label);
    offset = target.end;

    final afterSpace = _skipHorizontalSpace(input, offset);
    if (!input.startsWith('|', afterSpace)) {
      break;
    }
    offset = _skipHorizontalSpace(input, afterSpace + 1);
    if (_takeRuleLabelAt(input, offset) == null) {
      return null;
    }
  }

  final selector = _parseActionSelectorAt(input, offset);
  final end = selector.end;
  if (!_hasValidEdgeRemainder(input, end)) {
    return null;
  }
  return (
    targets: [
      for (final label in labels)
        EdgeTarget(
          label: label,
          index: selector.index,
          selectorKind: selector.kind,
          authoredSelector: selector.authored,
        ),
    ],
    end: end,
  );
}

({String kind, Object? authored, int index, int end}) _parseActionSelectorAt(
  String input,
  int offset,
) {
  if (!input.startsWith('[', offset)) {
    return (kind: 'unindexed', authored: null, index: 0, end: offset);
  }

  final close = input.indexOf(']', offset + 1);
  final blockStart = input.indexOf('{', offset + 1);
  if (close >= 0 && (blockStart < 0 || close < blockStart)) {
    final authored = input.substring(offset + 1, close).trim();
    if (_isAsciiDigits(authored)) {
      final index = int.tryParse(authored);
      if (index != null) {
        return (kind: 'numeric', authored: index, index: index, end: close + 1);
      }
    }
    if (isRuleLabel(authored)) {
      return (kind: 'named', authored: authored, index: 0, end: close + 1);
    }
    return (kind: 'invalid', authored: authored, index: 0, end: close + 1);
  }

  var end = offset + 1;
  while (end < input.length) {
    final code = input.codeUnitAt(end);
    if (_isHorizontalSpace(code) || code == _openBrace) {
      break;
    }
    end += 1;
  }
  final authored = input.substring(offset + 1, end).trim();
  return (kind: 'invalid', authored: authored, index: 0, end: end);
}

({String target, int? index, int end})? _parseBlindEdgePrefix(String input) {
  if (!input.startsWith('=>')) {
    return null;
  }
  final label = _takeRuleLabelAt(input, _skipHorizontalSpace(input, 2));
  if (label == null) {
    return null;
  }
  final parsedIndex = _parseIndexAt(input, label.end, allowSpace: true);
  final end = parsedIndex?.end ?? label.end;
  if (!_hasValidEdgeRemainder(input, end)) {
    return null;
  }
  return (target: label.label, index: parsedIndex?.index, end: end);
}

({List<BareEdgeTarget> targets, int end})? _parseBareEdgePrefix(String input) {
  var offset = 0;
  final labels = <String>[];
  while (true) {
    final target = _takeRuleLabelAt(input, offset);
    if (target == null) {
      return null;
    }
    labels.add(target.label);
    offset = target.end;

    final afterSpace = _skipHorizontalSpace(input, offset);
    if (!input.startsWith('|', afterSpace)) {
      break;
    }
    offset = _skipHorizontalSpace(input, afterSpace + 1);
    if (_takeRuleLabelAt(input, offset) == null) {
      return null;
    }
  }

  final parsedIndex = _parseIndexAt(input, offset, allowSpace: true);
  final index = parsedIndex?.index;
  final end = parsedIndex?.end ?? offset;
  return (
    targets: [
      for (final label in labels) BareEdgeTarget(label: label, index: index),
    ],
    end: end,
  );
}

({String label, int end})? _takeRuleLabelAt(String input, int offset) {
  if (offset < 0 || offset > input.length) {
    return null;
  }
  final scan = takeRuleLabelPrefix(input.substring(offset));
  if (scan == null) {
    return null;
  }
  return (label: scan.label, end: offset + scan.label.length);
}

({int index, int end})? _parseIndexAt(
  String input,
  int offset, {
  required bool allowSpace,
}) {
  var cursor = allowSpace ? _skipHorizontalSpace(input, offset) : offset;
  if (!input.startsWith('[', cursor)) {
    return null;
  }
  cursor = _skipHorizontalSpace(input, cursor + 1);
  final digitsStart = cursor;
  while (cursor < input.length && _isAsciiDigit(input.codeUnitAt(cursor))) {
    cursor += 1;
  }
  if (cursor == digitsStart) {
    return null;
  }
  final index = int.tryParse(input.substring(digitsStart, cursor));
  if (index == null) {
    return null;
  }
  cursor = _skipHorizontalSpace(input, cursor);
  if (!input.startsWith(']', cursor)) {
    return null;
  }
  return (index: index, end: cursor + 1);
}

bool _hasValidEdgeRemainder(String input, int offset) {
  final remainder = input.substring(offset);
  if (remainder.isEmpty) {
    return true;
  }
  final beginsWithSpace = _isHorizontalSpace(remainder.codeUnitAt(0));
  final trimmed = remainder.trimLeft();
  if (trimmed.isEmpty || trimmed.startsWith('#')) {
    return true;
  }
  return trimmed.startsWith('{') ||
      trimmed.startsWith('.') ||
      trimmed.startsWith('->') ||
      trimmed.startsWith('=>') ||
      (beginsWithSpace &&
          (trimmed.startsWith('/') ||
              _lifecyclePattern.hasMatch(trimmed) ||
              _splitPattern.hasMatch(trimmed) ||
              _conditionalPattern.hasMatch(trimmed)));
}

int _skipHorizontalSpace(String input, int offset) {
  var cursor = offset;
  while (cursor < input.length &&
      _isHorizontalSpace(input.codeUnitAt(cursor))) {
    cursor += 1;
  }
  return cursor;
}

bool _isHorizontalSpace(int codeUnit) => codeUnit == _space || codeUnit == _tab;

bool _isAsciiDigit(int codeUnit) => codeUnit >= _zero && codeUnit <= _nine;

bool _isAsciiDigits(String value) {
  if (value.isEmpty) {
    return false;
  }
  for (final code in value.codeUnits) {
    if (!_isAsciiDigit(code)) {
      return false;
    }
  }
  return true;
}

bool _startsWithEdgeToken(String input) =>
    input.startsWith('->') || input.startsWith('=>');

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
  var source = rest.substring(startBrace);
  final firstScan = _scanLineForBraces(remainder, depth);
  depth = firstScan.depth;

  if (depth == 0) {
    final blockContent = firstScan.text.endsWith('}')
        ? firstScan.text.substring(0, firstScan.text.length - 1).trim()
        : firstScan.text.trim();
    return _ConsumedBlock(
      code: blockContent,
      remainder: remainder.substring(firstScan.text.length).trim(),
      source: source.substring(0, firstScan.text.length + 1),
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
    source += '\n${scanned.text}';

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
        source: source,
      );
    }

    if (content.isNotEmpty) {
      content += '\n';
    }
    content += line.trim();
    cursor.index += 1;
  }

  return _ConsumedBlock(code: content.trim(), remainder: '', source: source);
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
    remaining = remaining.substring(nameEnd).trimLeft();

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
