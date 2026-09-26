---
id: rgx-bootstrap-published-remedy
title: "Published RGX f6e5acdc passes LS-004 public failure and bootstrap controls; retained adoption is pending"
answers:
  - "which published RGX revision passed LS-004 failure success and reuse on September26"
  - "can LS-004 be called fixed at LinkedSpec retained RGX pin"
  - "why does adopting the LS-004 remedy require director authorization"
  - "what remains after public bootstrap remedy verification"
date: 2026-09-26
status: upstream public remedy verified; retained pin adoption required under RGX-CONSUMER-BUILD-REPORTS.1.2
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

LinkedSpec still pins `8763a0e6bea97879f027237439d57725f83ead23`, where the same
failure prints misleading success. The director's section20 and AGENTS forbid
pin changes without an explicit exception. Required `.1.2` owns authorized
adoption, native consumer compatibility and exact canonical proof. No pin update,
downstream application acceptance or new publication is claimed by `.1.1`.
The director will notify ARCHOGEN only after the retained checkout is fixed.

The supplied ARCHOGEN/SEMULITH snapshots remain byte-exact. Live remote main is
still `a8d34c845`, containing all eight recorded related fix/admission references.
All three SEMULITH remedies are published; their opt-in document-parser adoption
requirements remain unchanged. [[consumer-report-fix-commits]] owns that ledger.

The first current-version public command spent5044.794s including transitive
checkout initialization, including a large LLVM transfer visible in public output.
This is a dated preparation observation, not an implementation-derived dependency
procedure or future timing guarantee. All storage was repository-local; public
Cargo cache copy was verified byte-for-byte and no old compiled outputs were reused.
