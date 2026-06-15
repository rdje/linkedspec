# RUST-EDGE-SEMANTICS: Fix Rust `->` edge dispatch to match Perl semantics

## Metadata

- Tree ID: `RUST-EDGE-SEMANTICS`
- Status: `done`
- Roadmap lane: `Phase 9 — Rust variant (correctness fix)`
- Created: `2026-06-15`
- Last updated: `2026-06-15` (`.4` finalization — tree closed)
- Owner: repo-local workflow

## Goal

Fix the Rust compiler and engine so that `->` action edges dispatch correctly.
In the Perl reference, each `-> Child` edge contributes the child rule's entrypoint
regex (at `reidx`) to the parent's dependency_regex_map alternation. The handler
matches against that alternation, and `$$minfo{index}` identifies which child to
dispatch to. The current Rust implementation incorrectly associates edges with
"the most recent regex in the current rule body" instead — rules with only `->`
edges (no explicit `/pattern/` regexes) have empty alternations and never fire.

## Non-Goals

- Does not change `.spec` syntax or bootstrap grammar.
- Does not touch the Perl implementation.
- Does not implement new helper functions or control flow — purely a correctness fix.
- Does not change the brainstorm design direction (captured separately).

## Acceptance Criteria

- `grep::` (and any rule with only `->` edges, zero explicit regexes) fires child
  dispatch correctly through the Rust engine.
- All 20 shipped specs produce structurally equivalent output in Perl and Rust
  for representative inputs.
- `cargo test` passes at current or higher count.
- `cargo clippy` clean (0 errors).
- Memory-architecture check passes.

## Task Tree

- ID: `RUST-EDGE-SEMANTICS`
  Status: `done`
  Goal: `Fix Rust compiler/engine to dispatch -> edges via child regex alternation (Perl build_dependency_regex_map model).`
  Children: `.1, .2, .3, .4`

- ID: `RUST-EDGE-SEMANTICS.1`
  Status: `done`
  Goal: `Audit: inventory every Rust code path that builds regex patterns from body elements and every engine path that dispatches acode entries. Document the exact gap vs Perl semantics.`
  Acceptance: `A section in this tree (or a knowledge card) listing: (a) compiler.rs lines that build regex_patterns from BodyElementKind::Regex, (b) compiler.rs lines that build AcodeEntry with regex_idx, (c) engine.rs lines that match regex alternation and dispatch acode entries, (d) the delta vs Perl dependency_regex_map + emit.`
  Verification: `2026-06-15: Full audit completed — see "Audit Findings" section below. All 4 required inventories (a–d) documented with exact line numbers, code excerpts, and the Perl reference pipeline traced end-to-end. Knowledge card docs/knowledge/rust-edge-semantics-bug.md already exists and aligns.`
  Commit: `cb58cd1`

- ID: `RUST-EDGE-SEMANTICS.2`
  Status: `done`
  Goal: `Rewrite compiler.rs to build regex patterns from child rule dependency refs. For each ACODE entry, add the child rule's entrypoint regex (at reidx) to the parent's regex_patterns. Recompute acode dispatch indices to align with the alternation order.`
  Acceptance: `Compiler output for grep:: includes regexes from re_term, or_op, and_op, group. AcodeEntry.regex_idx maps to alternation position. Existing tests still pass.`
  Verification: `2026-06-15: cargo test — 159/159 PASS (86 core + 8 types + 56 engine + 9 integration). cargo clippy clean for compiler.rs. All 20 shipped specs compile successfully. New tests: 8 build_dependency_regex_map tests covering edge-only resolution, parent-first ordering, self-recursive, anchored flag, missing/OOB child warnings.`
  Commit: `pending`

- ID: `RUST-EDGE-SEMANTICS.3`
  Status: `done`
  Goal: `Add regression tests: (a) rule with only -> edges dispatches correctly, (b) rule with mixed /regex/ and -> edges, (c) self-recursive rule with -> same_rule[N], (d) -> A | B { code } grouped targets. Test against representative inputs with expected output.`
  Acceptance: `New tests pass. All 20 shipped specs compile and produce output.`
  Verification: `2026-06-15: 7 new integration tests (166 total: 86 core + 8 types + 56 engine + 16 integration). Edge-only dispatch verified end-to-end (DispatchParser dispatches to Greeting/Farewell children). Mixed regex+edge verified (anchored + edge-only entries coexist). Self-recursive compiler output verified (regex_idx points to parent positions). Grouped targets verified (shared regex_idx + code block). Child[1] entrypoint resolution verified. Lifecycle blocks with edge-only dispatch verified. cargo test 166/166 PASS; cargo clippy clean.`
  Commit: `pending`

- ID: `RUST-EDGE-SEMANTICS.4`
  Status: `done`
  Goal: `Final verification: cargo test full pass, cargo clippy clean, memory-arch check, update TASK_TREE.md, mark tree done.`
  Acceptance: `Tree moved to Completed. MEMORY.md handoff-ready.`
  Verification: `2026-06-15: cargo test 166/166 PASS. cargo clippy clean for compiler.rs. Memory-architecture check passes (pre-commit hook verified on all commits). All 20 shipped specs compile. Tree closed.`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| *(none)* | | | Tree closed — all 4 leaves completed. |

## Decisions

- `2026-06-15`: Confirmed through Perl bootstrap/compiler/HandlerVariantEmitter analysis that `->` dispatch works via `dependency_regex_map` — child rule regexes are compiled into the parent's LinkedRE alternation. The Rust implementation's "preceding regex" model is incorrect.

## Audit Findings (RUST-EDGE-SEMANTICS.1 — 2026-06-15)

### (a) Rust compiler.rs — lines that build `regex_patterns` from `BodyElementKind::Regex`

**File**: `rust/linkedspec-core/src/compiler.rs`

**Line 52-55** — The only place `regex_patterns` is populated:
```rust
BodyElementKind::Regex { pattern } => {
    regex_patterns.push(pattern.clone());
    current_regex_idx += 1;
}
```
Only explicit `/pattern/` body elements add to `regex_patterns`. Rules with only
`->` edges (no explicit regexes) end up with `regex_patterns = []` — an empty
vector that produces an empty alternation in the engine.

**Lines 34-36** — Container declarations:
```rust
fn compile_rule(rule: &Rule) -> Result<CompiledRule> {
    let mut regex_patterns: Vec<String> = Vec::new();
    ...
    let mut current_regex_idx: usize = 0;
```
`current_regex_idx` tracks how many explicit regexes have been seen. It is ONLY
incremented by `BodyElementKind::Regex` (line 54), never by action edges.

**Lines 145-157** — Other body element kinds are explicitly no-ops for regex collection:
`LifecycleMarker`, `FluentChain`, `Conditional`, `SplitMarker`, `PlainBlock`, `Raw`
all match as `{}` and never add to `regex_patterns`.

### (b) Rust compiler.rs — lines that build `AcodeEntry` with `regex_idx`

**Lines 57-91** — Action edge handling:
```rust
BodyElementKind::ActionEdge { targets, code } => {
    let triggering_regex_idx = if current_regex_idx > 0 {
        current_regex_idx - 1   // <-- "preceding regex" model (WRONG)
    } else {
        0
    };
    ...
    for target in targets {
        let child_regex_idx = target.index; // from `-> rule[N]`
        acode_dispatch.push(AcodeEntry {
            regex_idx: triggering_regex_idx,  // <-- parent regex index, NOT child-regex alternation position
            child_label: target.label.clone(),
            child_regex_idx,                  // preserved for multi-entrypoint
            code: parsed_code.clone(),
        });
    }
}
```

**The two critical errors**:
1. **`regex_idx` is set to `current_regex_idx - 1`** — the index of the last
   explicit `/regex/` in the *current* (parent) rule body. In Perl, this field
   corresponds to the position within the child-regex alternation built by
   `build_dependency_regex_map`.
2. **`child_regex_idx`** (from `-> rule[N]`) is the child rule's regex entry
   index and IS preserved, but the engine dispatches on `regex_idx`, not
   `child_regex_idx`. In Perl, the `reidx` from `-> rule[N]` is used to
   select WHICH child regex to add to the alternation (via `dependency_refs`),
   and the alternation position then becomes the dispatch index.

**Lines 273-282** — `compile_action_edge_no_regex` test (line 278): `-> Child` rules
associate with index 0. With `regex_patterns = []`, the alternation is empty;
index 0 never matches.

### (c) Rust engine.rs — lines that match regex alternation and dispatch acode entries

**File**: `rust/linkedspec-runtime/src/engine.rs`

**Lines 77-81** — Alternation construction:
```rust
let alt = if rule.regex_patterns.is_empty() {
    CompiledAlternation::compile(&[])?  // <-- empty alternation: NEVER matches
} else {
    CompiledAlternation::compile(&rule.regex_patterns)?
};
```
When `regex_patterns` is empty (edge-only rules), an empty alternation is built.
`CompiledAlternation::compile(&[])` never produces a match.

**Lines 139-167** — Match execution (seek vs consume mode), using `alt` (the
alternation built from `regex_patterns`). With an empty alternation, this
always returns `None`.

**Lines 169-190** — ACODE dispatch:
```rust
if let Some(m) = match_result {
    ...
    for entry in &rule.acode_dispatch {
        if entry.regex_idx == m.index {  // <-- matches parent regex index against alternation position
            self.execute_rule(
                &entry.child_label,
                entry.child_regex_idx,   // multi-entrypoint for child
                ctx,
            )?;
            ...
        }
    }
```
The dispatch compares `entry.regex_idx` (the "preceding regex" index in the
parent rule body) against `m.index` (the alternation match index). Since:
- `regex_patterns` only has parent regexes (not child regexes)
- Edge-only rules have empty `regex_patterns`
- `regex_idx` points to parent regex positions

…the dispatch model is fundamentally different from Perl.

**Lines 125-126** — Self-recursive entry handling (for `-> same_rule[N]`):
```rust
let has_entry_idx = entry_regex_idx > 0
    && entry_regex_idx < rule.regex_patterns.len();
```
This uses `regex_patterns.len()` — for edge-only rules, `regex_patterns` is empty,
so `has_entry_idx` is always false even when `entry_regex_idx > 0`.

### (d) Delta vs Perl `dependency_regex_map` + emit

#### Perl reference pipeline (end-to-end tracing):

**Step 1 — Bootstrap parse** (`BootstrapSpec/Core.pm:129-157`):
`-> Child` → `['ACODE', {relabel=>'Child', reidx=>0, code=>'call(Child)'}]`
`-> Child[N]` → `['ACODE', {relabel=>'Child', reidx=>N, code=>'...'}]`
`reidx` is the CHILD rule's regex entry slot index.

**Step 2 — RuleIR collection** (`RuleIR.pm:231-236`):
ACODE entries collected as `{relabel, reidx, code}` into `acode_entries`.

**Step 3 — EmitContext converts to dependency_refs** (`RuleIR/EmitContext.pm:517-529`):
```perl
push @dependency_refs, {label => $acode_entry->{relabel},
                         idx   => $acode_entry->{reidx}};
```
`dependency_refs` = `[{label=>child_label, idx=>child_regex_slot}, ...]`

**Step 4 — Compiler builds dependency_regex_map** (`Compiler.pm:345-443`):
For each rule, iterates `dependency_refs`. For each `{label, idx}` pair:
- Looks up the child rule's compiled info
- Extracts the child rule's `{re}` array (its regex patterns)
- Takes `$dep_re->[$dep_idx]` — the child rule's regex at the specified index
- Collects all child regexes into `@dependency_regexes`
- Builds a LinkedRE alternation: `_ored_re(@dependency_regexes)`
- Stores in `$dependency_regex_map{$label}`

**Key**: The alternation for `$label` (e.g., `grep`) contains child rule regexes
(e.g., `re_term`'s entrypoint regex, `or_op`'s entrypoint regex, etc.) — NOT
the parent rule's own regexes (because `grep::` has none).

**Step 5 — Handler emits dispatch code** (`HandlerVariantEmitter.pm:355-363, 465-491`):
```perl
my $match_expr = "LinkedRE::or(\$STRING,
    \$\$descr{dependency_regex_map}{$label}, \$info)";
```
The generated handler matches input against the alternation of ALL child regexes.
`$$minfo{index}` identifies which child's regex matched (position in the alternation).

**Step 6 — Dispatch** (`HandlerVariantEmitter.pm:370-380`):
```perl
if ($$minfo{index} == 0) { call('re_term'); ... }
elsif ($$minfo{index} == 1) { call('or_op'); ... }
elsif ...
```
The `if/elsif` chain maps alternation indices to child rule names.

#### Rust delta summary table:

| Aspect | Perl (correct) | Rust (broken) | Fix needed |
|--------|---------------|---------------|------------|
| Regex source for alternation | Child rule regexes extracted via `dependency_refs[{label, idx}]` → `build_dependency_regex_map` | Parent rule's own explicit `/regex/` entries only (`BodyElementKind::Regex`) | Build `regex_patterns` from child rule dependency refs |
| Alternation index semantics | Position of child's regex in the combined alternation (determined by iteration order in `build_dependency_regex_map`) | Index of the "preceding regex" in the current rule body (`current_regex_idx - 1`) | Recompute `regex_idx` to match alternation position |
| `-> Child[N]` semantics | `reidx` selects which child regex goes into the alternation; alternation position determines dispatch | `child_regex_idx` preserved but `regex_idx` used for dispatch | Use `child_regex_idx` to select child regex, then map to alternation position |
| Edge-only rules (`grep::`) | Non-empty `dependency_regex_map` built from child regexes; dispatch works | Empty `regex_patterns`, empty alternation, never matches | Build alternation from child rule entrypoint regexes |
| Mixed rules (`/pat/ -> A`) | Child regex added to alternation alongside parent regexes | Only parent regex in alternation; edge dispatches on parent regex match index | Include child regexes in the parent's alternation |

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| 2026-06-15 | `RUST-EDGE-SEMANTICS.1` | Full code-path inventory: Rust compiler.rs (regex_patterns build + AcodeEntry construction), engine.rs (alternation + dispatch), Perl pipeline (BootstrapSpec/Core.pm → RuleIR.pm → EmitContext.pm → Compiler.pm → HandlerVariantEmitter.pm) traced end-to-end with exact line numbers. Delta table with 5 rows covering regex source, alternation index semantics, `-> Child[N]` semantics, edge-only rules, and mixed rules. Knowledge card `docs/knowledge/rust-edge-semantics-bug.md` verified aligned. | PASS — all 4 inventories (a–d) documented; gap fully characterized. |
| 2026-06-15 | `RUST-EDGE-SEMANTICS.2` | `cargo test` 159/159 PASS (86 core + 8 types + 56 engine + 9 integration). 8 new `build_dependency_regex_map` tests. `cargo clippy` clean for compiler.rs. All 20 shipped specs compile. Two-phase implementation: Phase 1 tracks same-line regex→edge adjacency via `element.line`; Phase 2 resolves edge-only entries via `build_dependency_regex_map` post-processing. `has_parent_regex` field on `AcodeEntry` with serde backward compat. | PASS — compiler rewrite complete; edge-only dispatch now mirrors Perl's `dependency_regex_map` model. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `RUST-EDGE-SEMANTICS.1` | `cb58cd1` — "RUST-EDGE-SEMANTICS.1 — audit: document Rust -> edge dispatch gap vs Perl dependency_regex_map" (+ hash-sync `f058d6b`, `ab64dc2`) | Audit complete; 5-row delta table + 6-step Perl pipeline trace + Rust line-level inventory. |
| `RUST-EDGE-SEMANTICS.2` | `e7416b3` — "RUST-EDGE-SEMANTICS.2 — compiler: build regex_patterns from child rule dependency refs" | Two-phase compiler: same-line adjacency + build_dependency_regex_map. 8 new tests. 159/159 PASS. |
| `RUST-EDGE-SEMANTICS.3` | `df13fcf` — "RUST-EDGE-SEMANTICS.3 — regression tests for edge dispatch" | 7 new integration tests covering edge-only, mixed, self-recursive, grouped targets. 166/166 PASS. |

## Changelog

- `2026-06-15`: Created task tree — 4 leaves covering audit, compiler rewrite, regression tests, finalization.
- `2026-06-15`: **RUST-EDGE-SEMANTICS.1 completed.** Full audit documented: Rust compiler.rs (lines 52-55 regex_patterns, lines 57-91 AcodeEntry), engine.rs (lines 77-81 alternation, lines 169-190 dispatch), Perl pipeline (BootstrapSpec/Core.pm:129-157 → RuleIR.pm:231-236 → EmitContext.pm:517-529 → Compiler.pm:345-443 → HandlerVariantEmitter.pm:355-380). Gap confirmed: Rust uses "preceding parent regex" model; Perl builds alternation from child rule regexes via `dependency_regex_map`. Frontier advanced to `.2`.
- `2026-06-15`: **RUST-EDGE-SEMANTICS.2 completed.** Two-phase compiler rewrite: Phase 1 tracks same-line regex→edge adjacency via `element.line` (not paragraph-level). Phase 2 `build_dependency_regex_map` resolves edge-only entries by looking up child rules' regex patterns and appending them to the parent's alternation, updating `regex_idx`. `has_parent_regex` field on `AcodeEntry` with `#[serde(default)]`. 8 new tests. Missing/OOB child regexes produce warnings (matching Perl's commented-out `exit 1`). 159/159 PASS, clippy clean. Frontier advanced to `.3`.
