import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

final Map<String, Object?> _contract =
    jsonDecode(
          File(
            '../capability_conformance/rule_local_cursor_contract.json',
          ).readAsStringSync(),
        )
        as Map<String, Object?>;

const _parentChildCases = <_ExecutionCase>[
  _ExecutionCase(
    id: 'and_to_or_blind',
    input: 'prefix x',
    expected: ['hit'],
    source: '''
Top::AND
 => Child
Child:
 /x/
 -> Child { return("hit") }
''',
  ),
  _ExecutionCase(
    id: 'or_to_and_blind',
    input: 'prefix x',
    source: '''
Top::|
 => Child
Child:AND
 /x/
 -> Child { return("hit") }
''',
  ),
  _ExecutionCase(
    id: 'and_to_or_action',
    input: 'x junk x',
    expected: 'hit',
    source: '''
Top::AND
 -> Child { return(call(Child)) }
Child:
 /x/
 -> Child { return("hit") }
''',
  ),
  _ExecutionCase(
    id: 'or_to_and_action',
    input: 'prefix x junk x',
    source: '''
Top::|
 -> Child { return(call(Child)) }
Child:AND
 /x/
 -> Child { return("hit") }
''',
  ),
  _ExecutionCase(
    id: 'and_to_or_call',
    input: 'p junk x',
    expected: 'hit',
    source: '''
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:
 /x/
 -> Child { return("hit") }
''',
  ),
  _ExecutionCase(
    id: 'or_to_and_call',
    input: 'prefix p junk x',
    source: '''
Top::|
 /p/
 -> Top { return(call(Child)) }
Child:AND
 /x/
 -> Child { return("hit") }
''',
  ),
  _ExecutionCase(
    id: 'and_to_or_recursion',
    input: 'p junk xp junk z',
    expected: 'done',
    source: '''
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:OR
 /x/ -> Child[0] { return(call(Top)) }
 /z/ -> Child[1] { return("done") }
''',
  ),
  _ExecutionCase(
    id: 'or_to_and_recursion',
    input: 'junk p junk x z',
    source: '''
Top::|
 /p/ -> Top[0] { return(call(Child)) }
 /z/ -> Top[1] { return("done") }
Child:AND
 /x/ -> Child { return(call(Top)) }
''',
  ),
];

const _structuralCases = <_ExecutionCase>[
  _ExecutionCase(
    id: 'ordered_landmarks',
    input: 'junk h junk b',
    expected: ['header', 'body'],
    source: '''
Top::AND
 => Header
 => Body
Header:
 /h/
 -> Header { return("header") }
Body:
 /b/
 -> Body { return("body") }
''',
  ),
  _ExecutionCase(
    id: 'anchored_choice',
    input: 'prefix x',
    source: '''
Top::|
 => X
 => Y
X:AND
 /x/
 -> X { return("x") }
Y:AND
 /y/
 -> Y { return("y") }
''',
  ),
];

void main() {
  test(
    'executes every neutral composition live reconstructed and generated',
    () {
      expect(
        _parentChildCases.map((item) => item.id).toSet(),
        _rows('parent_child_cases').map((row) => row['id']).toSet(),
      );
      expect(
        _structuralCases.map((item) => item.id).toSet(),
        _rows('structural_replacements').map((row) => row['id']).toSet(),
      );

      for (final item in [..._parentChildCases, ..._structuralCases]) {
        final parsed = parseSpec(item.source);
        final reconstructed = SpecFile.fromJson(
          _jsonObject(jsonDecode(jsonEncode(parsed.toJson()))),
        );
        for (final (route, spec) in [
          ('live', parsed),
          ('normalized JSON', reconstructed),
        ]) {
          final result = LinkedSpecRuntimeEngine(
            compileSpec(spec),
          ).parse(item.input);
          expect(result.value, item.expected, reason: '${item.id}: $route');
        }
        final compiled = compileSpec(parsed);
        expect(
          executeGeneratedParserV2(
            compiled,
            buildGeneratedRulePlan(compiled),
            item.input,
            'rule-local-cursor/${item.id}.spec',
          ),
          item.expected,
          reason: '${item.id}: generated v2',
        );
      }
    },
  );

  test('every neutral family spelling spends its entered policy', () {
    final rows = _rows('family_cases');
    expect(rows, hasLength(36));

    for (final row in rows) {
      final id = row['id']! as String;
      final header = row['header']! as String;
      final prefix = header.startsWith('Top::')
          ? ''
          : 'Root::\n I { return("unused") }\n\n';
      final parsed = parseSpec(
        '$prefix$header\n /x/ -> Top { return("hit") }\n',
      );
      final reconstructed = SpecFile.fromJson(
        _jsonObject(jsonDecode(jsonEncode(parsed.toJson()))),
      );
      final seeks = row['cursor_policy'] == 'seek';

      for (final (route, spec) in [
        ('live', parsed),
        ('normalized JSON', reconstructed),
      ]) {
        try {
          final value = LinkedSpecRuntimeEngine(
            compileSpec(spec),
          ).parse('prefix x', topRule: 'Top').value;
          expect(value, seeks ? 'hit' : null, reason: '$id: $route');
        } on RuntimeInterpreterException catch (error) {
          expect(seeks, isFalse, reason: '$id: $route: $error');
          expect(error.message, contains('expected at least'));
        }
      }

      final compiled = compileSpec(parsed);
      final generatedPlan = buildGeneratedRulePlan(compiled);
      final topPlan = generatedPlan.singleWhere((plan) => plan.label == 'Top');
      final generatedFamily = GeneratedRuleFamily.fromWireName(topPlan.family)!;
      expect(
        generatedFamily.cursorPolicy.name,
        row['cursor_policy'],
        reason: '$id: generated family policy',
      );
      for (final plan in generatedPlan) {
        expect(plan.toJson().keys.toSet(), {'label', 'family'});
      }
      try {
        final value = executeGeneratedParserV2(
          compiled,
          generatedPlan,
          'prefix x',
          'rule-local-cursor/$id.spec',
          topRule: 'Top',
        );
        expect(value, seeks ? 'hit' : null, reason: '$id: generated v2');
      } on GeneratedSourceException catch (error) {
        expect(seeks, isFalse, reason: '$id: generated v2: $error');
        expect(error.code, GeneratedSourceCode.generatedExecutionFailed);
        expect(error.detail, contains('expected at least'));
      }
    }
  });

  test('loaded execution and trace attribute policy to each rule entry', () {
    final item = _parentChildCases.singleWhere(
      (candidate) => candidate.id == 'and_to_or_call',
    );
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-rule-local-cursor-',
    );
    try {
      final specFile = File('${scratch.path}/loaded.spec')
        ..writeAsStringSync(item.source);
      final loaded = loadAndCompileSpec(
        SpecRequest.path(specFile.path),
        SpecLoadOptions(cwd: scratch),
      );
      expect(loaded.createEngine().parse(item.input).value, item.expected);

      final trace = LinkedSpecTraceEmitter(
        LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
        stdoutWriter: (_) {},
      );
      final traced = LinkedSpecRuntimeEngine(
        loaded.compiled,
      ).parse(item.input, trace: trace);
      expect(traced.value, item.expected);

      final ruleEntries = trace.events
          .where(
            (event) =>
                event.kind == LinkedSpecTraceEventKind.enter &&
                event.topic == 'dart_runtime:rule',
          )
          .map((event) => event.details)
          .toList();
      expect(
        ruleEntries,
        contains(
          allOf(contains('label=Top '), contains('cursor_policy=consume')),
        ),
      );
      expect(
        ruleEntries,
        contains(
          allOf(contains('label=Child '), contains('cursor_policy=seek')),
        ),
      );
    } finally {
      scratch.deleteSync(recursive: true);
    }
    expect(scratch.existsSync(), isFalse);
  });

  test('public global cursor override source is removed', () {
    final engineSource = File(
      'lib/src/runtime/interpreter.dart',
    ).readAsStringSync();
    final loaderSource = File('lib/src/io/spec_loader.dart').readAsStringSync();
    final corpusSource = File(
      'lib/src/corpus/manifest_runner.dart',
    ).readAsStringSync();
    final parserAdapterSource = File(
      'lib/src/parser/user_function_definition_parser.dart',
    ).readAsStringSync();
    final primarySource = File(
      'lib/src/cli/primary_cli.dart',
    ).readAsStringSync();

    expect(engineSource, isNot(contains('this.parseMode =')));
    expect(engineSource, isNot(contains('required this.parseMode')));
    expect(loaderSource, isNot(contains('LinkedSpecParseMode parseMode')));
    expect(corpusSource, isNot(contains('LinkedSpecParseMode parseMode')));
    expect(parserAdapterSource, isNot(contains('parseMode:')));
    expect(primarySource, isNot(contains('parse_mode=')));
    expect(primarySource, isNot(contains('--parse-mode MODE')));

    final matcherSource = File(
      'lib/src/runtime/matching.dart',
    ).readAsStringSync();
    expect(matcherSource, contains('LinkedSpecParseMode parseMode'));
    expect(matcherSource, contains('seekMatch'));
    expect(matcherSource, contains('consumeMatch'));
  });

  test('generated-source v2 derives policy from each family row', () {
    final andCompiled = compileSpec(
      parseSpec('Top::AND\n /x/ -> Top { return("hit") }\n'),
    );
    expect(
      LinkedSpecRuntimeEngine(andCompiled).parse('prefix x').value,
      isNull,
    );
    expect(
      executeGeneratedParserV2(
        andCompiled,
        buildGeneratedRulePlan(andCompiled),
        'prefix x',
        'cursor-v2-and.spec',
      ),
      isNull,
    );

    final pipeCompiled = compileSpec(
      parseSpec('''
Top::|
 => X
 => Y
 E { return(retv) }
X: /x/ E { return("x") }
Y: /y/ E { return("y") }
'''),
    );
    expect(LinkedSpecRuntimeEngine(pipeCompiled).parse('xy').value, 'x');
    expect(
      classifyGeneratedRuleFamily(pipeCompiled.rule('Top')!),
      GeneratedRuleFamily.orBcode,
    );
    expect(
      executeGeneratedParserV2(
        pipeCompiled,
        buildGeneratedRulePlan(pipeCompiled),
        'xy',
        'cursor-v2-pipe.spec',
      ),
      'x',
    );
  });
}

List<Map<String, Object?>> _rows(String name) {
  return (_contract[name]! as List)
      .map((item) => Map<String, Object?>.from(item! as Map))
      .toList(growable: false);
}

Map<String, Object?> _jsonObject(Object? value) {
  return Map<String, Object?>.from(value! as Map);
}

final class _ExecutionCase {
  const _ExecutionCase({
    required this.id,
    required this.source,
    required this.input,
    this.expected,
  });

  final String id;
  final String source;
  final String input;
  final Object? expected;
}
