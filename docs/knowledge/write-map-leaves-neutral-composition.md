---
id: write-map-leaves-neutral-composition
title: "Nested writes inside map_leaves bang keep receiver, unrelated, shadow, and continuation transactions distinct"
answers:
  - "how do write vivification and map_leaves bang compose"
  - "can a map_leaves bang callback vivify its copied value"
  - "is a callback value replacement subtree revisited after vivification"
  - "does an unrelated nested write survive a later map_leaves callback failure"
  - "does a failed unrelated nested write roll back map_leaves bang"
  - "which diagnostic wins when a callback nested-writes the active receiver"
  - "do same-receiver nested-write segment and RHS expressions evaluate before the map guard"
  - "can a same-spelling shadow binding vivify during map_leaves bang"
  - "can continuation write the receiver after map_leaves bang commits"
  - "does continuation nested-write failure roll back the map_leaves bang commit"
  - "what is the current six-runtime boundary for composed write and map_leaves bang source"
date: 2026-08-31
status: accepted neutral composition; both mechanisms implemented on Perl/Rust/Dart/Julia, Lua/admission pending
tags: [dsl, mutation, vivification, map-leaves, composition, identity, atomicity, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.1.3 adds capability_conformance/write_map_leaves_composition_contract.json without a new executable entrypoint. The existing write checker validates eight embedded nested writes; the existing mutation checker executes six callback compositions and one post-commit continuation, retains 167 base mutations, and rejects 593 composition scalar/container-shape mutations. Exact primary-command probes return the non-bang control {\"leaf\":[]} on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. The bang source stops before callback nested-write lowering: Perl returns null; Rust warns at the stopped map_leaves identifier then returns null; Dart, Julia, and both Lua ABIs exit 1 with the generic parser-invocation boundary. No backend or capability is admitted."
evidence_update_2026_08_31_perl_write_boundary: "FUTURE-PARITY-BACKLOG.19.2.1 makes the nested-write half executable on Perl but leaves map_leaves! parsing/runtime untouched. The composed callback/continuation cases therefore remain neutral-only on every backend until .19.2.2 and later backend/admission leaves."
evidence_update_2026_08_31_scope_conflict: "The .19.2.2 audit proves the helper-mediated and post-commit fn carriers cannot reach caller tree/audit under the admitted fresh function-local contract. Existing explicit-target set and caller-scoped with blocks can express the same identity/ordering proof without implicit capture. Director decision is required before fixture or behavior change."
evidence_update_2026_08_31_perl_implementation: "The director chose option A. FUTURE-PARITY-BACKLOG.19.2.2 replaces the impossible helper carriers with explicit-target set and caller-scoped with, preserving pure function scope and all intended observations. The corrected current corpus has 592 composition mutations. Perl implements both mechanisms and rejects every active-receiver write route, including binding-target array pipelines; Rust, Dart, Julia, Lua, capability, and public admission remain pending."
evidence_update_2026_09_01_rust_implementation: "FUTURE-PARITY-BACKLOG.19.3.2 executes the frozen six callback compositions and one continuation boundary on Rust. Direct proof covers callback-value and unrelated vivification, later callback failure, failed unrelated write effects, pre-evaluation same-receiver guard precedence, distinct same-spelling shadow vivification, post-commit continuation failure, and all detachment boundaries. The current composition oracle rejects all 592 mutations unchanged."
evidence_update_2026_09_02_dart_implementation: "FUTURE-PARITY-BACKLOG.19.4.2 executes the six callback and one continuation composition boundaries on Dart through the same typed carrier as the base mutation contract. The required primary-route audit also found both current-boundary sources used an inert parent /x/ contrary to the established parent-loop/child-regex invariant. Removing only that parent regex restores the intended zero-regex Top dispatch to Done's /[a-z]+/; the non-bang result and bang parse boundary then match their frozen observations. The checker digest changes only for those two source bytes and still rejects 592 mutations."
evidence_update_2026_09_03_julia_write_half: "FUTURE-PARITY-BACKLOG.19.5.1 implements the unchanged write half on Julia through typed native/reconstructed/generated/emitted-module/CLI routes. The composed non-bang control and its embedded writes now use Julia's evaluated-selector dense isolated semantics; map_leaves! still fails before callback execution, so full Julia composition remains owned by .19.5.2."
evidence_update_2026_09_03_julia_composition: "FUTURE-PARITY-BACKLOG.19.5.2 executes the frozen six callback and one continuation composition boundaries on Julia. Callback-local and unrelated vivification use the .19.5.1 carrier, same-receiver guard precedence wins before selectors/RHS, same-spelling function parameters remain distinct, non-bang aliases remain isolated, and the zero-regex Top loop selects Done's regex. The current composition oracle rejects all 592 mutations unchanged."
evidence_update_2026_09_04_lua_write_half: "FUTURE-PARITY-BACKLOG.19.6.1 implements the unchanged write half in shared Lua on PUC Lua and LuaJIT through typed native/reconstructed/generated/emitted/CLI routes. The composed non-bang control and embedded writes now use evaluated-selector dense isolated semantics; map_leaves! remains unsupported raw syntax, so full Lua composition stays owned by .19.6.2."
reverify: "bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py && bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py && PERL5OPT=-Mwarnings=FATAL perl -Iperl t/map_leaves_mutation_perl_contract.t && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test map_leaves_mutation_contract && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib receiver_mutation_ -- --nocapture && (cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/map_leaves_mutation_contract_test.dart) && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include(\"julia/test/map_leaves_mutation_contract_test.jl\")'"
---

# Future-neutral write/`map_leaves!` composition

`linkedspec-write-map-leaves-composition-v1` binds the unchanged
[[write-vivification-neutral-contract]] and [[map-leaves-mutation-neutral-contract]] authorities by identity,
repo-relative path, and canonical-JSON digest. It supplies shared fixtures to the two existing checkers; it is not
a third executable or a backend admission.

## Callback transaction boundaries

A callback may nested-write its detached `value` and return the updated result. That result becomes the leaf
replacement, remains detached, and is not revisited during the same original-shape traversal. Merely changing the
callback local still cannot update the receiver without returning it.

A write to an unrelated binding follows the nested-write contract independently of receiver rebuild. Completed
unrelated writes persist if a later callback fails. If the write itself fails, its unchanged diagnostic aborts the
bang call before receiver commit; partial structural path creation is discarded, while any segment/RHS side effect
completed before structural validation retains ordinary write semantics.

The active guard compares resolved identity before attempting a same-receiver nested write. It raises
`receiver_mutation_reentrant` before segment or RHS evaluation, so that diagnostic outranks invalid selectors,
evaluation failures, kind conflicts, and gaps. A helper parameter with receiver spelling but a distinct identity
may vivify normally and cannot write the guarded outer binding.

## Commit and continuation

Complete callback success commits the rebuilt receiver once and releases its guard. Continuation then runs
against the detached result. A continuation helper may reach the receiver and perform an ordinary nested write;
if that write fails, its structural attempt rolls back but the earlier `map_leaves!` receiver commit remains.

The composed source is current on Perl, Rust, Dart, and Julia: both mechanisms execute and preserve the boundaries
above, including generated Rust/Dart carriers and Julia's generated-plan/emitted-module routes. Lua implements
the nested-write half but still rejects the bang carrier. The non-bang
control remains unchanged on all six runtime routes. It uses a zero-regex `Top` whose loop dispatches to `Done`;
only `Done` owns the matching regex. Lua receiver mutation and portable/public admission follow in later `.19`
leaves.

Related: ADR `0036`, [[write-vivification-receiver-mutation-direction]], and
[[tool-project-data-ssd-storage]]. The resolved carrier conflict is
[[map-leaves-function-scope-contract-conflict]].
