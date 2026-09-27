import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

import 'dart_checks.dart' as checks;
import '../nested-tree/dart_checks.dart' show exactJson;

String replaceOnce(String source, String from, String to) {
  expect(from.allMatches(source), hasLength(1), reason: 'mutation owner');
  return source.replaceAll(from, to);
}

Map<String, String> segmentVariants(String source) {
  const prefix =
      '  if(num_ne(cursor_pos(), 0));\n'
      '   push(parts, hash("kind", "entry_prefix", "span", [0, cursor_pos()], "text", input_slice(0, cursor_pos())))\n'
      '  endif();\n';
  const tail =
      ' LX {\n  push(parts, hash("kind", gap_kind(), "span", gap_span(), "text", gap_text()))\n';
  return {
    'selection': replaceOnce(source, '[0-9]', '[1-9]'),
    'tail': replaceOnce(source, tail, ' LX {\n'),
    'item_span': replaceOnce(
      source,
      '[entry_start_pos(), entry_end_pos()]',
      '[entry_end_pos(), entry_end_pos()]',
    ),
    'entry_prefix': replaceOnce(source, prefix, ''),
  };
}

Map<String, ({bool parent, String source})> childVariants(
  String parent,
  String child,
) => {
  'leading_zero': (
    parent: false,
    source: replaceOnce(child, '(0|[1-9][0-9]*)', '([0-9]+)'),
  ),
  'wrong_span': (
    parent: false,
    source: replaceOnce(
      child,
      '"start", entry_start_pos()',
      '"start", num_add(entry_start_pos(), 1)',
    ),
  ),
  'whole_item': (
    parent: true,
    source: replaceOnce(
      parent,
      'parse_job(entry_group(0)',
      'parse_job(entry_text()',
    ),
  ),
};

List<checks.Builder> carriers(String source, List<String> labels) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  validateSpec(parsed);
  final restored = SpecFile.fromJson(
    checks.object(jsonDecode(jsonEncode(parsed.toJson()))),
  );
  validateSpec(restored);
  final routes = <checks.Builder>[];
  for (final spec in [parsed, restored]) {
    final compiled = compileSpec(spec);
    final plan = buildGeneratedRulePlan(compiled);
    validateGeneratedRulePlanV2(compiled, plan, 'lossless/readiness');
    expect(plan.map((row) => row.label), labels);
    final families = {
      for (final row in plan)
        row.label: GeneratedRuleFamily.fromWireName(row.family)!,
    };
    routes.add((seed) {
      final engine = LinkedSpecRuntimeEngine(
        compiled,
        stagedAstEnrichmentSeed: seed,
      );
      return (input) => engine.parse(input).value;
    });
    routes.add((seed) {
      final engine = LinkedSpecRuntimeEngine(
        compiled,
        stagedAstEnrichmentSeed: seed,
      );
      return (input) => engine
          .executeGeneratedWithPlan(input, families, 'lossless/readiness')
          .value;
    });
  }
  final compiled = compileSpec(parsed);
  final plan = buildGeneratedRulePlan(compiled);
  // Public v2 execution creates an engine per call; it proves isolation only.
  routes.add(
    (seed) =>
        (input) => executeGeneratedParserV2(
          compiled,
          plan,
          input,
          'lossless/readiness',
          stagedAstEnrichmentSeed: seed,
        ),
  );
  return routes;
}

void register(Directory root, Directory Function() createWorkspace) {
  final fixture = '${root.path}/tests/language-readiness/lossless-child';
  final segments = File(
    '${root.path}/tests/language-readiness/lossless-segments/grammar.spec',
  ).readAsStringSync();
  final casesText = File(
    '${root.path}/tests/language-readiness/lossless-segments/cases.json',
  ).readAsStringSync();
  final parent = File('$fixture/parent.spec').readAsStringSync();
  final child = File('$fixture/child.spec').readAsStringSync();
  final strictText = File('$fixture/cases.json').readAsStringSync();
  final cases = checks.object(jsonDecode(casesText));
  final strict = checks.object(jsonDecode(strictText));
  test('lossless: five matched carriers preserve actual child recognition and outcomes', () {
    final segmentRoutes = carriers(segments, ['Item', 'Segments']);
    final parents = carriers(parent, ['Item', 'Segments']);
    final children = carriers(child, ['Number', 'Digits']);
    Object? records;
    for (var route = 0; route < 5; route++) {
      checks.segmentation(cases, segmentRoutes[route](null));
      final result = checks.children(
        cases,
        strict,
        parents[route],
        children[route](null),
        checks.digest(child),
      );
      if (records == null) {
        records = result;
      } else {
        exactJson(result, records);
      }
    }
    for (final entry in segmentVariants(segments).entries) {
      for (final build in carriers(entry.value, ['Item', 'Segments'])) {
        checks.segmentMutation(entry.key, cases, build(null));
      }
    }
    for (final entry in childVariants(parent, child).entries) {
      final variant = entry.value;
      final routes = carriers(
        variant.source,
        variant.parent ? ['Item', 'Segments'] : ['Number', 'Digits'],
      );
      for (var i = 0; i < 5; i++) {
        checks.childMutation(
          entry.key,
          variant.parent ? routes[i] : parents[i],
          (variant.parent ? children[i] : routes[i])(null),
          checks.digest(variant.parent ? child : variant.source),
        );
      }
    }
  });

  test('lossless: fresh emitted parent and children pass strict analysis and execution', () async {
    final workspace = createWorkspace();
    try {
      Directory('${workspace.path}/lib/lossless-child')
          .createSync(recursive: true);
      Directory('${workspace.path}/lib/nested-tree').createSync();
      Directory('${workspace.path}/bin').createSync();
      File('${workspace.path}/pubspec.yaml').writeAsStringSync('''
name: lossless_child_readiness_emitted
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ../../../dart
dev_dependencies:
  test: ^1.25.0
''');
      File('$fixture/dart_checks.dart')
          .copySync('${workspace.path}/lib/lossless-child/dart_checks.dart');
      // Analyze the outer carrier producer in the same valid package context too.
      File('$fixture/dart_carriers.dart')
          .copySync('${workspace.path}/lib/lossless-child/dart_carriers.dart');
      File('${root.path}/tests/language-readiness/nested-tree/dart_checks.dart')
          .copySync('${workspace.path}/lib/nested-tree/dart_checks.dart');
      File('${workspace.path}/cases.json').writeAsStringSync(casesText);
      File('${workspace.path}/strict.json').writeAsStringSync(strictText);
      final modules = <String, String>{
        'segments': segments,
        'parent': parent,
        'child': child,
        for (final entry in segmentVariants(segments).entries)
          'segment_${entry.key}': entry.value,
        for (final entry in childVariants(parent, child).entries)
          entry.key: entry.value.source,
      };
      final imports = StringBuffer(
        "import 'dart:convert';\nimport 'dart:io';\n"
        "import '../lib/lossless-child/dart_checks.dart' as checks;\n"
        "import '../lib/nested-tree/dart_checks.dart' show exactJson;\n",
      );
      final body = StringBuffer(
        "void main() {\n"
        "final cases=checks.object(jsonDecode(File('cases.json').readAsStringSync()));\n"
        "final strict=checks.object(jsonDecode(File('strict.json').readAsStringSync()));\n"
        "var modules=0;\n",
      );
      for (final entry in modules.entries) {
        final id = entry.key;
        final parsed = parseSpecWithStagedUserFunctionDefinitions(entry.value);
        validateSpec(parsed);
        File('${workspace.path}/lib/$id.dart').writeAsStringSync(
          emitDartSourceV2(compileSpec(parsed), 'lossless/$id'),
        );
        imports.writeln("import '../lib/$id.dart' as $id;");
        body.writeln(
          "exactJson($id.metadata().toJson(), {'contract_id':'linkedspec-generated-source-v2','format_version':2,'source_identity':'lossless/$id'});\n"
          "$id.validatePlan($id.plan()); modules++;\n",
        );
      }
      body.writeln(
        "checks.segmentation(cases,(input)=>segments.execute(input));\n"
        "checks.children(cases,strict,(seed)=>(input)=>parent.execute(input,stagedAstEnrichmentSeed:seed),"
        "(input)=>child.execute(input),'${checks.digest(child)}');\n",
      );
      for (final id in segmentVariants(segments).keys) {
        body.writeln(
          "checks.segmentMutation('$id',cases,(input)=>segment_$id.execute(input));",
        );
      }
      for (final entry in childVariants(parent, child).entries) {
        final parentId = entry.value.parent ? entry.key : 'parent';
        final childId = entry.value.parent ? 'child' : entry.key;
        final digest = checks.digest(
          entry.value.parent ? child : entry.value.source,
        );
        body.writeln(
          "checks.childMutation('${entry.key}',(seed)=>(input)=>$parentId.execute(input,stagedAstEnrichmentSeed:seed),"
          "(input)=>$childId.execute(input),'$digest');",
        );
      }
      body.writeln(
        "print(jsonEncode({'modules':modules,'segmentation_cases':13,'child_accept':4,'child_reject':15,'mutations':7}));\n}",
      );
      File('${workspace.path}/bin/main.dart')
          .writeAsStringSync('$imports$body');
      for (final arguments in const [
        ['pub', 'get', '--offline'],
        ['analyze', '--fatal-infos', '--fatal-warnings'],
        ['run', 'bin/main.dart'],
      ]) {
        final result = await Process.run(
          Platform.resolvedExecutable,
          arguments,
          workingDirectory: workspace.path,
        );
        expect(
          result.exitCode,
          0,
          reason: '${arguments.join(' ')}\n${result.stdout}\n${result.stderr}',
        );
        if (arguments.first == 'run') {
          exactJson(jsonDecode((result.stdout as String).trim()), {
            'modules': 10,
            'segmentation_cases': 13,
            'child_accept': 4,
            'child_reject': 15,
            'mutations': 7,
          });
        }
      }
    } finally {
      workspace.deleteSync(recursive: true);
    }
  });
}
