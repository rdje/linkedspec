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
- latest_commit: `20a37cd2` — `FUTURE-PARITY-BACKLOG.9.1.6.4 - emit Julia generated-source v2`
  (ahead: 227; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.6.5 - remove Julia global cursor overrides`.
- active_work_unit: `.9.1.6.5` is complete and verified task-tree-first from clean `20a37cd2`. Engine/loader/corpus/
  primary global ownership is removed with exact API/CLI diagnostics; docs/KM and all proof are synchronized.
- next_action: regenerate/check the Knowledge Map and doctrines after final evidence, commit `.9.1.6.5`, clear the
  brief, verify handoff-ready, then activate `.9.1.6.6` task-tree-first.
- current_proof: Julia root core/routes remain signed off: one resolver owns explicit > first marker > first rule,
  loaded/normalized/generated/emitted direct/traced reuse it; cursor removal now preserves `--top-rule` at exact
  primary 65/65x2, corpus 105, and root governance 4/7 plus 34 mutations. Root admission remains `.4.3`.
- current_cursor_normalization: All 36 parsed/compiled family rows, 18 edge rows, six ownership sets, six portable
  diagnostics, eight parent-child mechanisms, and two structural replacements are exact. Normal entered rules
  derive policy once; children rederive independently. Descriptor v1 has no global mode and projects exact facts;
  focused descriptor proof is 809 and direct/normalized/loaded bytes agree. Generated v2 focused proof is 65;
  its five seek/five consume mapping, compact-pipe OR identity, direct/traced/fresh-loaded execution, and v1-before-
  corrupt-payload rejection are exact. Public legacy keys fail before input/user code; low-level matchers remain.
  Package is 3,187, ten processes, primary 65/65x2, corpus 105, generated governance 80/0/0, cursor 66/4+4/39,
  logical 8/0, root 4/7+34, and capability 80/0/0. KM is 619/4,498; mdBook/four doctrines pass. Canonical local CI
  exits 0 after root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 637 seconds.
- current_cursor_admission: Dart remains clean at `7aa9c578`: 15 roles, package 271, primary 65x2, corpus 105,
  and neutral 67/4+4/39. Julia implementation is current through public removal `.5`, but rollout remains pending
  until composed admission `.6`.
- latest_bootstrap_read: 2026-07-18 — full roadmap/codebase/mdBook, active task, Knowledge Map, Toolbox, ADRs
  `0044`/`0046`, neutral/admitted cursor precedent, Julia architecture/root routes, and exact drivers reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root admission `.9.1.1.2.4.3-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.6.6-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: completed/verified `.9.1.6.5` candidate awaiting final regeneration,
  commit, brief clearing, and clean-state verification. Generated mdBook/Python-cache artifacts are removed.
