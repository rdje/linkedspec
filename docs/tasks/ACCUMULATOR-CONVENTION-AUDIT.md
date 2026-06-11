# ACCUMULATOR-CONVENTION-AUDIT: Audit convention-based accumulator helpers

## Metadata

- Tree ID: `ACCUMULATOR-CONVENTION-AUDIT`
- Status: `active`
- Roadmap lane: `Method-like DSL migration follow-on`
- Created: `2026-06-11`
- Last updated: `2026-06-11`
- Owner: repo-local workflow

## Goal

Audit all convention-based accumulator helpers — helpers that silently/implicitly target the current-rule array (`@RuleName`) without the user explicitly naming the target. Document every such helper, its ActionIR contract, the exact lowering path, and every usage site across the 19 shipped specs. The outcome is a complete inventory that informs whether any should gain explicit-target forms, be deprecated, or remain as-is with clear documentation.

## Non-Goals

- Does NOT migrate or change any helper behavior — audit only.
- Does NOT change ActionIR lowering, Contracts, or Scanner rules.
- Does NOT retire or deprecate any helpers — only identifies candidates.
- Does NOT touch the plugin corpus or `.plg` files.

## Acceptance Criteria

- Every convention-based accumulator helper is identified with its ActionIR contract ID, lowering owner, and Scanner rule.
- Every usage site across the 19 shipped `specs/*.spec` files is counted and categorized.
- The audit distinguishes between: (a) bare `push(Child)` implicit-target, (b) `push(Child, index)` implicit-target, (c) `push(Child, named_target)` explicit-target via push, (d) `push_value(array(name), ...)` fully explicit.
- The audit notes any `push(...)` calls that could be ambiguous between conventions.
- Phase0 regression gate stays green throughout (no code changed).
- Findings are documented in this task file with clear recommendations.

## Task Tree

- ID: `ACCUMULATOR-CONVENTION-AUDIT`
  Status: `active`
  Goal: `Complete audit of all convention-based accumulator helpers across ActionIR contracts and shipped specs.`
  Children: `ACCUMULATOR-CONVENTION-AUDIT.1, ACCUMULATOR-CONVENTION-AUDIT.2, ACCUMULATOR-CONVENTION-AUDIT.3`

- ID: `ACCUMULATOR-CONVENTION-AUDIT.1`
  Status: `done`
  Goal: `Inventory all convention-based accumulator contracts in ActionIR (Contracts.pm, Scanner rules, lowering owners). Identify every helper that implicitly targets the current-rule array.`
  Acceptance: `Task file lists every relevant ActionIR contract ID, its Scanner rule, lowering owner, and the exact implicit-target mechanics.`
  Verification: `perl -c perl/LinkedSpec.pm OK; phase0 1004 PASS baseline holds (no code changed). ActionIR Contracts.pm §§_build_call_and_dispatch_contracts + _build_assignment_and_regex_contracts fully audited; Scanner/PrimitiveBasicRules.pm push_child_call* scan rules reviewed; MethodLowering.pm push_value/push_nonempty lowering reviewed.`
  Commit: `ACCUMULATOR-CONVENTION-AUDIT.1 — ActionIR accumulator contract inventory complete`

- ID: `ACCUMULATOR-CONVENTION-AUDIT.2`
  Status: `done`
  Goal: `Categorize every usage site across all 19 shipped specs/*.spec files: count bare push(Child), push(Child, index), push(Child, named_target), push_value, push_nonempty, and fluent .push(...) forms.`
  Acceptance: `Task file contains a per-spec breakdown with exact counts for each accumulator form. Ambiguous or noteworthy patterns are flagged.`
  Verification: `perl -c perl/LinkedSpec.pm OK; phase0 1004 PASS baseline (no code changed). All 19 specs audited line by line.`
  Commit: `ACCUMULATOR-CONVENTION-AUDIT.2 — per-spec accumulator usage categorization complete`

- ID: `ACCUMULATOR-CONVENTION-AUDIT.3`
  Status: `pending`
  Goal: `Synthesize findings: document the convention clearly, identify any helpers that hide the target in ways that hurt readability, and make explicit-target recommendations where appropriate.`
  Acceptance: `Task file contains a clear summary of the convention, which helpers are healthy, which could benefit from explicit-target alternatives, and concrete recommendations. Phase0 stays green.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `ACCUMULATOR-CONVENTION-AUDIT.3` | `pending` | Contract inventory + usage categorization complete; now synthesize findings and recommendations. |

## Leaf .1 — ActionIR Contract Inventory (COMPLETE)

### Source files audited
- `perl/LinkedSpec/ActionIR/Contracts.pm` — `_build_call_and_dispatch_contracts` (lines 128–258), `_build_assignment_and_regex_contracts` (lines 1784–1836)
- `perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm` — `_scan_contract_push_child_call_builtin`, `_scan_contract_push_child_call_indexed_builtin`
- `perl/LinkedSpec/ActionIR/MethodLowering.pm` — `_lower_push_value_statement` (line 1735), `_lower_push_nonempty_statement` (line 1776)

### Convention-based (implicit target = current-rule array `@$label`)

These helpers use `$label` — the current rule name — as the target array. The caller does not name the target; the convention supplies it.

| # | Contract ID | DSL form | Emitted Perl | Scanner | Compat surface? |
|---|-------------|----------|-------------|---------|-----------------|
| 1 | `push_single_arg` | `push(Child)` | `push @$label, call(Child)` | `PrimitivePipelineRules` / `LegacyRules` | No |
| 2 | `push_indexed_arg` | `push(Child, idx)` | `push @$label, call(Child)->[idx]` | `PrimitivePipelineRules` / `LegacyRules` | No |

The `$label` variable is injected by `_build_call_and_dispatch_contracts($label)` in `Contracts.pm:129`. Every rule paragraph gets its own contract table with its own `$label`.

### Explicit-target (user names the target array)

| # | Contract ID | DSL form | Emitted Perl |
|---|-------------|----------|-------------|
| 3 | `push_target_arg` | `push(Child, target)` | `push @target, call(Child)` |
| 4 | `push_target_indexed_arg` | `push(Child, target, idx)` | `push @target, call(Child)->[idx]` |
| 5 | `push_scope_target_arg` | `push(scope, Child, target)` | `push @target, call(Child)` (with scope context) |

These are **not** convention-based — the user explicitly names the target array as the second or third argument. They share the `push(...)` spelling with the convention-based forms, which is the ambiguity risk.

### Internal builtin (compatibility surface only)

| # | Contract ID | Matches emitted | Scanner rule | Compat surface? |
|---|-------------|----------------|-------------|-----------------|
| 6 | `push_child_call_builtin` | `push @target, call(Child)` | `PrimitiveBasicRules::_scan_contract_push_child_call_builtin` | **Yes** |
| 7 | `push_child_call_indexed_builtin` | `push @target, call(Child)->[idx]` | `PrimitiveBasicRules::_scan_contract_push_child_call_indexed_builtin` | **Yes** |

These are `compatibility_surface: 1` — they match already-emitted Perl code (from the convention-based and explicit-target contracts above) during the scanner pass. They are not user-facing DSL forms. The `_builtin` suffix signals they are internal. Zero shipped specs should hit these as unresolved; they exist to re-scan already-lowered code.

### Fully explicit (MethodLowering — `push_value` / `push_nonempty`)

| # | Contract ID | DSL form | Lowering owner | Lowers to |
|---|-------------|----------|---------------|-----------|
| 8 | `push_value` | `push_value(array(name), value)` | `MethodLowering::_lower_push_value_statement` | `push @name, $lowered_value` |
| 9 | `push_nonempty` | `push_nonempty(array(name), value)` | `MethodLowering::_lower_push_nonempty_statement` | `push @name, $value if defined + nonempty` |

These are fully explicit: the target must be `array(name)`, `a(name)`, or a bare word. They pass through `MethodLowering`'s structured lowering pipeline rather than being regex-substituted in `Contracts.pm`.

### Fluent `.push(Child, target)` form

The fluent form `.push(Child, target)` on blind-call action-edge chains (used extensively in `ebnf.spec`) is rendered by `BootstrapSpec::Core::_render_method_call_chain`. It becomes a `push(Child, target)` call which then matches `push_target_arg` — the target is explicit (second argument). The chain receiver provides the rule context but does not supply the accumulator target.

### Key architectural observation

The `push(Child)` / `push(Child, idx)` forms are the **only** convention-based accumulators in the entire ActionIR surface. Every other accumulator helper (`push_value`, `push_nonempty`, `push(Child, target)`, fluent `.push`) requires the user to name the target explicitly. The convention is: if `push()` receives exactly one argument (a child rule name) or two arguments where the second looks like an integer index, the target is the current rule's accumulator. If the second argument is a word (not an integer), it's treated as an explicit target name.

### Ambiguity note

There is a structural ambiguity in `push(Child, arg)`: is `arg` an index (convention-based) or a target array name (explicit)? Contracts.pm resolves this by pattern order — `push_indexed_arg` (`\d+`) is checked before `push_target_arg` (`\w+`). A bare `push(Child, 0)` always means "push call(Child)->[0] into @$label". A bare `push(Child, items)` always means "push call(Child) into @items". This is fragile: if a rule happens to be named `0`, `push(0)` could be read as either, and the disambiguation depends on regex match order in Contracts.pm. No shipped spec triggers this edge case.

## Decisions

- `2026-06-11`: Created task tree. Audit-only approach — no behavior changes in this tree. The `_builtin` suffix on ActionIR contract IDs (`push_child_call_builtin`, `push_child_call_indexed_builtin`) already signals these are internal/convention-based rather than user-facing `push(...)` helpers.
- `2026-06-11` (`.1`): The only convention-based accumulators are `push(Child)` and `push(Child, idx)` — 2 out of 9 accumulator-related contracts. The other 7 require explicit target naming. The `push(Child, arg)` integer-vs-word disambiguation is fragile but not currently triggered by any shipped spec.
- `2026-06-11` (`.2`): Convention-based `push(Child)`/`push(Child, idx)` is nearly extinct in shipped specs — only 4 total uses across 3 of 19 specs. The overwhelming norm (63 `push_value` + 19 fluent `.push` in `ebnf.spec`) is explicit-target. See detailed per-spec table below.

## Leaf .2 — Per-Spec Usage Categorization (COMPLETE)

### Summary

| Form | Total uses | Specs using it | Convention-based? |
|------|-----------|----------------|-------------------|
| `push(Child)` — bare implicit | 3 | regdef (2), tkgui (1) | **Yes** |
| `push(Child, idx)` — indexed implicit | 1 | ebnf (1) | **Yes** |
| `.push(Child, target)` — fluent chain | 19 | ebnf (19) | No (target explicit) |
| `push_value(...)` — fully explicit | 63 | ds_vhistory(14), ebnf(2), hlink_substitution(1), Lispish(8), sdce(3), simenv(27), spec(1), tablegrep(2), vhdl(5) | No |
| `push_nonempty(...)` — fully explicit | 2 | ebnf (2) | No |

**Total accumulator operations across all 19 shipped specs: 88**
- Convention-based (implicit target): **4** (4.5%)
- Explicit target: **84** (95.5%)

### Per-spec detail

| Spec | `push(Child)` | `push(C, idx)` | `.push(C, tgt)` | `push_value` | `push_nonempty` | Total |
|------|:--:|:--:|:--:|:--:|:--:|:--:|
| BNF | — | — | — | — | — | 0 |
| DT | — | — | — | — | — | 0 |
| ds_vhistory | — | — | — | 14 | — | 14 |
| ebnf | — | 1 | 19 | 2 | 2 | 24 |
| hlink_substitution | — | — | — | 1 | — | 1 |
| ifelse | — | — | — | — | — | 0 |
| lib_reader | — | — | — | — | — | 0 |
| Lispish | — | — | — | 8 | — | 8 |
| operators_try | — | — | — | — | — | 0 |
| portmap | — | — | — | — | — | 0 |
| pplugin | — | — | — | — | — | 0 |
| regdef | 2 | — | — | — | — | 2 |
| sdce | — | — | — | 3 | — | 3 |
| simenv | — | — | — | 27 | — | 27 |
| spec | — | — | — | 1 | — | 1 |
| tablegrep | — | — | — | 2 | — | 2 |
| tclite | — | — | — | — | — | 0 |
| tkgui | 1 | — | — | — | — | 1 |
| vhdl | — | — | — | 5 | — | 5 |
| verilog | — | — | — | — | — | 0 |
| **TOTAL** | **3** | **1** | **19** | **63** | **2** | **88** |

### Detailed usage by category

#### Convention-based: `push(Child)` — 3 uses, 2 specs

```
specs/regdef.spec:2:   -> reg_def  {push(reg_def)}
specs/regdef.spec:8:   -> reg_fld  {push(reg_fld)}
specs/tkgui.spec:2:    -> sub_gui  {push(sub_gui)}
```

Pattern: action-edge child-call block with a single `push(Child)` statement. The implicit target is `@regdef`, `@regdef`, and `@sub_gui` respectively (matching each rule's name). These are the simplest possible child-dispatch-and-accumulate pattern.

#### Convention-based: `push(Child, idx)` — 1 use, 1 spec

```
specs/ebnf.spec:192:   push(quoted_string, 1);
```

Pattern: inside an action block, pushes `call(quoted_string)->[1]` into `@ebnf` (the current rule `grammar_file`). Takes the second element of the child's return array.

#### Fluent chain: `.push(Child, target)` — 19 uses, 1 spec

All 19 in `specs/ebnf.spec`. Pattern: blind-call edges with fluent chains:
```
=> rule_name.push(rule_name, rule)
=> include_dir.push(includes)
=> include_file.push(includes)
-> semantic_annotation.push(semantic_annotations)
```

The fluent `.push(Child, target)` form names the target array explicitly (second argument). The chain receiver (`rule_name`, `include_dir`, etc.) provides the child rule context; the second argument is the accumulator target. These lower through `push_target_arg` — not convention-based.

#### Fully explicit: `push_value(array(name), value)` — 63 uses, 9 specs

The dominant form. Every call names the target array explicitly via `array(name)` or `a(name)`. Examples:
```
push_value(a(word_items), s(retv))
push_value(a(pieces), s(retv))
push_value(a(vhistory), a("?object:", ...))
```

#### Fully explicit: `push_nonempty(array(name), value)` — 2 uses, 1 spec

```
specs/ebnf.spec:196:  push_nonempty(a(logging_annotation), trim(capture_slice()));
specs/ebnf.spec:200:  push_nonempty(a(logging_annotation), trim(capture_slice()));
```

### Noteworthy patterns

1. **`ebnf.spec` is the outlier** — 24 accumulator ops, the only spec using convention-based `push(C, idx)` and fluent `.push()`, and the only spec using `push_nonempty`. It is the most complex shipped spec and exercises the broadest accumulator surface.

2. **`regdef.spec` and `tkgui.spec` are the last holdouts of bare `push(Child)`** — 2 and 1 uses respectively. Both are small, simple specs where the implicit target convention is arguably clearest.

3. **`simenv.spec` is the heaviest `push_value` user** — 27 uses, all fully explicit with `push_value(a(...), ...)`.

4. **Zero uses of `push(Child, target)` (explicit-target bare form)** — the `push_target_arg` contract exists but no shipped spec spells `push(Child, named_target)` without the fluent `.push()` prefix. The explicit-target form only appears via fluent chains or `push_value`.

5. **10 of 19 specs use zero accumulators** — their action code doesn't need child-result accumulation (they use `return(...)` directly, `assign(...)`, or have no action code).

6. **No lifecycle-block-specific accumulator convention** — all accumulator usage (convention-based and explicit) occurs in action-edge blocks (`{...}` after `-> Child`), not lifecycle blocks (`I { ... }`, `LX { ... }`, etc.). Lifecycle blocks use `push_value` with explicit targets when they need accumulation (e.g., `sdce.spec`'s `LS`/`LX` blocks).

## Open Questions

- Does the fluent `.push(Child, target)` form on action-edge targets count as convention-based (the target is explicit via the chain) or implicit (the chain receiver is the rule)? **Answered in .1: fluent `.push(Child, target)` lowers through `push_target_arg` — the target is explicit (second argument). The chain receiver provides rule context but does not supply the accumulator target.**
- Are there any lifecycle-block accumulator conventions distinct from action-edge ones? **Partially answered: Contracts.pm `_build_call_and_dispatch_contracts` is called per-rule and the `$label` injection is identical for action and lifecycle blocks. No lifecycle-specific accumulator convention found.**
- Does `push(Child)` with the implicit target need an explicit-target alternative (`push_value(array(RuleName), call(Child))`) for clarity, or is the brevity the point? **Still open — will assess in .3 synthesis after .2 usage counts.**

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-11` | `ACCUMULATOR-CONVENTION-AUDIT.1` | `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS (no code changed); ActionIR Contracts + Scanner + MethodLowering fully audited | `passed` |
| `2026-06-11` | `ACCUMULATOR-CONVENTION-AUDIT.2` | `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS (no code changed); all 19 specs audited line by line | `passed` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `ACCUMULATOR-CONVENTION-AUDIT.1` | `bbd15d5` — ACCUMULATOR-CONVENTION-AUDIT.1 — ActionIR accumulator contract inventory complete | 9 contracts identified (2 convention-based, 3 explicit-target, 2 builtin, 2 fully-explicit). No code changes. |
| `ACCUMULATOR-CONVENTION-AUDIT.2` | `pending` | 88 total accumulator ops across 19 specs; only 4 convention-based (4.5%). |

## Changelog

- `2026-06-11`: Created task tree. Activated from backlog item #3.
- `2026-06-11` (`.1`): Completed ActionIR contract inventory. Audited all 9 accumulator-related contracts across Contracts.pm (call+dispatch + assignment+regex), Scanner/PrimitiveBasicRules.pm (push_child_call* scan rules), and MethodLowering.pm (push_value/push_nonempty lowering). Identified exactly 2 convention-based helpers: `push(Child)` and `push(Child, idx)`. All others require explicit target naming.
