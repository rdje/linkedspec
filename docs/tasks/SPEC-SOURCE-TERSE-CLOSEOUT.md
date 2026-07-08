# SPEC-SOURCE-TERSE-CLOSEOUT: Exhaustive shipped-spec terse source closeout

## Metadata

- Tree ID: `SPEC-SOURCE-TERSE-CLOSEOUT`
- Status: `done`
- Roadmap lane: `Overall roadmap - .spec language evolution (terse format)`
- Created: `2026-07-08`
- Last updated: `2026-07-08`
- Owner: repo-local workflow

## Goal

Prove and, where needed, complete the terse-format migration across every root
`specs/*.spec` file so other roadmap activities can proceed without carrying
source-format doubt.

## Non-Goals

- Do not redesign the accepted terse language surface.
- Do not rewrite valid current syntax merely because a newer feature could spell it
  differently unless the replacement is objectively lower-risk and part of the
  accepted current surface.
- Do not resume the paused `SPEC-LANG-REFERENCE` book scorch except to record any
  explicit supersession if this source closeout resolves one of its stale facts.

## Acceptance Criteria

- Every root `specs/*.spec` file has been audited against the current accepted terse
  surface.
- Retired source spellings are absent from root specs: `declare(...)`,
  `.declare(...)`, `assign(...)`, `scalar(...)`, `array_copy(...)`, `hash_copy(...)`,
  `push_value(...)`, `concat(...)`, short wrappers `s(...)` / `a(...)` / `h(...)`, and
  old direct hash-literal `{ key => value }`.
- Any remaining non-minimal but valid current spelling is explicitly classified so it
  is not confused with compatibility debt.
- All 21 shipped specs compile with zero compatibility-surface rules.
- Focused source scans, phase0, Rust corpus oracle, mdBook build, and doctrine/memory
  checks pass or any narrower verification choice is justified.
- Live docs, mdBook, roadmap/task-tree status, and memory pointer are updated.
- The completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `SPEC-SOURCE-TERSE-CLOSEOUT`
  Status: `done`
  Goal: `Close all root specs/*.spec terse source-format doubt.`
  Children: `SPEC-SOURCE-TERSE-CLOSEOUT.1`

- ID: `SPEC-SOURCE-TERSE-CLOSEOUT.1`
  Status: `done`
  Goal: `Audit and migrate every root specs/*.spec file to the current accepted terse source surface.`
  Acceptance: `Retired-source scans are clean, shipped descriptors remain fully ActionIR-ready, docs record the closeout, and verification passes.`
  Verification: `perl -c -Iperl perl/PPlugin.pm`; `perl -c -Iperl tools/gen_oracle_corpus.pl`;
    root-spec retired-helper and host-residue scans; 21 descriptor sweep (`1.0000 0 0` for every
    shipped spec); focused hlink/pplugin probes; `PERL5LIB= perl -Iperl tools/gen_oracle_corpus.pl`;
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference -- --nocapture`
    (99 fixtures); `PERL5LIB= prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`;
    `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_memory_architecture.sh`;
    `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `git diff --check`;
    `bash tools/run_ci_local.sh`.
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `SPEC-SOURCE-TERSE-CLOSEOUT.1` | `done` | Root `specs/*.spec` source-format closeout completed; final docs/gates/commit are the only remaining handoff steps. |

## Decisions

- `2026-07-08`: Treat "all specs are ported" as a source-format closeout requirement,
  not only a compatibility-surface metric. The closeout blocks moving to unrelated
  activities until verified.
- `2026-07-08`: Valid current forms are not churned merely to use every later terse feature.
  The closeout criterion is no retired source spellings or Perl host-action residue in root specs,
  not a style rewrite of already-current syntax.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-08` | `SPEC-SOURCE-TERSE-CLOSEOUT.1` | Strict source scans for retired helpers (`declare`, `assign`, `array_copy`, `hash_copy`, `concat`, short wrappers, old hash arrows) and host-action residue (`$$STRING`, `$IPOS`, `$LSPOS`, `$LMATCH`, `CAPTURE`, `sub {`, raw `eval`, raw `pos($$STRING)`, raw Perl list vars); all 21 root descriptors via `LinkedSpec::get_parser(..., return_descriptor=>1)`; focused hlink and pplugin runtime probes; `perl -c -Iperl perl/PPlugin.pm`; `perl -c -Iperl tools/gen_oracle_corpus.pl`; `PERL5LIB= perl -Iperl tools/gen_oracle_corpus.pl`; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference -- --nocapture`; `PERL5LIB= prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `git diff --check`; `bash tools/run_ci_local.sh` | PASS - root specs are clean for retired/host-residue source spellings; every shipped descriptor reports `1.0000 0 0`; hlink bracket/mixed outputs are neutral strings and active in the Rust oracle; pplugin parser returns body text while `PPlugin.pm` preserves legacy coderef execution; Rust oracle passes over 99 fixtures; phase0 passes `1..1028`; full local CI passes. |

## Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — User directive required completing the all-root `specs/*.spec`
  terse-source migration before moving to other activities; source scans identified remaining host-action
  residues in `hlink_substitution`, `pplugin`, `Lispish`, `ebnf`, `simenv`, and `vhdl`.
- [x] **ROOT CAUSE (WHY + WHERE)** — The earlier descriptor-clean state did not prove source-format closure:
  `hlink_substitution.spec` still returned a Perl scalar-reference payload, `pplugin.spec` built plugin coderefs
  inside the spec, and several specs still contained raw Perl/source-position residues even though descriptor
  compatibility metadata was green.
- [x] **FIX** — Migrated those residues to accepted helper/value forms, moved pplugin coderef wrapping into
  `perl/PPlugin.pm`, added the neutral hlink bracket/mixed oracle cases, and synced live docs, mdBook, Knowledge
  cards, and task-tree state.
- [x] **ADDRESSED (verified)** — Retired-helper scans, host-residue scans, 21-descriptor sweep, focused hlink and
  pplugin probes, oracle regeneration, and the 99-fixture Rust oracle all pass; hlink bracket outputs are JSON
  strings and pplugin parser output is body text.
- [x] **NO REGRESSION** — `PERL5LIB= prove -q -Iperl t/phase0_regression.t` passes `1..1028`; `mdbook build`,
  Knowledge Map, memory, doctrine, task metadata, and whitespace checks pass.
- [x] **LOCKSTEP** — `bash tools/run_ci_local.sh` passes after the source/corpus/docs sync; Rust oracle manifest,
  generated fixtures, mdBook, Knowledge Map, and live docs all agree on the 99-fixture state.

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SPEC-SOURCE-TERSE-CLOSEOUT.1` | `SPEC-SOURCE-TERSE-CLOSEOUT.1 - close root spec terse source` | Pending commit execution. |

## Changelog

- `2026-07-08`: Created task tree for the exhaustive root-spec terse source closeout.
- `2026-07-08`: Completed the source closeout. Migrated the remaining root-spec host-action
  residues in `hlink_substitution`, `pplugin`, `Lispish`, `ebnf`, `simenv`, and `vhdl`;
  added `hlink_bracket_body` and `hlink_mixed_bracket_brace` to the Rust oracle; kept
  pplugin body execution in the Perl `PPlugin` adapter rather than in `specs/pplugin.spec`.
