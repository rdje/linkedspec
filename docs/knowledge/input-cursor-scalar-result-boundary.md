---
id: input-cursor-scalar-result-boundary
title: Readonly input and cursor scalar results need typed composition before legacy substitution
answers:
  - can input_text split into an indexed String entry directly
  - why does cursor_rest coalesce leave an undefined host helper
  - why does a named input reader default work while its direct chain fails
  - which task owns input and cursor scalar result continuations
  - why can a scalar set_key block produce invalid Perl despite ready metadata
  - why does quoted match_has fail while a bare capture name works
  - did the first context scalar probe inspect the correct rule metadata
date: 2026-10-27
status: bounded Perl27.1 implemented; independent Rust27.2 next; compiler/policy28.1 and capture-name29.1 owned
tags: [perl, fluent, source-location, input, cursor, scalar]
evidence: "TYPE23.1.7 public native/fresh/Value descriptor/substitution packets at af1fda392; input-cursor-results.md and current typed source-location contracts."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/input_cursor_result_continuations.t"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_context_scalar_results.pl named_input_cursor_defaults direct_input_cursor_defaults input_cursor_consumer_rejection"
---

Existing direct match/input String split flows and bare capture-presence helpers
work. Named input/cursor defaults yield ALPHA/11/!/1; direct defaults instead fail
emitted compilation near )[ and simpler cursor_rest coalesce/cat leaves a host
coalesce call. Input scalar take/set_key block operands also fail near {{, with
Value raw0/unresolved0/ready1. MethodLowering's typed Call fallback lacks several
getters known only to later Contracts substitution; failed fluent lowering then
leaves DSL alongside emitted source. Existing legacy consumer dispatch lacks the
actual-result guard and leaves a set_key key block authored.27.1 owns proper
reader/result composition through existing getter owners, without cursor effects.

The first six-case instrument inspected Top rather than action-bearing Value.
Its exact bytes/stdout/stderr plus refinement writer remain in the first gzip
capsule, and are not action-bearing readiness proof. Corrected nine-case and three
input/cursor packets inspect Value. Native child errors can be diagnostic stdout
with an outer [null] result; fresh compiled/execute channels distinguish failure.
The original preludes and existing SESSION7 setpgid EPERM are retained/disclosed.

Constant literal/named/context scalar take/set_key roots retain legacy []/Hash
policies, while cat/add scalar prefixes enable clean null guards.28.1 owns policy
assessment and actual block-key compiler repair before admission. Quoted capture
names leave known host calls with ready metadata; bare names lower. Contracts'
bare-only rewrite/unresolved patterns explain this distinction.29.1 owns intended
static syntax/lowering-or-rejection/readiness and book clarification before
admission. Neither finding is treated as a successful null read or fixed here.

Frozen target/shared fixture and independent27 children preserve eleven readonly
input/cursor readers, signatures/bounds/kinds/source order/defaults and compatible
String/Number/inter-type methods. No new helper/type/AST field/callback/write/copy
or legacy root policy is selected. Full admission stays23.4.


Perl27.1 shares the ten zero-argument getter bodies with native contract rewriting
and uses the existing input_slice lowering. Exactly eleven static source shapes
now enable typed actual-result dispatch. A first candidate repairs ordinary reader
chains but loses origin through the legacy trailing-with source rebuild. The
retained candidate/repaired AST/substitution packet shows the raw block Hash key
before repair. Folding only reader-owned with prefixes through existing AST nodes
retains that origin, including fluent prefixes, without changing parser/schema.

Five new native/fresh/Value raw0/unresolved0/ready1 groups pass; expanded with
controls also pass independently for Array/Hash/Bool results and outer restoration.
Shared all-spelling output, empty/zero/kinds, source SWC/snapshots, lazy defaults,
String split/signed/String transitions, typed Number index and operand skips hold.
Direct defaults13 and source-location contract4 pass. No cursor/bounds/projection,
callback/control/free/named legacy policy or generated field changes. Rust27.2
independently follows; full23.4/28.1/29.1/registration/pressure owners remain.
