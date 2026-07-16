import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('executes regex repetition with lifecycle collection', () {
    final engine = _engine(r'''
Top::
 I { set(words, []) }
 /hello[ \t]+(\w+)/
 LE { push(words, match_group(0)) }
 E { return(copy(words)) }
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
 E { return(copy(top)) }

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

  test('push child convention appends to current rule accumulator', () {
    final engine = _engine(r'''
Top::
 -> Item { push(Item) }
LX { return(copy(Top)) }

Item: /x/ I { return("item") }
''');

    final result = engine.parse('x');

    expect(result.value, ['item']);
    expect(result.output, [
      ['item'],
    ]);
  });

  test('skips leading public-parser blank lines before top rule', () {
    final engine = _engine(r'''
Top::
 I { cur = undef; items = [] }
 LX { return(array(cur[1], copy(items))) }
 -> object { cur = call(object) }
 -> version { push(items, call(version)) }

object: /(?i)\nobject:\s+(\S+)/ I.return(array("?object:", flat_array(entry_groups())))
version: /(?i)\nversion:\s+(\S+)/ I.return(array("?version:", flat_array(entry_groups())))
''');

    final result = engine.parse('\nobject: /proj/foo\nversion: 1\n');

    expect(result.value, [
      null,
      [
        ['?version:', '1'],
      ],
    ]);
  });

  test('keeps ordinary scalar-held indexed reads public', () {
    final engine = _engine(r'''
Top::
 /x/
 LE { payload = ["tag", "name"]; return(payload[1]) }
''');

    final result = engine.parse('x');

    expect(result.value, 'name');
  });

  test('push child numeric index appends child payload to current rule', () {
    final engine = _engine(r'''
Top::
 -> Item { push(Item, 1) }
 -> Comma
 -> Item { push(Item, 1) }
 LX { return(copy(Top)) }

Item: /"([^"]*)"/ I { return(array("item", entry_group(0))) }
Comma: /,/ I { return(entry_text()) }
''');

    final result = engine.parse('"a","b"');

    expect(result.value, ['a', 'b']);
    expect(result.output, [
      ['a', 'b'],
    ]);
  });

  test('executes self close edge that reuses the opener regex slot', () {
    final engine = _engine(r'''
Top::
 -> Quote .push
 LX.return(array("top", copy(Top)))

Quote: /"/
 -> Text .push
 -> Quote .return(array("quote", copy(Quote)))

Text: /x/
''');

    final result = engine.parse('""');

    expect(result.value, [
      'top',
      [
        ['quote', <Object?>[]],
      ],
    ]);
  });

  test('executes indexed self close edge after unrelated child choices', () {
    final engine = _engine(r'''
Top::
 -> Pair .push
 LX.return(array("top", copy(Top)))

Pair: /\[/ /\]/
 -> Other .push
 -> Another .push
 -> Pair[1] .return(array("pair", copy(Pair)))

Other: /x/
Another: /y/
''');

    final result = engine.parse('[]');

    expect(result.value, [
      'top',
      [
        ['pair', <Object?>[]],
      ],
    ]);
  });

  test('keeps aggregate resets rule local across recursive calls', () {
    final engine = _engine(r'''
top::
 -> sexpr { return(call(sexpr)) }

sexpr: /\(/ /\)/  I { set(items, []) }
 -> sexpr     { push(items, call(sexpr)) }
 -> atom      { push(items, call(atom)) }
 -> sexpr[1]  { return(copy(items)) }

atom: /[A-Za-z0-9]+/   I.return(entry_text())
''');

    final result = engine.parse('(a(b)c)');

    expect(result.value, [
      'a',
      ['b'],
      'c',
    ]);
  });

  test('push and append mutate scalar-held array values', () {
    final engine = _engine(r'''
Top::
 I { items = [] }
 /x/
 LE { push(items, "head"); items += "tail" }
 LX { return(copy(items)) }
''');

    final result = engine.parse('x');

    expect(result.value, ['head', 'tail']);
  });

  test('preserves recursive top-rule LX sequence values', () {
    final engine = _engine(r'''
sexpr:: /\(/ /\)/  I { set(items, []) }
 -> sexpr     { push(items, call(sexpr)) }
 -> atom      { push(items, call(atom)) }
 -> sexpr[1]  { return(copy(items)) }
LX { return(copy(items)) }

atom: /[A-Za-z0-9]+/   I.return(entry_text())
''');

    final nested = engine.parse('(a(b)c)');
    expect(nested.value, [
      [
        'a',
        ['b'],
        'c',
      ],
    ]);

    final sequence = engine.parse('(a) (b)');
    expect(sequence.value, [
      ['a'],
      ['b'],
    ]);
  });

  test('keeps undeclared child array mutations caller visible', () {
    final engine = _engine(r'''
Top::
 -> Child { call(Child); return(copy(items)) }

Child: /x/ I { push(items, "child") }
''');

    final result = engine.parse('x');

    expect(result.value, ['child']);
  });

  test('executes AND blind-call dispatch in sequence', () {
    final engine = _engine(r'''
Top::AND
 I { set(log, []) }
 => ChildA { push(log, retv) }
 => ChildB { push(log, retv) }
 E { return(copy(log)) }

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

  test('surfaces implicit AND blind-call child returns in order', () {
    final engine = _engine(r'''
Top::AND
 => ChildA
 => ChildB

ChildA:
 /a/
 E { return("A") }

ChildB:
 /[ \t]+b/
 E { return("B") }
''');

    expect(engine.parse('a b').value, ['A', 'B']);
  });

  test('keeps named marks rule-local', () {
    final engine = _engine(r'''
Top::AND
 => First
 => Second

First:AND
 /A/
 /x/
 -> First[0] { mark_here(shared) }
 -> First[1] { return(mark_pos(shared)) }

Second:AND
 /B/
 /C/
 -> Second[1] { return(mark_exists(shared)) }
''');

    expect(engine.parse('AxBC').value, [1, 0]);
  });

  test('projects multibyte mark positions and lengths in characters', () {
    final engine = _engine(r'''
Top::AND
 => Value

Value:AND
 /A/
 /éB/
 /C/
 -> Value[0] { mark_here(origin) }
 -> Value[2] { return(hash("len", capture_len_from(origin), "pos", mark_pos(origin), "text", capture_from(origin))) }
''');

    expect(engine.parse('AéBC').value, [
      {'len': 2, 'pos': 1, 'text': 'éB'},
    ]);
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
 I { set(out, []) }
 /a/ -> A { push(out, match_text()) }
 /b/ -> B { push(out, match_text()) }
 E { return(copy(out)) }

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
 I { set(iters, []) }
 /x*/
 LE { push(iters, "i") }
 E { return(copy(iters)) }
''');

    final result = engine.parse('abc');

    expect(result.value, ['i']);
    expect(result.cursorCodeUnit, 0);
  });

  test('records repeated lifecycle order around loop exhaustion', () {
    final engine = _engine(r'''
Top::OR{1}
 I { push(events, "I") }
 LS { push(events, "LS") }
 /a/
 LE { push(events, "LE") }
 IT { push(events, "IT") }
 EX { push(events, "EX") }
 LX { push(events, "LX") }
 E { return(copy(events)) }
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

  test('rewinds cursor through explicit match and entry helpers', () {
    final entryRewindEngine = _engine(r'''
Top::AND
 I { set(log, []) }
 /ab/ -> Top[0] { push(log, hash("slot", 0, "cursor", cursor_pos(), "entry_start", entry_start_pos(), "match_start", match_start_pos())) }
 /cd/ -> Top[1] {
   before = cursor_pos();
   rewind_entry_start();
   push(log, hash("slot", 1, "before", before, "after", cursor_pos(), "entry_start", entry_start_pos(), "match_start", match_start_pos(), "rest", cursor_rest()))
 }
 E { return(copy(log)) }
''');
    final matchRewindEngine = _engine(r'''
Top::AND
 I { set(log, []) }
 /ab/ -> Top[0] { push(log, hash("slot", 0, "cursor", cursor_pos(), "entry_start", entry_start_pos(), "match_start", match_start_pos())) }
 /cd/ -> Top[1] {
   before = cursor_pos();
   rewind_match_start();
   push(log, hash("slot", 1, "before", before, "after", cursor_pos(), "entry_start", entry_start_pos(), "match_start", match_start_pos(), "rest", cursor_rest()))
 }
 E { return(copy(log)) }
''');

    final entryRewindResult = entryRewindEngine.parse('abcd');
    final matchRewindResult = matchRewindEngine.parse('abcd');

    expect(entryRewindResult.value, [
      {'slot': 0, 'cursor': 2, 'entry_start': 0, 'match_start': 0},
      {
        'slot': 1,
        'before': 4,
        'after': 0,
        'entry_start': 0,
        'match_start': 2,
        'rest': 'abcd',
      },
    ]);
    expect(entryRewindResult.cursorCodeUnit, 0);

    expect(matchRewindResult.value, [
      {'slot': 0, 'cursor': 2, 'entry_start': 0, 'match_start': 0},
      {
        'slot': 1,
        'before': 4,
        'after': 2,
        'entry_start': 0,
        'match_start': 2,
        'rest': 'cd',
      },
    ]);
    expect(matchRewindResult.cursorCodeUnit, 2);
  });

  test('saves and restores cursor explicitly through stack helpers', () {
    final engine = _engine(r'''
Top::AND
 /ab/ -> Top[0] { save_cursor() }
 /cd/
 E { restore_cursor(); return(hash("cursor", cursor_pos(), "rest", cursor_rest())) }
''', parseMode: LinkedSpecParseMode.consume);

    final result = engine.parse('abcd');

    expect(result.value, {'cursor': 2, 'rest': 'cd'});
    expect(result.cursorCodeUnit, 2);
  });

  test('captures until named boundary without consuming the boundary', () {
    final engine = _engine(r'''
Top::
 I { set(out, []) }
 -> Annotation.push(out)
 LX { return(copy(out)) }

Annotation: /@(\w+):[ \t]*/
 I { body = capture_until_boundary(Annotation, Boundary); return(hash("kind", "annotation", "name", entry_group(0), "body", trim(body), "cursor", cursor_pos(), "rest", cursor_rest())) }

Boundary: /END/
''');

    final result = engine.parse('@a: first @b: second END');

    expect(result.value, [
      {
        'kind': 'annotation',
        'name': 'a',
        'body': 'first',
        'cursor': 10,
        'rest': '@b: second END',
      },
      {
        'kind': 'annotation',
        'name': 'b',
        'body': 'second',
        'cursor': 21,
        'rest': 'END',
      },
    ]);
    expect(result.cursorCodeUnit, 21);
  });

  test('executes capture-slice logical and diagnostic helper surfaces', () {
    final engine = _engine(r'''
Body::AND /BEGIN/ /END/
 -> Body[0] { start_capture_slice() }
 -> Body[1] {
   print("closing (", match_text(), "\n");
   say("ignored");
   return(hash(
     "body", trim(capture_slice()),
     "body_len", capture_slice_len(),
     "until_cursor", capture_slice_until_cursor(),
     "start_pos", capture_slice_pos(),
     "start_line", capture_slice_line(),
     "start_col", capture_slice_col(),
     "logic", and(or(false, true), not(false))
   ))
 }
''');

    final result = engine.parse('BEGIN body END');

    expect(result.value, {
      'body': 'body',
      'body_len': 6,
      'until_cursor': ' body END',
      'start_pos': 5,
      'start_line': 1,
      'start_col': 6,
      'logic': true,
    });
  });

  test('terminates on exit_now helper', () {
    final engine = _engine(r'''
Top::
 /x/
 E { print("fatal"); exit_now(7) }
''');

    expect(
      () => engine.parse('x'),
      throwsA(isA<RuntimeExitNow>().having((exit) => exit.status, 'status', 7)),
    );
  });

  test('applies consume matching from a rewound cursor', () {
    final engine = _engine(r'''
Top::AND
 /ab/ -> Top[0] { rewind_match_start() }
 /ab/
 E { return(hash("cursor", cursor_pos(), "rest", cursor_rest())) }
''', parseMode: LinkedSpecParseMode.consume);

    final result = engine.parse('ab');

    expect(result.value, {'cursor': 2, 'rest': ''});
    expect(result.cursorCodeUnit, 2);
  });

  test('exposes char-based cursor and whole-input helper values', () {
    final engine = _engine(r'''
Top::AND
 /é/
 /x/
 E {
   return(hash(
     "cursor", cursor_pos(),
     "cursor_line", cursor_line(),
     "cursor_col", cursor_col(),
     "rest", cursor_rest(),
     "rest_len", cursor_rest_len(),
     "input", input_text(),
     "input_len", input_len(),
     "slice", input_slice(1, 1),
     "end_pos", input_end_pos(),
     "end_line", input_end_line(),
     "end_col", input_end_col()
   ))
 }
''', parseMode: LinkedSpecParseMode.consume);

    final result = engine.parse('éx');

    expect(result.value, {
      'cursor': 2,
      'cursor_line': 1,
      'cursor_col': 3,
      'rest': '',
      'rest_len': 0,
      'input': 'éx',
      'input_len': 2,
      'slice': 'x',
      'end_pos': 2,
      'end_line': 1,
      'end_col': 3,
    });
    expect(result.cursorCodeUnit, 2);
  });

  test('exposes entry and match line helper values', () {
    final engine = _engine(r'''
Top::AND
 /a\n/
 /b/
 E {
   return(hash(
     "entry_line", entry_line(),
     "entry_col", entry_col(),
     "match_line", match_line(),
     "match_col", match_col()
   ))
 }
''', parseMode: LinkedSpecParseMode.consume);

    final result = engine.parse('a\nb');

    expect(result.value, {
      'entry_line': 1,
      'entry_col': 1,
      'match_line': 2,
      'match_col': 1,
    });
  });

  test('preserves scalar array hash stores and nested reads', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   set(value, "ok");
   set(items, ["a"]);
   items += value;
   set(meta, { "k" : "v" });
   meta["n"] = 2;
   payload = { "children" : [ { "name" : "zero" }, { "name" : value } ] };
   return(hash(
     "items", copy(items),
     "meta", copy(meta),
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
   return(array(
     items[0],
     copy(items),
     copy(items),
     meta,
     copy(meta),
     meta["key"]
   ))
 }
''');

    final result = engine.parse('x');

    expect(result.value, [
      'ok',
      ['ok', 'tail'],
      ['ok', 'tail'],
      {'key': 'ok'},
      {'key': 'ok'},
      'ok',
    ]);
  });

  test(
    'keeps scalar-held assignment values visible to later call arguments',
    () {
      final engine = _engine(r'''
Top::
 /x/
 E {
   set(value, "ok");
   set(key, "stage");
   return(array(
     items = [value],
     copy(items),
     set(meta, { key : value }),
     copy(meta)
   ))
 }
''');

      final result = engine.parse('x');

      expect(result.value, [
        ['ok'],
        ['ok'],
        {'stage': 'ok'},
        {'stage': 'ok'},
      ]);
    },
  );

  test('executes nested value-path assignment without autovivification', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   payload = { "items" : [{ "name" : "old" }] };
   root_array = [{ "name" : "old" }];
   return(array(
     (payload["items"][0]["name"] = "new").count_keys(),
     payload["items"][1] = "tail",
     payload,
     payload["items"][3] = "gap",
     payload,
     payload["missing"][0] = "bad",
     payload,
     payload["items"][0][0] = "bad",
     payload,
     root_array[0]["name"] = "changed",
     root_array[1] = { "name" : "tail" },
     root_array["bad"] = { "name" : "bad" },
     root_array
   ))
 }
''');

    final result = engine.parse('x');

    final updatedPayload = {
      'items': [
        {'name': 'new'},
        'tail',
      ],
    };
    expect(result.value, [
      1,
      updatedPayload,
      updatedPayload,
      null,
      updatedPayload,
      null,
      updatedPayload,
      null,
      updatedPayload,
      [
        {'name': 'changed'},
      ],
      [
        {'name': 'changed'},
        {'name': 'tail'},
      ],
      null,
      [
        {'name': 'changed'},
        {'name': 'tail'},
      ],
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
      'entry_has': 1,
      'match_has': 1,
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

  test('executes string scalar helpers and receiver chains', () {
    final engine = _engine(r'''
Top::
 /(.+)/
 E {
   raw = entry_group(0);
   set(tmp, ["x"]);
   missing = tmp[5];
   return(hash(
     "trim", trim(raw),
     "chain", raw.trim().lowercase().replace_substr("-", "_").rm_suffix("_end"),
     "substr", substr(trim(raw), 1, 3),
     "contains", contains_substr(raw, "-B-"),
     "starts", starts_with(trim(raw), "A"),
     "ends", ends_with(trim(raw), "END"),
     "matches", matches(trim(raw), /^A/),
     "split", raw.trim().split("-"),
     "coalesce", coalesce(missing, "fallback"),
     "coalesce_nonempty", coalesce_nonempty("", "filled"),
     "defined", is_defined(""),
     "undefined", is_undefined(missing),
     "empty", is_empty(""),
     "nonempty", is_nonempty("x"),
     "empty_array", is_empty(array()),
     "nonempty_hash", is_nonempty(hash("k", "v")),
     "str_eq", str_eq("a", "a"),
     "str_lt", str_lt("a", "b")
   ))
 }
''');

    final result = engine.parse(' A-B-END ');

    expect(result.value, {
      'trim': 'A-B-END',
      'chain': 'a_b',
      'substr': '-B-',
      'contains': 1,
      'starts': 1,
      'ends': 1,
      'matches': true,
      'split': ['A', 'B', 'END'],
      'coalesce': 'fallback',
      'coalesce_nonempty': 'filled',
      'defined': true,
      'undefined': true,
      'empty': true,
      'nonempty': true,
      'empty_array': true,
      'nonempty_hash': true,
      'str_eq': true,
      'str_lt': true,
    });
  });

  test('executes shipped regex dialect forms through helper regex values', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   value = "0XFA";
   case_insensitive = matches(value, "(?i)0x[0-9a-f]+");
   posix_possessive = matches("NAME", "[[:alpha:]]++");
   return(hash(
     "case_insensitive", case_insensitive,
     "posix_possessive", posix_possessive
   ))
 }
''');

    final result = engine.parse('x');

    expect(result.value, {'case_insensitive': true, 'posix_possessive': true});
  });

  test('executes numeric helpers aliases symbols and receivers', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   scores += 1;
   scores += 5;
   scores += 3;
   scores += 5;
   return(hash(
     "symbol_add", +(2, *(3, 4)),
     "div", num_div(7, 2),
     "mod", 17.mod(5),
     "clamp", num_clamp(42, 0, 10),
     "gt", gt(10, 2),
     "le", <=(2, 2),
     "round", 3.5.round(),
     "range", num_range(array(3, 9, 1, 7)),
     "avg", avg(array(2, 4, 6)),
     "median", median(array(5, 1, 4, 2)),
     "minimum", min(array(8, 3, 5, 1)),
     "bare_min", min(scores),
     "bare_max", max(scores),
     "bad_div", num_div(5, 0),
     "bad_number", num_add("x", 1)
   ))
 }
''');

    final result = engine.parse('x');

    expect(result.value, {
      'symbol_add': 14,
      'div': 3.5,
      'mod': 2,
      'clamp': 10,
      'gt': 1,
      'le': 1,
      'round': 4,
      'range': 8,
      'avg': 4,
      'median': 3,
      'minimum': 1,
      'bare_min': 1,
      'bare_max': 5,
      'bad_div': null,
      'bad_number': null,
    });
  });

  test('matches the neutral scalar numeric contract exactly', () {
    final contract =
        jsonDecode(
              File(
                '../capability_conformance/scalar_numeric_contract.json',
              ).readAsStringSync(),
            )
            as Map<String, Object?>;

    expect(contract['format'], 1);
    expect(contract['contract_id'], 'linkedspec-scalar-numeric-v1');
    expect((contract['cases']! as List<Object?>), hasLength(55));

    final result = _engine(contract['spec_source']! as String).parse('xx');
    expect(result.value, contract['expected']);
  });

  test(
    'executes array helpers and receiver chains without mutating snapshots',
    () {
      final engine = _engine(r'''
Top::
 /x/
 E {
   items += "b";
   items += "a";
   items += "c";
   items += "a";
   phrases += "aa-b";
   phrases += "cc-aa";
   set(public, [" x ", "", "Y"]);
   return(hash(
     "sorted_drop_first", items.sorted().drop_front(2).first(),
     "reverse_take_last", items.reversed().take(2).last(),
     "contains", items.sorted().contains("c"),
     "index", items.sorted().index_of("c"),
     "drop_join", items.drop_back().join_values("|"),
     "uniq_join", items.uniq().join_values(","),
     "filter_count", items.filter_match(/^a$/).count(),
     "split_filter_count", phrases.split_each("-").filter_match(/^aa$/).count(),
     "transform_join", public.trim_each().filter_nonempty().lowercase_each().join_values("|"),
     "take_last", items.take_last(2),
     "slice", items.sorted().slice(1, 2),
     "flat", flat_array(array("p", "q"), "r"),
     "array_flat_splice", array("tag", flat_array(array("p", "q")), "tail"),
     "array_copy_nested", array("tag", copy(array("p", "q"))),
     "concat", concat_arrays(array("x"), array("y", "z")),
     "sum", array(2, 4, 6).sum(),
     "avg", array(2, 4, 6).avg(),
     "source", copy(items),
     "empty_missing", missing.sorted().is_empty()
   ))
 }
''');

      final result = engine.parse('x');

      expect(result.value, {
        'sorted_drop_first': 'b',
        'reverse_take_last': 'c',
        'contains': 1,
        'index': 3,
        'drop_join': 'b|a|c',
        'uniq_join': 'b,a,c',
        'filter_count': 2,
        'split_filter_count': 2,
        'transform_join': 'x|y',
        'take_last': ['c', 'a'],
        'slice': ['a', 'b'],
        'flat': ['p', 'q', 'r'],
        'array_flat_splice': ['tag', 'p', 'q', 'tail'],
        'array_copy_nested': [
          'tag',
          ['p', 'q'],
        ],
        'concat': ['x', 'y', 'z'],
        'sum': 12,
        'avg': 4,
        'source': ['b', 'a', 'c', 'a'],
        'empty_missing': true,
      });
    },
  );

  test('executes array split bridges and value-returning end mutations', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   raw = " left , right,,third ";
   split(parts, raw, /\s*,\s*/);
   items.push_back("a");
   items.push_back("b");
   items.push_front("z");
   items.pop_back();
   items.pop_front();
   items.push_back("c");
   return(hash(
     "parts", copy(parts),
     "receiver_split", "a, b".split(/\s*,\s*/),
     "items", copy(items),
     "value_push", items.push_back("bad"),
     "after_value_push", copy(items),
     "tagged", split_tagged_records("a,b", /,/, "?tag:", "field")
   ))
 }
''');

    final result = engine.parse('x');

    expect(result.value, {
      'parts': [' left', 'right', '', 'third '],
      'receiver_split': ['a', 'b'],
      'items': ['a', 'c'],
      'value_push': ['a', 'c', 'bad'],
      'after_value_push': ['a', 'c', 'bad'],
      'tagged': [
        ['?tag:', 'a', 'field'],
        ['?tag:', 'b', 'field'],
      ],
    });
  });

  test('executes statement-form regex substitution and split mutation', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   value = "\"bar,baz\""
   numbered = "a12b"
   parts = []
   substr(value, "\"|\\s", "", go)
   regex_subst(numbered, /(\d+)/, "[$1]", g)
   split(parts, value, /,/)
   return(hash("value", value, "numbered", numbered, "parts", copy(parts)))
 }
''');

    final result = engine.parse('x');

    expect(result.value, {
      'value': 'bar,baz',
      'numbered': 'a[12]b',
      'parts': ['bar', 'baz'],
    });
  });

  test('executes hash helpers receiver chains and mutation boundaries', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   set_key(meta, "b", 2)
   set_key(meta, "a", 1)
   set_key(meta, "drop", 0)
   set_key(meta, "stmt_hash", 4)
   set_key(overlay, "a", 10)
   set_key(overlay, "c", 3)
   value_set = set_key(meta, "value_only", 9)
   receiver_set = meta.set_key("receiver_only", 5)
   return(hash(
     "keys", meta.sorted_keys().join_values(","),
     "values", meta.sorted_values().join_values("|"),
     "count", meta.count_keys(),
     "has_a", meta.has_key("a"),
     "drop_pick", meta.drop_keys("drop").pick_keys("a", "stmt_hash").sorted_values(),
     "rename", meta.rename_key("a", "aa").drop_keys("drop").set_key("z", 7).sorted_keys().join_values(","),
     "merged", merge_hash(copy(meta), overlay).sorted_values(),
     "bare_first_merge", merge_hash(meta, overlay).sorted_keys(),
     "value_set_has", value_set.has_key("value_only"),
     "receiver_set_has", receiver_set.has_key("receiver_only"),
     "after_value_set", copy(meta).has_key("value_only"),
     "after_receiver_set", copy(meta).has_key("receiver_only"),
     "index_value", meta["expr"] = "E",
     "after_index_value", copy(meta).has_key("expr"),
     "flat_splice", hash("z", 0, flat(meta)).sorted_keys().join_values(","),
     "flat_hash_splice", hash("z", 0, meta.flat_hash()).sorted_keys().join_values(","),
     "map_field", hash("nested", copy(meta)).pick_keys("nested")
   ))
 }
''');

    final result = engine.parse('x');

    expect(result.value, {
      'keys': 'a,b,drop,stmt_hash',
      'values': '1|2|0|4',
      'count': 4,
      'has_a': 1,
      'drop_pick': [1, 4],
      'rename': 'aa,b,stmt_hash,z',
      'merged': [10, 2, 3, 0, 4],
      'bare_first_merge': ['a', 'b', 'c', 'drop', 'stmt_hash'],
      'value_set_has': 1,
      'receiver_set_has': 1,
      'after_value_set': 0,
      'after_receiver_set': 0,
      'index_value': {'b': 2, 'a': 1, 'drop': 0, 'stmt_hash': 4, 'expr': 'E'},
      'after_index_value': 1,
      'flat_splice': 'a,b,drop,expr,stmt_hash,z',
      'flat_hash_splice': 'a,b,drop,expr,stmt_hash,z',
      'map_field': {
        'nested': {'b': 2, 'a': 1, 'drop': 0, 'stmt_hash': 4, 'expr': 'E'},
      },
    });
  });

  test('executes value blocks controls and trailing with blocks', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   counted = { count = 0; while(num_lt(count, 2)) { count = num_add(count, 1) }; count };
   local = { while(true) { return("local") }; "bad" };
   branch = { if(false) { return("bad") } elseif(true) { return("yes") } else { return("no") } };
   kind = "b";
   switched = { switch(kind) { case("a") { return("bad") } case("b") { return("hit") } default { return("miss") } } };
   inline = if(false, "bad", else("fallback"));
   inline_plain = if(false, "bad", "fallback");
   with_result = with("inner") { value = cat(value, "!"); return(value) };
   receiver = " a-b ".trim().with() { return(value.split("-")) }.count();
   return(array(counted, local, branch, switched, inline, inline_plain, with_result, receiver, value))
 }
''');

    final result = engine.parse('x');

    expect(result.value, [
      2,
      'local',
      'yes',
      'hit',
      'fallback',
      'fallback',
      'inner!',
      2,
      null,
    ]);
  });

  test('keeps attached while returns rule-level outside value blocks', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   while(true) { return("done") };
   return("bad")
 }
''');

    final result = engine.parse('x');

    expect(result.value, 'done');
  });

  test('treats empty aggregate returns as successful matches', () {
    final hashEngine = _engine(r'''
Top::
 /x/ -> Done { m = {}; return(copy(m)) }

Done::
 /[a-z]+/
''');
    final arrayEngine = _engine(r'''
Top::
 /x/ -> Done { items = []; return(copy(items)) }

Done::
 /[a-z]+/
''');

    final hashResult = hashEngine.parse('xhello');
    final arrayResult = arrayEngine.parse('xhello');

    expect(hashResult.matched, isTrue);
    expect(hashResult.value, <String, Object?>{});
    expect(hashResult.cursorCodeUnit, 1);
    expect(arrayResult.matched, isTrue);
    expect(arrayResult.value, <Object?>[]);
    expect(arrayResult.cursorCodeUnit, 1);
  });

  test('executes marker-form if else endif statement chains', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   flag = true;
   items += false;
   push(items, true);
   meta["enabled"] = true;
   if(false);
   return("bad");
   else();
   return(array(flag, copy(items), copy(meta)));
   endif()
 }
''');

    final result = engine.parse('x');

    expect(result.value, [
      true,
      [false, true],
      {'enabled': true},
    ]);
  });

  test('executes hash and array tree traversal receiver blocks', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   meta = { "b" : { "y" : "B" }, "a" : "A", "arr" : ["u", "v"] };
   items = ["a", ["b", "c"], { "h" : "H" }];
   nonhash = "x".map_leaves() { seen += "bad" };
   nonarray = "x".walk_leaves() { seen += "bad" };
   return(array(
     meta.map_leaves() { return(cat(join_values("/", path), "=", coalesce_nonempty(join_values("", value), value))) },
     meta.reduce_leaves("") { return(cat(acc, key)) },
     meta.walk_leaves() { seen += join_values("/", path); return(value) }.count_keys(),
     items.map_leaves() { return(cat(join_values("/", path), "=", if(count(value.sorted_keys()), cat("{", value.sorted_keys().join_values(","), "}"), else(value)))) },
     items.reduce_leaves("") { return(cat(acc, join_values("/", path), ":", if(count(value.sorted_keys()), cat("{", value.sorted_keys().join_values(","), "}"), else(value)), ";")) },
     items.walk_leaves() { seen += join_values("/", path); return(value) }.count(),
     seen,
     is_undefined(nonhash),
     is_undefined(nonarray)
   ))
 }
''');

    final result = engine.parse('x');

    expect(result.value, [
      {
        'a': 'a=A',
        'arr': 'arr=uv',
        'b': {'y': 'b/y=B'},
      },
      'aarry',
      3,
      [
        '0=a',
        ['1/0=b', '1/1=c'],
        '2={h}',
      ],
      '0:a;1/0:b;1/1:c;2:{h};',
      3,
      ['a', 'arr', 'b/y', '0', '1/0', '1/1', '2'],
      true,
      true,
    ]);
  });

  test('restores scoped tree callback bindings', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   meta = { "a" : "A" };
   items = ["B"];
   value = "outer_value";
   key = "outer_key";
   index = "outer_index";
   path = "outer_path";
   depth = "outer_depth";
   acc = "outer_acc";
   mapped_hash = meta.map_leaves() { value = cat(value, "!"); key = "inner"; path = ["inner"]; depth = 99; return(value) };
   reduced_hash = meta.reduce_leaves("seed") { acc = cat(acc, key); return(acc) };
   mapped_array = items.map_leaves() { value = cat(value, "?"); index = 9; path = ["inner"]; depth = 99; return(cat(value, index)) };
   reduced_array = items.reduce_leaves("seed") { acc = cat(acc, index); return(acc) };
   null_reduced = meta.reduce_leaves(if(false, "unused")) { before = is_undefined(acc); acc = "inner_acc"; return(before) };
   return(array(mapped_hash["a"], reduced_hash, mapped_array.first(), reduced_array, null_reduced, value, key, index, path, depth, acc))
 }
''');

    final result = engine.parse('x');

    expect(result.value, [
      'A!',
      'seeda',
      'B?9',
      'seed0',
      true,
      'outer_value',
      'outer_key',
      'outer_index',
      'outer_path',
      'outer_depth',
      'outer_acc',
    ]);
  });

  test('executes registered user functions in runtime value paths', () {
    final engine = _engineWithFunctions(
      r'''
Top::
 /x/
 E {
   set(value, "caller");
   set(items, ["caller"]);
   discard("ignored");
   normalize(" A-B ").lowercase();
   eager = echo(set(value, "arg"));
   shaped = use_shapes(array("b", "a"), hash("key", "Value"));
   return(hash(
     "value", value,
     "eager", eager,
     "normal", normalize(" A-B ").lowercase().replace_substr("-", "_"),
     "shaped", shaped,
     "items", copy(items)
   ))
 }
''',
      [
        _function('normalize', const ['value'], 'trim(value)'),
        _function('echo', const ['value'], 'return(value)'),
        _function('discard', const [
          'value',
        ], 'set(value, "inner"); return(value)'),
        _function(
          'use_shapes',
          const ['items', 'meta'],
          [
            'set(items, items.sorted())',
            'set_key(meta, "extra", "ok")',
            'return(hash("first", items.first(), "meta", copy(meta)))',
          ].join('; '),
        ),
      ],
    );

    final result = engine.parse('x');

    expect(result.value, {
      'value': 'arg',
      'eager': 'arg',
      'normal': 'a_b',
      'shaped': {
        'first': 'a',
        'meta': {'key': 'Value', 'extra': 'ok'},
      },
      'items': ['caller'],
    });
  });

  test('diagnoses direct and mutual user function recursion', () {
    final direct = _engineWithFunctions(
      r'''
Top::
 /x/
 E { return(loop("x")) }
''',
      [
        _function('loop', const ['value'], 'return(loop(value))'),
      ],
    );

    expect(
      () => direct.parse('x'),
      throwsA(
        isA<RuntimeInterpreterException>()
            .having(
              (error) => error.message,
              'message',
              contains(
                'user function recursion is not supported: loop -> loop',
              ),
            )
            .having(
              (error) => error.diagnostic?.stage,
              'diagnostic stage',
              'user_function_call',
            )
            .having(
              (error) => error.diagnostic?.handlerSourceLabel,
              'handler source',
              'dart_runtime:function:loop',
            ),
      ),
    );

    final mutual = _engineWithFunctions(
      r'''
Top::
 /x/
 E { return(alpha("x")) }
''',
      [
        _function('alpha', const ['value'], 'return(beta(value))'),
        _function('beta', const ['value'], 'return(alpha(value))'),
      ],
    );

    expect(
      () => mutual.parse('x'),
      throwsA(
        isA<RuntimeInterpreterException>().having(
          (error) => error.message,
          'message',
          contains(
            'user function recursion is not supported: alpha -> beta -> alpha',
          ),
        ),
      ),
    );
  });

  test('diagnoses registered user function arity mismatches at runtime', () {
    final engine = _engineWithFunctions(
      r'''
Top::
 /x/
 E { return(echo()) }
''',
      [
        _function('echo', const ['value'], 'return(value)'),
      ],
    );

    expect(
      () => engine.parse('x'),
      throwsA(
        isA<RuntimeInterpreterException>().having(
          (error) => error.message,
          'message',
          contains("user function 'echo' expects 1 argument(s), got 0"),
        ),
      ),
    );
  });

  test('attaches structured diagnostics to missing runtime rule errors', () {
    final engine = _engine(
      r'''
Top::
 /x/
 E { return(match_text()) }
''',
      specName: 'diagnostic.spec',
      specPath: 'specs/diagnostic.spec',
    );

    try {
      engine.parse('x', topRule: 'Missing');
      fail('missing runtime rule should throw');
    } on RuntimeInterpreterException catch (error) {
      expect(error.message, "rule 'Missing' is not compiled");
      final diagnostic = error.diagnostic;
      expect(diagnostic, isNotNull);
      expect(diagnostic!.toJson(), {
        'type': 'runtime_parser',
        'stage': 'rule_lookup',
        'owner_stage': 'dart_runtime',
        'summary': 'Dart runtime rule lookup failed',
        'detail': "rule 'Missing' is not compiled",
        'spec_name': 'diagnostic.spec',
        'spec_path': 'specs/diagnostic.spec',
        'top_rule': 'Missing',
        'rule_label': 'Missing',
        'handler_source_label': 'dart_runtime:rule:Missing',
      });
      expect(error.toJson()['diagnostic'], diagnostic.toJson());
    }
  });

  test('reports entry and local match line boundary helpers', () {
    final engine = _engine(r'''
Top::
 /b\nc/
 E {
   return(hash(
     "entry_start_line", entry_start_line(),
     "entry_start_col", entry_start_col(),
     "entry_end_line", entry_end_line(),
     "entry_end_col", entry_end_col(),
     "match_start_line", match_start_line(),
     "match_start_col", match_start_col(),
     "match_end_line", match_end_line(),
     "match_end_col", match_end_col(),
     "next", next()
   ))
 }
''');

    final result = engine.parse('a\nb\nc');

    expect(result.value, {
      'entry_start_line': 2,
      'entry_start_col': 1,
      'entry_end_line': 3,
      'entry_end_col': 2,
      'match_start_line': 2,
      'match_start_col': 1,
      'match_end_line': 3,
      'match_end_col': 2,
      'next': null,
    });
  });

  test('statement next skips to the next rule iteration', () {
    final engine = _engine(r'''
Top::
 /skip/ { next() }
 /keep/
 E { return(match_text()) }
''');

    final result = engine.parse('skipkeep');

    expect(result.value, 'keep');
  });

  test('wraps action runtime failures with structured diagnostics', () {
    final engine = _engine(r'''
Top::
 -> Child

Child:
 /x/
 E { unknown_helper() }
''');

    try {
      engine.parse('x');
      fail('unsupported runtime helper should throw');
    } on RuntimeInterpreterException catch (error) {
      expect(
        error.message,
        "unsupported runtime helper 'unknown_helper' in rule Child",
      );
      final diagnostic = error.diagnostic;
      expect(diagnostic, isNotNull);
      expect(diagnostic!.toJson(), containsPair('stage', 'runtime_execution'));
      expect(
        diagnostic.toJson(),
        containsPair('summary', 'Dart runtime interpreter failed'),
      );
      expect(diagnostic.toJson(), containsPair('top_rule', 'Top'));
      expect(diagnostic.toJson(), containsPair('rule_label', 'Child'));
      expect(
        diagnostic.toJson(),
        containsPair('handler_source_label', 'dart_runtime:rule:Child'),
      );
    }
  });

  test('matches the governed exhaustive pure helper fixture exactly', () {
    final source = File(
      '../capability_conformance/fixtures/capability_pure_helper_surface.spec',
    ).readAsStringSync();
    final result = _engine(source).parse('x');

    expect(result.value, [
      {
        'coalesce': 'fallback',
        'concat_arrays': [1, 2, 3],
        'contains': 1,
        'contains_substr': 1,
        'ends_with': 1,
        'flat': ['x', 'y', 'z'],
        'has_key': 1,
        'num_abs': 3,
        'num_avg': 4,
        'num_ceil': 3,
        'num_clamp': 10,
        'num_div': 3,
        'num_floor': 2,
        'num_ge': 1,
        'num_le': 1,
        'num_median': 3,
        'num_mod': 2,
        'num_mul': 12,
        'num_ne': 1,
        'num_range': 8,
        'num_round': 3,
        'num_sum': 6,
        'slice': ['b', 'c'],
        'starts_with': 1,
        'take_last': ['b', 'c'],
        'uppercase_each': ['A', 'BC'],
      },
    ]);
  });

  test('matches the governed exhaustive position helper fixture exactly', () {
    final source = File(
      '../capability_conformance/fixtures/capability_position_helper_surface.spec',
    ).readAsStringSync();
    final result = _engine(source).parse('ab');

    expect(result.value, [
      {
        'cursor_col': 3,
        'cursor_rest': '',
        'cursor_rest_len': 0,
        'entry_col': 1,
        'entry_end_col': 3,
        'entry_end_line': 1,
        'entry_end_pos': 2,
        'entry_has': 1,
        'entry_len': 2,
        'entry_line': 1,
        'entry_map': {'word': 'ab'},
        'entry_start_col': 1,
        'entry_start_line': 1,
        'entry_start_pos': 0,
        'input_end_col': 3,
        'input_end_line': 1,
        'input_end_pos': 2,
        'input_len': 2,
        'input_text': 'ab',
        'match_col': 1,
        'match_end_col': 1,
        'match_end_line': 1,
        'match_end_pos': null,
        'match_group': null,
        'match_groups': <Object?>[],
        'match_has': 0,
        'match_len': null,
        'match_map': <String, Object?>{},
        'match_named': null,
        'match_start_col': 1,
        'match_start_line': 1,
      },
    ]);
  });

  test('keeps a real zero-width local match present at offset zero', () {
    final engine = _engine(r'''
Top::
 /(?<empty>)/
 E { return(hash("group", match_group(0), "has", match_has(empty), "len", match_len(), "start", match_start_pos(), "end", match_end_pos())) }
''');

    expect(engine.parse('x').value, {
      'end': 0,
      'group': '',
      'has': 1,
      'len': 0,
      'start': 0,
    });
  });

  test('matches the governed marker-control fixture exactly', () {
    final source = File(
      '../capability_conformance/fixtures/capability_control_marker_surface.spec',
    ).readAsStringSync();

    expect(_engine(source).parse('xx').value, ['elif', 'case-b']);
  });

  test('matches the governed anonymous capture fixture exactly', () {
    final source = File(
      '../capability_conformance/fixtures/capability_capture_anonymous_surface.spec',
    ).readAsStringSync();

    expect(_engine(source).parse('AxxBC').value, [
      {
        'rest': 'xxBC',
        'rest_len': 4,
        'slice': 'xxB',
        'slice_col': 2,
        'slice_len': 3,
        'slice_line': 1,
        'slice_pos': 1,
        'take': 'xxB',
        'take_len': 3,
        'take_rest': 'xxBC',
        'take_rest_len': 4,
        'take_until_cursor': 'xxBC',
        'take_until_cursor_len': 4,
        'until_cursor': 'xxBC',
        'until_cursor_len': 4,
      },
    ]);
  });

  test('matches the governed named capture fixture exactly', () {
    final source = File(
      '../capability_conformance/fixtures/capability_capture_named_surface.spec',
    ).readAsStringSync();

    expect(_engine(source).parse('AxxBC').value, [
      {
        'between': 'xxBC',
        'between_len': 4,
        'copied_pos': 1,
        'from': 'xxB',
        'from_len': 3,
        'origin_exists': 1,
        'origin_pos': 1,
        'rest': 'xxBC',
        'rest_len': 4,
        'take_between': 'xxBC',
        'take_between_len': 4,
        'take_len': 3,
        'take_rest': 'xxBC',
        'take_rest_len': 4,
        'take_until_cursor': 'xxBC',
        'take_until_cursor_len': 4,
        'until_cursor': 'xxBC',
        'until_cursor_len': 4,
        'whole_input': 'AxxBC',
      },
    ]);
  });
}

LinkedSpecRuntimeEngine _engine(
  String source, {
  LinkedSpecParseMode parseMode = LinkedSpecParseMode.seek,
  String? specName,
  String? specPath,
}) {
  return LinkedSpecRuntimeEngine(
    compileSpec(parseSpec(source)),
    parseMode: parseMode,
    specName: specName,
    specPath: specPath,
  );
}

LinkedSpecRuntimeEngine _engineWithFunctions(
  String source,
  List<FunctionDefinition> functions, {
  LinkedSpecParseMode parseMode = LinkedSpecParseMode.seek,
}) {
  final parsed = parseSpec(source);
  return LinkedSpecRuntimeEngine(
    compileSpec(SpecFile(functions: functions, rules: parsed.rules)),
    parseMode: parseMode,
  );
}

FunctionDefinition _function(
  String name,
  List<String> params,
  String bodySource,
) {
  return FunctionDefinition(
    name: name,
    params: params,
    arity: params.length,
    bodySource: bodySource,
    bodyAst: parseActionBlock(bodySource).toJson(),
    source: 'fn $name(${params.join(", ")}) { $bodySource }',
    sourceSpan: const SourceSpan(lineStart: 1, lineEnd: 1),
    bodySpan: const SourceSpan(lineStart: 1, lineEnd: 1),
  );
}
