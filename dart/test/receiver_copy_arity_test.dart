import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('receiver copy rejects extra operands before effects', () {
    final parsed = parseSpecWithStagedUserFunctionDefinitions(r'''
Top:: I {
 effects=0;
 invalid={effects=num_add(effects,1); [["a"]]}.first().copy({effects=num_add(effects,1); 1});
 invalid_direct={effects=num_add(effects,1); ["b"]}.copy({effects=num_add(effects,1); 1});
 valid_effects=0; original=[["a"]];
 copied={valid_effects=num_add(valid_effects,1); original}.first().copy();
 copied+="b";
 return([invalid,invalid_direct,effects,copied,original,valid_effects,"x".copy().uppercase(),missing.copy()]);
}
''');
    const expected = [
      null,
      null,
      0,
      ['a', 'b'],
      [
        ['a'],
      ],
      1,
      'X',
      null,
    ];
    final compiled = compileSpec(parsed);
    expect(LinkedSpecRuntimeEngine(compiled).execute('x').value, expected);
    final restored = SpecFile.fromJson(
      (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
    );
    expect(
      LinkedSpecRuntimeEngine(compileSpec(restored)).execute('x').value,
      expected,
    );
    expect(
      executeGeneratedParserV2(
        compiled,
        buildGeneratedRulePlan(compiled),
        'x',
        'receiver-copy-arity.spec',
      ),
      expected,
    );
  });
}
