import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';

void main(List<String> arguments) {
  final fixture = jsonDecode(File(arguments.single).readAsStringSync()) as Map;
  for (final item in fixture['cases'] as List) {
    final row = (item as Map).cast<String, Object?>();
    final id = row['id'] as String;
    final source = 'Top::\n /x/\n E { ${row['body']} }\n';
    try {
      final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
      final compiled = compileSpec(parsed);
      final specJson = jsonEncode(parsed.toJson());
      print('DART_SIGNED_PARSE\t${jsonEncode({
        'id': id,
        'source': source,
        'spec_json': specJson,
        'compiled_json': jsonEncode(compiled.toJson()),
      })}');
      final reconstructed = SpecFile.fromJson(
        (jsonDecode(specJson) as Map).cast<String, Object?>(),
      );
      final routes = <String, Object? Function()>{
        'native': () => LinkedSpecRuntimeEngine(compiled)
            .execute('x', topRule: 'Top')
            .value,
        'spec_json': () => LinkedSpecRuntimeEngine(compileSpec(reconstructed))
            .execute('x', topRule: 'Top')
            .value,
        'generated_plan': () => executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          'x',
          'signed-dart/$id.spec',
        ),
      };
      for (final entry in routes.entries) {
        final result = <String, Object?>{'id': id, 'route': entry.key};
        try {
          result['ok'] = entry.value();
        } on RuntimeInterpreterException catch (error) {
          result['error'] = error.toJson();
        } on Object catch (error) {
          result['other_error'] = '$error';
          result['other_type'] = '${error.runtimeType}';
        }
        print('DART_SIGNED_RUN\t${jsonEncode(result)}');
      }
    } on Object catch (error) {
      print('DART_SIGNED_COMPILE_ERROR\t${jsonEncode({
        'id': id,
        'source': source,
        'error': '$error',
        'type': '${error.runtimeType}',
      })}');
    }
  }
}
