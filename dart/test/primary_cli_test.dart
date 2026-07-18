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

  test(
    'rejects the removed global parse-mode flag with migration guidance',
    () {
      final output = runLinkedSpecDartPrimaryCli(const [
        '--inline-spec',
        'Top:: /x/',
        '--input',
        'x',
        '--parse-mode',
        'seek',
      ]);

      expect(output.exitCode, 2);
      expect(output.stdoutBytes, isEmpty);
      expect(
        utf8.decode(output.stderrBytes),
        startsWith(
          'linkedspec: --parse-mode has been removed; cursor policy is derived '
          'from each rule (OR/default=seek, AND=consume)\n\nUsage:\n',
        ),
      );
      expect(
        utf8.decode(output.stderrBytes),
        isNot(contains('parse-mode MODE')),
      );
    },
  );

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

  test('--top-rule overrides authored top markers and canonicalizes JSON', () {
    const source = '''
Top::
 /a/ -> Done { return("top") }

Alternate:
 /x/ -> Done { return(hash("z", 0, "a", hash("d", 4, "b", 2))) }

Done::
 /[ax]/
''';

    final output = runLinkedSpecDartPrimaryCli(const [
      '--inline-spec',
      source,
      '--input',
      'x',
      '--top-rule',
      'Alternate',
    ]);

    expect(output.exitCode, 0);
    expect(output.stderrBytes, isEmpty);
    expect(output.stdoutBytes, utf8.encode('{"a":{"b":2,"d":4},"z":0}\n'));
  });

  test('emits the exact low canonical trace before JSON', () {
    final output = runLinkedSpecDartPrimaryCli(const [
      '--inline-spec',
      _traceSpec,
      '--input',
      'x',
      '--trace',
      'low',
    ]);

    expect(output.exitCode, 0);
    expect(output.stderrBytes, isEmpty);
    expect(
      utf8.decode(output.stdoutBytes),
      '[linkedspec][low] compile:start\n'
      '[linkedspec][low] compile:ok\n'
      '[linkedspec][low] input:start\n'
      '[linkedspec][low] input:ok\n'
      '[linkedspec][low] invoke:start\n'
      '[linkedspec][low] invoke:ok\n'
      '"trace"\n',
    );
  });

  test('routes emoji trace with reset while keeping JSON on stdout', () {
    final root = Directory.systemTemp.createTempSync(
      'linkedspec-dart-primary-trace-',
    );
    try {
      final traceFile = File('${root.path}/trace.log')
        ..writeAsStringSync('stale trace\n');
      final output = runLinkedSpecDartPrimaryCli(
        const [
          '--inline-spec',
          _traceSpec,
          '--input',
          'x',
          '--trace',
          'low',
          '--trace-file',
          'trace.log',
          '--trace-mode',
          'route',
          '--trace-reset',
          '--trace-emoji',
        ],
        workingDirectory: root,
        repositoryRoot: Directory('..'),
      );

      expect(output.exitCode, 0);
      expect(utf8.decode(output.stdoutBytes), '"trace"\n');
      expect(output.stderrBytes, isEmpty);
      expect(
        traceFile.readAsStringSync(),
        '[linkedspec][low] ℹ️ compile:start\n'
        '[linkedspec][low] ℹ️ compile:ok\n'
        '[linkedspec][low] ℹ️ input:start\n'
        '[linkedspec][low] ℹ️ input:ok\n'
        '[linkedspec][low] ℹ️ invoke:start\n'
        '[linkedspec][low] ℹ️ invoke:ok\n',
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('maps trace setup failure to stable compilation failure', () {
    final output = runLinkedSpecDartPrimaryCli(const [
      '--inline-spec',
      _traceSpec,
      '--input',
      'x',
      '--trace',
      'low',
      '--trace-file',
      '.',
      '--trace-reset',
    ]);

    expect(output.exitCode, 1);
    expect(output.stdoutBytes, isEmpty);
    expect(
      output.stderrBytes,
      utf8.encode('linkedspec: parser compilation failed\n'),
    );
  });
}

const _traceSpec = '''
Top::
 /x/ -> Done { return("trace") }

Done::
 /x/
''';
