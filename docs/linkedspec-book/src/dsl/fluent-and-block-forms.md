# Fluent and Block Forms

LinkedSpec actions can be written in two styles: **fluent** (chained method calls separated by
dots) and **structured** (statements inside a lifecycle block). This chapter covers both styles,
the currently portable control-flow forms, and the attached-block flow syntax being implemented in
Round 2.

## The two expression styles

Most ordinary LinkedSpec helper statements — assignment, push, return, and pure
value helpers — can be written in either fluent or structured style. No-arg action-edge
continuations such as `-> child .push` and `-> child[1] .return(expr)` are portable on the
Perl reference and Rust. Receiver-fluent attached `when/otherwise` block chains are portable on
action-edge and lifecycle-marker surfaces. Compact lifecycle receiver chains such as
`I.return(...)` and `I.set(...).return(...)` are also portable on lifecycle-marker surfaces:
they execute as the same ordered lifecycle statements as the equivalent `{ ... }` block.

**Fluent style** chains calls on action edges with `.method()`:

```text
/[A-Za-z_, ]+/ -> FieldList
  .set(parts, [])
  .set(raw, entry_text())
  .split(parts, raw, /,/)
  .filter_nonempty(parts)
  .return(hash("kind", "field_list", "fields", copy(parts)));
```

**Structured style** places calls inside a lifecycle block:

```text
I {
  items = [];
  retv = undef;
}
```

For ordinary helper statements, both styles lower to the same action model. The choice between them is
readability: use fluent chains for short action edges and structured blocks when the action needs multiple
updates or branch logic.

Compact lifecycle receiver chains are useful when the lifecycle hook is short:

```text
value : /[A-Za-z_]\w*/ I.return(hash("kind", "name", "text", entry_text()))
```

For multiple lifecycle statements, the chain runs left to right:

```text
item : /[A-Za-z_]\w*/
 I.set(text, lowercase(entry_text()))
  .return(hash("kind", "item", "text", text))
```

This is equivalent to:

```text
item : /[A-Za-z_]\w*/
 I {
   text = lowercase(entry_text());
   return(hash("kind", "item", "text", text));
 }
```

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
Expression-valued blocks are the separate value form used inside value-consuming
expressions. They can also be receiver-dot receivers when their yielded value matches
the helper family, for example `{ [3, 1, 2] }.sorted().join_values(",")` or
`{ " a-b " }.trim().split("-").count()`.

```text
rule:AND+
 I   { acc = []; n = 0; }
 E   { push(acc, call(child)); n = num_add(n, 1); }
 LX  { return(hash("items", copy(acc), "count", n)); }
```

## Statement separators

Inside structured action and lifecycle blocks, a newline is an implicit separator between
top-level helper statements:

```text
-> child {
  set(name, "field")
  return(name)
}
```

A semicolon separates adjacent statements when multiple statements share one physical
line:

```text
-> child { set(name, "field"); return(name) }
```

The last statement on the line needs no trailing semicolon: `;` is a separator, not a
terminator. Plain spaces between same-line helper calls are not statement separators.
Semicolons inside nested expressions or literal payloads stay inside that expression and
do not split the outer statement.

This applies equally to function-style helpers, assignment statements, cursor/capture
operations, and marker-style control statements. Newlines nested inside parentheses,
brackets, blocks, quoted strings, or regex payloads remain part of the surrounding statement.

Marker-style `endswitch()` follows the same rule. When another statement starts on the next
line, the compiler preserves the newline as the LinkedSpec separator and emits whatever
host-language boundary its switch representation requires. Authors do not add a trailing
semicolon merely because the statement is `endswitch()`.

## Control-flow expression forms

LinkedSpec currently supports four portable control-flow families:

- `if/elseif/else` as attached-block statements, with `when/otherwise` as readable aliases for
  the first and fallback attached branches.
- `if/elseif/else` as statement-marker chains.
- `switch/case/default` as attached-block statements.
- `while(cond) { ... }` as an attached-block statement loop with a deterministic iteration-safety guard.

Attached statement-level `switch(...) { case(...) { ... } default { ... } }` is portable on the
Perl reference and Rust backend. Attached statement-level `while(...) { ... }` is also portable on both
variants; the condition is evaluated before each iteration, and non-terminating loops hit the same
10000-iteration safety diagnostic on both implementations. Inline-composite `if(...)` and `switch(...)` are
portable value expressions in supported value positions: `return(...)`, assignment RHS, and fluent
`.return(...)`.

### If family: marker style

Open and close markers build the branch structure explicitly. Every `if` must be closed by `endif`.
Every `elseif` and `else` switches the active branch.

```text
rule:AND+
 I {
   on = 0;
 }
 -> child {
   if(on);
   push(acc, call(child));
   elseif(is_nonempty(tmp));
   push(acc, first(tmp));
   else();
   push(acc, "default");
   endif();
 }
```

Zero-argument markers can drop parentheses for a lighter look:

```text
-> child {
  if(is_nonempty(src));
  push(acc, first(src));
  else;
  push(acc, "default");
  endif;
}
```

The fluent equivalent chains the markers with dots:

```text
-> child
  .if(is_nonempty(src))
  .push(acc, first(src))
  .else
  .push(acc, "default")
  .endif;
```

The parenthesized spellings are currently universal. Bare control-marker suffixes are established on rule-edge and
lifecycle fluent chains. The Perl reference additionally accepts the six standalone aliases `else`, `endif`,
`default`, `endcase`, `endswitch`, and `next`, plus a generic final zero-argument receiver segment such as `.trim`;
the remaining backend rollout is explicitly owned by `FUTURE-PARITY-BACKLOG.16`. This narrow surface does not
change `if(condition)` / `while(condition)` headers or the general parenthesized call grammar. Action-edge
fluent continuations are portable on the Perl reference and Rust for the edge-scoped child-return
surface: no-arg `.push`, `.return(expr)`, `.return_undef()`, explicit-target `.push(target)`, and
`.push(child,target)` inside fluent control chains. Multiline dotted continuations remain attached
to the preceding action edge, so this form is equivalent to keeping the same calls on one chain.
Compact lifecycle-marker chains such as `I.return(...)` are portable too.

### If family: attached blocks

Attached blocks put each branch body directly after its condition. The parser lowers them to the
same control markers as marker style, with an implicit `endif()` at the end of the chain.

```text
-> child {
  if(is_nonempty(src)) {
    push(acc, first(src))
  } elseif(is_defined(fallback)) {
    push(acc, fallback)
  } else {
    push(acc, "default")
  }
}
```

`when(...) { ... }` is an alias for the first attached `if(...) { ... }` branch, and
`otherwise { ... }` is an alias for the fallback `else { ... }` branch:

```text
-> child {
  when(is_nonempty(src)) {
    return(first(src))
  } otherwise {
    return("default")
  }
}
```

Use the aliases when they read better for classification-style rules. They are not host-language
`when` blocks; both the Perl reference and Rust backend normalize them to canonical `if/else`
control flow.

The same branch shape can also be written as a fluent block chain on an action edge:

```text
-> child
  .when(is_nonempty(src)) {
    return(first(src))
  }.otherwise {
    return("default")
  }
```

The fallback can also be written as a no-dot continuation after the first block:

```text
-> child
  .when(is_nonempty(src)) {
    return(first(src))
  } otherwise {
    return("default")
  }
```

Lifecycle markers accept the same receiver-fluent branch shape:

```text
I.when(is_defined(input_kind)) {
  set(kind, input_kind)
}.otherwise {
  set(kind, "default")
}
```

These fluent block chains normalize to the same attached statement controls as the structured
block spelling. Use whichever form keeps the rule easier to scan; prefer the structured spelling
when a branch body is long or teaches several statements.

### If family: inline composite

Inline-composite `if` supports a full `if`/`elseif`/`else` chain as a portable value expression in supported
value-consuming positions. It evaluates conditions left-to-right and evaluates only the selected branch
payload:

```text
set(result,
  if(on,
    first(acc),
    elseif(is_nonempty(tmp), first(tmp)),
    else("default")
  )
);
```

The portable attached-block spelling writes the selected value from branch statements:

```text
I {
  if(on) {
    set(result, first(acc))
  } elseif(is_nonempty(tmp)) {
    set(result, first(tmp))
  } else {
    set(result, "default")
  }
}
```

The fluent `.return(if(...))` spelling follows the same portability boundary:

```text
-> child
  .return(if(on,
    first(acc),
    elseif(is_nonempty(tmp), first(tmp)),
    else("default")
  ));
```

### If family: attached block

Attached-block `if` is the portable block-bodied statement form on Perl and Rust. It accepts compact
same-line `} elseif/else {` continuations and lowers to the same branch-control model as the marker style:

```text
-> child {
  if(on) {
    push(acc, call(child));
  } elseif(is_nonempty(tmp)) {
    found = first(tmp);
    push(acc, found);
  } else {
    push(acc, "default");
  }
}
```

If a statement follows the attached chain on the same physical line, keep the normal separator rule: add a
semicolon after the closing `}` or put the next statement on a new line.

### Switch family: inline composite

Inline-composite `switch` is a portable value expression when one driving value chooses a payload. The first
argument is the switch expression; remaining arguments are `case`/`default` branches. The source is evaluated
once, branches are tested in order, and the selected branch payload becomes the value:

```text
LX {
  return(switch(kind,
    case("token", "found a token"),
    case("list", "found a list"),
    default("unknown")
  ));
}
```

The fluent equivalent returns the same selected payload. Compatibility return arrays may contain ordinary
string tags on legacy/action-edge surfaces, but those tag strings are not part of the inline value-control
contract:

```text
LX
  .return(switch(kind,
    case("token", "found a token"),
    case("list", "found a list"),
    default("unknown")
  ));
```

Expression-valued branch blocks are accepted too:

```text
LX {
  return(switch(kind,
    case("token", { "found a token" }),
    case("list", { "found a list" }),
    default({ "unknown" })
  ));
}
```

In a `switch`, a bare subject name is a scalar read, but a bare case label is a literal tag. For example,
`switch(kind, case(token, "found"), default("unknown"))` reads scalar `kind` and matches the literal label
`"token"`. Use quoted labels in new examples when that is clearer; use a value expression such as
`case(cat(name, ""), body)` when the case label itself must be read dynamically.

### Switch family: attached block (outer block body)

Use attached-block `switch` when each branch has statement bodies, side effects, or early `return(...)`
statements. The switch subject is evaluated once, `case(...)` branches are tested in order, the first matching
branch runs, and `default` runs only when no prior case matched:

```text
LX {
  switch(kind) {
    case("token") {
      return(cat("token: ", name));
    }
    case("list") {
      return(cat("list: ", count(items)));
    }
    default {
      return("unknown");
    }
  }
}
```

The same case-label rule applies to attached blocks: `switch(kind)` reads scalar `kind`, while `case(token)`
matches the literal tag `"token"`.

The outer block form requires branch bodies on each `case(...)` or `default` branch:

```text
LX {
  switch(kind) {
    case("token") {
      return(cat("token: ", name));
    }
    case("list") {
      return(cat("list: ", count(items)));
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
  while(num_lt(count, 3)) {
    set(count, num_add(count, 1));
  }
  return(count);
}
```

`return(expr)` inside the loop returns from the surrounding rule/action, just like it does inside attached
`if` or `switch` bodies:

```text
-> child {
  while(is_nonempty(queue)) {
    return(first(queue));
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
| Single-branch if/else choice | Attached block or marker style | Portable on Perl and Rust |
| Multi-branch switch with simple bodies | Attached switch | Portable first-match/default behavior |
| Multi-branch switch with complex bodies | Attached switch | Branch bodies can span lines and contain statements |
| Repeated statement body in the Perl reference | Attached while | Re-evaluates the condition and has a deterministic safety guard |
| Deeply nested if/else chains | Marker-style | Explicit open/close markers prevent ambiguity |
| Return payload construction from simple branch values | Inline value `if`/`switch` | Returns the selected payload lazily |
| Return payload construction with substantial statement bodies | Attached block or marker style | Easier to read and maintain |
| Conditional accumulation | Attached block or marker style | Branch body can contain multiple statements |

## Worked example: all forms together

This rule accumulates child results, chooses a return shape based on count, and uses
multiple forms in combination:

```text
Items::
 I {
   acc = [];
   kind = "list";
   retv = undef;
 }
 -> Item {
   retv = call(Item);
   push(acc, retv);
   next();
 }
 LX {
   if(is_empty(acc));
   return(hash("kind", kind, "items", array()));
   else();
   switch(count(acc)) {
     case(1) {
       return(hash("kind", "singleton", "item", first(acc)))
     }
     case(2) {
       return(hash(
         "kind", "pair",
         "first", first(acc),
         "second", first(drop_front(acc))
       ))
     }
     default {
       return(hash(
         "kind", kind,
         "items", copy(acc),
         "count", count(acc)
       ))
     }
   }
   endif();
 }

Item: /\s*[A-Za-z_]+/
 I { return(hash("text", trim(entry_text()))) }
```

This rule uses:
- Structured lifecycle blocks (`I { }`, `LX { }`)
- An action edge that calls `Item`, records its payload, and continues scanning
- Statement-marker `if` inside `LX`
- Inline-composite `switch` inside the `else` branch

Short action-edge helper sequences can use fluent chains when they stay readable. Use structured blocks when
state updates, lifecycle phases, or branch bodies need more room, and prefer the structured attached-block
forms for portable block-bodied control flow.
