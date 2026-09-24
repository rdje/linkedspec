---
id: perl-direct-read-autovivification-gap
title: "Perl direct reads preserve missing and null paths after the .89 repair"
answers:
  - "can Perl direct reads create missing containers"
  - "why does reading a missing Perl path replace null or create an array"
  - "which task repairs Perl direct read purity"
  - "do the write vivification read exclusions hold through Perl Get"
date: 2026-09-24
status: repaired under SESSION-STARTUP-READING.89; native and fresh generated recurrence verified
tags: [perl, bindings, arrays, read, autovivification, SESSION-STARTUP-READING]
evidence: "Six public Get/call_spec_handler_subst and Rust CLI observations are retained in docs/checkpoints/SESSION-STARTUP-READING.89-read-purity.json. Five Perl reads mutate the root or an intermediate; one existing-container control agrees. All six Rust results preserve expected state. No handler errors explain away the mutations."
reverify: "env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/generated_source_contract.t t/write_vivification_perl_contract.t t/actionir_ast_parser.t t/trace_actionir_compact_lowerers.t"
---

ADR0036 and `write_vivification_contract.json` require reads to leave state
unchanged. The neutral `read_exclusion_cases` include an absent root and a missing
intermediate. The public book and earlier implementation cards repeated that
requirement as an unconditional implementation fact. Startup `.88` independently
checked it while reviewing its Rust indexed-read documentation and found a Perl
violation:

| State and read | Perl state afterward | Required state afterward |
| --- | --- | --- |
| absent `items`; `items[0]` | `[]` | absent/null observation |
| `items = undef`; `items[0]` | `[]` | `null` |
| `tree = {}`; `tree["missing"][0]` | `{"missing":[]}` | `{}` |
| `tree = []`; `tree[0][0]` | `[[]]` | `[]` |
| `tree = {"missing":undef}`; `tree["missing"][0]` | `{"missing":[]}` | `{"missing":null}` |

Each read returns null, so a result-only check misses the state mutation.
`tree = {"list":["a"]}; tree["list"][0]` returns `"a"` and preserves the
existing container on both engines. All six sources compile and run without a
Perl context error; Rust preserves the complete expected objects.

Toolbox lowering shows `$items->[0]`, `$tree->{"missing"}->[0]`, and
`$tree->[0]->[0]`. The first-party owner is
`perl/LinkedSpec/ActionIR/MethodLowering.pm`'s typed-AST direct-access closure,
with a parallel compact-source path in
`ValueExpr.pm::_lower_direct_nested_access_value_expr`. Both previously started from the base
lexical and concatenated raw `->{...}` / `->[...]` dereferences. The initial intake
identified only ValueExpr; `.89` public trace and a controlled ValueExpr-only
change showed that the public AST path must also be repaired. Autovivification changes
the observed binding. This is separate from the Rust private-map defect repaired
by `.88`, and separate from Perl grouped-postfix owner `.87.4`.

`.89` restores the existing contract through one guarded expression emitter in
ValueExpr, shared by both lowering paths. A lexical read cursor retains the
receiver across selector execution; each compatible rvalue lookup updates only
that cursor. Generated temporary names avoid authored and nested-expression
identifiers. No binding is stored, vivified, copied or marked present by the read.
Selector order/count on valid or missing paths and explicit effects remain
ordinary Perl behavior. Wrong-kind paths now yield null and evaluate selectors
normally instead of raising a raw host dereference exception. Strict write-selector
policy is unchanged.

`t/generated_source_contract.t` executes 25 direct cases twice natively and twice
in an independently loaded fresh child, plus function parameter/local reads,
selector failures/order, receiver retention, temporary-name collisions, and tied
root/presence/reference-identity controls. The LF/CRLF book source is included and
executed directly. `t/write_vivification_perl_contract.t` now actually runs all
three frozen `read_exclusion_cases` through public Perl lowering; the neutral
Python model alone was never Perl runtime proof. The original diagnostic results
above remain the pre-repair baseline. Regenerate saved Perl parser source.

The separate function array-constructor failure is owned for immediate repair by
`.90`; its literal twin isolates the read tests. Grouped postfix remains `.87.4`.
No neutral expectation, serialized/generated-source format, backend policy or
six-runtime gate changes in this repair.

Related: [[write-vivification-receiver-mutation-direction]],
[[write-vivification-perl-reference]], [[rust-single-index-read-bypasses-typed-binding]].
