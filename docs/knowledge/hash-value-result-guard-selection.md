---
id: hash-value-result-guard-selection
title: Pure Hash-valued helper results need retained-result guard ownership
answers:
  - "why does merge_hash take return empty Array instead of null"
  - "why does a literal Hash pick_keys take chain fail Perl compilation"
  - "why does rejected set_key copy still run with"
  - "which task owns Hash-valued helper result guards"
  - "are zero-key drop_keys and pick_keys admitted canonical forms"
  - "must Hash-valued guard repairs preserve initial source policies"
date: 2026-11-07
status: original selection frozen; bounded Perl source/result repairs focused-checked, peers pending
tags: [hash, helpers, guards, perl, selection, source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.1.37; hash-value-result-selection-2026-11-07/REVIEW.md retains original32, exact shared28 with15 failures/13 healthy controls, four separate unready zero-key profiles,32 actual artifact pairs and eight effective evidence corruptions. No SDK production change or peer verdict."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/hash-value-result-selection-2026-11-07/review.py"
---

At activation795e8c1a, actual public substitution/handler reveals legacy take's
nonarray[] fallback for free pick_keys and raw literal DSL for receiver/composed
needed-error chains. Five free failures, five receiver compile failures, three
later-body failures and two required-producer-error compile failures contrast
with thirteen healthy controls, including constructor rejection and terminal
required errors. MethodLowering.pm's ordinary source/prefix/retained/copy/with
classifications cover constructors/views but omit these pure Hash-valued roles.

Family77 owns ordinary merge_hash/free2/receiver1, set_key/free3/receiver2,
rename_key/free3/receiver2, drop_keys/pick_keys with at least one key. Every backend
first acquires its own unchanged28 and source/arity/error fences; Perl evidence
does not establish peer failures or portable initial-source policy. Four Perl
zero-key profiles remain unready/unresolved, not canonical authority. Preserve
mutation, key splices, copy depth and destination-absent rename controls; existing
collision differences remain FUTURE-PARITY-BACKLOG.5 (the selection REVIEW corrects
one naming typo in the frozen first contract without rewriting its seal).

Reverify recovers historical evidence, not the latest production verdict. No full
context/native-transitive custody/isolation/registration/23.4 admission follows.

Perl source77.0 and result77.1.1 now have separate focused outcomes. See
[[perl-hash-helper-scalar-host-read]] and [[perl-hash-value-result-guards]] for the
precise source policy, actual inverse, healthy preservation and current limits.
The original selection and frozen shared28 remain unchanged; peers assess their
own source/arity/error profiles before implementation.
