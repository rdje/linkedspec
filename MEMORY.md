# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.6.1` — exact Julia family/bare-edge normalization, portable
  diagnostics, compiled lowering, documentation, full signoff, and cleanup are complete; commit is pending.
- latest_commit: `ee8efbfc` — `FUTURE-PARITY-BACKLOG.9.1.6.0 - map Julia cursor rollout`
  (ahead: 223; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.6.1 - normalize Julia cursor families and edges`.
- active_work_unit: `.9.1.6.1` is verified and documented; only its prepared commit/clean boundary remains. Runtime,
  descriptor, generated, option/CLI, admission, shared fixtures, and rollout remain untouched and out of scope.
- next_action: stage intended `.9.1.6.1` source/test/docs, commit through `git_message_brief.txt`, clear the brief,
  verify clean, then activate runtime `.9.1.6.2` task-tree-first.
- current_proof: Julia root core/routes remain signed off: one resolver owns explicit > first marker > first rule,
  loaded/normalized/generated/emitted direct/traced reuse it, package progresses through cursor 56/57, primary is
  32/65x2, corpus 105, and root governance 4/7 plus 34 mutations. Generated root state stays v1/format 1.
- current_cursor_normalization: All 36 parsed/compiled family rows are exact; all 18 edge rows and six ownership
  sets retain typed bare/explicit/lifecycle identity, lower valid family ownership, and emit the six portable
  diagnostics. Focused proof is 353; nested complete package is 2,215 pass plus the exact one staged help mismatch;
  ordinary package remains 56/57, primary 32/65x2, corpus 105, cursor governance 67/4+4/39, and root 4/7+34.
  Runtime remains global seek with parent-child 5/8 and structural 1/2; descriptor/generated/options stay v0/v1/
  present. Rollout remains 4+4. KM is 615/4,455; mdBook/doctrines and canonical root 7+5, cursor 288, primary
  65x2, Phase 0 1,031 in 614s pass. Generated book/cache are removed; reusable Julia depot is 142 MB.
- current_cursor_admission: Dart remains clean at `7aa9c578`: 15 roles, package 271, primary 65x2, corpus 105,
  and neutral 67/4+4/39. Julia preflight changes no executable/contract/fixture/capability/rollout/public semantics.
- latest_bootstrap_read: 2026-07-18 — full roadmap/codebase/mdBook, active task, Knowledge Map, Toolbox, ADRs
  `0044`/`0046`, neutral/admitted cursor precedent, Julia architecture/root routes, and exact drivers reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root admission `.9.1.1.2.4.3-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.6.1-.9` after `.0`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: complete verified `.9.1.6.1` source/test/docs awaiting prepared commit;
  no runtime/descriptor/generated/options/shared-fixture/capability/rollout change and no background job.
