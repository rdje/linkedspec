import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/cli/primary_cli.dart';
import 'package:test/test.dart';

Map<String, Object?> _contract() {
  return (jsonDecode(
            File(
              '../capability_conformance/complete_named_mark_contract.json',
            ).readAsStringSync(),
          )
          as Map)
      .cast<String, Object?>();
}

CompiledSpec _compileSource(String source) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  validateSpec(parsed);
  return compileSpec(parsed);
}

void main() {
  test('stages exactly seven complete named-mark inventory names', () {
    final contract = _contract();
    expect(contract['contract_id'], 'linkedspec-complete-named-mark-v1');

    final names = (contract['helpers']! as List)
        .cast<Map<Object?, Object?>>()
        .map((helper) => helper['name']! as String)
        .toSet();
    expect(completeNamedMarkActionIrCallNames, names);
    expect(completeNamedMarkActionIrCallNames, hasLength(7));
    expect(
      completeNamedMarkActionIrCallNames.every(isKnownActionIrCallName),
      isTrue,
    );
    expect(
      completeNamedMarkActionIrCallNames.intersection(
        supportedActionIrCallNames,
      ),
      isEmpty,
      reason: 'shared 239-name admission remains FUTURE-PARITY-BACKLOG.17.5',
    );
  });

  test('matches the neutral fixture natively and through generated state', () {
    final fixture = (_contract()['fixture']! as Map).cast<String, Object?>();
    final source = fixture['spec_source']! as String;
    final input = fixture['input']! as String;
    final expected = fixture['expected'];
    final compiled = _compileSource(source);

    expect(LinkedSpecRuntimeEngine(compiled).parse(input).value, expected);

    final plan = buildGeneratedRulePlan(compiled);
    expect(
      executeGeneratedParserV1(
        compiled,
        plan,
        input,
        'complete-named-mark.spec',
      ),
      expected,
    );

    final generated = emitDartSourceV1(compiled, 'complete-named-mark.spec');
    expect(generated, contains('linkedspec-generated-source-v1'));
    final encoded = RegExp(
      "const _compiledSpecJsonBase64 = '([^']+)';",
    ).firstMatch(generated)![1]!;
    final normalized = (jsonDecode(utf8.decode(base64Decode(encoded))) as Map)
        .cast<String, Object?>();
    final reconstructed = compileSpec(SpecFile.fromJson(normalized));
    expect(LinkedSpecRuntimeEngine(reconstructed).parse(input).value, expected);
  });

  test('matches the neutral fixture through the primary Dart CLI', () {
    final fixture = (_contract()['fixture']! as Map).cast<String, Object?>();
    final output = runLinkedSpecDartPrimaryCli([
      '--inline-spec',
      fixture['spec_source']! as String,
      '--input',
      fixture['input']! as String,
    ]);

    expect(output.exitCode, 0);
    expect(output.stderrBytes, isEmpty);
    expect(jsonDecode(utf8.decode(output.stdoutBytes)), fixture['expected']);
  });
}
