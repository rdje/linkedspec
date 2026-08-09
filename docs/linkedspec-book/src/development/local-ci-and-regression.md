# Local CI and Regression

LinkedSpec relies heavily on a strong regression gate.

This is not incidental. LinkedSpec is being refactored while it remains a working dynamic parser system. The local gate is what lets the project change internal architecture without quietly breaking shipped specs, diagnostics contracts, or helper-DSL lowering semantics.

> **Perl reference implementation.** This chapter describes the **Perl reference
> backend's** CI and regression gate (`perl -c`, `t/phase0_regression.t`,
> `tools/run_ci_local.sh`). A backend in another language has its own build/test gate,
> but every backend must pass the shared, language-neutral test corpus that defines
> `.spec` compliance (see [Backend Handoff](../appendix/backend-handoff.md)).

## Main local gate

Run:

```bash
bash tools/run_ci_local.sh
```

This is the canonical regression gate for local development.

### Neutral typed source-location contract

The default gate requires and runs the backend-neutral typed source-location checker through repository-managed
Python storage:

```bash
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
```

The check is unconditional. It independently derives Unicode-scalar, line/column, and UTF-8 coordinates;
materializes direct and derived spans; executes invocation and bounded-transaction state transitions; validates
recursive and zero/one/two-regex structural cases; and rejects all 41 registered mutations.

The gate then unconditionally runs the admitted Perl value and projection consumers:

```bash
PERL5LIB= prove -Iperl t/typed_source_location_values.t t/typed_source_location_perl_contract.t
```

The gate also requires and ordinarily executes Rust's exact value and projection consumer:

```bash
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract
```

The gate then requires and ordinarily executes Dart's exact four-test value and projection consumer through
repository-managed Dart storage:

```bash
cd dart
bash ../tools/run_dart_project_data.sh test --reporter failures-only test/typed_source_location_contract_test.dart
```

The gate also requires and executes Julia's exact value and projection consumer through repository-managed Julia
storage:

```bash
bash tools/run_julia_project_data.sh --project=julia \
  --startup-file=no --history-file=no -e \
  'using LinkedSpecJulia, JSON3, Test; include("julia/test/typed_source_location_contract_test.jl")'
```

Its current rollout result is 7 complete / 7 pending with 41 registered mutations. Passing this gate proves the
neutral contract, both completed public-structure rows, and the internal Perl, Rust, Dart, and Julia runtimes
across their exact value/helper carriers. Rust retains UTF-8-byte registers, Dart retains UTF-16 code-unit
registers, and Julia retains zero-based UTF-8 code-unit registers while each converts at its immutable typed
boundary. This does not claim public authored `Position`/`Span` values, transaction syntax or behavior, or
admission of PUC Lua or LuaJIT.

Dart's admitted consumer covers its internal value core and all 92+7 helper projections across native,
reconstructed, generated-plan, and freshly emitted execution. The independent rollout checker requires its
ordinary path and canonical command exactly once, rejects retained dormancy, and rejects any regression of the
completed `dart_runtime` row.

Julia's admitted consumer covers its internal value core and all 92+7 helper projections across native,
reconstructed, and generated-plan execution. The independent rollout checker requires its ordinary include and
canonical command exactly once, rejects stale dormancy, and rejects any regression of completed `julia_runtime`.

The gate unconditionally verifies the neutral MCP transport before checking all five derived bindings. It requires
every contract artifact and runs the generators in this exact order before the admitted implementation proofs:

```bash
bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py
bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py
bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py
bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py
bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py
bash tools/run_python_project_data.sh tools/generate_julia_mcp_contract.py
bash tools/run_python_project_data.sh tools/generate_lua_mcp_contract.py
PERL5LIB= prove -Iperl t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t t/mcp_server_perl_stdio.t
bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py
PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t
```

The first step catches stale generated frames/digests; the second independently checks schemas, provenance, raw
and lifecycle/handle/policy outcomes, and 76 mutations. Only then may the third verify the byte-exact generated
backend modules, after which focused binding, decoded-server, and adversarial stdio proofs run for every formally
admitted backend. The stdio suites lock
all ten raw and ten lifecycle cases, exact frame/depth/id limits, duplicate/unicode/number mutants, canonical
emission, cancellation through flush, continuation after rejected frames, EOF release, I/O failures, and sanitized
logging. The admission checker then verifies a separate five-implementation/six-runtime status ledger, unchanged
transport digest, one exact twelve-role consumer per admitted runtime, production authority fences, and complete
shared rollout. All six runtime consumers prove direct-native/MCP identity for capabilities plus all nineteen
neutral queries. The recurring tool-
governance test rejects missing owners and invalid ordering. This keeps a backend-derived module from blessing or
hiding stale normative bytes and keeps a premature status promotion from masquerading as conformance. The focused
suites use only caller-owned in-memory handles; they read no source path and change no native semantic/primary-CLI
contract.

Perl parent closeout `.10.9.2.4` deliberately reruns this committed chain unchanged. It adds no umbrella test or
replacement oracle: parent completion is the conjunction of the neutral, derived-binding, server, ledger, and
admission owners already shown above. At that historical Perl-only boundary, shared rollout remained pending
while the other runtime rows qualified.

Completed Rust preflight `.10.9.3.0` froze the dependency order. Decoded-server leaf `.10.9.3.1` adds the shared
verified-bundle consumer and byte-fresh Rust binding after neutral materialization, independent validation, and
the unchanged byte-fresh Perl binding. Strict stdio `.10.9.3.2` adds the bounded hostile-byte and lifecycle proof.
Exact admission `.10.9.3.3` then runs private MCP unit proof, decoded and stdio public proof, and one twelve-role
external Rust consumer before the ledger checker; only Rust advances to 2/5 implementations + 2/6 runtimes and
shared rollout stays pending. Perl admission still runs after the checker. The 39-mutation checker and tool-
governance test reject generated-binding, consumer, tracked-input, and validator/proof-order drift.

No-change closeout `.10.9.3.4` runs that exact committed sequence again without a replacement implementation,
fixture, or umbrella oracle. Focused and canonical gates pass unchanged, close parent `.10.9.3`, and preserve Dart
`.10.9.4` as the next clean-boundary owner. Dart `.10.9.4.1-.3` has since added its generated binding, decoded
server, strict stdio, and exact admission; no-change `.10.9.4.4` recomposes that chain and closes the parent.
Julia `.10.9.5.1-.3` then adds its generated binding, decoded server, strict number-kind-preserving stdio, and
one ordered twelve-role external admission consumer. No-change `.10.9.5.4` reruns that exact committed chain,
closes parent `.10.9.5`, and adds no replacement implementation, fixture, or umbrella oracle. Shared Lua
`.10.9.6.1-.3` now adds one common implementation plus one 202-assertion consumer run independently on both ABIs;
the current ledger is 5/5 implementations + 6/6 runtimes with recurring rollout complete and 141 rejected
implementation/admission/recurring mutations. `tools/check_mcp_six_runtime.sh` is required and syntax-checked
unconditionally; `LINKEDSPEC_RUN_MCP_MATRIX=1` opts into its neutral → transport/bindings → six consumers →
ledger → primary-no-drift composition. Its canonical signoff passes all seven current doctrines, the exact cross-
runtime MCP chain, Rust semantic in 81.29 seconds, Julia semantic 416/416 in 28.9 seconds,
containment/moved-root execution, primary CLI 66x2, RAM 54%, and Phase 0 1,031/1,031 in 643 seconds. The optional
leg independently repeats Perl 13, Rust 1/1 in 15.77 seconds, Dart 1/1, Julia 257/257 in 6.9 seconds, Lua 281/281
per ABI, the complete/141 ledger, and primary 30/30.
No-change `.10.9.6.4` reruns that exact committed sequence, passes Phase 0 1,031/1,031 in 652 seconds plus the
same complete dual-ABI gate, preserves pending/114, and closes the shared Lua parent without a replacement test,
fixture, consumer, implementation, or umbrella oracle.

Signoff-complete behavior-free recurring audit `.10.9.7.0` and ADR `0062` froze the final evidence seam before
code. The audit distinguished two facts that could not be conflated: the six native semantic consumers already
proved all twenty ordered responses, while the MCP consumers then proved complete transport/security/lifecycle
coverage but direct/MCP identity for only capabilities plus one representative graph query. Implemented `.1`
has since extended those existing identity roles to all twenty neutral requests/digests without copying response
bodies or adding production helpers.

Implemented `tools/check_mcp_six_runtime.sh` is repository-routed and fail-fast. In order it validates the neutral
semantic contract, materializes and independently validates the MCP contract, checks all five generated bindings,
runs Perl/Rust/Dart/Julia/PUC Lua/LuaJIT MCP consumers exactly once, checks the admission/recurring ledger, and
runs the existing three-case primary no-drift projection. Rust target and Julia writable-depot state live under
its exact managed artifact root. Canonical CI requires and syntax-checks the driver, while
`LINKEDSPEC_RUN_MCP_MATRIX=1` opts into the expensive composition. The coordinated `.1` transition has marked
thin transport complete in both ledgers.

No-change implementation closeout `.10.9.7.1.1.4` reruns that same chain independently. Its canonical opt-in
gate passes all seven doctrines, Rust semantic 1/1, Julia semantic 416/416 in 29.3 seconds, containment/moved-root,
primary CLI 66x2, RAM 54%, and Phase 0 1,031/1,031 in 655 seconds. The optional leg repeats Perl 13, Rust 1/1 in
15.88 seconds, Dart 1/1, Julia 257/257 in 6.8 seconds, Lua 281/281 per ABI, complete/141 governance, and primary
30/30. Implementation parents `.10.9.7.1.1` and `.10.9.7.1` are closed without a replacement proof or status
movement. At that historical boundary, MCP-parent closeout `.10.9.7.2` was next.

Final no-change MCP-parent closeout `.10.9.7.2` reruns the same driver and an independent canonical MCP opt-in
from clean `77ceb921`. Focused proof remains semantic 6/20/110, MCP 35/10/10/76, six runtime consumers,
complete/141 governance, and primary 30/30. Canonical execution exits zero through all seven doctrines,
containment/moved-root, primary CLI 66x2, RAM 53%, Phase 0 1,031/1,031, and the rebuilt optional MCP chain.
Parents `.10.9.7` and `.10.9` close without a replacement proof or status/authority movement. Public no-drift
remains `.10.10`.

The planning leaf's host-authorized canonical signoff passes LinkedSpec's macOS-sandbox containment and moved-root
proof, semantic 6/20/105, MCP 35/10/10/68, the current six runtime admissions, primary CLI 66x2, RAM 60%, Phase 0
1,031/1,031 in 772 seconds, and the complete PUC Lua/LuaJIT opt-in gate. Running the same gate inside another
filesystem sandbox can deny nested `sandbox-exec`; that host restriction is not a locality failure, so canonical
evidence must come from a run allowed to exercise LinkedSpec's own sandbox profile.

Behavior-free Julia plan `.10.9.5.0` and ADR `0060` freeze the generated-Base64-binding -> decoded-server ->
strict-number-preserving-stdio -> exact-admission -> no-change-closeout sequence. Leaves `.1-.3` now implement
and admit the first four owners. Canonical order requires generator freshness, focused binding/decoded/stdio
proof, then the 178-assertion exact twelve-role consumer before the ledger checker. The checker locks Julia's
four source owners, package/CI registration, role declaration/invocation/completion, authority fences, Julia-only
status movement, and unchanged transport digest. No primary-CLI mode, executable, SDK/network stack, async
runtime, source bootstrap, semantic cache, aggregator, or legacy adapter enters that proof.

The Julia closeout canonical signoff passes Rust semantic admission 1/1 in 79.25 seconds, Dart 1/1, Julia
416/416 in 27.6 seconds, repository-volume containment, moved-root execution, primary CLI 66x2, RAM 58%, and
Phase 0 1,031/1,031 in 631 seconds. Focused MCP recomposition remains exact at neutral 35/10/10/68, four
byte-fresh bindings, Perl 22+13, Rust 15+3+4+1, Dart 15+1, Julia 48+139+170+178, and ledger 4/5 + 4/6
pending/79.

Behavior-free shared Lua plan `.10.9.6.0` and ADR `0061` freeze the remaining canonical order as byte-fresh
generated literal binding, identical PUC Lua/LuaJIT decoded proof, identical strict-stdio proof, one exact consumer
invoked once per ABI, then the implementation ledger. Decoded leaf `.10.9.6.1` now registers the Lua generator,
generated binding, frozen runtime, C99 native system seam, server, and two focused tests. Strict-wire leaf `.2`
adds one private iterative scanner/stdio loop, public protected `server:serve_stdio`, and a third focused test.
Exact admission `.3` adds one 202-assertion twelve-role consumer source and runs it unchanged on both ABIs. The
complete Lua gate runs 111 binding/runtime, 210 decoded/security, 247 strict-stdio, and 202 admission assertions
identically on each ABI, beside both 177-test package legs, primary 66x2, corpus 105/105, and the
16-owner/three-module storage proof. Source/CI/authority governance now rejects 114 mutations; MCP is exactly 5/5
implementations + 6/6 runtimes with recurring rollout pending.

The strict-wire leaf's complete signoff runs this composition with `LINKEDSPEC_RUN_LUA=1`: all six doctrines;
neutral MCP 35/10/10/68; all five byte-fresh bindings; Perl 22+13, Rust 15+3+4+1, Dart 15+1, and Julia
48+139+170+178; the unchanged 4/5 + 4/6 pending ledger at 98 mutations; Rust semantic 1/1 in 82.15 seconds,
Dart 1/1, Julia 416/416 in 29.2 seconds; kernel-contained relocation; moved-root execution; primary CLI 66x2;
RAM 63%; Phase 0 1,031/1,031; and the full PUC Lua/LuaJIT gate.

The `.10.9.5.0` planning signoff passes the unchanged focused chain and complete canonical gate: Rust semantic
admission 1/1 in 80.66 seconds, Dart 1/1, Julia 416/416 in 29.3 seconds, six-family process containment, moved-root
execution, CLI 66x2, and Phase 0 1,031/1,031 in 642 seconds. The ledger remains 3/5 + 3/6 pending/58.

The GitHub workflow is intentionally kept as a thin wrapper around the same command:

```text
.github/workflows/ci.yml
  -> bash tools/run_ci_local.sh
```

That means local validation and hosted validation are intentionally not two separate systems when hosted CI is enabled.

## Primary CLI conformance fixtures

The primary command has a separate backend-neutral, byte-exact fixture runner:

```bash
PERL5LIB= perl tools/run_cli_conformance.pl \
  --display-command 'perl bin/linkedspec' \
  -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec
```

`cli_conformance/manifest.json` is data, not a Perl-only test table. The runner accepts an arbitrary command array,
creates one isolated workspace per case, materializes checked-in inputs, captures raw stdout/stderr separately, and
compares exact channel bytes, exit status, and expected generated files. `{{COMMAND}}` represents the only allowed
help/diagnostic difference: the backend executable token or unavoidable host launch wrapper. `{{REPO_ROOT}}`,
`{{WORKSPACE}}`, and `{{CASE_ID}}` represent exact runner inputs rather than backend-specific expected results.

The suite currently locks both help forms, 20 strict usage cases, eleven success cases, four baseline operational
failures, 20 canonical trace cases, and eight strict UTF-8 behavior cases on Perl. All 65 pass with
`POSIXLY_CORRECT` unset or set. ADR `0024` trace cases cover exact
UTF-8 phase records, stdout/route/mirror, reset/persistence/append, levels/aliases, emoji, byte counts, field
escaping, and all failure phases. The canonical local gate invokes this same runner in both environments.
ADR `0025` defines Unicode scalar text encoded as strict preserved UTF-8 at process/file boundaries. `.6.2`
now decodes Perl argv/files, emits recursive UTF-8 JSON once, and locks inline/file Unicode, normalization
preservation, input BOM/newlines, non-stripped source BOM, invalid phases, and trace byte counts. `.6.3` closes
the reference. Rust `.1.5.2.4` historically closed reusable direct execution plus the then-current 61-case
canonical trace projection. During the rule-local cursor migration, Perl established the 63-case reference bytes
and Rust later passed them unchanged in both environments after `.9.1.4.6`. Root-selection admission advances the
shared manifest reference-first to 65 cases. Perl owns the reference bytes; Rust core/routes/admission `.2.1-.3`
and Dart `.3.1-.3` now pass them exactly at 65/65 in both environments. Julia core `.4.1` passes the root-owned
cases, route `.4.2` passes its 57-assertion composed proof, cursor `.9.1.6.5` makes the shared command 65/65 twice,
and root admission `.4.3` topology-locks that complete boundary. Lua
leaf `.5` owns its migration.
`tools/run_rust_local.sh` and `tools/run_dart_local.sh` are
green against the expanded manifest. UTF-16/UTF-32 are not
implicit inputs.

Julia core `.9.1.1.2.4.1` improved the expanded manifest from its 31/65 preflight to 32/65 in each environment by
closing the sole root-owned markerless compilation case. Cursor `.9.1.6.5` then removes the identical 22 help/
usage and 11 medium-or-higher request-trace failures. Julia now passes 65/65 twice; cursor admission `.6` closes
its cursor topology requirement, and root admission `.4.3` closes the separate root topology requirement through
137 focused assertions.

Lua behavior-free preflight `.9.1.1.2.5.0` ran the same shared manifest through disposable native adapters. Core
`.5.1` now makes PUC Lua and LuaJIT identical with `POSIXLY_CORRECT` unset and set at 32/65 in every leg by closing
only `success_markerless_first_authored_rule`. The 22 help/usage and 11 request-trace mismatches still belong to
cursor `.9.1.7`. Focused root proof is 99 assertions; route proof is 101 assertions over loaded/reconstructed,
generated/emitted direct/traced, trace, diagnostics, and plan-first ordering. Complete package execution is 176
passing groups plus one cursor help failure, and corpus execution is 105/105 per ABI. Route `.5.2` preserves
generated v1/format-1 identity and its minimal plan; cursor `.9.1.7` owns the remaining 33, and topology admission
`.5.3` requires both tracks. Hand-authored selection fixtures use `I`; fixed shared request-trace bytes retain `E`.

Lua cursor preflight `.9.1.7.0` runs separately built PUC Lua and LuaJIT native modules and records identical
results. Family parsing/classification/intrinsic execution is 36/36, 34/36, and 22/36; expected-success edge and
ownership normalization is 5/13 and 2/4; portable invalid diagnostics are 0/7; mixed parent/child and structural
execution is 4/8 and 1/2. Package remains 176/177 per ABI, each default/POSIX primary leg remains 32/65, and each
corpus remains 105/105. These expected staged failures are not a green backend gate; they are the frozen input to
`.1-.6`. The neutral checker itself is green at 67 migration files, 5 complete / 3 pending, and 44 rejected
mutations. The preflight changes documentation and task ownership only.
Canonical closeout repeats root consumers 7+5, cursor admission 288, reference primary 65/65 twice, and Phase 0
1,031/1,031 in 631 seconds.

Lua runtime leaf `.9.1.7.2` registers a separate 110-assertion contract consumer in both ABI legs. Its identical
44-failure RED boundary is now green across all 36 families, 8/8 parent-child mechanisms, 2/2 structural
replacements, loaded/normalized/recursive/trace paths, and explicit generated-v1/outer compatibility isolation.
Together with diagnostic, logical, root-core, root-route, and normalization consumers, focused proof is 1,046
assertions per ABI. The known complete-package help mismatch and 33 shared primary cursor residuals remain expected
until option-removal leaf `.5`; do not reinterpret those staged failures as runtime-policy regressions. Registering
the consumer advances only inventory to 68 files; rollout remains 5 complete / 3 pending with 44 mutations.

Descriptor leaf `.9.1.7.3` adds the next standalone dual-ABI consumer. Before implementation it reports the same
364 failures of 776 assertions on PUC Lua and LuaJIT: only the legacy root global field and missing rule/edge
projection differ. After implementation it passes 875/875 per ABI across exact root/rule fields, all 36 families,
every valid semantic edge, normalized invalid diagnostics, direct rule projection, byte-identical direct/
normalized/loaded descriptors, and loaded AND execution. The seven focused consumers total 1,921 assertions per
ABI. Package, primary, corpus, inventory, rollout, and mutation boundaries remain deliberately unchanged until
their later owners. Full signoff also passes memory/Knowledge Map checks, all four doctrines, and canonical root
consumers 7+5, cursor admission 288, reference primary 65x2, and Phase 0 1,031/1,031 in 621 seconds.

Generated-source leaf `.9.1.7.4` adds one 106-assertion consumer to both ABI legs. Identical 44/106 RED now passes
v2/format-2 identity, the minimal ordered plan, five seek and five consume families, compact-Pipe choice, both
structural replacements, deterministic direct/traced/persisted execution, and stale-v1 rejection before corrupt
payload reconstruction. All eight focused consumers total 2,027 assertions per ABI. Package remains 176/177x2
only at staged help, every default/POSIX primary leg remains 32/65, corpus remains 105/105 per ABI, and registering
the consumer moves only inventory to 69 files at unchanged rollout 5+3 and 44 mutations.
Knowledge Map generation is 630 facts / 4,622 keys. The mdBook, four doctrines, root consumers 7+5, cursor
admission 288, reference primary 65x2, and canonical Phase 0 1,031/1,031 in 644 seconds all pass. The generated
book, Python cache, and disposable native trees are removed after proof.

Route leaf `.4.2` signs off with its 57 focused assertions, core 79, loader 82, emitter 59, corpus 105, root
governance 4/7 plus 34 rejected mutations, and the canonical Phase-0 total of 1,031 tests. It deliberately does
not advance Julia's rollout row. Cursor implementation and admission have since removed the 33 option/trace
mismatches and locked the complete cursor topology. Root topology admission `.4.3` now adds one exact 15-role
consumer, raises governance to 5/7 plus 39 rejected mutations, and passes package 3,428, primary 65x2, and corpus
105 without changing semantic owners. Canonical CI then passes root consumers 7+5, cursor admission 288, the
reference primary 65x2, and Phase 0 1,031/1,031 in 616 seconds.

Task dependencies preserve backend order around that root work. Dart's composed cursor admission `.9.1.5.6`
locks one exact 15-role consumer, advances only Dart from 3/5 to 4/4, and closes `.9.1.5` after package 271,
primary 65x2, and corpus 105. It is cleanly committed at `7aa9c578`; with Julia root routes already committed,
both cursor dependencies are satisfied and behavior-free Julia preflight `.9.1.6.0` is verified; its clean commit
precedes `.1-.6`.
That preflight parses all 36 neutral headers but finds current family classification at 34/36 because Julia still
treats compact `|` as AND. All engines store global seek; bare-edge parsing is 3 action / 3 blind / 1 lifecycle /
11 raw, with no exact portable result across the seven edge/edge-set error rows and silent acceptance of indexed
blind syntax. Exact mixed-family execution agrees on 5/8 rows and the two structural replacements on 1/2.
Descriptor state is still global-mode, generated source is v1, package execution reaches 56/57, shared primary is
32/65 twice, corpus is 105/105, and cursor governance remains 67 files / 4 complete / 4 pending / 39 mutations.
No executable behavior changes in `.0`; `.1-.6` isolate old v1 semantics until the generated-v2 leaf owns the bump.

Rust, Dart, Julia, and Lua root-selection admissions are omission-sensitive. The neutral contract declares one 15-role
consumer per backend over selection/failure/strict rows plus native, loaded/reconstructed, generated/emitted,
descriptor, diagnostic, trace, and primary routes. Its checker requires one exact function marker per role, the
six shared root-selection/request-trace primary case identities, each tracked canonical input, the complete
backend-package driver, and optional canonical registration. Julia additionally locks inclusion from
`julia/test/runtests.jl`. Lua uses one shared consumer source and requires distinct PUC Lua and LuaJIT driver
invocations. With Lua admitted, 44 mutations reject semantic, topology, inventory, and rollout drift. Authored
selection fixtures return from `I`, distinguishing entered-rule proof from a coincidentally equal successful `E`
result, while the fixed shared request-trace fixture retains its canonical source bytes.

Final root-selection admission adds `bash tools/check_root_rule_selection_five_backend.sh`. It reruns Perl core
and routes, each exact Rust/Dart/Julia admission, the same Lua source on PUC Lua and LuaJIT, the 5x2x6 selected
root-rule matrix, and generated/capability/corpus-proof ledgers. The public contract requires both roadmaps and 23
other current surfaces, forbids 19 stale current claims, and raises drift coverage to 54 mutations. Canonical CI
keeps this all-toolchain composition optional: run
`LINKEDSPEC_RUN_ROOT_RULE_MATRIX=1 bash tools/run_ci_local.sh`.
This is the 5x2x6 selected root-rule matrix.
Ordinary canonical signoff still syntax-checks and requires the recurring driver; the final closeout passes the
65-case reference suite twice and Phase 0 1,031/1,031 in 642 seconds.

Rust cursor admission is also omission-sensitive. The neutral contract declares one 15-role consumer, and its
checker requires the consumer as a tracked canonical input, one exact marker per role, the complete runtime-package
command in `tools/run_rust_local.sh`, and that optional Rust driver's registration in `tools/run_ci_local.sh`.
The default canonical gate remains toolchain-independent; setting `LINKEDSPEC_RUN_RUST=1` executes the same complete
Rust package that contains the consumer. Dart cursor admission applies the same omission-sensitive pattern: its
15-role consumer is a tracked canonical input, `tools/run_dart_local.sh` runs the complete Dart suite containing
it, and `LINKEDSPEC_RUN_DART=1` invokes that registered driver. Julia now applies the same pattern: one exact
15-role consumer is included by the complete package driver, tracked by canonical CI, and reachable through
`LINKEDSPEC_RUN_JULIA=1`. Lua applies the same pattern with one exact 15-role consumer run under PUC Lua and
LuaJIT by `tools/run_lua_local.sh`; canonical CI tracks it and `LINKEDSPEC_RUN_LUA=1` invokes the complete
dual-ABI driver. One recurring driver now composes Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, the selected 5x2x5
primary projection, and generated/capability/language-coverage ledgers. Run
`bash tools/check_rule_local_cursor_five_backend.sh` directly or set `LINKEDSPEC_RUN_CURSOR_MATRIX=1` on the
canonical local gate. The current cursor ledger is 8 complete / 0 pending with 75 governed migration files and
60 rejected drift mutations after recurring and public no-drift admission.

The duplicate-slot audit following that admission deliberately uses temporary probes rather than adding a new
gate before the neutral contract exists. `LinkedSpec::Get`, `return_descriptor`, emitted/standalone source, and a
routed debug trace establish the Perl failure mechanism. Native/generated probes then freeze the six-runtime
boundary: Perl and Rust reject the later duplicate in ordered AND; Dart, Julia, PUC Lua, and LuaJIT preserve it;
all six choose the first duplicate in OR. Repeated Perl versus dual-ABI Lua and a non-identical Perl control prove
that the distinction is slot identity rather than repetition generally. All disposable Rust/Dart/Julia/Lua probe
outputs are removed immediately after measurement. Leaf `.9.1.8.1.1` owns the first durable neutral contract,
checker, fixtures, mutations, and canonical registration; audit `.0` does not pre-empt that decision or change
runtime behavior.

ADR `0047` now supplies that neutral boundary. Run:

```bash
bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py
```

The checker independently evaluates five exact ordered/choice/repeated/control/cross-target fixtures, requires
two typed invariants, locks descriptor/trace identity and unchanged generated-source v2, inventories all six
runtime legs, fixes the `.1-.7` migration, requires 22 public documents and 12 stale-current denials, and rejects
59 mutations. Canonical CI tracks the contract, checker, every admitted consumer, and the recurring driver. The
default gate runs the neutral checker and Perl consumer. Run the exact all-toolchain composition directly, or opt
it into canonical CI:

```bash
bash tools/check_duplicate_regex_slot_identity_five_backend.sh
LINKEDSPEC_RUN_DUPLICATE_SLOT_MATRIX=1 bash tools/run_ci_local.sh
```

The consumer's 12 roles cover native and loaded execution, repeated duplicate and non-duplicate sequences,
first-authored choice, cross-target slots, descriptor, emitted and independently loaded generated v2 source,
native/generated trace, and both typed diagnostics. Generated v2 embeds `dependency_slot_map` execution payload
but keeps its plan rows exactly `{label, family}`. Rust's 15-role consumer adds native, loaded, reconstructed,
descriptor, emitted/generated, native/generated trace, primary, repeated/control/cross-target/choice, and typed
diagnostic proof. Its serialized `CompiledSpec` remains the generated execution payload, and emitted source
publishes the slot-contract constant without widening the plan. Dart's 15-role consumer uses normalized-spec JSON
as the generated payload, checks direct authored-alternative matching, loaded/reconstructed/descriptor/emitted/
generated/native-trace/generated-trace/primary/diagnostic routes, and retains exact `{label, family}` plans.
Julia's module-isolated 15-role consumer covers the same routes using direct authored-alternative matching and
canonical normalized `SpecFile` JSON as its generated payload. It publishes descriptor/emitted identity, locks
native/generated trace and typed failures, and retains exact `{label, family}` plans. One shared Lua 15-role
consumer covers the same topology on PUC Lua and LuaJIT. The recurring driver then runs the selected
`success_and_rule_consumes` case across five commands and two environments plus the generated-source, capability,
and language-coverage ledgers. Rollout is closed at 7 complete / 0 pending.
Julia-local signoff is package 3,549, primary 65x2, and corpus 105/105; canonical Phase 0 is 1,031/1,031 in 623
seconds.

ADR `0048` has a separate executable boundary for repeated action results. Run its neutral/reference proof and
the admitted backend consumers with:

```bash
bash tools/run_python_project_data.sh tools/check_repeated_action_result_contract.py
PERL5LIB= prove -Iperl t/repeated_action_result_perl_contract.t
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test repeated_action_result_contract
(cd dart && bash ../tools/run_dart_project_data.sh test test/repeated_action_result_contract_test.dart)
julia --project=julia --compiled-modules=no julia/test/repeated_action_result_contract_test.jl
bash tools/run_lua_local.sh
bash tools/check_repeated_action_result_five_backend.sh
```

The neutral checker evaluates eight exact mode cases and ten special cases, including duplicate slots,
nested/null/fluent values, zero and below-minimum results, lifecycle override authority, scalar pipe, and blind
bare-OR classification. It also locks descriptors, generated-source-v2 family rows, selected-slot trace, route
topology, a checked-in corpus bundle, six-runtime inventory, and 35 independent mutation failures. The Perl
consumer composes ten live/loaded/descriptor/emitted/generated/trace/primary/corpus roles. Rust adds one exact
15-role consumer spanning native, loaded/reconstructed, descriptor, emitted/generated direct/traced, primary,
corpus, lifecycle, bounds, progress, and slot traces; the complete Rust-local driver runs it unconditionally.
Dart adds the same 15-role topology through normalized reconstruction and its native/generated/emitted/trace/
primary/corpus routes; `tools/run_dart_local.sh` runs that consumer with format, analyzer, package, primary, and
corpus gates. Julia adds the same 15-role topology, including a fresh isolated emitted-source host, loaded/
reconstructed state, stale-family rejection, and native/generated selected-slot traces; `tools/run_julia_local.sh`
runs it with package, primary, and corpus gates. Lua adds one byte-identical 15-role consumer covering both PUC
Lua and LuaJIT, including fresh emitted-module execution, stale-family rejection, and exact native/generated
slot traces; `tools/run_lua_local.sh` runs it unconditionally on both installed ABIs. The recurring driver runs
all six admitted runtime legs, projects `explicit_or_two_hits` as
`success_explicit_repeated_action_results` across five commands in default and POSIX environments, and checks
generated-source, capability, and language-coverage ledgers. The closed checker rejects 54 mutations and reports
8 complete / 0 pending. Set `LINKEDSPEC_RUN_REPEATED_ACTION_RESULT_MATRIX=1` to include this all-toolchain driver
in canonical local CI; its default remains SDK-independent. Public no-drift covers 25 current documents and 12
stale-current denials.
Recurring signoff passes the selected case on every 5x2 leg; canonical reference proof passes all 66 cases in
both environments and Phase 0 passes 1,031/1,031 in 641 seconds.

The audit's final signoff passes Knowledge Map 636 facts / 4,678 question keys, mdBook, memory/task governance,
all four doctrines, canonical primary CLI 65/65 in both environments, and Phase 0 1,031/1,031 in 619 seconds.
Rust admission `.9.1.8.1.3` independently passes the complete Rust-local package (including both 105-fixture
execution layers), its exact 15-role consumer, primary 65/65 twice, Knowledge Map 639/4,702, mdBook, all four
doctrines, and canonical Phase 0 1,031/1,031 in 619 seconds. The first canonical run rejected a root-selection
marker split across a source newline; the corrected contiguous marker and duplicate-slot additions pass together
on the full rerun.

Schema version 1 workspace inputs use `path` plus exactly one checked-in `source`
or explicit `bytes_hex`. Hex data is non-empty, lowercase, and even-length, and is
materialized raw; this makes invalid UTF-8 cases reviewable without binary blobs.

## Five-Backend Primary CLI Matrix

Run the complete exact-interface proof from the repository root:

```bash
bash tools/run_primary_cli_matrix.sh
```

Pass `--manifest PATH` to run another schema-v1 CLI manifest through the same five commands and two option
environments without changing the canonical 66-case interface suite. The current self-hosted Unicode-label proof
uses one aggregate case so each leg compiles `specs/spec.spec` only once:

```bash
bash tools/run_primary_cli_matrix.sh \
  --manifest unicode_case/self_hosted_cli/manifest.json
```

That case includes all 9 positive labels, all 8 negative labels, both exact-identity pairs, the three
header/action/blind no-prefix surfaces, and newline splitting. Canonical local CI runs both the ordinary manifest
and this current-grammar manifest when `LINKEDSPEC_RUN_CLI_MATRIX=1`.

The driver checks all toolchains, builds Rust, prepares and warms Dart, warms the normal Julia project, builds PUC
Lua native adapters in disposable temporary storage, and runs the shared manifest against Perl, Rust, Dart,
Julia, and Lua with `POSIXLY_CORRECT` unset and set. The historical admitted boundary was 5x2x61. The later
rule-local cursor boundary reached 63 cases, with Perl, Rust, and Dart admitted before their remaining backend
leaves. Root-selection admission expands the current manifest to 65 cases reference-first: Perl and Rust are
admitted at 65/65 in both environments; Dart is also admitted at 65/65 twice through its exact 15-role consumer.
Julia now passes 65/65 twice and is topology-admitted. Lua subsequently removed its 33 cursor-owned mismatches;
the complete five-backend 5x2x66 matrix is green, while the recurring root gate selects only its six owned cases.
The additional current-grammar contract is 5x2x1 and intentionally remains a separate manifest.

The `LUA-BACKEND-PARITY.7.3` no-drift closeout leaves those executable contracts unchanged. Its canonical local
gate passes the Perl reference command at 61/61 in both default and POSIX option environments and Phase 0 at
1,031/1,031 in 608 seconds; the immediately preceding recurring Lua proof remains 169/169 per ABI, focused 61x2,
complete corpus 105/105, and shared matrix 5x2x61.

The core gate remains toolchain-independent by default. On a machine with all backends installed, include the
matrix explicitly:

```bash
LINKEDSPEC_RUN_CLI_MATRIX=1 bash tools/run_ci_local.sh
```

The admitted punctuation-light syntax has a narrower composed matrix that also includes PUC Lua and LuaJIT:

```bash
bash tools/check_punctuation_light_five_backend.sh
# or as an optional local-CI leg
LINKEDSPEC_RUN_PUNCTUATION_MATRIX=1 bash tools/run_ci_local.sh
```

## Capability Census Gate

The exact CLI and interpreter corpus are necessary but do not enumerate every public API and mdBook contract.
Validate the machine-readable broader census with:

```bash
perl tools/check_capability_conformance.pl
```

`capability_conformance/manifest.json` currently contains 16 capabilities and 80 backend states: all 80 pass.
Every evidence path must exist. The separate exclusion ledger is now schema v2 with exactly two ordered records:
deprecated Perl plugin machinery is `legacy` under pending `.6`, and general provider search/recursive staged
queues remain `future` under active structural/progressive/staged parent `.14`. Each record explicitly carries
nullable `retention_authority`; future and open-legacy records require null, while completed legacy ownership
requires an existing repository-relative durable retention authority.

The checker derives unique task ids and leading status enums from tracked task sources, admits only
proposed/pending/active future owners, locks exact exclusion content/order, and rejects 24 in-memory schema,
classification, retention, task-status, content, and satisfied-record mutations. Completed semantic/MCP and
rule-local cursor narratives are absent rather than mislabeled as future. The 16 capability rows remain 80/0/0,
so this governance correction changes no runtime behavior. The canonical local gate runs this check before
focused suites. The 60/0/0 generated-source milestone is historical; punctuation-light admission `.16.7` added
four states, and Lua `.8.4` adds 16 all-pass states in one final admission.

Capability exclusion freshness is public-closed under `FUTURE-PARITY-BACKLOG.24`. The same checker requires 12
governed projections and ten path-scoped stale-current denials, then rejects six public mutations independently
of the unchanged 24 manifest mutations. This keeps the book tied to executable capability truth.

The file-oriented native API has a separate executable resolution/loading contract:

```bash
perl tools/check_native_spec_resolution_contract.pl
```

It validates the versioned schema plus 14 portable name cases, nine deterministic path-precedence/file-kind cases,
and four strict UTF-8 preservation/rejection cases before backend-specific consumers run. The canonical core gate
also requires `prove -Iperl t/native_spec_resolution.t`, which consumes the same fixture through Perl's public
portable facade; Rust, Dart, Julia, and Lua consume it directly in their focused package gates. Lua proves the
14/9/4 fixture on both PUC Lua and LuaJIT.

The same gate also enforces exhaustive current ActionIR coverage:

```bash
perl tools/check_language_capability_coverage.pl
```

That checker requires exact Dart/Julia/Lua inventory identity at 246 current names, occurrence across the mdBook
and governed 105-case corpus plus exact named-mark fixture, every one of 122 independently derived public Perl
contracts in each backend inventory, and rejection of nine classified non-public names. It separately requires
Dart's, Julia's, and Lua's seven source-boundary compatibility aliases and canonical targets to match the neutral
typed-source contract without inflating the common 246-name inventory. Lua's focused consumer executes those
mappings through native, loaded, reconstructed, generated-plan, and emitted routes on both PUC Lua and LuaJIT.

## Focused Rust Gate

Run the repo-owned Rust gate from the repository root:

```bash
bash tools/run_rust_local.sh
```

After gate hardening `.9.1.4.1`, it checks formatting, runs the complete `linkedspec-core` package, runs the
complete `linkedspec-runtime` package (including the 105-fixture interpreter oracle, exhaustive generated
classifier, and native trace controls), builds `linkedspec-rust`, then runs every current primary-command fixture
with `POSIXLY_CORRECT` unset and set. It also invokes the Rust storage oracle described below. Override Cargo with
`LINKEDSPEC_CARGO_CMD`; for targeted Cargo work use the self-rooted managed wrapper, for example:

```bash
bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-core
```

Core runs first because dependency compilation never executes a dependency crate's own tests. Normalization
`.9.1.4.2` raises current proof to 189 unit + 3 descriptor + 5 contract-driven family/edge integration + 8 type
tests. A separate three-test runtime integration locks the staged live boundary. Together they cover the parser/
compiler/validation/descriptor/serialization and embedding paths central to the cursor rollout.

The `.9.1.4.6` cursor boundary passed the then-63-case manifest in default and POSIX environments. The retired
flag returns the reference-owned targeted usage error and all eleven cursor-era request-trace projections omit
the legacy global field. Root-selection leaf `.9.1.1.2.2` established Rust's 65-case boundary; the repeated-action
recurring leaf adds and proves the 66th shared case.

The canonical shared gate does not require a Rust toolchain by default. Opt in on a Rust-capable checkout:

```bash
LINKEDSPEC_RUN_RUST=1 bash tools/run_ci_local.sh
```

### Rust mutation testing (planned)

ADR `0039` adopts `cargo-mutants` as a separate test-strength tool, not another commit gate. Mutation execution
will never run per commit, in pre-commit hooks, or in ordinary local CI—not even with diff/file scope. The existing
focused and broader Rust tests remain the normal workflow.

Mutation campaigns will be explicit on-demand investigations or meaningful milestone/release/admission work. A
2026-07-15 list-only census with `cargo-mutants 27.0.0` found 3,333 candidates across 19 production files, so
targeted files must precede any resource-guarded, sharded breadth. Every survivor, timeout, and unviable mutant
will receive a separate disposition; true test gaps gain behavior-focused tests. The generated Rust Unicode case
table is the initial narrow exclusion because its generator, exact-byte regeneration, neutral contract, and
runtime proof already own correctness. `RUST-MUTATION-TESTING` owns the future safe manual command and pilot. No
mutation command is admitted yet, and no mutation score is currently claimed.

## Optional Dart Gate

The Dart backend has its own focused local gate:

```bash
bash tools/run_dart_local.sh
```

It runs Dart formatting, strict analyzer checks, all 337 Dart package tests, a repository-filesystem storage oracle,
shared primary-CLI help, a bounded corpus-runner smoke, all 66 primary cases in default and POSIX environments,
and the full 105-fixture corpus execution. The storage oracle locks all 18 temporary owners and all 47 hosted
lockfile packages offline; the separate corpus runner remains the 105-fixture owner.
`FUTURE-PARITY-BACKLOG.1.5.3.4` closes the recurring backend gate and Dart primary-command no-drift, while
`PROJECT-DATA-SSD-ROOTING.2.3` adds the storage proof. The canonical local
gate does not require a Dart SDK by default. When a checkout has
Dart installed and you want one command to include both gates, run:

```bash
LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh
```

## Focused Julia Gate

Run the repo-owned focused gate from the repository root:

```bash
bash tools/run_julia_local.sh
```

It runs `Pkg.test()`, the nine-family `tools/check_julia_primary_cli.sh` real-process checker, corpus-runner help,
and the complete 105-fixture corpus. The Julia
executable and depot are configurable:

```bash
LINKEDSPEC_JULIA_CMD=/path/to/julia \
LINKEDSPEC_JULIA_DEPOT_PATH=/path/to/depot \
bash tools/run_julia_local.sh
```

The canonical shared gate does not require Julia by default. Opt in explicitly on a Julia-capable checkout:

```bash
LINKEDSPEC_RUN_JULIA=1 bash tools/run_ci_local.sh
```

These checks currently cover package loading, source parsing/validation, function-shell projection, typed ActionIR
parsing, ActionIR contract resolution, user-function registry projection/stitching, compiled-state descriptor
projection, seek/consume runtime regex selection, capture/offset projection, cursor and entry/local match registers,
zero-progress detection, first default/AND/OR/repetition dispatch, lifecycle and child-edge flow, narrow
accumulators/returns, recursion/progress guards, registered user functions, diagnostics/tracing, boundary capture,
manifest-backed corpus validation, controlled and full library corpus execution, public-parser leading-trivia
parity, spec-driven top-level user-function source composition, native primary request execution/canonical JSON,
stable primary failure/trace routing, and unbounded full-manifest CLI execution. The complete package now passes
3,291 assertions. Cursor-option removal eliminates the former 1/57 help mismatch and all 33 shared help/usage/
request-trace mismatches; the independent runner passes 65/65 twice. The neutral-consuming core suite passes 79
assertions, route proof passes 57, composed cursor admission passes 104, and the standalone complete corpus remains
105/105. Cursor rollout is admitted for Julia; root rollout still requires its separate `.4.3` topology consumer.

The library executor and corpus CLI support named or bounded subsets. Use the self-rooted storage wrapper so both
package/depot state and temporary output stay on the repository filesystem:

```bash
bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.instantiate()'
bash tools/run_julia_project_data.sh --project=julia julia/bin/corpus_runner.jl \
  --corpus rust/linkedspec-runtime/tests/corpus --execute --case proof_edge_array_literal
```

The wrapper derives its writable repository-local depot and managed scratch from the current checkout. It appends
only Julia's runtime system depots and deliberately does not consult a developer-home package depot.

Validation-only loading remains the default. Adding `--execute` without selectors runs the complete validated
manifest and passes 105/105; `--case`, `--offset`, and `--limit` remain available for diagnostics. The permanent
aggregate regression locks manifest order, endpoints, 99 passes, zero failures, and exact output for every fixture.

## Focused Lua Gate

Run both supported Lua ABIs from the repository root:

```bash
bash tools/run_lua_local.sh
```

The gate builds ABI-specific disposable PCRE2 adapters, syntax-checks the Lua tree, runs the full native suite on
PUC Lua and LuaJIT, runs the current 66-case primary manifest under default and POSIX environments on PUC Lua, and
validates plus executes the exact 105-case corpus through the developer command. During the dependency-ordered
root/cursor migration, the complete package currently reaches 176/177 on each ABI and stops only at the known
cursor-help mismatch; the independent shared-primary proof is 32/65 in all four PUC Lua/LuaJIT environment legs,
with all 33 remaining mismatches owned by cursor `.9.1.7`. Its library-level controlled corpus tests
exercise automatic function-aware parsing, explicit validation/compilation, source-identified execution, exact
wrapped output comparison, trace/diagnostic/endpoints, stable failure stages, named/bounded selection, and
continuation after failures. The developer corpus command validates by default and executes the complete manifest
only when passed bare `--execute`. Primary adapter `.7.1` independently implements exact options, strict UTF-8,
native execution/canonical JSON, stable failures/exits, and canonical phase trace. Admission `.7.2` makes both
61-case process legs recurring here and extends the warmed matrix to 5x2x61. Status is
`runtime-corpus-primary-cli`; no-drift `.7.3` closes parent `.7`, confirms the checkout-native setup plus separate
corpus/primary boundaries, and hands off to generated-source work without changing behavior. Planning `.8.1.0`
corrects the earlier v1/v2-only scaffold wording against outward descriptor v3. Deterministic exact-v1/v2/v3
emitter core `.8.1.1` is now covered here: metadata/errors match contract v1, equivalent input emits byte-identical
ASCII source, effective callable/rule state survives reconstruction, and direct/traced modules execute in process
on both ABIs. `.8.1.2` passes the exact selected ABI runtime into the suite, persists valid/corrupt modules plus a
runner in unique caller-owned storage, launches fresh PUC Lua and LuaJIT processes with the gate's native module
paths, captures exact stdout/stderr observations, and requires cleanup after normal and injected-failure paths.
`.8.2` adds exact plan rows/four rejections, plan-authoritative root/nested dispatch, portable generated trace, one
isolated all-family module, and emitted neutral variadic execution. The family matrix consumes the exact ABI
runtime passed by the gate and removes its caller-owned host root. The `.8.3` gate consumes the exact
contract-owned 8/105 list after full-manifest validation, proves interpreter
values before emission, and independently loads all eight modules with exact result/metadata/plan/trace identity
and cleanup in the selected ABI host. Final `.8.4` admits Lua across all 16 rows at 80/0/0.
The completed `.8.3` slice passes generated-source/callable/capability checks, Lua 177/177 per ABI, primary CLI
61/61 in both environments, corpus 105/105, and the canonical gate with both reference CLI legs at 61/61 plus
Phase 0 true reach `1..1031` in 620 seconds.
The completed `.8.2` slice passes generated-source/callable/capability checks, Lua 176/176 per ABI, primary CLI
61/61 in both environments, corpus 105/105, and the canonical gate with both reference CLI legs at 61/61 plus
Phase 0 true reach `1..1031` in 626 seconds.
The completed `.8.1.2` slice passes generated-source/callable/capability checks, Lua 173/173 per ABI, primary CLI
61/61 in both environments, corpus 105/105, and the canonical gate with both reference CLI legs at 61/61 plus
Phase 0 true reach `1..1031` in 607 seconds.
The planning-only `.8.1.0` slice passes generated-source/callable/capability checks, Lua 169/169 per ABI, primary
CLI 61/61 in both environments, corpus 105/105, and the canonical gate with both reference CLI legs at 61/61 plus
Phase 0 true reach `1..1031` in 609 seconds.
The `.7.1` adapter passes the canonical local gate without recurring Lua admission: both reference CLI
environments remain 61/61 and Phase 0 reaches `1..1031` in 606 seconds.
Admission `.7.2` independently passes the canonical local gate with the same reference CLI legs at 61/61 and
Phase 0 true reach `1..1031` in 607 seconds.
The same suite permanently executes exact manifest offsets 0-39 at 40/40, locks first/last names, every wrapped
expected output, and byte/character endpoint 1, without promoting the developer command.
It also permanently executes exact capability offsets 99-104 at 6/6, locking all six governed names, unchanged
wrapped outputs, and byte/character endpoints `2,1,2,1,5,5`.
Advanced/shipped admission likewise executes exact offsets 40-98 at 59/59. Its independent literal ledger locks
all selected names in manifest order, every byte/character endpoint, match and failure state, and exactly one
wrapping of each unchanged expected JSON value. Together these three windows cover the complete 105-case manifest;
`.6.3` adds the final no-selector 105/105 library gate and projects it through the developer runner. The runner
prints ordered PASS/FAIL records plus a summary and returns 0 for all-pass, 1 for fixture failures, and 2 for
arguments or manifest drift. The complete dual-ABI suites pass 167/167 with status `runtime-corpus-full`.
The `.6.3` closeout passes the canonical local gate: both 61-case primary CLI environments and Phase 0
`1..1031`, with Phase 0 completing in 621 seconds.
The `.6.2.6` admission passes the canonical local gate: both 61-case primary CLI environments and Phase 0
`1..1031`, with Phase 0 completing in 621 seconds.
The `.6.1.3` admission also passes the canonical local gate: both 61-case primary CLI environments and Phase 0
`1..1031`, with Phase 0 completing in 640 seconds. Allow at least 30 minutes for a complete gate under concurrent
machine load; this measured run took 1,316.33 seconds end to end.
The `.6.1.4` closeout independently passes that same canonical boundary, with Phase 0 completing in 651 seconds
and the load-affected full gate taking 1,328.76 seconds end to end.

Library selection is independent of that command:

```lua
local execution = linkedspec.execute_corpus_fixtures(corpus_root, {
  case_names = { "proof_edge_array_literal" },
})
assert(linkedspec.corpus_execution_passed(execution))
```

### Retaining repository-local caches

The repository is on a high-capacity SSD, so reusable build and package caches are retained by default. Do not
routinely delete `rust/target`, the repository-local Julia depot, Dart packages, or similar warmed state. A
specific disposable per-run scratch directory may be removed only after proving that no process uses it and that
it contains no retained diagnostic evidence.

Existing project-owned data outside the repository filesystem is migration input, not a supported cache location.
Move it by copy/verify/use/delete: identify exact ownership, copy retained bytes into a root-derived SSD location,
verify counts/sizes/hashes where material, exercise the workflow there, and delete only the exact old source.
Never blanket-delete an operating-system temporary directory or a shared developer cache; they may contain agent
state, application IPC, or another project's data.

The bounded command `--execute --offset 68 --limit 31` now passes 31/31. Anonymous capture, logical/output helper,
recursive top-rule, structural child-push, statement mutation, and public-parser leading-trivia leaves closed each
independent mechanism. `.6.2.4.6` now permanently runs that full window and locks its counts, endpoints, zero
failures, and exact outputs. Julia has since closed the routed top-level function fixtures under `.6.2.5` and the
complete 99/99 manifest gate under `.6.3`; `.6.4` has since added the focused gate and optional shared-CI wiring.

### Callable-codeblock five-backend recurring proof

Five-backend callable recurring/public admission is complete. `tools/check_callable_codeblock_five_backend.sh`
composes the established authorities without adding another semantic implementation. It runs neutral, Perl, Rust,
Dart, Julia, PUC Lua, and LuaJIT in exact order; the two Lua runtime rows execute one focused file. The driver
enters one managed repository-data run and delegates through the supported Python, Cargo, Dart, Julia, and Lua
wrappers; Perl runs inside that boundary with ambient `PERL5LIB` cleared.

Canonical local CI always requires and syntax-checks the driver. Set
`LINKEDSPEC_RUN_CALLABLE_CODEBLOCK_MATRIX=1` to execute the all-toolchain composition. The checker rejects 23
topology, route, status, and public-governance mutations: missing/reordered roles, collapsed or divergent Lua
runtime rows, stale paths, project-data bypass, stale four-backend identity, canonical omission/duplication,
satisfied-exclusion resurrection, public document/marker/denylist omission, and sole-facing project-status count
drift. Public no-drift covers 25 current-facing documents and explicitly denies the stale 24 claim.

Lua's focused construction/invocation consumer is already part of the complete Lua gate on both ABIs:

```bash
bash tools/run_lua_project_data.sh puc lua/test/callable_codeblock_literal_contract_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/callable_codeblock_literal_contract_test.lua
bash tools/run_lua_local.sh
```

It passes 449 assertions per ABI for exact literal/signature/body/span records, inert copy/transport, dynamic caller
context, static precedence, declared-final equivalence, ordered copied fixed/rest values, result access/chaining,
every neutral failure/recursion field, canonical reconstruction, generated execution, and byte-fresh emitted
modules with corrupt-payload and cleanup proof. `.11.8.4` runs that unchanged file once per Lua ABI and removes
only the satisfied `future.generic_final_codeblock` exclusion. The 16-capability census remains 80/0/0.

The `.11.8.3` signoff preserves that boundary while passing complete Lua 177x2, CLI 66x2, corpus 105/105, exact
storage owner 17, neutral callable governance plus 20 mutations, signatures 3/9/7, and capability 80/0/0. The
Knowledge Map is 779 facts / 6,322 question keys and this book renders 79 files / 14,048 KiB. All seven doctrines
and the canonical gate pass, including containment/moved-root proof, RAM 51%, Phase 0 1,031/1,031 in 809 seconds,
and the exact four-backend callable matrix.

## Hosted GitHub Actions status

Hosted GitHub Actions CI is currently disabled for cost-control reasons.

The workflow file remains tracked because the local CI script audits it as part of the repository's validation surface, but the hosted workflow no longer runs on `push` or `pull_request`. It is left behind `workflow_dispatch` with a disabled job guard, so even an accidental manual dispatch does not spend runner minutes.

To re-enable hosted CI later, restore the `push` and `pull_request` triggers in `.github/workflows/ci.yml`, remove the job-level disabled guard, and run the local gate before pushing the re-enable commit.

## What the local gate checks

`tools/run_ci_local.sh` currently does the following:

- verifies required commands are available: `git`, `perl`, and `prove`,
- verifies required tracked files exist, including the primary CLI, neutral manifest/runner/tests, local gate,
  `perl/LinkedSpec.pm`, and `t/phase0_regression.t`,
- verifies key tracked input directories are present and non-empty,
- rejects untracked files inside CI input areas,
- self-proves aggregate-selector scanning under three concurrent processes while keeping the positive untracked
  discovery probe outside backend package formatter traversal,
- audits selected core paths for machine-specific absolute paths,
- runs Perl syntax checks for the library, primary CLI, neutral runner, and focused tests,
- validates the machine-readable capability census, backend evidence paths, and task ownership,
- runs the focused runner/trace suites and all 61 primary CLI cases under default and POSIX option environments,
- runs the main phase0 regression suite,
- runs `scripts/check_memory_architecture.sh` to verify memory architecture invariants (layer integrity, pointer freshness, bounded-layer consistency),
- runs `knowledge-map/scripts/check_knowledge_map.sh` to verify Knowledge Map integrity (derived map matches source cards, no stale entries),
- runs `scripts/check_task_tree_metadata.sh` through the doctrine driver; completed trees cannot advertise live
  frontier rows, while a pending node cannot claim task-tree-first activation or name another node from its tree as
  its own commit; four in-memory fixtures lock the exact low-noise boundary,
- runs `scripts/check_diagnosis_evidence.sh` through the doctrine driver; in a pre-commit context this requires
  staged code/spec/test/tooling changes to carry a task-tree acceptance checklist with LinkedSpec-tool evidence
  signatures,
- enforces a RAM usage guard that refuses to run the test suite when system memory utilization exceeds 88%, preventing resource-exhaustion failures from masking real test results,
- optionally runs `tools/run_rust_local.sh` when `LINKEDSPEC_RUN_RUST=1` is set,
- optionally runs `tools/run_dart_local.sh` when `LINKEDSPEC_RUN_DART=1` is set,
- optionally runs `tools/run_julia_local.sh` when `LINKEDSPEC_RUN_JULIA=1` is set,
- optionally runs the dual-ABI `tools/run_lua_local.sh` when `LINKEDSPEC_RUN_LUA=1` is set,
- optionally runs the recurring Perl/Rust/Dart/Julia callable-codeblock composition when
  `LINKEDSPEC_RUN_CALLABLE_CODEBLOCK_MATRIX=1` is set,
- optionally runs the complete warmed five-backend primary CLI matrix when `LINKEDSPEC_RUN_CLI_MATRIX=1` is set.

The command sequence includes:

```bash
perl -c perl/LinkedSpec.pm
perl -c bin/linkedspec
perl -c tools/run_cli_conformance.pl
PERL5LIB= prove -Iperl t/cli_conformance_runner.t t/trace_cli.t
PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- \
  perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec
perl -c -Iperl t/phase0_regression.t
prove -v -Iperl t/phase0_regression.t
```

## Repository relocation and path discipline

The repository root is deliberately movable. You may rename the checkout, copy it to another volume, or restore it
under another user without rewriting a project path. Persisted references to repository-owned content therefore
use paths relative to the repository root. A script, module, or executable that needs an absolute path computes it
from its own current location (or from an explicit caller root) and keeps that absolute value only at runtime.

This rule is narrower and stronger than banning absolute paths as a data type. These remain valid:

- an explicit caller request such as `/tmp/input.spec` or `C:/Demo`;
- a caller-owned temporary directory;
- an external interpreter or tool under `/usr` or `/opt`;
- a URL or a test needle that proves private paths do not escape.

None of those values may become an implicit repository root. In particular, a compiled-in build directory is not
a valid locator for shipped specs: after moving a binary, it would silently search the old checkout. ADR `0052`
defines this contract. `REPO-ROOT-PATH-PORTABILITY` is landing it in dependency order: runtime repair, exact legacy
path cleanup, durable-command cleanup, a fast structural doctrine, then a recurring copied-binary relocation
oracle. That rollout is now complete. The 2026-07-25 audit found no tracked current/former checkout literal and no tracked symlink. Perl, Dart,
Julia, and Lua pass named-spec process probes from outside the checkout. Rust's repaired primary command searches
current-executable ancestry before cwd ancestry for `specs/user_function_definition.spec`, then falls back to cwd
when neither anchor is a checkout. A binary copied beneath a synthetic moved root therefore loads that root's
unique adjacent spec instead of the compile-time source checkout.

The exact legacy cleanup is complete. Eight frozen configuration/source owners now use root-relative project
defaults, caller-selected `PATH` tools, or their existing explicit configuration fields. In particular, the legacy
network plugin reads both its executable and design input from `conf/network.conf`; Tcl/Tkx package discovery is
caller-owned; and no audited owner retains developer-home, private-volume, `/vobs`, or `/dsync` defaults. Explicit
external paths such as the stable `/usr/bin/csplit` tool remain legal under the boundary above.

The initial 12 audited Julia Knowledge Map reverify commands became path-portable under `.1.3`. Storage migration
`PROJECT-DATA-SSD-ROOTING.2.4` now routes all 88 existing current Julia cards through a self-rooted targeted wrapper, the
complete gate, or the self-rooted primary checker. Those boundaries derive managed scratch and the retained
source-bearing depot from the current checkout and add only Julia-managed system depots. No current Julia reverify
command stores a concrete interpreter, developer depot, or operating-system-temp Julia depot.

Static enforcement is registered as the `REPO-ROOT-PATHS` doctrine. Run it directly with:

```bash
bash scripts/check_repo_root_path_portability.sh
```

The checker reads only tracked parent-repository text, excluding the `rgx` gitlink and ignored/generated caches.
Its built-in 14-case self-test proves rejection of current checkout, Unix/macOS/Windows developer roots, macOS
private volume/session roots, and compile-time Rust primary discovery while preserving relative paths, URLs,
`/usr`/`/opt` tools, caller `/tmp`, and neutral `C:/Demo`/path-denial fixtures. It also requires the five primary
commands to retain their runtime anchors: Perl `FindBin`, Rust executable-then-cwd marker discovery, Dart cwd plus
script ascent, Julia `@__DIR__`, and Lua `debug.getinfo`. The normal doctrine driver runs this checker from both
pre-commit and canonical local CI.

Ignored build/package caches may contain tool-generated absolute metadata and should be regenerated after a move.
Compiled debug information may also record source locations, so searching binary strings is not a relocation
oracle. Run the recurring process proof with:

```bash
bash tools/test_repo_root_process_portability.sh
```

The Rust integration owner copies the freshly built primary beneath a synthetic moved repository. A conflicting
ambient repository returns a different sentinel, so exact `"relocated-root"` output proves executable ancestry
wins rather than merely proving that some named spec resolved. Removing the moved repository marker then requires
exit 1 and exact compile-failure output. The same self-rooted oracle repeats Perl, Dart, Julia, and Lua named
`Lispish` execution from a same-SSD cwd outside the checkout and requires exact `["hello",["world"]]` output.
All generated state and native Lua modules remain below its managed repository-storage run. Canonical local CI
invokes this composed boundary once; later semantic, MCP, and callable recurring drivers bring the current path
tree to 42 routed entrypoints.

Canonical backend flags decide which optional legs the orchestrator schedules; a skipped optional leg does not
mean that backend cannot be built locally. Relocation closeout directly reran the complete Rust, Dart, Julia, PUC
Lua, and LuaJIT gates. It also passed the five-backend primary matrix at 660/660, self-hosted Unicode at 10/10,
all maintained diagnostic/logical/root/cursor/duplicate/repeated/punctuation matrices, and scalar numeric at 55/55
across six runtimes. This full local proof complements, rather than replaces, the canonical composition gate.

## Project data locality and same-volume storage

Repository relocation also defines the storage volume. All project-owned generated output, build state, package
cache/depot content, logs, traces, runtime-created fixtures, and temporary workspaces must remain on the same
filesystem as the current checkout. Persisted names are root-relative; supported entrypoints derive absolute
scratch and cache roots only at runtime. They do not default to the operating-system temporary directory or a
developer-home cache.

Cross-volume access is denied by default. The narrow exceptions are explicit caller-authorized inputs and
documented strictly required external executables, system libraries, devices, credentials, or operating-system
services. Those dependencies are not project storage and should be read-only where possible. ADR `0053` and task
tree `PROJECT-DATA-SSD-ROOTING` define the complete contract.

The behavior-free planning audit found 65 retained CLI workspaces and two Julia depots outside the repository
filesystem (67 directories/135,756 KiB), two exact Dart checkout metadata records, one LinkedSpec stanza inside a
shared Julia log, an initially reported 100 tracked temporary-allocation owners, and 24 executable off-repository
defaults. Rust `.2.2` corrected one missed imported `env::temp_dir()` use, so the initial unique total is 101 and
the Rust family count is 17. Planning `.0`
changed no data. Perl leaf `.2.1` has since migrated the 65 exact CLI workspaces; later family leaves retain the
same requirement to verify count/bytes/hash where material, exercise the SSD replacement, and then delete the exact
old source. Ambiguous shared global caches are never deleted wholesale; supported workflows populate repository-
local caches and stop reading the shared copy.

Planning `.0` is behavior-free but was signed off with temporary, Cargo, Dart, and Julia cache variables rooted
beneath the repository. The complete canonical gate passes Rust semantic admission 1/1 in 82.41 seconds, Dart
1/1, Julia 416/416 in 29.7 seconds, both 66-case Perl primary environments, and Phase 0 1,031/1,031 in 657
seconds. This proves the current gate can run from manually selected same-volume project state before the standard
initializer is implemented; it does not claim the defaults are migrated yet.

Initializer `.1.1` is now implemented. From the repository root, source it before any direct tool invocation:

```bash
source tools/project_data_env.sh
```

It derives the physical checkout from its own file, creates the ignored repository-relative
`/.linkedspec-data/scratch/` and `/.linkedspec-data/cache/` roots, and exports all standard temporary variables,
Cargo home/target, Dart package cache/home, and Julia depot variables. Reusable dependencies remain beneath `cache/`;
managed runs live beneath `scratch/runs/`.

Before replacing `TMPDIR`, the initializer captures its inherited value once as invocation-local host authority.
Nested managed entrypoints preserve that first value after project scratch routing. This value is never used for
project output and is never persisted; the relocated containment oracle uses it only to identify and deny the
actual per-user host temporary namespace.

Caller overrides are not trusted by spelling. The helper resolves their existing or nearest existing directory,
compares GNU/BSD device identity with the repository, creates the directory only after that comparison, and checks
the final destination again. A same-filesystem override is preserved; an invalid or cross-filesystem override is
replaced with the repo-derived default without writing there. Julia defaults to one writable local depot followed
by Julia's runtime system depots, deliberately omitting the developer-home depot. The focused shell test proves
default creation/ignore state, same-volume overrides, hostile cross-volume values from outside caller cwd, source-
only use, and exact test cleanup:

```bash
bash tools/test_project_data_env.sh
```

Leaf `.1.1` signoff passes that focused proof, all five doctrines, and the complete canonical gate while retaining
warmed caches on the repository filesystem: Rust semantic admission 1/1 in 83.33 seconds, Dart 1/1, Julia 416/416
in 30.2 seconds, reference CLI 66/66 in both option environments, and Phase 0 1,031/1,031 in 652 seconds.

Routing leaf `.1.2` makes the pre-commit hook, each doctrine boundary, both Knowledge Map scripts, the canonical
Perl gate, Rust/Dart/Julia/Lua local runners, and the mdBook wrapper source the helper immediately after self-root
discovery. The portable Knowledge Map scripts resolve it through generic `KM_ENV_INITIALIZER`, configured as a
repo-relative path in `.knowledge_map.conf`, and enter lifecycle through generic `KM_RUN_INITIALIZER`, so the
reusable bundle stays project-agnostic. Build this book through the routed wrapper:

```bash
bash tools/run_mdbook_local.sh
```

`tools/test_project_data_workflow_routing.sh` checks every source-before-runtime boundary and launches the
lightweight workflows plus backend preflights from another filesystem with hostile inherited temp/cache variables.
Every selected project-data directory is created on the repository device. The complete canonical gate is also run
from that outside cwd for signoff. Direct lower-level commands still require an explicit
`source tools/project_data_env.sh`; backend-specific hard-coded workspace/default migration remains independently
owned by `.2.1-.2.6`.

Complete `.1.2` signoff starts the canonical gate from the other filesystem while retaining validated SSD-local
caches. Rust semantic admission passes 1/1 in 77.50 seconds, Dart 1/1, Julia 416/416 in 27.1 seconds, reference CLI
66/66 in both option environments, and Phase 0 1,031/1,031 in 662 seconds.

Lifecycle leaf `.1.3` gives each top-level supported invocation one private directory below
`/.linkedspec-data/scratch/runs/<checkout-id>/`. The checkout id is a random, path-free token stored below the
ignored project-data root, so it follows a moved checkout without persisting its old pathname. Each run directory
is created with `mktemp`, carries a non-symlink version-2 marker containing exact checkout/run identity plus
wrapper, foreground-child, dedicated process-group identity, and requested failure policy, and exports its private
`tmp/` child through `TMPDIR`, `TMP`, and `TEMP`. Nested supported scripts reuse that run instead of creating
overlapping lifecycle owners. Binding policy in the marker ensures a crash after recording a default-delete
failure still leaves abandoned/recoverable scratch, not a false explicitly retained failure.

Success removes the exact validated run directory. Failure also removes it by default; diagnostic retention is an
explicit per-invocation policy:

```bash
LINKEDSPEC_FAILED_RUN_POLICY=retain bash tools/run_ci_local.sh
```

The retained `/.linkedspec-data/cache/` hierarchy is outside the run directory and is never touched by this
cleanup. A direct low-level foreground command can use the same contract:

```bash
bash tools/project_data_run.sh perl -Iperl -c t/phase0_regression.t
```

An untrappable interruption can leave an active marker. Recovery is intentionally separate from ordinary startup:

```bash
bash tools/project_data_run.sh --list
bash tools/project_data_run.sh --recover
bash tools/project_data_run.sh --purge-failed
```

Marker version 2 starts the foreground command in a dedicated process group. Descendants inherit that group unless
they deliberately escape it; supported workflows do not detach. The wrapper waits for the whole group to drain
before success/default-failure cleanup and forwards HUP, INT, and TERM to the group. Listing classifies
current-checkout runs as live, explicitly failed, abandoned, or indeterminate. Recovery deletes only abandoned
runs after wrapper, child, and group liveness have been checked again immediately before removal. It retains live
and explicit failed runs; `--purge-failed` is the explicit, separately guarded deletion for dead diagnostic
failures. A live or reused group id is retained conservatively. Legacy, malformed, group-mismatched, interrupted
`starting`, symbolic-link, and other-checkout candidates never authorize automated deletion.

This closes the marker-version-1 limitation found during reconciliation. The deterministic RED launched a
descendant whose cwd remained inside managed `tmp/`, let the direct child return, and observed the run deleted
while the descendant remained live. The green proof now covers both normal background descendants and abrupt
wrapper/direct-child loss: recovery retains the run while the orphan group lives and removes it only after the
group drains.

`tools/test_project_data_lifecycle.sh` proves successful and default-failure cleanup, retained-cache survival,
explicit failure retention and purge, two simultaneous distinct live runs, background-descendant drain,
group-wide signal forwarding, abrupt wrapper/direct-child loss, live-orphan-group protection, drained-group
recovery, legacy/mismatched/indeterminate-marker refusal, non-executable shell entrypoint support, and checkout
isolation.
`tools/test_project_data_workflow_routing.sh` additionally locks every environment-plus-run boundary and requires
no managed run leaf after each completed outside-cwd workflow.

Complete `.1.3` signoff from the other-filesystem cwd passes Rust semantic admission 1/1 in 82.78 seconds, Dart
1/1, Julia 416/416 in 30.1 seconds, both 66-case Perl primary environments, and Phase 0 1,031/1,031 in 639
seconds. The wrapper then reports zero managed runs. A preceding attempt against the valid but not-yet-populated new
Cargo cache failed at its sandbox-blocked registry refresh and also left zero managed runs; the complete restart
used the existing repository-relative retained cache with Cargo offline. Cache population/migration remains a
later backend-owned leaf, separate from this lifecycle contract.

### Perl temporary data, traces, and CLI workspaces

Perl migration `.2.1` extends the routed set with the standalone five-backend primary matrix and adds a focused
process oracle:

```bash
bash tools/test_perl_project_data_storage.sh
```

The oracle may be launched from any working directory. It enters one managed run, checks that both its run and
`TMPDIR` share the repository device, then exercises the same allocation shapes used by the 24 tracked Perl
owners: default and named `File::Temp` directories/files, explicit `TMPDIR => 1`, a routed LinkedSpec trace file,
and a real `tools/run_cli_conformance.pl` subprocess workspace. The CLI child verifies its actual cwd is the
current run's `tmp/linkedspec-cli-*` directory, writes an expected trace artifact, and exits through normal
workspace cleanup. The proof also locks the two oracle-capture tempfiles and preserves inert `/tmp` values used by
semantic privacy tests. `tools/run_ci_local.sh` runs this oracle before its two 66-case primary legs.

The pre-migration internal temporary root held 65 exact directories created by the CLI runner's manifest-owned
workspace template. They were copied to repository-relative
`/.linkedspec-data/cache/migrated/perl-cli-workspaces/`. Source and destination both measured 65 directories,
17 files, and 1,590 bytes and produced canonical inventory SHA-256
`2a24e96043cf42b0c5e31d6b77064c64b07e36d6506ff9724d2c361f53ce8f49`. The copied nested source/input fixture
then produced its exact expected JSON through the Perl primary command. Only after those checks were all 65 old
directories deleted; the internal CLI-workspace census is now zero and the verified SSD copy remains recoverable.

Complete `.2.1` signoff passes the expanded outside-cwd routing oracle, focused runner/trace suites, both primary
environments at 66/66, and canonical Rust semantic admission 1/1 in 77.61 seconds, Dart 1/1, Julia 416/416 in 27.2
seconds, and Phase 0 1,031/1,031 in 625 seconds.

### Rust Cargo cache, tests, generated projects, and relocation

Rust migration `.2.2` adds a focused process oracle:

```bash
bash tools/test_rust_project_data_storage.sh
```

The oracle self-roots and enters managed repository storage. It proves `TMPDIR`, `CARGO_HOME`, and
`CARGO_TARGET_DIR` share the repository device, locks the exact 17 tracked Rust temporary-allocation owners, and
exercises representative core trace, runtime trace-control, generated child-Cargo-project, and repository-topology
paths. It then copies the built primary command into managed scratch, invokes it from a nested cwd with an inline
spec, creates a trace, and verifies both output and trace without an off-volume project write. The complete
`tools/run_rust_local.sh` gate invokes the same oracle after its package/build proof.

The repository-relative Cargo home covers every registry package in `rust/Cargo.lock`: 195 compressed entries,
195 unpacked source directories, 12,741 files, and 371,604 KiB. Its canonical compressed-cache inventory hash is
`a51efb284d62287872f6cc2fd113b1f31c6c5c2e5c1e7d1dd5e52de1e735b399`; locked offline fetch and build pass. The
shared developer Cargo cache is ambiguous multi-project state, so it was neither copied wholesale nor deleted;
supported LinkedSpec workflows no longer consult it.

The planning census reported 16 Rust temporary owners because it recognized fully qualified
`std::env::temp_dir()` but missed an imported `env::temp_dir()` in the core trace tests. The corrected count is 17
and the recurring oracle matches both spellings. Exact Rust-prefixed residue in the inherited per-user temporary
root and `/private/tmp` is zero, so there was no unambiguous old Rust-owned source to delete.

Repository-local `TMPDIR` is below the real checkout. Consequently, a synthetic executable placed there is not
external to repository ancestry. The topology-only unit now injects a repository-marker predicate over relative
synthetic paths; the copied-binary storage oracle remains the real filesystem proof. Complete `.2.2` Rust signoff
passes runtime 149, the 105-fixture corpus, the 105-case generated classifier, integration 197, semantic admission,
the storage oracle, and primary 66/66 in both environments.

### Dart package cache, tests, generated callers, and traces

Dart migration `.2.3` adds a focused process oracle:

```bash
bash tools/test_dart_project_data_storage.sh
```

Targeted Dart commands use the same storage boundary:

```bash
(cd dart && bash ../tools/run_dart_project_data.sh test)
```

`PUB_CACHE` controls hosted packages but not every Dartdev read. Process containment later showed Dartdev consulting
`HOME/.dart-tool/dart-flutter-telemetry.config` before several subcommands honored the package cache. The targeted
wrapper therefore gives only the Dart child a repository-local HOME at
`/.linkedspec-data/cache/dart-home/`; all maintained Dart package/format/analyze/test/run surfaces use it. The
public CLI still reports its established native Dart invocation syntax.

The oracle self-roots and enters managed repository storage. It proves the active run, `TMPDIR`, and `PUB_CACHE`
share the repository device; locks the exact 18 tracked `Directory.systemTemp` owners; requires all 47 hosted
packages and hashes in `dart/pubspec.lock`; resolves them offline; and exercises native pipeline traces, an emitted
source caller package, and trace-control paths. `native_pipeline_trace_test.dart` independently requires Dart's
resolved `Directory.systemTemp` to equal routed `TMPDIR`. The complete `tools/run_dart_local.sh` gate invokes the
same oracle after its 337 package tests and continues through primary 66/66 twice and corpus 105/105.

The repository-relative Dart cache contains 5,903 package payload files / 63,744,165 bytes with hash
`039c5fd8728ea44f23b028ee9400846c353e71a071d46da355b8e1e0d857f29e`. Its 47 pub index files differ from the
shared cache only in volatile `_fetchedAt`; canonical JSON with that field removed has matching hash
`21e59ae7c96ad7a94b77f7e854a685d4729c22623486a1acea4ab444777f067b`. The warmed SSD cache moved atomically from
its noncanonical target-era root into `/.linkedspec-data/cache/dart-pub/`, leaving no duplicate source.

Only after successful offline resolution and full-gate use were the two exact shared `active_roots` records for
the current and absent former checkout deleted with their empty hash shards. Shared active-root residue is zero.
The shared package payload is ambiguous multi-project data, so it remains untouched and supported workflows no
longer consult it. Canonical signoff with the default Dart cache passes Rust admission 1/1 in 77.57 seconds, Dart
admission 1/1, Julia 416/416 in 27.1 seconds, primary 66/66 twice, and Phase 0 1,031/1,031 in 624 seconds.

### Julia depot, temporary workspaces, generated output, and traces

Julia migration `.2.4` adds one targeted self-rooted command boundary:

```console
$ bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3'
```

The wrapper derives the current checkout from its own file, enters managed scratch, defaults package operations to
offline mode, and uses the retained repository depot followed only by Julia-managed system depots. It deliberately
does not consult the developer-home depot. The canonical first depot contains the five external package trees
locked by `julia/Manifest.toml`—JSON3, Parsers, PrecompileTools, Preferences, and StructTypes—plus the General
registry. Their exact source payload is 146 files / 710,665 bytes with canonical hash
`6840ce825c96acd208d308fc58baac1306dcfd64afe1dc4b365f1eccfe906af1`.

The recurring process oracle is:

```console
$ bash tools/test_julia_project_data_storage.sh
```

It freezes all 17 tracked `mktempdir()`/`tempdir()` owners, checks filesystem-device identity for the managed run,
`TMPDIR`, writable depot, and every package file, rejects package symlinks and an explicit external depot entry,
and proves JSON3 loads from the first depot. Its Julia probe requires `tempdir()` to equal routed `TMPDIR`, writes
generated v2 source and a trace beneath `mktempdir()`, and leaves no completed `jl_*` workspace.
`julia/test/runtests.jl` independently locks the same temp-root contract. The complete
`tools/run_julia_local.sh` gate invokes the oracle between package tests and primary/corpus proof.

The warmed source-bearing depot moved atomically from its noncanonical same-SSD location into the canonical cache.
The two exact old internal-volume depots were copied into repository-relative retained migration storage and
independently verified before deletion. The larger copy contains 346 directories / 256 files / 133,963,036 bytes
with hash `bddd661bcfb5e43b4cdb4f688d0de68530e8a94ee0b8f1c38ac873c89d8c9ed8`; the query copy contains 24 directories /
15 files / 4,284,303 bytes with hash `aa599da3058fc18240fad33792b0a2d006731abb8c2bc7f2348b78aeb4c3030c`.
Only after offline loading and the complete package/primary/105-fixture gate passed were both exact old sources
deleted. The exact former-checkout stanza in the shared developer usage log was also deleted; ambiguous shared
depot content remains untouched and unused.

Julia's package manager creates a `manifest_usage.toml` index containing absolute checkout and managed-run paths.
That file is disposable package-GC metadata, not a dependency cache, so supported package wrappers remove it after
the child command while retaining package sources, registry, and compiled cache. This prevents a move from leaving
stale checkout identity in retained project data. All 88 existing current Julia Knowledge Map reverify cards now use the
targeted wrapper, complete gate, or self-rooted primary checker. The workflow-routing oracle covers 30 boundaries,
including all eight Julia-consuming cross-backend checkers.

### Lua native modules, temporary workspaces, generated output, and traces

Lua migration `.2.5` adds a targeted self-rooted wrapper for either ABI:

```console
$ bash tools/run_lua_project_data.sh puc -e 'local l = require("linkedspec"); print(l.backend_name())'
$ bash tools/run_lua_project_data.sh luajit lua/test/rule_local_cursor_descriptor_test.lua
```

The wrapper enters managed repository scratch, creates a unique native directory, builds the selected ABI's PCRE2,
filesystem, and MCP-system modules, supplies repository `LUA_PATH` and the disposable `LUA_CPATH` to the child, and cleans the
native tree on exit. `tools/build_lua_native.sh` is also self-rooted: it compares the nearest existing output
ancestor with the repository device before creation and validates the resolved directory afterward. A caller-
selected output on another filesystem is rejected without creating the requested path.

The recurring process oracle is:

```console
$ bash tools/test_lua_project_data_storage.sh
```

It freezes the exact 17 Lua-family allocation owners, requires every Lua owner to read routed `TMPDIR`, rejects
hard-coded operating-system temporary templates and anonymous `io.tmpfile()`, and builds both three-module ABI sets
below a managed path containing a space. It checks actual filesystem identity and non-symlink module files, runs a
real native parse, writes generated-source v2 and trace output, rejects an other-filesystem builder destination,
and proves exact cleanup. The complete `tools/run_lua_local.sh` gate reuses its two ABI builds and runs the oracle
after the standalone MCP 111 + 210 proofs and both 177-test suites per ABI, primary 66/66 twice, and corpus
105/105. Three new self-rooted boundaries raise the
hostile outside-cwd routing proof from 30 to 33.

Both initial old-root censuses contained zero exact `linkedspec-lua-*` directories, and the complete proof leaves
them at zero. There was therefore no retained Lua payload to copy or delete. The installed Lua interpreters,
compiler, `pkg-config`, ABI/PCRE2 headers and library, and operating-system libraries are strictly necessary read-
only toolchain inputs, not project storage. One composite Knowledge Map command whose remaining scratch belongs to
Python/Rust is explicitly deferred to tool-family `.2.6`; all five Lua-owned stale commands now use managed
boundaries.

### Python, Knowledge Map, mdBook, and tool-generated output

Tool migration `.2.6` adds one targeted Python boundary:

```console
$ bash tools/run_python_project_data.sh tools/check_unicode_case_contract.py
```

The wrapper accepts only a repository-root-relative, nonsymlink Python script, initializes managed scratch, and
stores imported bytecode below retained `/.linkedspec-data/cache/python-pycache/`. Both Unicode contract checkers
also select an explicit verified managed temporary root, so invoking either checker directly cannot fall back to
an operating-system temporary filesystem. Maintained documentation and canonical CI use the wrapper.

Knowledge Map integration now configures the portable bundle's optional `KM_OUTPUT_VALIDATOR`. Generation checks
the nearest existing output ancestor before directory creation and validates the realized map after writing;
checking also rejects a configured map on another filesystem. The portable bundle keeps this hook empty by
default. LinkedSpec supplies it through the repo-relative `.knowledge_map.conf` initializer without persisting a
checkout path.

Build the public book only through:

```console
$ bash tools/run_mdbook_local.sh
```

The wrapper resolves the default `book.toml` destination, `MDBOOK_BUILD__BUILD_DIR`, and every `-d`/`--dest-dir`
argument relative to the book root when needed. It rejects another-filesystem or symlink output before launching
mdBook and verifies the created directory afterward. This preserves caller-selectable same-SSD output while
preventing project HTML from leaking onto another volume.

The recurring proof is:

```console
$ bash tools/test_tool_project_data_storage.sh
```

It freezes three Python temporary owners, 13 shell allocator owners, and 19 Python checker entrypoints. It creates
real retained bytecode, Knowledge Map, fake-mdBook HTML, CLI workspace, and TAP artifacts on the repository device;
locks both oracle subprocess captures to initialized `TMPDIR`; proves hostile Python, Knowledge Map, and mdBook
destinations are rejected without creation; and works through the outside-cwd routing oracle. The only deliberate
cross-volume reads are bounded device/absence checks needed to prove rejection. An initial exact census found one
disposable 88-line Julia audit list in the old temporary root; after content/provenance classification, that exact
file was deleted and both frozen old roots returned zero LinkedSpec tool residue. Adding the Python wrapper and
tool oracle brings the outside-cwd routed-entrypoint proof from 33 to 35 boundaries.

Final `.2.6` signoff passes every affected Python contract, environment/lifecycle/tool storage oracles, all 35
routed boundaries, actual book generation, Knowledge Map 716 facts / 5,653 question keys, five doctrines, and zero
managed runs. Canonical local CI passes Rust semantic admission 1/1 in 77.49 seconds, Dart 1/1, Julia 416/416 in
27.0 seconds, both 66-case primary environments, and Phase 0 1,031/1,031 in 624 seconds.

Reconciliation `.3.1.1` then checked every frozen source/destination/deletion record. It found one missed exact
same-SSD owner: root-relative `rust/target/project-data-ssd-rooting/`, containing a duplicate 12,741-file Cargo
cache and 13 disposable scratch files. The cache matched the canonical root in file count/bytes and had a
byte-identical registry tree; locked offline fetch passed before deletion. The exact 12,754-file/2,376-directory
old root was deleted, and locked fetch plus all six backend/tool storage oracles pass afterward. Both frozen old
temporary roots and the shared Dart/Julia metadata scans have zero LinkedSpec matches. Ambiguous multi-project
caches remain untouched and unused. Descendant-liveness remediation `.3.1.2` binds each managed command and all
descendants to one marker-v2 process group before the final residue proof.

The separately committed final audit `.3.2` does not infer cleanliness from those migration records. It resolves
both inherited temporary roots at runtime and checks their bounded LinkedSpec-identifying namespaces before real
destination use. It then runs the Perl, Rust, Dart, Julia, Lua, and tool storage oracles and repeats the old-root,
shared Dart active-root, shared Julia usage-log, superseded target-identity, and managed-run censuses. Every pre-
and post-use result is zero, so there is no deletion target: no external or shared path is changed. Retained copies
still match Perl 65 directories / 17 files / 1,590 bytes and Julia 346 directories / 256 files / 133,963,036 bytes
plus 24 directories / 15 files / 4,284,303 bytes. The final audit therefore closes existing-data migration while
preserving ambiguous multi-project caches exactly as found.

Structural enforcement follows through the registered `PROJECT-DATA-STORAGE` doctrine:

```console
$ bash scripts/check_project_data_storage_locality.sh
```

The checker reads tracked current code, configuration, tests, tools, root guidance, every book chapter, and the
executable `reverify:` line of each Knowledge fact. It rejects concrete operating-system-temporary, developer-home,
unrooted cache/depot/build/output, and unsupported external storage defaults. Explicit caller inputs, inert path or
privacy fixtures, necessary external executables and libraries, and external roots read only by rejection tests
remain legal. Twenty-eight embedded reject/accept cases run with every check, including bare maintained Dart-command
rejection, scalar/list-form Knowledge reverification commands, the exact inert CLI usage label, and the process
oracle's narrowly scoped contained hostile-cache injection. The doctrine is one registry entry, so the existing pre-commit and
local-CI driver enforce it automatically; after the relocation closeout registered its composed oracle, hostile
outside-cwd routing covers 40 entrypoints. Manual TAP, failing-set, and focused-test examples in `TOOLBOX.md` use a checkout-derived diagnostic
directory instead of an operating-system temporary path.

### Relocated process containment

Structural proof is composed with a real process-level oracle:

```bash
bash tools/test_project_data_process_locality.sh
```

On macOS the oracle uses `sandbox-exec`, selected because `fs_usage` and `dtruss` require root on the current host.
It archives a collision-safe checkout view below managed repository scratch, clone-copies the retained Dart/Julia
caches and built Rust primary, and starts from the runtime-derived system temporary root on another filesystem with
hostile temp, Cargo, Dart, Julia, and Python cache variables. The kernel profile denies writes outside the relocated
checkout except `/dev/null`, denies developer-home and both OS-temporary data reads, and admits one exact read-only
caller input.

The driver requires the exact `caller-input dart julia lua perl rust tool` probe set. Each primary backend writes a
nonempty trace beneath the relocated root, and the Python checker creates bytecode beneath the routed cache. Kept
mutation checks reject an old-volume write, a shared Cargo-cache read, a symlink escape, and an omitted tool probe;
any denied-access or `xcrun_db-` diagnostic fails the successful driver. The initial run exposed both Dart's hidden
HOME telemetry read and Apple's `/usr/bin/cc` shim attempting a per-user-temp `xcrun_db-*` refresh. The Dart wrapper
above removes the first. On macOS `tools/build_lua_native.sh` removes the second by invoking the active developer
tree's real `clang` with the active SDK instead of the stateful shim; required compiler, SDK, header, library, and
interpreter reads remain the frozen read-only external dependency class.

Correction `.6` closes a later false RED in that oracle. Calling `getconf DARWIN_USER_TEMP_DIR` after the common
initializer had replaced `TMPDIR` could return managed project scratch, so the oracle misclassified correct SSD
routing as a same-filesystem host-temp failure. It now consumes only the pre-routing runtime capture described
above and requires a capture marker, an existing nonsymlink directory, and another filesystem device. Embedded
mutations reject missing and repository-device substitutions. Environment, lifecycle, routing, all six storage
oracles, structural/path doctrines, relocated containment, both 66-case primary CLI runs, and Phase 0 1,031/1,031
in 626 seconds pass locally. No machine-specific host path is persisted and no project destination changes.

Final enforcement signoff passes all six family storage oracles, eight affected parity drivers, the 28-case
structural doctrine, the historical `.4.2` inventory of 38 routed boundaries, Knowledge Map 721 facts / 5,713
question keys, mdBook, memory, all six
doctrines, and zero managed runs. The complete canonical gate passes Rust semantic admission 1/1 in 78.09 seconds,
Dart 1/1, Julia 416/416 in 27.2 seconds, both 66-case primary environments, the nested relocated containment
proof, and Phase 0 1,031/1,031 in 620 seconds.

### Final storage closeout

Closeout leaf `PROJECT-DATA-SSD-ROOTING.5` independently recomposes the complete contract instead of treating the
per-family results above as sufficient. A fresh census before and after all backend and parity work resolves the
system and per-user OS temporary roots at runtime. Both are on another filesystem and both contain zero bounded
LinkedSpec-identifying top-level entry. The shared Dart active-root and Julia manifest-usage surfaces contain zero
LinkedSpec file; `rust/target/project-data-ssd-rooting/`, the old `/private/tmp` Julia depot, and the old temporary
audit list are absent. No exact owner reappeared, so closeout deletes zero external path and leaves ambiguous shared
caches untouched.

The retained migration copies remain exact: Perl is 65 directories / 17 files / 1,590 bytes; Julia is
346 directories / 256 files / 133,963,036 bytes plus 24 directories / 15 files / 4,284,303 bytes. Cargo home, Dart
package cache, Dart child home, Julia writable depot, Python bytecode cache, and Rust target all have the same
filesystem device as the current repository. The canonical Julia depot retains no `manifest_usage.toml`, and the
managed-run census is zero.

Julia “offline resolution” is specifically network-free dependency resolution from the repository-relative
`/.linkedspec-data/cache/julia-depot/` writable depot. All five locked external package source trees live there on
the repository filesystem. The Julia executable and Julia-managed read-only system depots are externally installed
host-toolchain resources; they are strictly necessary reads, not LinkedSpec package or project-data stores.

The complete backend proof passes Rust core 193, runtime 149, corpus 105, generated classifier 105, integration
197, semantic admission 1/1, storage, and primary 66x2; Dart format/analyze, 337 tests, storage, primary 66x2, and
corpus 105; Julia 9,297 assertions, storage, primary process proof, and corpus 105; and PUC Lua plus LuaJIT 177
tests each, storage, PUC primary 66x2, and corpus 105. The maintained variant matrix then passes:

- primary CLI: 660/660 across five backends, default/POSIX environments, and 66 cases;
- self-hosted Unicode manifest: 10/10 across the same ten backend/environment legs;
- diagnostic and logical selected primary cases: 10/10 each;
- root-rule selection: 60/60; rule-local cursor: 50/50;
- duplicate-slot and repeated-action selected primary cases: 10/10 each;
- punctuation-light: complete across all five backends and both Lua ABIs;
- scalar/numeric: 55/55 across Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT.

Each focused matrix also passes its maintained native, generated, descriptor or trace, capability, support, and
corpus boundaries as applicable. Final canonical CI passes all six doctrines, Rust semantic admission 1/1 in
80.02 seconds, Dart 1/1, Julia 416/416 in 28.3 seconds, Perl primary 66/66 twice, relocated process containment,
and Phase 0 1,031/1,031 in 638 seconds. This closes ADR `0053` storage migration and makes repository-relocation
closeout the next architecture action.

Post-closeout correction `.6` leaves that migration result unchanged. It fixes only the process oracle's
pre-routing host-temp authority as described above, passes the complete local gate through Phase 0 1,031/1,031 in
626 seconds, and recloses the storage tree at cadence 41/300 without a push.

## CI input areas

The local gate treats these as CI inputs:

- `.github/workflows`
- `tools`
- `specs`
- `conf`
- `tablescript`
- `ebnf`
- `perl`
- `t`

Untracked files in those areas fail the gate.

The former root `plugin/` corpus is intentionally not a CI input area. Its surviving `.plg` files were relocated to
`noncore/plugin/`, outside the core local gate.

That rule is deliberate. A local untracked file in `specs/`, `perl/`, or a corpus directory can make tests pass locally while CI fails or, worse, can hide a missing fixture. The gate forces those inputs to be tracked and reviewable.

The aggregate-selector source scanner also creates one positive untracked `.dart` probe to prove that its git
inventory cannot miss a new file. That probe is a serialized transaction: an advisory lock covers creation,
discovery, rejection, cleanup, and the final repository scan. It lives at repository root, so the scanner sees it
but the routed Dart formatter does not enumerate a disappearing package test. The public admission check runs three
staggered scanner processes and requires all to pass with no leftover root or legacy `dart/test` probes.

## Why the regression discipline is important

This project is changing internals aggressively:

- naming cleanup
- compiler-state refactors
- diagnostics tightening
- helper-surface evolution

The regression suite is what makes that sustainable.

It protects behavior across:

- public facade APIs such as `Get(...)` and `get_parser(...)`,
- parser-factory resolution and file loading,
- runtime context and structured diagnostics,
- compiler pipeline stage contracts,
- compiled descriptor state and dependency-regex validation,
- generated handler dispatch,
- ActionIR helper scanning and lowering,
- shipped `.spec` behavior,
- corpus parsing over legacy and real-project inputs.

## Task-tree ownership requirement

All code changes must be task-tree tracked or task-tree owned before they are made.

This is not a guideline. It is a hard, non-negotiable requirement:

- Every code change belongs to a specific task-tree leaf with a stable `TREE.N.N` identifier.
- A leaf must exist in the active task tree before implementation begins.
- Commit messages must carry the leaf identifier for traceability.
- If a change does not fit an existing leaf, split the leaf or create a new one before writing code.

For staged code/spec/test/tooling changes, the doctrine gate also requires the owning task file to carry the
task-acceptance checklist from `TOOLBOX.md`. The checklist records the reproduction/issue, root cause, fix,
verification, no-regression evidence, and lockstep documentation state.

If that check fires unexpectedly, inspect the staged set with `git diff --cached --name-only`. The intended
fix is to unstage unrelated governed files, stage/update the owning task-tree checklist, or split the work into
a smaller leaf. The check is intentionally narrow: it does not audit historical task files and does not re-run
commands copied into Markdown. The actual proof remains the focused validation recorded in the task leaf plus
the local CI gate.

The separate `TASK-TREE-METADATA` doctrine is also deliberately narrow. It rejects a completed tree with a live
frontier and two status/evidence contradictions proven by repository history: a pending node cannot say it was
activated task-tree-first, and its `Commit:` field cannot name a different node in the same tree. It does not turn
legacy prose or missing historical commit backfills into unrelated cleanup work. Run it directly with:

```bash
bash scripts/check_task_tree_metadata.sh
```

The task-tree workflow (`docs/TASK_TREE.md`) and per-phase tree files (`docs/tasks/<TREE>.md`) are the authoritative record of what leaf owns what work.

Task-tree ownership improves code quality by ensuring every change traces back to a documented intent with acceptance criteria. It enables interruption-safe recovery from task-tree state, prevents orphan changes that drift from the roadmap, and gives `git log --grep` on leaf IDs a complete ordered history of every leaf.

This requirement applies to all implementation, refactoring, bug-fix, and migration work. Documentation-only changes that do not touch code may reference a documentation-phase leaf but are not required to create a new leaf for small fixes.

When in doubt, create the leaf first.

## Important test surface

The main regression spine is:

```text
t/phase0_regression.t
```

That file is large because it is doing real work: protecting runtime behavior, compiler contracts, shipped specs, and migration slices.

The test file includes several kinds of checks:

- direct unit-style checks for helper/lowering seams,
- descriptor introspection checks for metadata and migration summaries,
- source-level checks that shipped specs use preferred helper DSL forms,
- smoke checks for selected shipped parsers,
- corpus regression checks over `conf/`, `tablescript/`, and `ebnf/`; the former root `plugin/` corpus was relocated
  to `noncore/` and no longer participates in the core gate,
- trace and runtime-context checks.

### Validation fuzzing harness

A dedicated validation fuzzing harness exists at:

```text
t/phase0_validation_fuzz.t
```

This test uses systematic edge-case generation (combinatorial, boundary, and
malformed-input patterns) across the main Validation.pm surfaces:

- `_parse_rule_label_line` — rule label parsing (~60+ edge cases)
- `_scan_rule_edges_in_fragment` — edge scanning with depth tracking (~20+ cases)
- `validate_spec_content` — envelope validation (15 cases)
- `validate_dsl_syntax` — full DSL syntax validation (~10+ cases)
- combinatorial rule label fuzzing (168 generated combinations)

Run it with:

```bash
prove -v -Iperl t/phase0_validation_fuzz.t
```

## Documentation-only changes

For book-only slices, the full phase0 gate is often not necessary.

Use the documentation gate:

```bash
git diff --check
bash tools/run_mdbook_local.sh
```

`git diff --check` catches whitespace problems that should not enter the repo.

`bash tools/run_mdbook_local.sh` proves the public book still builds.

If a documentation slice touches examples that depend on behavior, inspect the relevant source or tests as needed. If a documentation slice changes commands, public API examples, or documented behavior, run the relevant code/test gate too.

## Code or spec changes

For implementation, `.spec`, or regression changes, prefer the shared local CI gate:

```bash
bash tools/run_ci_local.sh
```

For a small syntax-only Perl change, at minimum run the focused syntax checks:

```bash
perl -c perl/LinkedSpec.pm
perl -c -Iperl t/phase0_regression.t
```

But before committing a real behavior change, run the full local gate unless there is a clear reason not to and the limitation is recorded.

## How to interpret failures

Read failures by owner and surface:

- A syntax failure in `perl/LinkedSpec.pm` means the facade or an eagerly loaded dependency is broken.
- A syntax failure in `t/phase0_regression.t` means the regression lock itself is malformed.
- A failure in shipped-spec helper-flow checks usually means ActionIR/lowering migration behavior changed.
- A descriptor metadata failure usually means compiler state, migration summary, or descriptor projection changed.
- A corpus failure usually means a parser change broke a realistic input class.
- An untracked CI input failure usually means a file was added locally but not staged/tracked.

When in doubt, preserve the failing test output and debug from the narrowest failing owner upward.

## Developer rule of thumb

Use this compact rule:

```text
docs-only change:
  git diff --check
  bash tools/run_mdbook_local.sh

code/spec/runtime change:
  bash tools/run_ci_local.sh
```

If a code/spec/runtime change also changes public understanding, update the public book and run the book build too.
