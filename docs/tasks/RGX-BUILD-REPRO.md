# RGX-BUILD-REPRO: rgx-core build failure — cold-clone reproduction report

## Metadata

- Tree ID: `RGX-BUILD-REPRO`
- Status: `done`
- Roadmap lane: `Phase 9 — Rust variant (rgx evaluation unblock)`
- Created: `2026-06-15`
- Last updated: `2026-06-15` (updated post-upstream-fix: rgx build verified working)
- Owner: repo-local workflow
- Upstream: https://github.com/rdje/rgx

## Goal

Provide a self-contained, copy-paste reproduction report so the rgx upstream maintainer
can reproduce the two build failures observed on a cold clone of rgx at commit `b771c7b`
and provide a fix or bootstrap procedure.

## Non-Goals

- Does NOT attempt to fix the rgx code ourselves (that's upstream domain).
- Does NOT cover runtime correctness or API behavior of rgx — this is purely a
  **build/bootstrap** reproduction report.
- Does NOT evaluate the `regex` crate migration path (that was `.2.3`, already done).

## Acceptance Criteria

- Bug report with exact reproduction steps is filed and self-contained.
- Each build path documents: exact command, observed error, root-cause analysis, and
  suggested fix direction.
- The report is complete enough that an upstream maintainer can reproduce and fix
  without needing to ask for additional environment details.

## Environment (critical — include in any upstream communication)

| Item | Value |
| --- | --- |
| rgx repository | `https://github.com/rdje/rgx` |
| rgx commit (original broken) | `b771c7b872675a333b2c42571249ba7b36435d2f` |
| rgx commit (current, fixed) | `8763a0e6bea97879f027237439d57725f83ead23` (HEAD of `main`) |
| Rust version | `rustc 1.95.0 (59807616e 2026-04-14)` |
| Edition | `2021` (workspace) |
| OS | macOS 26.1 (Darwin arm64) |
| Host project | `https://github.com/rdje/linkedspec` (rgx submodule at repo root) |

## Task Tree

- ID: `RGX-BUILD-REPRO`
  Status: `done`
  Goal: `Reproduce, document, and report two rgx-core build failures on cold clone.`
  Children: `.1`

- ID: `RGX-BUILD-REPRO.1`
  Status: `done`
  Goal: `File self-contained reproduction report upstream. Two build paths fail on cold clone: (A) default features — pgen crate missing generated file "subs/pgen/rust/src/../../generated/return_annotation_parser.rs" (bootstrap step not documented/automated). (B) --no-default-features — missing CharRange import (feature-gate bug), non-exhaustive ast::Regex match in parser.rs (12 missing variants), Rust 2024 edition _ expression issues.`
  Acceptance: `Upstream maintainer can reproduce both failures from the information in this task-tree. Path forward received (fix, bootstrap doc, or crates.io publish).`
  Verification: `Upstream fix confirmed — BUILD-FLOW.1 adds 'make build' entrypoint (hides PGEN bootstrap), BUILD-FLOW.2 fixes --no-default-features build. Cold-clone 'make' succeeds on macOS arm64, rustc 1.95.0.`
  Commit: `8763a0e` (rgx upstream), linkedspec submodule pin bumped b771c7b→8763a0e

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | — | — | Tree complete |

## Reproduction Details

### How to reproduce

```bash
# 1. Clone the host project (which already has rgx as a submodule)
git clone https://github.com/rdje/linkedspec.git
cd linkedspec
git submodule update --init rgx
cd rgx

# 2. Verify you are at the exact commit
git log --oneline -1
# Expected: b771c7b Book: no-BS pass — remove performance/parity overclaims, state verifiable facts

# 3. Verify Rust version
rustc --version
# Expected: rustc 1.95.0 (59807616e 2026-04-14)
```

### Build path A — default features (pgen-parser enabled)

```bash
cargo build -p rgx-core
# or equivalently:
cargo build --manifest-path Cargo.toml -p rgx-core
```

**Error:**
```
error: couldn't read `subs/pgen/rust/src/../../generated/return_annotation_parser.rs`:
No such file or directory (os error 2)
  --> subs/pgen/rust/src/lib.rs:43:9
   |
43 |         include!("../../generated/return_annotation_parser.rs");
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

error: could not compile `pgen` (lib) due to 1 previous error
```

**Root cause:** The `pgen` crate at `subs/pgen/rust/` uses `include!()` to embed a
generated file (`../../generated/return_annotation_parser.rs`) that does not exist in
the cold-clone source tree. The pgen submodule requires a **bootstrap step** to generate
this file before the crate can compile. The rgx README mentions this step:
`make -C subs/pgen/rust regex_parser_bootstrap` — but this is not run automatically by
`cargo build`, and the build fails with an unhelpful "file not found" error rather than
a clear "run the bootstrap first" message.

**Suggested fix direction:**
1. Add a `build.rs` to the `pgen` crate that either runs the bootstrap automatically
   or emits a clear compile-time error message: "pgen generated files missing — run
   `make -C subs/pgen/rust regex_parser_bootstrap` first."
2. OR: check the generated files into git so cold-clone `cargo build` works out of the box.
3. OR: publish pre-generated artifacts to crates.io so the `pgen` dependency doesn't
   need a local bootstrap.

### Build path B — `--no-default-features` (pgen-parser disabled)

```bash
cargo build -p rgx-core --no-default-features
# or equivalently:
cargo build --manifest-path Cargo.toml -p rgx-core --no-default-features
```

**Result: 35 errors across 3 root causes, plus 12 warnings.**

#### Error group B1 — `CharRange` behind feature gate (13 errors)

`CharRange` is imported under `#[cfg(feature = "pgen-parser")]` in `ast.rs`, but it is
used **unconditionally** in `parsing.rs:7293` (the `posix_class_ranges()` function).
When `--no-default-features` is passed, the `pgen-parser` feature is disabled, and
`CharRange` is not visible.

**Files/lines affected:**
- `rgx-core/src/ast.rs` — `CharRange` defined/imported behind `#[cfg(feature = "pgen-parser")]`
- `rgx-core/src/parsing.rs:7293-7313` — `posix_class_ranges()` uses `CharRange` without a feature gate

**Fix:** Either gate `posix_class_ranges()` on `#[cfg(feature = "pgen-parser")]`, or
move `CharRange` outside the feature gate (make it always available).

#### Error group B2 — non-exhaustive `ast::Regex` match (1 error, 12 missing variants)

`parser.rs:92` matches on `ast::Regex` but the match is non-exhaustive. When the
`pgen-parser` feature is disabled, the PGEN-backed parser (`Parser::parse_atom`) is
not compiled, so the `ast::Regex` enum's PGEN-specific variants (which presumably
would never be produced) are still visible to the exhaustiveness checker.

**Missing variants (12 total):**
1. `RelativeBackreference(i32)`
2. `ReturnedCaptureSubroutine { … }`
3. `Callout(u32)`
4. `MatchReset`
5. `NewlineSequence`
6. (plus 7 more)

**Files/lines affected:**
- `rgx-core/src/parser.rs:92` — the non-exhaustive match on `&ast::Regex`
- `rgx-core/src/ast.rs:11` — the `Regex` enum definition

**Fix:** Add a wildcard `_` arm to the match, or gate those `ast::Regex` variants on
`#[cfg(feature = "pgen-parser")]` so they don't appear in the exhaustiveness check
when the feature is off.

#### Error group B3 — Rust 2024 edition `_` expression issues (3 errors)

Rust 2024 edition treats bare `_` in some expression positions differently. The
following lines use `_` as a pattern in ways that the Rust 1.95 compiler rejects:

- `rgx-core/src/parser.rs:53` — `let initial_token = current_token.as_ref().map_or_else( …, _ )`
- `rgx-core/src/parser.rs:137` — `let token_snapshot = …`
- `rgx-core/src/parser.rs:158` — `let consumed_token = …`
- `rgx-core/src/parser.rs:182` — `let next_token = …`
- `rgx-core/src/parser.rs:460` — `let has_quantifier = …`
- `rgx-core/src/parser.rs:556` — `ci_override_ranges: _,`
- `rgx-core/src/c2/simd_scan.rs:83` — unreachable expression after `return`
- `rgx-core/src/c2/simd_scan.rs:104` — same
- `rgx-core/src/vm.rs:4114` — `let mut match_count = 1;`

**Fix:** Replace bare `_` with `_unused` or `_var` naming, and use `_ =>` in match arms.

### Feature-gate topology

```
rgx-core default features: ["std", "pgen-parser", "jit"]

pgen-parser = ["dep:pgen", "dep:serde", "dep:serde_json", "dep:serde_stacker"]

When pgen-parser is OFF:
  - pgen, serde, serde_json, serde_stacker are NOT compiled
  - ast::CharRange is NOT imported
  - parsing.rs:7293 posix_class_ranges() fails — CharRange not in scope (B1)
  - parser.rs:92 ast::Regex match is non-exhaustive (B2)
  - The PGEN-backed Parser is not compiled
```

## Decisions

- `2026-06-15`: **ADR: rgx adoption DEFER** (see `RUST-FUNCTIONAL-PARITY.2.3`). The
  API audit confirmed all required primitives exist. Adoption is deferred until rgx
  builds on a cold clone (either via `cargo build` working out of the box, or via
  crates.io publication). The existing `regex` crate with the look-around workaround
  (`.2.2`) remains sufficient for LinkedSpec v1.
- `2026-06-15`: This task-tree is explicitly a **communication artifact** targeted at
  the rgx upstream maintainer. It is not a LinkedSpec implementation tree — zero
  LinkedSpec code changes are expected. It blocks `.2.4` in `RUST-FUNCTIONAL-PARITY`.

## Blockers

- ~~**`.1`** — Waiting for upstream rgx response.~~ **RESOLVED.** Upstream rgx commits `BUILD-FLOW.1` through `BUILD-FLOW.4` provide: (a) a `make` build entrypoint that hides the PGEN bootstrap (`BUILD-FLOW.1`), (b) a fix for the `--no-default-features` build (`BUILD-FLOW.2`), (c) a knowledge-map card and downstream response (`BUILD-FLOW.3`), and (d) `docs/INTEGRATION.md` downstream handoff guide (`BUILD-FLOW.4`). Cold-clone `make` verified working.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-15` | `.1` | Both build paths reproduced from cold clone; errors documented | reproduced |
| `2026-06-15` | `.1` | Upstream fix verified: `make` succeeds on cold clone (macOS arm64, rustc 1.95.0); default features + PGEN bootstrap work | passed |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `RGX-BUILD-REPRO.1 — rgx submodule pin bumped b771c7b→8763a0e, build fix verified` | Upstream BUILD-FLOW.1–.4 resolved both cold-clone build issues |

## Changelog

- `2026-06-15`: Created task tree. Extracted from `RUST-FUNCTIONAL-PARITY.2.4` with
  full cold-clone reproduction details for both build paths.
- `2026-06-15`: **Closed.** Upstream rgx BUILD-FLOW fixes resolved both build failures.
  rgx submodule pin bumped from `b771c7b` to `8763a0e`. Tree complete.
