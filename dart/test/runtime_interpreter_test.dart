import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('executes regex repetition with lifecycle collection', () {
    final engine = _engine(r'''
Top::
 I { set(array(words), []) }
 /hello[ \t]+(\w+)/
 LE { push(array(words), match_group(0)) }
 E { return(copy(array(words))) }
''');

    final result = engine.parse('hello one hello two');

    expect(result.value, ['one', 'two']);
    expect(result.output, [
      ['one', 'two'],
    ]);
    expect(result.lifecycleEvents.map((event) => event.lifecycle), [
      'I',
      'LE',
      'LE',
      'E',
    ]);
  });

  test(
    'dispatches action-edge children and fluent push accumulates returns',
    () {
      final engine = _engine(r'''
top::
 -> item .push
 E { return(copy(array(top))) }

item:
 /x/
 I { return(entry_text()) }
''');

      final result = engine.parse('xx');

      expect(result.value, ['x', 'x']);
      expect(result.output, [
        ['x', 'x'],
      ]);
    },
  );

  test('executes AND blind-call dispatch in sequence', () {
    final engine = _engine(r'''
Top::AND
 I { set(array(log), []) }
 => ChildA { push(array(log), retv) }
 => ChildB { push(array(log), retv) }
 E { return(copy(array(log))) }

ChildA:
 /a/
 E { return("A") }

ChildB:
 /[ \t]+b/
 E { return("B") }
''');

    final result = engine.parse('a b');

    expect(result.value, ['A', 'B']);
    expect(result.cursorCodeUnit, 3);
  });

  test('executes OR blind-call miss through LX return', () {
    final engine = _engine(r'''
Top::OR
 => ChildA
 => ChildB
 LX { return("or-miss") }
 E { return("unexpected") }

ChildA::
 I { return_undef() }
 /$^/

ChildB::
 I { return_undef() }
 /$^/
''');

    final result = engine.parse('c');

    expect(result.value, 'or-miss');
    expect(result.lifecycleEvents.map((event) => event.lifecycle), [
      'I',
      'I',
      'LX',
    ]);
  });

  test('honors bounded OR repetition over action-edge alternatives', () {
    final engine = _engine(r'''
Top::OR{2,3}
 I { set(array(out), []) }
 /a/ -> A { push(array(out), match_text()) }
 /b/ -> B { push(array(out), match_text()) }
 E { return(copy(array(out))) }

A:
 /a/

B:
 /b/
''');

    final result = engine.parse('abab');

    expect(result.value, ['a', 'b', 'a']);
    expect(result.cursorCodeUnit, 3);
  });

  test('cuts zero-progress repetition after one successful iteration', () {
    final engine = _engine(r'''
Top::OR+
 I { set(array(iters), []) }
 /x*/
 LE { push(array(iters), "i") }
 E { return(copy(array(iters))) }
''');

    final result = engine.parse('abc');

    expect(result.value, ['i']);
    expect(result.cursorCodeUnit, 0);
  });

  test('records repeated lifecycle order around loop exhaustion', () {
    final engine = _engine(r'''
Top::OR{1}
 I { push(array(events), "I") }
 LS { push(array(events), "LS") }
 /a/
 LE { push(array(events), "LE") }
 IT { push(array(events), "IT") }
 EX { push(array(events), "EX") }
 LX { push(array(events), "LX") }
 E { return(copy(array(events))) }
''');

    final result = engine.parse('a');

    expect(result.value, ['I', 'LS', 'LE', 'IT', 'EX', 'LX']);
    expect(result.lifecycleEvents.map((event) => event.lifecycle), [
      'I',
      'LS',
      'LE',
      'IT',
      'EX',
      'LX',
      'E',
    ]);
  });

  test('preserves scalar array hash stores and nested reads', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   set(value, "ok");
   set(array(items), ["a"]);
   items += value;
   set(hash(meta), { "k" : "v" });
   meta["n"] = 2;
   payload = { "children" : [ { "name" : "zero" }, { "name" : value } ] };
   return(hash(
     "items", copy(array(items)),
     "meta", copy(hash(meta)),
     "name", payload["children"][1]["name"]
   ))
 }
''');

    final result = engine.parse('x');

    expect(result.value, {
      'items': ['a', 'ok'],
      'meta': {'k': 'v', 'n': 2},
      'name': 'ok',
    });
  });

  test('reads variable-held shapes through wrappers and indexed vars', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   value = "ok";
   items = [value, "tail"];
   meta = { "key" : value };
   return(array(items[0], copy(items), hash(meta), meta["key"]))
 }
''');

    final result = engine.parse('x');

    expect(result.value, [
      'ok',
      ['ok', 'tail'],
      {'key': 'ok'},
      'ok',
    ]);
  });

  test('exposes named capture maps and source positions', () {
    final engine = _engine(r'''
Top::
 /(?<name>\w+)=(\d+)/
 E {
   return(hash(
     "entry_text", entry_text(),
     "match_text", match_text(),
     "entry_groups", entry_groups(),
     "match_group_1", match_group(1),
     "entry_named", entry_named(name),
     "match_named", match_named(name),
     "entry_has", entry_has(name),
     "match_has", match_has(name),
     "entry_map", entry_map(),
     "match_map", match_map(),
     "entry_len", entry_len(),
     "match_len", match_len(),
     "entry_start", entry_start_pos(),
     "entry_end", entry_end_pos(),
     "match_start", match_start_pos(),
     "match_end", match_end_pos()
   ))
 }
''');

    final result = engine.parse('xx key=42');

    expect(result.value, {
      'entry_text': 'key=42',
      'match_text': 'key=42',
      'entry_groups': ['key', '42'],
      'match_group_1': '42',
      'entry_named': 'key',
      'match_named': 'key',
      'entry_has': true,
      'match_has': true,
      'entry_map': {'name': 'key'},
      'match_map': {'name': 'key'},
      'entry_len': 6,
      'match_len': 6,
      'entry_start': 3,
      'entry_end': 9,
      'match_start': 3,
      'match_end': 9,
    });
  });
}

LinkedSpecRuntimeEngine _engine(String source) {
  return LinkedSpecRuntimeEngine(compileSpec(parseSpec(source)));
}
