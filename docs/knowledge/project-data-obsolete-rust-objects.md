---
id: project-data-obsolete-rust-objects
title: The saved pre-adoption Cargo target contains obsolete compiler objects beside retained executables
answers:
  - "why was linkedspec data scratch using 232 GB"
  - "which cleanup owns the large old pre-adoption Rust target"
  - "can obsolete pre-adoption rcgu object files be removed"
  - "why does the ad hoc claim checker need claims durability nesting"
  - "did cleanup delete historical executables or the retained RGX repository"
date: 2026-10-30
status: dated cleanup46.2 completed and verified
tags: [artifacts, cleanup, rust, storage, claims, retention]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.46.2; exact adoption producer87-89, current scratch census, per-entry metadata plan, permitted liveness refusal/idle observations, guard controls and current offline Rust test. Final dated disposal/retained-entry review passes; exact producers, metadata and executable inputs are retained."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-operation-inventory/project-data-cleanup46-2/review.py"
---

The September adoption producer moved `rust/target` intact to
`.linkedspec-data/scratch/ls004-adoption26/pre-adoption-rust-target` before a
fresh build. That preservation kept obsolete compiler objects as well as
historical executables. Current supported Cargo work uses `rust/target`.
The old target is a large dated scratch bucket; this does not establish a
dependency implementation cause or a continuing need for every cached object.

Cleanup46.2 selects only direct old `debug/deps/*.rcgu.o` entries that are
regular, non-executable, on the repository volume, single-link, and older than
the adoption boundary. Hardlinked objects and every other entry stay retained.
The adjacent `retained-rgx` Git repository is outside both traversal and mutation.
Quarantine precedes the current public offline Rust rule-call check. Exact
per-file identity guards precede unlink; the retained metadata plan and final
residue review distinguish removal from a merely proposed cleanup.

The initial ad hoc claim lookup used top-level `durability`, while the actual
schema is `claims[].durability`. A nested fixture exposes that false negative;
the corrected complete namespace scan precedes deletion and shared documentation
changes. The temporary staged helper is repaired. The canonical claim validator
already uses the correct schema. The local helper is
`.linkedspec-data/verification/computed-functions-claim-inputs.py`; its accepted
bytes can be recovered from the cleanup checkpoint if needed.
Initial empty discovery earns no proof credit;
this is not an audit of every historical helper invocation.

The new disposal prototype also lacked explicit refusal of `..` before its
lexical containment check. An owned existing-sibling control demonstrates the
initial guard's admission and the corrected guard's rejection before real
mutation. No external source or other repository is touched by this control.
Successful same-user open-file/cwd inspection is required; inspection denial is
not absence. A live inventory process is actually rejected before the later
idle observation. No concurrent adversarial or other-user liveness guarantee
is claimed.

Allocated file metadata is not physical volume space reclaimed. Original
disposable object bytes are intentionally not archived; exact old-build
reproduction is not claimed. Historical executables, source, evidence, package
stores, incremental data and the current warmed target remain available.

## Dated completion

Exactly 330165 selected objects are absent; all 4215917 other direct entries retain their captured identities. The selected metadata sums to 49600550824 logical and 50270818304 allocated bytes. The current offline rule-call target passes six tests with old deps quarantined. Original deps is restored with no quarantine residue. Complete metadata, actual producers, guard epochs and the actual successful test executable are retained in the owning checkpoint.
