import '../ast/spec_ast.dart';

enum LinkedSpecParseMode {
  seek,
  consume;

  factory LinkedSpecParseMode.fromName(String name) {
    return switch (name) {
      'seek' => LinkedSpecParseMode.seek,
      'consume' => LinkedSpecParseMode.consume,
      _ => throw FormatException('unsupported parse mode $name'),
    };
  }

  String get jsonName {
    return switch (this) {
      LinkedSpecParseMode.seek => 'seek',
      LinkedSpecParseMode.consume => 'consume',
    };
  }
}

final class RuntimeRegexAlternation {
  RuntimeRegexAlternation._(this.alternatives);

  factory RuntimeRegexAlternation.compile(
    Iterable<String> patterns, {
    bool caseSensitive = true,
    bool multiLine = false,
    bool unicode = false,
    bool dotAll = false,
  }) {
    return RuntimeRegexAlternation._(
      List.unmodifiable([
        for (final (index, pattern) in patterns.indexed)
          RuntimeRegexAlternative(
            index: index,
            pattern: pattern,
            regex: compileRuntimeRegex(
              pattern,
              caseSensitive: caseSensitive,
              multiLine: multiLine,
              unicode: unicode,
              dotAll: dotAll,
            ),
          ),
      ]),
    );
  }

  final List<RuntimeRegexAlternative> alternatives;

  bool get isEmpty => alternatives.isEmpty;

  RuntimeRegexMatch? match(
    String input,
    int codeUnitCursor, {
    LinkedSpecParseMode parseMode = LinkedSpecParseMode.seek,
  }) {
    return switch (parseMode) {
      LinkedSpecParseMode.seek => seekMatch(input, codeUnitCursor),
      LinkedSpecParseMode.consume => consumeMatch(input, codeUnitCursor),
    };
  }

  /// Match only the required authored alternative while preserving its index.
  RuntimeRegexMatch? matchAlternative(
    int alternativeIndex,
    String input,
    int codeUnitCursor, {
    LinkedSpecParseMode parseMode = LinkedSpecParseMode.seek,
  }) {
    if (alternativeIndex < 0 || alternativeIndex >= alternatives.length) {
      throw RangeError.index(
        alternativeIndex,
        alternatives,
        'alternativeIndex',
      );
    }
    final alternative = alternatives[alternativeIndex];
    final cursor = _clampCodeUnitOffset(input, codeUnitCursor);
    final RegExpMatch? rawMatch;
    switch (parseMode) {
      case LinkedSpecParseMode.seek:
        rawMatch = alternative.regex.allMatches(input, cursor).firstOrNull;
      case LinkedSpecParseMode.consume:
        final prefix = alternative.regex.matchAsPrefix(input, cursor);
        rawMatch = prefix != null && prefix.start == cursor
            ? prefix as RegExpMatch
            : null;
    }
    if (rawMatch == null) {
      return null;
    }
    return RuntimeRegexMatch._fromRegExpMatch(
      input: input,
      alternativeIndex: alternative.index,
      pattern: alternative.pattern,
      regex: alternative.regex,
      match: rawMatch,
    );
  }

  RuntimeRegexMatch? seekMatch(String input, int codeUnitCursor) {
    final cursor = _clampCodeUnitOffset(input, codeUnitCursor);
    RuntimeRegexMatch? best;
    for (final alternative in alternatives) {
      final rawMatch = alternative.regex.allMatches(input, cursor).firstOrNull;
      if (rawMatch == null) {
        continue;
      }
      final candidate = RuntimeRegexMatch._fromRegExpMatch(
        input: input,
        alternativeIndex: alternative.index,
        pattern: alternative.pattern,
        regex: alternative.regex,
        match: rawMatch,
      );
      if (_isBetterSeekCandidate(candidate, best)) {
        best = candidate;
      }
    }
    return best;
  }

  RuntimeRegexMatch? consumeMatch(String input, int codeUnitCursor) {
    final cursor = _clampCodeUnitOffset(input, codeUnitCursor);
    for (final alternative in alternatives) {
      final rawMatch = alternative.regex.matchAsPrefix(input, cursor);
      if (rawMatch == null || rawMatch.start != cursor) {
        continue;
      }
      return RuntimeRegexMatch._fromRegExpMatch(
        input: input,
        alternativeIndex: alternative.index,
        pattern: alternative.pattern,
        regex: alternative.regex,
        match: rawMatch as RegExpMatch,
      );
    }
    return null;
  }

  JsonObject toJson() {
    return {
      'patterns': [for (final alternative in alternatives) alternative.pattern],
    };
  }
}

final class RuntimeRegexAlternative {
  const RuntimeRegexAlternative({
    required this.index,
    required this.pattern,
    required this.regex,
  });

  final int index;
  final String pattern;
  final RegExp regex;
}

final class RuntimeRegexMatch {
  RuntimeRegexMatch._({
    required this.input,
    required this.alternativeIndex,
    required this.pattern,
    required this.codeUnitStart,
    required this.codeUnitEnd,
    required this.groups,
    required this.captures,
    required List<int> captureGroupIndices,
    required int captureRegexOptions,
    required this.named,
  }) : _captureGroupIndices = captureGroupIndices,
       _captureRegexOptions = captureRegexOptions;

  factory RuntimeRegexMatch.reindexed(
    RuntimeRegexMatch match,
    int alternativeIndex,
  ) {
    return RuntimeRegexMatch._(
      input: match.input,
      alternativeIndex: alternativeIndex,
      pattern: match.pattern,
      codeUnitStart: match.codeUnitStart,
      codeUnitEnd: match.codeUnitEnd,
      groups: match.groups,
      captures: match.captures,
      captureGroupIndices: match._captureGroupIndices,
      captureRegexOptions: match._captureRegexOptions,
      named: match.named,
    );
  }

  factory RuntimeRegexMatch._fromRegExpMatch({
    required String input,
    required int alternativeIndex,
    required String pattern,
    required RegExp regex,
    required RegExpMatch match,
  }) {
    final groups = <String>[];
    final captures = <String>[];
    final captureGroupIndices = <int>[];
    for (var index = 0; index <= match.groupCount; index += 1) {
      final value = match.group(index);
      if (index == 0) {
        groups.add(value ?? '');
        continue;
      }
      if (value != null) {
        captures.add(value);
        captureGroupIndices.add(index);
      }
      groups.add(value ?? '');
    }

    final named = <String, String>{};
    for (final name in match.groupNames) {
      final value = match.namedGroup(name);
      if (value != null) {
        named[name] = value;
      }
    }

    return RuntimeRegexMatch._(
      input: input,
      alternativeIndex: alternativeIndex,
      pattern: pattern,
      codeUnitStart: match.start,
      codeUnitEnd: match.end,
      groups: List.unmodifiable(groups),
      captures: List.unmodifiable(captures),
      captureGroupIndices: List.unmodifiable(captureGroupIndices),
      captureRegexOptions: _runtimeRegexOptions(regex),
      named: Map.unmodifiable(named),
    );
  }

  final String input;
  final int alternativeIndex;
  final String pattern;
  final int codeUnitStart;
  final int codeUnitEnd;
  final List<String> groups;
  final List<String> captures;
  final List<int> _captureGroupIndices;
  final int _captureRegexOptions;
  List<({int start, int end})?>? _stagedCaptureSpanCache;
  final Map<String, String> named;

  String get text => groups.firstOrNull ?? '';
  int get codeUnitLength => codeUnitEnd - codeUnitStart;
  int get charStart => codeUnitOffsetToCharOffset(input, codeUnitStart);
  int get charEnd => codeUnitOffsetToCharOffset(input, codeUnitEnd);
  int get charLength => charEnd - charStart;
  bool get isZeroWidth => codeUnitStart == codeUnitEnd;

  LineColumn get startLineColumn {
    return lineColumnAtCodeUnitOffset(input, codeUnitStart);
  }

  String? namedCapture(String name) => named[name];

  bool madeProgressFrom(int codeUnitCursor) {
    return codeUnitEnd > _clampCodeUnitOffset(input, codeUnitCursor);
  }

  bool isZeroProgressFrom(int codeUnitCursor) {
    return codeUnitEnd == _clampCodeUnitOffset(input, codeUnitCursor);
  }

  JsonObject toJson() {
    final lineColumn = startLineColumn;
    return {
      'alternative_index': alternativeIndex,
      'pattern': pattern,
      'text': text,
      'code_unit_start': codeUnitStart,
      'code_unit_end': codeUnitEnd,
      'code_unit_length': codeUnitLength,
      'char_start': charStart,
      'char_end': charEnd,
      'char_length': charLength,
      'line': lineColumn.line,
      'column': lineColumn.column,
      'groups': groups,
      'captures': captures,
      'named': named,
      'zero_width': isZeroWidth,
    };
  }
}

/// Returns one live-regex-proven participating-capture range for the private
/// staged-provenance carrier, or `null` when bounded instrumentation cannot
/// preserve and prove the original match.
///
/// This internal module function deliberately is not exported by the package
/// umbrella. Existing match JSON and public capture helpers remain unchanged.
({int start, int end})? stagedCaptureCodeUnitSpan(
  RuntimeRegexMatch match,
  int compactCaptureIndex,
) {
  if (compactCaptureIndex < 0 || compactCaptureIndex >= match.captures.length) {
    return null;
  }
  final spans = match._stagedCaptureSpanCache ??= List.unmodifiable(
    _recoverCaptureCodeUnitSpans(
      pattern: match.pattern,
      input: match.input,
      matchStart: match.codeUnitStart,
      matchEnd: match.codeUnitEnd,
      matchText: match.text,
      regexOptions: match._captureRegexOptions,
      captureGroupIndices: match._captureGroupIndices,
      captures: match.captures,
    ),
  );
  return spans[compactCaptureIndex];
}

final class _CapturePatternGroup {
  const _CapturePatternGroup({
    required this.index,
    required this.contentStart,
    required this.close,
  });

  final int index;
  final int contentStart;
  final int close;
}

final class _OpenPatternGroup {
  const _OpenPatternGroup({
    required this.captureIndex,
    required this.contentStart,
  });

  final int? captureIndex;
  final int? contentStart;
}

List<({int start, int end})?> _recoverCaptureCodeUnitSpans({
  required String pattern,
  required String input,
  required int matchStart,
  required int matchEnd,
  required String matchText,
  required int regexOptions,
  required List<int> captureGroupIndices,
  required List<String> captures,
}) {
  final unavailable = List<({int start, int end})?>.filled(
    captures.length,
    null,
  );
  if (captures.isEmpty) {
    return unavailable;
  }
  final groups = _parseCapturePatternGroups(pattern);
  if (groups == null) {
    return unavailable;
  }
  final byIndex = <int, _CapturePatternGroup>{
    for (final group in groups) group.index: group,
  };
  final result = <({int start, int end})?>[];
  for (var index = 0; index < captures.length; index += 1) {
    final group = byIndex[captureGroupIndices[index]];
    if (group == null) {
      return unavailable;
    }
    final span = _instrumentedCaptureSpan(
      pattern: pattern,
      group: group,
      input: input,
      matchStart: matchStart,
      matchEnd: matchEnd,
      matchText: matchText,
      regexOptions: regexOptions,
    );
    if (span == null ||
        input.substring(span.start, span.end) != captures[index]) {
      return unavailable;
    }
    result.add(span);
  }
  return result;
}

({int start, int end})? _instrumentedCaptureSpan({
  required String pattern,
  required _CapturePatternGroup group,
  required String input,
  required int matchStart,
  required int matchEnd,
  required String matchText,
  required int regexOptions,
}) {
  var startName = 'lsStagedStart${group.index}';
  var endName = 'lsStagedEnd${group.index}';
  while (pattern.contains('?<$startName>') || pattern.contains('?<$endName>')) {
    startName = '${startName}x';
    endName = '${endName}x';
  }
  final startProbe = '(?=(?<$startName>[\\s\\S]*))';
  final endProbe = '(?=(?<$endName>[\\s\\S]*))';
  final instrumented =
      '${pattern.substring(0, group.contentStart)}'
      '$startProbe${pattern.substring(group.contentStart, group.close)}'
      '$endProbe${pattern.substring(group.close)}';
  try {
    final instrumentedRegex = compileRuntimeRegex(
      instrumented,
      caseSensitive: regexOptions & 1 != 0,
      multiLine: regexOptions & 2 != 0,
      unicode: regexOptions & 4 != 0,
      dotAll: regexOptions & 8 != 0,
    );
    final raw = instrumentedRegex.matchAsPrefix(input, matchStart);
    if (raw is! RegExpMatch ||
        raw.start != matchStart ||
        raw.end != matchEnd ||
        raw.group(0) != matchText) {
      return null;
    }
    final startSuffix = raw.namedGroup(startName);
    final endSuffix = raw.namedGroup(endName);
    if (startSuffix == null || endSuffix == null) {
      return null;
    }
    final start = input.length - startSuffix.length;
    final end = input.length - endSuffix.length;
    if (start < matchStart || end < start || end > matchEnd) {
      return null;
    }
    return (start: start, end: end);
  } on FormatException {
    return null;
  }
}

int _runtimeRegexOptions(RegExp regex) {
  return (regex.isCaseSensitive ? 1 : 0) |
      (regex.isMultiLine ? 2 : 0) |
      (regex.isUnicode ? 4 : 0) |
      (regex.isDotAll ? 8 : 0);
}

List<_CapturePatternGroup>? _parseCapturePatternGroups(String pattern) {
  final completed = <_CapturePatternGroup>[];
  final stack = <_OpenPatternGroup>[];
  var captureIndex = 0;
  var escaped = false;
  var inClass = false;
  for (var index = 0; index < pattern.length; index += 1) {
    final char = pattern[index];
    if (escaped) {
      if (!inClass && RegExp(r'[1-9]').hasMatch(char)) {
        return null;
      }
      escaped = false;
      continue;
    }
    if (char == r'\') {
      escaped = true;
      continue;
    }
    if (char == '[' && !inClass) {
      inClass = true;
      continue;
    }
    if (char == ']' && inClass) {
      inClass = false;
      continue;
    }
    if (inClass) {
      continue;
    }
    if (char == '(') {
      final contentStart = _captureGroupContentStart(pattern, index);
      final currentCaptureIndex = contentStart == null ? null : ++captureIndex;
      stack.add(
        _OpenPatternGroup(
          captureIndex: currentCaptureIndex,
          contentStart: contentStart,
        ),
      );
      continue;
    }
    if (char != ')') {
      continue;
    }
    if (stack.isEmpty) {
      return null;
    }
    final open = stack.removeLast();
    if (open.captureIndex != null) {
      completed.add(
        _CapturePatternGroup(
          index: open.captureIndex!,
          contentStart: open.contentStart!,
          close: index,
        ),
      );
    }
  }
  if (escaped || inClass || stack.isNotEmpty) {
    return null;
  }
  completed.sort((left, right) => left.index.compareTo(right.index));
  return completed;
}

int? _captureGroupContentStart(String pattern, int openIndex) {
  if (openIndex + 1 >= pattern.length || pattern[openIndex + 1] != '?') {
    return openIndex + 1;
  }
  if (openIndex + 2 >= pattern.length) {
    return null;
  }
  final marker = pattern[openIndex + 2];
  final named =
      marker == '<' ||
      (marker == 'P' &&
          openIndex + 3 < pattern.length &&
          pattern[openIndex + 3] == '<');
  if (!named) {
    return null;
  }
  final nameStart = marker == '<' ? openIndex + 3 : openIndex + 4;
  if (nameStart >= pattern.length) {
    return null;
  }
  final lookbehindMarker = pattern[nameStart];
  if (marker == '<' && (lookbehindMarker == '=' || lookbehindMarker == '!')) {
    return null;
  }
  final close = pattern.indexOf('>', nameStart);
  return close < 0 ? null : close + 1;
}

RegExp? _compileStructuralRegex(
  String pattern, {
  required bool caseSensitive,
  required bool multiLine,
  required bool unicode,
  required bool dotAll,
}) {
  final kind = _StructuralRegexKind.fromPattern(pattern);
  if (kind == null) {
    return null;
  }
  return _StructuralRegExp(
    pattern,
    kind: kind,
    isCaseSensitive: caseSensitive,
    isMultiLine: multiLine,
    isUnicode: unicode,
    isDotAll: dotAll,
  );
}

const _specLifecycleLineBlockPattern =
    r'''(?m:^[ \t]*(I|LS|LE|LX|E|EX|IT)[ \t]*(?<blkLBL>\{(?:[^{}"']++|"(?:\\.|[^"])*+"|'(?:\\.|[^'])*+'|(?&blkLBL))*+\})[ \t]*(?=\r?$))''';
const _specStandaloneLifecycleBlockPattern =
    r'''(?m:^[ \t]*(?<blkSLB>\{(?:[^{}"']++|"(?:\\.|[^"])*+"|'(?:\\.|[^'])*+'|(?&blkSLB))*+\})[ \t]*(?=\r?$))''';

enum _StructuralRegexKind {
  squareBrackets,
  ebnfReturnScalar,
  ebnfReturnArray,
  ebnfReturnObject,
  specActionBlock,
  specActionFluent,
  specBlindBlock,
  specBlindFluent,
  specBareBlock,
  specBareFluent,
  specLifecycleLineBlock,
  specStandaloneLifecycleBlock,
  specLifecycleBlock,
  specLifecycleFluent,
  specFunctionDefinition;

  static _StructuralRegexKind? fromPattern(String pattern) {
    if (pattern == r'(\[(?:[^\[\]]++|(?R))+\])') {
      return _StructuralRegexKind.squareBrackets;
    }
    if (pattern ==
        r'->\s*\K(?:\$\d+|"[^"]*"|'
            "'"
            r"[^']*'"
            r')') {
      return _StructuralRegexKind.ebnfReturnScalar;
    }
    if (pattern.startsWith(r'->\s*\K(?&array_structure)(?(DEFINE)')) {
      return _StructuralRegexKind.ebnfReturnArray;
    }
    if (pattern.startsWith(r'->\s*\K(?&object_structure)(?(DEFINE)')) {
      return _StructuralRegexKind.ebnfReturnObject;
    }
    if (pattern.startsWith(r'->[ \t]*((?:') && pattern.contains('(?<blkAB>')) {
      return _StructuralRegexKind.specActionBlock;
    }
    if (pattern.startsWith(r'->[ \t]*(') && pattern.contains('(?<chAF>')) {
      return _StructuralRegexKind.specActionFluent;
    }
    if (pattern.startsWith(r'=>[ \t]*(') && pattern.contains('(?<blkBB>')) {
      return _StructuralRegexKind.specBlindBlock;
    }
    if (pattern.startsWith(r'=>[ \t]*(') && pattern.contains('(?<chBF>')) {
      return _StructuralRegexKind.specBlindFluent;
    }
    if (pattern.startsWith(r'(?m:^[ \t]*(') && pattern.contains('(?<blkBE>')) {
      return _StructuralRegexKind.specBareBlock;
    }
    if (pattern.startsWith(r'(?m:^[ \t]*(') && pattern.contains('(?<blkBEF>')) {
      return _StructuralRegexKind.specBareFluent;
    }
    if (pattern == _specLifecycleLineBlockPattern) {
      return _StructuralRegexKind.specLifecycleLineBlock;
    }
    if (pattern == _specStandaloneLifecycleBlockPattern) {
      return _StructuralRegexKind.specStandaloneLifecycleBlock;
    }
    if (pattern.startsWith(r'(I|LS|LE|LX|E|EX|IT)[ \t]*(?<blkLB>') ||
        pattern.startsWith(r'(\w++)[ \t]*(?<blkLB>')) {
      return _StructuralRegexKind.specLifecycleBlock;
    }
    if (pattern.startsWith(r'(I|LS|LE|LX|E|EX|IT)(?<chLF>') ||
        pattern.startsWith(r'(\w++)(?<chLF>')) {
      return _StructuralRegexKind.specLifecycleFluent;
    }
    if (pattern.startsWith(r'fn[ \t]+') &&
        (pattern.contains('(?<blkFN>') || pattern.contains('(?<blkVFN>'))) {
      return _StructuralRegexKind.specFunctionDefinition;
    }
    return null;
  }
}

RegExp? _compileSpecStructuralPrefix(
  String pattern,
  _StructuralRegexKind kind, {
  required bool unicode,
}) {
  switch (kind) {
    case _StructuralRegexKind.specActionBlock:
      final label = _specRuleLabelAtom(pattern, r'->[ \t]*((?:');
      return RegExp(
        '->[ \\t]*((?:$label[ \\t]*(?:\\[[ \\t]*\\d+[ \\t]*\\][ \\t]*)?)'
        '(?:[ \\t]*\\|[ \\t]*$label[ \\t]*(?:\\[[ \\t]*\\d+[ \\t]*\\][ \\t]*)?)*)[ \\t]*',
        unicode: unicode,
      );
    case _StructuralRegexKind.specActionFluent:
      final label = _specRuleLabelAtom(pattern, r'->[ \t]*(');
      return RegExp(
        '->[ \\t]*($label)[ \\t]*(?:\\[[ \\t]*\\d+[ \\t]*\\][ \\t]*)?',
        unicode: unicode,
      );
    case _StructuralRegexKind.specBlindBlock:
    case _StructuralRegexKind.specBlindFluent:
      final label = _specRuleLabelAtom(pattern, r'=>[ \t]*(');
      return RegExp('=>[ \\t]*($label)[ \\t]*', unicode: unicode);
    case _StructuralRegexKind.specBareBlock:
      final label = _specRuleLabelAtom(pattern, r'(?m:^[ \t]*(');
      return RegExp(
        '^[ \\t]*($label(?:[ \\t]*\\[[ \\t]*\\d+[ \\t]*\\])?'
        '(?:[ \\t]*\\|[ \\t]*$label(?:[ \\t]*\\[[ \\t]*\\d+[ \\t]*\\])?)*)[ \\t]*',
        multiLine: true,
        unicode: unicode,
      );
    case _StructuralRegexKind.specBareFluent:
      final label = _specRuleLabelAtom(pattern, r'(?m:^[ \t]*(');
      return RegExp(
        '^[ \\t]*($label)[ \\t]*(?:\\[[ \\t]*(\\d+)[ \\t]*\\][ \\t]*)?',
        multiLine: true,
        unicode: unicode,
      );
    case _StructuralRegexKind.specLifecycleLineBlock:
      return RegExp(r'^[ \t]*(I|LS|LE|LX|E|EX|IT)[ \t]*', multiLine: true);
    case _StructuralRegexKind.specStandaloneLifecycleBlock:
      return RegExp(r'^[ \t]*', multiLine: true);
    case _StructuralRegexKind.specLifecycleBlock:
      return RegExp(
        pattern.startsWith('(I|')
            ? r'(I|LS|LE|LX|E|EX|IT)[ \t]*'
            : r'(\w+)[ \t]*',
      );
    case _StructuralRegexKind.specLifecycleFluent:
      return RegExp(
        pattern.startsWith('(I|') ? r'(I|LS|LE|LX|E|EX|IT)' : r'(\w+)',
      );
    case _StructuralRegexKind.squareBrackets:
    case _StructuralRegexKind.ebnfReturnScalar:
    case _StructuralRegexKind.ebnfReturnArray:
    case _StructuralRegexKind.ebnfReturnObject:
    case _StructuralRegexKind.specFunctionDefinition:
      return null;
  }
}

String _specRuleLabelAtom(String pattern, String prefix) {
  if (!pattern.startsWith(prefix)) {
    throw FormatException('unsupported self-hosted rule-label prefix', pattern);
  }
  final start = prefix.length;
  if (pattern.startsWith(r'\w+', start)) {
    return r'\w+';
  }
  if (start >= pattern.length || pattern.codeUnitAt(start) != _openBracket) {
    throw FormatException('missing self-hosted rule-label class', pattern);
  }
  final end = pattern.indexOf(']+', start);
  if (end < 0) {
    throw FormatException('unterminated self-hosted rule-label class', pattern);
  }
  return pattern.substring(start, end + 2);
}

final class _StructuralRegExp implements RegExp {
  _StructuralRegExp(
    this.pattern, {
    required this.kind,
    required bool isCaseSensitive,
    required bool isMultiLine,
    required bool isUnicode,
    required bool isDotAll,
  }) : _isCaseSensitive = isCaseSensitive,
       _isMultiLine = isMultiLine,
       _isUnicode = isUnicode,
       _isDotAll = isDotAll {
    _specPrefix = _compileSpecStructuralPrefix(
      pattern,
      kind,
      unicode: isUnicode,
    );
  }

  final _StructuralRegexKind kind;

  @override
  final String pattern;

  final bool _isCaseSensitive;
  final bool _isMultiLine;
  final bool _isUnicode;
  final bool _isDotAll;
  late final RegExp? _specPrefix;

  @override
  bool get isCaseSensitive => _isCaseSensitive;

  @override
  bool get isMultiLine => _isMultiLine;

  @override
  bool get isUnicode => _isUnicode;

  @override
  bool get isDotAll => _isDotAll;

  @override
  Iterable<RegExpMatch> allMatches(String input, [int start = 0]) sync* {
    var cursor = _clampCodeUnitOffset(input, start);
    while (cursor <= input.length) {
      final match = _matchAt(input, cursor);
      if (match != null) {
        yield match;
        cursor = match.end > cursor ? match.end : cursor + 1;
        continue;
      }
      cursor += 1;
    }
  }

  @override
  RegExpMatch? firstMatch(String input) {
    return allMatches(input).firstOrNull;
  }

  @override
  bool hasMatch(String input) {
    return firstMatch(input) != null;
  }

  @override
  Match? matchAsPrefix(String input, [int start = 0]) {
    return _matchAt(input, _clampCodeUnitOffset(input, start));
  }

  @override
  String? stringMatch(String input) {
    return firstMatch(input)?.group(0);
  }

  _StructuralRegExpMatch? _matchAt(String input, int start) {
    return switch (kind) {
      _StructuralRegexKind.squareBrackets => _matchSquareBrackets(input, start),
      _StructuralRegexKind.ebnfReturnScalar => _matchEbnfReturnScalar(
        input,
        start,
      ),
      _StructuralRegexKind.ebnfReturnArray => _matchEbnfReturnStructure(
        input,
        start,
        open: _openBracket,
        close: _closeBracket,
      ),
      _StructuralRegexKind.ebnfReturnObject => _matchEbnfReturnStructure(
        input,
        start,
        open: _openBrace,
        close: _closeBrace,
      ),
      _StructuralRegexKind.specActionBlock => _matchSpecActionBlock(
        input,
        start,
      ),
      _StructuralRegexKind.specActionFluent => _matchSpecFluent(
        input,
        start,
        prefix: _specPrefix!,
        blockName: 'blkAF',
        chainName: 'chAF',
      ),
      _StructuralRegexKind.specBlindBlock => _matchSpecBlock(
        input,
        start,
        prefix: _specPrefix!,
        blockName: 'blkBB',
      ),
      _StructuralRegexKind.specBlindFluent => _matchSpecFluent(
        input,
        start,
        prefix: _specPrefix!,
        blockName: 'blkBF',
        chainName: 'chBF',
      ),
      _StructuralRegexKind.specBareBlock => _matchSpecBareBlock(input, start),
      _StructuralRegexKind.specBareFluent => _matchSpecBareFluent(input, start),
      _StructuralRegexKind.specLifecycleLineBlock => _matchSpecBlock(
        input,
        start,
        prefix: _specPrefix!,
        blockName: 'blkLBL',
        completeLine: true,
      ),
      _StructuralRegexKind.specStandaloneLifecycleBlock =>
        _matchSpecStandaloneLifecycleBlock(input, start),
      _StructuralRegexKind.specLifecycleBlock => _matchSpecBlock(
        input,
        start,
        prefix: _specPrefix!,
        blockName: 'blkLB',
      ),
      _StructuralRegexKind.specLifecycleFluent => _matchSpecFluent(
        input,
        start,
        prefix: _specPrefix!,
        blockName: 'blkLF',
        chainName: 'chLF',
      ),
      _StructuralRegexKind.specFunctionDefinition => _matchSpecFunction(
        input,
        start,
      ),
    };
  }

  _StructuralRegExpMatch? _matchSquareBrackets(String input, int start) {
    if (!_hasCodeUnit(input, start, _openBracket)) {
      return null;
    }
    final end = _parseBalanced(input, start, _openBracket, _closeBracket);
    if (end == null || end == start + 2) {
      return null;
    }
    final text = input.substring(start, end);
    return _match(input, start, end, [text, text]);
  }

  _StructuralRegExpMatch? _matchEbnfReturnScalar(String input, int start) {
    final valueStart = _ebnfReturnValueStart(input, start);
    if (valueStart == null) {
      return null;
    }
    final first = input.codeUnitAt(valueStart);
    int? end;
    if (first == _dollar) {
      var cursor = valueStart + 1;
      while (cursor < input.length && _isDigitCode(input.codeUnitAt(cursor))) {
        cursor += 1;
      }
      if (cursor > valueStart + 1) {
        end = cursor;
      }
    } else if (first == _doubleQuote || first == _singleQuote) {
      end = _parseSimpleQuoted(input, valueStart, first);
    }
    if (end == null) {
      return null;
    }
    return _match(input, valueStart, end, [input.substring(valueStart, end)]);
  }

  _StructuralRegExpMatch? _matchEbnfReturnStructure(
    String input,
    int start, {
    required int open,
    required int close,
  }) {
    final valueStart = _ebnfReturnValueStart(input, start);
    if (valueStart == null || !_hasCodeUnit(input, valueStart, open)) {
      return null;
    }
    final end = _parseBalanced(input, valueStart, open, close);
    if (end == null) {
      return null;
    }
    return _match(input, valueStart, end, [input.substring(valueStart, end)]);
  }

  int? _ebnfReturnValueStart(String input, int start) {
    if (start + 2 > input.length ||
        input.codeUnitAt(start) != _hyphen ||
        input.codeUnitAt(start + 1) != _greaterThan) {
      return null;
    }
    return _skipWhitespace(input, start + 2);
  }

  _StructuralRegExpMatch? _matchSpecActionBlock(String input, int start) {
    final prefix = _specPrefix!.matchAsPrefix(input, start);
    if (prefix == null) {
      return null;
    }
    final blockStart = prefix.end;
    final blockEnd = _parseBalancedCodeBlock(input, blockStart);
    if (blockEnd == null) {
      return null;
    }
    final block = input.substring(blockStart, blockEnd);
    return _match(
      input,
      start,
      blockEnd,
      [input.substring(start, blockEnd), prefix.group(1), block],
      named: {'blkAB': block},
    );
  }

  _StructuralRegExpMatch? _matchSpecBareBlock(String input, int start) {
    final prefix = _specPrefix!.matchAsPrefix(input, start);
    if (prefix == null) {
      return null;
    }
    final blockStart = prefix.end;
    final blockEnd = _parseBalancedCodeBlock(input, blockStart);
    if (blockEnd == null) {
      return null;
    }
    final end = _physicalLineMatchEnd(input, blockEnd);
    if (end == null) {
      return null;
    }
    final block = input.substring(blockStart, blockEnd);
    return _match(
      input,
      start,
      end,
      [input.substring(start, end), prefix.group(1), block],
      named: {'blkBE': block},
    );
  }

  _StructuralRegExpMatch? _matchSpecBareFluent(String input, int start) {
    final prefix = _specPrefix!.matchAsPrefix(input, start);
    if (prefix == null) {
      return null;
    }
    final chainStart = prefix.end;
    final chainEnd = _parseFluentChain(input, chainStart);
    if (chainEnd == null) {
      return null;
    }
    var contentEnd = chainEnd;
    String? block;
    final afterChain = _skipWhitespace(input, chainEnd);
    if (_hasCodeUnit(input, afterChain, _openBrace)) {
      final blockEnd = _parseBalancedCodeBlock(input, afterChain);
      if (blockEnd == null) {
        return null;
      }
      block = input.substring(afterChain, blockEnd);
      contentEnd = blockEnd;
    }
    final end = _physicalLineMatchEnd(input, contentEnd);
    if (end == null) {
      return null;
    }
    final chain = input.substring(chainStart, chainEnd);
    return _match(
      input,
      start,
      end,
      [
        input.substring(start, end),
        prefix.group(1),
        prefix.group(2),
        chain,
        block,
      ],
      named: {if (block != null) 'blkBEF': block},
    );
  }

  _StructuralRegExpMatch? _matchSpecBlock(
    String input,
    int start, {
    required RegExp prefix,
    required String blockName,
    bool completeLine = false,
  }) {
    final prefixMatch = prefix.matchAsPrefix(input, start);
    if (prefixMatch == null) {
      return null;
    }
    final blockStart = prefixMatch.end;
    final blockEnd = _parseBalancedCodeBlock(input, blockStart);
    if (blockEnd == null) {
      return null;
    }
    final end = completeLine
        ? _physicalLineMatchEnd(input, blockEnd)
        : blockEnd;
    if (end == null) {
      return null;
    }
    final block = input.substring(blockStart, blockEnd);
    return _match(
      input,
      start,
      end,
      [input.substring(start, end), prefixMatch.group(1), block],
      named: {blockName: block},
    );
  }

  _StructuralRegExpMatch? _matchSpecStandaloneLifecycleBlock(
    String input,
    int start,
  ) {
    final prefixMatch = _specPrefix!.matchAsPrefix(input, start);
    if (prefixMatch == null) {
      return null;
    }
    final blockStart = prefixMatch.end;
    final blockEnd = _parseBalancedCodeBlock(input, blockStart);
    if (blockEnd == null) {
      return null;
    }
    final end = _physicalLineMatchEnd(input, blockEnd);
    if (end == null) {
      return null;
    }
    final block = input.substring(blockStart, blockEnd);
    return _match(
      input,
      start,
      end,
      [input.substring(start, end), block],
      named: {'blkSLB': block},
    );
  }

  _StructuralRegExpMatch? _matchSpecFluent(
    String input,
    int start, {
    required RegExp prefix,
    required String blockName,
    required String chainName,
  }) {
    final prefixMatch = prefix.matchAsPrefix(input, start);
    if (prefixMatch == null) {
      return null;
    }
    final chainStart = prefixMatch.end;
    final chainEnd = _parseFluentChain(input, chainStart);
    if (chainEnd == null) {
      return null;
    }
    var end = chainEnd;
    String? block;
    final afterChain = _skipWhitespace(input, chainEnd);
    if (_hasCodeUnit(input, afterChain, _openBrace)) {
      final blockEnd = _parseBalancedCodeBlock(input, afterChain);
      if (blockEnd == null) {
        return null;
      }
      block = input.substring(afterChain, blockEnd);
      end = blockEnd;
    }
    final chain = input.substring(chainStart, chainEnd);
    return _match(
      input,
      start,
      end,
      [input.substring(start, end), prefixMatch.group(1), chain, block],
      named: {chainName: chain, if (block != null) blockName: block},
    );
  }

  _StructuralRegExpMatch? _matchSpecFunction(String input, int start) {
    final variadic = pattern.contains('(?<blkVFN>');
    final prefix =
        (variadic ? _specVariadicFunctionPrefix : _specFunctionPrefix)
            .matchAsPrefix(input, start);
    if (prefix == null) {
      return null;
    }
    final blockStart = prefix.end;
    final blockEnd = _parseBalancedCodeBlock(input, blockStart);
    if (blockEnd == null) {
      return null;
    }
    final block = input.substring(blockStart, blockEnd);
    final groups = variadic
        ? [
            input.substring(start, blockEnd),
            prefix.group(1),
            prefix.group(2) ?? '',
            prefix.group(3),
            block,
          ]
        : [
            input.substring(start, blockEnd),
            prefix.group(1),
            prefix.group(2) ?? '',
            block,
          ];
    return _match(
      input,
      start,
      blockEnd,
      groups,
      named: {variadic ? 'blkVFN' : 'blkFN': block},
    );
  }

  _StructuralRegExpMatch _match(
    String input,
    int start,
    int end,
    List<String?> groups, {
    Map<String, String> named = const {},
  }) {
    return _StructuralRegExpMatch(
      pattern: this,
      input: input,
      start: start,
      end: end,
      groups: List.unmodifiable(groups),
      named: Map.unmodifiable(named),
    );
  }
}

final class _StructuralRegExpMatch implements RegExpMatch {
  const _StructuralRegExpMatch({
    required RegExp pattern,
    required this.input,
    required this.start,
    required this.end,
    required List<String?> groups,
    required Map<String, String> named,
  }) : _pattern = pattern,
       _groups = groups,
       _named = named;

  final RegExp _pattern;
  final List<String?> _groups;
  final Map<String, String> _named;

  @override
  RegExp get pattern => _pattern;

  @override
  final String input;

  @override
  final int start;

  @override
  final int end;

  @override
  int get groupCount => _groups.length - 1;

  @override
  Iterable<String> get groupNames => _named.keys;

  @override
  String? group(int group) {
    if (group < 0 || group >= _groups.length) {
      throw RangeError.range(group, 0, _groups.length - 1, 'group');
    }
    return _groups[group];
  }

  @override
  String? operator [](int group) => this.group(group);

  @override
  List<String?> groups(List<int> groupIndices) {
    return [for (final index in groupIndices) group(index)];
  }

  @override
  String? namedGroup(String name) => _named[name];
}

final class RuntimeMatchRegisters {
  const RuntimeMatchRegisters({
    required this.input,
    required this.cursorCodeUnit,
    this.entryMatch,
    this.localMatch,
    this.captureStartCodeUnit,
  });

  factory RuntimeMatchRegisters.empty(String input, {int cursorCodeUnit = 0}) {
    final cursor = _clampCodeUnitOffset(input, cursorCodeUnit);
    return RuntimeMatchRegisters(
      input: input,
      cursorCodeUnit: cursor,
      captureStartCodeUnit: cursor,
    );
  }

  final String input;
  final int cursorCodeUnit;
  final RuntimeRegexMatch? entryMatch;
  final RuntimeRegexMatch? localMatch;
  final int? captureStartCodeUnit;

  int get cursorCharOffset {
    return codeUnitOffsetToCharOffset(input, cursorCodeUnit);
  }

  LineColumn get cursorLineColumn {
    return lineColumnAtCodeUnitOffset(input, cursorCodeUnit);
  }

  RuntimeMatchRegisters enterChild() {
    return RuntimeMatchRegisters(
      input: input,
      cursorCodeUnit: cursorCodeUnit,
      entryMatch: localMatch,
      captureStartCodeUnit: localMatch?.codeUnitEnd ?? cursorCodeUnit,
    );
  }

  RuntimeMatchRegisters withLocalMatch(RuntimeRegexMatch match) {
    if (!identical(input, match.input) && input != match.input) {
      throw ArgumentError('match input does not belong to this register input');
    }
    return RuntimeMatchRegisters(
      input: input,
      cursorCodeUnit: match.codeUnitEnd,
      entryMatch: entryMatch ?? match,
      localMatch: match,
      captureStartCodeUnit: captureStartCodeUnit ?? match.codeUnitEnd,
    );
  }

  RuntimeMatchRegisters withCursorCodeUnit(int codeUnitCursor) {
    return RuntimeMatchRegisters(
      input: input,
      cursorCodeUnit: _clampCodeUnitOffset(input, codeUnitCursor),
      entryMatch: entryMatch,
      localMatch: localMatch,
      captureStartCodeUnit: captureStartCodeUnit,
    );
  }

  RuntimeMatchRegisters withCaptureStartCodeUnit(int codeUnitCursor) {
    return RuntimeMatchRegisters(
      input: input,
      cursorCodeUnit: cursorCodeUnit,
      entryMatch: entryMatch,
      localMatch: localMatch,
      captureStartCodeUnit: _clampCodeUnitOffset(input, codeUnitCursor),
    );
  }

  bool zeroProgressSince(int previousCodeUnitCursor) {
    return cursorCodeUnit ==
        _clampCodeUnitOffset(input, previousCodeUnitCursor);
  }

  JsonObject toJson() {
    final lineColumn = cursorLineColumn;
    return {
      'cursor_code_unit': cursorCodeUnit,
      'cursor_char_offset': cursorCharOffset,
      'cursor_line': lineColumn.line,
      'cursor_column': lineColumn.column,
      if (captureStartCodeUnit != null)
        'capture_start_code_unit': captureStartCodeUnit,
      if (entryMatch != null) 'entry_match': entryMatch!.toJson(),
      if (localMatch != null) 'local_match': localMatch!.toJson(),
    };
  }
}

final class LineColumn {
  const LineColumn({required this.line, required this.column});

  final int line;
  final int column;

  JsonObject toJson() => {'line': line, 'column': column};
}

int codeUnitOffsetToCharOffset(String input, int codeUnitOffset) {
  final clamped = _clampCodeUnitOffset(input, codeUnitOffset);
  return input.substring(0, clamped).runes.length;
}

int charOffsetToCodeUnitOffset(String input, int charOffset) {
  if (charOffset <= 0) {
    return 0;
  }
  var seen = 0;
  var codeUnitOffset = 0;
  for (final rune in input.runes) {
    if (seen >= charOffset) {
      break;
    }
    codeUnitOffset += String.fromCharCode(rune).length;
    seen += 1;
  }
  return codeUnitOffset.clamp(0, input.length);
}

LineColumn lineColumnAtCodeUnitOffset(String input, int codeUnitOffset) {
  final charOffset = codeUnitOffsetToCharOffset(input, codeUnitOffset);
  var line = 1;
  var column = 1;
  var index = 0;
  for (final rune in input.runes) {
    if (index >= charOffset) {
      break;
    }
    if (rune == _lineFeed) {
      line += 1;
      column = 1;
    } else {
      column += 1;
    }
    index += 1;
  }
  return LineColumn(line: line, column: column);
}

bool _isBetterSeekCandidate(
  RuntimeRegexMatch candidate,
  RuntimeRegexMatch? current,
) {
  if (current == null) {
    return true;
  }
  if (candidate.codeUnitStart != current.codeUnitStart) {
    return candidate.codeUnitStart < current.codeUnitStart;
  }
  return candidate.alternativeIndex < current.alternativeIndex;
}

RegExp compileRuntimeRegex(
  String pattern, {
  bool caseSensitive = true,
  bool multiLine = false,
  bool unicode = false,
  bool dotAll = false,
}) {
  final effectiveUnicode = unicode || _containsSupplementaryScalar(pattern);
  final structural = _compileStructuralRegex(
    pattern,
    caseSensitive: caseSensitive,
    multiLine: multiLine,
    unicode: effectiveUnicode,
    dotAll: dotAll,
  );
  if (structural != null) {
    return structural;
  }

  final normalized = _normalizePattern(pattern);
  return RegExp(
    normalized.pattern,
    caseSensitive: caseSensitive && !normalized.caseInsensitive,
    multiLine: multiLine || normalized.multiLine,
    unicode: effectiveUnicode,
    dotAll: dotAll || normalized.dotAll,
  );
}

bool _containsSupplementaryScalar(String pattern) {
  return pattern.runes.any((scalar) => scalar > 0xFFFF);
}

_NormalizedRegexPattern _normalizePattern(String pattern) {
  final inline = _normalizeInlineFlagGroups(pattern);
  return _NormalizedRegexPattern(
    pattern: _normalizePossessiveQuantifiers(
      _normalizeLowerUnboundedQuantifiers(
        _normalizePosixCharacterClasses(
          _normalizePythonNamedCaptureSyntax(inline.pattern),
        ),
      ),
    ),
    caseInsensitive: inline.caseInsensitive,
    multiLine: inline.multiLine,
    dotAll: inline.dotAll,
  );
}

final class _NormalizedRegexPattern {
  const _NormalizedRegexPattern({
    required this.pattern,
    required this.caseInsensitive,
    required this.multiLine,
    required this.dotAll,
  });

  final String pattern;
  final bool caseInsensitive;
  final bool multiLine;
  final bool dotAll;
}

String _normalizePythonNamedCaptureSyntax(String pattern) {
  return pattern.replaceAllMapped(
    RegExp(r'\(\?P<([A-Za-z_][A-Za-z0-9_]*)>'),
    (match) => '(?<${match[1]}>',
  );
}

_NormalizedRegexPattern _normalizeInlineFlagGroups(String pattern) {
  final output = StringBuffer();
  var caseInsensitive = false;
  var multiLine = false;
  var dotAll = false;
  var escaped = false;
  var inClass = false;

  for (var index = 0; index < pattern.length; index += 1) {
    final code = pattern.codeUnitAt(index);
    if (escaped) {
      output.writeCharCode(code);
      escaped = false;
      continue;
    }
    if (code == _backslash) {
      output.writeCharCode(code);
      escaped = true;
      continue;
    }
    if (code == _openBracket) {
      inClass = true;
      output.writeCharCode(code);
      continue;
    }
    if (code == _closeBracket) {
      inClass = false;
      output.writeCharCode(code);
      continue;
    }
    if (!inClass &&
        index + 3 <= pattern.length &&
        pattern.codeUnitAt(index) == _openParen &&
        pattern.codeUnitAt(index + 1) == _question) {
      var flagIndex = index + 2;
      while (flagIndex < pattern.length &&
          _isInlineRegexFlag(pattern[flagIndex])) {
        flagIndex += 1;
      }
      if (flagIndex > index + 2 && flagIndex < pattern.length) {
        final terminator = pattern.codeUnitAt(flagIndex);
        if (terminator == _closeParen || terminator == _colon) {
          final flags = pattern.substring(index + 2, flagIndex);
          caseInsensitive = caseInsensitive || flags.contains('i');
          multiLine = multiLine || flags.contains('m');
          dotAll = dotAll || flags.contains('s');
          if (terminator == _colon) {
            output.write('(?:');
          }
          index = flagIndex;
          continue;
        }
      }
    }
    output.write(pattern[index]);
  }

  return _NormalizedRegexPattern(
    pattern: output.toString(),
    caseInsensitive: caseInsensitive,
    multiLine: multiLine,
    dotAll: dotAll,
  );
}

bool _isInlineRegexFlag(String value) {
  return value == 'i' || value == 'm' || value == 's';
}

String _normalizePosixCharacterClasses(String pattern) {
  final output = StringBuffer();
  var escaped = false;
  var inClass = false;

  for (var index = 0; index < pattern.length; index += 1) {
    final code = pattern.codeUnitAt(index);
    if (escaped) {
      output.writeCharCode(code);
      escaped = false;
      continue;
    }
    if (code == _backslash) {
      output.writeCharCode(code);
      escaped = true;
      continue;
    }
    if (inClass && code == _openBracket) {
      final replacement = _posixCharacterClassAt(pattern, index);
      if (replacement != null) {
        output.write(replacement.value);
        index = replacement.endIndex;
        continue;
      }
    }
    if (code == _openBracket) {
      inClass = true;
      output.writeCharCode(code);
      continue;
    }
    if (code == _closeBracket) {
      inClass = false;
      output.writeCharCode(code);
      continue;
    }
    output.writeCharCode(code);
  }

  return output.toString();
}

_PosixCharacterClassReplacement? _posixCharacterClassAt(
  String pattern,
  int index,
) {
  if (index + 4 >= pattern.length ||
      pattern.codeUnitAt(index) != _openBracket ||
      pattern.codeUnitAt(index + 1) != _colon) {
    return null;
  }

  var nameEnd = index + 2;
  while (nameEnd + 1 < pattern.length &&
      pattern.codeUnitAt(nameEnd) != _colon) {
    nameEnd += 1;
  }
  if (nameEnd + 1 >= pattern.length ||
      pattern.codeUnitAt(nameEnd + 1) != _closeBracket) {
    return null;
  }

  final value =
      _posixCharacterClassReplacements[pattern.substring(index + 2, nameEnd)];
  if (value == null) {
    return null;
  }
  return _PosixCharacterClassReplacement(value: value, endIndex: nameEnd + 1);
}

final class _PosixCharacterClassReplacement {
  const _PosixCharacterClassReplacement({
    required this.value,
    required this.endIndex,
  });

  final String value;
  final int endIndex;
}

const _posixCharacterClassReplacements = {
  'alnum': 'A-Za-z0-9',
  'alpha': 'A-Za-z',
  'ascii': r'\x00-\x7F',
  'blank': r'\t ',
  'cntrl': r'\x00-\x1F\x7F',
  'digit': '0-9',
  'graph': r'\x21-\x7E',
  'lower': 'a-z',
  'print': r'\x20-\x7E',
  'punct': r'''!"#$%&'()*+,\-./:;<=>?@\[\\\]^_`{|}~''',
  'space': r'\s',
  'upper': 'A-Z',
  'word': r'A-Za-z0-9_',
  'xdigit': 'A-Fa-f0-9',
};

String _normalizeLowerUnboundedQuantifiers(String pattern) {
  return pattern.replaceAllMapped(
    RegExp(r'\{,(\d+)\}'),
    (match) => '{0,${match[1]}}',
  );
}

String _normalizePossessiveQuantifiers(String pattern) {
  final output = StringBuffer();
  var escaped = false;
  var inClass = false;
  var previousWasQuantifier = false;

  for (var index = 0; index < pattern.length; index += 1) {
    final code = pattern.codeUnitAt(index);
    if (escaped) {
      output.writeCharCode(code);
      previousWasQuantifier = false;
      escaped = false;
      continue;
    }
    if (code == _backslash) {
      output.writeCharCode(code);
      previousWasQuantifier = false;
      escaped = true;
      continue;
    }
    if (code == _openBracket) {
      inClass = true;
      output.writeCharCode(code);
      previousWasQuantifier = false;
      continue;
    }
    if (code == _closeBracket) {
      inClass = false;
      output.writeCharCode(code);
      previousWasQuantifier = false;
      continue;
    }
    if (!inClass && code == _plus && previousWasQuantifier) {
      previousWasQuantifier = false;
      continue;
    }
    output.writeCharCode(code);
    previousWasQuantifier = !inClass && _isQuantifierCode(code);
  }

  return output.toString();
}

bool _isQuantifierCode(int value) {
  if (value == _plus ||
      value == _asterisk ||
      value == _question ||
      value == _closeBrace) {
    return true;
  }
  return false;
}

int? _parseBalanced(String input, int start, int open, int close) {
  if (!_hasCodeUnit(input, start, open)) {
    return null;
  }
  var depth = 0;
  for (var cursor = start; cursor < input.length; cursor += 1) {
    final code = input.codeUnitAt(cursor);
    if (code == open) {
      depth += 1;
    } else if (code == close) {
      depth -= 1;
      if (depth == 0) {
        return cursor + 1;
      }
    }
  }
  return null;
}

int? _parseBalancedCodeBlock(String input, int start) {
  if (!_hasCodeUnit(input, start, _openBrace)) {
    return null;
  }
  var depth = 0;
  for (var cursor = start; cursor < input.length; cursor += 1) {
    final code = input.codeUnitAt(cursor);
    if (code == _doubleQuote || code == _singleQuote) {
      final quotedEnd = _parseEscapedQuoted(input, cursor, code);
      if (quotedEnd == null) {
        return null;
      }
      cursor = quotedEnd - 1;
      continue;
    }
    if (code == _openBrace) {
      depth += 1;
    } else if (code == _closeBrace) {
      depth -= 1;
      if (depth == 0) {
        return cursor + 1;
      }
    }
  }
  return null;
}

int? _parseBalancedParens(String input, int start) {
  if (!_hasCodeUnit(input, start, _openParen)) {
    return null;
  }
  var depth = 0;
  for (var cursor = start; cursor < input.length; cursor += 1) {
    final code = input.codeUnitAt(cursor);
    if (code == _doubleQuote || code == _singleQuote) {
      final quotedEnd = _parseEscapedQuoted(input, cursor, code);
      if (quotedEnd == null) {
        return null;
      }
      cursor = quotedEnd - 1;
      continue;
    }
    if (code == _openParen) {
      depth += 1;
    } else if (code == _closeParen) {
      depth -= 1;
      if (depth == 0) {
        return cursor + 1;
      }
    }
  }
  return null;
}

int? _parseEscapedQuoted(String input, int start, int quote) {
  if (!_hasCodeUnit(input, start, quote)) {
    return null;
  }
  var escaped = false;
  for (var cursor = start + 1; cursor < input.length; cursor += 1) {
    final code = input.codeUnitAt(cursor);
    if (escaped) {
      escaped = false;
      continue;
    }
    if (code == _backslash) {
      escaped = true;
      continue;
    }
    if (code == quote) {
      return cursor + 1;
    }
  }
  return null;
}

int? _parseSimpleQuoted(String input, int start, int quote) {
  if (!_hasCodeUnit(input, start, quote)) {
    return null;
  }
  for (var cursor = start + 1; cursor < input.length; cursor += 1) {
    if (input.codeUnitAt(cursor) == quote) {
      return cursor + 1;
    }
  }
  return null;
}

int? _parseFluentChain(String input, int start) {
  var cursor = start;
  var sawCall = false;
  while (cursor < input.length) {
    final beforeWhitespace = cursor;
    cursor = _skipWhitespace(input, cursor);
    if (!_hasCodeUnit(input, cursor, _dot)) {
      return sawCall ? beforeWhitespace : null;
    }
    cursor += 1;
    cursor = _skipWhitespace(input, cursor);
    final nameStart = cursor;
    if (cursor >= input.length || !_isWordStartCode(input.codeUnitAt(cursor))) {
      return null;
    }
    cursor += 1;
    while (cursor < input.length && _isWordCode(input.codeUnitAt(cursor))) {
      cursor += 1;
    }
    if (cursor == nameStart) {
      return null;
    }
    final beforeArgs = cursor;
    cursor = _skipWhitespace(input, cursor);
    if (_hasCodeUnit(input, cursor, _openParen)) {
      final argsEnd = _parseBalancedParens(input, cursor);
      if (argsEnd == null) {
        return null;
      }
      cursor = argsEnd;
    } else {
      cursor = beforeArgs;
    }
    sawCall = true;
  }
  return sawCall ? cursor : null;
}

int _skipWhitespace(String input, int start) {
  var cursor = start;
  while (cursor < input.length) {
    final code = input.codeUnitAt(cursor);
    if (code != _space &&
        code != _tab &&
        code != _lineFeed &&
        code != _carriageReturn) {
      break;
    }
    cursor += 1;
  }
  return cursor;
}

int? _physicalLineMatchEnd(String input, int start) {
  var cursor = start;
  while (cursor < input.length) {
    final code = input.codeUnitAt(cursor);
    if (code != _space && code != _tab) {
      break;
    }
    cursor += 1;
  }
  if (cursor == input.length || input.codeUnitAt(cursor) == _lineFeed) {
    return cursor;
  }
  if (input.codeUnitAt(cursor) == _carriageReturn &&
      (cursor + 1 == input.length ||
          input.codeUnitAt(cursor + 1) == _lineFeed)) {
    return cursor;
  }
  return null;
}

bool _hasCodeUnit(String input, int index, int codeUnit) {
  return index >= 0 &&
      index < input.length &&
      input.codeUnitAt(index) == codeUnit;
}

bool _isDigitCode(int code) {
  return code >= _zero && code <= _nine;
}

bool _isWordStartCode(int code) {
  return (code >= _upperA && code <= _upperZ) ||
      (code >= _lowerA && code <= _lowerZ) ||
      code == _underscore;
}

bool _isWordCode(int code) {
  return _isWordStartCode(code) || _isDigitCode(code);
}

int _clampCodeUnitOffset(String input, int offset) {
  return offset.clamp(0, input.length);
}

final _specFunctionPrefix = RegExp(
  r'fn[ \t]+([A-Za-z_]\w*)\s*\(([A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)?\)\s*',
);
final _specVariadicFunctionPrefix = RegExp(
  r'fn[ \t]+([A-Za-z_]\w*)\s*\((?:([A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)\s*,\s*)?\.\.\.([A-Za-z_]\w*)\)\s*',
);

const _lineFeed = 0x0a;
const _carriageReturn = 0x0d;
const _tab = 0x09;
const _space = 0x20;
const _asterisk = 0x2a;
const _plus = 0x2b;
const _question = 0x3f;
const _colon = 0x3a;
const _backslash = 0x5c;
const _dollar = 0x24;
const _dot = 0x2e;
const _hyphen = 0x2d;
const _greaterThan = 0x3e;
const _doubleQuote = 0x22;
const _singleQuote = 0x27;
const _zero = 0x30;
const _nine = 0x39;
const _upperA = 0x41;
const _upperZ = 0x5a;
const _underscore = 0x5f;
const _lowerA = 0x61;
const _lowerZ = 0x7a;
const _openParen = 0x28;
const _closeParen = 0x29;
const _openBracket = 0x5b;
const _closeBracket = 0x5d;
const _openBrace = 0x7b;
const _closeBrace = 0x7d;
