---
id: rtlutils-regex-hang
title: The phase0 hang is a catastrophic regex in the Perl-only legacy VHDL subsystem (RTLUtils/FSMGen/VHDL::ConstantEval) — self-contained, zero core dependency, slated for retirement
answers:
  - "what is RTLUTILS-REGEX-HANG"
  - "why does t/phase0_regression.t hang"
  - "where is the catastrophic regex that hangs phase0"
  - "does the .spec parser/compiler/runtime core depend on RTLUtils or FSMGen or VHDL::ConstantEval"
  - "what depends on RTLUtils FSMGen VHDL::ConstantEval"
  - "should I fix the RTLUtils regex hang or retire the subsystem"
  - "what blocks the SPEC-FORMAT-TERSE implementation leaves"
  - "how big is the legacy VHDL/RTL/FSM generation subsystem"
date: 2026-06-18
status: accepted
tags: [legacy-retirement, phase0, regex-hang, vhdl, portability, spec-format-terse]
evidence: "git grep reference sweep + module inspection 2026-06-18 (LEGACY-VHDL-RETIRE.1). Catastrophic regex located; zero core functional dependency confirmed; dependent set catalogued."
reverify: "sed -n '746p' perl/RTLUtils.pm; git grep -lE 'RTLUtils|FSMGen|VHDL::ConstantEval' -- 'perl/LinkedSpec.pm' 'perl/LinkedSpec/'   # core ref = LinkedSpec.pm comment only (line 246); 0 functional"
---

# `RTLUTILS-REGEX-HANG` and the legacy VHDL/RTL/FSM subsystem

`t/phase0_regression.t` hangs because of a **catastrophic-backtracking regex** in the
**Perl-only legacy VHDL/RTL/FSM-generation subsystem**, not anywhere in the active `.spec`
engine.

## The hang

- Offending regex: **`perl/RTLUtils.pm:746`** —
  `/(\w+)(?=(?:\[.*?\])?\s*<=((?s).+?);)/go`. The variable-width lookahead wrapping a dotall
  non-greedy `(?s).+?` backtracks exponentially on input lacking a matching `<= … ;`.
- Reached via `RTLUtils::drive_entity_component(...)` → `_drive_instances(...)`. Phase0 exercises
  `RTLUtils` in subprocess migration-smoke blocks (e.g. `drive_entity_component` at
  `t/phase0_regression.t:3540`).
- (Earlier notes attributed it to `add_header_n_context_clause`; the actual pattern is at line 746
  in `_drive_instances`.)

## The subsystem (Perl-only, no Rust/Julia/Dart counterpart)

- `perl/RTLUtils.pm` (877), `perl/FSMGen.pm` (3,549, `use RTLUtils`, ≈30 calls; `AUTOLOAD`→PluginBridge),
  `perl/VHDL/ConstantEval.pm` (90, `require RTLUtils`). = **4,516 lines**.
- Exclusively-dependent `plugin/*.plg`: `fsmgen, lte_digital_rf, mbist, msword, regtest, rtl`
  = **1,979 lines**. Plus ≈206 lines of phase0 migration-smoke blocks. Total ≈**6,701 lines**.

## Zero dependency from the active `.spec` core

The `.spec` parser/compiler/runtime (`LinkedSpec.pm` + its `LinkedSpec/*` owner tree, `ActionIR/*`,
`BootstrapSpec/Core`, `LinkedRE`, `PathSearch`) has **no functional dependency** on these modules.
The only `perl/` reference is a **comment** (`perl/LinkedSpec.pm:246`); `tools/gen_oracle_corpus.pl:31`
is also a comment. No shipped `specs/*.spec` and nothing in `bin/` reference them.

## Direction: retire, don't fix

Per the user doctrine [[feedback_keep-only-portable-cross-variant]] this subsystem is
non-portable Perl-only legacy = retirement debt. Retiring it (owned by `LEGACY-VHDL-RETIRE`)
**also clears the hang**, which is the gate blocking the `SPEC-FORMAT-TERSE` implementation
leaves (`.1.x`+). Patching the regex in soon-deleted code is the wrong move. Removal scope is
confirmed with the user before any deletion. (Distinct from the [[andplusplus-lx-parser-hang]],
a separate spec.spec self-parse hang.)
