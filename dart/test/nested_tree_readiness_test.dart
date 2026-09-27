import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

import '../../tests/language-readiness/nested-tree/dart_checks.dart' as checks;
import '../../tests/language-readiness/lossless-child/dart_carriers.dart'
    as lossless;

Directory createReadinessWorkspace(Directory root) {
  final scratch = Directory('${root.path}/.linkedspec-data/scratch')
    ..createSync(recursive: true);
  return scratch.createTempSync('nested-tree-dart-');
}

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

Map<String, String> contextVariants(String source) {
  const comparison =
      '  if(str_ne(match_group(0), name));\n   exit_now(2);\n  endif();\n';
  const recursiveEdge = ' -> Element { push(children, call(Element)) }\n';
  const corruptEdge =
      ' -> Element { push(children, call(Element)); name = "lost" }\n';
  const span = '[start, cursor_pos()]';
  expect(comparison.allMatches(source), hasLength(1));
  expect(recursiveEdge.allMatches(source), hasLength(1));
  expect(span.allMatches(source), hasLength(1));
  return {
    'original': source,
    'comparison': source.replaceAll(comparison, ''),
    'state': source.replaceAll(recursiveEdge, corruptEdge),
    'span': source.replaceAll(span, '[cursor_pos(), cursor_pos()]'),
  };
}

class ReadinessFixture {
  const ReadinessFixture({
    required this.name,
    required this.labels,
    required this.sourceVariants,
    this.acceptedCount = 6,
    this.rejectedCount = 7,
    this.recoveryId = 'nested_state',
    this.spanCase = 'nested_state',
    this.spanEnd = 9,
  });
  final String name;
  final List<String> labels;
  final Map<String, String> Function(String) sourceVariants;
  final int acceptedCount;
  final int rejectedCount;
  final String recoveryId;
  final String spanCase;
  final int spanEnd;
  int get executions => 2 * (acceptedCount + 2 * rejectedCount);

  void check(String id, Map<String, dynamic> cases, checks.Parse parse) {
    if (id == 'original') {
      expect(
        checks.sequence(
          cases,
          parse,
          acceptedCount: acceptedCount,
          rejectedCount: rejectedCount,
          recoveryId: recoveryId,
        ),
        executions,
      );
    } else {
      checks.mutation(id, cases, parse, spanEnd: spanEnd, spanCase: spanCase);
    }
  }
}

void main() {
  final root = Directory(Platform.environment['LINKEDSPEC_REPO_ROOT']!);
  lossless.register(root, () => createReadinessWorkspace(root));
  for (final fixture in const [
    ReadinessFixture(
      name: 'nested-tree',
      labels: ['Top', 'List', 'Atom', 'Space', 'Invalid'],
      sourceVariants: variants,
    ),
    ReadinessFixture(
      name: 'context-names',
      labels: ['Top', 'Element', 'Text', 'Space', 'Invalid'],
      sourceVariants: contextVariants,
      acceptedCount: 11,
      rejectedCount: 17,
      recoveryId: 'siblings_restore_parent',
      spanCase: 'nested_distinct',
      spanEnd: 17,
    ),
  ]) {
    registerFixture(root, fixture);
  }
}

void registerFixture(Directory root, ReadinessFixture config) {
  final fixture = Directory(
    '${root.path}/tests/language-readiness/${config.name}',
  );
  final source = File('${fixture.path}/grammar.spec').readAsStringSync();
  final casesText = File('${fixture.path}/cases.json').readAsStringSync();
  final cases = jsonDecode(casesText) as Map<String, dynamic>;

  test(
    '${config.name}: native and generated routes preserve typed recovery',
    () {
      for (final entry in config.sourceVariants(source).entries) {
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
          expect(plan.map((row) => row.label), config.labels);
          final families = {
            for (final row in plan)
              row.label: GeneratedRuleFamily.fromWireName(row.family)!,
          };
          final engine = LinkedSpecRuntimeEngine(compiled);
          // Four routes retain the engine across every rejection and recovery.
          config.check(entry.key, cases, (input) => engine.parse(input).value);
          config.check(
            entry.key,
            cases,
            (input) => engine
                .executeGeneratedWithPlan(input, families, entry.key)
                .value,
          );
        }
        final compiled = compileSpec(parsed);
        final plan = buildGeneratedRulePlan(compiled);
        // The public convenience entry creates an engine per call.
        config.check(
          entry.key,
          cases,
          (input) => executeGeneratedParserV2(compiled, plan, input, entry.key),
        );
      }
    },
  );

  test('${config.name}: fresh emitted modules preserve mutation sensitivity', () async {
    final child = createReadinessWorkspace(root);
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
        '${root.path}/tests/language-readiness/nested-tree/dart_checks.dart',
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
      for (final entry in config.sourceVariants(source).entries) {
        final id = entry.key;
        final parsed = parseSpecWithStagedUserFunctionDefinitions(entry.value);
        validateSpec(parsed);
        File('${child.path}/lib/$id.dart').writeAsStringSync(
          emitDartSourceV2(compileSpec(parsed), '${config.name}/$id'),
        );
        imports.writeln("import '../lib/$id.dart' as $id;");
        body.writeln('''
  checks.exactJson($id.metadata().toJson(), {
    'contract_id': 'linkedspec-generated-source-v2',
    'format_version': 2,
    'source_identity': '${config.name}/$id',
  });
  $id.validatePlan($id.plan());
''');
        body.writeln(
          id == 'original'
              ? '  checks.require(checks.sequence(cases, (input) => $id.execute(input), acceptedCount: ${config.acceptedCount}, rejectedCount: ${config.rejectedCount}, recoveryId: "${config.recoveryId}") == ${config.executions}, "execution count");'
              : '  checks.mutation("$id", cases, (input) => $id.execute(input), spanEnd: ${config.spanEnd}, spanCase: "${config.spanCase}");',
        );
        body.writeln('  modules++;');
      }
      body.writeln(
        "  print(jsonEncode({'modules': modules, 'original_executions': ${config.executions}, 'mutations': 3}));\n}",
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
            'original_executions': config.executions,
            'mutations': 3,
          });
        }
      }
    } finally {
      child.deleteSync(recursive: true);
    }
  });
}
