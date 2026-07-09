---
id: noncurrent-helper-code-purge-inventory
title: Non-current helper spelling purge is split across Perl source, Rust source, tests, tools, and specs
answers:
  - what owns removing non-current helper spellings from Perl and Rust code
  - where do non-current helper spelling references remain
  - why is the Perl Rust helper purge split
  - what is the next leaf for non-current helper code cleanup
date: 2026-07-09
status: current
tags: [task-tree, helper-surface, perl, rust, tests, tools, specs, NONCURRENT-HELPER-CODE-PURGE]
evidence: "NONCURRENT-HELPER-CODE-PURGE.1 created docs/tasks/NONCURRENT-HELPER-CODE-PURGE.md after the director clarified that non-current helper spellings must be deleted from Perl/Rust code surfaces. Read-only scans found owner categories in Perl ActionIR source, Rust runtime source, active tests, tooling, oracle-generation paths, and checked-in specs. The same scans also showed common-word false positives, so the purge is split into context-aware leaves rather than a blind replacement. NONCURRENT-HELPER-CODE-PURGE.2.1 then removed Perl current-helper normalization through old string/copy/assignment names, removed the removed append-helper contract/scanner/lowering paths from touched Perl owners, removed deleted current-helper-family names from the bootstrap return-payload classifier, and passed phase0 1..1028; declaration/return/wrapper and metadata remnants remain queued under .2.2/.2.3."
reverify: "rg -n '_retired|retired_helper|legacy helper|LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER' perl rust t tools specs"
---

`docs/tasks/NONCURRENT-HELPER-CODE-PURGE.md` owns the Perl/Rust code purge.

The inventory leaf split the work because the remaining references are not one
homogeneous implementation table. They include:

- Perl ActionIR recognition and diagnostic source paths.
- Rust runtime/parser diagnostic source paths.
- Active Perl and Rust test strings.
- Tooling and oracle-generation fixture text.
- Checked-in `.spec` labels or output strings that collide with the removed
  helper surface.

`NONCURRENT-HELPER-CODE-PURGE.2.1` closed the first executable Perl slice:
current string/copy/assignment/append behavior stays on current helper names,
the removed append-helper branch is gone from the touched source owners, the
bootstrap classifier no longer accepts deleted current-helper-family spellings,
and phase0 passes `1..1028`.

The next executable leaf is `NONCURRENT-HELPER-CODE-PURGE.2.2`: remove Perl
declaration, return-family, and wrapper source-owner paths while preserving
current return, `return_undef`, auto-existing variable, assignment/reset,
`array(...)`, `hash(...)`, and bare-read behavior.

Related facts: [[legacy-helper-retirement-split-inventory]],
[[dart-actionir-contract-resolver]], [[terse-declaration-helper-compatibility-policy]].
