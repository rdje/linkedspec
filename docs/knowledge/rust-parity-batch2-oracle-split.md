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
evidence: "RUST-PARITY.7.3.1 split the remaining/harder shipped-spec oracle batch after reading docs/tasks/RUST-PARITY.md, tools/gen_oracle_corpus.pl, rust/linkedspec-runtime/tests/corpus/README.md, rust/linkedspec-runtime/tests/corpus_oracle.rs, TOOLBOX.md, and the rust-perl-output-oracle Knowledge Map card. The generator already has the hard alarm timeout, the corpus is green over 65 fixtures after .7.2, and .7.2 recorded concrete divergences for portmap, lib_reader, ebnf, BNF, DT, ifelse, operators_try, and spec.spec smokes. After the user directed timeout debugging instead of treating the timeout as a vague guard, the split leaves are .7.3.2 trace-first timeout/hang investigation, .7.3.3 hlink_substitution delimiter/link paths, .7.3.4 portmap/lib_reader/ebnf structural divergence triage, .7.3.5 BNF/DT/ifelse/operators_try/spec.spec null-output or action-parser-warning triage, and .7.3.6 post-timeout RTL/plugin/legacy safety smoke."
reverify: "rg -n 'RUST-PARITY\\.7\\.3\\.[1-6]|timeout/hang|hlink_substitution|portmap|lib_reader|operators_try|RTL/plugin/legacy' docs/tasks/RUST-PARITY.md docs/TASK_TREE.md"
---

# RUST-PARITY.7.3 Batch-2 Oracle Split

**Confirmed 2026-07-03 (`RUST-PARITY.7.3.1`).** The remaining shipped-spec
oracle expansion is intentionally not one implementation slice. It mixes several
different risk classes: a timeout/hang question that must be proven first,
hlink delimiter/link-path fixtures, already-recorded simple-spec structural
mismatches, null-output or action-parser warning cases, and legacy/RTL/plugin-
adjacent specs that should not proceed until timeout wording is current.

The current frontier is `RUST-PARITY.7.3.2`: debug the referenced timeout/hang
risk first with LinkedSpec's own toolbox. For a true hang, use the fork+SIGKILL
hard-timeout census before trace because `alarm()` cannot interrupt a
catastrophic regex opcode. Once there is a live reproducer/rule path, use
`LINKEDSPEC_TRACE_LEVEL=debug`, per-call trace options, and parser-source dumps
to pinpoint source/rule/regex evidence. If the historical `RTLUtils` timeout is
stale after retirement/quarantine, update the generator/corpus/task/KM wording
to say so while keeping a generic guard.

The later lanes are:

- `.7.3.3`: remaining `hlink_substitution` delimiter/link-path fixtures.
- `.7.3.4`: `portmap`, `lib_reader`, and `ebnf` structural divergence triage.
- `.7.3.5`: `BNF`, `DT`, `ifelse`, `operators_try`, and `spec.spec` null-output
  or action-parser-warning triage.
- `.7.3.6`: `pplugin`, `vhdl`, `simenv`, `tablegrep`, `sdce`, `regdef`,
  `tkgui`, `ds_vhistory`, and `verilog` safety smoke after `.7.3.2` has
  resolved or retired the timeout/hang concern.
