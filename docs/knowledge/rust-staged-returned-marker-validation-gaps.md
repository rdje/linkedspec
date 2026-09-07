---
id: rust-staged-returned-marker-validation-gaps
title: Returned Rust staged markers bypass deep result checks and can overflow provenance extent
answers:
  - "does Rust deeply validate forbidden result keys inside returned staged markers"
  - "why can Rust staged derived provenance panic in strictly_decreases"
  - "which task repairs returned staged marker validation and provenance arithmetic"
date: 2026-09-07
status: native debug counterexamples measured; repair pending under SESSION-STARTUP-READING.74
tags: [rust, staged-parsing, provenance, validation, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.37 public host API probes, ordinary-record controls and native backtrace isolate marker detachment and unchecked extent summation."
reverify:
  - "bash tools/project_data_run.sh env RUST_BACKTRACE=1 .linkedspec-data/scratch/startup96-staged-boundaries/probe .linkedspec-data/scratch/startup96-staged-boundaries/validation-controls"
---

# Marker recognition precedes deep result validation

The outer job parses abcdef; a callback returns a child marker for b at source interval [1,2).
The valid control succeeds after one callback for current-depth enrichment and two for recursive enrichment.
Adding the forbidden key host with a synthetic plain object inside the returned marker sidecar also succeeds:
current depth publishes that marker and recursive mode completes b after two callbacks.
An ordinary returned object containing the same host key instead returns staged_result_not_detached/host in
both modes after one callback. No actual host pointer or external service is involved: all values are JSON.

staged_ast_enrichment.rs detach_plain counts a marker as one node and immediately clones it (2350–2352),
before the ordinary object key recursion. Atomic accounting need not mean unchecked contents.
ADR0088 429–444 records the Julia precedent: recursively inspect marker records for forbidden/live data while
retaining atomic node accounting. Rust marker_sidecar/preparation do not repair this omission later.

# Invalid derived extents reach unchecked recursive arithmetic

A second child marker has text b but two direct segments [0,u64::MAX), same synthetic source identity.
Current-depth enrichment accepts it after the outer callback. Recursive enrichment panics before callback two.
The probe catches that panic outside the public enrichment API; process exit 0 is therefore not product success.
A repeated diagnostic run with RUST_BACKTRACE=1 identifies strictly_decreases at line 2121, called by
static_chain_diagnostic at 2043, prepare_plan at 1531 and enrich_recursively at 1220/1228.
The source sums child extents with sum::<u64>() before checking containment; the two lengths overflow.
Provenance segments validate individual integer ordering but not the aggregate or text consistency first.
Related rebase_position/rebase_span arithmetic belongs in .74's audit; no new measured failure is claimed there.

Repair .74 requires deep marker validation, checked extent/rebase arithmetic and typed rejection without panic,
with valid controls, failure policies, carriers and book alignment after required reading.
This measurement uses existing debug libraries; release overflow behavior and other backends are not measured.
The diagnostic six-record run completes in 0.029 seconds; the complete artifact/assertion manifest and library
hashes are indexed in `staged-target-preparation-gaps.md`. No generated corpus or runtime file is changed here.

## September 7 declaration boundary reconciliation

The next reading checkpoint `SESSION-STARTUP-READING.3.3.38` completes staged_parse_job.rs.
Its public validate_and_materialize_provenance obtains source-authorized positions/spans and exact materialized
text; the private constructor always uses it. Those source checks are absent from the already-measured returned
JSON path. .74 must define the required validation at that host boundary without weakening the declaration
constructor or pretending a detached marker alone supplies a live source snapshot.

## September 7 preserved-probe scope clarification

`SESSION-STARTUP-READING.3.3.39` clarifies the reverify commands above: invoking the preserved native
probe reruns the runtime statically linked during `.3.3.37`. It does not test a subsequently rebuilt or
repaired runtime. Current-source or repair proof must rebuild the probe against newly verified managed
libraries and record their identities before rerunning the controls. The original measurements and
pending repair ownership remain unchanged.
