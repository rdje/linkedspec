# USER GUIDE - ActionIR `ControlFlow.pm`
This guide covers the statement-level control-flow lowering implemented by `perl/LinkedSpec/ActionIR/ControlFlow.pm`.

Read this when you want canonical `if/else` flow, switch/case branching, and helper-based output statements inside those branches.
For exact DSL-to-Perl examples for every control-flow marker and emitted branch shape discussed here, also read [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md).

Method-DSL migration note:
- fluent-versus-structured authoring equivalence is intended to hold inside these branch bodies too,
- so `if(...)` / `elseif(...)` branches and `switch(...)` / `case(...)` action bodies are part of the same method-like DSL equivalence target,
- and supported general-`return(...)` branch-local method slices are now regression-locked on both the fluent and structured surfaces,
- including the corresponding lifecycle surfaces (`I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`, with `LX.if(...).m(...).endif()` versus `LX { if(...); m(...); endif() }` as representative examples, plus the parallel switch/case forms),
- and supported multi-step helper sequences inside action-edge branch bodies are regression-locked there too,
- and that same supported multi-step helper-sequence equivalence is regression-locked on lifecycle branch bodies too,
- and inline composite `switch(..., case(...), default(...))` method forms are regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces,
- even when the docs show only representative branch examples.

Syntax status note:
- the examples in this guide show the currently supported control-flow surface,
- but that surface is not being treated as final UX law,
- and the roadmap now explicitly keeps a control-flow syntax revisit open so we can reduce friction around marker-style forms like `else();` and `endif()`,
- investigate more natural semicolon-light or brace-delimited branch syntax,
- and evaluate inline composite `if(...)` forms similar in spirit to inline composite `switch(...)`.
- that semicolon-light direction is only for canonical method-like DSL blocks,
- not for a mixed raw-Perl-plus-DSL authoring model,
- because raw Perl in `.spec` is now being treated as obsolete authoring that should be rejected and migrated away.
- an agreed pre-implementation design note is now also tracked:
  - keep one branch header mapped to one body carrier,
  - do not mix inline branch actions and attached branch blocks on the same `case(...)`, `default()`, `if(...)`, or `elseif(...)`,
  - do not pursue chained branch-body syntax like `case(value, m1(...).m2(...))`,
  - treat `case(value, { ... })` as the preferred first structured inline-switch extension,
  - `case(value) { ... }` and `default() { ... }` are now supported switch sugar on both inline composite and structured marker-style switch surfaces,
  - treat inline composite `if(cond, action1(...), ..., elseif(cond2, ...), else(...))` as the first `if(...)` step, with the matching structured attached-block form `if(cond) { ... } elseif(cond2) { ... } else() { ... }` now landed on structured block surfaces,
  - and treat marker-style `if(...) ... endif()` / `switch(...) ... endswitch()` as structured-block-context syntax rather than as a free-standing fluent surface.
- Structured block contexts for those marker-style forms include:
  - top-level action-edge `{ ... }` blocks,
  - lifecycle blocks such as `I { ... }`, `LS { ... }`, `LE { ... }`, `E { ... }`, `EX { ... }`, `IT { ... }`, and `LX { ... }`,
  - and nested structured branch bodies such as `case(value, { ... })` and `case(value) { ... }`.

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
1. marker-style flow (`switch() case() default() endswitch()` with optional semicolons on both action-edge structured blocks and lifecycle `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX` blocks), including attached branch-block sugar such as `case(value) { ... }` and `default() { ... }`, and
2. inline composite switch arguments (`switch(expr, case(...), default(...))`), including both `case(value, { ... })` / `default({ ... })` and attached `case(value) { ... }` / `default() { ... }` branch-body forms.

It also supports three `if(...)` surfaces:
1. marker-style flow (`if(...) ... elseif(...) ... else() ... endif()`) in structured block contexts,
2. inline composite flow (`if(cond, action1(...), ..., elseif(cond2, ...), else(...))`) plus its structured branch-body form `if(cond, { ... }, elseif(cond2, { ... }), else({ ... }))`, and
3. structured attached-block composite flow (`if(cond) { ... } elseif(cond2) { ... } else() { ... }`) on action-edge and lifecycle block surfaces.

For the structured branch-body `if(...)` surfaces in items `2` and `3`, nested switch flow is now part of the supported structured-context contract too. That includes:
- marker-style `switch(...) ... case(...) ... default() ... endswitch()`, and
- inline-composite `switch(...)` forms, including attached switch-branch sugar such as `case(value) { ... }` / `default() { ... }`.

Those nested switch forms can now live inside composite-`if(...)` branch bodies without dropping out of canonical rewrite readiness.
That nested inline-composite `switch(...)` coverage inside composite-`if(...)` branch bodies now explicitly includes broader multi-`case(...)` shapes too, not only the simpler single-`case(...)` form.
That same composite-`if(...)` nested marker-switch contract now explicitly includes the deeper `if/elseif/else` branch shape too, not only the simpler `if/else` shape.
That same deeper composite-`if/elseif/else` branch shape is now regression-locked for nested inline-composite `switch(...)` flow too, not only nested marker-style `switch(...) ... endswitch()` flow.
That same deeper composite-`if/elseif/else` branch shape now explicitly includes the broader multi-`case(...)` nested inline-composite `switch(...)` form too, not only the simpler single-`case(...)` nested inline-switch shape.
That same deeper composite-`if/elseif/else` branch shape now explicitly includes the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` form too, not only the simpler single-`case(...)` marker-switch shape.
Marker-style `if(...) ... endif()` and marker-style `switch(...) ... endswitch()` are also intended to allow arbitrarily deep mutual nesting in structured block contexts. The current regression suite locks a representative deeper alternating chain across action-edge and the full lifecycle family, and that same deeper alternating contract is now pinned inside attached switch branch blocks too, so there is no DSL-fixed semantic nesting cap here beyond normal recursion/resource limits.

## `if / elseif / else / endif`
These are statement markers, not Perl block keywords.
In structured helper-only blocks and structured lifecycle `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX` blocks, semicolons are accepted but not required between top-level method statements.

### Basic form

```text
if(condition)
  ...
endif()
```

### With else branch

```text
if(condition)
  ...
else()
  ...
endif()
```

### With elseif/elif

```text
if(condition_a)
  ...
elseif(condition_b)
  ...
else()
  ...
endif()
```

Alias form:

```text
i(condition_a)
  ...
elif(condition_b)
  ...
endif()
```

## Common `if` use cases
### Flush a working array only when it has content

```text
if(is_nonempty(array(word)))
  push_value(array(tail), join_values("", array(word)));
  assign(array(word), array());
endif()
```

### Return different payloads depending on accumulator state

```text
if(is_nonempty(array(tail)))
  return(array(scalar(head), array_copy(array(tail))));
else()
  return(array(scalar(head), undef));
endif()
```

### Optional return

```text
if(is_nonempty(array(items)))
  return(array_copy(array(items)));
else()
  return_undef();
endif()
```

## `switch / case / default / endswitch`
Switch is useful when the same driving value controls multiple branches.

### Marker-style switch

```text
switch(scalar(kind))
  case("SPACE")
    ...
  case("COMMENTS")
    ...
  default()
    ...
endswitch()
```

Optional `endcase()` is supported when you want to close a case explicitly before opening the next one, but it is not required in most normal flows.

### Regex case matching
`case(...)` is not limited to literal equality tests. Regex cases are also supported.

Example:

```text
switch(scalar(token))
  case(/^BEGIN_/)
    say("begin token");
  case(/^END_/)
    say("end token");
  default()
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

The first structured branch-body extension is supported too:

```text
switch(
  scalar(op),
  case("|", {
    push(pipe_operator, rule)
    say("pipe")
  }),
  default({
    say("Error")
    return_undef()
  })
)
```

Current direction note:
- the current composite baseline remains `switch(expr, case(...), default(...))` with explicit action lists,
- `case(value, { ... })` and `default({ ... })` are now supported as the first structured inline-switch branch-body extension,
- attached-block switch sugar `case(value) { ... }` and `default() { ... }` is now supported too, on both inline composite and structured marker-style switch surfaces,
- and those attached switch branch blocks can now carry nested marker-style flow such as `if(...) ... endif()` while staying fully language-agnostic-ready,
- and they now have explicit regression coverage for nested marker-style `switch(...) ... case(...) ... default() ... endswitch()` flow too,
- and they now have explicit regression coverage for the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape too,
- and the two supported inline-switch structured branch-body carriers `case(value, { ... })` / `default({ ... })` and `case(value) { ... }` / `default() { ... }` are now regression-locked in parity for that broader nested marker-switch shape too,
- and the structured marker-style outer switch surface is now regression-locked in parity across its plain branch-marker form and attached-block switch branch sugar for that broader nested marker-switch shape too,
- and they now have explicit regression coverage for nested composite `if(...)` forms too, including both inline composite and attached-block inner `if` surfaces,
- and they now have explicit regression coverage for parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies too, even when those deeper `if/elseif/else` branches themselves carry nested inline-composite `switch(...)` flow,
- and that same deeper attached-switch parity now has explicit regression coverage for nested marker-style `switch(...) ... endswitch()` flow inside those deeper `if/elseif/else` branches too,
- and that same attached-switch parity now has explicit regression coverage for the broader multi-`case(...)` nested inline-composite `switch(...)` shape inside those deeper `if/elseif/else` branches too,
- and that broader multi-`case(...)` nested inline-switch parity now spans both inline composite and marker-style outer switch families too,
- and that same deeper attached-switch parity now has explicit regression coverage for the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape too, across both inline composite and marker-style outer switch families,
- and they now have explicit regression coverage for nested inline-composite `switch(...)` forms too, on both inline composite and marker-style outer switch surfaces,
- and that nested composite-`if(...)` coverage now explicitly includes the deeper `elseif(...)` branch shape too,
- and that nested inline-composite `switch(...)` coverage now explicitly includes broader multi-`case(...)` shapes too,
- and composite `if(...)` branch bodies now also have explicit regression coverage for broader nested multi-`case(...)` marker-style `switch(...) ... endswitch()` flow, across both structured inline branch-block and attached-block `if(...)` forms,
- and those same composite `if(...)` branch bodies now also have explicit regression coverage for the deeper `if/elseif/else` branch shape with nested marker-style `switch(...) ... endswitch()` flow,
- and those same deeper composite `if/elseif/else` branch bodies now also have explicit regression coverage for nested inline-composite `switch(...)` flow,
- but mixed forms like `default(action1(...)) { action2(...) }` are intentionally out of scope,
- because each branch should have exactly one body carrier.

Nested structured flow example:

```text
switch(
  scalar(op),
  case("|") {
    if(scalar(on))
      say("pipe")
      return_undef()
    else()
      return_undef()
    endif()
  },
  default() {
    return_undef()
  }
)
```

That same nested marker-flow pattern is also supported on the marker-style switch surface:

```text
switch(scalar(op))
  case("|") {
    if(scalar(on))
      say("pipe")
      return_undef()
    else()
      return_undef()
    endif()
  }
  default() {
    return_undef()
  }
endswitch()
```

Nested marker-style switch inside an attached branch block is also supported:

```text
switch(
  scalar(op),
  case("|") {
    switch(scalar(mode))
      case("x")
        say("x")
        return_undef()
      default()
        return_undef()
    endswitch()
  },
  default() {
    return_undef()
  }
)
```

## Inline composite `if(...)` design direction
The first inline composite `if(...)` slice is now supported.

Supported form:

```text
if(
  scalar(on),
  action1(...),
  action2(...),
  elseif(scalar(alt_on), action3(...), action4(...)),
  else(action5(...), action6(...))
)
```

This is the supported first-step compact form. It lowers through the same control-flow path as the older marker-style baseline:

```text
if(scalar(on))
  action1(...)
  action2(...)
elseif(scalar(alt_on))
  action3(...)
  action4(...)
else()
  action5(...)
  action6(...)
endif()
```

Structured branch-body extension:

```text
if(
  scalar(on),
  {
    action1(...)
    action2(...)
  },
  elseif(scalar(alt_on), {
    action3(...)
    action4(...)
  }),
  else({
    action5(...)
    action6(...)
  })
)
```

That structured inline-composite `if(...)` form is now supported too. It uses the same one-header / one-body-carrier rule as the structured inline-composite `switch(...)` branch-body extension, and it reuses the normal semicolon-light structured statement splitter inside each branch body.

Lifecycle-family note:
- the inline composite control-flow surfaces in this guide are no longer only `LX` proof points,
- action-list and structured branch-block forms for inline composite `if(...)` and `switch(...)` are now regression-locked across `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`,
- and the guide continues to show `LX` examples only because they are representative, not because the support stops there.

Longer-term ergonomics may move toward attached-block forms:

```text
if(scalar(on)) {
  action1(...);
  action2(...)
} elseif(scalar(alt_on)) {
  action3(...);
  action4(...)
} else() {
  action5(...);
  action6(...)
}
```

That attached-block direction is intentionally tracked as a later concrete-syntax step rather than the first implementation slice.

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
if(is_nonempty(array(assigns)))
  return(hash("name", scalar(block_namei), "content", array_copy(array(assigns))));
else()
  return_undef();
endif()
```

Use it when the “no result” case is a deliberate branch outcome.

## Worked examples
### Example: simple presence guard

```text
if(is_nonempty(array(items)))
  return(array_copy(array(items)));
else()
  return_undef();
endif()
```

### Example: recursive-head/tail finalizer

```text
if(scalar(has_head))
  if(is_nonempty(array(tail)))
    return(array(scalar(head), array_copy(array(tail))));
  else()
    return(array(scalar(head), undef));
  endif()
else()
  return(array(undef));
endif()
```

### Example: classify child return types

```text
switch(scalaref(retv, {type}))
  case("SPACE")
    assign(array(word), array());
  case("COMMENTS")
    return_undef();
  default()
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
switch(scalar(token))
  case(/^\\?/)
    say("tag token");
  case(/^[A-Z_]+$/)
    say("identifier-like token");
  default()
    say("fallback token");
endswitch()
```

## Recommendations
- Use helper flow markers, not raw Perl `if (...) { ... }`, when authoring `.spec` control flow.
- Raw Perl control-flow bodies are legacy migration debt, not part of the intended long-term `.spec` surface.
- Keep nested `if(...)` blocks readable; deeply nested branch stacks are still harder to maintain than assigning an intermediate flag.
- Prefer inline switch only when each branch is short. Use marker-style switch for longer bodies.
- Use `say(...)` and `print(...)` for diagnostics instead of embedding raw output statements if backend-neutrality matters.

## Related guides
- Condition expressions: [`USER_GUIDE_ActionIR_FlowExpr.md`](USER_GUIDE_ActionIR_FlowExpr.md)
- Legacy capture/backtrack helpers: [`USER_GUIDE_ActionIR_Contracts.md`](USER_GUIDE_ActionIR_Contracts.md)
