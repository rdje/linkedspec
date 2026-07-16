---
id: diagnostic-output-neutral-contract
title: Portable diagnostic output is a quiet caller-owned typed event channel
answers:
  - what is the portable print say print_each contract
  - how many arguments do print say and print_each accept
  - are diagnostic helper arguments evaluated once left to right
  - how are null arrays hashes codeblocks booleans and numbers rendered in diagnostic output
  - does print_each reevaluate prefix and suffix for every item
  - what happens when diagnostic_sink is absent or throws
  - does diagnostic output enter the parse result
  - do diagnostic events appear in primary CLI trace or stdout
  - what happens to diagnostic events around exit_now
date: 2026-07-16
status: current
tags: [architecture, parity, helpers, diagnostic-output, events, sink, generated-source, cli]
evidence: "ADR 0042 ratifies linkedspec-diagnostic-output-v1. capability_conformance/diagnostic_output_contract.json encodes three helpers, 11 render rows, five invalid arities, six semantic scenarios, and an exact rollout ledger; tools/check_diagnostic_output_contract.py independently evaluates those fixtures and rejects eight drift mutations. FUTURE-PARITY-BACKLOG.5.1.2-.6 complete all five native legs while three later legs remain pending."
reverify: "python3 tools/check_diagnostic_output_contract.py"
---

The canonical policy is ADR `0042`; the executable target is
`capability_conformance/diagnostic_output_contract.json`. Native execution accepts an optional caller-owned sink
per invocation. It receives synchronous typed `RuntimeDiagnosticOutputEvent` values with exact
`helper_name`/`rule_label`/`message` fields. Without a sink, execution is quiet. Rich helper events remain distinct
from native trace and ADR `0024`'s canonical primary-command phase trace.

The fixture, rather than any current backend, is authoritative. It fixes arity-before-evaluation, once-only
left-to-right arguments, scalar diagnostic rendering, one-event-per-call/item grouping, empty/wrong-kind behavior,
Unicode order, structural-result neutrality, unchanged sink-failure propagation, and immediate `exit_now`.
Generated APIs must propagate the per-invocation sink; primary commands omit it and therefore emit only canonical
parse JSON on successful default execution.

The rollout ledger now records Perl, Rust, Dart, Julia, and Lua native execution as `complete`. Generated/CLI
projection `.5.1.7`, recurring admission `.5.1.8`, and public no-drift `.5.1.9` remain.

Related facts: [[perl-diagnostic-output-events]], [[rust-diagnostic-output-events]],
[[dart-diagnostic-output-events]], [[julia-diagnostic-output-helpers]],
[[cross-backend-diagnostic-output-drift]], [[lua-diagnostic-output-events]],
[[trace-cross-variant-capability-contract]], [[scalar-to-text-coercion-cross-backend-gap]].
