import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

final Map<String, Object?> _contract =
    jsonDecode(
          File(
            '../capability_conformance/root_rule_selection_contract.json',
          ).readAsStringSync(),
        )
        as Map<String, Object?>;

void main() {
  test('neutral selection and failure rows resolve exactly', () {
    expect(_contract['contract_id'], linkedSpecRootRuleSelectionContract);

    for (final caseValue in _objects(_contract['selection_cases'])) {
      final id = caseValue['id']! as String;
      final rows = _objects(caseValue['rules']);
      final compiled = _compiledForRows(rows);
      final before = [
        for (final label in compiled.compiledRuleOrder)
          (label, compiled.rule(label)!.header.isTop),
      ];
      final selection = compiled.resolveEntryRule(
        caseValue['explicit_selector'] as String?,
      );
      expect(selection.rule.label, caseValue['expected_label'], reason: id);
      expect(
        selection.basis.contractName,
        caseValue['expected_basis'],
        reason: id,
      );
      expect(
        [
          for (final label in compiled.compiledRuleOrder)
            (label, compiled.rule(label)!.header.isTop),
        ],
        before,
        reason: '$id authored identity',
      );
    }

    for (final caseValue in _objects(_contract['failure_cases'])) {
      final id = caseValue['id']! as String;
      try {
        _compiledForRows(
          _objects(caseValue['rules']),
        ).resolveEntryRule(caseValue['explicit_selector'] as String?);
        fail('$id must reject selection');
      } on EntryRuleSelectionException catch (error) {
        expect(error.code, caseValue['expected_code'], reason: id);
        expect(error.stage, caseValue['expected_stage'], reason: id);
        if (error.code == 'entry_rule_not_found') {
          expect(error.toJson()['fields'], {
            'entry_rule': caseValue['explicit_selector'],
          }, reason: id);
        } else {
          expect(error.toJson()['fields'], isEmpty, reason: id);
        }
      }
    }
  });

  test('validation and native execution apply exact precedence', () {
    const marked = '''Earlier:
 /x/
 E { return("earlier") }

Marked::
 /x/
 E { return("marked") }

Later::
 /x/
 E { return("later") }
''';
    const markerless = '''First:
 /x/
 E { return("first") }

Second:
 /x/
 E { return("second") }
''';

    final markedEngine = _engine(marked);
    expect(markedEngine.parse('x').value, 'marked');
    expect(markedEngine.parse('x', topRule: 'Earlier').value, 'earlier');
    expect(markedEngine.parse('x', topRule: 'Later').value, 'later');

    final markerlessEngine = _engine(markerless);
    expect(markerlessEngine.parse('x').value, 'first');
    expect(markerlessEngine.parse('x', topRule: 'Second').value, 'second');

    for (final source in ['', '# no rules\n']) {
      try {
        validateSpec(parseSpec(source));
        fail('zero-rule source must fail validation');
      } on SpecValidationException catch (error) {
        expect(error.diagnostic?.code, 'no_rules_defined');
        expect(error.diagnostic?.stage, 'validate_spec');
      }
    }
  });

  test('unknown and zero-rule selection fail before user code', () {
    final engine = _engine('''Top::
 /x/
 I { exit_now(99) }
''');
    try {
      engine.parse('x', topRule: 'Missing');
      fail('unknown entry rule must reject before exit_now');
    } on RuntimeInterpreterException catch (error) {
      expect(error.message, "entry rule 'Missing' is not defined");
      expect(error.diagnostic?.code, 'entry_rule_not_found');
      expect(error.diagnostic?.stage, 'select_entry_rule');
      expect(error.diagnostic?.entryRule, 'Missing');
      expect(error.diagnostic?.topRule, 'Missing');
      expect(error.diagnostic?.ruleLabel, 'Missing');
    }

    final empty = LinkedSpecRuntimeEngine(
      compileSpec(const SpecFile(rules: []), validateSource: false),
    );
    try {
      empty.parse('', topRule: 'Missing');
      fail('zero rules must reject before explicit selection');
    } on RuntimeInterpreterException catch (error) {
      expect(error.diagnostic?.code, 'no_rules_defined');
      expect(error.diagnostic?.stage, 'validate_spec');
      expect(error.diagnostic?.entryRule, isNull);
      expect(error.diagnostic?.topRule, isNull);
    }
  });

  test('descriptor keeps authored identity separate from selection', () {
    final compiled = _compiledForRows(const [
      {'label': 'Earlier', 'authored_is_top': false},
      {'label': 'Marked', 'authored_is_top': true},
      {'label': 'Later', 'authored_is_top': true},
    ]);
    final before = compiled.toDescriptorJson();
    expect(compiled.resolveEntryRule('Earlier').rule.label, 'Earlier');
    expect(
      LinkedSpecRuntimeEngine(compiled).parse('x', topRule: 'Earlier').value,
      'Earlier',
    );
    final after = compiled.toDescriptorJson();

    expect(after, before);
    final meta = _object(after['meta']);
    expect(meta['entry_rule_contract'], linkedSpecRootRuleSelectionContract);
    expect(meta['definition_order'], ['Earlier', 'Marked', 'Later']);
    expect(meta, isNot(contains('entry_rule')));
    expect(meta, isNot(contains('selected_entry_rule')));
    final spec = _object(after['spec']);
    expect(_object(_object(spec['Earlier'])['meta'])['is_top'], isFalse);
    expect(_object(_object(spec['Marked'])['meta'])['is_top'], isTrue);
    expect(_object(_object(spec['Later'])['meta'])['is_top'], isTrue);
  });

  test('neutral strict rows remain authored-edge graph analysis', () {
    for (final caseValue in _objects(_contract['strict_cases'])) {
      final id = caseValue['id']! as String;
      final source = switch (id) {
        'explicit_selection_is_not_reference' => 'A:\n /a/\n\nB:\n /b/\n',
        'marker_selection_is_not_reference' =>
          'Top::\n /x/ -> Child\n\nChild:\n /x/ -> Child\n',
        'closed_reference_cycle_has_no_unused_rules' =>
          'A:\n /a/ -> B\n\nB:\n /b/ -> A\n',
        _ => throw StateError('unhandled strict case $id'),
      };
      final expectedUnused = _strings(caseValue['expected_unused']);
      if (expectedUnused.isEmpty) {
        expect(
          () => validateSpec(parseSpec(source), strictSyntax: true),
          returnsNormally,
          reason: id,
        );
      } else {
        expect(
          () => validateSpec(parseSpec(source), strictSyntax: true),
          throwsA(
            isA<SpecValidationException>().having(
              (error) => error.message,
              'unused labels',
              contains(expectedUnused.join(', ')),
            ),
          ),
          reason: id,
        );
      }
    }
  });
}

CompiledSpec _compiledForRows(List<Map<String, Object?>> rows) {
  if (rows.isEmpty) {
    return compileSpec(const SpecFile(rules: []), validateSource: false);
  }
  final source = rows
      .map((row) {
        final label = row['label']! as String;
        final separator = row['authored_is_top'] == true ? '::' : ':';
        return '$label$separator\n /x/\n E { return("$label") }\n';
      })
      .join('\n');
  return compileSpec(parseSpec(source));
}

LinkedSpecRuntimeEngine _engine(String source) {
  return LinkedSpecRuntimeEngine(compileSpec(parseSpec(source)));
}

Map<String, Object?> _object(Object? value) {
  return Map<String, Object?>.from(value! as Map);
}

List<Map<String, Object?>> _objects(Object? value) {
  return [for (final row in value! as List) _object(row)];
}

List<String> _strings(Object? value) {
  return [for (final item in value! as List) item! as String];
}
