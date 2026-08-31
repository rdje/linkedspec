---
id: map-leaves-mutation-neutral-contract
title: "The map_leaves! contract guards one receiver binding and commits before continuation"
answers:
  - "what is the neutral map_leaves bang contract"
  - "is map_leaves bang current on any backend"
  - "what AST node owns map_leaves bang"
  - "which bang methods are allowed in version one"
  - "can map_leaves bang use a temporary or nested receiver"
  - "does map_leaves bang revisit replacement subtrees"
  - "what callback fields does map_leaves bang bind"
  - "can a map_leaves bang callback mutate the same receiver"
  - "are shadow bindings rejected as reentrant map_leaves mutation"
  - "does continuation failure roll back map_leaves bang"
  - "why do current backends reject map_leaves bang differently"
date: 2026-08-31
status: accepted neutral contract; implemented on Perl, remaining backends/admission pending
tags: [language, mutation, map-leaves, receiver-methods, traversal, reentrancy, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.1.2 adds capability_conformance/map_leaves_mutation_contract.json and tools/check_map_leaves_mutation_contract.py. The independent checker passes 4 valid syntax, 14 invalid syntax, 5 exclusions, 10 successes, 8 pre-commit failures, continuation/shadow/guard-release/nonbang/detachment proof, and 167 rejected mutations. A checked-in action-edge control returns the same nested value on Perl/Rust/Dart/Julia/Lua. Its minimal one-token bang twin becomes null on Perl/Rust (Rust warns) and a generic parser-invocation failure on Dart/Julia/Lua. Parser and Perl ActionIR/toolbox inspection prove all current fluent method grammars are identifier-only and Perl classifies the bang segment as raw_perl/invalid_fluent_chain. No backend behavior or capability is admitted."
evidence_update_2026_08_31_composition: "FUTURE-PARITY-BACKLOG.19.1.3 makes the existing checker also execute six shared callback compositions and one post-commit continuation against the unchanged write-vivification authority. It retains 167 base mutations and rejects 593 composition scalar/container-shape mutations. Exact composed current probes preserve the same pre-runtime bang boundary on six routes; no backend behavior is admitted."
evidence_update_2026_08_31_perl_write_boundary: "FUTURE-PARITY-BACKLOG.19.2.1 implements only ordinary nested-write vivification on Perl. Perl fluent parsing still rejects map_leaves!, so receiver mutation and callback composition remain unimplemented on every backend; .19.2.2 owns the Perl bang path."
evidence_update_2026_08_31_scope_conflict: "The .19.2.2 implementation audit confirms two frozen helper carriers assume implicit caller binding capture by an unparameterized fn, contradicting the admitted pure function-local scope. Exact Perl proof leaves caller tree/audit unchanged. Implementation is decision-blocked; no bang behavior or contract bytes changed."
evidence_update_2026_08_31_perl_implementation: "The director chose pure-function-preserving option A. FUTURE-PARITY-BACKLOG.19.2.2 corrects the two carriers, implements the dedicated Perl receiver_mutation_chain parser/lowering/runtime, guards every executable receiver-write route including binding-target array pipelines, and passes 58 focused tests, 167 base plus 592 composition mutations, and all 1,032 Phase 0 tests. Rust, Dart, Julia, Lua, portable capability, and public admission remain pending."
evidence_update_2026_08_31_write_surface_signoff: "Expanded Perl signoff found documented three-argument split(target, source, delimiter) stopped at AST value-helper arity inside a callback before the binding-target array-pipeline owner. MethodLowering now routes recognized pipeline statements to that owner first. Fatal-warning live proof covers split, split_each, trim_each, filter_nonempty, filter_match, lowercase_each, uppercase_each, uniq, composed pipelines, and all four array-end methods; each active-receiver attempt raises receiver_mutation_reentrant with the authored span before writing."
reverify: "bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py && PERL5OPT=-Mwarnings=FATAL perl -Iperl t/map_leaves_mutation_perl_contract.t && rg -n 'parse_name|_parse_fluent_call_segment|_parseFluentCallSegment|_action_parse_fluent_call_segment|parse_fluent_call' rust/linkedspec-core/src/expr.rs perl/LinkedSpec/ActionIR/AST/Parser.pm dart/lib/src/action/action_parser.dart julia/src/action/ActionParser.jl lua/src/linkedspec/action_parser.lua"
---

# Neutral `map_leaves!` contract

`FUTURE-PARITY-BACKLOG.19.1.2` freezes `linkedspec-map-leaves-mutation-v1` before backend implementation. Its sole
v1 syntax is `IDENTIFIER.map_leaves!() { ACTION_BLOCK }`. The bang is one suffix on this receiver method token,
not an identifier character or a general permission for functions, aliases, `walk_leaves!`, `reduce_leaves!`, or
bang continuations. One dedicated `receiver_mutation_chain` AST owns the bare `binding_reference`, mutation call,
callback block, authored Unicode-scalar spans, and ordinary non-bang continuation.

The receiver resolves to an existing uniform-binding identity holding an harray or array. The runtime deep-copies
that root and traverses only the snapshot's original shape. Hash roots recurse through hashes in sorted-key order;
array roots recurse through arrays in index order. Cross-kind aggregates are leaves. Each callback gets detached
`value`, complete copied `path`, `depth`, and `key` or `index`; its detached result replaces the leaf. A replacement
with the root container kind is not revisited.

The resolved binding identity is guarded for the callback interval. Direct assignment, nested write, nested
`map_leaves!`, and helper-mediated writes through that same identity fail before mutation with
`receiver_mutation_reentrant`. Earlier effects on unrelated bindings persist. A scoped or parameter binding with
the same spelling is a distinct identity and is allowed. Callback failure or re-entrancy leaves the receiver
unchanged; the guard is released on every exit.

After all callbacks succeed, the rebuilt root is committed once. A detached updated root becomes the bang call's
result, and only then does ordinary fluent continuation execute. A continuation failure therefore preserves the
completed receiver commit. The committed binding, returned root, snapshot, callback frames, and aggregate callback
results share no writable host aliases.

Perl now implements this contract through the dedicated AST and copy-on-write runtime. The exact non-bang control
remains unchanged on all five backends; the bang form is current only on Perl. Rust still stops at the identifier
and returns null with its parse warning, while Dart/Julia/Lua expose their generic parser-invocation failure.
Those four implementations and portable/public admission remain owned by later `.19` leaves.

Composition with nested write-vivification is frozen separately by [[write-map-leaves-neutral-composition]].
The implementation-time function-scope conflict in two composition carriers was resolved without caller capture;
see [[map-leaves-function-scope-contract-conflict]].
