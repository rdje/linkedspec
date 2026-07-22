import 'dart:convert';
import 'dart:typed_data';

import '../parser/unicode_rule_label.dart' show isRuleLabel;
import 'sha256.dart' show sha256Hex;

const _semanticSourceId = 'source:0';

/// Maximum caller-selected source detail that this index may disclose.
enum SemanticSourceDetail {
  none('none'),
  identity('identity'),
  span('span'),
  text('text');

  const SemanticSourceDetail(this.wireName);

  final String wireName;
}

/// Required caller-owned policy for one immutable semantic snapshot.
final class SemanticIndexOptions {
  const SemanticIndexOptions({
    required this.logicalName,
    required this.sourceDetailCeiling,
    this.entryRule,
  });

  final String logicalName;
  final SemanticSourceDetail sourceDetailCeiling;
  final String? entryRule;
}

/// Stable constructor or source-map failure before semantic projection.
final class SemanticIndexError implements Exception {
  SemanticIndexError({
    required this.stage,
    required this.code,
    required this.message,
    Map<String, Object?> fields = const {},
  }) : fields = Map.unmodifiable(
         Map.fromEntries(
           (fields.entries.toList()
                 ..sort((left, right) => left.key.compareTo(right.key)))
               .map((entry) => MapEntry(entry.key, entry.value)),
         ),
       );

  final String stage;
  final String code;
  final String message;
  final Map<String, Object?> fields;

  Map<String, Object?> toJson() => {
    'stage': stage,
    'code': code,
    'message': message,
    'fields': Map<String, Object?>.from(fields),
  };

  @override
  String toString() => '$code at $stage: $message';
}

/// Caller-registered source identity with no implicit filesystem path.
final class SemanticSourceIdentity {
  const SemanticSourceIdentity({
    required this.sourceId,
    required this.logicalName,
    required this.byteLength,
    required this.scalarLength,
    required this.contentDigest,
  });

  final String sourceId;
  final String logicalName;
  final int byteLength;
  final int scalarLength;
  final String? contentDigest;

  Map<String, Object?> toJson() => {
    'source_id': sourceId,
    'logical_name': logicalName,
    'byte_length': byteLength,
    'scalar_length': scalarLength,
    'content_digest': contentDigest,
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticSourceIdentity &&
      other.sourceId == sourceId &&
      other.logicalName == logicalName &&
      other.byteLength == byteLength &&
      other.scalarLength == scalarLength &&
      other.contentDigest == contentDigest;

  @override
  int get hashCode => Object.hash(
    sourceId,
    logicalName,
    byteLength,
    scalarLength,
    contentDigest,
  );
}

/// Exact zero-based byte / one-based line-and-scalar-column span.
final class SemanticSourceSpan {
  const SemanticSourceSpan({
    required this.startByte,
    required this.endByte,
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
  });

  final int startByte;
  final int endByte;
  final int startLine;
  final int startColumn;
  final int endLine;
  final int endColumn;

  Map<String, Object?> toJson() => {
    'start_byte': startByte,
    'end_byte': endByte,
    'start_line': startLine,
    'start_column': startColumn,
    'end_line': endLine,
    'end_column': endColumn,
  };

  @override
  bool operator ==(Object other) =>
      other is SemanticSourceSpan &&
      other.startByte == startByte &&
      other.endByte == endByte &&
      other.startLine == startLine &&
      other.startColumn == startColumn &&
      other.endLine == endLine &&
      other.endColumn == endColumn;

  @override
  int get hashCode => Object.hash(
    startByte,
    endByte,
    startLine,
    startColumn,
    endLine,
    endColumn,
  );
}

/// Opaque immutable semantic source foundation.
///
/// Construction copies caller input, normalizes it to canonical strict UTF-8,
/// and builds exact byte/scalar coordinates. It performs no parsing, target
/// execution, path resolution, or host-state capture.
final class SemanticIndex {
  SemanticIndex._({
    required String sourceText,
    required Uint8List sourceBytes,
    required String logicalName,
    required SemanticSourceDetail sourceDetailCeiling,
    required List<int> scalars,
  }) : _sourceText = sourceText,
       _sourceBytes = sourceBytes,
       _logicalName = logicalName,
       _sourceDetailCeiling = sourceDetailCeiling,
       _sourceMap = _SemanticSourceMap(scalars),
       _contentDigest = 'sha256:${sha256Hex(sourceBytes)}';

  /// Capture already decoded Unicode text and copy its canonical UTF-8 form.
  factory SemanticIndex.fromSource(
    String source, {
    required SemanticIndexOptions options,
  }) {
    _validateOptions(options);
    final scalars = _strictScalars(
      source,
      stage: 'decode_source',
      code: 'semantic_index_invalid_unicode',
      message: 'Semantic index source is not valid Unicode scalar text',
    );
    final copiedText = String.fromCharCodes(scalars);
    final copiedBytes = Uint8List.fromList(utf8.encode(copiedText));
    return SemanticIndex._(
      sourceText: copiedText,
      sourceBytes: copiedBytes,
      logicalName: options.logicalName,
      sourceDetailCeiling: options.sourceDetailCeiling,
      scalars: scalars,
    );
  }

  /// Strictly decode and copy UTF-8 bytes before any language parsing.
  factory SemanticIndex.fromUtf8(
    List<int> source, {
    required SemanticIndexOptions options,
  }) {
    _validateOptions(options);
    for (var index = 0; index < source.length; index += 1) {
      final byte = source[index];
      if (byte < 0 || byte > 0xFF) {
        throw SemanticIndexError(
          stage: 'validate_source',
          code: 'semantic_index_invalid_source',
          message: 'Semantic index byte input contains a value outside 0..255',
          fields: {'byte_index': index, 'value': byte},
        );
      }
    }
    final copiedBytes = Uint8List.fromList(source);
    final String sourceText;
    try {
      sourceText = utf8.decode(copiedBytes, allowMalformed: false);
    } on FormatException catch (error) {
      throw SemanticIndexError(
        stage: 'decode_source',
        code: 'semantic_index_invalid_utf8',
        message: 'Semantic index source is not valid UTF-8',
        fields: {if (error.offset != null) 'offset': error.offset},
      );
    }
    final scalars = _strictScalars(
      sourceText,
      stage: 'decode_source',
      code: 'semantic_index_invalid_utf8',
      message: 'Semantic index source is not valid UTF-8',
    );
    return SemanticIndex._(
      sourceText: sourceText,
      sourceBytes: copiedBytes,
      logicalName: options.logicalName,
      sourceDetailCeiling: options.sourceDetailCeiling,
      scalars: scalars,
    );
  }

  final String _sourceText;
  final Uint8List _sourceBytes;
  final String _logicalName;
  final SemanticSourceDetail _sourceDetailCeiling;
  final _SemanticSourceMap _sourceMap;
  final String _contentDigest;

  /// Return copied caller identity and exact source sizes without a host path.
  SemanticSourceIdentity get sourceIdentity {
    _requireSourceDetail(SemanticSourceDetail.identity);
    return SemanticSourceIdentity(
      sourceId: _semanticSourceId,
      logicalName: _logicalName,
      byteLength: _sourceBytes.length,
      scalarLength: _sourceMap.scalarLength,
      contentDigest: _sourceDetailCeiling == SemanticSourceDetail.text
          ? _contentDigest
          : null,
    );
  }

  /// Map an exact strict-UTF-8 byte range.
  SemanticSourceSpan sourceSpanForBytes(int start, int end) {
    _requireSourceDetail(SemanticSourceDetail.span);
    return _sourceMap.spanForByteRange(start, end);
  }

  /// Map an exact Unicode-scalar range.
  SemanticSourceSpan sourceSpanForScalars(int start, int end) {
    _requireSourceDetail(SemanticSourceDetail.span);
    return _sourceMap.spanForScalarRange(start, end);
  }

  /// Return exact decoded source text for one strict byte range.
  String sourceExcerptForBytes(int start, int end) {
    _requireSourceDetail(SemanticSourceDetail.text);
    final scalarRange = _sourceMap.scalarRangeForBytes(start, end);
    return _sourceText.substring(
      _sourceMap.codeUnitAtScalar(scalarRange.$1),
      _sourceMap.codeUnitAtScalar(scalarRange.$2),
    );
  }

  /// Locate one exact decoded occurrence at or after an exact byte boundary.
  SemanticSourceSpan? locateExact(String needle, {int afterByte = 0}) {
    _requireSourceDetail(SemanticSourceDetail.span);
    if (needle.isEmpty) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_needle_invalid',
        message: 'Source lookup needle must not be empty',
      );
    }
    final needleScalars = _strictScalars(
      needle,
      stage: 'map_source',
      code: 'semantic_source_needle_invalid',
      message: 'Source lookup needle must be valid Unicode scalar text',
    );
    _sourceMap.spanForByteRange(afterByte, afterByte);
    final needleBytes = utf8.encode(String.fromCharCodes(needleScalars));
    final start = _indexOfBytes(_sourceBytes, needleBytes, afterByte);
    if (start == null) {
      return null;
    }
    return _sourceMap.spanForByteRange(start, start + needleBytes.length);
  }

  void _requireSourceDetail(SemanticSourceDetail required) {
    if (_sourceDetailCeiling.index >= required.index) {
      return;
    }
    throw SemanticIndexError(
      stage: 'apply_source_ceiling',
      code: 'semantic_source_detail_forbidden',
      message: 'Requested source detail exceeds the semantic index ceiling',
      fields: {
        'ceiling': _sourceDetailCeiling.wireName,
        'required': required.wireName,
      },
    );
  }

  @override
  String toString() =>
      'SemanticIndex(sourceId: $_semanticSourceId, '
      'sourceDetailCeiling: ${_sourceDetailCeiling.wireName})';
}

final class _SemanticSourceMap {
  _SemanticSourceMap(List<int> scalars) {
    final byteAtScalar = <int>[0];
    final codeUnitAtScalar = <int>[0];
    final lineAtScalar = <int>[1];
    final columnAtScalar = <int>[1];
    var byteOffset = 0;
    var codeUnitOffset = 0;
    var line = 1;
    var column = 1;

    for (final scalar in scalars) {
      byteOffset += _utf8Width(scalar);
      codeUnitOffset += scalar > 0xFFFF ? 2 : 1;
      if (scalar == 0x0A) {
        line += 1;
        column = 1;
      } else {
        column += 1;
      }
      byteAtScalar.add(byteOffset);
      codeUnitAtScalar.add(codeUnitOffset);
      lineAtScalar.add(line);
      columnAtScalar.add(column);
    }

    _byteAtScalar = List.unmodifiable(byteAtScalar);
    _codeUnitAtScalar = List.unmodifiable(codeUnitAtScalar);
    _lineAtScalar = List.unmodifiable(lineAtScalar);
    _columnAtScalar = List.unmodifiable(columnAtScalar);
  }

  late final List<int> _byteAtScalar;
  late final List<int> _codeUnitAtScalar;
  late final List<int> _lineAtScalar;
  late final List<int> _columnAtScalar;

  int get scalarLength => _byteAtScalar.length - 1;

  int codeUnitAtScalar(int scalar) => _codeUnitAtScalar[scalar];

  SemanticSourceSpan spanForScalarRange(int start, int end) {
    if (start < 0 || start > end || end > scalarLength) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_range_invalid',
        message: 'Source scalar range is outside the captured source',
        fields: {'start_scalar': start, 'end_scalar': end},
      );
    }
    return _spanForScalarBoundaries(start, end);
  }

  SemanticSourceSpan spanForByteRange(int start, int end) {
    final scalarRange = scalarRangeForBytes(start, end);
    return _spanForScalarBoundaries(scalarRange.$1, scalarRange.$2);
  }

  (int, int) scalarRangeForBytes(int start, int end) {
    if (start < 0 || start > end || end > _byteAtScalar.last) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_range_invalid',
        message: 'Source byte range is outside the captured source',
        fields: {'start_byte': start, 'end_byte': end},
      );
    }
    final startScalar = _boundaryIndex(_byteAtScalar, start);
    if (startScalar == null) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_boundary_invalid',
        message: 'Source byte range starts inside a UTF-8 scalar',
        fields: {'start_byte': start},
      );
    }
    final endScalar = _boundaryIndex(_byteAtScalar, end);
    if (endScalar == null) {
      throw SemanticIndexError(
        stage: 'map_source',
        code: 'semantic_source_boundary_invalid',
        message: 'Source byte range ends inside a UTF-8 scalar',
        fields: {'end_byte': end},
      );
    }
    return (startScalar, endScalar);
  }

  SemanticSourceSpan _spanForScalarBoundaries(int start, int end) {
    return SemanticSourceSpan(
      startByte: _byteAtScalar[start],
      endByte: _byteAtScalar[end],
      startLine: _lineAtScalar[start],
      startColumn: _columnAtScalar[start],
      endLine: _lineAtScalar[end],
      endColumn: _columnAtScalar[end],
    );
  }
}

void _validateOptions(SemanticIndexOptions options) {
  final nameScalars = _strictScalars(
    options.logicalName,
    stage: 'validate_options',
    code: 'semantic_index_invalid_option',
    message: 'Semantic index logical name must be valid Unicode scalar text',
    fieldName: 'option',
    fieldValue: 'logical_name',
  );
  if (nameScalars.isEmpty || nameScalars.any(_isControlScalar)) {
    throw SemanticIndexError(
      stage: 'validate_options',
      code: 'semantic_index_invalid_option',
      message:
          'Semantic index logical name must be nonempty and contain no '
          'control characters',
      fields: {'option': 'logical_name'},
    );
  }
  final entryRule = options.entryRule;
  if (entryRule != null && !isRuleLabel(entryRule)) {
    throw SemanticIndexError(
      stage: 'validate_options',
      code: 'semantic_index_invalid_option',
      message: 'Semantic index entry rule must be a valid rule label',
      fields: {'option': 'entry_rule'},
    );
  }
}

List<int> _strictScalars(
  String value, {
  required String stage,
  required String code,
  required String message,
  String fieldName = 'code_unit_offset',
  Object? fieldValue,
}) {
  final scalars = <int>[];
  var index = 0;
  while (index < value.length) {
    final first = value.codeUnitAt(index);
    if (first >= 0xD800 && first <= 0xDBFF) {
      if (index + 1 >= value.length) {
        throw SemanticIndexError(
          stage: stage,
          code: code,
          message: message,
          fields: {fieldName: fieldValue ?? index},
        );
      }
      final second = value.codeUnitAt(index + 1);
      if (second < 0xDC00 || second > 0xDFFF) {
        throw SemanticIndexError(
          stage: stage,
          code: code,
          message: message,
          fields: {fieldName: fieldValue ?? index},
        );
      }
      scalars.add(0x10000 + ((first - 0xD800) << 10) + (second - 0xDC00));
      index += 2;
      continue;
    }
    if (first >= 0xDC00 && first <= 0xDFFF) {
      throw SemanticIndexError(
        stage: stage,
        code: code,
        message: message,
        fields: {fieldName: fieldValue ?? index},
      );
    }
    scalars.add(first);
    index += 1;
  }
  return List.unmodifiable(scalars);
}

bool _isControlScalar(int scalar) =>
    scalar <= 0x1F || (scalar >= 0x7F && scalar <= 0x9F);

int _utf8Width(int scalar) {
  if (scalar <= 0x7F) {
    return 1;
  }
  if (scalar <= 0x7FF) {
    return 2;
  }
  if (scalar <= 0xFFFF) {
    return 3;
  }
  return 4;
}

int? _boundaryIndex(List<int> boundaries, int target) {
  var low = 0;
  var high = boundaries.length - 1;
  while (low <= high) {
    final middle = low + ((high - low) ~/ 2);
    final value = boundaries[middle];
    if (value == target) {
      return middle;
    }
    if (value < target) {
      low = middle + 1;
    } else {
      high = middle - 1;
    }
  }
  return null;
}

int? _indexOfBytes(List<int> haystack, List<int> needle, int start) {
  final lastStart = haystack.length - needle.length;
  for (var candidate = start; candidate <= lastStart; candidate += 1) {
    var matched = true;
    for (var offset = 0; offset < needle.length; offset += 1) {
      if (haystack[candidate + offset] != needle[offset]) {
        matched = false;
        break;
      }
    }
    if (matched) {
      return candidate;
    }
  }
  return null;
}
