---
id: selected-consumer-proof-input-closure-gap
title: Selected passing consumer transcripts need transitive inputs and a stable document boundary
answers:
  - "does a selected suite file hash bind all Phase0 artifact inputs"
  - "which inputs were omitted by the basic regex proof publisher"
  - "can continuity publishing change Phase0 input bytes after its run"
  - "who owns the selected consumer and book proof input closure repair"
date: 2026-10-04
status: P1 repair pending under SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3
tags: [claims, evidence, provenance, phase0, documentation, input-closure]
evidence: "The final .1.1.0 review preserves the original claim/publisher as claim-initial.json/.py, separates the complete private/compiler measurement from consumer/render observations, and discloses broader falsification/durability gaps with an immediate P1 repair. The actual passing TAP and render streams are unchanged."
reverify: "Read the source-backed selected input graph and actual remeasurement under .1.1.3 when it lands; initial producer/claim and observed streams remain under docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-. Do not refresh their input hashes as if they captured a newer run."
---

# Selected passing consumer transcripts need transitive inputs and a stable document boundary

The initial regex proof publisher binds regular Perl/spec files, selected suite
files, tools and the affected book chapter/configuration. That covers the bounded
private source-position/compiler observations but does not close all inputs of
the broader consumer/render result.

Phase0 discovers conf, tablescript and EBNF corpus files, reads contract JSON and
fixtures, executes nested Perl consumers and scans root/book Markdown. Generated
source tests read examples. The book compiler reads other book source files.
Continuity publishing after the captured suite run changes some root Markdown;
the exact bytes at each original read were not separately retained. The passing
transcripts remain actual observations, but missing hashes cannot simply be
filled with today's bytes and labeled the original measurement.

The new claim records the broad result with explicit falsification and durability
gaps. `.1.1.3` owns the selected graph/census, producer/input retention, stable
publication boundary, actual distinguishing controls and recovery or remeasurement
where needed. It runs before basic statement framing. The larger prior-record
producer audit remains with `SESSION-STARTUP-READING.5`; this finding does not close
that audit or retroactively repair older records.
