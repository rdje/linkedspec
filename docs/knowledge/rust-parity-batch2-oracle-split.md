---
id: rust-parity-batch2-oracle-split
title: RUST-PARITY.7.3 batch-2 oracle expansion is split and closed; timeout, hlink, structural, null-output/spec-smoke, and RTL/plugin/legacy lanes are complete
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
date: 2026-07-04
status: confirmed
tags: [rust, oracle, corpus, parity, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.7.3.1 split the remaining/harder shipped-spec oracle batch after reading docs/tasks/RUST-PARITY.md, tools/gen_oracle_corpus.pl, rust/linkedspec-runtime/tests/corpus/README.md, rust/linkedspec-runtime/tests/corpus_oracle.rs, TOOLBOX.md, and the rust-perl-output-oracle Knowledge Map card. The corpus was green over 65 fixtures after .7.2, and .7.2 recorded concrete divergences for portmap, lib_reader, ebnf, BNF, DT, ifelse, operators_try, and spec.spec smokes. After the user directed timeout debugging instead of treating the timeout as a vague guard, the split leaves became .7.3.2 trace-first timeout/hang investigation, .7.3.3 hlink_substitution delimiter/link paths, .7.3.4 portmap/lib_reader/ebnf structural divergence triage, .7.3.5 BNF/DT/ifelse/operators_try/spec.spec null-output or action-parser-warning triage, and .7.3.6 post-timeout RTL/plugin/legacy safety smoke. RUST-PARITY.7.3.2 then verified the historic RTLUtils timeout is retired and hardened gen_oracle_corpus with per-case fork/SIGKILL timeouts. RUST-PARITY.7.3.3.1 split hlink delimiter work after bracket outputs exposed the scalar-ref JSON gap. RUST-PARITY.7.3.3.2 added the JSON-safe {abc} fixture, raising the corpus to 66. RUST-PARITY.7.3.3.3 deferred bracket/mixed hlink fixtures to .7.3.3.4 because Perl scalar refs cannot be JSON-encoded and Rust cannot currently execute the scalar-ref action branch. RUST-PARITY.7.3.4 closed portmap/lib_reader/ebnf through implementation subleaves and raised the corpus to 77. RUST-PARITY.7.3.5 closed null-output/spec smoke triage: BNF/DT/ifelse/operators_try representative inputs are Perl null diagnostic cases, operators_try quoted-brace warnings are fixed, four spec.spec smokes are active, and the corpus is 81 fixtures. RUST-PARITY.7.3.6 added seven RTL/plugin/legacy safety smokes and routed richer mismatches to follow-up instead of promoting unsafe fixtures; the corpus is 88 fixtures. RUST-PARITY.7.4 then finalized the manifest-backed oracle corpus guard, closing .7 and advancing the frontier to .8."
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
`RUST-PARITY.7.3.3.2` added the JSON-safe `{abc}` curly fixture with the
hardened oracle guard in place. `RUST-PARITY.7.3.3.3` then deferred bracket and
mixed hlink fixtures because they require a neutral scalar-ref/action-payload
contract or a hlink spec migration. `RUST-PARITY.7.3.6` then added seven
RTL/plugin/legacy safety smokes and left the richer mismatches as explicit
follow-up blockers. `RUST-PARITY.7.4` finalized the manifest-backed regression
guard. `RUST-PARITY.8.1` then split the broad code-generation emitter lane, so
the current frontier is `RUST-PARITY.8.2`: minimal Rust source-emitter scaffold
plus compile/run harness.

The later lanes are:

- `.7.3.3.2`: done — JSON-safe `hlink_substitution` curly-brace fixture.
- `.7.3.3.3`: done — scalar-ref representation decision deferred bracket/mixed
  fixtures with Perl JSON failure and Rust action-branch evidence.
- `.7.3.3.4`: deferred — neutral scalar-ref/action-payload contract or hlink
  spec migration before bracket/mixed fixtures.
- `.7.3.4`: done — `portmap`, `lib_reader`, and `ebnf` structural divergence triage closed through
  implementation subleaves and active oracle fixtures.
- `.7.3.5`: done — `BNF`, `DT`, `ifelse`, and `operators_try` probed inputs are diagnostic Perl-null cases;
  quoted-brace `operators_try` warnings are fixed; four `spec.spec` smokes are active.
- `.7.3.6`: done — seven green `pplugin`, `vhdl`, `simenv`, `tablegrep`, `regdef`,
  `tkgui`, and `ds_vhistory` safety smokes entered the corpus; richer `pplugin`,
  `tkgui`, `sdce`, recursive `tablegrep`, `simenv`, VHDL, `ds_vhistory`, and
  `verilog` candidates remain follow-up blockers.
- `.7.4`: done — regression guard and oracle corpus finalization.
- `.8.1`: done — code-generation emitter lane split/inventory.
- `.8.2`: current frontier — minimal generated Rust-source scaffold plus compile/run harness.
