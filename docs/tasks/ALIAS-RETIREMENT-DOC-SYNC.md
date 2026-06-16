# ALIAS-RETIREMENT-DOC-SYNC: Correct stale "compatibility alias" claims for the retired array-edge aliases

## Metadata

- Tree ID: `ALIAS-RETIREMENT-DOC-SYNC`
- Status: `completed`
- Roadmap lane: `Overall roadmap — documentation and book sync (zero-drift doctrine)`
- Created: `2026-06-16`
- Last updated: `2026-06-16` (`.1` done — tree complete)
- Owner: repo-local workflow

## Goal

Bring every doc into zero-drift agreement with the actual `.spec` contract on the
**retired array-edge aliases** `tail` / `drop_last` / `flatten` / `array_values`. These
were retired in `COMPAT-ALIAS-RETIREMENT.1`; the Perl reference no longer recognizes them
(absent from all helper-recognition regexes), no shipped spec uses them, and `t/` has zero
locks. The book Helper Contract Catalog (`appendix/helper-contract-catalog.md`
§Compatibility-Aliases) already lists them "Retired", but other pages still call them
"compatibility alias / remain compatibility syntax". The `.spec` language is the one
universal contract and the docs are variant-agnostic, so this retirement is contract truth
that every doc must reflect.

Discovered by `RUST-PARITY.5.5.2` (the leaf that resolved the alias-retirement Open
Question and deliberately did not add these aliases to the Rust variant), then flagged by
the user: the book/doc must be variant-agnostic and correct, not deferred as "Perl-side".

## Non-Goals

- Touching the OTHER alias categories whose retirement status is not verified here
  (capture aliases like `capture_slice_here()`/`capture_from_rule_start()`, the
  `entry_named_map()`/`match_named_map()` named-map aliases, or the `return_*` medium-term
  aliases). Those are a separate audit; this tree is scoped to the four verified-retired
  array-edge aliases only.
- Rewriting genuine historical narrative — only the false present-tense "remains supported /
  is a compatibility alias" claims are corrected; the fact that they once landed as aliases
  stays in the record, annotated as retired.

## Acceptance Criteria

- Every doc claim that `tail`/`drop_last`/`flatten`/`array_values` "remain(s) a
  compatibility alias / compatibility syntax" is corrected to state they are retired
  (`COMPAT-ALIAS-RETIREMENT.1`), across the book, `ROADMAP_V2.md`, and `ROADMAP.md`.
- The book builds (`mdbook build`) and the memory-architecture + knowledge-map gates pass.
- Live docs updated; committed through `COMMIT.md`.

## Task Tree

- ID: `ALIAS-RETIREMENT-DOC-SYNC`
  Status: `active`
  Goal: Correct stale array-edge-alias retention claims across all docs
  Children: `.1`

- ID: `ALIAS-RETIREMENT-DOC-SYNC.1`
  Status: `done`
  Goal: Fix the stale "compatibility alias" claims for `tail`/`drop_last`/`flatten`/`array_values` in the book (`appendix/formal-grammar.md`), `ROADMAP_V2.md`, and `ROADMAP.md`
  Acceptance: the audited stale lines (book formal-grammar.md:357; ROADMAP_V2 182/256/257/260/262; ROADMAP 735/736/993/994/997/999/1189/1190/1191/1242) state retirement; `mdbook build` exit 0; gates pass; committed.
  Verification: Done — 2026-06-16. Corrected 16 lines across 3 files: book `appendix/formal-grammar.md:357` (`array_values` → "retired alias of array_copy"; the book Helper Contract Catalog §Compatibility-Aliases already said "Retired", so the book is now internally consistent), `ROADMAP_V2.md` (182 ×3 claims, 256, 257, 260, 262, + the "follow-up audit targets" mention), and `ROADMAP.md` (735, 736, 993, 994, 997, 999, 1189, 1190, 1191, 1242). Each false present-tense "remains/preserving … compatibility alias/syntax" claim → "was a compatibility alias, since **retired** (`COMPAT-ALIAS-RETIREMENT.1`)", preserving the historical "Landed …" record. Verified zero remaining stale array-edge retention claims (grep clean); `mdbook build` exit 0; memory-arch + knowledge-map gates pass. USER_GUIDE.md and ROADMAP.md:253 matches were a different alias category (capture / named-map aliases) — left out of scope per Non-Goals.
  Commit: `ALIAS-RETIREMENT-DOC-SYNC.1` (see Commit Log)

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `ALIAS-RETIREMENT-DOC-SYNC.1` | `done` | doc-sync complete; tree closed |

## Decisions

- `2026-06-16`: Scoped to the four **verified-retired** array-edge aliases only. Their
  retirement is airtight (no recognition regex, 0 shipped-spec uses, 0 `t/` locks, "Retired"
  in the book catalog), so correcting the docs is fact, not judgment. The capture / named-map
  / return aliases caught by the same grep are a separate, unverified category and are left to
  a future audit (Non-Goals) to keep this slice signoff-clean.
- `2026-06-16`: For historical "Landed follow-up" bullets in `ROADMAP.md`/`ROADMAP_V2.md`,
  annotate the retirement inline ("was a compatibility alias, retired in
  `COMPAT-ALIAS-RETIREMENT.1`") rather than deleting the history — preserves the audit trail
  while removing the false present-tense claim.

## Open Questions

- Capture aliases (`capture_slice_here`, `capture_from_rule_start`, `capture_slice_length`,
  `capture_rest_length`) and `entry_named_map`/`match_named_map` are also described as
  "remain supported" in `USER_GUIDE.md` and the book — their retirement status is NOT verified
  here. Deferred to a separate audit (does not block this frontier).

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-16` | `ALIAS-RETIREMENT-DOC-SYNC.1` | grep for remaining `tail`/`drop_last`/`flatten`/`array_values` "remain/compatibility" claims; `mdbook build`; `scripts/check_memory_architecture.sh`; `knowledge-map/scripts/check_knowledge_map.sh` | clean (0 remaining); mdbook exit 0; gates exit 0 |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `ALIAS-RETIREMENT-DOC-SYNC.1` | `ALIAS-RETIREMENT-DOC-SYNC.1 — retire array-edge alias claims across book + roadmaps` | 16 lines / 3 files; book now internally consistent with its own catalog |

## Changelog

- `2026-06-16`: Created task tree (driven by RUST-PARITY.5.5.2's alias-retirement resolution + user direction that docs must be variant-agnostic and zero-drift).
- `2026-06-16`: `.1` done — corrected 16 stale array-edge-alias retention claims across `appendix/formal-grammar.md`, `ROADMAP_V2.md`, and `ROADMAP.md` to state retirement (`COMPAT-ALIAS-RETIREMENT.1`), preserving the historical landing records. `mdbook build` exit 0; gates pass. Tree complete.
