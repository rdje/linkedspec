# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.6.4` — Julia generated-source v2 derives cursor from minimal
  validated family rows, rejects v1 before payload reconstruction, and passes full signoff.
- latest_commit: `3caeb097` — `FUTURE-PARITY-BACKLOG.9.1.6.3 - project Julia cursor descriptor v1`
  (ahead: 226; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.6.4 - emit Julia generated-source v2`.
- active_work_unit: `.9.1.6.4` is fully implemented, documented, and verified from clean `3caeb097`; only its
  prepared commit remains. Julia current emission is v2/format 2; options/admission stay `.5-.6`.
- next_action: commit `.9.1.6.4`, clear/verify the brief and clean tree, then activate `.9.1.6.5` task-tree-first.
- current_proof: Julia root core/routes remain signed off: one resolver owns explicit > first marker > first rule,
  loaded/normalized/generated/emitted direct/traced reuse it; primary is
  32/65x2, corpus 105, and root governance 4/7 plus 34 mutations. Generated root selection is preserved in v2.
- current_cursor_normalization: All 36 parsed/compiled family rows, 18 edge rows, six ownership sets, six portable
  diagnostics, eight parent-child mechanisms, and two structural replacements are exact. Normal entered rules
  derive policy once; children rederive independently; generated v1 and explicit outer callers retain bounded
  compatibility. Descriptor v1 has no global mode and projects exact normalized family/policy/ownership/edge facts;
  focused descriptor proof is 809 and direct/normalized/loaded bytes agree. Generated v2 focused proof is 65;
  its five seek/five consume mapping, compact-pipe OR identity, direct/traced/fresh-loaded execution, and v1-before-
  corrupt-payload rejection are exact. Package is 3,133 plus the exact staged help mismatch, primary 32/65x2,
  corpus 105, generated governance 80/0/0, cursor 67/4+4/39, and root 4/7+34. Options remain present and rollout
  remains 4+4. KM is 618/4,489; mdBook/doctrines pass; canonical root 7+5, cursor 288, primary 65x2, and Phase 0
  1,031/1,031 in 643s pass. Generated book/cache cleanup passes.
- current_cursor_admission: Dart remains clean at `7aa9c578`: 15 roles, package 271, primary 65x2, corpus 105,
  and neutral 67/4+4/39. Julia normalization/runtime/descriptor are implemented but rollout remains pending
  through `.5-.6`.
- latest_bootstrap_read: 2026-07-18 — full roadmap/codebase/mdBook, active task, Knowledge Map, Toolbox, ADRs
  `0044`/`0046`, neutral/admitted cursor precedent, Julia architecture/root routes, and exact drivers reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root admission `.9.1.1.2.4.3-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.6.5-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: fully verified `.9.1.6.4` source/tests/docs/KM and prepared commit only;
  no option/shared-fixture/capability/rollout change or background job.
