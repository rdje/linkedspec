# SPEC-SPEC-SELFHOST: Rewrite spec.spec to faithfully self-host the BootstrapSpec::Core .spec format

## Metadata

- Tree ID: `SPEC-SPEC-SELFHOST`
- Status: `done`
- Roadmap lane: `Phase 7 follow-on — self-hosted .spec grammar (rewrite)`
- Created: `2026-06-16`
- Last updated: `2026-06-16` (`.4` done — tree complete)
- Owner: repo-local workflow

## Goal

Replace the current unusable `specs/spec.spec` with a new, complete, accurate `.spec`
description of the **currently supported `.spec` file format**, derived directly from the
authoritative hardcoded grammar in `perl/LinkedSpec/BootstrapSpec/Core.pm`. The new file is
self-hosting: it describes the `.spec` language in the `.spec` DSL itself, recognizing the
same token forms the bootstrap recognizes and emitting equivalent structural nodes.

## Non-Goals

- Promoting spec.spec to the primary parse path (BootstrapSpec::Core stays the oracle;
  spec.spec remains the diagnostic/candidate side-channel per the dual-path design).
- Changing the bootstrap grammar or any `.spec` language syntax (this is a description of
  the EXISTING format, not an evolution of it).
- Rust-variant work (tracked separately under `RUST-PARITY`).
- Brainstormed future `.spec` format changes (those are `brainstorming` only; not adopted).

## Acceptance Criteria

- `specs/spec.spec` is rewritten to cover every top-level token form recognized by
  `BootstrapSpec::Core.pm`: rule labels (all colon/mode forms), regex literals, action edges
  (block / fluent / bare, grouped targets, `[N]` slot index), blind-call edges
  (block / fluent / bare), lifecycle/code blocks (I/LS/LE/E/EX/IT/LX + any `Type {}`), split
  markers (`@capture_slice` / `@capture_from_here` / `@move_pos` / `@mark(name)`), and comments.
- The new spec.spec uses only canonical, raw-Perl-free ActionIR helpers.
- `LinkedSpec::Get(\$spec_spec_content)` builds a parser coderef and the descriptor reports
  `language_agnostic_ready_ratio == 1.0000`, zero blocked rules, zero compatibility-surface
  rules (so `t/phase0_regression.t` `compile_all_target_specs` + `all_target_specs_are_actionir_ready`
  stay green — spec.spec is in the discovered target set).
- The full phase0 regression gate passes (`prove -Iperl t/phase0_regression.t`).
- Cross-check fidelity vs the bootstrap oracle (`tools/cross_check_spec_parsers.pl`) is
  measured and recorded; the new grammar should not regress, and should improve where feasible.
- Live docs updated (DEVELOPMENT_NOTES.md self-hosting status, mdBook self-hosting note,
  CHANGES.md, MEMORY.md) and each completed leaf committed through `COMMIT.md`.

## Task Tree

- ID: `SPEC-SPEC-SELFHOST`
  Status: `done`
  Goal: Rewrite spec.spec to faithfully self-host the BootstrapSpec::Core format
  Children: `.1`, `.2`, `.3`, `.4` (all done)

- ID: `SPEC-SPEC-SELFHOST.1`
  Status: `done`
  Goal: Inventory the BootstrapSpec::Core token grammar → spec.spec node mapping
  Acceptance: A precise mapping of each bootstrap start-token rule (regex + emitted einfo tuple)
    to the spec.spec rule that must recognize it and the structural node it should emit
  Verification: Done — 2026-06-16: full read of `perl/LinkedSpec/BootstrapSpec/Core.pm` (851 lines).
    14 rule descriptors; SPEC_ROOT flat-scanner groups einfo tuples into paragraphs at ELABEL
    boundaries. Token→tuple table recorded in Decisions below.
  Commit: `pending`

- ID: `SPEC-SPEC-SELFHOST.2`
  Status: `done`
  Goal: Author the new specs/spec.spec (replace the garbage) — complete, faithful, documented, raw-Perl-free
  Acceptance: New `specs/spec.spec` covering all token forms; `LinkedSpec::Get` builds a parser
    coderef; descriptor ratio 1.0000, zero blocked/compatibility rules
  Verification: Done — 2026-06-16. Hierarchical model mirroring SPEC_ROOT: `spec_file::` owns the
    paragraph accumulators (`paragraphs`/`current`), dispatches to 12 per-token part rules, and
    starts a new paragraph at every `rule_header` (group-at-header). 13 rules total. Descriptor:
    `language_agnostic_ready_ratio == 1.0000`, blocked 0, compat 0.
  Commit: `pending`

- ID: `SPEC-SPEC-SELFHOST.3`
  Status: `done`
  Goal: Verify — full phase0 gate green; measure + record cross-check fidelity vs bootstrap oracle; iterate
  Acceptance: `prove -Iperl t/phase0_regression.t` PASS; `tools/cross_check_spec_parsers.pl`
    fidelity measured and recorded; no regression vs prior spec.spec
  Verification: Done — 2026-06-16. Paragraph-count fidelity vs bootstrap oracle: 19/19 shipped
    specs match exactly (independent check); `tools/cross_check_spec_parsers.pl` reports
    "ALL 20 specs match. spec.spec has proven output parity with BootstrapSpec" (was 2/20).
    Self-hosting: spec.spec divides itself into 13 paragraphs == its 13 rules. Multiline fluent
    chains fixed by using `\s*` joins (matching the bootstrap) — fixed the ebnf 40→24 over-count
    (spurious `Error:` from `say("Error: ...")` in multiline guard chains). phase0 gate: see log.
  Commit: `pending`

- ID: `SPEC-SPEC-SELFHOST.4`
  Status: `done`
  Goal: Docs sync + finalize — DEVELOPMENT_NOTES, mdBook self-hosting note, extension policy, CHANGES, MEMORY
  Acceptance: Live docs reflect the rewrite; extension-surface policy preserved; tree closed
  Verification: `done` — 2026-06-16. Docs synced to the `.2`/`.3` rewrite (commit `4c667b7`): DEVELOPMENT_NOTES.md gained a self-hosting status note superseding the MEDIUM-IMPACT.3.x "2/20" dual-path entries (rewrite = faithful 13-rule description of BootstrapSpec::Core; ratio 1.0000; cross-check harness now full 20/20 paragraph-count parity; self-hosts 13==13); mdBook `compiler/pipeline-overview.md` dual-path note now states the paragraph-grouping parity (bootstrap still primary). Extension-surface policy confirmed PRESERVED verbatim in the new spec.spec header (EXTENSION-SURFACE POLICY block) — acceptance met without further edits. Non-Goals preserved (bootstrap = oracle/primary; spec.spec = diagnostic side channel). `git diff --check` clean; `mdbook build` exit 0; `scripts/check_memory_architecture.sh` exit 0. Docs-only (no phase0 needed; the rewrite was gated under `.3`).
  Commit: `SPEC-SPEC-SELFHOST.4 — docs sync + finalize; close the self-hosting rewrite tree`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | — | — | Tree complete — all 4 leaves done; no frontier. |

## Decisions

- `2026-06-16`: Created tree. spec.spec confirmed unusable (87 lines, 3 vague rules) and
  not used for anything yet; rewrite from scratch grounded in BootstrapSpec::Core.pm.
- `2026-06-16` (`.1`): BootstrapSpec::Core token→tuple inventory (the description contract):

  | Bootstrap rule (Core.pm) | Start-token regex (first slot) | Emitted einfo tuple |
  | --- | --- | --- |
  | ENTRY_LABEL | `\w+\s*::?\s*(mode|neg-lookahead)` | `['ELABEL'|'ELABEL_INITIAL', label, node_type, min, max]` |
  | RE_PATTERN | `(?<!\\)/.+?(?<!\\)/` | `['RE', pattern]` (slashes stripped) |
  | ACTION_CODE_BLOCK | `->\s*(TARGETS)\s*\{` … `\}` | `['ACODE',{relabel,reidx,code}]` per target |
  | METHOD_EMPTY_ACTION_CODE_BLOCK | `->\s*\w+(\[\d+\])?(\.chain)+(\{blk\})?` | `['ACODE',{relabel,reidx,code}]` |
  | EMPTY_ACTION_CODE_BLOCK | `->\s*\w+(\[0\])?` | `['ACODE',{relabel,reidx:0,code:"call(label)"}]` |
  | NON_ACTION_CODE_BLOCK | `\w+\s*\{` … `\}` | `['<Type>CODE', code]` (ICODE/LSCODE/…/LXCODE) |
  | METHOD_EMPTY_NON_ACTION_CODE_BLOCK | `\w+(\.chain)+(\{blk\})?` | `['<Type>CODE', code]` |
  | COMMENT | `[ \t]*#.*` | `['COMMENT']` |
  | BLIND_CALL_CODE_BLOCK | `=>\s*\w+\s*\{` … `\}` | `['BCODE',{call,code}]` |
  | METHOD_EMPTY_BLIND_CODE_BLOCK | `=>\s*\w+(\.chain)+(\{blk\})?` | `['BCODE',{call,code}]` |
  | EMPTY_BLIND_CODE_BLOCK | `=>\s*\w+` | `['BCODE',{call,code:"$rule=call(child)"}]` |
  | SPLIT_LIKE_CODE | `@\s*(capture_slice|capture_from_here|move_pos|mark\(\w+\))` | `['MARK_POS',{name}]` / `['MOVE_POS']` |
  | CURLY_BRACE | `(?<!\\)\{` `\}` `"…"` `'…'` | brace scanner (internal nesting/string skip) |

  Mode→node_type (ENTRY_LABEL): `&`→AND, `|`→OR, `+`→REP_PLUS, `*`→REP_STAR, `?`→REP_OPT,
  `OR`→REP_OR_EXPLICIT, `OR+`→REP_OR_PLUS, `AND`→AND_EXPLICIT, `AND+`→REP_AND_PLUS,
  `OR{n,m}`→REP_OR_BOUNDED, `AND{n,m}`→REP_AND_BOUNDED, none→default. Open-max sentinel `10**9`.

## Open Questions

- Hierarchical model (spec_file → rule_paragraph → body_element) vs flat-scanner model
  (single repeated-choice over all token forms). Leaning hierarchical for readability; the
  bootstrap itself is flat-scanner + ELABEL paragraph grouping. Resolve during `.2` authoring
  by what compiles + cross-checks best. Does not block starting `.2`.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-16` | `SPEC-SPEC-SELFHOST.1` | Full read of `perl/LinkedSpec/BootstrapSpec/Core.pm` (851 lines) | Done — 14 descriptors inventoried; token→tuple table recorded |
| `2026-06-16` | `SPEC-SPEC-SELFHOST.2` | `LinkedSpec::Get(spec.spec, return_descriptor)` migration summary | ratio 1.0000, blocked 0, compat 0 |
| `2026-06-16` | `SPEC-SPEC-SELFHOST.3` | paragraph-count vs bootstrap oracle (19 shipped specs); `tools/cross_check_spec_parsers.pl`; self-parse | 19/19 match; harness "ALL 20 specs match"; self-parse 13==13 |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SPEC-SPEC-SELFHOST.2` | `SPEC-SPEC-SELFHOST.2 — rewrite spec.spec as a faithful self-hosting grammar` (`4c667b7`) | `.1` inventory + `.3` verification folded into this work commit; spec.spec rewritten, ratio 1.0000, 20/20 cross-check |
| `SPEC-SPEC-SELFHOST.4` | `SPEC-SPEC-SELFHOST.4 — docs sync + finalize; close the self-hosting rewrite tree` | Docs synced; extension-surface policy confirmed preserved; tree closed and moved to Completed |

## Changelog

- `2026-06-16`: Created task tree; `.1` inventory complete from BootstrapSpec::Core.pm.
- `2026-06-16`: `.2` + `.3` done — rewrote `specs/spec.spec` as a faithful hierarchical
  self-hosting grammar (spec_file -> 12 part rules, group-at-rule_header). Compiles ratio
  1.0000; 19/19 paragraph-count fidelity vs bootstrap; cross-check harness 20/20; self-hosting.
- `2026-06-16`: `.4` done — **tree complete**. Synced live docs to the rewrite: DEVELOPMENT_NOTES
  self-hosting status note (supersedes the "2/20"-era dual-path notes; now full 20/20 cross-check
  parity), mdBook `pipeline-overview` dual-path parity note, and confirmed the extension-surface
  policy is preserved verbatim in the new spec.spec header. Bootstrap remains oracle/primary;
  spec.spec stays the diagnostic side channel (Non-Goals). Recorded the `.2` commit `4c667b7`.
  Tree moved to Completed in `docs/TASK_TREE.md`.
