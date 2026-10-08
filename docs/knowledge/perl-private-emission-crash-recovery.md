---
id: perl-private-emission-crash-recovery
title: Interrupted private emission draft survives in a Git-bound recovery checkpoint
answers:
  - "where is the private emission draft after the October9 machine crash"
  - "how do I resume SourceEmissions foundation implementation after recovery"
  - "was the recovered private emission foundation accepted"
date: 2026-10-09
status: recovery verified; foundation implementation and acceptance open
tags: [perl, actionir, recovery, source-emission, continuity]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0 reconstructs all eight surviving dirty files, verifies48 original claim bindings, observes six corruption REDs, and restores eight selected production owners byte-exact."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0-review.py"
---

The crash snapshot retains the exact dirty Git delta at immutable activation
`58a11ae80cc55f8d19a0a7a4f0203ae491d11383`, plus complete untracked payloads.
The interrupted memory/task activation and unverified `SourceEmissions.pm` are
recoverable from `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0-crash.json`. Reconstruction uses an isolated
Git index and object store, preserving the real index and current production.

Foundation continuation belongs to
`SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1`.
Follow `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0-handoff.md`; activate that leaf before restoring the
draft and accessor. The saved implementation has no recovered proof harness or
acceptance results. Original independent fragment/callback/invocation oracles,
source inverses, consumers and later full Phase0 obligations remain required.
Only surviving on-disk files are recovered; lost conversation, process memory
and unsaved editor buffers are outside the checkpoint.
