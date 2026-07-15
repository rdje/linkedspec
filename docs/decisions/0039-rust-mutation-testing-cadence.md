# 0039 - Rust mutation testing is explicit and milestone-scoped

- Date: 2026-07-15
- Status: accepted direction; implementation pending
- Tags: rust, testing, mutation-testing, cargo-mutants, quality, local-ci, resources

## Context

LinkedSpec's Rust workspace has broad unit, integration, corpus-oracle, generated-source, CLI, Unicode, trace, and
contract tests. Those passing tests prove known behavior, but ordinary coverage cannot show whether assertions
would detect plausible semantic changes. The director uses `cargo-mutants` on other Rust projects and proposed it
for LinkedSpec.

The tool is already installed locally as `cargo-mutants 27.0.0`. A list-only workspace census on 2026-07-15 found
3,333 candidate mutations in 19 production files: 1,217 in `linkedspec-core` and 2,116 in `linkedspec-runtime`.
`engine.rs` alone contributes 1,343 candidates. Mutation campaigns rebuild and repeatedly run tests, so even
targeted campaigns are unsuitable for LinkedSpec's per-commit workflow.

## Decision

1. **Adopt mutation testing for Rust.** `cargo-mutants` will supplement, not replace, the existing Rust tests by
   detecting plausible changes that those tests fail to reject.
2. **Never execute mutants per commit.** No mutation campaign—full, diff-scoped, or file-scoped—belongs in the
   commit workflow, pre-commit hooks, or ordinary local CI. Normal focused and broader tests remain those gates.
3. **Use explicit campaigns.** Mutation execution is a deliberate on-demand investigation or a meaningful
   milestone/release/admission activity. Targeted files come first; broad campaigns are resource-guarded and
   sharded only when measured cost and value justify them.
4. **Keep semantic code in scope.** Hand-written parser, validation, compiler, expression, runtime, engine, helper,
   loader, staged, diagnostic, trace, source-emitter, identity, serialization, and observable adapter logic are
   candidates. File size alone is not an exclusion.
5. **Exclude generated truth, not difficult truth.** The auto-generated
   `rust/linkedspec-runtime/src/unicode_case_mapping.rs` is initially excluded because its generator, exact-byte
   regeneration check, neutral fixture, and runtime proof are authoritative. Other exclusions require similarly
   narrow durable evidence.
6. **Classify every non-caught result.** Survivors, timeouts, and unviable mutants are distinct. Survivors are
   classified as a test gap, equivalent/redundant behavior, unreachable/dead code, deliberately unspecified
   behavior, or tool limitation. True gaps gain focused behavior tests; exclusions record exact rationale.
7. **Do not chase a vanity score.** A mutation percentage is meaningful only for a fixed comparable campaign.
   Signoff centers on survivor dispositions, strengthened contracts, reproducible command/config/tool identity,
   and measured cost.
8. **Own resources and artifacts.** The future repo command must make scope explicit, refuse an accidental full
   run, bound parallelism/timeouts/output, use disposable scratch/output storage, and document deterministic
   cleanup. Hosted CI remains disabled under ADR `0004`.

## Consequences

- `RUST-MUTATION-TESTING` owns configuration, a safe manual command surface, a bounded pilot, survivor-driven test
  strengthening, and final milestone cadence.
- The first implementation slice adds policy/configuration only; the first mutation execution is a separately
  committed pilot with its exact resource and result record.
- Rust feature work and current Lua parity do not wait on this optional verification program.
- A future release may require a named mutation campaign, but ordinary commits never do.
- This planning decision changes no Rust code, test result, CI behavior, or claimed mutation score.

## Links

- Parent owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` `.20`
- Detailed tree: `docs/tasks/RUST-MUTATION-TESTING.md`
- Local CI policy: ADR `0004`
- Rust gate: `tools/run_rust_local.sh`
