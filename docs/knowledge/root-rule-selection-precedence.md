---
id: root-rule-selection-precedence
title: "Directed root-selection contract: explicit selector > first authored `::` > first authored `:` when no marker exists"
answers:
  - "what is the root rule selection precedence"
  - "does --top-rule have priority over Rule::"
  - "can --top-rule select an ordinary single colon rule"
  - "what rule is top when a spec has no double colon rule"
  - "is Rule:: required in every spec"
  - "what task owns first rule as top"
  - "which backends currently reject a spec without Rule::"
  - "does selecting the entry rule count as a strict unused reference"
  - "does root selection rewrite descriptor is_top metadata"
  - "why does Perl currently select an ordinary rule before a later Rule:: marker"
date: 2026-07-18
status: neutral contract accepted under ADR 0046; backend rollout 1 complete / 6 pending
tags: [dsl, root-rule, top-rule, entry-selection, cli, descriptor, generated-source, strict-syntax, backend-parity, ADR-0046, FUTURE-PARITY-BACKLOG]
evidence: "Director clarification on 2026-07-18 fixes exact precedence: (1) an explicit entry selector, specifically CLI `--top-rule NAME`, has highest priority and may designate any declared rule, including an ordinary `Rule:` even when a `Rule::` exists; (2) without an explicit selector, the first authored `Rule::` is the default; (3) when no rule ends in `::`, the first authored ordinary `Rule:` is the default. Full five-backend audit under `.9.1.1.2.0` found: Perl validation requires a marker but `Compiler::run_get_pipeline` finally selects requested label or parsed row zero, so an earlier ordinary rule defeats a later marker; Rust validation and native/generated defaults require the first marker, with explicit selection confined to `execute_value`/primary; Dart, Julia, and Lua validation require a marker while their ordered runtime helpers already implement marker-then-first fallback. The existing shared CLI case proves an explicit ordinary rule beats two markers. Strict-unused remains defined-minus-statically-referenced with no selected/marked-rule exemption. ADR 0046 plus `capability_conformance/root_rule_selection_contract.json` now lock eight selections, three failures, three strict cases, source identity, route projections, exact current inventory, seven rollout legs, and 24 mutations without changing backend behavior."
reverify: "python3 tools/check_root_rule_selection_contract.py; perl -Iperl -MLinkedSpec -e 'my %ctx; my $s=\"Earlier:\\n /a/\\n\\nMarked::\\n /b/\\n\"; LinkedSpec::Get(\\$s, runtime_ctx_ref=>\\%ctx); print qq{$ctx{top_rule}\\n}'  # current Perl prints Earlier until .9.1.1.2.1; rg -n \"no top rule found|at least one rule must use|must define a top rule\" perl/LinkedSpec/Validation.pm rust/linkedspec-core/src/validation.rs dart/lib/src/validation julia/src/spec/Validator.jl lua/src/linkedspec/spec_validator.lua"
---

# Root-rule selection precedence

The durable target contract is ordered, not ambiguous:

1. An explicit entry selector wins. On the shared primary command this is `--top-rule NAME`; it may select any
   declared rule and has priority even when the source contains one or more `Rule::` markers.
2. With no explicit selector, the first authored `Rule::` in definition order is the default.
3. With no explicit selector and no `::` marker, the first authored ordinary `Rule:` is the default.

Zero-rule input remains invalid and an explicit unknown name remains an error. A rule selected by any route remains
an ordinary rule at execution time; authored `is_top` metadata records source syntax and is not rewritten to mimic
the dynamic selector. Generated and reconstructed paths preserve definition order plus authored markers, while
request trace keeps the requested selector/`<default>` distinction and runtime attribution records the resolved
label.

Strict-unused is deliberately orthogonal. Selecting or marking a rule does not add an authored edge and does not
exempt the selected rule from the existing defined-minus-referenced check.

ADR [0046](../decisions/0046-root-rule-selection-precedence.md) and the executable neutral contract are complete.
The validators named in the front matter still make the no-marker fallback unreachable, and current Perl still
uses parsed row zero ahead of a later marker. Follow task subtree `.9.1.1.2` for the 1/7 rollout state; do not report
markerless selection as uniformly implemented until the remaining six legs close.
