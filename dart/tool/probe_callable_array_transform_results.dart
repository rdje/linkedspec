import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'callable_array_transform_observation.dart' as observation;

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
    'CALLABLE_TRANSFORM_DART_GRAMMAR ${jsonEncode({'path': userFunctionDefinitionSpecRelativePath, 'source': functionGrammarSource})}',
  );
  final output = Directory.fromUri(root.uri.resolve('${arguments.single}/'));
  final fresh = Directory('${output.path}/fresh');
  Directory('${fresh.path}/lib').createSync(recursive: true);
  Directory('${fresh.path}/bin').createSync(recursive: true);
  File.fromUri(
    root.uri.resolve('dart/tool/callable_array_transform_observation.dart'),
  ).copySync('${fresh.path}/lib/observation.dart');
  final cases =
      (jsonDecode(File('${output.path}/cases.json').readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();
  final imports = StringBuffer(
    "import 'dart:convert';\nimport 'package:array_transform_callable_dart_fresh/observation.dart' as observation;\n",
  );
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
      Directory('${fresh.path}/inputs').createSync(recursive: true);
      final serialized = jsonEncode(parsed.toJson());
      final inputFile = File('${fresh.path}/inputs/case_$index.json');
      inputFile.writeAsStringSync(serialized);
      final retained = inputFile.readAsStringSync();
      if (retained != serialized) {
        throw StateError('parsed input changed before SDK restoration');
      }
      print('CALLABLE_TRANSFORM_DART_INPUT $id $retained');
      final compiled = compileSpec(parsed);
      final restored = SpecFile.fromJson(
        (jsonDecode(retained) as Map).cast<String, Object?>(),
      );
      final emitted = emitDartSourceV2(
        compiled,
        'array-transform-callable-result-guard/$id.spec',
      );
      File('${fresh.path}/lib/case_$index.dart').writeAsStringSync(emitted);
      imports.writeln(
        "import 'package:array_transform_callable_dart_fresh/case_$index.dart' as case_$index;",
      );
      main.writeln(
        'print("CALLABLE_TRANSFORM_DART_FRESH $id " + jsonEncode(observation.observeCallableTransform(() => case_$index.execute(${jsonEncode(row['input'])}))));',
      );
      final input = row['input'] as String;
      actual = {
        'native': observation.observeCallableTransform(
          () => LinkedSpecRuntimeEngine(compiled).execute(input).value,
        ),
        'restored': observation.observeCallableTransform(
          () => LinkedSpecRuntimeEngine(
            compileSpec(restored),
          ).execute(input).value,
        ),
        'plan': observation.observeCallableTransform(
          () => executeGeneratedParserV2(
            compiled,
            buildGeneratedRulePlan(compiled),
            input,
            'array-transform-callable-result-guard-assessment.spec',
          ),
        ),
      };
    } catch (error) {
      actual = {
        'preparation_error': true,
        ...observation.callablePipelineError(error),
      };
    }
    print('CALLABLE_TRANSFORM_DART $id ${jsonEncode(actual)}');
  }
  main.writeln('}');
  File('${fresh.path}/bin/main.dart').writeAsStringSync('$imports\n$main');
}
