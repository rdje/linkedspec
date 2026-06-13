# Fluent and Block Forms

LinkedSpec actions can be written in two equivalent styles: **fluent** (chained method calls
separated by dots) and **structured** (statements inside a lifecycle block). This chapter
covers both styles, their three expression forms for control flow, and when to prefer each.

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

Both styles lower to the same generated handler code. The choice between them is
readability, not capability: what you can express in one style you can express in the
other.

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

## Control-flow expression forms

LinkedSpec supports two control-flow families — **if/elseif/else** and
**switch/case/default** — each in three equivalent expression forms.

### If family: marker style

Open and close markers build the branch structure explicitly. Every `if` must be closed
by `endif`. Every `elseif` and `else` closes the preceding branch.

```text
rule:AND+
 I {
   declare(scalar, on, 0);
 }
 -> child {
   if(scalar(on)) {
     push_value(array(acc), call(child));
   }
   elseif(is_nonempty(array(tmp))) {
     push_value(array(acc), first(array(tmp)));
   }
   else {
     push_value(array(acc), "default");
   }
   endif();
 }
```

Zero-argument markers can drop parentheses for a lighter look:

```text
-> child {
  if(is_nonempty(array(src))) {
    push_value(array(acc), first(array(src)));
  }
  else {
    push_value(array(acc), "default");
  }
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

When an `if`/`elseif`/`else` carries a `{ }` block immediately after its arguments, the
block body replaces bare continuation arguments:

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

Attached-block form can mix with plain marker branches in the same chain:

```text
-> child {
  if(scalar(on)) {
    push_value(array(acc), call(child));
  } elseif(is_nonempty(array(tmp)))
    push_value(array(acc), first(array(tmp)));
  else {
    push_value(array(acc), "default");
  }
}
```

### Switch family: marker style

Marker-style switch opens with `switch(expr)`, then each `case`/`default` opens a
branch, closed by `endcase`/`endswitch`:

```text
LX {
  switch(scalar(kind)) {
    case("token")
      return("found a token");
    case("list")
      return("found a list");
    default
      return("unknown");
    endswitch;
  }
}
```

The fluent equivalent chains everything with dots:

```text
LX
  .switch(scalar(kind))
  .case("token")
  .return("found a token")
  .case("list")
  .return("found a list")
  .default
  .return("unknown")
  .endswitch;
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

An outer block body contains the branch markers:

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

The outer block can use either marker-style or attached-block branch bodies freely:

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

## Equivalence guarantee

Every form in this chapter lowers through the same `ControlFlow.pm` lowering pipeline and
produces equivalent generated code. Specifically:

- **Marker-style `if/endif`** and **attached-block `if { }`** produce identical branch
  structure — the attached block is syntactic sugar that emits the closing `}` at the next
  branch marker without an explicit `endif`.

- **Inline composite `if(cond, body, elseif(cond2, body2))`** produces a `do { if ... }`
  block identical in effect to the marker-style chain.

- **Marker-style `switch/endswitch`** produces `do { my $switch_var; my $hit_var; if ... }`
  identical to the inline composite form.

- **Fluent chains** (`.if(...)`, `.declare(...)`, `.return(...)`) produce the same
  statements as the equivalent structured-block content — the dot-separated chain is
  syntactic sugar over the block form.

This equivalence holds across all seven lifecycle families (`I`, `LS`, `LE`, `E`, `EX`,
`IT`, `LX`) and on both action edges (`->`) and blind-call edges (`=>`).

## When to use which form

| Situation | Preferred form | Reason |
| --- | --- | --- |
| Short helper-only sequences (1–3 calls) | Fluent chain | Compact, scans quickly |
| Substantial branch logic (4+ statements) | Structured block | Easier to read and maintain |
| Single-branch if/else choice | Inline composite or attached block | Expresses intent directly |
| Multi-branch switch with simple bodies | Inline composite | One expression, no markers to balance |
| Multi-branch switch with complex bodies | Attached-block outer switch | Branch bodies can span lines |
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
   if(is_empty(array(acc))) {
     return(hash("kind", scalar(kind), "items", array()));
   }
   switch(count(array(acc))) {
     case(1) {
       return(hash("kind", "singleton", "item", first(array(acc))));
     }
     case(2) {
       return(hash(
         "kind", "pair",
         "first", scalar(array(acc), 0),
         "second", scalar(array(acc), 1)
       ));
     }
     default {
       return(hash(
         "kind", scalar(kind),
         "items", array_copy(array(acc)),
         "count", count(array(acc))
       ));
     }
   }
 }
```

This rule uses:
- Structured lifecycle blocks (`I { }`, `E { }`, `LX { }`)
- Attached-block `if { }` inside `LX`
- Attached-block outer `switch { }` inside the `else` branch
- Attached-block branch bodies inside the `switch`

The same logic could be written entirely in fluent style on an action edge, or with marker
chains — the choice is stylistic.
