import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('parses rule headers, inline body elements, and mode variants', () {
    final modes = <String, RuleMode>{
      'R1:AND': RuleMode.and,
      'R2:OR+': RuleMode.orPlus,
      'R3::*': RuleMode.star,
      'R4:?': RuleMode.optional,
      'R5:AND{2,4}': RuleMode.andBounded(min: 2, max: 4),
      'R6:OR{3}': RuleMode.orBounded(min: 3, max: 3),
      'R7:&': RuleMode.single,
      'R8:|': RuleMode.pipe,
    };

    for (final entry in modes.entries) {
      final spec = parseSpec('${entry.key}\n /x/');
      expect(spec.rules.single.header.mode, entry.value, reason: entry.key);
      expect(spec.rules.single.body.single.kind, isA<RegexBodyElementKind>());
    }

    final inline = parseSpec(
      'Top:: /x/ I { return(entry_text()) } E.return("done")',
    );
    expect(
      inline.rules.single.header.rest,
      '/x/ I { return(entry_text()) } E.return("done")',
    );
    expect(inline.rules.single.body[0].kind, isA<RegexBodyElementKind>());
    expect(inline.rules.single.body[1].kind, isA<CodeBlockBodyElementKind>());
    expect(inline.rules.single.body[2].kind, isA<CodeBlockBodyElementKind>());
  });

  test(
    'registers regex literals on header lines instead of swallowing them',
    () {
      final single = parseSpec('Top::\n -> semi\n\nsemi : /;/');
      final semi = single.findRule('semi')!;
      expect(_regexPatternsOf(semi), [';']);

      final pair = parseSpec('Top::\n -> bracket\n\nbracket : /\\(/ /\\)/');
      final bracket = pair.findRule('bracket')!;
      expect(_regexPatternsOf(bracket), ['\\(', '\\)']);
    },
  );

  test('parses action and blind edges with blocks and fluent chains', () {
    final spec = parseSpec(r'''
Top::->Child.push
 -> Child[1] .return(array("?child:", copy(Child)))
 -> A | B { return(entry_text()) }
 =>Helper.trim()

Child: /x/ /y/
Helper: /h/
''');

    final top = spec.topRule!;
    expect(top.body.length, 4);

    final compact = top.body[0].kind as ActionEdgeBodyElementKind;
    expect(compact.targets.single.label, 'Child');
    expect(compact.targets.single.index, 0);
    expect(compact.fluentChain.single.method, 'push');

    final indexed = top.body[1].kind as ActionEdgeBodyElementKind;
    expect(indexed.targets.single.index, 1);
    expect(indexed.fluentChain.single.method, 'return');
    expect(indexed.fluentChain.single.args, 'array("?child:", copy(Child))');

    final grouped = top.body[2].kind as ActionEdgeBodyElementKind;
    expect(grouped.targets.map((target) => target.label), ['A', 'B']);
    expect(grouped.code, 'return(entry_text())');

    final blind = top.body[3].kind as BlindEdgeBodyElementKind;
    expect(blind.target, 'Helper');
    expect(blind.fluentChain.single.method, 'trim');
  });

  test('attaches multiline fluent continuations to action edges', () {
    final spec = parseSpec(r'''
Top::
 -> item
  .if(on)
    .push(item, out)
  .else()
    .return_undef()
  .endif()

item: /x/
''');

    final edge = spec.topRule!.body.single.kind as ActionEdgeBodyElementKind;
    expect(edge.fluentChain.map((call) => (call.method, call.args)), [
      ('if', 'on'),
      ('push', 'item, out'),
      ('else', ''),
      ('return_undef', ''),
      ('endif', ''),
    ]);
  });

  test('normalizes receiver-fluent when otherwise blocks to attached code', () {
    final spec = parseSpec(r'''
Top::
 -> Done.when(false) {
    return("bad")
 }.otherwise {
    return("fallback")
 }
 I.when(false) { set(out, "bad") } otherwise { set(out, "fallback") }

Done:
 /x/
''');

    final action = spec.topRule!.body[0].kind as ActionEdgeBodyElementKind;
    expect(action.fluentChain, isEmpty);
    expect(action.code, contains('when(false)'));
    expect(action.code, contains('return("fallback")'));

    final lifecycle = spec.topRule!.body[1].kind as CodeBlockBodyElementKind;
    expect(lifecycle.lifecycle, 'I');
    expect(lifecycle.code, contains('otherwise'));
    expect(lifecycle.code, contains('set(out, "fallback")'));
  });

  test('parses lifecycle compact fluent chains as code blocks', () {
    final compact = parseSpec(r'''
Top::
 I.set(out, undef).set(out, "ok").return(out)
 /x/
''');
    final block = compact.topRule!.body[0].kind as CodeBlockBodyElementKind;
    expect(block.code, 'set(out, undef); set(out, "ok"); return(out)');

    final multilineArgs = parseSpec(r'''
Top::
 I.return({
  "type" => "function_definition_error",
  "source_text" => entry_text()
 })
 /x/
''');
    final multilineBlock =
        multilineArgs.topRule!.body[0].kind as CodeBlockBodyElementKind;
    expect(multilineBlock.code, startsWith('return({'));
    expect(multilineBlock.code, contains('"source_text" => entry_text()'));
    expect(multilineArgs.topRule!.body[1].kind, isA<RegexBodyElementKind>());
  });

  test('keeps braces inside quoted code-block strings as code text', () {
    final spec = parseSpec(r'''
Top::
 /a/ I { print("literal { brace"); print('literal } brace') }
 /b/ E { return("ok") }
''');

    final block = spec.topRule!.body[1].kind as CodeBlockBodyElementKind;
    expect(block.code, contains('print("literal { brace")'));
    expect(block.code, contains("print('literal } brace')"));
    expect(spec.topRule!.body[2].kind, isA<RegexBodyElementKind>());
  });

  test(
    'preserves raw fallback lines and rejects pre-rule function definitions',
    () {
      final raw = parseSpec('Top::\n raw compatibility line');
      expect(raw.topRule!.body.single.kind, isA<RawBodyElementKind>());

      expect(
        () => parseSpec(
          'fn normalize(value) { return(trim(value)) }\n\nTop::\n /x/',
        ),
        throwsA(isA<SpecParseException>()),
      );
    },
  );

  test('parses every shipped spec source file', () {
    final specFiles =
        Directory('../specs')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.spec'))
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    expect(specFiles, isNotEmpty);
    for (final file in specFiles) {
      final parsed = parseSpec(file.readAsStringSync());
      expect(parsed.rules, isNotEmpty, reason: file.path);
    }
  });

  test(
    'parses corpus rule specs that do not start with function definitions',
    () {
      final corpusSpecs =
          Directory('../rust/linkedspec-runtime/tests/corpus')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('/input.spec'))
              .toList()
            ..sort((left, right) => left.path.compareTo(right.path));

      var parsedCount = 0;
      var skippedFunctionShells = 0;
      for (final file in corpusSpecs) {
        final source = file.readAsStringSync();
        if (_startsWithTopLevelFunction(source)) {
          skippedFunctionShells += 1;
          continue;
        }
        final parsed = parseSpec(source);
        expect(parsed.rules, isNotEmpty, reason: file.path);
        parsedCount += 1;
      }

      expect(parsedCount, greaterThan(80));
      expect(skippedFunctionShells, greaterThan(0));
    },
  );
}

List<String> _regexPatternsOf(Rule rule) {
  return [
    for (final element in rule.body)
      if (element.kind case final RegexBodyElementKind regex) regex.pattern,
  ];
}

bool _startsWithTopLevelFunction(String source) {
  for (final line in source.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    return trimmed.startsWith('fn ');
  }
  return false;
}
