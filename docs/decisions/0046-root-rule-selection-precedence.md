# 0046 - Root-rule selection uses explicit selector, first authored marker, then first authored rule

- Date: 2026-07-18
- Status: accepted; backend rollout pending
- Tags: architecture, grammar, root-rule, entry-rule, top-rule, cli, descriptor, generated-source, trace, validation, parity

## Context

ADR `0010` established the durable execution model: a selected entry rule is an ordinary rule, and `::` does not
change its regex, mode, edge, lifecycle, recursion, or cursor semantics. It described `::` as an entry marker but
did not fully settle selection when an explicit selector, multiple markers, an earlier ordinary rule, or no marker
is present.

The implementations consequently diverged:

- Perl validation requires a marker, but its final compiler choice defaults to the first parsed rule even when a
  later `::` exists. An explicit `top_rule` wins. Perl outward rule metadata does not currently preserve an
  authored `is_top` bit.
- Rust validation requires a marker. Native default and generated execution use the first marked rule. Explicit
  entry selection exists on `execute_value` and the primary command, but older native/generated entrypoints do not
  yet share the full route contract.
- Dart, Julia, and Lua validation require a marker, while their runtime default helpers already scan the ordered
  compiled rules for the first marker and then fall back to the first rule. The fallback is therefore present but
  unreachable through the normal validated source path. Their explicit selector wins.
- The shared primary CLI already proves that `--top-rule Alternate` can select an ordinary rule in a source that
  contains two `::` markers, and an unknown explicit name returns invocation exit `1`.
- Strict-unused validation is intentionally independent: it computes declared labels minus statically referenced
  labels. A selected or marked entry rule is not treated as referenced or exempt.

The director resolved the ambiguity on 2026-07-18 and explicitly confirmed that `--top-rule` has priority over
`Rule::`.

## Decision

### 1. Selection has one ordered precedence

For every native, loaded, reconstructed, generated, emitted-source, traced, and primary-command execution:

1. If the caller supplies an explicit entry-rule label, select that declared rule. It may be an ordinary `Rule:`
   or any marked `Rule::`, and it wins over every marker.
2. Otherwise select the first authored `Rule::` in definition order.
3. Otherwise select the first authored rule in definition order. With no marker, that rule is an ordinary
   `Rule:`.

The primary-command spelling is `--top-rule NAME`; native adapters use their existing `top_rule` or entry-rule
option shape. Adapter-specific timing may differ, but the selected label and outcome may not.

Definition order is semantic for this decision. Loaded, serialized, reconstructed, and generated forms must
preserve enough ordered authored state to reproduce it.

### 2. A marker is optional, but a rule is not

A valid executable `.spec` contains at least one rule. A `::` marker is no longer a validity requirement under the
accepted contract. Zero-rule input fails structural validation with portable code `no_rules_defined` at
`validate_spec` before selector resolution or user-code evaluation.

An explicit selector is exact and must name a declared rule. An unknown name fails before user code with portable
code `entry_rule_not_found`, stage `select_entry_rule`, and field `entry_rule`. The primary command retains its
canonical operational projection: exit `1` and the normalized error class `parser invocation failed`.

Duplicate labels and other source-shape failures remain governed by the existing grammar and win before selection.

### 3. Authored identity and effective selection are different facts

`is_top` records source syntax only: it is true exactly for a header authored with `::`. Selecting an ordinary
rule explicitly or by markerless fallback does not rewrite it to true. Selecting a later marker explicitly does
not clear the earlier marker. Multiple authored markers remain legal; the first matters only for the default
branch.

Descriptors preserve definition order and each rule's authored `is_top` identity. They must not publish a dynamic
selection by mutating source metadata. The effective entry rule is execution state and belongs in runtime trace
and diagnostic attribution.

Generated artifacts preserve ordered authored identity sufficient to recompute the default. An explicit
execution selector is not serialized back as authored marker state. Direct, traced, and standalone-emitted roles
apply the same precedence.

### 4. Request trace and runtime attribution remain distinct

The canonical primary request trace describes the request: it records the explicit selector or `<default>` when
the caller omitted one. It does not replace `<default>` with the resolved label.

Native/runtime trace and structured diagnostics describe execution and therefore attribute the resolved effective
entry label. An unknown explicit selector attributes the requested missing label at the selection failure boundary
without claiming that it was entered.

### 5. Strict-unused semantics do not change

Entry selection is not a rule edge. Neither an explicit selector nor `::` adds a reference in the authored
dependency graph, and the selected rule is not exempt from strict-unused validation. This preserves the established
defined-minus-referenced behavior across all five backends. A markerless strict spec must satisfy that same graph
contract independently of how its entry rule is chosen.

### 6. The neutral artifact is authoritative during rollout

`capability_conformance/root_rule_selection_contract.json` (`linkedspec-root-rule-selection-v1`) is the executable
target. It fixes eight successful
selection cases, three failures, three strict-graph cases, route projections, the five-backend audit, and the exact
seven-leg rollout. `bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py` independently evaluates the model and
rejects semantic, topology, documentation, and rollout drift.

The neutral leg changes no backend behavior. Implementation proceeds Perl, Rust, Dart, Julia, Lua/LuaJIT, then
composed generated/primary/public admission under `FUTURE-PARITY-BACKLOG.9.1.1.2.1-.6`. Until a backend leg lands,
its current validator/default behavior remains accurately recorded in the contract inventory and mdBook.

## Consequences

- `--top-rule` is unambiguously authoritative even when one or more markers exist.
- A marker remains useful authored default metadata but is no longer mandatory ceremony.
- An ordinary first rule provides deterministic markerless execution.
- Perl must stop using the first rule ahead of a later marker; Rust must extend fallback and explicit selection to
  every execution route; Dart, Julia, and Lua must make their existing fallback reachable.
- Descriptors and generated artifacts cannot blur authored syntax with per-execution state.
- Strict-unused results remain stable rather than silently treating entry choice as a dependency.

## Supersession

This record supersedes ADR `0010` only for root-selection precedence and marker-required validity. ADR `0010`
remains authoritative for the selected rule being otherwise ordinary, regex/mode uniformity, and recursion/
forward-progress doctrine.

## Links

- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.9.1.1.2`)
- Executable contract: `capability_conformance/root_rule_selection_contract.json`
- Checker: `tools/check_root_rule_selection_contract.py`
- Audit card: `docs/knowledge/root-rule-selection-precedence.md`
- Earlier mechanics decision: ADR `0010`
