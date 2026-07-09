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
            regex: RegExp(
              _normalizePattern(pattern),
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
  const RuntimeRegexMatch._({
    required this.input,
    required this.alternativeIndex,
    required this.pattern,
    required this.codeUnitStart,
    required this.codeUnitEnd,
    required this.groups,
    required this.captures,
    required this.named,
  });

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
      named: match.named,
    );
  }

  factory RuntimeRegexMatch._fromRegExpMatch({
    required String input,
    required int alternativeIndex,
    required String pattern,
    required RegExpMatch match,
  }) {
    final groups = <String>[];
    final captures = <String>[];
    for (var index = 0; index <= match.groupCount; index += 1) {
      final value = match.group(index);
      if (index == 0) {
        groups.add(value ?? '');
        continue;
      }
      if (value != null) {
        captures.add(value);
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

String _normalizePattern(String pattern) {
  return _normalizeLowerUnboundedQuantifiers(
    _normalizePythonNamedCaptureSyntax(pattern),
  );
}

String _normalizePythonNamedCaptureSyntax(String pattern) {
  return pattern.replaceAllMapped(
    RegExp(r'\(\?P<([A-Za-z_][A-Za-z0-9_]*)>'),
    (match) => '(?<${match[1]}>',
  );
}

String _normalizeLowerUnboundedQuantifiers(String pattern) {
  return pattern.replaceAllMapped(
    RegExp(r'\{,(\d+)\}'),
    (match) => '{0,${match[1]}}',
  );
}

int _clampCodeUnitOffset(String input, int offset) {
  return offset.clamp(0, input.length);
}

const _lineFeed = 0x0a;
