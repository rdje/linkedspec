/// Immutable source identities, Unicode-scalar positions, and source spans.
///
/// A [SourceAuthority] owns snapshots of caller-supplied decoded text. Values
/// retain only an opaque authority identity, source identity, scalar offsets,
/// and explicit provenance. They never retain copied source text or parser
/// state.
library;

import 'dart:convert';

const _validateValuePhase = 'validate_value';
const _sourceMismatchCode = 'source_location_source_mismatch';
const _positionOutOfRangeCode = 'source_location_position_out_of_range';
const _reversedSpanCode = 'source_location_reversed_span';
const _invalidDerivedProvenanceCode =
    'source_location_invalid_derived_provenance';

/// Rule and invocation roles attached to private source-location diagnostics.
final class SourceLocationContext {
  const SourceLocationContext({
    required this.ruleRole,
    required this.invocationRole,
  });

  final String ruleRole;
  final String invocationRole;
}

/// The supported materialization policies for explicitly derived text.
enum DerivedTextPolicy {
  concatenateInOrder('concatenate_in_order');

  const DerivedTextPolicy(this.serializedName);

  final String serializedName;
}

/// Immutable source identity plus a zero-based Unicode-scalar offset.
final class Position {
  const Position._({
    required int authorityId,
    required String sourceId,
    required int offset,
  }) : _authorityId = authorityId,
       _sourceId = sourceId,
       _offset = offset;

  final int _authorityId;
  final String _sourceId;
  final int _offset;

  /// Returns a detached neutral record.
  Map<String, Object?> toJson() => <String, Object?>{
    'source_id': _sourceId,
    'offset': _offset,
  };
}

/// Immutable same-source half-open interval plus a provenance label.
final class Span {
  const Span._({
    required int authorityId,
    required String sourceId,
    required int start,
    required int end,
    required String provenance,
  }) : _authorityId = authorityId,
       _sourceId = sourceId,
       _start = start,
       _end = end,
       _provenance = provenance;

  final int _authorityId;
  final String _sourceId;
  final int _start;
  final int _end;
  final String _provenance;

  /// Returns a detached neutral record.
  Map<String, Object?> toJson() => _spanRecord(this);
}

/// Immutable ordered direct-span provenance for explicitly derived text.
final class DerivedText {
  DerivedText._({
    required int authorityId,
    required DerivedTextPolicy policy,
    required List<Span> spans,
  }) : _authorityId = authorityId,
       _policy = policy,
       _spans = List<Span>.unmodifiable(spans);

  final int _authorityId;
  final DerivedTextPolicy _policy;
  final List<Span> _spans;

  /// Returns a detached neutral record.
  Map<String, Object?> toJson() => <String, Object?>{
    'policy': _policy.serializedName,
    'spans': <Object?>[for (final span in _spans) span.toJson()],
  };
}

/// Detached line, column, and UTF-8 byte evidence for one position.
final class SourceCoordinates {
  const SourceCoordinates._({
    required String sourceId,
    required int offset,
    required int line,
    required int column,
    required int utf8ByteOffset,
  }) : _sourceId = sourceId,
       _offset = offset,
       _line = line,
       _column = column,
       _utf8ByteOffset = utf8ByteOffset;

  final String _sourceId;
  final int _offset;
  final int _line;
  final int _column;
  final int _utf8ByteOffset;

  /// Returns a detached neutral record.
  Map<String, Object?> toJson() => <String, Object?>{
    'source_id': _sourceId,
    'offset': _offset,
    'line': _line,
    'column': _column,
    'utf8_byte_offset': _utf8ByteOffset,
  };
}

/// One of the four private immutable-value contract failures.
final class SourceLocationException implements Exception {
  SourceLocationException._({
    required String code,
    required SourceLocationContext context,
    required Map<String, Object?> fields,
  }) : _record = Map<String, Object?>.unmodifiable(<String, Object?>{
         'code': code,
         'phase': _validateValuePhase,
         'rule_role': context.ruleRole,
         'invocation_role': context.invocationRole,
         ...fields,
       });

  final Map<String, Object?> _record;

  /// Returns a detached machine-readable error record.
  Map<String, Object?> toJson() => Map<String, Object?>.from(_record);

  @override
  String toString() => _record['code']! as String;
}

final class _DecodedSource {
  _DecodedSource(this.text) {
    var line = 1;
    var column = 1;
    var codeUnitOffset = 0;
    var utf8ByteOffset = 0;
    final codeUnitAtScalar = <int>[0];
    final lineAtScalar = <int>[line];
    final columnAtScalar = <int>[column];
    final utf8ByteAtScalar = <int>[0];

    for (final scalar in text.runes) {
      final scalarText = String.fromCharCode(scalar);
      codeUnitOffset += scalarText.length;
      utf8ByteOffset += utf8.encode(scalarText).length;
      if (scalar == 0x0a) {
        line += 1;
        column = 1;
      } else {
        column += 1;
      }
      codeUnitAtScalar.add(codeUnitOffset);
      lineAtScalar.add(line);
      columnAtScalar.add(column);
      utf8ByteAtScalar.add(utf8ByteOffset);
    }

    _codeUnitAtScalar = List<int>.unmodifiable(codeUnitAtScalar);
    _lineAtScalar = List<int>.unmodifiable(lineAtScalar);
    _columnAtScalar = List<int>.unmodifiable(columnAtScalar);
    _utf8ByteAtScalar = List<int>.unmodifiable(utf8ByteAtScalar);
  }

  final String text;
  late final List<int> _codeUnitAtScalar;
  late final List<int> _lineAtScalar;
  late final List<int> _columnAtScalar;
  late final List<int> _utf8ByteAtScalar;

  int get scalarLength => _codeUnitAtScalar.length - 1;

  bool containsBoundary(int offset) =>
      offset >= 0 && offset < _codeUnitAtScalar.length;

  int? scalarOffsetAtCodeUnit(int codeUnitOffset) {
    var low = 0;
    var high = _codeUnitAtScalar.length - 1;
    while (low <= high) {
      final middle = low + ((high - low) >> 1);
      final candidate = _codeUnitAtScalar[middle];
      if (candidate == codeUnitOffset) {
        return middle;
      }
      if (candidate < codeUnitOffset) {
        low = middle + 1;
      } else {
        high = middle - 1;
      }
    }
    return null;
  }

  String slice(int start, int end) =>
      text.substring(_codeUnitAtScalar[start], _codeUnitAtScalar[end]);
}

/// Owns immutable decoded-source snapshots and validates typed values.
final class SourceAuthority {
  SourceAuthority({required Map<String, String> sources})
    : _authorityId = _claimAuthorityId(),
      _sources = Map<String, _DecodedSource>.unmodifiable(
        <String, _DecodedSource>{
          for (final entry in sources.entries)
            entry.key: _DecodedSource(entry.value),
        },
      );

  static int _nextAuthorityId = 1;

  final int _authorityId;
  final Map<String, _DecodedSource> _sources;

  static int _claimAuthorityId() => _nextAuthorityId++;

  /// Constructs and validates one Unicode-scalar-offset position.
  Position position({
    required String sourceId,
    required int offset,
    required SourceLocationContext context,
  }) {
    final source = _sources[sourceId];
    if (source == null || !source.containsBoundary(offset)) {
      throw SourceLocationException._(
        code: _positionOutOfRangeCode,
        context: context,
        fields: <String, Object?>{
          'source_id': sourceId,
          'position_offset': offset,
          'source_length': source?.scalarLength ?? 0,
        },
      );
    }
    return Position._(
      authorityId: _authorityId,
      sourceId: sourceId,
      offset: offset,
    );
  }

  /// Converts one current Dart UTF-16 code-unit boundary to a typed position.
  ///
  /// This is runtime-support API. It does not change the engine's existing
  /// code-unit cursor, match, capture, or mark registers.
  Position positionFromCodeUnit({
    required String sourceId,
    required int codeUnitOffset,
    required SourceLocationContext context,
  }) {
    final source = _sources[sourceId];
    final scalarOffset = source?.scalarOffsetAtCodeUnit(codeUnitOffset);
    if (scalarOffset == null) {
      throw SourceLocationException._(
        code: _positionOutOfRangeCode,
        context: context,
        fields: <String, Object?>{
          'source_id': sourceId,
          'position_offset': codeUnitOffset,
          'source_length': source?.scalarLength ?? 0,
        },
      );
    }
    return position(sourceId: sourceId, offset: scalarOffset, context: context);
  }

  /// Returns the Unicode-scalar length of an owned decoded source, if known.
  int? sourceScalarLength(String sourceId) => _sources[sourceId]?.scalarLength;

  /// Constructs and validates one direct half-open span.
  Span directSpan({
    required Position start,
    required Position end,
    required String provenance,
    required SourceLocationContext context,
  }) {
    if (start._sourceId != end._sourceId ||
        start._authorityId != end._authorityId ||
        start._authorityId != _authorityId) {
      throw SourceLocationException._(
        code: _sourceMismatchCode,
        context: context,
        fields: <String, Object?>{
          'source_id': start._sourceId,
          'other_source_id': end._sourceId,
        },
      );
    }
    if (start._offset > end._offset) {
      throw SourceLocationException._(
        code: _reversedSpanCode,
        context: context,
        fields: <String, Object?>{
          'source_id': start._sourceId,
          'start_offset': start._offset,
          'end_offset': end._offset,
        },
      );
    }
    return Span._(
      authorityId: _authorityId,
      sourceId: start._sourceId,
      start: start._offset,
      end: end._offset,
      provenance: provenance,
    );
  }

  /// Constructs and validates explicitly ordered derived text.
  DerivedText derivedText({
    required DerivedTextPolicy policy,
    required List<Span> spans,
    required SourceLocationContext context,
  }) {
    for (var index = 0; index < spans.length; index += 1) {
      final span = spans[index];
      if (span._authorityId != _authorityId ||
          !_sources.containsKey(span._sourceId)) {
        throw SourceLocationException._(
          code: _invalidDerivedProvenanceCode,
          context: context,
          fields: <String, Object?>{
            'provenance_index': index,
            'source_id': span._sourceId,
          },
        );
      }
    }
    return DerivedText._(
      authorityId: _authorityId,
      policy: policy,
      spans: spans,
    );
  }

  /// Derives one-based line/column and UTF-8 byte evidence for a position.
  SourceCoordinates coordinates(
    Position position, {
    required SourceLocationContext context,
  }) {
    final source = _sources[position._sourceId];
    if (position._authorityId != _authorityId ||
        source == null ||
        !source.containsBoundary(position._offset)) {
      throw SourceLocationException._(
        code: _positionOutOfRangeCode,
        context: context,
        fields: <String, Object?>{
          'source_id': position._sourceId,
          'position_offset': position._offset,
          'source_length': source?.scalarLength ?? 0,
        },
      );
    }
    final offset = position._offset;
    return SourceCoordinates._(
      sourceId: position._sourceId,
      offset: offset,
      line: source._lineAtScalar[offset],
      column: source._columnAtScalar[offset],
      utf8ByteOffset: source._utf8ByteAtScalar[offset],
    );
  }

  /// Materializes one direct span or explicitly derived text.
  String materialize(Object value, {required SourceLocationContext context}) {
    if (value is Span) {
      return _materializeSpan(value, context: context, provenanceIndex: 0);
    }
    if (value is DerivedText) {
      if (value._authorityId != _authorityId) {
        throw SourceLocationException._(
          code: _invalidDerivedProvenanceCode,
          context: context,
          fields: <String, Object?>{
            'provenance_index': 0,
            'source_id': value._spans.isEmpty
                ? ''
                : value._spans.first._sourceId,
          },
        );
      }
      final buffer = StringBuffer();
      for (var index = 0; index < value._spans.length; index += 1) {
        buffer.write(
          _materializeSpan(
            value._spans[index],
            context: context,
            provenanceIndex: index,
          ),
        );
      }
      return buffer.toString();
    }
    throw ArgumentError.value(
      value,
      'value',
      'must be a typed direct span or derived text',
    );
  }

  String _materializeSpan(
    Span span, {
    required SourceLocationContext context,
    required int provenanceIndex,
  }) {
    final source = _sources[span._sourceId];
    if (span._authorityId != _authorityId ||
        source == null ||
        !source.containsBoundary(span._start) ||
        !source.containsBoundary(span._end) ||
        span._start > span._end) {
      throw SourceLocationException._(
        code: _invalidDerivedProvenanceCode,
        context: context,
        fields: <String, Object?>{
          'provenance_index': provenanceIndex,
          'source_id': span._sourceId,
        },
      );
    }
    return source.slice(span._start, span._end);
  }
}

Map<String, Object?> _spanRecord(Span span) => <String, Object?>{
  'source_id': span._sourceId,
  'start': span._start,
  'end': span._end,
  'provenance': span._provenance,
};
