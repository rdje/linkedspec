# NONCURRENT-HELPER-CODE-PURGE: Remove Non-Current Helper Spellings From Code

## Metadata

- Tree ID: `NONCURRENT-HELPER-CODE-PURGE`
- Status: `done`
- Roadmap lane: `.spec language evolution / codebase no-drift`
- Created: `2026-07-09`
- Last updated: `2026-07-09`
- Owner: repo-local workflow

## Goal

Remove explicit non-current helper spelling support, diagnostics, fixtures, labels, and source references from
the Perl and Rust codebases so removed helper names are not recognized, specially parsed, or preserved as
runtime/test/tool source surface. Helper-looking calls outside the current contract must flow through generic
unknown-helper handling, not through a name-specific removal compatibility layer.

## Non-Goals

- Do not change current helper semantics or accepted current aliases.
- Do not broaden the `.spec` language or add compatibility aliases.
- Do not rewrite historical project documentation in this tree unless it blocks code/test verification.
- Do not touch the Dart `.3.3` function-registry work until this directive is either exhausted or explicitly
  reprioritized after a clean commit boundary.

## Acceptance Criteria

- Perl source no longer contains explicit recognition paths, diagnostic helpers, or source-preservation logic for
  the non-current helper spelling set owned by `SPEC-FORMAT-TERSE.8`.
- Rust source no longer contains explicit recognition paths, diagnostic helpers, or source-preservation logic for
  the same non-current helper spelling set.
- Active Perl/Rust tests and tool-generated fixtures no longer embed those spellings as helper calls or code
  examples; equivalent current-surface tests use current spellings or generic invented unknown-helper names.
- Checked-in `.spec` grammar labels, helper strings, and generated corpus inputs are renamed or migrated where
  they collide with removed helper names, with expected-output drift reviewed deliberately.
- Focused scans over `perl/`, `rust/`, `t/`, `tools/`, `bin/`, and `specs/` are clean for the owned spelling set,
  excluding only generic language words that are not helper names in context.
- Focused Perl/Rust checks and the broader gate pass where the blast radius warrants it.
- Live docs, task-tree status, and Knowledge Map facts stay aligned after each leaf.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `NONCURRENT-HELPER-CODE-PURGE`
  Status: `done`
  Goal: Remove non-current helper spelling support/references from Perl and Rust code surfaces.
  Children: `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `NONCURRENT-HELPER-CODE-PURGE.1`
  Status: `done`
  Goal: Inventory and split the Perl/Rust code purge before implementation.
  Acceptance: Read-only scans identify the source/test/tool/spec owner categories; executable leaves are split
    before any parser/runtime code edits.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.1 - split code purge task tree`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.34`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree NONCURRENT-HELPER-CODE-PURGE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.34 --id NONCURRENT-HELPER-CODE-PURGE.1`.

- ID: `NONCURRENT-HELPER-CODE-PURGE.2`
  Status: `done`
  Goal: Remove Perl source recognition and diagnostic paths for non-current helper spellings.
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`

- ID: `NONCURRENT-HELPER-CODE-PURGE.2.1`
  Status: `done`
  Goal: Stop Perl current helper lowering from normalizing through old string/copy/assignment/append helper names.
  Acceptance: Current `cat(...)`, `copy(...)`, `set(...)`, and `push(...)` semantics lower through current method
    names; old source spellings in this family no longer have a name-specific parser/lowering/contract branch or
    diagnostic-only lowerer in the touched Perl ActionIR source owners.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.2.1 - purge Perl current helper compatibility`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.34`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree NONCURRENT-HELPER-CODE-PURGE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.34 --id NONCURRENT-HELPER-CODE-PURGE.2.1`.

- ID: `NONCURRENT-HELPER-CODE-PURGE.2.2`
  Status: `done`
  Goal: Remove Perl declaration, return-family, and short-wrapper helper-specific source owner paths.
  Acceptance: Declaration helper spellings, old return-family helper spellings, and short/old scalar-wrapper
    helper spellings are no longer recognized through dedicated source-owner paths; current return, `return_undef`,
    auto-existing variable, assignment/reset, `array(...)`, `hash(...)`, and bare-read behavior still lowers.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.2.2 - purge Perl declaration and return helper paths`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.34`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree NONCURRENT-HELPER-CODE-PURGE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.34 --id NONCURRENT-HELPER-CODE-PURGE.2.2`.

- ID: `NONCURRENT-HELPER-CODE-PURGE.2.3`
  Status: `done`
  Goal: Remove remaining Perl non-current helper IDs from contract/canonical/flow metadata.
  Acceptance: Perl contract scans and canonical event metadata only list current helper/control IDs or generic
    unknown-helper fallback paths.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.2.3 - purge Perl helper metadata names`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.34`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree NONCURRENT-HELPER-CODE-PURGE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.34 --id NONCURRENT-HELPER-CODE-PURGE.2.3`.

- ID: `NONCURRENT-HELPER-CODE-PURGE.2.4`
  Status: `done`
  Goal: Close Perl source purge scans and focused tests.
  Acceptance: Perl ActionIR parser/lowering/runtime source stops branching on the removed helper names; current
    helpers still lower; non-current helper-looking calls use generic unknown-helper behavior.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.2.4 - close Perl source purge scans`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.34`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree NONCURRENT-HELPER-CODE-PURGE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.34 --id NONCURRENT-HELPER-CODE-PURGE.2.4`.

- ID: `NONCURRENT-HELPER-CODE-PURGE.3`
  Status: `done`
  Goal: Remove Rust source recognition and diagnostic paths for non-current helper spellings.
  Acceptance: Rust parser/runtime source stops branching on the removed helper names; current helpers still parse
    and execute; non-current helper-looking calls use generic unknown-helper behavior.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.3 - purge Rust helper diagnostics`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.34`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree NONCURRENT-HELPER-CODE-PURGE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.34 --id NONCURRENT-HELPER-CODE-PURGE.3`.

- ID: `NONCURRENT-HELPER-CODE-PURGE.4`
  Status: `done`
  Goal: Migrate active tests, tools, generated fixtures, and checked-in `.spec` labels away from non-current helper
    spellings.
  Acceptance: Active Perl/Rust test strings, tooling fixtures, generated corpus inputs, and checked-in `.spec`
    labels/source strings no longer carry the removed helper spellings except unavoidable generic-language false
    positives.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.4 - migrate retired helper fixtures`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.34`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree NONCURRENT-HELPER-CODE-PURGE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.34 --id NONCURRENT-HELPER-CODE-PURGE.4`.

- ID: `NONCURRENT-HELPER-CODE-PURGE.5`
  Status: `done`
  Goal: Final no-drift scan and documentation closeout for the Perl/Rust code purge.
  Acceptance: Focused scans and gates prove no remaining code/test/tool/spec references to the removed helper
    spelling set, and live docs/KM record the current generic unknown-helper policy.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.5 - close helper purge no-drift`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.34`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree NONCURRENT-HELPER-CODE-PURGE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.34 --id NONCURRENT-HELPER-CODE-PURGE.5`.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `NONCURRENT-HELPER-CODE-PURGE.5` | `done` | Final no-drift scan and documentation closeout completed; tree is closed. |

## Decisions

- `2026-07-09`: The director clarified that removed helper spellings must not appear in new Dart code and must
  also be deleted from the Perl and Rust codebases. Because the Dart `.3.2` tree was dirty at the time, the
  pivot waited until `DART-BACKEND-PARITY.3.2` was committed clean.
- `2026-07-09`: This tree treats the `SPEC-FORMAT-TERSE.8` non-current helper set as the source of truth without
  re-encoding the spelling list into new implementation code.
- `2026-07-09`: Broad textual scans are diagnostic only. Several words in the historical denylist are common
  implementation terms, so each implementation leaf must confirm context before editing.

## Open Questions

- None. Tree complete.

## Blockers

- None known before `.5`.

## Verification Log

- `2026-07-09` — `.2.1` removed Perl current-helper normalization through old string/copy/assignment names,
  removed the removed append-helper contract/scanner/lowering branches, renamed the current append lowerer to
  current `push` terminology, and updated AST tests to fabricate current helper AST calls only. Focused syntax,
  AST parser, compact-lowerer, direct current-helper probes, and removed-append scans pass.
- `2026-07-09` — `.2.2` removed Perl declaration/return/wrapper helper-call source-owner paths, rewrote active
  regression fixtures away from those spellings, and kept current return/setup/read behavior green. Focused syntax,
  AST parser, compact-lowerer, scoped exact scans, and full phase0 (`1027` tests) pass.
- `2026-07-09` — `.2.3` removed exact retired helper names from raw-compat ActionIR diagnostic metadata, added a
  focused metadata regression test, and kept Perl ActionIR metadata plus phase0 green.
- `2026-07-09` — `.2.4` closed Perl source purge scans and behavior probes. Exact retired-helper call-shape scans
  over Perl source are clean, current helper lowering probes pass, retired value-position helper-looking calls use
  the generic unsupported-helper sentinel, focused ActionIR tests pass, and full phase0 remains green (`1027`
  tests).
- `2026-07-09` — `.3` removed Rust source recognition and name-specific retired-helper diagnostic paths. Rust
  known-call validation no longer admits retired helper spellings, `declare(...)` keyword arguments are not
  specially parsed, retired helper-looking runtime calls use the generic unknown-helper fallback, and full
  `linkedspec-core` plus `linkedspec-runtime` package tests pass.
- `2026-07-09` — `.4` migrated active tests, tools, generated fixtures, and checked-in `.spec` labels/source
  strings away from retired helper spellings. EBNF return-label collisions now use `return_scalar_value` /
  `return_array_value`; portmap concatenation output now uses `?concatenation:`; focused scans, full phase0, full
  `linkedspec-runtime`, corpus oracle, and mdBook build pass.
- `2026-07-09` — `.5` closed the final no-drift audit. One remaining Rust runtime unit-test fixture that used
  retired helper strings for generic fallback coverage was migrated to invented unknown helper names. Final exact
  retired-helper call-shape, label/tag, `?concat:`, scalar-wrapper, and short-wrapper scans are clean or classified
  as non-helper input text false positives; Rust formatting and the focused generic unknown-helper runtime unit
  test pass.

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `NONCURRENT-HELPER-CODE-PURGE.1` | Read-only scans over `perl`, `rust`, `t`, `tools`, `scripts`, `bin`, and `specs`; task-tree split. | PASS. Owner categories are known; implementation starts with Perl source. |
| `2026-07-09` | `NONCURRENT-HELPER-CODE-PURGE.2.2` | Perl syntax checks; `prove -q -Iperl t/actionir_ast_parser.t t/trace_actionir_compact_lowerers.t`; `PERL5LIB= prove -q -Iperl t/phase0_regression.t`; scoped exact scans; mdBook helper/status scan. | PASS. Source-owner paths for the removed declaration, return-family, and short-wrapper helper-call spellings are gone from the touched Perl/test surfaces. |
| `2026-07-09` | `NONCURRENT-HELPER-CODE-PURGE.2.3` | `perl -c -Iperl perl/LinkedSpec/ActionIR/Contracts.pm`; `perl -c -Iperl t/noncurrent_helper_metadata.t`; `prove -q -Iperl t/noncurrent_helper_metadata.t`; focused exact metadata scan; `prove -q -Iperl t/actionir_ast_parser.t t/trace_actionir_compact_lowerers.t t/noncurrent_helper_metadata.t`; `PERL5LIB= prove -q -Iperl t/phase0_regression.t`. | PASS. Raw-compat diagnostic labels no longer publish exact retired helper names, and metadata tests lock contract/canonical behavior against the retired helper set. |
| `2026-07-09` | `NONCURRENT-HELPER-CODE-PURGE.2.4` | Exact retired-helper call-shape scans over Perl source; direct current-helper and retired-helper behavior probes; `perl -c perl/LinkedSpec.pm`; `perl -c -Iperl t/noncurrent_helper_metadata.t`; `prove -q -Iperl t/noncurrent_helper_metadata.t t/actionir_ast_parser.t t/trace_actionir_method_lowering.t t/trace_actionir_pipeline.t`; `PERL5LIB= prove -q -Iperl t/phase0_regression.t`. | PASS. Perl source no longer has exact retired helper-call recognition paths; current helpers still lower; retired value-position helper-looking calls use the same unsupported-helper sentinel path as invented unknown helpers. |
| `2026-07-09` | `NONCURRENT-HELPER-CODE-PURGE.3` | Rust focused retired-helper scans; `cargo fmt --manifest-path rust/Cargo.toml --all --check`; `cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core`; `cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime`; focused runtime generic-unknown-helper and `scalaref_retirement_4` runs. | PASS. Rust source no longer recognizes or diagnoses retired helper spellings through name-specific paths; current helpers and runtime package tests remain green. |
| `2026-07-09` | `NONCURRENT-HELPER-CODE-PURGE.4` | Exact retired-helper call-shape scans; exact retired label/tag scans; exact `?concat:` scan; `perl -c -Iperl` for touched tests/tools; `prove -q -Iperl t/noncurrent_helper_metadata.t`; `prove -q -Iperl t/phase0_validation_fuzz.t`; `PERL5LIB= prove -q -Iperl t/phase0_regression.t`; `perl tools/gen_oracle_corpus.pl`; Rust focused integration tests; `cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle`; `cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime`; `mdbook build docs/linkedspec-book`. | PASS. Active tests/tools/specs/corpus inputs no longer carry removed helper spellings as executable calls or colliding labels/tags. |
| `2026-07-09` | `NONCURRENT-HELPER-CODE-PURGE.5` | Final exact retired-helper call-shape scans; retired label/tag scans; exact `?concat:` scan; scalar-wrapper scan; short-wrapper spec-surface scan; `cargo fmt --manifest-path rust/Cargo.toml --all --check`; focused `linkedspec-runtime` unknown-helper unit test. | PASS. Final active code/test/tool/spec no-drift closeout is clean; only short-wrapper scan hits are parser input text, not helper calls. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `NONCURRENT-HELPER-CODE-PURGE.1` | `NONCURRENT-HELPER-CODE-PURGE.1 - split code purge task tree` | Inventory/split before code edits. |
| `NONCURRENT-HELPER-CODE-PURGE.2.1` | `NONCURRENT-HELPER-CODE-PURGE.2.1 - purge Perl current helper compatibility` | Current `cat`/`copy`/`set`/`push` paths stay on current names. |
| `NONCURRENT-HELPER-CODE-PURGE.2.2` | `NONCURRENT-HELPER-CODE-PURGE.2.2 - purge Perl declaration and return helper paths` | Perl declaration/return/wrapper helper-call source-owner paths removed. |
| `NONCURRENT-HELPER-CODE-PURGE.2.3` | `NONCURRENT-HELPER-CODE-PURGE.2.3 - purge Perl helper metadata names` | Perl raw-compat metadata no longer uses exact retired helper names as diagnostic labels. |
| `NONCURRENT-HELPER-CODE-PURGE.2.4` | `NONCURRENT-HELPER-CODE-PURGE.2.4 - close Perl source purge scans` | Perl source purge closeout scans/probes passed; Rust source cleanup is next. |
| `NONCURRENT-HELPER-CODE-PURGE.3` | `NONCURRENT-HELPER-CODE-PURGE.3 - purge Rust helper diagnostics` | Rust source recognition and name-specific retired-helper diagnostics removed; fixture/tool/spec migration is next. |
| `NONCURRENT-HELPER-CODE-PURGE.4` | `NONCURRENT-HELPER-CODE-PURGE.4 - migrate retired helper fixtures` | Active test/tool/spec/corpus spellings migrated; final no-drift closeout is next. |
| `NONCURRENT-HELPER-CODE-PURGE.5` | `NONCURRENT-HELPER-CODE-PURGE.5 - close helper purge no-drift` | Final no-drift scan and docs/KM closeout; tree closed. |

## Changelog

- `2026-07-09`: Created task tree after the director's Perl/Rust code purge directive and split implementation
  into Perl source, Rust source, active tests/tools/spec fixtures, and final no-drift closeout.
- `2026-07-09`: Closed the Perl source purge container through `.2.4`; active frontier advances to Rust source
  cleanup under `.3`.
- `2026-07-09`: Closed Rust source recognition/diagnostic cleanup through `.3`; active frontier advances to
  active test/tool/generated fixture and checked-in `.spec` migration under `.4`.
- `2026-07-09`: Closed active test/tool/generated fixture and checked-in `.spec` migration through `.4`; active
  frontier advances to final no-drift scan and documentation closeout under `.5`.
- `2026-07-09`: Closed final no-drift scan and documentation closeout through `.5`; tree complete.
