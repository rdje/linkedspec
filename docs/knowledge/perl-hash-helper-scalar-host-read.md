---
id: perl-hash-helper-scalar-host-read
title: Perl pure Hash helper scalar sources can read an unrelated main Hash
answers:
  - "why does merge_hash with Number3 include unrelated host data"
  - "can set_key rename_key drop_keys or pick_keys read main Hash3"
  - "which task repairs scalar source host reads before Hash helper composition"
  - "does a ready merge_hash extra operand mean other extra shapes are ready"
  - "what initial source policies must Perl Hash helper guard repairs preserve"
date: 2026-11-07
status: ten localized source defects confirmed; immediate P1 source repair77.0 pending
tags: [perl, hash, source, isolation, helpers, preflight]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.77.1.0; hash-value-result-guard-perl-2026-11-07/PREFLIGHT.md retains actual76 (unchanged28/shared15 failures plus48 own policies), actual ten reused Number3 sources under three localized host states and86 actual artifact pairs. All ten native/fresh results read main::3 only when populated; empty/outer controls and unchanged host maps distinguish the cause. First readonly recovery/eight corruptions PASS; SDK unchanged."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/hash-value-result-guard-perl-2026-11-07/review_preflight.py"
---

Actual public substitution/handler shows non-reference scalar dereference into
Hash data. MethodLowering.pm8339/8374/8404/8438/8470 tests defined alone for pure
merge_hash/set_key/rename_key/drop_keys/pick_keys producers, so Number3 resolves
unrelated main::3 on both native/fresh execution. Localized empty/outer/main
controls on each free/receiver source distinguish this from a DSL working Hash
or outer loader namespace. Host maps stay unchanged. P1 child77.0 precedes
composition77.1.1; the preflight makes no production change.

Forty-eight independently acquired own clean-host fences retain Number3/null
fallback Hashes, Array[1] errors, null-with W and produced-size guards. Extra
merge remains ready1/SAW; extra set/rename and zero-key drop/pick remain unready.
Preserve these differences and producer/source/operand/copy/mutation boundaries;
do not freeze the exposed host dependency as legitimate policy or infer peers.
Historical readonly recovery is not the latest fixed-product verdict. Broader
SESSION17 isolation, native-transitive custody and full23.4 remain open.
