import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';

const _usage = '''
Usage: dart run bin/corpus_runner.dart --corpus <path> [--execute] [--case <name> ...] [--offset <n>] [--limit <n>]

LinkedSpec Dart corpus-runner scaffold.
Without --execute, loads and validates the manifest-backed corpus directory.
With --execute, runs selected fixtures through the current Dart parser, compiler, and runtime.
Until full corpus parity lands, --execute requires --case or --limit.
''';

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    print(_usage.trimRight());
    return;
  }

  final options = _CorpusRunnerOptions.parse(args);
  if (options.error != null) {
    stderr.writeln(options.error);
    stderr.writeln(_usage.trimRight());
    exitCode = 64;
    return;
  }

  try {
    if (options.execute) {
      final result = executeCorpusFixtures(
        options.corpusPath!,
        caseNames: options.caseNames,
        offset: options.offset,
        limit: options.limit,
      );
      for (final fixture in result.results) {
        if (fixture.passed) {
          print('PASS ${fixture.name}');
        } else {
          print(
            'FAIL ${fixture.name}: ${fixture.failure ?? 'unknown failure'}',
          );
        }
      }
      final failed = result.failures.length;
      print(
        '$linkedSpecDartPackageName corpus execution ran '
        '${result.results.length} fixture(s) from ${result.validation.root.path}: '
        '${result.passedCount} passed, $failed failed',
      );
      if (failed > 0) {
        exitCode = 1;
      }
      return;
    }

    final result = loadCorpusFixtures(options.corpusPath!);
    print(
      '$linkedSpecDartPackageName corpus scaffold loaded '
      '${result.fixtures.length} fixture(s) from ${result.root.path}',
    );
  } on CorpusManifestException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

final class _CorpusRunnerOptions {
  const _CorpusRunnerOptions({
    required this.corpusPath,
    required this.execute,
    required this.caseNames,
    required this.offset,
    required this.limit,
    required this.error,
  });

  factory _CorpusRunnerOptions.parse(List<String> args) {
    String? corpusPath;
    var execute = false;
    final caseNames = <String>[];
    var offset = 0;
    int? limit;
    String? error;

    String? nextValue(String flag, int index) {
      if (index + 1 >= args.length) {
        error = '$flag requires a value';
        return null;
      }
      return args[index + 1];
    }

    int? parseNonNegativeInt(String flag, String value) {
      final parsed = int.tryParse(value);
      if (parsed == null || parsed < 0) {
        error = '$flag requires a non-negative integer';
        return null;
      }
      return parsed;
    }

    for (var index = 0; index < args.length && error == null; index += 1) {
      final arg = args[index];
      if (arg == '--execute') {
        execute = true;
      } else if (arg == '--corpus') {
        corpusPath = nextValue(arg, index);
        index += 1;
      } else if (arg.startsWith('--corpus=')) {
        corpusPath = arg.substring('--corpus='.length);
      } else if (arg == '--case') {
        final value = nextValue(arg, index);
        if (value != null) {
          caseNames.add(value);
        }
        index += 1;
      } else if (arg.startsWith('--case=')) {
        caseNames.add(arg.substring('--case='.length));
      } else if (arg == '--offset') {
        final value = nextValue(arg, index);
        if (value != null) {
          offset = parseNonNegativeInt(arg, value) ?? offset;
        }
        index += 1;
      } else if (arg.startsWith('--offset=')) {
        offset =
            parseNonNegativeInt(arg, arg.substring('--offset='.length)) ??
            offset;
      } else if (arg == '--limit') {
        final value = nextValue(arg, index);
        if (value != null) {
          limit = parseNonNegativeInt(arg, value);
        }
        index += 1;
      } else if (arg.startsWith('--limit=')) {
        limit = parseNonNegativeInt(arg, arg.substring('--limit='.length));
      } else {
        error = 'unknown argument: $arg';
      }
    }

    if (error == null && (corpusPath == null || corpusPath.isEmpty)) {
      error = '--corpus requires a path';
    }
    if (error == null &&
        !execute &&
        (caseNames.isNotEmpty || offset != 0 || limit != null)) {
      error = '--case, --offset, and --limit require --execute';
    }
    if (error == null && execute && caseNames.isEmpty && limit == null) {
      error =
          '--execute requires --case or --limit until full corpus parity is enabled';
    }
    if (error == null && limit == 0) {
      error = '--limit requires a value greater than zero';
    }

    return _CorpusRunnerOptions(
      corpusPath: corpusPath,
      execute: execute,
      caseNames: List<String>.unmodifiable(caseNames),
      offset: offset,
      limit: limit,
      error: error,
    );
  }

  final String? corpusPath;
  final bool execute;
  final List<String> caseNames;
  final int offset;
  final int? limit;
  final String? error;
}
