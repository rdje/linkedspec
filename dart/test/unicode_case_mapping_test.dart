import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/runtime/unicode_case_mapping.dart';
import 'package:test/test.dart';

void main() {
  final contract =
      jsonDecode(
            File(
              '../capability_conformance/unicode_case_contract.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  final fixtures = (contract['fixtures']! as List<Object?>)
      .cast<Map<String, Object?>>();

  test('generated Unicode 17 tables and runtime paths match fixtures', () {
    expect(unicodeCaseContractId, contract['contract_id']);
    expect(unicodeCaseVersion, contract['unicode_version']);
    expect(unicodeCaseDataSha256, contract['data_sha256']);

    for (final fixture in fixtures) {
      final id = fixture['id']! as String;
      final input = fixture['input']! as String;
      final lower = fixture['lower']! as String;
      final upper = fixture['upper']! as String;
      expect(unicodeLowercase(input), lower, reason: '$id direct lowercase');
      expect(unicodeUppercase(input), upper, reason: '$id direct uppercase');

      final literal = jsonEncode(input);
      final source =
          '''
Top::
 /x/ -> Done {
   set(array(lower_items), [$literal])
   lowercase_each(array(lower_items))
   set(array(upper_items), [$literal])
   uppercase_each(array(upper_items))
   return([lowercase($literal), $literal.lowercase(), uppercase($literal), $literal.uppercase(), copy(array(lower_items)), copy(array(upper_items))])
 }

Done::
 /x/
''';
      final engine = LinkedSpecRuntimeEngine(compileSpec(parseSpec(source)));
      expect(engine.parse('xx').value, [
        lower,
        lower,
        upper,
        upper,
        [lower],
        [upper],
      ], reason: '$id helper, receiver, and array paths');
    }
  });
}
