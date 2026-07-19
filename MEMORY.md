# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.1` — Lua root core is implemented, verified, documented,
  cleaned, and prepared for its one commit.
- latest_commit: `c8324dce` — `FUTURE-PARITY-BACKLOG.9.1.1.2.5.0 - map Lua root selection`
  (ahead: 231; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.1 - implement Lua root selection core`.
- active_work_unit: `.5.1` completion; do not activate `.5.2` until commit/brief cleanup/clean-tree proof.
- next_action: commit `.5.1`, clear `git_message_brief.txt`, prove clean, then activate composed Lua routes `.5.2`.
- current_proof: PUC Lua and LuaJIT now accept markerless one-or-more-rule source and share one pre-context resolver
  for explicit > first marker > first rule. Portable zero/unknown failures, immutable descriptor identity, strict
  authored-edge no-drift, and entry-`I` result evidence pass focused 99, diagnostic 119, and logical 359 per ABI.
  Package is 176/177 with only the cursor-help mismatch; every default/POSIX ABI leg is exactly 32/65 with the same
  33 cursor-owned failures; corpus is 105/105 per ABI. Routes `.5.2`, cursor `.9.1.7`, and admission `.5.3` remain;
  rollout stays 5/7+39. KM is 624/4,546; mdBook/four doctrines pass. Canonical exits 0 after root 7+5, cursor 288,
  primary 65x2, and Phase 0 1,031/1,031 in 613 seconds. Generated book/cache/native trees are absent.
- current_cursor_normalization: All 36 parsed/compiled family rows, 18 edge rows, six ownership sets, six portable
  diagnostics, eight parent-child mechanisms, and two structural replacements are exact. Normal entered rules
  derive policy once; children rederive independently. Descriptor v1 has no global mode and projects exact facts;
  focused descriptor proof is 809 and direct/normalized/loaded bytes agree. Generated v2 focused proof is 65;
  its five seek/five consume mapping, compact-pipe OR identity, direct/traced/fresh-loaded execution, and v1-before-
  corrupt-payload rejection are exact. Public legacy keys fail before input/user code; low-level matchers remain.
  Package is 3,291, ten processes, primary 65/65x2, corpus 105, generated governance 80/0/0, cursor 67/5+3/44,
  logical 8/0, root 4/7+34, and capability 80/0/0. KM is 621/4,512; mdBook/four doctrines pass. Canonical local CI
  exits 0 after root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 641 seconds.
- current_cursor_admission: Julia now has one exact 15-role consumer; focused composition 104, package 3,291,
  ten processes, primary 65x2, and corpus 105 pass. Only Julia advances to neutral 67/5+3/44. The complete/primary
  drivers create only the first writable entry of a stacked depot; corrected offline proof leaves no malformed
  colon-bearing directory.
- latest_bootstrap_read: 2026-07-18 — full roadmap/codebase/mdBook, active task, Knowledge Map, Toolbox, ADRs
  `0044`/`0046`, neutral/admitted cursor precedent, Julia architecture/root routes, and exact drivers reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root admission `.9.1.1.2.5-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.7-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: completed `.5.1` source/tests/docs await the prepared commit; no background
  job remains. Commit brief is zero bytes until populated immediately before commit.
