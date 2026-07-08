---
id: task-acceptance-evidence-gate-boundary
title: "TASK-ACCEPTANCE evidence gate checks staged governed changes for checklist evidence shape"
answers:
  - "what does the TASK-ACCEPTANCE doctrine check enforce"
  - "does check_diagnosis_evidence rerun commands from task files"
  - "which staged paths trigger the task acceptance evidence gate"
  - "why is the task acceptance evidence gate narrow"
  - "where is the diagnosis evidence checklist enforced"
  - "what should I do if TASK-ACCEPTANCE fires unexpectedly"
  - "what are the known limits of the task acceptance evidence gate"
date: 2026-07-08
status: current
tags: [doctrine-enforcement, task-trees, evidence, tooling]
evidence: "scripts/check_diagnosis_evidence.sh; scripts/check_doctrines.sh; DOCTRINE_ENFORCEMENT.md §10; TOOLBOX.md; docs/tasks/DOCTRINE-ENFORCEMENT-ADOPT.md"
reverify: "bash scripts/check_diagnosis_evidence.sh && bash scripts/check_doctrines.sh && rg -n 'TASK-ACCEPTANCE|check_diagnosis_evidence|Acceptance Checklist' scripts/check_doctrines.sh DOCTRINE_ENFORCEMENT.md TOOLBOX.md docs/tasks/DOCTRINE-ENFORCEMENT-ADOPT.md"
---

`TASK-ACCEPTANCE` is an evidence-shape gate, not a hook-time command executor.
`scripts/check_diagnosis_evidence.sh` inspects only the staged set. It passes
with no staged governed paths. It fires for staged code/spec/test/tooling paths
under `.github/workflows/`, `.githooks/`, `bin/`, `perl/`, `rust/`, `specs/`,
`t/`, `tools/`, or `scripts/`.

When it fires, one staged `docs/tasks/*.md` file must carry the `TOOLBOX.md`
acceptance checklist with all six checked labels: reproduce/issue, root cause
with WHY+WHERE, fix, addressed/verified, no regression, and lockstep. The same
staged task file must include conservative LinkedSpec-tool/output signatures,
WHY/WHERE evidence shape, and verification evidence shape.

The check deliberately does not re-run arbitrary commands pasted into Markdown.
That avoids false positives and hook-time command-execution risk. The actual
reproducibility oracle remains the focused validation commands recorded in the
task leaf plus the broader local gate (`tools/run_ci_local.sh`).

If the gate fires unexpectedly, inspect `git diff --cached --name-only`. Resolve
the mismatch by unstaging unrelated governed files, staging/updating the real
owning task-tree checklist, or splitting the work into a smaller leaf with its
own evidence trail. The known limit is deliberate: the check proves staged
evidence shape and ownership, not truthfulness, historical completeness, or that
the cited commands have been re-run.
