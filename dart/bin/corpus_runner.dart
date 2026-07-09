import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';

const _usage = '''
Usage: dart run bin/corpus_runner.dart --corpus <path>

LinkedSpec Dart corpus-runner scaffold.
Loads and validates the manifest-backed corpus directory without executing parser semantics.
''';

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    print(_usage.trimRight());
    return;
  }

  final corpusPath = _corpusPathFromArgs(args);
  if (corpusPath == null) {
    stderr.writeln(_usage.trimRight());
    exitCode = 64;
    return;
  }

  try {
    final result = loadCorpusFixtures(corpusPath);
    print(
      '$linkedSpecDartPackageName corpus scaffold loaded '
      '${result.fixtures.length} fixture(s) from ${result.root.path}',
    );
  } on CorpusManifestException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

String? _corpusPathFromArgs(List<String> args) {
  for (var index = 0; index < args.length; index += 1) {
    final arg = args[index];
    if (arg == '--corpus') {
      if (index + 1 >= args.length) {
        return null;
      }
      return args[index + 1];
    }
    if (arg.startsWith('--corpus=')) {
      return arg.substring('--corpus='.length);
    }
  }
  return null;
}
