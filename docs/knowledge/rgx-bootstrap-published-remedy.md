---
id: rgx-bootstrap-published-remedy
title: "RGX f6e5acdc supplies the publicly verified LS-004 bootstrap remedy"
answers:
  - "which published RGX revision passed LS-004 failure success and reuse on September26"
  - "can LS-004 be called fixed at LinkedSpec retained RGX pin"
  - "why does adopting the LS-004 remedy require director authorization"
  - "what remains after public bootstrap remedy verification"
date: 2026-09-27
status: remedy adopted and canonically published at fd3e328d5; unauthorized recipient write recorded under .1.3.1; ARCHOGEN verification pending
tags: [consumer-reports, rgx, bootstrap, public-interface, adoption]
evidence: "RGX-CONSUMER-BUILD-REPORTS.1.1: retained failure/reuse; published f6e5acdc two accurate prerequisite failures, fresh bootstrap success and two reuse controls; exact public logs and source/report/cache hashes in docs/checkpoints/RGX-CONSUMER-BUILD-REPORTS.1.1.json. No implementation inspection or pin change."
reverify: "Read docs/upstream/rgx/bootstrap-progress-status.md and the named checkpoint; use only the chosen revision's published docs/INTEGRATION.md and make bootstrap on isolated repository-local storage. Keep fresh failure separate from already-prepared reuse."
---

Published RGX `f6e5acdc99720349d1e3ecef9f821f365c4db19c` stops at the first
missing offline prerequisite, exits2 and prints no later named steps or false
seed-success message. The independent repeat agrees. Fresh normal bootstrap
exits0 with completion; two prepared offline controls exit0 with the documented
no-op. The checkout remains Git-clean. This is public behavioral verification,
not a source-level diagnosis or identification of the individual upstream fix commit.

The older `8763a0e6bea97879f027237439d57725f83ead23` prints misleading success.
After this finding, the director instructed fixing that identified issue and
notifying both the director and ARCHOGEN when done. `.1.2` owns that narrow
RGX pin exception, adoption, native compatibility and exact canonical proof;
`.1.3` owns publication and notification. No dependency source inspection or
patches are authorized. `.1.1` itself changed no pin and claimed no consumer acceptance.

The adopted checkout is the exact Git-clean f6e5acdc source already prepared by
the public command above. The older opaque checkout, all4200 files/251037999 bytes,
its local edits and usable Git metadata are preserved under
`.linkedspec-data/scratch/ls004-adoption26/retained-rgx`; before/after file hashes
and Git statuses agree. The old Rust target is retained separately; the native
build starts with a fresh `rust/target`. Both consumer lockfiles add only the
required typed-arena2.0.2 record and two transitive dependency edges. Source and
target preservation is not a dependency implementation audit.

The supplied ARCHOGEN/SEMULITH snapshots remain byte-exact. At the .1.1 checkpoint,
remote main was `a8d34c845`, containing all eight recorded related fix/admission references.
All three SEMULITH remedies are published; their opt-in document-parser adoption
requirements remain unchanged. [[consumer-report-fix-commits]] owns that ledger.

The first current-version public command spent5044.794s including transitive
checkout initialization, including a large LLVM transfer visible in public output.
This is a dated preparation observation, not an implementation-derived dependency
procedure or future timing guarantee. All storage was repository-local; public
Cargo cache copy was verified byte-for-byte and no old compiled outputs were reused.

## September27 delivery

Adoption `fd3e328d5dd5c80981a1c3b8496a27270291f7b8` passes exact canonical acceptance and is published
with matching remote read-back. The subsequent ARCHOGEN documentation commit was
unauthorized; [[external-repositories-read-only]] records the binding boundary and
[[consumer-report-fix-commits]] separates the technical fixes from that incident.
ARCHOGEN alone owns its repository disposition and downstream verification. Final
LinkedSpec-only parent closeout is .1.3.2, after the committed ownership correction8b5b5ffd8; its exact canonical proof is required before landing.
