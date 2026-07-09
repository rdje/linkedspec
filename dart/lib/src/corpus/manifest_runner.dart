import 'dart:convert';
import 'dart:io';

import '../compiler/compiled_spec.dart';
import '../parser/spec_parser.dart';
import '../runtime/interpreter.dart';
import '../runtime/matching.dart';
import '../validation/spec_validator.dart';

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

final class CorpusExecutionResult {
  CorpusExecutionResult({
    required this.validation,
    required List<CorpusFixtureExecutionResult> results,
  }) : results = List<CorpusFixtureExecutionResult>.unmodifiable(results);

  final CorpusValidationResult validation;
  final List<CorpusFixtureExecutionResult> results;

  bool get passed => failures.isEmpty;

  int get passedCount => results.length - failures.length;

  List<CorpusFixtureExecutionResult> get failures {
    return [
      for (final result in results)
        if (!result.passed) result,
    ];
  }

  CorpusFixtureExecutionResult fixture(String name) {
    return results.firstWhere((result) => result.name == name);
  }
}

final class CorpusFixtureExecutionResult {
  const CorpusFixtureExecutionResult._({
    required this.name,
    required this.expectedJson,
    required this.actualValue,
    required this.actualOutput,
    required this.matched,
    required this.cursorCodeUnit,
    required this.failure,
  });

  factory CorpusFixtureExecutionResult.success({
    required String name,
    required Object? expectedJson,
    required RuntimeParseResult parseResult,
  }) {
    return CorpusFixtureExecutionResult._(
      name: name,
      expectedJson: expectedJson,
      actualValue: parseResult.value,
      actualOutput: List<Object?>.unmodifiable(parseResult.output),
      matched: parseResult.matched,
      cursorCodeUnit: parseResult.cursorCodeUnit,
      failure: null,
    );
  }

  factory CorpusFixtureExecutionResult.failure({
    required String name,
    required Object? expectedJson,
    required String failure,
    RuntimeParseResult? parseResult,
  }) {
    return CorpusFixtureExecutionResult._(
      name: name,
      expectedJson: expectedJson,
      actualValue: parseResult?.value,
      actualOutput: parseResult == null
          ? null
          : List<Object?>.unmodifiable(parseResult.output),
      matched: parseResult?.matched,
      cursorCodeUnit: parseResult?.cursorCodeUnit,
      failure: failure,
    );
  }

  final String name;
  final Object? expectedJson;
  final Object? actualValue;
  final List<Object?>? actualOutput;
  final bool? matched;
  final int? cursorCodeUnit;
  final String? failure;

  bool get passed => failure == null;
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

CorpusExecutionResult executeCorpusFixtures(
  String corpusPath, {
  LinkedSpecParseMode parseMode = LinkedSpecParseMode.seek,
  Iterable<String> caseNames = const <String>[],
  int offset = 0,
  int? limit,
}) {
  final validation = loadCorpusFixtures(corpusPath);
  final selectedFixtures = _selectExecutionFixtures(
    validation.fixtures,
    caseNames: caseNames,
    offset: offset,
    limit: limit,
  );
  final results = [
    for (final fixture in selectedFixtures)
      _executeFixture(fixture, parseMode: parseMode),
  ];
  return CorpusExecutionResult(validation: validation, results: results);
}

List<CorpusFixture> _selectExecutionFixtures(
  List<CorpusFixture> fixtures, {
  required Iterable<String> caseNames,
  required int offset,
  required int? limit,
}) {
  final requestedNames = caseNames.toList(growable: false);
  if (offset < 0) {
    throw const CorpusManifestException(
      'corpus execution offset must be zero or greater',
    );
  }
  if (limit != null && limit <= 0) {
    throw const CorpusManifestException(
      'corpus execution limit must be greater than zero',
    );
  }

  if (requestedNames.isNotEmpty) {
    if (offset != 0 || limit != null) {
      throw const CorpusManifestException(
        'corpus execution case selection cannot be combined with offset or limit',
      );
    }
    final byName = {for (final fixture in fixtures) fixture.name: fixture};
    final seen = <String>{};
    final selected = <CorpusFixture>[];
    for (final name in requestedNames) {
      if (!seen.add(name)) {
        throw CorpusManifestException(
          'corpus execution selection contains duplicate case name: $name',
        );
      }
      final fixture = byName[name];
      if (fixture == null) {
        throw CorpusManifestException(
          'selected corpus case not found in manifest: $name',
        );
      }
      selected.add(fixture);
    }
    return selected;
  }

  if (offset >= fixtures.length) {
    throw CorpusManifestException(
      'corpus execution offset $offset is outside fixture count ${fixtures.length}',
    );
  }
  final unboundedEnd = fixtures.length;
  final boundedEnd = limit == null ? unboundedEnd : offset + limit;
  final end = boundedEnd > unboundedEnd ? unboundedEnd : boundedEnd;
  return List<CorpusFixture>.unmodifiable(fixtures.sublist(offset, end));
}

CorpusFixtureExecutionResult _executeFixture(
  CorpusFixture fixture, {
  required LinkedSpecParseMode parseMode,
}) {
  try {
    final spec = parseSpec(fixture.specSource);
    final compiled = compileSpec(spec);
    final parseResult = LinkedSpecRuntimeEngine(
      compiled,
      parseMode: parseMode,
      specName: fixture.name,
    ).execute(fixture.inputText);

    if (!parseResult.matched) {
      return CorpusFixtureExecutionResult.failure(
        name: fixture.name,
        expectedJson: fixture.expectedJson,
        parseResult: parseResult,
        failure:
            'runtime did not match input; cursor_code_unit=${parseResult.cursorCodeUnit}',
      );
    }

    final expectedOutput = <Object?>[fixture.expectedJson];
    if (!_jsonEquals(parseResult.output, expectedOutput)) {
      return CorpusFixtureExecutionResult.failure(
        name: fixture.name,
        expectedJson: fixture.expectedJson,
        parseResult: parseResult,
        failure:
            'output mismatch on input ${jsonEncode(fixture.inputText)}\n'
            '    expected (reference, wrapped): ${_formatJson(expectedOutput)}\n'
            '    actual   (engine.execute)    : ${_formatJson(parseResult.output)}',
      );
    }

    return CorpusFixtureExecutionResult.success(
      name: fixture.name,
      expectedJson: fixture.expectedJson,
      parseResult: parseResult,
    );
  } on SpecParseException catch (error) {
    return CorpusFixtureExecutionResult.failure(
      name: fixture.name,
      expectedJson: fixture.expectedJson,
      failure: 'parse failed: ${error.message}',
    );
  } on SpecValidationException catch (error) {
    return CorpusFixtureExecutionResult.failure(
      name: fixture.name,
      expectedJson: fixture.expectedJson,
      failure: 'validate failed: ${error.message}',
    );
  } on CompiledSpecException catch (error) {
    return CorpusFixtureExecutionResult.failure(
      name: fixture.name,
      expectedJson: fixture.expectedJson,
      failure: 'compile failed: ${error.message}',
    );
  } on RuntimeInterpreterException catch (error) {
    return CorpusFixtureExecutionResult.failure(
      name: fixture.name,
      expectedJson: fixture.expectedJson,
      failure: 'execute failed: ${error.message}',
    );
  } on Object catch (error) {
    return CorpusFixtureExecutionResult.failure(
      name: fixture.name,
      expectedJson: fixture.expectedJson,
      failure: 'unexpected failure: $error',
    );
  }
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

bool _jsonEquals(Object? left, Object? right) {
  if (identical(left, right)) {
    return true;
  }
  if (left is num && right is num) {
    return left == right;
  }
  if (left == null || right == null) {
    return left == right;
  }
  if (left is String || left is bool || right is String || right is bool) {
    return left == right;
  }
  if (left is List && right is List) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index += 1) {
      if (!_jsonEquals(left[index], right[index])) {
        return false;
      }
    }
    return true;
  }
  if (left is Map && right is Map) {
    if (left.length != right.length) {
      return false;
    }
    for (final entry in left.entries) {
      final key = entry.key;
      if (!right.containsKey(key) || !_jsonEquals(entry.value, right[key])) {
        return false;
      }
    }
    return true;
  }
  return false;
}

String _formatJson(Object? value) {
  return jsonEncode(_canonicalJson(value));
}

Object? _canonicalJson(Object? value) {
  if (value is List) {
    return [for (final item in value) _canonicalJson(item)];
  }
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return {for (final key in keys) key: _canonicalJson(value[key])};
  }
  return value;
}
