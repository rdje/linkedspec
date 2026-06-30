# Fluent and Block Forms

LinkedSpec actions can be written in two styles: **fluent** (chained method calls separated by
dots) and **structured** (statements inside a lifecycle block). This chapter covers both styles,
the currently portable control-flow forms, and the attached-block flow syntax being implemented in
Round 2.

## The two expression styles

Most ordinary LinkedSpec helper statements — declaration, assignment, push, return, and pure
value helpers — can be written in either fluent or structured style. Block-bodied fluent control
flow is a narrower surface: use the structured attached-block forms below for portable
cross-backend block control; fluent block chains are documented as portable only after both
backends preserve the same behavior.

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
Lifecycle blocks are statement blocks, not expression-valued blocks: the value of the
last statement is discarded unless that statement is an explicit `return(...)`.
Use `return(...)` when the lifecycle block is meant to write the surrounding rule
return channel.

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

LinkedSpec currently supports four portable control-flow families:

- `if/elseif/else` as attached-block statements, with `when/otherwise` as readable aliases for
  the first and fallback attached branches.
- `if/elseif/else` as inline-composite expressions or statement-marker chains.
- `switch/case/default` as inline-composite expressions or attached-block statements.
- `while(cond) { ... }` as an attached-block statement loop with a deterministic iteration-safety guard.

Attached statement-level `switch(...) { case(...) { ... } default { ... } }` is portable on the
Perl reference and Rust backend. Attached statement-level `while(...) { ... }` is also portable on both
variants; the condition is evaluated before each iteration, and non-terminating loops hit the same
10000-iteration safety diagnostic on both implementations.

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

The parenthesized and bare marker spellings are the portable structured marker forms. Fluent
marker chains are available on the Perl reference and are being locked separately before the book
can present every action-edge fluent continuation as cross-backend portable.

### If family: attached blocks

Attached blocks put each branch body directly after its condition. The parser lowers them to the
same control markers as marker style, with an implicit `endif()` at the end of the chain.

```text
-> child {
  if(is_nonempty(array(src))) {
    push_value(array(acc), first(array(src)))
  } elseif(is_defined(scalar(fallback))) {
    push_value(array(acc), scalar(fallback))
  } else {
    push_value(array(acc), "default")
  }
}
```

`when(...) { ... }` is an alias for the first attached `if(...) { ... }` branch, and
`otherwise { ... }` is an alias for the fallback `else { ... }` branch:

```text
-> child {
  when(is_nonempty(array(src))) {
    return(first(array(src)))
  } otherwise {
    return("default")
  }
}
```

Use the aliases when they read better for classification-style rules. They are not host-language
`when` blocks; both the Perl reference and Rust backend normalize them to canonical `if/else`
control flow.

On the Perl reference, the same branch shape can be written as a fluent block chain on an
action edge or lifecycle marker:

```text
-> child
  .when(is_nonempty(array(src))) {
    return(first(array(src)))
  }.otherwise {
    return("default")
  }
```

The fallback can also be written as a no-dot continuation after the first block:

```text
-> child
  .when(is_nonempty(array(src))) {
    return(first(array(src)))
  } otherwise {
    return("default")
  }
```

Use the structured attached-block spelling above for portable cross-backend examples until
fluent block chains are locked on every backend.

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

Attached-block `if` is the portable block-bodied statement form on Perl and Rust. It accepts compact
same-line `} elseif/else {` continuations and lowers to the same branch-control model as the marker style:

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

If a statement follows the attached chain on the same physical line, keep the normal separator rule: add a
semicolon after the closing `}` or put the next statement on a new line.

### Switch family: inline composite

Use inline-composite `switch` when the switch itself should produce a value. The first argument is the switch
expression; remaining arguments are `case`/`default` branches:

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

With structured branch blocks:

```text
LX {
  return(switch(scalar(kind),
    case("token", { "found a token" }),
    case("list", { "found a list" }),
    default({ "unknown" })
  ));
}
```

### Switch family: attached block (outer block body)

Use attached-block `switch` when each branch has statement bodies, side effects, or early `return(...)`
statements. The switch subject is evaluated once, `case(...)` branches are tested in order, the first matching
branch runs, and `default` runs only when no prior case matched:

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

The outer block form requires branch bodies on each `case(...)` or `default` branch:

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

### While family: attached block (Perl reference status)

Use attached-block `while` when a statement body must repeat while a DSL condition stays true. The condition
is evaluated before every iteration, so body mutations can make the loop terminate:

```text
LX {
  set(count, 0);
  while(num_lt(scalar(count), 3)) {
    set(count, num_add(scalar(count), 1));
  }
  return(count);
}
```

`return(expr)` inside the loop returns from the surrounding rule/action, just like it does inside attached
`if` or `switch` bodies:

```text
-> child {
  while(is_nonempty(array(queue))) {
    return(first(array(queue)));
  }
  return("empty");
}
```

The Perl reference guards each attached `while` with a deterministic 10000-iteration safety limit. A loop whose
condition never becomes false fails the rule instead of hanging the generated parser. A same-line statement
after the loop still needs the normal semicolon separator after the closing `}`.

## Equivalence Guarantee

The current portable equivalence guarantee is intentionally narrower:

- Fluent chains and structured-block statements produce the same ordinary helper statements.
- Inline-composite `if(...)` and statement-marker `if(...); ... endif()` select one branch.
- Inline-composite `switch(...)` evaluates the switch expression once and returns the first matching branch.
- Attached-block `switch(...) { case(...) { ... } default { ... } }` evaluates the switch expression once
  and executes only the first matching branch or the default branch.
- Attached-block `while(...) { ... }` evaluates its condition before every iteration, executes its body while
  true, and fails deterministically after 10000 iterations if the condition never becomes false.

## When to use which form

| Situation | Preferred form | Reason |
| --- | --- | --- |
| Short helper-only sequences (1–3 calls) | Fluent chain | Compact, scans quickly |
| Substantial branch logic (4+ statements) | Structured block | Easier to read and maintain |
| Single-branch if/else choice | Inline composite or marker style | Expresses intent directly |
| Multi-branch switch with simple bodies | Inline composite | One expression, no markers to balance |
| Multi-branch switch with complex bodies | Attached switch | Branch bodies can span lines and contain statements |
| Repeated statement body in the Perl reference | Attached while | Re-evaluates the condition and has a deterministic safety guard |
| Deeply nested if/else chains | Marker-style | Explicit open/close markers prevent ambiguity |
| Return payload construction | Inline composite | Returns the evaluated expression directly |
| Conditional accumulation | Attached block or marker style | Branch body can contain multiple statements |

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

Short action-edge helper sequences can use fluent chains when they stay readable. Use structured blocks when
state updates, lifecycle phases, or branch bodies need more room, and prefer the structured attached-block
forms for portable block-bodied control flow.
