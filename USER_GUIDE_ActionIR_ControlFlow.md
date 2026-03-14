# USER GUIDE - ActionIR `ControlFlow.pm`
This guide covers the statement-level control-flow lowering implemented by `perl/LinkedSpec/ActionIR/ControlFlow.pm`.

Read this when you want canonical `if/else` flow, switch/case branching, and helper-based output statements inside those branches.
For exact DSL-to-Perl examples for every control-flow marker and emitted branch shape discussed here, also read [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md).

Method-DSL migration note:
- fluent-versus-structured authoring equivalence is intended to hold inside these branch bodies too,
- so `if(...)` / `elseif(...)` branches and `switch(...)` / `case(...)` action bodies are part of the same method-like DSL equivalence target,
- and supported general-`return(...)` branch-local method slices are now regression-locked on both the fluent and structured surfaces,
- even when the docs show only representative branch examples.

## What this module is responsible for
This module lowers:
- `if(...)` and alias `i(...)`
- `elseif(...)` and alias `elif(...)`
- `else()`
- `endif()`
- `switch(...)`
- `case(...)`
- `default()`
- `endcase()`
- `endswitch()`
- `say(...)`
- `print(...)`
- `return_undef()`

It also supports two switch styles:
1. marker-style flow (`switch(); case(); default(); endswitch()`), and
2. inline composite switch arguments (`switch(expr, case(...), default(...))`).

## `if / elseif / else / endif`
These are statement markers, not Perl block keywords. In helper flow, you normally write them as statement-like calls with semicolons.

### Basic form

```text
if(condition);
  ...
endif()
```

### With else branch

```text
if(condition);
  ...
else();
  ...
endif()
```

### With elseif/elif

```text
if(condition_a);
  ...
elseif(condition_b);
  ...
else();
  ...
endif()
```

Alias form:

```text
i(condition_a);
  ...
elif(condition_b);
  ...
endif()
```

## Common `if` use cases
### Flush a working array only when it has content

```text
if(is_nonempty(array(word)));
  push_value(array(tail), join_values("", array(word)));
  assign(array(word), array());
endif()
```

### Return different payloads depending on accumulator state

```text
if(is_nonempty(array(tail)));
  return(array(scalar(head), array_copy(array(tail))));
else();
  return(array(scalar(head), undef));
endif()
```

### Optional return

```text
if(is_nonempty(array(items)));
  return(array_copy(array(items)));
else();
  return_undef();
endif()
```

## `switch / case / default / endswitch`
Switch is useful when the same driving value controls multiple branches.

### Marker-style switch

```text
switch(scalar(kind));
  case("SPACE");
    ...
  case("COMMENTS");
    ...
  default();
    ...
endswitch()
```

Optional `endcase()` is supported when you want to close a case explicitly before opening the next one, but it is not required in most normal flows.

### Regex case matching
`case(...)` is not limited to literal equality tests. Regex cases are also supported.

Example:

```text
switch(scalar(token));
  case(/^BEGIN_/);
    say("begin token");
  case(/^END_/);
    say("end token");
  default();
    say("other token");
endswitch()
```

Use regex cases when the branch logic is classification-by-pattern rather than classification-by-exact-value.

### When switch is a good fit
Use switch when:
- all branches are based on one driving value,
- you have multiple equality or regex cases,
- repeated `elseif(eq(...))` would be noisier than a single dispatch block.

## Inline composite switch
Inline switch keeps the case structure inside one expression.

Example:

```text
switch(
  scalar(op),
  case("|", push(pipe_operator, rule)),
  case("&", say("amp")),
  default(say("Error"), return_undef())
)
```

Use this when:
- the branch actions are short,
- the branch structure is simple,
- you want the dispatch logic compact and local.

## `say(...)`
`say(...)` is the newline-terminating output helper.

Examples:

```text
say("(Lispish) -E- Syntax Error")
say("entered rule ", scalar(rule_name))
```

Use it when you want a simple line-oriented diagnostic.

## `print(...)`
`print(...)` is the non-newline-forcing output helper.

Examples:

```text
print("begin_end_blocks: BEGIN (", scalar(IMATCH), "\n")
print("Object ", scalaref(cur_object, [1]), "\n")
print("token=", scalar(token), " type=", scalaref(retv, {type}), "\n")
```

Use it when:
- you want full control over line endings,
- you want to assemble richer diagnostics,
- you are porting older debug-print rules into canonical helper flow.

## `return_undef()`
This is the explicit helper for returning `undef` in canonical control-flow.

Example:

```text
if(is_nonempty(array(assigns)));
  return(hash("name", scalar(block_namei), "content", array_copy(array(assigns))));
else();
  return_undef();
endif()
```

Use it when the “no result” case is a deliberate branch outcome.

## Worked examples
### Example: simple presence guard

```text
if(is_nonempty(array(items)));
  return(array_copy(array(items)));
else();
  return_undef();
endif()
```

### Example: recursive-head/tail finalizer

```text
if(scalar(has_head));
  if(is_nonempty(array(tail)));
    return(array(scalar(head), array_copy(array(tail))));
  else();
    return(array(scalar(head), undef));
  endif();
else();
  return(array(undef));
endif()
```

### Example: classify child return types

```text
switch(scalaref(retv, {type}));
  case("SPACE");
    assign(array(word), array());
  case("COMMENTS");
    return_undef();
  default();
    push_value(array(word), scalaref(retv, {content}));
endswitch()
```

### Example: compact inline switch

```text
switch(
  scalaref(retv, {type}),
  case("SPACE", assign(array(word), array())),
  case("COMMENTS", return_undef()),
  default(push_value(array(word), scalaref(retv, {content})))
)
```

### Example: regex-driven switch

```text
switch(scalar(token));
  case(/^\\?/);
    say("tag token");
  case(/^[A-Z_]+$/);
    say("identifier-like token");
  default();
    say("fallback token");
endswitch()
```

## Recommendations
- Use helper flow markers, not raw Perl `if (...) { ... }`, when the branch logic is part of canonical DSL migration work.
- Keep nested `if(...)` blocks readable; deeply nested branch stacks are still harder to maintain than assigning an intermediate flag.
- Prefer inline switch only when each branch is short. Use marker-style switch for longer bodies.
- Use `say(...)` and `print(...)` for diagnostics instead of embedding raw output statements if backend-neutrality matters.

## Related guides
- Condition expressions: [`USER_GUIDE_ActionIR_FlowExpr.md`](USER_GUIDE_ActionIR_FlowExpr.md)
- Legacy capture/backtrack helpers: [`USER_GUIDE_ActionIR_Contracts.md`](USER_GUIDE_ActionIR_Contracts.md)
