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
evidence: "git grep sweep + module inspection + pristine-HEAD worktree run 2026-06-18 (LEGACY-VHDL-RETIRE.1/.2/.3). Hang confirmed at the add_header smoke (subtest 110); subsystem retired; a second pre-existing back-half hang (HTML::PathLinks::link_path_tokens, subtest 131) found — both now RESOLVED (see Resolution): NONCORE-QUARANTINE.3 relocated HTML::PathLinks to noncore/ + excised its smoke; PHASE0-BACKHALF-TRIAGE took phase0 to 960/960 green (2026-06-22)."
reverify: "! test -e perl/RTLUtils.pm && ! test -e perl/FSMGen.pm && echo 'subsystem retired (LEGACY-VHDL-RETIRE)'   # RESOLVED 2026-06-22: phase0 now 960/960 green end-to-end (PHASE0-BACKHALF-TRIAGE); subtest-131 HTML::PathLinks smoke excised by NONCORE-QUARANTINE.3"
---

# `RTLUTILS-REGEX-HANG` and the legacy VHDL/RTL/FSM subsystem

`t/phase0_regression.t` hangs because of a **catastrophic-backtracking regex** in the
**Perl-only legacy VHDL/RTL/FSM-generation subsystem**, not anywhere in the active `.spec`
engine.

## The hang (corrected 2026-06-18 via a pristine-HEAD worktree run)

- The hang is in **`RTLUtils::add_header_n_context_clause`** — confirmed by running the pristine
  HEAD `t/phase0_regression.t` in a detached worktree with a timeout: subtest 109
  `rtlutils_drive_entity_component_uses_header_package_owner` completes (ok), and it **hangs at
  subtest 110 `rtlutils_header_context_clause_package_owner_preserves_payload`**.
- Root cause: that smoke test passes a **recursive** `add_package_re`
  (`([[:alpha:]]\w+)(?:\.((?1)))?$`), which `add_header_n_context_clause` applies at
  **`perl/RTLUtils.pm:104`** (`map { m/$add_package_re/o } …`); the `(?1)` recursion + `$` anchor
  backtracks catastrophically.
- **The original attribution (`add_header_n_context_clause`) was correct.** A `LEGACY-VHDL-RETIRE.1`
  note that "corrected" it to `RTLUtils.pm:746` / `drive_entity_component` was itself **wrong** —
  subtest 109 (`drive_entity_component`) completes; line 746's regex does not hang on the test input.

## A SECOND, pre-existing back-half hang (unmasked by removing the first)

Removing the RTLUtils hang (subtest 110) revealed that the **entire back half of phase0 (subtests
111+) had never executed** while the hang stood — and it has its own pre-existing problems,
unrelated to this subsystem:

- **`HTML::PathLinks::link_path_tokens(...)` hangs** (subtest 131
  `html_path_link_owner_avoids_pplugin_and_preserves_link_wrapping_contract`) — a separate
  catastrophic regex. `require HTML::PathLinks` / `require HTTP::FileAccess` load fine and fast; the
  **call** to `link_path_tokens` hangs (the subprocess is alarm-killed → that subtest fails 3/7).
  HTML::PathLinks depends only on **kept** modules (Global, HTTP::FileAccess,
  Text::VariableSubstitution), so this is **not** caused by the VHDL retirement.
- So clearing the RTLUtils hang is **necessary but not sufficient** for a green phase0; the back
  half needs its own fix track.

## Resolution (2026-06-22 — phase0 is now green end-to-end)

Both hangs are cleared and the back half is green:

- The **subtest-131 `HTML::PathLinks::link_path_tokens` hang is moot** — `NONCORE-QUARANTINE.3` relocated
  `HTML::PathLinks` (with the rest of the non-core domain island) to `noncore/` and **excised its
  migration-smoke subtest**, so phase0 reaches green without ever needing an `HTML::PathLinks` regex fix.
- The **back-half fix track is `PHASE0-BACKHALF-TRIAGE`** — it triaged the 173 pre-existing failures
  (108 STALE re-blessed TEST-ONLY + 2 user-authorized engine defects fixed, ADR `0008`) and resolved the
  `corpus_regression`/dark-tail tail. **`t/phase0_regression.t` is now 960/960 GREEN end-to-end** and
  `bash tools/run_ci_local.sh` exits **0**. The `SPEC-FORMAT-TERSE` implementation gate this card blocked
  is therefore **cleared** (its `.1.x`+ leaves are now PNT-eligible).

## The subsystem (Perl-only, no Rust/Dart/Julia/Lua counterpart)

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
