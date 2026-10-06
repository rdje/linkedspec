---
id: project-root-evidence-filesystem-modes
title: Actual-root evidence records filesystem permissions separately from Git mode
answers:
  - "why does actual-root component evidence reject original input mode"
  - "must filesystem permissions equal recorded Git mode in evidence capture"
  - "how does the progressive contract checker recover actual-root input bytes"
  - "which observed permission differences caused the component capture RED"
date: 2026-10-06
status: historical mode correction hash-bound; current recognition input modes independently guarded
tags: [claims, inputs, git, permissions, component-gate, provenance]
evidence: "The .1.5.2 component instrument stops before running the checker when it compares complete stat permissions to Git mode. The complete observed census has36 readable differences, beginning noncore/AmbiTiming.pm0640 versus recorded100644, with zero executable-bit drift. Preserve both fields and guard actual permissions unchanged; no chmod is performed. Healthy component capture checks4638 actual-root inputs/five retained byte deltas. Independent exact three-edit repair/census/original RED and four effective evidence controls pass."
reverify:
  - "bash scripts/check_claim_verification.sh"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3-review.py"
---

The published progressive checker requires tracked-file metadata and runs in the
actual LinkedSpec Git root. A plain immutable Git-object input tree has no separate
repository metadata. The selected component capture therefore conservatively
records all regular committed parent inputs, retaining actual-root byte deltas
completely and guarding each supplied byte stream before and after the command.
Unchanged originals remain recoverable through the committed object manifest.
This is a supplied-input superset, not a claim of minimal observed IO.

The first instrument assumed recorded Git mode equals full filesystem permissions.
Its actual RED occurs at that comparison, before the component checker runs. The
independent complete census distinguishes readable0640 files from recorded100644;
all36 observations preserve the executable flag. The correction removes that false
comparison, adds actual filesystem_mode and uses it in the final unchanged-mode
guard. Exact original producer/failure channels, the complete census and repaired
producer are retained and hash-bound. Project permissions and tracked modes do not
change. These are dated observations, not a permanent count or a repository defect.

The original progressive component inputs retain five exact byte deltas from cleanef2dd019b,
including the active leaf's mutable pointer/task and prior-claim freeze. Later
continuity edits do not refresh that observation; original bytes stay recovered
inside its tracked input manifest. Source/fixture inputs must still match their
current declared producer bytes when reviewed. Submodule/nonregular payloads are
excluded, OS/Git/Python prerequisites are read-only, all project storage remains
repository-local and other Git repositories remain read-only.

After the recognition owner changes, the original progressive mode correction
is reverified through its historical claim/input hashes at committed34f687;
the current recognition comparison checks its own complete actual-root snapshot.
The claim gate does not re-execute historical producers. Do not run the old
current-source component comparison against later changed production bytes.
