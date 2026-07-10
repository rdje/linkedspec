import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/src/cli/primary_cli.dart';
import 'package:test/test.dart';

void main() {
  test('renders the exact shared help template for the Dart token', () {
    final expected = File('../cli_conformance/cases/help/stdout.txt')
        .readAsStringSync()
        .replaceAll('{{COMMAND}}', linkedspecDartDisplayCommand);

    final output = runLinkedSpecDartPrimaryCli(const ['--help']);

    expect(output.exitCode, 0);
    expect(output.stderrBytes, isEmpty);
    expect(output.stdoutBytes, utf8.encode(expected));
  });

  test('rejects case drift, abbreviations, and positionals in order', () {
    final output = runLinkedSpecDartPrimaryCli(const [
      'one',
      '--UNKNOWN',
      '--inl=Top:: /x/',
      'two',
    ]);

    expect(output.exitCode, 2);
    expect(output.stdoutBytes, isEmpty);
    expect(
      utf8.decode(output.stderrBytes),
      startsWith(
        "linkedspec: unexpected positional argument 'one'; "
        "unknown option '--UNKNOWN'; unknown option '--inl'; "
        "unexpected positional argument 'two'\n\nUsage:\n",
      ),
    );
  });

  test('compiles source before loading a deferred input file', () {
    final root = Directory.systemTemp.createTempSync(
      'linkedspec-dart-primary-order-',
    );
    try {
      final output = runLinkedSpecDartPrimaryCli(
        const [
          '--inline-spec',
          'not a spec',
          '--input-file',
          'also-missing.txt',
        ],
        workingDirectory: root,
        repositoryRoot: Directory('..'),
      );

      expect(output.exitCode, 1);
      expect(
        output.stderrBytes,
        utf8.encode('linkedspec: parser compilation failed\n'),
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('keeps malformed source and input bytes in their owning phases', () {
    final root = Directory.systemTemp.createTempSync(
      'linkedspec-dart-primary-utf8-',
    );
    try {
      File('${root.path}/invalid.bin').writeAsBytesSync([0xC3, 0x28]);
      final sourceOutput = runLinkedSpecDartPrimaryCli(
        const ['--spec-file', 'invalid.bin', '--input', 'x'],
        workingDirectory: root,
        repositoryRoot: Directory('..'),
      );
      final inputOutput = runLinkedSpecDartPrimaryCli(
        const ['--inline-spec', 'Top::\n /x/\n', '--input-file', 'invalid.bin'],
        workingDirectory: root,
        repositoryRoot: Directory('..'),
      );

      expect(sourceOutput.exitCode, 1);
      expect(
        sourceOutput.stderrBytes,
        utf8.encode('linkedspec: parser compilation failed\n'),
      );
      expect(inputOutput.exitCode, 1);
      expect(
        inputOutput.stderrBytes,
        utf8.encode('linkedspec: input load failed\n'),
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('strict UTF-8 loading preserves a leading BOM and newlines', () {
    final root = Directory.systemTemp.createTempSync(
      'linkedspec-dart-primary-bom-',
    );
    try {
      final file = File('${root.path}/text.txt')
        ..writeAsBytesSync([0xEF, 0xBB, 0xBF, ...utf8.encode('é\r\n')]);

      expect(readPrimaryCliStrictUtf8File(file), '\uFEFFé\r\n');

      final source = File('${root.path}/bom.spec')
        ..writeAsBytesSync([0xEF, 0xBB, 0xBF, ...utf8.encode('Top::\n /x/\n')]);
      final output = runLinkedSpecDartPrimaryCli(
        ['--spec-file', source.path, '--input', 'x'],
        workingDirectory: root,
        repositoryRoot: Directory('..'),
      );
      expect(output.exitCode, 1);
      expect(
        output.stderrBytes,
        utf8.encode('linkedspec: parser compilation failed\n'),
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('named resolution prefers cwd exact, cwd suffix, then repo specs', () {
    final root = Directory.systemTemp.createTempSync(
      'linkedspec-dart-primary-resolve-',
    );
    final cwd = Directory('${root.path}/cwd')..createSync();
    final repo = Directory('${root.path}/repo')..createSync();
    final specs = Directory('${repo.path}/specs')..createSync();
    final exact = File('${cwd.path}/Demo')..writeAsStringSync('exact');
    final suffixed = File('${cwd.path}/Demo.spec')
      ..writeAsStringSync('suffixed');
    final fallback = File('${specs.path}/Demo.spec')
      ..writeAsStringSync('fallback');
    try {
      expect(resolvePrimaryCliNamedSpec('Demo', cwd, repo)?.path, exact.path);
      exact.deleteSync();
      expect(
        resolvePrimaryCliNamedSpec('Demo', cwd, repo)?.path,
        suffixed.path,
      );
      suffixed.deleteSync();
      expect(
        resolvePrimaryCliNamedSpec('Demo', cwd, repo)?.path,
        fallback.path,
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });
}
