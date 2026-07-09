import 'dart:convert';
import 'dart:io';

final class CorpusManifestException implements Exception {
  const CorpusManifestException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class CorpusManifest {
  const CorpusManifest({
    required this.format,
    required this.caseCount,
    required this.cases,
  });

  final int format;
  final int caseCount;
  final List<String> cases;
}

final class CorpusFixture {
  const CorpusFixture({
    required this.name,
    required this.specSource,
    required this.inputText,
    required this.expectedJson,
  });

  final String name;
  final String specSource;
  final String inputText;
  final Object? expectedJson;
}

final class CorpusValidationResult {
  const CorpusValidationResult({
    required this.root,
    required this.manifest,
    required this.fixtures,
  });

  final Directory root;
  final CorpusManifest manifest;
  final List<CorpusFixture> fixtures;
}

CorpusValidationResult loadCorpusFixtures(String corpusPath) {
  final root = Directory(corpusPath);
  if (!root.existsSync()) {
    throw CorpusManifestException('corpus directory missing: ${root.path}');
  }

  final manifest = _loadManifest(root);
  _assertManifestMatchesDirectories(root, manifest);

  final fixtures = [
    for (final caseName in manifest.cases) _loadFixture(root, caseName),
  ];

  return CorpusValidationResult(
    root: root,
    manifest: manifest,
    fixtures: fixtures,
  );
}

CorpusManifest _loadManifest(Directory root) {
  final manifestFile = _childFile(root, 'manifest.json');
  if (!manifestFile.existsSync()) {
    throw CorpusManifestException(
      'cannot read corpus manifest ${manifestFile.path}: file does not exist',
    );
  }

  final Object? decoded;
  try {
    decoded = jsonDecode(manifestFile.readAsStringSync());
  } on FormatException catch (error) {
    throw CorpusManifestException(
      'malformed corpus manifest ${manifestFile.path}: ${error.message}',
    );
  }

  if (decoded is! Map) {
    throw CorpusManifestException(
      'malformed corpus manifest ${manifestFile.path}: top-level value must be an object',
    );
  }

  final manifestMap = decoded.cast<String, Object?>();
  final format = _requiredInt(manifestMap, 'format', manifestFile);
  if (format != 1) {
    throw CorpusManifestException(
      'unsupported corpus manifest format $format in ${manifestFile.path}',
    );
  }

  final caseCount = _requiredInt(manifestMap, 'case_count', manifestFile);
  final cases = _requiredStringList(manifestMap, 'cases', manifestFile);
  if (caseCount != cases.length) {
    throw CorpusManifestException(
      'corpus manifest case_count=$caseCount does not match cases.len()=${cases.length}',
    );
  }
  if (caseCount <= 0) {
    throw const CorpusManifestException(
      'corpus manifest must name at least one fixture',
    );
  }

  _validateCaseNames(cases);
  return CorpusManifest(format: format, caseCount: caseCount, cases: cases);
}

int _requiredInt(Map<String, Object?> manifest, String key, File manifestFile) {
  final value = manifest[key];
  if (value is! int) {
    throw CorpusManifestException(
      'malformed corpus manifest ${manifestFile.path}: field $key must be an integer',
    );
  }
  return value;
}

List<String> _requiredStringList(
  Map<String, Object?> manifest,
  String key,
  File manifestFile,
) {
  final value = manifest[key];
  if (value is! List) {
    throw CorpusManifestException(
      'malformed corpus manifest ${manifestFile.path}: field $key must be an array',
    );
  }

  final result = <String>[];
  for (final item in value) {
    if (item is! String) {
      throw CorpusManifestException(
        'malformed corpus manifest ${manifestFile.path}: field $key must contain only strings',
      );
    }
    result.add(item);
  }
  return result;
}

void _validateCaseNames(List<String> cases) {
  final seen = <String>{};
  for (final name in cases) {
    if (name.isEmpty ||
        name.contains('/') ||
        name.contains(r'\') ||
        name == '.' ||
        name == '..') {
      throw CorpusManifestException('invalid corpus manifest case name: $name');
    }
    if (!seen.add(name)) {
      throw const CorpusManifestException(
        'corpus manifest contains duplicate case names',
      );
    }
  }
}

void _assertManifestMatchesDirectories(
  Directory root,
  CorpusManifest manifest,
) {
  final expected = manifest.cases.toSet();
  final actual = _directoryCaseNames(root);
  final missing = _difference(expected, actual);
  final extra = _difference(actual, expected);
  if (missing.isNotEmpty || extra.isNotEmpty) {
    throw CorpusManifestException(
      'oracle corpus manifest drift\n'
      '  missing fixture dirs: ${_formatNames(missing)}\n'
      '  extra fixture dirs: ${_formatNames(extra)}\n'
      'regenerate with `perl tools/gen_oracle_corpus.pl` and stage the manifest plus fixture dirs',
    );
  }
}

Set<String> _directoryCaseNames(Directory root) {
  final result = <String>{};
  for (final entity in root.listSync(followLinks: false)) {
    if (entity is Directory) {
      result.add(_basename(entity));
    }
  }
  return result;
}

List<String> _difference(Set<String> left, Set<String> right) {
  return left.difference(right).toList()..sort();
}

CorpusFixture _loadFixture(Directory root, String caseName) {
  final caseDir = _childDirectory(root, caseName);
  final specFile = _requiredFixtureFile(caseDir, 'input.spec');
  final inputFile = _requiredFixtureFile(caseDir, 'input.txt');
  final expectedFile = _requiredFixtureFile(caseDir, 'expected.json');

  final Object? expectedJson;
  try {
    expectedJson = jsonDecode(expectedFile.readAsStringSync());
  } on FormatException catch (error) {
    throw CorpusManifestException(
      'malformed expected.json for corpus case $caseName: ${error.message}',
    );
  }

  return CorpusFixture(
    name: caseName,
    specSource: specFile.readAsStringSync(),
    inputText: inputFile.readAsStringSync(),
    expectedJson: expectedJson,
  );
}

File _requiredFixtureFile(Directory caseDir, String fileName) {
  final file = _childFile(caseDir, fileName);
  if (!file.existsSync()) {
    throw CorpusManifestException('missing required fixture file ${file.path}');
  }
  return file;
}

Directory _childDirectory(Directory parent, String name) {
  return Directory('${parent.path}${Platform.pathSeparator}$name');
}

File _childFile(Directory parent, String name) {
  return File('${parent.path}${Platform.pathSeparator}$name');
}

String _basename(FileSystemEntity entity) {
  final parts = entity.uri.pathSegments.where((part) => part.isNotEmpty);
  return parts.last;
}

String _formatNames(List<String> names) {
  return '[${names.join(', ')}]';
}
