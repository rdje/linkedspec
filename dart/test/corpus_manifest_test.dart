import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('loads checked-in corpus manifest and fixture files', () {
    final result = loadCorpusFixtures(
      '../rust/linkedspec-runtime/tests/corpus',
    );

    expect(result.manifest.format, 1);
    expect(result.manifest.caseCount, result.manifest.cases.length);
    expect(result.fixtures, hasLength(result.manifest.caseCount));
    expect(result.fixtures.first.specSource, isNotEmpty);
  });

  test('detects missing fixture directory', () {
    final root = Directory.systemTemp.createTempSync(
      'linkedspec-dart-missing-',
    );
    try {
      _writeManifest(root, ['alpha', 'beta']);
      _writeFixture(root, 'alpha');

      expect(
        () => loadCorpusFixtures(root.path),
        throwsA(
          isA<CorpusManifestException>().having(
            (error) => error.message,
            'message',
            contains('missing fixture dirs: [beta]'),
          ),
        ),
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('detects stale extra fixture directory', () {
    final root = Directory.systemTemp.createTempSync('linkedspec-dart-extra-');
    try {
      _writeManifest(root, ['alpha']);
      _writeFixture(root, 'alpha');
      _writeFixture(root, 'stale');

      expect(
        () => loadCorpusFixtures(root.path),
        throwsA(
          isA<CorpusManifestException>().having(
            (error) => error.message,
            'message',
            contains('extra fixture dirs: [stale]'),
          ),
        ),
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('rejects case count mismatch', () {
    final root = Directory.systemTemp.createTempSync('linkedspec-dart-count-');
    try {
      _writeManifest(root, ['alpha'], caseCount: 2);
      _writeFixture(root, 'alpha');

      expect(
        () => loadCorpusFixtures(root.path),
        throwsA(
          isA<CorpusManifestException>().having(
            (error) => error.message,
            'message',
            contains('case_count=2 does not match cases.len()=1'),
          ),
        ),
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('rejects missing required fixture file', () {
    final root = Directory.systemTemp.createTempSync('linkedspec-dart-file-');
    try {
      _writeManifest(root, ['alpha']);
      _writeFixture(root, 'alpha', writeExpected: false);

      expect(
        () => loadCorpusFixtures(root.path),
        throwsA(
          isA<CorpusManifestException>().having(
            (error) => error.message,
            'message',
            contains('expected.json'),
          ),
        ),
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });
}

void _writeManifest(Directory root, List<String> cases, {int? caseCount}) {
  final manifest = {
    'format': 1,
    'case_count': caseCount ?? cases.length,
    'cases': cases,
  };
  _childFile(root, 'manifest.json').writeAsStringSync(jsonEncode(manifest));
}

void _writeFixture(Directory root, String name, {bool writeExpected = true}) {
  final fixture = _childDirectory(root, name)..createSync();
  _childFile(fixture, 'input.spec').writeAsStringSync('Top:: /x/');
  _childFile(fixture, 'input.txt').writeAsStringSync('x');
  if (writeExpected) {
    _childFile(fixture, 'expected.json').writeAsStringSync(jsonEncode([]));
  }
}

Directory _childDirectory(Directory parent, String name) {
  return Directory('${parent.path}${Platform.pathSeparator}$name');
}

File _childFile(Directory parent, String name) {
  return File('${parent.path}${Platform.pathSeparator}$name');
}
