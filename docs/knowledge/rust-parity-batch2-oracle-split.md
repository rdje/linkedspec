---
id: rust-parity-batch2-oracle-split
title: RUST-PARITY.7.3 batch-2 oracle expansion is split with timeout debugging first
answers:
  - "how is RUST-PARITY.7.3 split"
  - "what is the next RUST-PARITY.7.3 task"
  - "which leaf owns timeout hang debugging in RUST-PARITY.7.3"
  - "which leaf owns RTLUtils timeout audit"
  - "which leaf owns remaining hlink_substitution oracle fixtures"
  - "which leaf owns portmap lib_reader ebnf oracle divergences"
  - "which leaf owns BNF DT ifelse operators_try spec.spec oracle divergences"
  - "which leaf owns RTL plugin legacy shipped-spec oracle smokes"
  - "why is RUST-PARITY.7.3 not one large implementation slice"
date: 2026-07-03
status: confirmed
tags: [rust, oracle, corpus, parity, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.7.3.1 split the remaining/harder shipped-spec oracle batch after reading docs/tasks/RUST-PARITY.md, tools/gen_oracle_corpus.pl, rust/linkedspec-runtime/tests/corpus/README.md, rust/linkedspec-runtime/tests/corpus_oracle.rs, TOOLBOX.md, and the rust-perl-output-oracle Knowledge Map card. The corpus is green over 65 fixtures after .7.2, and .7.2 recorded concrete divergences for portmap, lib_reader, ebnf, BNF, DT, ifelse, operators_try, and spec.spec smokes. After the user directed timeout debugging instead of treating the timeout as a vague guard, the split leaves became .7.3.2 trace-first timeout/hang investigation, .7.3.3 hlink_substitution delimiter/link paths, .7.3.4 portmap/lib_reader/ebnf structural divergence triage, .7.3.5 BNF/DT/ifelse/operators_try/spec.spec null-output or action-parser-warning triage, and .7.3.6 post-timeout RTL/plugin/legacy safety smoke. RUST-PARITY.7.3.2 then verified the historic RTLUtils timeout is retired and hardened gen_oracle_corpus with per-case fork/SIGKILL timeouts. RUST-PARITY.7.3.3.1 split hlink delimiter work after bracket outputs exposed the scalar-ref JSON gap, so the current frontier is .7.3.3.2."
reverify: "rg -n 'RUST-PARITY\\.7\\.3\\.[1-6]|timeout/hang|hlink_substitution|portmap|lib_reader|operators_try|RTL/plugin/legacy' docs/tasks/RUST-PARITY.md docs/TASK_TREE.md"
---

# RUST-PARITY.7.3 Batch-2 Oracle Split

**Confirmed 2026-07-03 (`RUST-PARITY.7.3.1`).** The remaining shipped-spec
oracle expansion is intentionally not one implementation slice. It mixes several
different risk classes: a timeout/hang question that must be proven first,
hlink delimiter/link-path fixtures, already-recorded simple-spec structural
mismatches, null-output or action-parser warning cases, and legacy/RTL/plugin-
adjacent specs that should not proceed until timeout wording is current.

`RUST-PARITY.7.3.2` is done: the historical `RTLUtils` timeout is retired from
the current core tree, and `tools/gen_oracle_corpus.pl` now enforces its generic
timeout with per-case fork/SIGKILL instead of `alarm()`. `RUST-PARITY.7.3.3.1`
is also done: hlink delimiter candidates are split by JSON representability.
The current frontier is `RUST-PARITY.7.3.3.2`: add the JSON-safe `{abc}` curly
fixture with the hardened oracle guard in place.

The later lanes are:

- `.7.3.3.2`: JSON-safe `hlink_substitution` curly-brace fixture.
- `.7.3.3.3`: scalar-ref representation decision for `hlink_substitution`
  bracket/mixed fixtures.
- `.7.3.4`: `portmap`, `lib_reader`, and `ebnf` structural divergence triage.
- `.7.3.5`: `BNF`, `DT`, `ifelse`, `operators_try`, and `spec.spec` null-output
  or action-parser-warning triage.
- `.7.3.6`: `pplugin`, `vhdl`, `simenv`, `tablegrep`, `sdce`, `regdef`,
  `tkgui`, `ds_vhistory`, and `verilog` safety smoke after `.7.3.2` has
  resolved or retired the timeout/hang concern.
