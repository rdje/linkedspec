// FUTURE-PARITY-BACKLOG.10.5.0.2.1 — native Dart label parsing/validation.

import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  const decomposedTop = 'To\u{0308}p';

  test(
    'scanner parses every declaration and edge form with exact identity',
    () {
      final action = parseSpec('''
Töp::AND
 -> $decomposedTop | Δοκιμή { return(entry_text()) }

$decomposedTop:
 /x/

Δοκιμή:
 /x/
''');
      validateSpec(action);
      expect(action.rules.map((rule) => rule.header.label), [
        'Töp',
        decomposedTop,
        'Δοκιμή',
      ]);
      final actionEdge =
          action.rules.first.body.single.kind as ActionEdgeBodyElementKind;
      expect(actionEdge.targets.map((target) => target.label), [
        decomposedTop,
        'Δοκιμή',
      ]);

      final blind = parseSpec('''
規則::AND
 => 𐐀Rule

𐐀Rule:
 /x/
''');
      validateSpec(blind);
      final blindEdge =
          blind.rules.first.body.single.kind as BlindEdgeBodyElementKind;
      expect(blindEdge.target, '𐐀Rule');

      final bare = parseSpec('''
9_root::OR
 A·B | _ { return(entry_text()) }

A·B:
 /x/

_:
 /x/
''');
      validateSpec(bare);
      final bareEdge =
          bare.rules.first.body.single.kind as BareEdgeBodyElementKind;
      expect(bareEdge.targets.map((target) => target.label), ['A·B', '_']);
    },
  );

  test('invalid suffixes never become partial action blind or bare edges', () {
    for (final invalid in [
      '',
      'Top-Rule',
      'Top Rule',
      'Top😀',
      'Top:',
      'Top/Rule',
      r'$Top',
    ]) {
      for (final arrow in ['->', '=>']) {
        final spec = parseSpec('Top::\n $arrow $invalid\n');
        expect(
          spec.rules.single.body.single.kind,
          isA<RawBodyElementKind>(),
          reason: '$arrow $invalid',
        );
        expect(
          () => validateSpec(spec),
          throwsA(_validationMessage(contains('unrecognized body syntax'))),
          reason: '$arrow $invalid',
        );
      }

      if (invalid.isNotEmpty) {
        final bare = parseSpec('Top::\n $invalid\n');
        expect(
          [
            for (final rule in bare.rules)
              for (final element in rule.body)
                element.kind is ActionEdgeBodyElementKind ||
                    element.kind is BlindEdgeBodyElementKind ||
                    element.kind is BareEdgeBodyElementKind,
          ],
          everyElement(isFalse),
          reason: 'bare $invalid',
        );
        expect(
          () => validateSpec(bare),
          throwsA(isA<SpecValidationException>()),
          reason: 'bare $invalid',
        );
      }
    }
  });

  test('invalid declarations never become suffix or prefix headers', () {
    for (final invalid in [
      '',
      'Top-Rule',
      'Top Rule',
      'Top😀',
      'Top:',
      'Top/Rule',
      r'$Top',
    ]) {
      expect(
        () => parseSpec('$invalid::\n /x/\n'),
        throwsA(isA<SpecParseException>()),
        reason: invalid,
      );
    }
  });

  test('validator rejects every programmatic declaration and target role', () {
    final invalidDeclaration = _specWith(
      label: 'Top-Rule',
      element: const RegexBodyElementKind(pattern: 'x'),
    );
    expect(
      () => validateSpec(invalidDeclaration),
      throwsA(_invalidLabel(role: 'declaration', label: 'Top-Rule', line: 1)),
    );

    final targetKinds = <BodyElementKind>[
      const ActionEdgeBodyElementKind(
        targets: [EdgeTarget(label: 'Bad-Target')],
      ),
      const BlindEdgeBodyElementKind(target: 'Bad-Target'),
      const BareEdgeBodyElementKind(
        targets: [BareEdgeTarget(label: 'Bad-Target')],
      ),
    ];
    for (final kind in targetKinds) {
      expect(
        () => validateSpec(_specWith(label: 'Top', element: kind)),
        throwsA(
          _invalidLabel(
            role: 'edge_target',
            label: 'Bad-Target',
            line: 2,
            owner: 'Top',
          ),
        ),
      );
    }
  });

  test('validator rejects invalid labels reconstructed from AST JSON', () {
    final encoded =
        jsonDecode(
              jsonEncode(
                _specWith(
                  label: 'Top',
                  element: const ActionEdgeBodyElementKind(
                    targets: [EdgeTarget(label: 'Child')],
                  ),
                ).toJson(),
              ),
            )
            as Map<String, Object?>;
    final rules = encoded['rules']! as List<Object?>;
    final owner = rules.single as Map<String, Object?>;
    final body = owner['body']! as List<Object?>;
    final element = body.single as Map<String, Object?>;
    final kind = element['kind']! as Map<String, Object?>;
    final targets = kind['targets']! as List<Object?>;
    final target = targets.single as Map<String, Object?>;
    target['label'] = 'Bad-Target';

    final reconstructed = SpecFile.fromJson(encoded);
    expect(
      () => validateSpec(reconstructed),
      throwsA(
        _invalidLabel(
          role: 'edge_target',
          label: 'Bad-Target',
          line: 2,
          owner: 'Top',
        ),
      ),
    );

    final header = owner['header']! as Map<String, Object?>;
    header['label'] = 'Bad-Declaration';
    final reconstructedInvalidDeclaration = SpecFile.fromJson(encoded);
    expect(
      () => validateSpec(reconstructedInvalidDeclaration),
      throwsA(
        _invalidLabel(role: 'declaration', label: 'Bad-Declaration', line: 1),
      ),
    );
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

Matcher _validationMessage(Matcher messageMatcher) {
  return isA<SpecValidationException>().having(
    (error) => error.message,
    'message',
    messageMatcher,
  );
}

Matcher _invalidLabel({
  required String role,
  required String label,
  required int line,
  String? owner,
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
