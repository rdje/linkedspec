import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';

Map<String, Object?> observe(Object? Function() operation) {
  try {
    return {'value': operation()};
  } catch (error) {
    return {
      'error': error.toString(),
      'class': error.runtimeType.toString(),
      if (error is RuntimeInterpreterException)
        'diagnostic': error.diagnostic?.toJson(),
    };
  }
}

void main(List<String> arguments) {
  final root = Directory.current.parent;
  if (arguments.length != 1) {
    throw ArgumentError('one repository-relative phase path required');
  }
  final phase = Uri.parse(arguments.single);
  if (phase.hasScheme ||
      phase.hasAuthority ||
      phase.path.isEmpty ||
      phase.path.startsWith('/') ||
      phase.pathSegments.any(
        (part) => part.isEmpty || part == '.' || part == '..',
      )) {
    throw ArgumentError('phase must stay relative to the repository root');
  }
  final functionGrammarSource = File.fromUri(
    root.uri.resolve(userFunctionDefinitionSpecRelativePath),
  ).readAsStringSync();
  print(
    'HASH_VIEW_DART_GRAMMAR ${jsonEncode({'path': userFunctionDefinitionSpecRelativePath, 'source': functionGrammarSource})}',
  );
  final output = Directory.fromUri(root.uri.resolve('${arguments.single}/'));
  final fresh = Directory('${output.path}/fresh');
  Directory('${fresh.path}/lib').createSync(recursive: true);
  Directory('${fresh.path}/bin').createSync(recursive: true);
  final cases =
      (jsonDecode(File('${output.path}/cases.json').readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();
  final imports = StringBuffer("import 'dart:convert';\n");
  final main = StringBuffer('void main() {\n');
  for (var index = 0; index < cases.length; index++) {
    final row = cases[index];
    final id = row['id'] as String;
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(id)) {
      throw FormatException('unsafe authored case id: $id');
    }
    Map<String, Object?> actual;
    try {
      final parsed = parseSpecWithStagedUserFunctionDefinitions(
        row['source'] as String,
        parserSpecSource: functionGrammarSource,
      );
      final compiled = compileSpec(parsed);
      final restored = SpecFile.fromJson(
        (jsonDecode(jsonEncode(parsed.toJson())) as Map)
            .cast<String, Object?>(),
      );
      Directory('${fresh.path}/inputs').createSync(recursive: true);
      File(
        '${fresh.path}/inputs/case_$index.json',
      ).writeAsStringSync(jsonEncode(parsed.toJson()));
      final emitted = emitDartSourceV2(
        compiled,
        'hash-view-result-guard/$id.spec',
      );
      File('${fresh.path}/lib/case_$index.dart').writeAsStringSync(emitted);
      imports.writeln(
        "import 'package:hash_view_dart_fresh/case_$index.dart' as case_$index;",
      );
      main.writeln(
        'try { final value = case_$index.execute(${jsonEncode(row['input'])}); print("HASH_VIEW_DART_FRESH $id " + jsonEncode({"value": value})); } catch (error) { print("HASH_VIEW_DART_FRESH $id " + jsonEncode({"error": error.toString(), "class": error.runtimeType.toString()})); }',
      );
      print('HASH_VIEW_DART_INPUT $id ${jsonEncode(parsed.toJson())}');
      final input = row['input'] as String;
      actual = {
        'native': observe(
          () => LinkedSpecRuntimeEngine(compiled).execute(input).value,
        ),
        'restored': observe(
          () => LinkedSpecRuntimeEngine(
            compileSpec(restored),
          ).execute(input).value,
        ),
        'plan': observe(
          () => executeGeneratedParserV2(
            compiled,
            buildGeneratedRulePlan(compiled),
            input,
            'hash-view-result-guard-assessment.spec',
          ),
        ),
      };
    } catch (error) {
      actual = {
        'preparation_error': error.toString(),
        'class': error.runtimeType.toString(),
      };
    }
    print('HASH_VIEW_DART $id ${jsonEncode(actual)}');
  }
  main.writeln('}');
  File('${fresh.path}/bin/main.dart').writeAsStringSync('$imports\n$main');
}
