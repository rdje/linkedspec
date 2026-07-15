# 0038 - Native parser acceleration is an optional derivative tier

- Date: 2026-07-15
- Status: accepted horizon; implementation pending
- Tags: architecture, parser, codegen, native, performance, generated-source, formats, portability

## Context

LinkedSpec's primary product promise is dynamic: load `foo.spec` on backend X and immediately obtain a functional
`foo` text-to-AST parser. The post-parity format program deliberately accepts that this universal dynamic parser
may not be the fastest possible parser for every format.

The project already has generated-source contract v1 across Perl, Rust, Dart, and Julia, with Lua parity planned.
That contract proves deterministic host source, independently loadable execution, normalized compiled-state
identity, structural-family validation, trace roles, diagnostics, and interpreter-first equivalence. Current Dart
and Julia emitters reconstruct normalized state and execute through their native in-memory engines; v1 is therefore
an essential portability foundation, not a demonstrated optimizing compiler or blanket throughput win.

The director proposed a longer horizon: after the dynamic parser is correct and usable, optionally convert it into
a backend-native, substantially faster parser. Backends may have different useful mechanisms, and Perl need not be
an acceleration target.

## Decision

1. **Keep dynamic parsing primary.** `foo.spec` and its complete import/staged graph remain the sole parser source
   of truth. Loading that graph must always construct a usable parser without a native compiler toolchain or
   prebuilt artifact.
2. **Add an optional third tier.** LinkedSpec distinguishes immediate dynamic interpretation/construction,
   fingerprinted warm compiled-state/cache reuse, and an explicit backend-native accelerator. The accelerator is
   never required to claim a format supported.
3. **Compile normalized semantics, not syntax shortcuts.** An accelerator consumes the governed effective compiled
   IR/state plus complete source identity. It may not introduce a backend-only `.spec` dialect, handwritten format
   parser, opaque host callback, or independent grammar.
4. **Treat every artifact as disposable.** Native source, packages, bytecode, object files, libraries, executables,
   and optimized caches are derivatives keyed by the complete `.spec` graph, LinkedSpec language/IR/runtime and
   staged contracts, Unicode-data version, backend/compiler version, behavior-relevant options, and target/ABI
   identity where applicable. A mismatch invalidates the artifact and falls back to the dynamic parser.
5. **Require semantic equivalence before speed.** The accelerated parser must match the dynamic parser's AST,
   source spans, diagnostics, Unicode behavior, recovery, parse mode, configured limits, and observable trace
   semantics over authoritative corpora, invalid cases, differential tests, fuzz/property cases, and adversarial
   inputs. Dynamic execution remains the oracle.
6. **Preserve explainability.** Native compile trace records lowering/optimization decisions and artifact identity.
   Runtime trace maps optimized events back to `.spec` graph, rule, source/span, and input-position identities
   under ADR `0037`, including exact rule filtering where implemented.
7. **Prove an objective benefit.** Promotion requires reproducible correctness-preserving measurements of dynamic
   cold construction, warm cache reuse, native artifact build/load, steady-state parsing, latency/throughput,
   memory, artifact size, and break-even workload. “Native” alone is not a performance claim.
8. **Keep toolchain and trust boundaries explicit.** Compiling or loading artifacts from untrusted `.spec` graphs
   is an explicit operation with isolated build directories, controlled dependencies, typed failures, cleanup,
   and documented platform/toolchain requirements. The ordinary dynamic path does not invoke a host compiler.
9. **Allow backend-specific mechanisms.** Rust may emit/compile specialized Rust or later target a lower-level
   backend; Dart may emit AOT-friendly Dart packages; Julia may use specialization/precompilation or another
   governed artifact; Lua may emit specialized Lua and use the selected runtime's optimizer or a later safe native
   route. These examples are hypotheses, not commitments. Perl may remain the dynamic/reference/generated-handler
   baseline unless evidence justifies an accelerator.
10. **Do not silently weaken parity doctrine.** Acceleration is a non-semantic optional deployment optimization,
    not a divergent language feature. No backend-specific accelerator becomes a mandatory core public capability
    or parity claim without a later decision reconciling its API with ADR `0023`.

## Consequences

- `NATIVE-PARSER-ACCELERATOR` owns the long-term evidence/contract/backend/admission program. It is non-blocking
  for `STRUCTURED-TEXT-FORMAT-PROGRAM` completion and cannot begin implementation before at least one dynamic
  format parser is complete enough to serve as a realistic optimization target.
- Generated-source v1 remains required current parity work and the semantic foundation. Accelerator work must not
  rename v1 or claim that its existing wrappers are already optimized.
- Backend experiments start only after a benchmark identifies a real bottleneck and a likely beneficial target.
  A backend may legitimately retain only dynamic and warm-cache tiers.
- Public docs report dynamic and accelerated performance separately and name artifact/toolchain/platform limits.
- This planning decision changes no parser, compiler, runtime, emitter, cache, CLI, capability census, or format
  implementation.

## Links

- Dynamic format program: ADR `0034`
- Selective observability: ADR `0037`
- User-observable parity: ADR `0023`
- Native in-memory contract: ADR `0022`
- Generated-source v1 owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` `.3`
- Planning owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` `.18.3`
- Horizon tree: `docs/tasks/NATIVE-PARSER-ACCELERATOR.md`
