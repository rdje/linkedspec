import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

String renderNode(Map<String, dynamic> node) => node['kind'] == 'list'
    ? '(${(node['items'] as List).map((item) => renderNode(item as Map<String, dynamic>)).join(' ')})'
    : node['lexeme'] as String;

void main() {
  final contract =
      jsonDecode(
            File('../tests/sexpr-document-v1/contract.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  final cases = (contract['cases'] as List).cast<Map<String, dynamic>>();
  final reuse = cases.singleWhere(
    (row) => row['id'] == 'reuse_after_rejection',
  );
  late LinkedSpecRuntimeEngine engine;
  setUpAll(() {
    final parsed = parseSpecWithStagedUserFunctionDefinitions(
      File('../specs/SExprDocumentV1.spec').readAsStringSync(),
    );
    validateSpec(parsed);
    engine = LinkedSpecRuntimeEngine(compileSpec(parsed));
  });
  test('authored case inventory', () => expect(cases, hasLength(37)));
  for (final row in cases) {
    test(row['id'] as String, () {
      final input = row['input'] as String;
      if (row['outcome'] == 'accept') {
        expect(
          engine.parse(input).value,
          row['expected'],
          reason: 'authored tree',
        );
        final expected = row['expected'] as Map<String, dynamic>;
        final rendered = (expected['forms'] as List)
            .map((node) => renderNode(node as Map<String, dynamic>))
            .join('\n');
        expect(
          engine.parse(rendered).value,
          expected,
          reason: 'token spelling round trip',
        );
      } else {
        expect(
          () => engine.parse(input),
          throwsA(
            isA<RuntimeExitNow>().having((error) => error.status, 'status', 1),
          ),
          reason: 'atomic typed rejection',
        );
        expect(
          engine.parse(reuse['input'] as String).value,
          reuse['expected'],
          reason: 'independent input after rejection',
        );
      }
    });
  }
}
