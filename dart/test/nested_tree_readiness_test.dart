import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

import '../../tests/language-readiness/nested-tree/dart_checks.dart' as checks;

Map<String, String> variants(String source) {
  const prefix =
      ' if(matches(input_slice(0, cursor_pos()), /[^ \\t\\r\\n\\f\\x0B]/));\n'
      '  exit_now(1);\n endif();\n';
  const gap = ' -> Invalid { exit_now(1) }\n';
  const span = '[start, cursor_pos()]';
  expect(prefix.allMatches(source), hasLength(1));
  expect(gap.allMatches(source), hasLength(2));
  expect(span.allMatches(source), hasLength(1));
  return {
    'original': source,
    'prefix': source.replaceAll(prefix, ''),
    'gap': source.replaceAll(gap, ''),
    'span': source.replaceAll(span, '[cursor_pos(), cursor_pos()]'),
  };
}

void checkVariant(String id, Map<String, dynamic> cases, checks.Parse parse) {
  if (id == 'original') {
    expect(checks.sequence(cases, parse), 40);
  } else {
    checks.mutation(id, cases, parse);
  }
}

void main() {
  final root = Directory(Platform.environment['LINKEDSPEC_REPO_ROOT']!);
  final fixture = Directory(
    '${root.path}/tests/language-readiness/nested-tree',
  );
  final source = File('${fixture.path}/grammar.spec').readAsStringSync();
  final casesText = File('${fixture.path}/cases.json').readAsStringSync();
  final cases = jsonDecode(casesText) as Map<String, dynamic>;

  test('native and generated routes preserve nesting and typed recovery', () {
    for (final entry in variants(source).entries) {
      final parsed = parseSpecWithStagedUserFunctionDefinitions(entry.value);
      validateSpec(parsed);
      final reconstructed = SpecFile.fromJson(
        (jsonDecode(jsonEncode(parsed.toJson())) as Map)
            .cast<String, Object?>(),
      );
      validateSpec(reconstructed);
      for (final spec in [parsed, reconstructed]) {
        final compiled = compileSpec(spec);
        final plan = buildGeneratedRulePlan(compiled);
        validateGeneratedRulePlanV2(compiled, plan, entry.key);
        expect(plan.map((row) => row.label), [
          'Top',
          'List',
          'Atom',
          'Space',
          'Invalid',
        ]);
        final families = {
          for (final row in plan)
            row.label: GeneratedRuleFamily.fromWireName(row.family)!,
        };
        final engine = LinkedSpecRuntimeEngine(compiled);
        // Four routes retain the engine across every rejection and recovery.
        checkVariant(entry.key, cases, (input) => engine.parse(input).value);
        checkVariant(
          entry.key,
          cases,
          (input) =>
              engine.executeGeneratedWithPlan(input, families, entry.key).value,
        );
      }
      final compiled = compileSpec(parsed);
      final plan = buildGeneratedRulePlan(compiled);
      // The public convenience entry creates an engine per call.
      checkVariant(
        entry.key,
        cases,
        (input) => executeGeneratedParserV2(compiled, plan, input, entry.key),
      );
    }
  });

  test('fresh emitted modules preserve values and mutation sensitivity', () async {
    final scratch = Directory('${root.path}/.linkedspec-data/scratch')
      ..createSync(recursive: true);
    final child = scratch.createTempSync('nested-tree-dart-');
    try {
      Directory('${child.path}/lib').createSync();
      Directory('${child.path}/bin').createSync();
      File('${child.path}/pubspec.yaml').writeAsStringSync('''
name: nested_tree_readiness_emitted
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ../../../dart
''');
      File('${child.path}/cases.json').writeAsStringSync(casesText);
      File(
        '${fixture.path}/dart_checks.dart',
      ).copySync('${child.path}/lib/checks.dart');
      final imports = StringBuffer(
        "import 'dart:convert';\nimport 'dart:io';\n"
        "import '../lib/checks.dart' as checks;\n",
      );
      final body = StringBuffer(
        'void main() {\n'
        "  final cases = jsonDecode(File('cases.json').readAsStringSync()) as Map<String, dynamic>;\n"
        '  var modules = 0;\n',
      );
      for (final entry in variants(source).entries) {
        final id = entry.key;
        final parsed = parseSpecWithStagedUserFunctionDefinitions(entry.value);
        validateSpec(parsed);
        File('${child.path}/lib/$id.dart').writeAsStringSync(
          emitDartSourceV2(compileSpec(parsed), 'nested-tree/$id'),
        );
        imports.writeln("import '../lib/$id.dart' as $id;");
        body.writeln('''
  checks.exactJson($id.metadata().toJson(), {
    'contract_id': 'linkedspec-generated-source-v2',
    'format_version': 2,
    'source_identity': 'nested-tree/$id',
  });
  $id.validatePlan($id.plan());
''');
        body.writeln(
          id == 'original'
              ? '  checks.require(checks.sequence(cases, (input) => $id.execute(input)) == 40, "execution count");'
              : '  checks.mutation("$id", cases, (input) => $id.execute(input));',
        );
        body.writeln('  modules++;');
      }
      body.writeln(
        "  print(jsonEncode({'modules': modules, 'original_executions': 40, 'mutations': 3}));\n}",
      );
      File('${child.path}/bin/main.dart').writeAsStringSync('$imports$body');
      for (final arguments in const [
        ['pub', 'get', '--offline'],
        ['analyze', '--fatal-infos', '--fatal-warnings'],
        ['run', 'bin/main.dart'],
      ]) {
        final process = await Process.run(
          Platform.resolvedExecutable,
          arguments,
          workingDirectory: child.path,
        );
        expect(
          process.exitCode,
          0,
          reason:
              '${arguments.join(' ')}\n${process.stdout}\n${process.stderr}',
        );
        if (arguments.first == 'run') {
          checks.exactJson(jsonDecode((process.stdout as String).trim()), {
            'modules': 4,
            'original_executions': 40,
            'mutations': 3,
          });
        }
      }
    } finally {
      child.deleteSync(recursive: true);
    }
  });
}
