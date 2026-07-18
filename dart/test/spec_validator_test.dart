import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('accepts a valid parsed rule spec', () {
    final spec = parseSpec('Top::\n /a/ -> Child\n\nChild:\n /b/');
    validateSpec(spec);
  });

  test('accepts markerless rules and rejects zero rules portably', () {
    validateSpec(parseSpec('Rule:\n /a/'));

    for (final source in ['', '# no rules\n']) {
      expect(
        () => validateSpec(parseSpec(source)),
        throwsA(
          isA<SpecValidationException>().having(
            (error) => error.diagnostic?.toJson(),
            'portable diagnostic',
            {
              'code': 'no_rules_defined',
              'stage': 'validate_spec',
              'message': 'spec does not define any rules',
              'fields': <String, Object?>{},
            },
          ),
        ),
      );
    }
  });

  test('rejects duplicate rule labels', () {
    final spec = parseSpec('Top::\n /a/\n\nTop:\n /b/');
    expect(
      () => validateSpec(spec),
      throwsA(_validationMessage(contains('duplicate rule label'))),
    );
  });

  test('rejects mixed action and blind-call edge families', () {
    final spec = parseSpec(r'''
Top::
 /a/ -> A
 /b/ => B

A: /a/
B: /b/
''');
    expect(
      () => validateSpec(spec),
      throwsA(_validationMessage(contains('mixes action'))),
    );
  });

  test('rejects undefined edge targets and out-of-range regex slots', () {
    final missing = parseSpec('Top::\n /a/ -> Ghost');
    expect(
      () => validateSpec(missing),
      throwsA(_validationMessage(contains('undefined rule'))),
    );

    final badIndex = parseSpec('Top::\n /a/ -> Child[1]\n\nChild:\n /b/');
    expect(
      () => validateSpec(badIndex),
      throwsA(_validationMessage(contains('regex slot 1'))),
    );
  });

  test('rejects grouped action targets without a shared block', () {
    final spec = parseSpec('Top::\n -> A | B\n\nA: /a/\nB: /b/');
    expect(
      () => validateSpec(spec),
      throwsA(_validationMessage(contains('grouped action-edge targets'))),
    );
  });

  test('rejects malformed raw body lines and regex structure', () {
    final raw = parseSpec('Top::\n unsupported helper line');
    expect(
      () => validateSpec(raw),
      throwsA(_validationMessage(contains('unrecognized body syntax'))),
    );

    final invalidRegex = parseSpec('Top::\n /[invalid/');
    expect(
      () => validateSpec(invalidRegex),
      throwsA(_validationMessage(contains('invalid regex pattern'))),
    );
  });

  test('strict syntax rejects unused rules while non-strict allows them', () {
    final spec = parseSpec('Top::\n /a/ -> Child\n\nChild:\n /b/');
    validateSpec(spec);
    expect(
      () => validateSpec(spec, strictSyntax: true),
      throwsA(_validationMessage(allOf(contains('unused'), contains('Top')))),
    );

    final recursiveTop = parseSpec('Top::\n /a/ -> Top');
    validateSpec(recursiveTop, strictSyntax: true);
  });

  test('validates user function registry records', () {
    final ok = _specWithFunctions([
      _function('normalize', ['value']),
    ]);
    validateSpec(ok);

    final duplicate = _specWithFunctions([
      _function('normalize', ['value']),
      _function('normalize', ['other']),
    ]);
    expect(
      () => validateSpec(duplicate),
      throwsA(_validationMessage(contains('duplicate user function'))),
    );

    final ruleCollision = _specWithFunctions([
      _function('Top', ['value']),
    ]);
    expect(
      () => validateSpec(ruleCollision),
      throwsA(_validationMessage(contains('collides with rule label'))),
    );

    final builtinCollision = _specWithFunctions([
      _function('trim', ['value']),
    ]);
    expect(
      () => validateSpec(builtinCollision),
      throwsA(_validationMessage(contains('built-in helper'))),
    );

    final duplicateParam = _specWithFunctions([
      _function('normalize', ['value', 'value']),
    ]);
    expect(
      () => validateSpec(duplicateParam),
      throwsA(_validationMessage(contains('duplicate parameter'))),
    );

    final reservedParam = _specWithFunctions([
      _function('normalize', ['ctx']),
    ]);
    expect(
      () => validateSpec(reservedParam),
      throwsA(_validationMessage(contains("parameter 'ctx' is reserved"))),
    );
  });

  test('validates every shipped spec source file in non-strict mode', () {
    final specFiles =
        Directory('../specs')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.spec'))
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    expect(specFiles, isNotEmpty);
    for (final file in specFiles) {
      final parsed = parseSpec(file.readAsStringSync());
      validateSpec(parsed);
    }
  });

  test(
    'validates corpus rule specs without top-level function definitions',
    () {
      final corpusSpecs =
          Directory('../rust/linkedspec-runtime/tests/corpus')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('/input.spec'))
              .toList()
            ..sort((left, right) => left.path.compareTo(right.path));

      var parsedCount = 0;
      for (final file in corpusSpecs) {
        final source = file.readAsStringSync();
        if (_startsWithTopLevelFunction(source)) {
          continue;
        }
        validateSpec(parseSpec(source));
        parsedCount += 1;
      }

      expect(parsedCount, greaterThan(80));
    },
  );
}

Matcher _validationMessage(Matcher messageMatcher) {
  return isA<SpecValidationException>().having(
    (error) => error.message,
    'message',
    messageMatcher,
  );
}

SpecFile _specWithFunctions(List<FunctionDefinition> functions) {
  final rule = Rule(
    header: const RuleHeader(
      label: 'Top',
      isTop: true,
      mode: RuleMode.defaultMode,
      rest: '',
      line: 1,
    ),
    body: const [
      BodyElement(
        kind: RegexBodyElementKind(pattern: 'x'),
        source: '/x/',
        line: 2,
      ),
    ],
  );
  return SpecFile(functions: functions, rules: [rule]);
}

FunctionDefinition _function(String name, List<String> params) {
  return FunctionDefinition(
    name: name,
    params: params,
    arity: params.length,
    bodySource: 'return(value)',
    source: 'fn $name(${params.join(", ")}) { return(value) }',
    sourceSpan: const SourceSpan(lineStart: 1, lineEnd: 1),
    bodySpan: const SourceSpan(lineStart: 1, lineEnd: 1),
  );
}

bool _startsWithTopLevelFunction(String source) {
  for (final line in source.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    return trimmed.startsWith('fn ');
  }
  return false;
}
