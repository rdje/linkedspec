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

  test('executes portmap corpus fixtures with reference result shapes', () {
    final result = executeCorpusFixtures(
      '../rust/linkedspec-runtime/tests/corpus',
      caseNames: const [
        'portmap_bare',
        'portmap_bit',
        'portmap_slice',
        'portmap_constant',
        'portmap_concatenation',
      ],
    );

    expect(
      result.failures
          .map((failure) => '${failure.name}: ${failure.failure}')
          .join('\n'),
      isEmpty,
    );
    expect(result.passed, isTrue);
    expect(result.passedCount, 5);
    expect(result.fixture('portmap_bare').actualValue, [
      '?bare:',
      ['foo'],
    ]);
    expect(result.fixture('portmap_concatenation').actualValue, [
      '?concatenation:',
      [
        [
          '?bare:',
          ['foo'],
        ],
        [
          '?bit:',
          ['bar', '2'],
        ],
      ],
    ]);
  });

  test('executes hlink corpus fixtures with delimiter capture shapes', () {
    final result = executeCorpusFixtures(
      '../rust/linkedspec-runtime/tests/corpus',
      caseNames: const [
        'hlink_raw_string',
        'hlink_raw_escaped_brackets',
        'hlink_curly_brace',
        'hlink_bracket_body',
        'hlink_mixed_bracket_brace',
      ],
    );

    expect(
      result.failures
          .map((failure) => '${failure.name}: ${failure.failure}')
          .join('\n'),
      isEmpty,
    );
    expect(result.passed, isTrue);
    expect(result.passedCount, 5);
    expect(result.fixture('hlink_raw_string').actualValue, ['plain text']);
    expect(result.fixture('hlink_raw_escaped_brackets').actualValue, [
      r'plain \[text\]',
    ]);
    expect(result.fixture('hlink_curly_brace').actualValue, ['{abc}']);
    expect(result.fixture('hlink_bracket_body').actualValue, ['abc']);
    expect(result.fixture('hlink_mixed_bracket_brace').actualValue, [
      'foo',
      'bar',
      '{baz}',
    ]);
  });

  test('executes helper mutation and text-normalization fixtures', () {
    final result = executeCorpusFixtures(
      '../rust/linkedspec-runtime/tests/corpus',
      caseNames: const [
        'simenv_multiline_value',
        'lib_reader_sattribute',
        'lib_reader_cattribute',
      ],
    );

    expect(
      result.failures
          .map((failure) => '${failure.name}: ${failure.failure}')
          .join('\n'),
      isEmpty,
    );
    expect(result.passed, isTrue);
    expect(result.passedCount, 3);
    expect(result.fixture('simenv_multiline_value').actualValue, [
      {
        'name': 'top',
        'content': [
          [
            {'type': 'anyvariable', 'content': 'BAR'},
            {'type': 'multiline_value', 'content': 'baz'},
          ],
        ],
      },
    ]);
    expect(result.fixture('lib_reader_sattribute').actualValue, [
      [
        'GROUP',
        'cell',
        'foo',
        [
          ['SATTRIBUTE', 'attr', 'bar'],
        ],
      ],
    ]);
    expect(result.fixture('lib_reader_cattribute').actualValue, [
      [
        'GROUP',
        'cell',
        'foo',
        [
          [
            'CATTRIBUTE',
            'attr',
            ['bar', 'baz'],
          ],
        ],
      ],
    ]);
  });

  test('executes legacy structural accumulator fixture', () {
    final result = executeCorpusFixtures(
      '../rust/linkedspec-runtime/tests/corpus',
      caseNames: const ['regdef_nested_register_fields'],
    );

    expect(
      result.failures
          .map((failure) => '${failure.name}: ${failure.failure}')
          .join('\n'),
      isEmpty,
    );
    expect(result.passed, isTrue);
    expect(result.passedCount, 1);
    expect(result.fixture('regdef_nested_register_fields').actualValue, [
      '?regdef_top:',
      [
        [
          '?reg_def:',
          'CTRL',
          [
            ['?reg_fld:', 'ENABLE', 'RW'],
            ['?reg_fld:', 'MODE', 'RO'],
          ],
        ],
      ],
    ]);
  });

  test('executes ds_vhistory leading newline public parser fixture', () {
    final result = executeCorpusFixtures(
      '../rust/linkedspec-runtime/tests/corpus',
      caseNames: const ['ds_vhistory_version_entry'],
    );

    expect(
      result.failures
          .map((failure) => '${failure.name}: ${failure.failure}')
          .join('\n'),
      isEmpty,
    );
    expect(result.passed, isTrue);
    expect(result.passedCount, 1);
    expect(result.fixture('ds_vhistory_version_entry').actualValue, [
      '?ds_vhistory:',
      [
        [
          '?object:',
          null,
          [
            [
              '?version_entry:',
              [
                ['?version:', '1'],
                ['?date:', 'today'],
              ],
            ],
          ],
        ],
      ],
    ]);
  });

  test('executes controlled fixtures against runtime output shape', () {
    final root = Directory.systemTemp.createTempSync(
      'linkedspec-dart-controlled-',
    );
    try {
      _writeManifest(root, [
        'scalar_output',
        'nested_aggregate_output',
        'rule_dispatch_output',
        'lifecycle_output_shape',
      ]);
      _writeFixture(
        root,
        'scalar_output',
        specSource: r'''
Top::
 /x/ -> Done { return("scalar-ok") }

Done::
 /[a-z]+/
''',
        inputText: 'xhello',
        expectedJson: 'scalar-ok',
      );
      _writeFixture(
        root,
        'nested_aggregate_output',
        specSource: r'''
Top::
 /n/ -> Done { return(hash("items", array("a", hash("b", 2)), "flag", true, "none", undef)) }

Done::
 /ested/
''',
        inputText: 'nested',
        expectedJson: {
          'flag': true,
          'items': [
            'a',
            {'b': 2},
          ],
          'none': null,
        },
      );
      _writeFixture(
        root,
        'rule_dispatch_output',
        specSource: r'''
Top::AND
 I { set(array(out), []) }
 => First { push(array(out), retv) }
 => Second { push(array(out), retv) }
 E { return(copy(array(out))) }

First:
 /a/
 E { return("first") }

Second:
 /b/
 E { return("second") }
''',
        inputText: 'ab',
        expectedJson: ['first', 'second'],
      );
      _writeFixture(
        root,
        'lifecycle_output_shape',
        specSource: r'''
Top::OR{1}
 I { push(array(events), "I") }
 LS { push(array(events), "LS") }
 /x/
 LE { push(array(events), "LE") }
 IT { push(array(events), "IT") }
 EX { push(array(events), "EX") }
 LX { push(array(events), "LX") }
 E { return(hash("cursor", cursor_pos(), "events", copy(array(events)))) }
''',
        inputText: 'x',
        expectedJson: {
          'cursor': 1,
          'events': ['I', 'LS', 'LE', 'IT', 'EX', 'LX'],
        },
      );

      final result = executeCorpusFixtures(root.path);

      expect(result.passed, isTrue);
      expect(result.passedCount, 4);
      expect(result.failures, isEmpty);
      expect(result.fixture('scalar_output').actualValue, 'scalar-ok');
      expect(result.fixture('nested_aggregate_output').actualValue, {
        'flag': true,
        'items': [
          'a',
          {'b': 2},
        ],
        'none': null,
      });
      expect(result.fixture('rule_dispatch_output').actualOutput, [
        ['first', 'second'],
      ]);
      expect(result.fixture('lifecycle_output_shape').actualOutput, [
        {
          'cursor': 1,
          'events': ['I', 'LS', 'LE', 'IT', 'EX', 'LX'],
        },
      ]);
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('reports fixture output mismatches without aborting the run', () {
    final root = Directory.systemTemp.createTempSync(
      'linkedspec-dart-mismatch-',
    );
    try {
      _writeManifest(root, ['passing', 'mismatched']);
      _writeFixture(
        root,
        'passing',
        specSource: r'''
Top::
 /x/ -> Done { return("ok") }

Done::
 /[a-z]+/
''',
        inputText: 'xpass',
        expectedJson: 'ok',
      );
      _writeFixture(
        root,
        'mismatched',
        specSource: r'''
Top::
 /x/ -> Done { return("actual") }

Done::
 /[a-z]+/
''',
        inputText: 'xfail',
        expectedJson: 'expected',
      );

      final result = executeCorpusFixtures(root.path);

      expect(result.passed, isFalse);
      expect(result.passedCount, 1);
      expect(result.failures, hasLength(1));
      expect(result.failures.single.name, 'mismatched');
      expect(result.failures.single.failure, contains('output mismatch'));
      expect(result.failures.single.failure, contains('"expected"'));
      expect(result.fixture('passing').passed, isTrue);
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('executes named and bounded fixture subsets', () {
    final root = Directory.systemTemp.createTempSync('linkedspec-dart-subset-');
    try {
      _writeManifest(root, ['mismatched', 'first', 'second']);
      _writeFixture(
        root,
        'mismatched',
        specSource: _returningSpec('actual'),
        inputText: 'xmismatch',
        expectedJson: 'expected',
      );
      _writeFixture(
        root,
        'first',
        specSource: _returningSpec('first'),
        inputText: 'xfirst',
        expectedJson: 'first',
      );
      _writeFixture(
        root,
        'second',
        specSource: _returningSpec('second'),
        inputText: 'xsecond',
        expectedJson: 'second',
      );

      final named = executeCorpusFixtures(root.path, caseNames: ['second']);
      expect(named.passed, isTrue);
      expect(named.results.map((result) => result.name), ['second']);

      final bounded = executeCorpusFixtures(root.path, offset: 1, limit: 1);
      expect(bounded.passed, isTrue);
      expect(bounded.results.map((result) => result.name), ['first']);

      expect(
        () => executeCorpusFixtures(root.path, caseNames: ['missing']),
        throwsA(
          isA<CorpusManifestException>().having(
            (error) => error.message,
            'message',
            contains('selected corpus case not found in manifest: missing'),
          ),
        ),
      );
      expect(
        () => executeCorpusFixtures(root.path, caseNames: ['first', 'first']),
        throwsA(
          isA<CorpusManifestException>().having(
            (error) => error.message,
            'message',
            contains('duplicate case name: first'),
          ),
        ),
      );
      expect(
        () => executeCorpusFixtures(root.path, caseNames: ['first'], limit: 1),
        throwsA(
          isA<CorpusManifestException>().having(
            (error) => error.message,
            'message',
            contains('cannot be combined with offset or limit'),
          ),
        ),
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('corpus runner execute mode reports selected fixtures', () {
    final root = Directory.systemTemp.createTempSync('linkedspec-dart-cli-');
    try {
      _writeManifest(root, ['mismatched', 'passing']);
      _writeFixture(
        root,
        'mismatched',
        specSource: _returningSpec('actual'),
        inputText: 'xfail',
        expectedJson: 'expected',
      );
      _writeFixture(
        root,
        'passing',
        specSource: _returningSpec('ok'),
        inputText: 'xpass',
        expectedJson: 'ok',
      );

      final process = Process.runSync(Platform.resolvedExecutable, [
        'run',
        'bin/corpus_runner.dart',
        '--corpus',
        root.path,
        '--execute',
        '--case',
        'passing',
      ], workingDirectory: Directory.current.path);

      expect(process.exitCode, 0);
      final stdout = process.stdout as String;
      expect(stdout, contains('PASS passing'));
      expect(stdout, contains('1 passed, 0 failed'));
      expect(stdout, isNot(contains('mismatched')));
    } finally {
      root.deleteSync(recursive: true);
    }
  });

  test('corpus runner execute mode requires explicit selection', () {
    final root = Directory.systemTemp.createTempSync(
      'linkedspec-dart-cli-selection-',
    );
    try {
      _writeManifest(root, ['passing']);
      _writeFixture(
        root,
        'passing',
        specSource: _returningSpec('ok'),
        inputText: 'xpass',
        expectedJson: 'ok',
      );

      final process = Process.runSync(Platform.resolvedExecutable, [
        'run',
        'bin/corpus_runner.dart',
        '--corpus',
        root.path,
        '--execute',
      ], workingDirectory: Directory.current.path);

      expect(process.exitCode, 64);
      expect(
        process.stderr as String,
        contains('--execute requires --case or --limit'),
      );
    } finally {
      root.deleteSync(recursive: true);
    }
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

String _returningSpec(String value) {
  return '''
Top::
 /x/ -> Done { return("$value") }

Done::
 /[a-z]+/
''';
}

void _writeFixture(
  Directory root,
  String name, {
  String specSource = 'Top:: /x/',
  String inputText = 'x',
  Object? expectedJson = const [],
  bool writeExpected = true,
}) {
  final fixture = _childDirectory(root, name)..createSync();
  _childFile(fixture, 'input.spec').writeAsStringSync(specSource);
  _childFile(fixture, 'input.txt').writeAsStringSync(inputText);
  if (writeExpected) {
    _childFile(
      fixture,
      'expected.json',
    ).writeAsStringSync(jsonEncode(expectedJson));
  }
}

Directory _childDirectory(Directory parent, String name) {
  return Directory('${parent.path}${Platform.pathSeparator}$name');
}

File _childFile(Directory parent, String name) {
  return File('${parent.path}${Platform.pathSeparator}$name');
}
