---
id: codeblock-matches-checkpoint-input-closure
title: Codeblock matches consumer needs four checkpoint files beyond its own suite source
answers:
  - "why did codeblock matches fail before its first TAP assertion in the fixed capsule"
  - "which checkpoint files does codeblock_matches_perl.t execute or read"
  - "does codeblock_matches_perl.t require the baseline runtime before module"
  - "how are the twelve original passing consumers composed with the repaired final consumer"
date: 2026-10-04
status: supplied-input defect fixed and independently verified under .1.1.3.1
tags: [claims, capsule, checkpoint, perl, codeblock, source-boundary]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.1 retains initial exit1/test exit2 at line8 with no TAP and1298 completed groups from twelve earlier suites. Exactly four immutable checkpoint inputs repair the final unchanged39-group consumer. Independent review preserves738/742-file actual boundaries, common input byte/mode identities and22 distinguishing RED controls."
reverify: "At exact c02ce88826f815c201a652d5b29bd3cf044d2740 run bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.1-review.py --public-book; publication/producer bytes are historical and must not be refreshed."
---

# Codeblock matches consumer needs four checkpoint files

`t/codeblock_matches_perl.t` line8 opens
`docs/checkpoints/SESSION-STARTUP-READING.87.2-cases.json`, then launches the
corresponding `.87.2-probe.pl`. That public probe runs `.87.2-fresh.pl` and
both require `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm`.
The observer uses the public LinkedSpec codeblock runtime; no dependency
implementation is involved. `.87.2-runtime-before.pm` is conditional on
`--baseline`; this suite's command does not request baseline and that route
is unassessed by this proof.

The original conservative capsule selected other checkpoint namespaces and
omitted these four files. A lexical reader list alone did not close the supplied
input population. The first twelve suites passed1298 groups with all738 inputs
intact; the final suite failed before any assertion. Its complete failed channels
remain under the .1.1.3.1 consumers-initial.json checkpoint.

Add only the four exact blobs from the same Git3fc589f8 boundary. The expanded
742-file capsule keeps every common original byte and mode unchanged. Rerun the
failed consumer and book:39 complete groups and the original examples pass.
Independent acceptance composes the13 exact suite plans at their actual input
boundaries and rejects capsule relabeling. It does not claim a single successful
full run of the expanded capsule or reconstruct older unretained live reads.
