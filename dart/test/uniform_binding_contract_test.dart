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
