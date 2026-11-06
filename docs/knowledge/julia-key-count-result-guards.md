---
id: julia-key-count-result-guards
title: Julia CountKeys guards numeric results while preserving scalar and mutation boundaries
answers:
  - "how does Julia guard ordinary CountKeys result continuations"
  - "why must Julia initial CountKeys permission exclude free Count ownership"
  - "can Julia count results regain CountKeys initial zero or run with bodies"
  - "why does Julia false count_keys remain null while free false returns zero"
  - "does Julia key-count guarding change scalar_result or Count permission"
  - "does Julia CountKeys repair preserve call_index mutation restrictions"
  - "must Julia CountKeys emitted modules be regenerated"
date: 2026-11-06
status: bounded Julia75.4 implemented with focused checks; independent peer Count ownership75.7 and installed Lua/callable/admission pending
tags: [julia, count_keys, count, guards, scalar, mutation, copy, logical, with]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.75.4; docs/checkpoints/key-count-guard-julia-2026-11-06/REVIEW.md retains actual declared first inputs/modules/full raw phases. Unchanged22 groups10PASS12RED become22PASS/four routes, ten healthy exact,22 modules/parsed inputs unchanged; current25/final346/strict depwarn and six original/four extra recovery corruptions pass."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error julia/test/key_count_result_guard_composition_test.jl"
  - "bash tools/run_python_project_data.sh docs/checkpoints/key-count-guard-julia-2026-11-06/review_ownership.py"
---

Canonical positional free-one/zero-extra CountKeys roles join existing common
kind ownership before Count initial-source permission. Produced Number/zero
rejects incompatible Array/Hash consumers before operands/later copy/logical/
with. A distinct first-step KeyCount permission skips only common guard;
scalar_result initialization/assignments/scalar guard and Count permission stay
exact. Retain enumerate/call_index and its separate Array-end mutation gate.
Producers/domains/signatures/copy/functions/parser/schema stay unchanged.

Independent four-route domain is free[0,0,0,0,0,0,2], receiver
[0,0,null,0,0,0,2]. count_keys(false)=0 while false.count_keys() remains null;
this slice preserves Julia's observed scalar policy without normalizing another
backend. Native/restored diagnostic/class and generated error wrapper stay exact.
Unchanged22 groups10PASS12RED become22PASS; all ten healthy observations remain
exact. Actual22 emitted module texts and parsed inputs are unchanged.

Current126/Count-length6/Count guards92/Length122=346 assertions pass with strict
depwarn and empty stderr; one normal runner include. Six original and four additional effective recovery
corruptions reject. Rebuild Julia applications/runtime; no generated-format or
source-regeneration change. Historical source recovery is not latest-code proof.

Actual declared direct source/manifest/fixture/writer/wrapper inputs and pre-run
modules/parsed inputs recover byte/mode-exactly, with full raw channels retained.
Fresh Modules share process/runtime. No host-seeding claim follows from the
seeded_hash label. Complete native/transitive custody4.2/general isolation/
source-context discovery4.1/callable75.6/full23.4 remain separate. Current frontier
belongs to MEMORY.md.

The first candidate's initial KeyCount permission still admitted free Count-owned
Numbers: count([1]).count_keys() returned0 and a later with body ran. Separate
three-program/four-route proof retains two actual REDs and one healthy initial-
source profile. Excluding the canonical free Count role from that permission
repairs both while preserving receiver Count rejection and initial Number zero.
Maintained25 programs pass126 assertions; all25 module/parsed bodies are unchanged.
Original22 proof/producer patch stay immutable; current-producer patch and separate
ownership/final-current epochs retain the exact single-predicate correction.
Historical readonly review is not latest-source proof. Independently assess
landed Rust/Dart permissions under P175.7 before remaining installed Lua75.5;
no peer defect is inferred from Julia's result.
