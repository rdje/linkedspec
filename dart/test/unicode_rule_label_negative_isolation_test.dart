// FUTURE-PARITY-BACKLOG.10.5.0.2.3 — negative labels and grammar isolation.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/cli/primary_cli.dart';
import 'package:test/test.dart';

final Map<String, Object?> _contract = Map<String, Object?>.from(
  jsonDecode(
        File(
          '../capability_conformance/unicode_rule_label_contract.json',
        ).readAsStringSync(),
      )
      as Map,
);

final List<Map<String, Object?>> _negativeFixtures = [
  for (final fixture
      in (_contract['negative_fixtures']! as List).cast<Map<String, Object?>>())
    Map<String, Object?>.from(fixture),
];

void main() {
  test('every negative label fails every external AST trust route', () {
    expect(_negativeFixtures, hasLength(8));

    for (final fixture in _negativeFixtures) {
      final label = fixture['label']! as String;
      final id = fixture['id']! as String;
      final cases = <({SpecFile spec, String role, int line, String? owner})>[
        (
          spec: _specWith(
            label: label,
            element: const RegexBodyElementKind(pattern: 'x'),
          ),
          role: 'declaration',
          line: 1,
          owner: null,
        ),
        (
          spec: _specWith(
            label: 'Root',
            element: ActionEdgeBodyElementKind(
              targets: [EdgeTarget(label: label)],
            ),
          ),
          role: 'edge_target',
          line: 2,
          owner: 'Root',
        ),
        (
          spec: _specWith(
            label: 'Root',
            element: BlindEdgeBodyElementKind(target: label),
          ),
          role: 'edge_target',
          line: 2,
          owner: 'Root',
        ),
        (
          spec: _specWith(
            label: 'Root',
            element: BareEdgeBodyElementKind(
              targets: [BareEdgeTarget(label: label)],
            ),
          ),
          role: 'edge_target',
          line: 2,
          owner: 'Root',
        ),
      ];

      for (final route in cases) {
        final matcher = _invalidLabel(
          role: route.role,
          label: label,
          line: route.line,
          owner: route.owner,
        );
        expect(
          () => validateSpec(route.spec),
          throwsA(matcher),
          reason: '$id ${route.role} programmatic',
        );
        expect(
          () => validateSpec(_reconstruct(route.spec)),
          throwsA(matcher),
          reason: '$id ${route.role} reconstructed',
        );
      }
    }
  });

  test('source surfaces reject whole invalid tokens without truncation', () {
    for (final fixture in _negativeFixtures) {
      final label = fixture['label']! as String;
      final id = fixture['id']! as String;
      if (id == 'newline') {
        continue;
      }

      expect(
        () => parseSpec('$label::\n /x/\n'),
        throwsA(isA<SpecParseException>()),
        reason: '$id declaration',
      );

      for (final arrow in ['->', '=>']) {
        final parsed = parseSpec('Root::\n $arrow $label\n');
        final rawLine = '$arrow $label'.trimRight();
        expect(
          parsed.rules.single.body.single.kind,
          isA<RawBodyElementKind>(),
          reason: '$id $arrow whole token',
        );
        expect(
          () => validateSpec(parsed),
          throwsA(
            _validationMessage(
              "rule 'Root': unrecognized body syntax at line 2: $rawLine",
            ),
          ),
          reason: '$id $arrow deterministic failure',
        );
      }

      if (label.isNotEmpty) {
        final parsed = parseSpec('Root::\n $label\n');
        expect(
          parsed.rules
              .expand((rule) => rule.body)
              .every(
                (element) =>
                    element.kind is! ActionEdgeBodyElementKind &&
                    element.kind is! BlindEdgeBodyElementKind &&
                    element.kind is! BareEdgeBodyElementKind,
              ),
          isTrue,
          reason: '$id bare whole token',
        );
        if (id == 'colon') {
          expect(parsed.rules.map((rule) => rule.header.label), [
            'Root',
            'Top',
          ]);
          validateSpec(parsed);
          continue;
        }
        expect(
          () => validateSpec(parsed),
          throwsA(isA<SpecValidationException>()),
          reason: '$id bare deterministic failure',
        );
      }
    }
  });

  test(
    'no-prefix surfaces never recover a suffix and newline splits tokens',
    () {
      const noPrefix = r'$Top';
      expect(
        () => parseSpec('$noPrefix::\n /x/\n'),
        throwsA(isA<SpecParseException>()),
      );
      for (final source in [
        'Root::\n -> $noPrefix\n',
        'Root::\n => $noPrefix\n',
        'Root::\n $noPrefix\n',
      ]) {
        final parsed = parseSpec(source);
        expect(parsed.rules.map((rule) => rule.header.label), ['Root']);
        expect(
          parsed.rules.single.body.every(
            (element) =>
                element.kind is! ActionEdgeBodyElementKind &&
                element.kind is! BlindEdgeBodyElementKind &&
                element.kind is! BareEdgeBodyElementKind,
          ),
          isTrue,
        );
        expect(
          () => validateSpec(parsed),
          throwsA(isA<SpecValidationException>()),
        );
      }

      final split = parseSpec('''
Root::OR
 -> Top
 Rule

Top:
 /x/

Rule:
 /x/
''');
      validateSpec(split);
      final rootKinds = split.rules.first.body.map((element) => element.kind);
      expect(
        rootKinds.whereType<ActionEdgeBodyElementKind>().single.targets.map(
          (target) => (target.label, target.index),
        ),
        [('Top', 0)],
      );
      expect(
        rootKinds.whereType<BareEdgeBodyElementKind>().single.targets.map(
          (target) => (target.label, target.index),
        ),
        [('Rule', null)],
      );
    },
  );

  test(
    'primary commands reject every negative declaration deterministically',
    () {
      for (final fixture in _negativeFixtures) {
        final label = fixture['label']! as String;
        final output = runLinkedSpecDartPrimaryCli([
          '--inline-spec',
          '$label::\n /x/\n',
          '--input',
          'x',
        ]);
        expect(output.exitCode, 1, reason: fixture['id']! as String);
        expect(output.stdoutBytes, isEmpty, reason: fixture['id']! as String);
        expect(
          output.stderrBytes,
          utf8.encode('linkedspec: parser compilation failed\n'),
          reason: fixture['id']! as String,
        );
      }
    },
  );

  test('unrelated identifier grammars retain their existing boundaries', () {
    validateSpec(
      _specWithFunctions([
        _function('_function9', ['value_2']),
      ]),
    );
    for (final name in ['Töp', '9_function', 'A·B', '𐐀Rule']) {
      expect(
        () => validateSpec(
          _specWithFunctions([
            _function(name, ['value']),
          ]),
        ),
        throwsA(_validationMessage("invalid user function name '$name'")),
        reason: 'function $name',
      );
      expect(
        () => validateSpec(
          _specWithFunctions([
            _function('valid_name', [name]),
          ]),
        ),
        throwsA(
          _validationMessage(
            "user function 'valid_name' has invalid parameter '$name'",
          ),
        ),
        reason: 'parameter $name',
      );
    }

    final helper = parseActionExpression('trim(value)') as ActionCallExpr;
    expect(helper.name, 'trim');
    final fluent =
        parseActionExpression('"x"._method9()') as ActionFluentChainExpr;
    expect(fluent.calls.single.method, '_method9');
    for (final name in ['Töp', '9helper', 'A·B', '𐐀Rule']) {
      expect(
        parseActionExpression('$name(value)'),
        isA<ActionRawExpr>().having(
          (expr) => expr.reason,
          'reason',
          'unsupported_expression',
        ),
        reason: 'helper $name',
      );
    }
    for (final name in ['Töp', '9method']) {
      expect(
        parseActionExpression('"x".$name()'),
        isA<ActionRawExpr>(),
        reason: 'fluent $name',
      );
    }
    expect(
      () => parseActionExpression('"x".trim!()'),
      throwsA(
        isA<ActionParseException>()
            .having((error) => error.code, 'code', 'bang_method_unknown')
            .having(
              (error) => error.message,
              'message',
              "unsupported bang method 'trim!'",
            ),
      ),
    );

    const lifecycleMarkers = ['I', 'LS', 'LE', 'LX', 'E', 'EX', 'IT'];
    final lifecycle = parseSpec('''
Root::
${lifecycleMarkers.map((marker) => ' $marker { return("$marker") }').join('\n')}
 /x/
''');
    expect(
      lifecycle.rules.single.body
          .map((element) => element.kind)
          .whereType<CodeBlockBodyElementKind>()
          .map((kind) => kind.lifecycle),
      lifecycleMarkers,
    );
    for (final marker in ['IX', 'Töp', '𐐀Rule']) {
      final parsed = parseSpec('Root::\n $marker { return("bad") }\n /x/\n');
      expect(
        parsed.rules.single.body
            .map((element) => element.kind)
            .whereType<CodeBlockBodyElementKind>(),
        isEmpty,
        reason: 'lifecycle $marker',
      );
      expect(
        () => validateSpec(parsed),
        throwsA(isA<SpecValidationException>()),
        reason: 'lifecycle $marker',
      );
    }

    final namedMark =
        parseActionExpression('mark_here(shared_9)') as ActionCallExpr;
    expect(
      (namedMark.args.single.value as ActionVariableExpr).name,
      'shared_9',
    );
    for (final name in ['Töp', '9_mark', 'mark-name']) {
      final mark = parseActionExpression('mark_here($name)') as ActionCallExpr;
      expect(
        mark.args.single.value,
        isA<ActionRawExpr>(),
        reason: 'mark $name',
      );
    }
  });
}

SpecFile _specWith({required String label, required BodyElementKind element}) {
  return SpecFile(
    rules: [
      Rule(
        header: RuleHeader(
          label: label,
          isTop: true,
          mode: RuleMode.defaultMode,
          rest: '',
          line: 1,
        ),
        body: [BodyElement(kind: element, source: '', line: 2)],
      ),
    ],
  );
}

SpecFile _reconstruct(SpecFile spec) {
  return SpecFile.fromJson(
    Map<String, Object?>.from(jsonDecode(jsonEncode(spec.toJson())) as Map),
  );
}

SpecFile _specWithFunctions(List<FunctionDefinition> functions) {
  return SpecFile(
    functions: functions,
    rules: [
      Rule(
        header: const RuleHeader(
          label: 'Töp',
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
      ),
    ],
  );
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

Matcher _validationMessage(String message) {
  return isA<SpecValidationException>().having(
    (error) => error.message,
    'message',
    message,
  );
}

Matcher _invalidLabel({
  required String role,
  required String label,
  required int line,
  required String? owner,
}) {
  return isA<SpecValidationException>().having(
    (error) => error.diagnostic?.toJson(),
    'portable diagnostic',
    {
      'code': 'invalid_rule_label',
      'stage': 'validate_rule_labels',
      'message':
          "$role '$label' is not a nonempty Unicode 17.0.0 "
          'XID_Continue rule label',
      'fields': {
        'label': label,
        'line': line,
        'role': role,
        if (owner != null) 'rule_label': owner,
      },
    },
  );
}
