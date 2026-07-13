import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  final contract =
      jsonDecode(
            File(
              '../capability_conformance/uniform_binding_contract.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;

  test('exact aggregate selectors fail at the Dart compile boundary', () {
    final cases = (contract['invalid_selector_cases']! as List)
        .cast<Map<String, Object?>>();
    for (final item in cases) {
      final source = item['source']! as String;
      final expected = _selectorDiagnostic(item);
      expect(
        () => _compile(_actionSource(source)),
        throwsA(
          isA<CompiledSpecException>().having(
            (error) => error.message,
            'message',
            contains(expected),
          ),
        ),
        reason: item['id']! as String,
      );
    }
  });

  test('dead fluent and unused function selectors also fail compilation', () {
    final deadSource = _actionSource(
      'if(false) { return(array(items)) }; return([])', // selector-rejection fixture
    );
    expect(
      () => _compile(deadSource),
      throwsA(_selectorCompileError('array', 'items')),
    );

    const fluentSource =
        'Top::\n -> Done.return(hash(meta))\nDone::\n /x/\n'; // selector-rejection fixture
    expect(
      () => _compile(fluentSource),
      throwsA(_selectorCompileError('hash', 'meta')),
    );

    const unusedFunctionSource =
        'fn retired() { return(array(items)) }\nTop::\n /x/ -> Done { return([]) }\nDone::\n /x/\n'; // selector-rejection fixture
    expect(
      () => compileSpec(
        parseSpecWithStagedUserFunctionDefinitions(unusedFunctionSource),
      ),
      throwsA(_selectorCompileError('array', 'items')),
    );
  });

  test('generated boundaries reject caller-constructed selector AST', () {
    final invalid = _compiledWithSelectorPayload();
    final plan = buildGeneratedRulePlan(invalid);

    expect(
      () => emitDartSourceV1(invalid, 'selector-generated.spec'),
      throwsA(
        isA<GeneratedSourceException>()
            .having(
              (error) => error.stage,
              'stage',
              GeneratedSourceStage.emitSource,
            )
            .having(
              (error) => error.code,
              'code',
              GeneratedSourceCode.generatedSourceEmitFailed,
            )
            .having(
              (error) => error.detail,
              'detail',
              contains(_selectorDiagnosticParts('array', 'items')),
            ),
      ),
    );

    expect(
      () =>
          validateGeneratedRulePlanV1(invalid, plan, 'selector-generated.spec'),
      throwsA(
        isA<GeneratedSourceException>()
            .having(
              (error) => error.stage,
              'stage',
              GeneratedSourceStage.compileOrLoadGeneratedSource,
            )
            .having(
              (error) => error.code,
              'code',
              GeneratedSourceCode.generatedSourceCompileFailed,
            )
            .having(
              (error) => error.detail,
              'detail',
              contains(_selectorDiagnosticParts('array', 'items')),
            ),
      ),
    );
  });

  test('retained aggregate constructors and literals still execute', () {
    _expectNativeAndGenerated(
      _actionSource(r'''
items = ["x"]
left = "l"
right = "r"
key = "key"
value = "r"
return([array(), array("items"), array(copy(items)), array(left, right), hash(), hash("key", value), [items], { key : value }])
'''),
      [
        <Object?>[],
        ['items'],
        [
          ['x'],
        ],
        ['l', 'r'],
        <String, Object?>{},
        {'key': 'r'},
        [
          ['x'],
        ],
        {'key': 'r'},
      ],
    );
  });

  test('future fixture runs natively and through generated plan', () {
    expect(contract['contract_id'], 'linkedspec-uniform-binding-v1');
    final fixture = (contract['fixture']! as Map).cast<String, Object?>();
    _expectNativeAndGenerated(
      fixture['spec_source']! as String,
      fixture['expected'],
      input: fixture['input']! as String,
    );
  });

  test('absent push and array-end mutation return independent updates', () {
    _expectNativeAndGenerated(
      r'''
Top::
 /x/ -> Done {
   first_push = push(items, "a")
   second_push = push(items, "b")
   items += "c"
   count = items.push_back("d").count()
   return({ "items" : items, "first_push" : first_push, "second_push" : second_push, "count" : count })
 }
Done::
 /x/
''',
      {
        'items': ['a', 'b', 'c', 'd'],
        'first_push': ['a'],
        'second_push': ['a', 'b'],
        'count': 4,
      },
    );
  });

  test('all array-end methods return independent updated arrays', () {
    _expectNativeAndGenerated(
      r'''
Top::
 /x/ -> Done {
   items = ["a", "b", "c"]
   after_push_back = items.push_back("d")
   after_push_front = items.push_front("z")
   after_pop_back = items.pop_back()
   after_pop_front = items.pop_front()
   count = items.push_back("e").count()
   return({
     "items" : items,
     "after_push_back" : after_push_back,
     "after_push_front" : after_push_front,
     "after_pop_back" : after_pop_back,
     "after_pop_front" : after_pop_front,
     "count" : count
   })
 }
Done::
 /x/
''',
      {
        'items': ['a', 'b', 'c', 'e'],
        'after_push_back': ['a', 'b', 'c', 'd'],
        'after_push_front': ['z', 'a', 'b', 'c', 'd'],
        'after_pop_back': ['z', 'a', 'b', 'c'],
        'after_pop_front': ['a', 'b', 'c'],
        'count': 4,
      },
    );
  });

  test('registered rule keeps ambiguous push precedence', () {
    _expectNativeAndGenerated(
      r'''
Top::
 I { items = ["unchanged"]; outputs = [] }
 /x/ -> Done { pushed = push(items, outputs); return([items, outputs, pushed]) }
items::
 /x/ I { return("child-result") }
Done::
 /x/
''',
      [
        ['unchanged'],
        ['child-result'],
        ['child-result'],
      ],
    );
  });

  test('mutable and pure split remain distinct', () {
    _expectNativeAndGenerated(
      r'''
Top::
 /x/ -> Done {
   stored = split(parts, "a,b", ",")
   pure = split("c,d", ",")
   return({ "parts" : parts, "stored" : stored, "pure" : pure })
 }
Done::
 /x/
''',
      {
        'parts': ['a', 'b'],
        'stored': ['a', 'b'],
        'pure': ['c', 'd'],
      },
    );
  });

  test('hash-index mutation returns the updated harray', () {
    _expectNativeAndGenerated(
      r'''
Top::
 /x/ -> Done {
   updated = (meta["stage"] = "ok")
   snapshot = copy(meta)
   return({ "meta" : meta, "updated" : updated, "snapshot" : snapshot })
 }
Done::
 /x/
''',
      {
        'meta': {'stage': 'ok'},
        'updated': {'stage': 'ok'},
        'snapshot': {'stage': 'ok'},
      },
    );
  });

  test('unused values are dropped without changing bindings', () {
    _expectNativeAndGenerated(
      r'''
Top::
 /x/ -> Done {
   set(items, ["a"])
   copy(items)
   updated = push(items, "b")
   return({ "items" : items, "updated" : updated })
 }
Done::
 /x/
''',
      {
        'items': ['a', 'b'],
        'updated': ['a', 'b'],
      },
    );
  });

  test('bare collection statements rebind the typed array', () {
    _expectNativeAndGenerated(
      r'''
Top::
 /x/ -> Done {
   trimmed = trim_each(set(words, [" a ", "", "b"]))
   trim_each(words)
   filter_nonempty(words)
   return({ "trimmed" : trimmed, "words" : words })
 }
Done::
 /x/
''',
      {
        'trimmed': ['a', '', 'b'],
        'words': ['a', 'b'],
      },
    );
  });

  test('wrong-kind mutation reports the neutral fields', () {
    final compiled = _compile(r'''
Top::
 /x/ -> Done { items = "text"; push(items, "x"); return(items) }
Done::
 /x/
''');

    RuntimeInterpreterException? nativeError;
    try {
      LinkedSpecRuntimeEngine(compiled).execute('xx');
    } on RuntimeInterpreterException catch (error) {
      nativeError = error;
    }
    expect(nativeError, isNotNull);
    _expectWrongKindFields(nativeError!.diagnostic!.detail);

    GeneratedSourceException? generatedError;
    try {
      executeGeneratedParserV1(
        compiled,
        buildGeneratedRulePlan(compiled),
        'xx',
        'uniform-binding-test.spec',
      );
    } on GeneratedSourceException catch (error) {
      generatedError = error;
    }
    expect(generatedError, isNotNull);
    _expectWrongKindFields(generatedError!.detail!);
  });

  test('set returns the assigned value for receiver chaining', () {
    _expectNativeAndGenerated(
      r'''
Top::
 /x/ -> Done {
   first = set(items, ["b", "a"]).sorted().first()
   return([first, items])
 }
Done::
 /x/
''',
      [
        'a',
        ['b', 'a'],
      ],
    );
  });

  test('I assignment scopes recursive typed bindings per invocation', () {
    _expectNativeAndGenerated(
      r'''
top::
 -> sexpr { return(call(sexpr)) }

sexpr: /\(/ /\)/ I { items = [] }
 -> sexpr { push(items, call(sexpr)) }
 -> atom { push(items, call(atom)) }
 -> sexpr[1] { return(copy(items)) }

atom: /[A-Za-z0-9]+/ I.return(entry_text())
''',
      [
        'a',
        ['b'],
        'c',
      ],
      input: '(a(b)c)',
    );
  });

  test('bare empty rule accumulator reads as an array value', () {
    _expectNativeAndGenerated(
      r'''
Top::
 -> Child { return(copy(Child)) }
Child: /x/
''',
      <Object?>[],
      input: 'x',
    );
  });
}

CompiledSpec _compile(String source) => compileSpec(parseSpec(source));

String _actionSource(String action) {
  return 'Top::\n /x/ -> Done { $action }\nDone::\n /x/\n';
}

String _selectorDiagnostic(Map<String, Object?> item) {
  return _selectorDiagnosticParts(
    item['surface']! as String,
    item['identifier']! as String,
  );
}

String _selectorDiagnosticParts(String surface, String identifier) {
  return 'aggregate_selector_removed surface=$surface '
      'identifier=$identifier replacement=$identifier';
}

Matcher _selectorCompileError(String surface, String identifier) {
  return isA<CompiledSpecException>().having(
    (error) => error.message,
    'message',
    contains(_selectorDiagnosticParts(surface, identifier)),
  );
}

CompiledSpec _compiledWithSelectorPayload() {
  final compiled = _compile(_actionSource('return([])'));
  final original = compiled.rulesByLabel['Top']!;
  final actionAst = parseActionBlock(
    'array'
    '(items)',
  ); // selector-rejection fixture: array(items)
  final invalidPayload = CompiledActionPayload(
    role: 'lifecycle',
    line: 1,
    source: 'array selector rejection fixture',
    code: actionAst.source,
    actionAst: actionAst,
    contracts: resolveActionBlockContracts(
      actionAst,
      functionRegistry: compiled.functionRegistry,
    ),
  );
  final invalidRule = CompiledRule(
    label: original.label,
    header: original.header,
    modeMetadata: original.modeMetadata,
    regexPatterns: original.regexPatterns,
    dependencyRefs: original.dependencyRefs,
    actionEdges: original.actionEdges,
    blindEdges: original.blindEdges,
    lifecycleActionPayloads: [
      ...original.lifecycleActionPayloads,
      invalidPayload,
    ],
    plainActionPayloads: original.plainActionPayloads,
    bodyElements: original.bodyElements,
  );
  return CompiledSpec(
    definitionOrder: compiled.definitionOrder,
    compiledRuleOrder: compiled.compiledRuleOrder,
    rulesByLabel: {...compiled.rulesByLabel, 'Top': invalidRule},
    redefinedRuleLabels: compiled.redefinedRuleLabels,
    functionRegistry: compiled.functionRegistry,
    dependencyRegexState: compiled.dependencyRegexState,
  );
}

void _expectNativeAndGenerated(
  String source,
  Object? expected, {
  String input = 'xx',
}) {
  final compiled = _compile(source);
  expect(
    LinkedSpecRuntimeEngine(compiled).execute(input).value,
    expected,
    reason: 'native execution',
  );
  expect(
    executeGeneratedParserV1(
      compiled,
      buildGeneratedRulePlan(compiled),
      input,
      'uniform-binding-test.spec',
    ),
    expected,
    reason: 'generated execution',
  );
}

void _expectWrongKindFields(String detail) {
  expect(detail, contains('binding_kind_mismatch'));
  expect(detail, contains('identifier=items'));
  expect(detail, contains('expected_kind=array'));
  expect(detail, contains('actual_kind=scalar'));
}
