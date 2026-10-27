---
id: perl-generic-final-codeblock-normalization
title: "Perl normalizes contextual final blocks through callable metadata"
answers:
  - "can Perl with run inside deferred codeblocks"
  - "does Perl support attached final codeblock arguments"
  - "does Perl support parenthesized contextual codeblock arguments"
  - "how does Perl declare that a callable accepts a final codeblock"
  - "do Perl user function signatures record parameter value kinds"
  - "where are Perl block taking helper and receiver methods declared"
  - "does Perl hard code receiver method names for trailing blocks"
  - "what is a codeblock_argument"
  - "does Perl promote a harray in a codeblock parameter"
  - "does callback codeblock include an argument list"
  - "why can Perl call value inside with"
  - "how does Perl with restore callable bindings"
  - "does calling a non callable with value report a typed error"
date: 2026-10-27
status: current
tags: [perl, actionir, codeblock, callable-contract, trailing-block, user-functions, generated-source]
evidence: "Original generic normalization and dated closeout evidence remain in this same card at accepted Git 2fca7d8489038c226fe0454a105f12a2af696a1f. TYPE-REFERENCE-BOOK.1.2.4 owns immediate scopes;16 adds metadata-governed deferred with."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/deferred_with_contract.t"
---

# Perl Generic Final-Codeblock Normalization

LinkedSpec::CallableContract governs builtin helper, receiver and typed user-function final arguments.
The parser recognizes attached receiver syntax without a method-name allowlist; callable metadata grants
semantics. Attached and parenthesized contextual braces normalize to the same version-1 codeblock_argument,
with zero positional parameters and typed body/source payload. Unknown receiver methods still fail validation.

User functions declare only a final value kind, for example callback: codeblock. Definitions, staged bodies
and staged parse jobs retain ordered params, exact arity and parameter_kinds. The declaration has no callback
argument list; an explicit {|item, ...rest| ...} literal owns its invocation signature. Typed functions use
the dynamic codeblock runtime. Immediate helpers retain their existing full-breadth block lowering.
Harrays are never promoted: an invalid final value yields final_argument_not_codeblock. Non-final,
nested-signature, nameless and unknown-type declarations fail before parser construction.

Builtin contracts cover helper with and receiver with, walk_leaves, map_leaves and reduce_leaves.
Contextual blocks read current dynamic values; explicit literals retain their own parameters.
No lexical environment or stored host coderef is introduced. The original July normalization closeout
and its exact historical measurements remain at the Git revision in evidence above; backend progress
belongs to the task trees.

October20 scoped repair: immediate with projects value as a scalar working binding only within its typed
body and dynamic invocation vocabulary. A callable receiver can therefore run as value(), including nested
with and registered-function bodies. The original AST retains authored spans. A function's shared binding
frame temporarily points value at the local slot and restores it on success or error. Other caller effects
remain visible. Helpers and registered functions retain static precedence; bound false/null/string/array/
harray calls reach value_not_callable. Deferred with16 uses the same callable metadata, temporary value/presence slots and caller context; both slots restore on success/error. Contextual bodies execute immediately; explicit callbacks use the existing invocation ABI.
This finite Perl repair does not admit exhaustive methods or another backend.

Related facts: [[final-codeblock-parameter-declaration]], [[callable-codeblock-literal-contract]],
[[perl-callable-codeblock-dynamic-invocation]], [[perl-final-codeblock-signature-declaration-gap]].

October27 preservation25.0: registered final contextual callbacks use the same
deferred computed-read grammar as explicit literals. Parser's signature/count
owner localizes the existing deferred-body flag when parsing an attached body or
reparsing a final parenthesized block. Registry-only fencing was insufficient:
helper/noncall reads otherwise became unsupported value_access with ready1/raw0.
All three forms now retain the explicit raw_perl rejection and raw1/unready.
Ordinary arguments and builtin immediate blocks keep their broader compiled
grammar; named readers, exact Unicode spans and success/failure scope restoration
are preserved. Run t/computed_selection_contextual_boundary.t for the finite
native/fresh/descriptor distinction. No AST field or executor vocabulary is added.
