// FUTURE-PARITY-BACKLOG.10.5.1.1 — Dart semantic input/source-map foundation.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

List<int> _fixtureBytes(String name) => File(
  '../capability_conformance/semantic_introspection/$name.spec',
).readAsBytesSync();

SemanticIndexOptions _options(
  String logicalName,
  SemanticSourceDetail detail, {
  String? entryRule,
}) => SemanticIndexOptions(
  logicalName: logicalName,
  sourceDetailCeiling: detail,
  entryRule: entryRule,
);

SemanticIndexError _captureError(void Function() operation) {
  try {
    operation();
  } on SemanticIndexError catch (error) {
    return error;
  }
  fail('expected SemanticIndexError');
}

void main() {
  test('strict byte capture copies source and exposes caller identity only', () {
    final source = _fixtureBytes('graph');
    final index = SemanticIndex.fromUtf8(
      source,
      options: _options('graph.spec', SemanticSourceDetail.text),
    );
    source.fillRange(0, source.length, 0x21);

    expect(
      index.sourceIdentity,
      const SemanticSourceIdentity(
        sourceId: 'source:0',
        logicalName: 'graph.spec',
        byteLength: 128,
        scalarLength: 128,
        contentDigest:
            'sha256:28505ba8524900f55e11452988acc6b7d35dccbccc1c0cb6194c8cda80a0cbcf',
      ),
    );
    final projected = index.sourceIdentity.toJson();
    projected['logical_name'] = '/tmp/private.spec';
    expect(index.sourceIdentity.logicalName, 'graph.spec');
    expect(index.sourceExcerptForBytes(0, 8), 'Top::AND');
    expect(index.toString(), isNot(contains('graph.spec')));
    expect(index.toString(), isNot(contains('/tmp')));
  });

  test('dependency-free SHA-256 matches standard single-block vectors', () {
    final empty = SemanticIndex.fromSource(
      '',
      options: _options('empty.spec', SemanticSourceDetail.text),
    );
    final abc = SemanticIndex.fromUtf8(const [
      0x61,
      0x62,
      0x63,
    ], options: _options('abc.spec', SemanticSourceDetail.text));

    expect(
      empty.sourceIdentity.contentDigest,
      'sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    );
    expect(
      abc.sourceIdentity.contentDigest,
      'sha256:ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });

  test('decoded and byte Unicode inputs converge on canonical coordinates', () {
    final bytes = _fixtureBytes('privacy');
    final raw = SemanticIndex.fromUtf8(
      bytes,
      options: _options('privacy.spec', SemanticSourceDetail.text),
    );
    final decoded = SemanticIndex.fromSource(
      utf8.decode(bytes),
      options: _options('privacy.spec', SemanticSourceDetail.text),
    );

    expect(raw.sourceIdentity, decoded.sourceIdentity);
    expect(raw.sourceIdentity.byteLength, 13);
    expect(raw.sourceIdentity.scalarLength, 11);
    expect(
      raw.sourceSpanForBytes(0, 6),
      const SemanticSourceSpan(
        startByte: 0,
        endByte: 6,
        startLine: 1,
        startColumn: 1,
        endLine: 1,
        endColumn: 6,
      ),
    );
    expect(
      raw.sourceSpanForBytes(8, 12),
      const SemanticSourceSpan(
        startByte: 8,
        endByte: 12,
        startLine: 2,
        startColumn: 2,
        endLine: 2,
        endColumn: 5,
      ),
    );
    expect(raw.sourceSpanForScalars(0, 5), raw.sourceSpanForBytes(0, 6));
    expect(raw.sourceExcerptForBytes(0, 6), 'Töp::');
    expect(raw.sourceExcerptForBytes(8, 12), '/é/');

    final supplementary = SemanticIndex.fromSource(
      '𐐀Rule\r\nX',
      options: _options('supplementary.spec', SemanticSourceDetail.text),
    );
    expect(
      supplementary.sourceSpanForScalars(0, 1),
      const SemanticSourceSpan(
        startByte: 0,
        endByte: 4,
        startLine: 1,
        startColumn: 1,
        endLine: 1,
        endColumn: 2,
      ),
    );
    expect(
      supplementary.sourceSpanForBytes(10, 11),
      const SemanticSourceSpan(
        startByte: 10,
        endByte: 11,
        startLine: 2,
        startColumn: 1,
        endLine: 2,
        endColumn: 2,
      ),
    );
  });

  test('ordered lookup and range failures are exact and deterministic', () {
    final graph = SemanticIndex.fromUtf8(
      _fixtureBytes('graph'),
      options: _options('graph.spec', SemanticSourceDetail.span),
    );
    final starts = <int>[];
    var cursor = 0;
    for (var occurrence = 0; occurrence < 4; occurrence += 1) {
      final span = graph.locateExact('/a/', afterByte: cursor)!;
      starts.add(span.startByte);
      cursor = span.endByte;
    }
    expect(starts, [10, 47, 119, 124]);
    expect(graph.locateExact('/a/', afterByte: cursor), isNull);

    final privacy = SemanticIndex.fromUtf8(
      _fixtureBytes('privacy'),
      options: _options('privacy.spec', SemanticSourceDetail.text),
    );
    final splitStart = _captureError(() => privacy.sourceSpanForBytes(2, 3));
    expect(splitStart.stage, 'map_source');
    expect(splitStart.code, 'semantic_source_boundary_invalid');
    expect(splitStart.fields, {'start_byte': 2});
    final splitEnd = _captureError(() => privacy.sourceSpanForBytes(1, 2));
    expect(splitEnd.fields, {'end_byte': 2});

    final scalarRange = _captureError(
      () => privacy.sourceSpanForScalars(4, 12),
    );
    expect(scalarRange.code, 'semantic_source_range_invalid');
    expect(scalarRange.fields, {'end_scalar': 12, 'start_scalar': 4});
    expect(scalarRange.fields.keys, ['end_scalar', 'start_scalar']);
    expect(
      () => scalarRange.fields['start_scalar'] = 0,
      throwsUnsupportedError,
    );
    final detachedError = scalarRange.toJson();
    (detachedError['fields']! as Map<String, Object?>)['start_scalar'] = 0;
    expect(scalarRange.fields['start_scalar'], 4);
    final afterBoundary = _captureError(
      () => privacy.locateExact('é', afterByte: 2),
    );
    expect(afterBoundary.code, 'semantic_source_boundary_invalid');
    final emptyNeedle = _captureError(() => privacy.locateExact(''));
    expect(emptyNeedle.code, 'semantic_source_needle_invalid');
  });

  test('source ceilings are enforced before foundation values leave', () {
    final bytes = _fixtureBytes('privacy');
    final none = SemanticIndex.fromUtf8(
      bytes,
      options: _options('private/path.spec', SemanticSourceDetail.none),
    );
    final noneError = _captureError(() => none.sourceIdentity);
    expect(noneError.stage, 'apply_source_ceiling');
    expect(noneError.code, 'semantic_source_detail_forbidden');
    expect(noneError.fields, {'ceiling': 'none', 'required': 'identity'});
    expect(none.toString(), isNot(contains('private/path.spec')));

    final identity = SemanticIndex.fromUtf8(
      bytes,
      options: _options('privacy.spec', SemanticSourceDetail.identity),
    );
    expect(identity.sourceIdentity.contentDigest, isNull);
    expect(
      _captureError(() => identity.sourceSpanForBytes(0, 6)).code,
      'semantic_source_detail_forbidden',
    );

    final span = SemanticIndex.fromUtf8(
      bytes,
      options: _options('privacy.spec', SemanticSourceDetail.span),
    );
    expect(span.sourceIdentity.contentDigest, isNull);
    expect(span.sourceSpanForBytes(0, 6).endByte, 6);
    expect(
      _captureError(() => span.sourceExcerptForBytes(0, 6)).code,
      'semantic_source_detail_forbidden',
    );
  });

  test('malformed input and invalid options fail before language parsing', () {
    final malformed = _captureError(
      () => SemanticIndex.fromUtf8([
        0xC3,
        0x28,
      ], options: _options('bad.spec', SemanticSourceDetail.text)),
    );
    expect(malformed.stage, 'decode_source');
    expect(malformed.code, 'semantic_index_invalid_utf8');

    final invalidByte = _captureError(
      () => SemanticIndex.fromUtf8([
        0x100,
      ], options: _options('bad.spec', SemanticSourceDetail.text)),
    );
    expect(invalidByte.stage, 'validate_source');
    expect(invalidByte.code, 'semantic_index_invalid_source');
    expect(invalidByte.fields, {'byte_index': 0, 'value': 256});

    final invalidText = _captureError(
      () => SemanticIndex.fromSource(
        String.fromCharCode(0xD800),
        options: _options('bad.spec', SemanticSourceDetail.text),
      ),
    );
    expect(invalidText.stage, 'decode_source');
    expect(invalidText.code, 'semantic_index_invalid_unicode');

    for (final name in ['', 'private\npath']) {
      final error = _captureError(
        () => SemanticIndex.fromSource(
          'not language syntax',
          options: _options(name, SemanticSourceDetail.text),
        ),
      );
      expect(error.stage, 'validate_options');
      expect(error.code, 'semantic_index_invalid_option');
      expect(error.fields, {'option': 'logical_name'});
    }

    final selector = _captureError(
      () => SemanticIndex.fromSource(
        'not language syntax',
        options: _options(
          'invalid.spec',
          SemanticSourceDetail.text,
          entryRule: 'Bad-Rule',
        ),
      ),
    );
    expect(selector.stage, 'validate_options');
    expect(selector.code, 'semantic_index_invalid_option');
    expect(selector.fields, {'option': 'entry_rule'});

    final languageFailure = SemanticIndex.fromSource(
      'not language syntax',
      options: _options(
        'language-failure.spec',
        SemanticSourceDetail.text,
        entryRule: 'Töp',
      ),
    );
    expect(
      languageFailure.snapshot.state,
      SemanticSnapshotState.failedCompilation,
    );
    expect(languageFailure.compilationAuthority.parsed, isFalse);
    expect(languageFailure.sourceExcerptForBytes(0, 3), 'not');
  });
}
