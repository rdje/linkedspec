---
id: semantic-call-signature-and-container-projection-gaps
title: Perl and Rust semantic calls claim unsupported arity acceptance and omit calls inside array expressions
answers:
  - "why does semantic call_signature_accepts accept the wrong argument count"
  - "why is a trim call inside an array absent from semantic query"
  - "why does Rust semantic array assignment lack a binding source"
  - "which task fixes semantic call signature evidence and composite traversal"
date: 2026-09-07
status: confirmed on paired Perl/Rust public queries; repair pending under SESSION-STARTUP-READING.67
tags: [perl, rust, semantic-introspection, calls, arity, evidence, source-reference, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.31 reads the full Rust call projector and runs six paired public query controls plus six Perl Get controls; exact source mechanisms and independent signature/value checks are retained."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl .linkedspec-data/scratch/startup89-semantic-bindings/probe.pl .linkedspec-data/scratch/startup90-semantic-call-evidence"
  - "bash tools/project_data_run.sh .linkedspec-data/scratch/startup89-semantic-bindings/probe .linkedspec-data/scratch/startup90-semantic-call-evidence"
---

# Call evidence and traversal gaps

The public Perl/Rust SemanticIndex APIs return compiled snapshots, successful queries and empty diagnostics
for all six exact sources below. The query requests every record at text detail; the reused harness keeps
the caller logical name `startup89.spec`. No target execution is requested by semantic construction/query.

A declared `fn normalize(value) { return(trim(value)) }` has `arity_min = arity_max = 1` in both responses.
For calls with zero, one and two arguments, both nevertheless emit `call_signature_accepts`.
The zero/two summaries explicitly say those counts satisfy `normalize(value)`, contradicting the signature
and argument-shape count in the same response. The valid one-argument control retains the expected evidence.

In Rust `call_projection.rs` 540–614 and Perl `SemanticCallProjection.pm` 416–470, the explanation builder
formats that acceptance step from the supplied count and declared parameter names without testing compatibility.
ADR 0049 requires portable decisions supported by their actual input facts; paired wrong answers alone cannot
establish that requirement. The contradiction here is independently checkable from the response's own signature.

With an unused function present to bypass the separately owned .22 gate:

| Assignment RHS | Edge call names on both query APIs | Perl Get value |
| --- | --- | --- |
| `trim(" x ")` | trim, return | `"x"` |
| `[trim(" x ")]` | return only | `["x"]` |
| `trim(trim(" x "))` | trim, trim, return | `"x"` |

Both call walkers unwrap scalar assignment and recurse through call arguments, then return for every other
expression kind. The array node therefore hides its active trim child. Rust `emit_statement` also registers
a binding source only when its RHS emits a call; the array binding has null source while Perl retains the exact
`[trim(" x ")]` source/span. Five paired full query responses are equal; this one binding source is the only
difference in the sixth. It is not the repeated-ID/source-overwrite mechanism already owned by .66.

Six separate Perl `Get` controls exit normally with empty stderr: the zero/two-argument calls yield null,
the one-argument call yields `"x"`, and the three container controls yield the values above. These observations
do not establish a Rust target-execution result, a typed runtime failure, or any behavior on other backends.
Source correlation/scanning, mixed edge kinds, lifecycle/function-local containers, keyword/rest/codeblock
compatibility, paging/relations/MCP and other runtime variants remain acceptance work under .67.

The source causes are Rust `rust/linkedspec-runtime/src/semantic_index/call_projection.rs` 299–383 and
540–614; Perl `perl/LinkedSpec/SemanticCallProjection.pm` 316–345 and 416–470. No runtime repairs landed.
The exact six sources/request, twelve responses, six Get outcomes, reused probe/library identities, commands,
status and supporting source proof live in `.linkedspec-data/scratch/startup90-semantic-call-evidence/`.
Its manifest covers 36 files/210,609 bytes; manifest itself is 7,246 bytes, SHA-256
`ace19ad5c4d9d7868b413017894086e7ff62eac3ca9badc12b27a44cf0cfc2d1`.
Independent assertions are 2,084 bytes, SHA-256
`01ffb7cbe877993595a1ebfef98c232070e3d73b92bcb99b123a91ffbbab71f4`.
Rust query execution takes 7.057 seconds, Perl queries 11.115, Perl Get 11.056; all exit 0 with empty stderr.
The already-verified .89 Rust probe is reused without recompiling. Its retained binary is dated diagnostic
evidence and must be rebuilt against current verified code before claiming repair proof.

Fresh neutral semantic proof still passes six groups/20 exact queries/128 mutations at rollout 9/0 and
admission 6/0. Existing exact fixture equality does not cover these counterexamples.

## September 10 Dart recurrence and bounded counter-controls

`DART-STARTUP-READING.1.30` adds nine public Dart query/typed-runtime controls,
recorded in [[dart-semantic-call-projection-counterexamples]]. The array case
reproduces omitted trim and null binding source while typed ActionIR contains
the call and runtime returns ["x"]; startup .67.2-.67.4 retains that repair.

Zero/two arguments instead reject semantic construction on unresolved contracts
and separately reject runtime arity, while exactly one succeeds. Four same-name
assignments keep distinct IDs/sources. These Dart controls do not reproduce the
earlier Perl/Rust false acceptance or Rust repeated-ID cause. Separate regex
source miscorrelation is owned by Dart .2.20. No other-backend or MCP rerun is
claimed; the earlier paired evidence remains unchanged.
