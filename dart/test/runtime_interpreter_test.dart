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

  test('executes string scalar helpers and receiver chains', () {
    final engine = _engine(r'''
Top::
 /(.+)/
 E {
   raw = entry_group(0);
   set(array(tmp), ["x"]);
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
      'contains': true,
      'starts': true,
      'ends': true,
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

  test('executes numeric helpers aliases symbols and receivers', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
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
      'gt': true,
      'le': true,
      'round': 4,
      'range': 8,
      'avg': 4,
      'median': 3,
      'minimum': 1,
      'bad_div': null,
      'bad_number': null,
    });
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
   set(array(public), [" x ", "", "Y"]);
   return(hash(
     "sorted_drop_first", items.sorted().drop_front(2).first(),
     "reverse_take_last", array(items).reversed().take(2).last(),
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
     "concat", concat_arrays(array("x"), array("y", "z")),
     "sum", array(2, 4, 6).sum(),
     "avg", array(2, 4, 6).avg(),
     "source", copy(array(items)),
     "empty_missing", missing.sorted().is_empty()
   ))
 }
''');

      final result = engine.parse('x');

      expect(result.value, {
        'sorted_drop_first': 'b',
        'reverse_take_last': 'c',
        'contains': true,
        'index': 3,
        'drop_join': 'b|a|c',
        'uniq_join': 'b,a,c',
        'filter_count': 2,
        'split_filter_count': 2,
        'transform_join': 'x|y',
        'take_last': ['c', 'a'],
        'slice': ['a', 'b'],
        'flat': ['p', 'q', 'r'],
        'concat': ['x', 'y', 'z'],
        'sum': 12,
        'avg': 4,
        'source': ['b', 'a', 'c', 'a'],
        'empty_missing': true,
      });
    },
  );

  test('executes array split bridges and statement-only end mutations', () {
    final engine = _engine(r'''
Top::
 /x/
 E {
   raw = " left , right,,third ";
   split(array(parts), raw, /\s*,\s*/);
   items.push_back("a");
   items.push_back("b");
   items.push_front("z");
   items.pop_back();
   items.pop_front();
   array(items).push_back("c");
   return(hash(
     "parts", copy(array(parts)),
     "receiver_split", "a, b".split(/\s*,\s*/),
     "items", copy(array(items)),
     "value_push", items.push_back("bad"),
     "after_value_push", copy(array(items)),
     "tagged", split_tagged_records("a,b", /,/, "?tag:", "field")
   ))
 }
''');

    final result = engine.parse('x');

    expect(result.value, {
      'parts': [' left', 'right', '', 'third '],
      'receiver_split': ['a', 'b'],
      'items': ['a', 'c'],
      'value_push': null,
      'after_value_push': ['a', 'c'],
      'tagged': [
        ['?tag:', 'a', 'field'],
        ['?tag:', 'b', 'field'],
      ],
    });
  });
}

LinkedSpecRuntimeEngine _engine(String source) {
  return LinkedSpecRuntimeEngine(compileSpec(parseSpec(source)));
}
