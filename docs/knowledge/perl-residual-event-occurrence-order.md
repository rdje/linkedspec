---
id: perl-residual-event-occurrence-order
title: Canonical residual events preserve each pending helper scan occurrence
answers:
  - "what is the deterministic residual scan occurrence contract"
  - "how does canonical replay skip consumed or exclusive helper events"
  - "which regression protects interleaved equal-text canonical events"
  - "does stable canonical order repair quoted or nested raw readiness"
date: 2026-10-03
status: bounded repair; exact staged canonical acceptance required for landing
tags: [perl, actionir, metadata, occurrence, provenance, readiness]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1 retains exact activation owner,27 matched source/seed before/current native-fresh comparisons,15 current traces,11 complete suites/424 top-level TAP tests, the actual Phase0 child and ten observed evidence controls."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1-review.py; env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/canonical_event_occurrence_order.t"
---

CanonicalEvents::_build_canonical_action_ir_events keeps an ordered raw-key/canonical-reference
sequence while filling its existing queues. After authored top-level statements consume queue
heads or delete an exclusive queue, replay appends only occurrences still at their queue head.
Already consumed/deleted occurrences are skipped. Equal raw text can be interleaved across keys;
A/B/A stays A/B/A. Public records, counts, fallback handling and scanner input are unchanged.

The sequence follows Diagnostics contract precedence and each scan's occurrence order, not
global lexical source order. No guessed source spans, ordinals, sorted snapshot or unique-key
ordering is introduced. Only CanonicalEvents production changes; scanner/AST/value/runtime and
neutral authorities stay byte-exact to clean5bbceb962. Existing exclusive ownership stays intact.

The15-test regression fails exactly its A/B/A oracle against the unchanged before-owner and
passes after repair. Other consumed/exclusive/blank/fallback/schema/identity/input controls pass
on both sides. Phase0 invokes the same standalone regression from its own child snippet. The
first dedicated extractor selected a later heredoc because its delimiter pattern was wrong;
before producer/error JSON is retained. Scoped extraction now executes the exact child and passes.

The first canonical gate correctly rejected that new Phase0 insertion through the historical
objective audit's exact signature-regression contract. Current evolution strips only the exact
owned ten-line occurrence subtest at its fixed anchor; the remaining bytes must equal committed
SIGNATURE_AFTER, and reversing the earlier signature repair must recover the original hash.
The activation audit snapshot reproduces RED. Six actual Phase0 corruption controls include
missing, duplicated and changed recurrence; isolated archive replay preserves original-log
read denial and tracked-write denial. This permits no unrelated Phase0 drift or fresh objective claim. The first failed canonical log retains exact bytes in a base64/length/SHA-256 envelope; storing its raw checkout identity as text failed the path doctrine. Decoding recovers the complete historical failure, while three invalid base64/hash/length controls reject. Current project paths remain relative; no path-check exception is introduced.

Nine original sources under three seeds retain27 baseline/current comparisons, each with native
and independent fresh emitted records. Baseline permutations are observed in three cases in this
new population; all current full sequences match independent raw-order oracles across seeds.
Raw arrays remain untouched. Canonical record populations, other metadata, ASTs, substitutions,
dumps/emitted bytes and native/fresh value/error/effect observations match. Known raw warning
streams survive; their process eval identifiers are excluded only from equality, while warning
classes are checked on both sides. Fifteen current traces retain the measured cursor-miss/skip/
rewrite decisions. Eleven focused suites pass424 top-level TAP tests; ten evidence corruptions
reject. These are reviewer controls, not runtime semantic mutants or arbitrary-overlap admission.

Quoted false control/helper blockers `.0.7.2` and nested raw false-ready `.0.7.0/.1` stay open.
Their exact current observations are preserved, not treated as portable positives. Dispatcher/
full selected compositions and other backend obligations remain separate. Compiler landing
requires the successful canonical receipt for the exact staged candidate; no gate count is
preclaimed by the focused checkpoint.
