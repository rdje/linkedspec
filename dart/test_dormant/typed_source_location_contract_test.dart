// FUTURE-PARITY-BACKLOG.14.2.3.0.2 — dormant Dart typed source-location RED.
//
// Ordinary `dart test` does not discover this pre-admission directory. Run the
// explicit contract through repository-local project data:
//
//   cd dart
//   bash ../tools/run_dart_project_data.sh test \
//     test_dormant/typed_source_location_contract_test.dart
//
// The immutable core is present and analyzed. Admission moves this consumer
// under ordinary discovery only after all four tests pass.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/runtime/source_location.dart' as typed;
import 'package:test/test.dart';

typedef _JsonObject = Map<String, Object?>;

final _JsonObject _contract = _readObject(
  '../capability_conformance/typed_source_location_contract.json',
);

const _context = typed.SourceLocationContext(
  ruleRole: 'typed_source_fixture_rule',
  invocationRole: 'typed_source_fixture_invocation',
);

const _cursorSource = r'''
Top::
 /ab/ -> Done {
  after_match = cursor_pos()
  save_cursor()
  rewind_match_start()
  match_start = cursor_pos()
  restore_cursor()
  restored_match = cursor_pos()
  save_cursor()
  rewind_entry_start()
  entry_start = cursor_pos()
  restore_cursor()
  restored_entry = cursor_pos()
  return(hash(
   "after_match", after_match,
   "match_start", match_start,
   "restored_match", restored_match,
   "entry_start", entry_start,
   "restored_entry", restored_entry
  ))
 }

Done:
 /ab/
''';

const _cursorExpected = <String, Object?>{
  'after_match': 2,
  'entry_start': 0,
  'match_start': 0,
  'restored_entry': 2,
  'restored_match': 2,
};

const _aliasSource = r'''
Top::OR{1,1}
 /(?<name>ab)/
 I { started = capture_slice_here() }
 E {
  return(array(
   started,
   capture_from_rule_start(),
   capture_len_from_rule_start(),
   capture_slice_length(),
   capture_rest_length(),
   entry_named_map(),
   match_named_map()
  ))
 }
''';

const _aliasExpected = <Object?>[
  null,
  'é🙂  ',
  4,
  4,
  6,
  <String, Object?>{'name': 'ab'},
  <String, Object?>{'name': 'ab'},
];

void main() {
  test('freezes all neutral immutable values and coordinate conversions', () {
    expect(_contract['contract_id'], 'linkedspec-typed-source-location-v1');
    final expectedCounts = _object(_contract['expected_counts']);
    expect(expectedCounts['sources'], 3);
    expect(expectedCounts['position_conversions'], 7);
    expect(expectedCounts['direct_spans'], 6);
    expect(expectedCounts['derived_text_cases'], 3);

    final sources = _decodedSources();
    final authority = typed.SourceAuthority(sources: sources);
    final positions = <String, typed.Position>{};
    typed.Position position(String sourceId, int offset) =>
        positions.putIfAbsent(
          '$sourceId\u0000$offset',
          () => authority.position(
            sourceId: sourceId,
            offset: offset,
            context: _context,
          ),
        );

    for (final fixture in _objectRows('position_conversions')) {
      final sourceId = fixture['source_id']! as String;
      final offset = fixture['offset']! as int;
      final value = position(sourceId, offset);
      expect(value.toJson(), {'source_id': sourceId, 'offset': offset});
      expect(authority.coordinates(value, context: _context).toJson(), {
        'source_id': sourceId,
        'offset': offset,
        'line': fixture['line'],
        'column': fixture['column'],
        'utf8_byte_offset': fixture['utf8_byte_offset'],
      });
    }

    final stablePosition = positions['unicode\u00001']!;
    final detachedPosition = stablePosition.toJson()..['offset'] = 99;
    expect(detachedPosition['offset'], 99);
    expect(stablePosition.toJson()['offset'], 1);

    final spans = <String, typed.Span>{};
    for (final fixture in _objectRows('direct_spans')) {
      final sourceId = fixture['source_id']! as String;
      final start = fixture['start']! as int;
      final end = fixture['end']! as int;
      final provenance = fixture['provenance']! as String;
      final span = authority.directSpan(
        start: position(sourceId, start),
        end: position(sourceId, end),
        provenance: provenance,
        context: _context,
      );
      spans[fixture['id']! as String] = span;
      expect(span.toJson(), {
        'source_id': sourceId,
        'start': start,
        'end': end,
        'provenance': provenance,
      });
      expect(
        authority.materialize(span, context: _context),
        fixture['expected_text'],
      );
    }

    for (final fixture in _objectRows('derived_text_cases')) {
      final orderedSpans = _list(
        fixture['span_ids'],
      ).cast<String>().map((id) => spans[id]!).toList(growable: false);
      final derived = authority.derivedText(
        policy: typed.DerivedTextPolicy.concatenateInOrder,
        spans: orderedSpans,
        context: _context,
      );
      expect(derived.toJson(), {
        'policy': 'concatenate_in_order',
        'spans': [for (final span in orderedSpans) span.toJson()],
      });
      expect(
        authority.materialize(derived, context: _context),
        fixture['expected_text'],
      );
    }
  });

  test('freezes authority ownership and four exact private diagnostics', () {
    final sources = _decodedSources();
    final authority = typed.SourceAuthority(sources: sources);
    sources['unicode'] = 'changed';

    typed.Position position(String sourceId, int offset) => authority.position(
      sourceId: sourceId,
      offset: offset,
      context: _context,
    );

    final ownedSpan = authority.directSpan(
      start: position('unicode', 0),
      end: position('unicode', 1),
      provenance: 'input',
      context: _context,
    );
    expect(authority.materialize(ownedSpan, context: _context), 'é');

    _expectDiagnostic(
      'source_mismatch',
      () => authority.directSpan(
        start: position('unicode', 0),
        end: position('ascii', 1),
        provenance: 'input',
        context: _context,
      ),
      {
        'rule_role': _context.ruleRole,
        'invocation_role': _context.invocationRole,
        'source_id': 'unicode',
        'other_source_id': 'ascii',
      },
    );
    _expectDiagnostic('position_out_of_range', () => position('unicode', 5), {
      'rule_role': _context.ruleRole,
      'invocation_role': _context.invocationRole,
      'source_id': 'unicode',
      'position_offset': 5,
      'source_length': 4,
    });
    _expectDiagnostic(
      'reversed_span',
      () => authority.directSpan(
        start: position('unicode', 2),
        end: position('unicode', 1),
        provenance: 'capture',
        context: _context,
      ),
      {
        'rule_role': _context.ruleRole,
        'invocation_role': _context.invocationRole,
        'source_id': 'unicode',
        'start_offset': 2,
        'end_offset': 1,
      },
    );

    final foreignAuthority = typed.SourceAuthority(
      sources: const {'foreign': 'foreign text'},
    );
    final foreignSpan = foreignAuthority.directSpan(
      start: foreignAuthority.position(
        sourceId: 'foreign',
        offset: 0,
        context: _context,
      ),
      end: foreignAuthority.position(
        sourceId: 'foreign',
        offset: 1,
        context: _context,
      ),
      provenance: 'input',
      context: _context,
    );
    _expectDiagnostic(
      'invalid_derived_provenance',
      () => authority.derivedText(
        policy: typed.DerivedTextPolicy.concatenateInOrder,
        spans: [foreignSpan],
        context: _context,
      ),
      {
        'rule_role': _context.ruleRole,
        'invocation_role': _context.invocationRole,
        'provenance_index': 0,
        'source_id': 'foreign',
      },
    );
  });

  test('freezes detached exact 92 projection rows and seven aliases', () {
    final dynamic projectionApi = LinkedSpecRuntimeEngine(
      _compile('Top::\n I { return("ok") }\n'),
    );
    final expectedRows = _object(_contract['helper_projections']);
    final rows = _object(projectionApi.typedSourceProjectionRows());
    expect(rows, expectedRows);

    final families = _list(
      _object(_contract['helper_projection_schema'])['families'],
    ).cast<String>();
    final names = <String>[];
    for (final family in families) {
      names.addAll(
        _list(rows[family]).map((row) => _list(row).first as String),
      );
    }
    expect(names, hasLength(92));
    expect(names.toSet(), hasLength(92));

    final expectedAliases = _list(_contract['compatibility_aliases']);
    expect(projectionApi.typedSourceCompatibilityAliases(), expectedAliases);
    expect(expectedAliases, hasLength(7));

    final captureRows = _list(rows['capture_mark']);
    _list(captureRows.first)[1] = 'wrong';
    expect(projectionApi.typedSourceProjectionRows(), expectedRows);
  });

  test('preserves mark capture cursor and alias results on all carriers', () {
    final namedMarkContract = _readObject(
      '../capability_conformance/complete_named_mark_contract.json',
    );
    final fixture = _object(namedMarkContract['fixture']);
    _assertCarriers(
      fixture['spec_source']! as String,
      fixture['input']! as String,
      'typed-source/complete-named-mark.spec',
      fixture['expected'],
    );
    _assertCarriers(
      _cursorSource,
      'ab',
      'typed-source/cursor-control.spec',
      _cursorExpected,
    );
    _assertCarriers(
      _aliasSource,
      'é🙂  ab',
      'typed-source/compatibility-aliases.spec',
      _aliasExpected,
    );
  });
}

Map<String, String> _decodedSources() => {
  for (final fixture in _objectRows('sources'))
    fixture['id']! as String: fixture['decoded_text']! as String,
};

void _expectDiagnostic(
  String diagnosticId,
  Object? Function() operation,
  _JsonObject expectedContext,
) {
  typed.SourceLocationException? captured;
  try {
    operation();
  } on typed.SourceLocationException catch (error) {
    captured = error;
  }
  expect(captured, isNotNull, reason: '$diagnosticId must fail');

  final diagnostic = _objectRows(
    'diagnostics',
  ).singleWhere((row) => row['id'] == diagnosticId);
  final record = captured!.toJson();
  expect(record['code'], diagnostic['code'], reason: diagnosticId);
  expect(record['phase'], diagnostic['phase'], reason: diagnosticId);
  for (final field in _list(diagnostic['required_context']).cast<String>()) {
    expect(record, contains(field), reason: '$diagnosticId $field');
  }
  for (final entry in expectedContext.entries) {
    expect(
      record[entry.key],
      entry.value,
      reason: '$diagnosticId ${entry.key}',
    );
  }
  for (final forbidden in const [
    'decoded_text',
    'source_text',
    'path',
    'match',
    'parser_state',
    'host_reference',
  ]) {
    expect(record, isNot(contains(forbidden)), reason: '$diagnosticId privacy');
  }
}

void _assertCarriers(
  String source,
  String input,
  String identity,
  Object? expected,
) {
  final parsed = parseSpec(source);
  validateSpec(parsed);
  final compiled = compileSpec(parsed);
  expect(
    LinkedSpecRuntimeEngine(compiled).parse(input).value,
    expected,
    reason: 'native $identity',
  );

  final reconstructed = SpecFile.fromJson(
    _object(jsonDecode(jsonEncode(parsed.toJson()))),
  );
  validateSpec(reconstructed);
  final reconstructedCompiled = compileSpec(reconstructed);
  expect(
    LinkedSpecRuntimeEngine(reconstructedCompiled).parse(input).value,
    expected,
    reason: 'reconstructed $identity',
  );

  expect(
    executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      input,
      identity,
    ),
    expected,
    reason: 'generated plan $identity',
  );
}

CompiledSpec _compile(String source) {
  final parsed = parseSpec(source);
  validateSpec(parsed);
  return compileSpec(parsed);
}

List<_JsonObject> _objectRows(String key) =>
    _list(_contract[key]).map(_object).toList(growable: false);

_JsonObject _readObject(String path) =>
    _object(jsonDecode(File(path).readAsStringSync()));

_JsonObject _object(Object? value) => (value! as Map).cast<String, Object?>();

List<Object?> _list(Object? value) => (value! as List).cast<Object?>();
