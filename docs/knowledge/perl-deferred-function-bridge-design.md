---
id: perl-deferred-function-bridge-design
title: Compiler-owned bridge plan for registered calls from Perl deferred bodies
answers:
  - "what interface will bridge Perl deferred calls to registered functions"
  - "why does a same-named callback override a registered function in Perl deferred code"
  - "which regression controls must precede the Perl deferred function bridge"
date: 2026-10-02
status: historical selected plan; implemented by perl-deferred-function-bridge
tags: [perl, functions, codeblock, composition, compiler, partial]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.0: 24 exact public Get/descriptor/source-dump controls and independently loaded fresh emitted artifacts from clean2516cf727. Checkpoint docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.0-contract.json binds observations, producers and reviewed inputs. Implementation .1 and canonical reconciliation .2 remain pending."
reverify: "Inspect the checkpoint's exact sources through LinkedSpec::Get/return_descriptor/parser_source_ref and fresh emit_generated_source execution; current regression remains PERL5LIB= prove -Iperl t/codeblock_push_composition_perl.t. This card preserves the pre-implementation boundary; current bounded proof is perl-deferred-function-bridge."
---

Twenty-four native/fresh emitted observations agree. Direct fixed/rest calls and both contextual-final
spellings succeed; their deferred counterparts fail with typed `unknown_helper` for the registered name.
Direct ordered arguments produce `["AB",["a","b"]]`. A same-named codeblock slot makes the deferred
`decorate` call return `"slot"`, whereas registered-function precedence requires `"!x"`. This second
symptom belongs to the same bridge implementation and its regression matrix, not a new language rule.

The public generated source explains the boundary: direct calls contain the central lowerer's function
`do` block, while deferred values contain typed call nodes and invoke CodeblockRuntime with only explicit
rule descriptor/input/match context. That runtime has no registered-function dispatch and falls through
to a scalar-held codeblock. Readiness remains1 with zero raw/fallback/unresolved counts for those deferred
sources; it describes recognized source rather than body execution completeness.

## Selected private interface

Keep the plain eight-field codeblock record unchanged. Extend the explicit generated invocation context
with a compiler-owned `registered_functions` table. Each entry carries the existing normalized positional/
rest signature, optional common final-codeblock contract, and a compiled callable body or an explicit
lowering diagnostic. CodeblockRuntime selects governed helpers, then registered functions, then bound
codeblocks. Definition registration already rejects helper/function collisions.

Generate each callable body through the existing central function lowerer, with a private already-evaluated
argument-array mode. Bind fixed parameters and a fresh rest array in the existing fresh function-local
scope; retain its working-frame, nested static calls, return handling and local declarations. Clear that
private argument mode before lowering nested functions. Do not introduce a second AST function interpreter,
runtime compilation, raw fallback, or a callable/environment field in a codeblock record.

Runtime dispatch validates the existing signature and rejects keywords, evaluates arguments once in source
order, promotes only accepted final contextual blocks through CallableContract, and validates the final
value kind. Hand the resulting values and explicit invocation context to the compiled body. Carry active
function/codeblock state across compiled/interpreted boundaries, unwind it on failure, and preserve the
actual typed exception. Static recursion diagnostics and startup32 remain unchanged. The bridge must reject
recursive mixed calls and distinguish independent same-named callback slots; choose the guard mechanics
against actual behavioral/identity controls during implementation, before claiming acceptance.

Compilation of an unrelated unsupported definition must not turn a ready callback into an unresolved
source. Keep this explicit control while selecting how a table entry retains unsupported-body diagnostics.
Do not erase the diagnostic or report unsupported execution as a successful null result.

## Implementation ownership and limits

`.1.3.3.0.2.1.1` owns MethodLowering.pm and CodeblockRuntime.pm plus an extension of the existing
`t/codeblock_push_composition_perl.t`; no new allocator or CI registration is planned. Add CallableContract.pm
only if common normalization needs a shared helper, declaring that path before editing it. Generated-format
v2 and the public schemas stay unchanged. Private invocation/emission movement requires canonical proof.

Required controls include fixed/rest/zero-rest/final forms; direct and nested calls; source-ordered effects;
fresh scopes and actual frame/slot identities; callback restoration on failure; helper/function/slot
precedence; genuine unknown calls; wrong arity, keywords and final kinds; static and mixed recursion;
private-name collisions; unrelated unsupported definitions; all existing33 sources/279 tests and direct
callable/variadic/binding/map dependents. Original normalization and seven controls are replayed before
dispatcher closeout. Neutral sixteen-case execution remains a later owner, including its semantic mutants.

The keyword baseline reports `unsupported_codeblock_actionir` with detail kind `raw_perl`; this is typed
data rejection, not raw execution. Direct recursive functions retain ready0/unresolved1. The startup32
control still returns null with no runtime error. Startup19/32/35/87 and other backends retain their owners.

October2 implementation `.0.2.1.1` supersedes the pending runtime state, preserving this dated plan
and checkpoint. [[perl-deferred-function-bridge]] records central lowering, opaque origin propagation,
71 sources/605 tests and remaining literal/normalization prerequisites. BindingRuntime clone propagation
was declared before editing; CallableContract and all public authorities remain unchanged.
