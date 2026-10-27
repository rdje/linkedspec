import 'dart:convert';
import 'dart:io';
import 'package:linkedspec_dart/linkedspec_dart.dart';

void main() {
  final root = Directory.current.parent;
  final source = File.fromUri(
    root.uri.resolve('tests/fixtures/substring_optional_argument_values.spec'),
  ).readAsStringSync();
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  for (final row in <(String, Object? Function())>[
    ('native', () => LinkedSpecRuntimeEngine(compiled).execute('x').value),
    (
      'restored',
      () => LinkedSpecRuntimeEngine(compileSpec(restored)).execute('x').value,
    ),
    (
      'plan',
      () => executeGeneratedParserV2(
        compiled,
        buildGeneratedRulePlan(compiled),
        'x',
        'substring-arguments.spec',
      ),
    ),
  ]) {
    stdout.writeln(jsonEncode({'route': row.$1, 'value': row.$2()}));
  }
}
