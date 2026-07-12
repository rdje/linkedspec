import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  final contract =
      jsonDecode(
            File(
              '../capability_conformance/scalar_text_contract.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;

  test('cat and scalar receiver text match the neutral contract', () {
    expect(contract['format'], 1);
    expect(contract['contract_id'], 'linkedspec-scalar-text-v1');
    expect((contract['policy']! as Map<String, Object?>)['codeblock'], isNull);
    expect(contract['retired_names'], ['concat']);

    final source = contract['spec_source']! as String;
    final engine = LinkedSpecRuntimeEngine(compileSpec(parseSpec(source)));
    expect(engine.parse('xx').value, contract['expected']);
  });
}
