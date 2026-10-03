---
id: historical-objective-audit-input-recovery
title: Historical objective audit hashes retained local logs without establishing their recovery
answers:
  - "can a fresh checkout recover the historical objective audit input logs"
  - "does a retained log hash prove archival recovery"
  - "why is the historical objective audit durability leg a gap"
  - "which task owns the 134 objective audit artifact inputs"
  - "why did normalization mode proof need an ignored audit report"
  - "what is the exact historical audit artifact population and recovery format"
date: 2026-10-03
status: P1 bounded input recovery owned by SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2
tags: [claims, durability, artifacts, historical-audit, input-coverage]
evidence: "The .0.4.1 author review follows verify_objectives.py's actual read(log) hash loop. Its134 local artifact inputs total84,613,241 bytes; the selected24 checkpoints total214,367 bytes. Concrete context-lua-storage.log is501 bytes, has no Git path history and its actual TAP timing line is absent from those selected checkpoints. The new audit capture records hashes without complete byte recovery. This is a new-claim coverage gap, not blanket classification of all earlier proof. The normalization-only public review consumes no legacy log and writes no tracked file. .0.4.2 must verify selected recovery before bridge parent closure."
reverify:
  - "bash tools/run_python_project_data.sh tests/language-readiness/verify_objectives.py (requires retained historical artifact inputs)"
  - "Inspect docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-verification.json historical_audit_input_coverage and the source-bound reviewer."
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-mode-replay-proof.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0-census.py"
---

The audit treats134 ignored local logs as inputs and checks their exact historical
SHA256 values. A map of those hashes is an integrity record, not a recovered byte
archive. Re-running a timing-bearing producer need not recreate the original log
bytes. The draft .0.4.1 combined claim therefore overstated its checked durability
leg even though its actual audit and normalization executions passed.

The corrected claim separates fully retained seven-case normalization proof from
the historical audit measurement and declares the latter leg3 gap. A read-only
`--normalization-only` reviewer checks current source/oracle/runtime observations,
governance and direct dependents without reading the legacy artifacts. The full
snapshot writer still records the actual local audit and its disclosure.

An additional `.0.4.1` replay defect affected the mode-denial instrument: its
snapshot check read an ignored intermediate audit report before reaching the
legacy-log guard. The declared normalization replay omits that audit producer.
Actual missing-report denial reproduces the failure in the retained original
instrument (`-mode-proof-before.py`, SHA256 `9d186b46847aa51ec6e4cc031528f67faad3786dd9ce7b8c5fbfd56e6b20d94b`).
The repaired instrument recovers the report's structured data in memory from
the tracked verification capture. `-mode-replay-proof.py` verifies original RED
and repaired GREEN with zero original-report reads; neither control changes an
original artifact or tracked capture. This metadata recovery does not recover
the134 original log byte streams or close their separate `.0.4.2` owner.

P1 `.0.4.2` inventories existing coverage before classifying individual gaps, retains
only the required observation inputs through a bounded repository-volume format,
and verifies exact hashes and safe isolated recovery. Operational paths stay
repository-relative; observed trace strings must never become filesystem locations.
Historical inputs/results/hashes remain unchanged, existing raw logs stay retained,
and historical writers must not run in the current checkout. Broader constants,
producer and claim auditing remains startup5/29. No claim is made here that every
earlier proof is unreproducible or that no possible archival source exists.

The `.4.2.0` read-only census independently reconstructs 48/39/47 milestone entries
and requires exact equality with the committed 134-member audit map. All old hashes
match. Raw bytes total 84,613,241; independent zlib1.2.12 level9 sizing totals
3,394,928. The 24 selected checkpoints total 214,367 bytes and provide zero complete
log identities among whole bytes, decoded UTF-8 strings and joined string arrays.
The three selected tracked surfaces have no common archive-extension member.
Other encodings and surfaces remain unassessed. Actual byte corruption, removed
membership, changed identity and three outside paths reject through healthy validators.

The source-bound capture and bounded plan live at
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0-verification.json` and
`docs/language-readiness/historical-audit-artifact-recovery.md`. `.4.2.1` implements
the closed deterministic ZIP/manifest, safe isolated restoration and historical
audit replay under original-input-read denial. Census does not close byte recovery.
