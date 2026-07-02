# SCALAREF-RETIREMENT: Retire Legacy `scalaref(...)` Access

## Metadata

- Tree ID: `SCALAREF-RETIREMENT`
- Status: `active`
- Roadmap lane: `Overall roadmap — .spec language evolution / compatibility retirement`
- Created: `2026-07-02`
- Last updated: `2026-07-02` (`.4` done — implementation support removed; frontier `.5`)
- Owner: repo-local workflow

## Goal

Retire and remove the legacy `scalaref(...)` helper surface from the public DSL and implementation, replacing it
with canonical direct nested access and the eventual non-Perl-shaped hash/object literal surface.

## Non-Goals

- Do not undo `RUST-PARITY.7.5.2`; that slice restored Rust parity for the existing shipped Lispish surface.
- Do not remove `scalaref(...)` before shipped specs, oracle fixtures, tests, and docs have a canonical replacement.
- Do not silently preserve `scalaref(...)` as a hidden compatibility helper after the removal leaf lands.
- Do not broaden the removal to unrelated helper families unless the inventory proves they are the same surface.

## Acceptance Criteria

- Every live `scalaref(...)` use in shipped specs, tests, docs, and Rust/Perl implementation code is inventoried.
- A canonical replacement is selected and documented before code removal.
- Shipped specs and corpus fixtures no longer require `scalaref(...)`.
- Perl and Rust reject or no longer recognize `scalaref(...)` consistently after the removal leaf.
- The mdBook no longer teaches `scalaref(...)` as a user-facing helper.
- Knowledge Map and live docs record the replacement contract and removal evidence.
- Focused tests plus the broader gates pass.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `SCALAREF-RETIREMENT`
  Status: `active`
  Goal: Retire and remove the legacy `scalaref(...)` access helper.
  Children: `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `SCALAREF-RETIREMENT.1`
  Status: `done`
  Goal: Own the 2026-07-02 user directive that `scalaref(...)` shall be retired/removed, and split the retirement migration before any behavior change.
  Acceptance: This task tree exists, `docs/TASK_TREE.md` links it, roadmap/live docs record the directive, and the next executable leaf is an inventory/design pass.
  Verification: Done — 2026-07-02. Created this tree after `RUST-PARITY.7.5.2` restored Rust parity for the existing shipped Lispish surface. The removal is explicitly split so no code/spec/book behavior changes happen without a dedicated owner.
  Commit: `SCALAREF-RETIREMENT.1 - own scalaref retirement track` (see Commit Log)

- ID: `SCALAREF-RETIREMENT.2`
  Status: `done`
  Goal: Inventory all `scalaref(...)` use and select the canonical replacement contract.
  Acceptance: Grep/code-search inventory covers `specs/`, `perl/`, `rust/`, `t/`, `docs/`, oracle fixtures, and generated/reference docs; every live use is classified as shipped-spec behavior, test-only lock, implementation support, or historical prose. The replacement contract states when direct nested access is sufficient and what remains blocked by hash/object literal spelling.
  Verification: Done — 2026-07-02. `rg` inventory covered shipped specs, corpus fixtures, Perl/Rust implementation, tests, tools, mdBook, user guides, live docs, task trees, and Knowledge Map. Perl lowering and Rust parser/runtime direct-access probes prove the replacement contract.
  Commit: `SCALAREF-RETIREMENT.2 - inventory scalaref retirement contract` (see Commit Log)

- ID: `SCALAREF-RETIREMENT.3`
  Status: `done`
  Goal: Migrate shipped specs, tests, oracle fixtures, and public docs away from `scalaref(...)`.
  Acceptance: No shipped spec or public book example requires `scalaref(...)`; Lispish and every migrated fixture still produce the same reference output through the canonical replacement; docs call `scalaref(...)` retired/removal-bound rather than supported.
  Verification: Done — 2026-07-02. Active `scalaref(` / `.scalaref(` scans are clean across shipped specs, checked-in corpus, public docs, tests, and generator. Lispish and migrated receiver-chain fixtures stay green with stable expected output.
  Commit: `SCALAREF-RETIREMENT.3 - migrate scalaref live surface` (see Commit Log)

- ID: `SCALAREF-RETIREMENT.4`
  Status: `done`
  Goal: Remove `scalaref(...)` recognition/execution from Perl and Rust.
  Acceptance: Perl lowering/scanner contracts and Rust parser/runtime no longer accept `scalaref(...)` as a supported helper; unsupported uses fail consistently with the current diagnostic policy; focused negative tests lock the rejection; migrated positive tests stay green.
  Verification: Done — 2026-07-02. Perl function-form and receiver-dot support removed from ActionIR lowering/flow/return paths; Rust `ScalarRefPath` parsing/runtime dispatch removed; focused Perl/Rust negative locks added while migrated direct-access positives stay green.
  Commit: `SCALAREF-RETIREMENT.4 - remove scalaref implementation support` (pending commit in this slice)

- ID: `SCALAREF-RETIREMENT.5`
  Status: `pending`
  Goal: Final drift sweep and close-out.
  Acceptance: No stale `scalaref(...)` support claims remain outside historical logs; Knowledge Map points to the replacement/removal contract; mdBook, roadmap, live docs, and task-tree status agree; full local gate passes; tree closes.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `SCALAREF-RETIREMENT.1` | `done` | Directive owned and split before behavior changes. |
| — | `SCALAREF-RETIREMENT.2` | `done` | Inventory and replacement contract locked before behavior changes. |
| — | `SCALAREF-RETIREMENT.3` | `done` | Live specs/tests/docs migrated after the replacement contract was locked. |
| — | `SCALAREF-RETIREMENT.4` | `done` | Implementation support removed after live users were migrated. |
| 1 | `SCALAREF-RETIREMENT.5` | `pending` | Final no-drift sweep and tree close. |

## Inventory and Replacement Contract

`SCALAREF-RETIREMENT.2` classified the current surface as follows:

| Class | Files | Finding | Replacement |
| --- | --- | --- | --- |
| Shipped specs | `specs/Lispish.spec`, `specs/pplugin.spec`, `specs/ds_vhistory.spec`, `specs/tablegrep.spec` | 16 function-form `scalaref(...)` calls. | Use direct nested access: `{field}` -> `["field"]`, `[0]` -> `[0]`, and mixed `[0]{name}` -> `[0]["name"]`. |
| Oracle fixtures | `rust/linkedspec-runtime/tests/corpus/lispish_x_y/input.spec`, `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_2_hash_receiver_value_chains/input.spec` | 6 calls in checked-in corpus inputs: 4 function-form Lispish calls and 1 receiver-dot hash call, plus one duplicate match from the grep expression. | Regenerate fixtures after spec/test migration; keep expected JSON unchanged. |
| Implementation support | `perl/LinkedSpec/ActionIR/{ValueExpr,MethodLowering,FlowExpr}.pm`, `perl/LinkedSpec/RuleIR/EmitContext.pm`, `rust/linkedspec-core/src/{expr,validation}.rs`, `rust/linkedspec-runtime/src/engine.rs` | Perl owns function-form lowering and receiver-dot method lowering; Rust owns scoped `ScalarRefPath`, validation, runtime dispatch, and receiver-dot execution. | Remove in `.4` now that `.3` migrated live uses; `.4` locks negative behavior. |
| Tests/tools | `t/phase0_regression.t`, `rust/linkedspec-runtime/tests/integration_test.rs`, `tools/gen_oracle_corpus.pl`, `rust/README.md`, corpus README | Positive locks, generated fixtures, and helper inventories still teach or depend on `scalaref`. | Migrate positive tests to direct access or `scalar(hash(...), key)`; add negative tests in `.4`. |
| Public docs | `docs/linkedspec-book/src/**`, `USER_GUIDE*.md` | 332 public/user-guide function-form references plus receiver-dot examples. | Replace examples during `.3`; historical architecture notes can remain only when explicitly labeled historical/retired. |
| Historical live docs | `docs/tasks/**`, `docs/knowledge/**`, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, `KNOWLEDGE_MAP.md` | Prior evidence records mention the old helper. | Preserve historical records, but add current retirement facts and avoid stale support claims in live status. |

Canonical replacement:

- Function form `scalaref(base, {key})` becomes `base["key"]`.
- Function form `scalaref(base, [0])` becomes `base[0]`.
- Mixed function paths such as `scalaref(base, {children}[0]{name})` become `base["children"][0]["name"]`.
- Dynamic array indexes use direct bare or explicit scalar indexes: `base["children"][i]` or `base["children"][scalar(i)]`.
- Receiver-dot `.scalaref("key")` is in scope for retirement because it is the same public field-read helper name. For a named working hash, use `scalar(hash(meta), "key")`. Direct bracket reads such as `retv["key"]` are for scalar hashref payloads, not working-hash value reads. For an expression receiver such as `meta.merge_hash(hash(extra)).scalaref("a")`, assign the expression to a named working hash first, then read `scalar(hash(temp), "a")`.

## Decisions

- `2026-07-02`: User directive accepted: `scalaref(...)` shall be retired and removed. The directive is split into this tree rather than folded into `RUST-PARITY.7.5.2` because `.7.5.2` is a parity fix for the current shipped surface, while retirement changes the language contract.
- `2026-07-02`: Replacement is expected to be direct nested access plus the future non-Perl-shaped hash/object literal surface, but `.2` must prove the exact contract from current uses before code changes.
- `2026-07-02`: `.2` proved direct nested access is sufficient for function-form shipped spec calls. Receiver-dot `.scalaref(key)` is also in retirement scope; expression receivers require a named working-hash temporary before reading with `scalar(hash(temp), key)`. Direct bracket reads remain valid for scalar hashref payloads such as `retv["key"]`, not as working-hash value reads.
- `2026-07-02`: `.3` migrated the active live surface away from both function-form and receiver-dot `scalaref` examples. Implementation recognition remains only as pre-removal compatibility until `.4`.
- `2026-07-02`: `.4` removed implementation recognition/execution. Old `scalaref(...)` spellings now follow the existing unsupported-helper/unknown-helper policy; direct nested access and named working-hash reads are the supported replacements.

## Open Questions

- Should unsupported `scalaref(...)` produce a dedicated retirement diagnostic or fall through to the existing unknown-helper path?
- Should a later feature add direct indexing on arbitrary expression receivers, or is named-temp migration sufficient for receiver-dot `.scalaref(...)` retirement?

## Blockers

- None for `.4`; live users are migrated and implementation removal is unblocked.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-02` | `SCALAREF-RETIREMENT.1` | Task-tree/index/roadmap/live-doc/KM tracking only; Knowledge Map regeneration/check, memory architecture, doctrine registry, mdBook build, `git diff --check` | Directive owned; no behavior change |
| `2026-07-02` | `SCALAREF-RETIREMENT.2` | `rg` inventory across specs, corpus, Perl/Rust implementation, tests, tools, mdBook, user guides, live docs, task trees, and Knowledge Map; Perl `call_spec_handler_subst` direct-access probes; Rust direct-access parser/runtime focused tests; Knowledge Map/memory/doctrine/diff checks in commit workflow | Replacement contract locked; no behavior change |
| `2026-07-02` | `SCALAREF-RETIREMENT.3` | `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`; `perl -c tools/gen_oracle_corpus.pl`; `perl tools/gen_oracle_corpus.pl`; focused Rust `scalaref_retirement_3`, hash receiver-chain, and hash consumer tests; Rust corpus oracle; `perl -c -Iperl t/phase0_regression.t`; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; `cargo fmt --manifest-path rust/linkedspec-runtime/Cargo.toml --check`; active `scalaref(` / `.scalaref(` scans; `git diff --check` | Live specs/tests/corpus/docs migrated; phase0 1015 green; corpus oracle 63 fixtures green |
| `2026-07-02` | `SCALAREF-RETIREMENT.4` | Perl syntax checks for `ValueExpr.pm`, `MethodLowering.pm`, `FlowExpr.pm`, `EmitContext.pm`, and `t/phase0_regression.t`; `prove -q -Iperl t/phase0_regression.t`; focused Rust parser/runtime checks for direct access and `scalaref_retirement_3`/`.4`; `cargo fmt --all -- --check`; `cargo check` for `linkedspec-core` and `linkedspec-runtime`; Rust corpus oracle; implementation removal scan; public-surface scan; `mdbook build docs/linkedspec-book`; Knowledge Map, memory architecture, doctrine registry, and diff checks | Implementation support removed; rejection behavior locked; migrated positives stay green; phase0 1015 green |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SCALAREF-RETIREMENT.1` | `SCALAREF-RETIREMENT.1 - own scalaref retirement track` | Tracking-only split; next executable leaf is `.2` inventory/design. |
| `SCALAREF-RETIREMENT.2` | `SCALAREF-RETIREMENT.2 - inventory scalaref retirement contract` | Inventory/replacement contract only; next executable leaf is `.3` migration. |
| `SCALAREF-RETIREMENT.3` | `SCALAREF-RETIREMENT.3 - migrate scalaref live surface` | Shipped specs, checked-in corpus, tests, and public docs no longer use active `scalaref` examples; next executable leaf is `.4` implementation removal. |
| `SCALAREF-RETIREMENT.4` | `SCALAREF-RETIREMENT.4 - remove scalaref implementation support` | Perl/Rust implementation support removed; next executable leaf is `.5` final drift sweep. |

## Changelog

- `2026-07-02`: Created tree from user directive that `scalaref(...)` shall be retired and removed.
- `2026-07-02`: `.2` inventory done. Function form migrates to direct nested access; receiver-dot form migrates through named hash temporaries where the receiver is an expression.
- `2026-07-02`: `.3` migration done. Active `scalaref` examples are gone from shipped specs, checked-in corpus, tests, generator, mdBook, and user guides; implementation removal moves to `.4`.
- `2026-07-02`: `.4` implementation removal done. Perl/Rust no longer support function-form or receiver-dot `scalaref`; final drift sweep moves to `.5`.
