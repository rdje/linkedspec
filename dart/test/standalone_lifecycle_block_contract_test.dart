// FUTURE-PARITY-BACKLOG.15.2 — standalone lifecycle-I shorthand admission.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

final Map<String, Object?> _contract = Map<String, Object?>.from(
  jsonDecode(
        File(
          '../capability_conformance/standalone_lifecycle_block_contract.json',
        ).readAsStringSync(),
      )
      as Map,
);

void main() {
  test('all explicit and shorthand placements normalize to lifecycle I', () {
    for (final row in _rows('placement_twins')) {
      final explicit = _lifecycle(row['explicit']! as String);
      final shorthand = _lifecycle(row['shorthand']! as String);
      expect(
        explicit.kind.toJson(),
        shorthand.kind.toJson(),
        reason: row['id']! as String,
      );
      expect(explicit.kind, isA<CodeBlockBodyElementKind>());
      expect((explicit.kind as CodeBlockBodyElementKind).lifecycle, 'I');
      expect(explicit.line, row['opening_line']);
      expect(shorthand.line, row['opening_line']);
      expect(
        (explicit.kind as CodeBlockBodyElementKind).code,
        (row['interior']! as String).trim(),
      );
      expect(
        (shorthand.kind as CodeBlockBodyElementKind).code,
        (row['interior']! as String).trim(),
      );
      expect(
        _allKinds(row['shorthand']! as String),
        isNot(contains('plain_block')),
      );
    }
  });

  test(
    'exact authored source and nested ActionIR input survive normalization',
    () {
      final row = Map<String, Object?>.from(
        _contract['provenance_twin']! as Map,
      );
      final explicit = _lifecycle(row['explicit']! as String);
      final shorthand = _lifecycle(row['shorthand']! as String);
      expect(explicit.source, row['explicit_block_source']);
      expect(shorthand.source, row['shorthand_block_source']);
      expect(explicit.line, row['opening_line']);
      expect(shorthand.line, row['opening_line']);
      expect(explicit.kind.toJson(), shorthand.kind.toJson());

      final explicitPayload = _compile(
        row['explicit']! as String,
      ).rule('Top')!.lifecycleActionPayloads.single;
      final shorthandPayload = _compile(
        row['shorthand']! as String,
      ).rule('Top')!.lifecycleActionPayloads.single;
      final explicitSemantic = explicitPayload.toJson()..remove('source');
      final shorthandSemantic = shorthandPayload.toJson()..remove('source');
      expect(explicitSemantic, shorthandSemantic);
    },
  );

  test(
    'duplicate forms preserve authored order through every available carrier',
    () {
      for (final row in _rows('duplicate_cases')) {
        final source = row['source']! as String;
        final parsed = parseSpec(source);
        final compiled = compileSpec(parsed);
        expect(
          _execute(compiled, _contract['duplicate_input']! as String),
          _contract['duplicate_expected'],
        );

        final reconstructed = SpecFile.fromJson(
          Map<String, Object?>.from(
            jsonDecode(jsonEncode(parsed.toJson())) as Map,
          ),
        );
        expect(
          _execute(
            compileSpec(reconstructed),
            _contract['duplicate_input']! as String,
          ),
          _contract['duplicate_expected'],
        );
        expect(
          executeGeneratedParserV2(
            compiled,
            buildGeneratedRulePlan(compiled),
            _contract['duplicate_input']! as String,
            'standalone-lifecycle/dart-${row['id']}.spec',
          ),
          _contract['duplicate_expected'],
        );
        expect(
          emitDartSourceV2(
            compiled,
            'standalone-lifecycle/dart-${row['id']}.spec',
          ),
          isNotEmpty,
        );
      }
    },
  );

  test('earlier brace owners remain unchanged', () {
    for (final row in _rows('ownership_cases')) {
      expect(
        _allKinds(row['source']! as String),
        contains(row['expected_kind']),
        reason: row['id']! as String,
      );
    }
  });

  test(
    'malformed explicit and shorthand twins reject at the same boundary',
    () {
      for (final row in _rows('malformed_twins')) {
        final explicit = _captureFailure(row['explicit']! as String);
        final shorthand = _captureFailure(row['shorthand']! as String);
        expect(
          explicit.runtimeType,
          shorthand.runtimeType,
          reason: row['id']! as String,
        );
        expect(explicit.toString(), isNotEmpty);
        expect(shorthand.toString(), isNotEmpty);
      }
    },
  );

  test('legacy serialized plain blocks remain readable and inert', () {
    final normalized = parseSpec('Top::\n { return("must-not-run") }\n');
    final top = normalized.rules.single;
    final legacy = SpecFile(
      sourceId: 'legacy-plain.spec',
      rules: [
        Rule(
          header: top.header,
          body: const [
            BodyElement(
              kind: PlainBlockBodyElementKind(code: ' return("must-not-run") '),
              source: '{ return("must-not-run") }',
              line: 2,
            ),
          ],
        ),
      ],
    );
    final reconstructed = SpecFile.fromJson(
      Map<String, Object?>.from(jsonDecode(jsonEncode(legacy.toJson())) as Map),
    );
    final compiled = compileSpec(reconstructed, validateSource: false);
    expect(compiled.rule('Top')!.plainActionPayloads, hasLength(1));
    expect(_execute(compiled, ''), isNull);
    expect(
      executeGeneratedParserV2(
        compiled,
        buildGeneratedRulePlan(compiled),
        '',
        'standalone-lifecycle/dart-legacy-plain.spec',
      ),
      isNull,
    );
  });
}

List<Map<String, Object?>> _rows(String field) => (_contract[field]! as List)
    .map((row) => Map<String, Object?>.from(row as Map))
    .toList(growable: false);

BodyElement _lifecycle(String source) => _parse(source).rules.single.body
    .singleWhere((element) => element.kind is CodeBlockBodyElementKind);

List<String> _allKinds(String source) => _parse(source).rules
    .expand((rule) => rule.body)
    .map((element) => element.kind.kind)
    .toList(growable: false);

CompiledSpec _compile(String source) => compileSpec(_parse(source));

SpecFile _parse(String source) =>
    parseSpecWithStagedUserFunctionDefinitions(source);

Object? _execute(CompiledSpec compiled, String input) =>
    LinkedSpecRuntimeEngine(compiled).parse(input).value;

Object _captureFailure(String source) {
  try {
    _compile(source);
  } catch (error) {
    return error;
  }
  fail('expected source to reject');
}
