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
}

LinkedSpecRuntimeEngine _engine(String source) {
  return LinkedSpecRuntimeEngine(compileSpec(parseSpec(source)));
}
