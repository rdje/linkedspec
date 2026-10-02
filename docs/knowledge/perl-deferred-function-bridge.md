---
id: perl-deferred-function-bridge
title: Perl deferred calls reuse central compiled registered-function bodies
answers:
  - "can a Perl deferred codeblock invoke a registered pure function"
  - "how do emitted codeblocks dispatch registered functions without capturing an environment"
  - "how does Perl preserve callback recursion identity through copies"
  - "why must equal independently constructed callbacks remain distinct"
  - "does the Perl registered bridge restore actual typed exceptions and function state"
  - "why does the frozen normalization still fail after registered dispatch repair"
  - "can a fresh checkout reconstruct the deferred function bridge probes"
date: 2026-10-02
status: bounded bridge verified; literal and normalization prerequisites remain
tags: [perl, functions, codeblock, composition, compiler, recursion, partial]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.1: 71 exact native/fresh emitted sources,605 top-level tests; old three-module baseline88 failures; six direct-dependent suites123 tests; seven original controls succeed. Checkpoint docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.1-verification.json binds producers, sources, logs and paired observations. Canonical exact-candidate outcome belongs to commit/receipt."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/codeblock_push_composition_perl.t t/callable_codeblock_literal_contract.t t/variadic_user_function_contract.t t/uniform_binding_contract.t t/map_leaves_mutation_perl_contract.t t/actionir_ast_parser.t t/trace_actionir_method_lowering.t; then inspect the source-bound checkpoint and owning prerequisite leaves."
---

MethodLowering::_codeblock_runtime_invocation_expr builds an explicit registered_functions table outside
plain callable records. Entries contain normalized signatures/common final-codeblock metadata and bodies
compiled by the existing central function lowerer, or plain typed lowering_error data. Its private runtime
argument-array mode binds fixed parameters and a fresh rest array, then clears before nested static calls.
It retains existing local declarations, working frames and returns; startup32 declaration/argument order
is unchanged. Compiler private names avoid the registry's parameter/local and caller-name inventory.

CodeblockRuntime::_eval_call selects registered functions before same-named bound callbacks. Dispatch
rejects keyword/arity before operands, promotes only accepted contextual final blocks through unchanged
CallableContract, evaluates arguments once in source order and checks the final value kind. The compiled
body receives explicit invocation context; no runtime compilation or second function interpreter exists.
Unsupported unused definitions remain diagnostic table data, so they do not poison caller readiness.

Active function names cross compiled/interpreted boundaries; central lowering localizes the appended
stack and restores it on failure. Codeblock recursion tracks opaque origins using weak Hash::Util::FieldHash
keys on actual body AST objects. Record clones retain the token, including BindingRuntime publication;
shallow compiled copy shares the original AST. Evaluating a literal creates a new AST instance. Tokens
retain neither AST nor environment, and no ninth record field is introduced. Value-derived keys were
rejected by a real finite three-callback control: two independently constructed equal callbacks must
execute distinctly, while aliases/copies must retain recursion rejection.

Actual native controls retain distinct argument/rest values and restored contexts, reject deliberately
aliased results, inspect real operand effects/handler entries and compare refaddr of the typed exception.
The fresh emitted child independently inspects rest identity, operand effects/entries, actual exception
identity and restored function/caller state. Existing23 push/17 scope/four diagnostic checks remain;
original33 source rows are byte-exact.71 paired values/errors and50 raw stdout observations from rows without runtime errors
agree; failure stdout includes native framework traces and is not claimed as matching DSL events.

RED requires the exact old BindingRuntime, MethodLowering and CodeblockRuntime modules. Facade dependency
BEGIN blocks prepend @INC, so a naive include/preload override selected current modules and falsely passed.
The corrected bootstrap prebinds all three canonical %INC keys to committed copies before absolute requires,
asserts their paths and absence of the new origin provider, and propagates through PERL5OPT to the child.
Its completed605-test run fails88 tests. The original contract scratch was accidentally replayed during
implementation; dated outputs were regenerated with the old modules and all24 checkpoint hashes match.

All seven original isolated controls now succeed. Frozen normalization still fails with undefined count;
generated while condition and infix increments remain unlowered despite ready1/raw0/fallback0/unresolved0.
P1 .0.4 owns source/contract diagnosis and repair. At the earlier bridge boundary a valid x,y literal
passed the AST facade but emitted raw invalid Perl; .0.2.1.3.1 subsequently protects its signature
delimiter, with nineteen healthy native/fresh pairs. Deferred attached-if and residual event-order
gaps remain separately owned by .0.5/.0.6 before dispatcher closeout. No whole pipeline, neutral16 semantic-mutant execution, other-backend parity,
new syntax, public admission or generated-format-v2 claim follows. Startup19/32/35/87 remain separate.

The checkpoint now preserves exact producer source lines and hashes, including the baseline bootstrap
and checkpoint instrument, plus a root-relative reconstruction recipe and ordered replay commands.
Hash-only scratch pointers were insufficient for fresh-checkout recovery; canonical attempt2 was
deliberately interrupted143 before completing to correct that gap. Reconstruct with the development
book's checkpoint recipe, verify every source/baseline hash before writing, and re-run from the captured
implementation source boundary. Future compiler/book changes may intentionally change these dated
observations;71 current regression oracles remain tracked in the existing test and recurring CI.
