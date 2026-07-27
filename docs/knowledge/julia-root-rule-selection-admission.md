---
id: julia-root-rule-selection-admission
title: "Julia root-rule selection is admitted through one exact 15-role consumer"
answers:
  - "is Julia root rule selection admitted"
  - "which root rule selection variants have parity after Julia admission"
  - "which variant parity has been achieved so far"
  - "what is the current root selection rollout count"
  - "what remains after Julia root selection admission"
  - "how many roles are in Julia root rule selection admission"
  - "where is the Julia root rule selection admission consumer"
  - "which Julia root selection routes are topology checked"
  - "which primary CLI cases admit Julia root selection"
  - "how many root selection drift mutations are checked after Julia admission"
  - "how many Julia package assertions pass after root selection admission"
  - "why do Julia root selection fixtures return from I instead of E"
date: 2026-07-18
status: Julia admitted; neutral, Perl, Rust, Dart, and Julia complete at 5/7
tags: [julia, root-rule, top-rule, admission, lifecycle, topology, primary-cli, backend-parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.4.3 adds `julia/test/root_rule_selection_admission_test.jl`, one omission-sensitive consumer whose 15 contract-declared roles execute exactly once: neutral selection/failure/strict rows; native; loaded; reconstructed; generated direct/traced; emitted-source direct/traced; descriptor; diagnostic; runtime trace; primary CLI; and primary request trace. Authored selection fixtures return distinct values from entry lifecycle `I`, making the result direct evidence of which rule was entered; only the exact shared request-trace fixture retains its canonical `E` source. The checker locks exact source role order/inventory, consumer path, six shared primary case ids, package-wide Julia driver, package include, canonical registration, Julia-only rollout promotion, and 39 total semantic/topology/inventory/rollout mutations. Focused admission passes 137 assertions. The complete Julia gate passes package 3,428, shared primary 65/65 with `POSIXLY_CORRECT` unset and set, and corpus 105/105. Only Julia advances, so root-selection rollout is 5 complete / 2 pending: neutral, Perl, Rust, Dart, and Julia complete; Lua/LuaJIT and final composed no-drift remain `.5-.6`."
evidence_update_2026_07_18_signoff: "Canonical CI passes all four doctrines, root consumers 7+5, cursor admission 288, reference primary 65x2, and Phase 0 1,031/1,031 in 616 seconds. mdBook, JSON, whitespace, Knowledge Map 622/4,524, and generated 11 MiB book / 28 KiB Python-cache cleanup pass."
reverify: "bash tools/run_julia_local.sh && bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py"
---

# Julia root-selection admission

Julia is the fourth admitted backend for `linkedspec-root-rule-selection-v1`,
after the Perl reference, Rust, and Dart. Together with the neutral contract,
that makes rollout 5 complete / 2 pending. Lua/LuaJIT and final five-backend
public no-drift remain dependency-ordered under `.9.1.1.2.5-.6`.

The admission test composes existing semantic owners rather than adding another
resolver. Its ordered role map covers every neutral row and native,
loaded/reconstructed, generated/emitted direct and traced, descriptor,
diagnostic, runtime-trace, primary, and request-trace projection exactly once.
The checker compares the complete ordered `role_*` source inventory with the
contract and locks the consumer into both the Julia package and canonical
drivers.

The marked and markerless execution fixtures use entry lifecycle `I` returns.
That choice matters: a distinct return at entry proves which rule selection
entered, while an exit lifecycle `E` return after a successful local match can
produce the same final value without isolating entry choice as clearly. The
shared request-trace case deliberately retains its existing `E` source because
that role verifies canonical checked-in trace bytes, not lifecycle semantics.

Focused composition passes 137 assertions without warnings. The complete Julia
driver passes 3,428 package assertions, all 65 shared primary cases in both
option environments, and all 105 corpus fixtures. Five new mutations cover
Julia role, consumer, shared-primary, canonical-driver, and rollout drift,
raising the root checker to 39 rejected mutations.

Related: [[julia-root-rule-selection-routes]],
[[julia-root-rule-selection-core]], [[julia-rule-local-cursor-admission]],
[[root-rule-selection-precedence]], and
[[dart-root-rule-selection-admission]].
