# Fluent and Block Forms

LinkedSpec actions can be written in two styles: **fluent** (chained method calls separated by
dots) and **structured** (statements inside a lifecycle block). This chapter covers both styles,
the currently portable control-flow forms, and the attached-block flow syntax being implemented in
Round 2.

## The two expression styles

Every LinkedSpec helper — declaration, assignment, push, return, flow control — can be
written either way.

**Fluent style** chains calls on action edges with `.method()`:

```text
/[A-Za-z_, ]+/ -> FieldList
  .declare(array, parts)
  .declare(scalar, raw)
  .assign(scalar(raw), entry_text())
  .split(array(parts), scalar(raw), /,/)
  .filter_nonempty(array(parts))
  .return(hash("kind", "field_list", "fields", array_copy(array(parts))));
```

**Structured style** places calls inside a lifecycle block:

```text
Toplevel:AND+
 I {
   declare(array, items);
   declare(scalar, retv);
 }
```

For ordinary helper statements, both styles lower to the same action model. The choice between them is
readability: use fluent chains for short action edges and structured blocks when the action needs multiple
updates or branch logic.

## Structured lifecycle blocks

The seven lifecycle markers open structured blocks where statements execute in a defined
order:

| Marker | Phase | When it runs |
| --- | --- | --- |
| `I` | Initial | Before any child rule dispatch |
| `LS` | Loop Start | Before each repeated child attempt |
| `LE` | Loop End | After each successful repeated child match |
| `E` | Each | After each child rule match (any position) |
| `EX` | Exit | After all children have matched |
| `IT` | Iteration | After each iteration of bounded repetition |
| `LX` | Late Exit | After the rule completes (final cleanup/return) |

A rule can use any subset of these blocks. Statements inside a block run in source order.

```text
rule:AND+
 I   { declare(array, acc); declare(scalar, n, 0); }
 E   { push_value(array(acc), call(child)); assign(scalar(n), num_add(scalar(n), 1)); }
 LX  { return(hash("items", array_copy(array(acc)), "count", scalar(n))); }
```

## Statement separators

Inside structured action and lifecycle blocks, a newline is an implicit separator between
top-level helper statements:

```text
-> child {
  set(name, "field")
  return(scalar(name))
}
```

Semicolons remain valid, and they are required when multiple statements share one
physical line:

```text
-> child { set(name, "field"); return(scalar(name)) }
```

Plain spaces between same-line helper calls are not statement separators. Semicolons
inside nested expressions or literal payloads stay inside that expression and do not split
the outer statement.

## Control-flow expression forms

LinkedSpec currently supports two portable control-flow families:

- `if/elseif/else` as inline-composite expressions or statement-marker chains.
- `switch/case/default` as inline-composite expressions.

Attached-block `if(...) { ... }`, `when(...) { ... } otherwise { ... }`, statement-level
`switch(...) { case(...) { ... } default { ... } }`, and `while(...) { ... }` are Round 2 implementation
work and should not be used as the portable contract yet.

### If family: marker style

Open and close markers build the branch structure explicitly. Every `if` must be closed by `endif`.
Every `elseif` and `else` switches the active branch.

```text
rule:AND+
 I {
   declare(scalar, on, 0);
 }
 -> child {
   if(scalar(on));
   push_value(array(acc), call(child));
   elseif(is_nonempty(array(tmp)));
   push_value(array(acc), first(array(tmp)));
   else();
   push_value(array(acc), "default");
   endif();
 }
```

Zero-argument markers can drop parentheses for a lighter look:

```text
-> child {
  if(is_nonempty(array(src)));
  push_value(array(acc), first(array(src)));
  else;
  push_value(array(acc), "default");
  endif;
}
```

The fluent equivalent chains the markers with dots:

```text
-> child
  .if(is_nonempty(array(src)))
  .push_value(array(acc), first(array(src)))
  .else
  .push_value(array(acc), "default")
  .endif;
```

All three spellings — parenthesized marker, bare marker, fluent chain — lower to the
same generated handler.

### If family: inline composite

A full if/elseif/else chain fits into one expression. The first argument is the condition;
remaining arguments before the next branch marker are the body.

```text
I {
  assign(scalar(result),
    if(scalar(on),
      first(array(acc)),
      elseif(is_nonempty(array(tmp)), first(array(tmp))),
      else("default")
    )
  );
}
```

The structured-block equivalent wraps branch bodies in `{ }`:

```text
I {
  assign(scalar(result),
    if(scalar(on), { first(array(acc)) },
      elseif(is_nonempty(array(tmp)), { first(array(tmp)) }),
      else({ "default" })
    )
  );
}
```

Inline composite is also available as the final call on a fluent chain:

```text
-> child
  .return(if(scalar(on),
    first(array(acc)),
    elseif(is_nonempty(array(tmp)), first(array(tmp))),
    else("default")
  ));
```

### If family: attached block

Attached-block `if` is the Round 2 target syntax. The Perl reference accepts this form, including compact
same-line `} elseif/else {` continuations, but it is not the portable contract until Rust parity lands in
`SPEC-FORMAT-TERSE.2.2.3`:

```text
-> child {
  if(scalar(on)) {
    push_value(array(acc), call(child));
  } elseif(is_nonempty(array(tmp))) {
    assign(scalar(found), first(array(tmp)));
    push_value(array(acc), scalar(found));
  } else {
    push_value(array(acc), "default");
  }
}
```

Use the marker form above for portable cross-backend specs today.

### Switch family: marker style

Marker-style statement `switch` is not portable across backends yet. Use inline-composite `switch`
for portable specs today:

```text
LX {
  return(switch(scalar(kind),
    case("token", "found a token"),
    case("list", "found a list"),
    default("unknown")
  ));
}
```

The fluent equivalent returns the same inline-composite value:

```text
LX
  .return(switch(scalar(kind),
    case("token", "found a token"),
    case("list", "found a list"),
    default("unknown")
  ));
```

### Switch family: inline composite

A complete switch fits into one expression. The first argument is the switch expression;
remaining arguments are `case`/`default` branches:

```text
LX {
  return(switch(scalar(kind),
    case("token", "found a token"),
    case("list", "found a list"),
    default("unknown")
  ));
}
```

With structured branch blocks:

```text
LX {
  return(switch(scalar(kind),
    case("token", { "found a token" }),
    case("list", { "found a token" }),
    default({ "unknown" })
  ));
}
```

### Switch family: attached block (outer block body)

An outer block body contains the branch markers. This is also Round 2 implementation work, not the current
portable contract:

```text
LX {
  switch(scalar(kind)) {
    case("token") {
      return(concat("token: ", scalar(name)));
    }
    case("list") {
      return(concat("list: ", count(array(items))));
    }
    default {
      return("unknown");
    }
  }
}
```

The planned outer block form can use either marker-style or attached-block branch bodies:

```text
LX {
  switch(scalar(kind)) {
    case("token")
      return(concat("token: ", scalar(name)));
    case("list")
      return(concat("list: ", count(array(items))));
    default
      return("unknown");
  }
}
```

## Equivalence Guarantee

The current portable equivalence guarantee is intentionally narrower:

- Fluent chains and structured-block statements produce the same ordinary helper statements.
- Inline-composite `if(...)` and statement-marker `if(...); ... endif()` select one branch.
- Inline-composite `switch(...)` evaluates the switch expression once and returns the first matching branch.

Attached-block control flow will join this guarantee only after the relevant Round 2 leaves land on both the
Perl reference and Rust backend.

## When to use which form

| Situation | Preferred form | Reason |
| --- | --- | --- |
| Short helper-only sequences (1–3 calls) | Fluent chain | Compact, scans quickly |
| Substantial branch logic (4+ statements) | Structured block | Easier to read and maintain |
| Single-branch if/else choice | Inline composite or marker style | Expresses intent directly |
| Multi-branch switch with simple bodies | Inline composite | One expression, no markers to balance |
| Multi-branch switch with complex bodies | Inline composite today; attached switch after Round 2 | Branch bodies can span lines after parity lands |
| Deeply nested if/else chains | Marker-style | Explicit open/close markers prevent ambiguity |
| Return payload construction | Inline composite | Returns the evaluated expression directly |
| Conditional accumulation | Marker style today; attached block after Round 2 | Branch body can contain multiple statements |

## Worked example: all forms together

This rule accumulates child results, chooses a return shape based on count, and uses
multiple forms in combination:

```text
Items::AND+
 I {
   declare(array, acc);
   declare(scalar, kind, "list");
 }
 E {
   push_value(array(acc), call(Item));
 }
LX {
   if(is_empty(array(acc)));
   return(hash("kind", scalar(kind), "items", array()));
   else();
   return(switch(count(array(acc)),
     case(1, hash("kind", "singleton", "item", first(array(acc)))),
     case(2, hash(
       "kind", "pair",
       "first", scalar(array(acc), 0),
       "second", scalar(array(acc), 1)
     )),
     default(hash(
       "kind", scalar(kind),
       "items", array_copy(array(acc)),
       "count", count(array(acc))
     ))
   ));
   endif();
 }
```

This rule uses:
- Structured lifecycle blocks (`I { }`, `E { }`, `LX { }`)
- Statement-marker `if` inside `LX`
- Inline-composite `switch` inside the `else` branch

The same logic could be written with a short fluent chain on an action edge when it stays readable. Use
structured blocks when the state updates or branch bodies need more room.
