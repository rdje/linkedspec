import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('selected values continue using their actual kinds', () {
    final parsed = parseSpecWithStagedUserFunctionDefinitions(r'''
fn clone_first(values) { return(values.first().copy()) }
Top::
 I {
  nested=[[3,1],[2]]; saved=copy(nested); rows=[{"b":2,"a":1}];
  copied_array=clone_first(nested); copied_hash=clone_first(rows);
  repeated=[[[4,1],[2]]].first().first().sorted().last().add(2);
  order=""; calls=0;
  computed={order=cat(order,"S"); [{"a":1}]}.first().set_key("b",{order=cat(order,"V"); calls=num_add(calls,1); 2});
  invalid_effects=0;
  invalid={invalid_effects=num_add(invalid_effects,1); [" a "]}.first({invalid_effects=num_add(invalid_effects,1); 1}).trim();
  return([
   " a : b ".split(/:/).first().trim().uppercase(),
   [" A "," B "].last().trim().lowercase(),
   [[3,1],[2]].first().sorted().last().add(4),
   [{"b":2,"a":1}].first().sorted_keys().last().uppercase(),
   [2,3].last().mul(4),
   [].first().trim(),copied_array,copied_hash,repeated,computed,order,calls,
   nested,saved,rows,invalid,invalid_effects,[[3,1]].first().min(),[3].first().min(2),
   [[3,1],[2]].first().copy().sorted().last().add(4),
   [{"b":2,"a":1}].first().copy().sorted_keys().last().uppercase()
  ]);
 }
''');
    const expected = [
      'A',
      'b',
      7,
      'B',
      12,
      null,
      [3, 1],
      {'a': 1, 'b': 2},
      6,
      {'a': 1, 'b': 2},
      'SV',
      1,
      [
        [3, 1],
        [2],
      ],
      [
        [3, 1],
        [2],
      ],
      [
        {'a': 1, 'b': 2},
      ],
      null,
      0,
      1,
      2,
      7,
      'B',
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
        'selected-value-receivers.spec',
      ),
      expected,
    );
  });
}
