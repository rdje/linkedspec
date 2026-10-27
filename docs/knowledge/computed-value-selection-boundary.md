---
id: computed-value-selection-boundary
title: Computed Array and Hash bracket reads need general typed postfix composition
answers:
  - can a split result be indexed directly
  - can a literal array be indexed before a fluent method
  - why does Perl split call indexing fail handler compilation
  - which task owns computed value bracket selection
  - does computed selection change grouped expression or write syntax
  - is value_access already represented by the native backends
  - why does actionir_ast_parser expect an obsolete substr sentinel
  - how do computed receiver and selector writes stay function local
  - why are direct computed call results separate from fluent literal selections
  - can value_access recognition change legacy callable raw status
  - why does a deferred computed read report ready but fail execution
  - how does Perl preserve deferred literal AST vocabulary
  - how does Perl distinguish computed data helpers from bound callables
  - does Perl direct registered function indexing work after helper selection
date: 2026-10-27
status: Perl noncall and governed data-helper sources checked; registered calls/full admission open
tags: [actionir, selection, fluent, arrays, hash, perl, composition]
evidence: "TYPE23.1.4 public Get/fresh probe and exact computed-selection-intake.json; normative computed-selection.md/shared fixture."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/computed_selection_noncall_contract.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/computed_selection_helper_calls.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/computed_selection_deferred_boundary.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/computed_selection_callable_compat.t"
---

At d98e139d7, named signed/typed selected continuations work on public Perl
Get/fresh, while pure-call/fluent/Array-literal/Hash-literal/block postfix reads
fail handler compilation. Exact source/errors are retained in the linked intake.
Perl AST only parses binding-based access and fluent call segments; its lowerer
has a special raw callable-result bridge through CodeblockRuntime::read_path,
not general typed computed access. Other runtimes already carry value_access
(receiver plus segments), with distinct admitted parser source shapes.

TYPE23.3.24 owns the additive ordinary read feature, Perl first and independent
backend checks after it. Reuse existing entry kinds, signed valid reads, once-only
receiver then ordered selectors and actual-result consumers. Full target and
exclusions are docs/checkpoints/type-operation-inventory/computed-selection.md.
Named read lookup order, grouping87.4, computed writes, dynamic Hash-key/coercion,
copy-domain/depth, callable/deferred/context and portable admission remain separate.
No backend support is inferred from merely carrying the AST node. Planned book
syntax must not become a runnable promise until its implementation is checked.

Related: [[rust-single-index-read-bypasses-typed-binding]],
[[terse-array-receiver-value-chains]], [[write-vivification-neutral-contract]].

Perl24.1.1 now emits typed fluent/literal/block reads through the shared guarded
ValueExpr reader, preserving named output and source/selector scopes. Bounded
native/fresh PASS36, frozen callable compatibility PASS5 top-level, parser PASS24,
direct selected/indexed PASS36, syntax and a ready zero-fallback descriptor pass.
Direct calls remain excluded: the wider candidate reroutes existing callable
negative-float/string reads, changing counts0 to2/null and raw1 to0. The original
producer/RED/restored packet is computed-callable-compat-intake.json. Restoring the
legacy path preserves four exact values1/2/0/0 and raw1.24.1.2 owns direct pure/
helper/function reads without reader/count/provenance/metadata promotion. Parent
24.1/full fixture and other backends remain open; AST names alone prove no support.

Three parser source-layout/sentinel assertions were stale after String19.1
(ea6f82c2a). Exact base producers reproduce them; the retained baseline probe/JSON
shows healthy discard and malformed substr-null behavior. Assertions now execute
semantic values. An initial -I-only overlay was invalidated by actual module paths,
then corrected explicitly. This repair is closed with24.1.1; full admission stays open.

24.1.2.0 repairs introduced explicit deferred-literal drift: global recognition
changed the executor's raw_perl failure to value_access and raw1/ready0 to0/1.
A scoped literal-body grammar fence restores prior parsing, error fields and
readiness; ordinary and inline reads remain supported. New regression PASS22,
direct callable PASS5 and syntax pass, including Unicode spans and restoration
after parse failure. Packet/producer: computed-deferred-boundary.json and
probe_computed_deferred_boundary.pl. Initial launcher postlude failure is retained;
corrected distinguishing replay exits0. No deferred operation or waiver admitted.
Approved bounded scalar/null copy4.2.2 is complete; direct computed calls resume.

24.1.2.1 adds statically governed ordinary data-helper Call receivers. The
purpose-specific MethodLowering resolver first canonicalizes through the known
helper-name owner (also used by function-name collision validation), then reuses
semantic String/Array/Hash value methods and Numeric helper families plus data
constructors/logical helpers. Trace-only family labels and runtime values are not
grammar authority. Flat list splices and context/control/rule/unknown names remain
excluded; Parser consults the owner lazily with OwnerDispatch error preservation
only after its deferred-body fence. No new AST fields or metadata waiver.
Native/fresh helper/ownership/scope/source-error/AST/readiness test PASS43, cold
parser incoming-error preservation, frozen four callable values1/2/0/0/raw1 and
direct noncall/deferred PASS58 retain their controls. New simple helpers are
raw0/unresolved0/ready1. The unchanged full target still fails compilation at
registered entries() selection, raw1/unresolved0/ready0;24.1.2.2 owns that required
source class before complete Perl/Rust handoff. Full source/context/portable
admission remains23.4. Known SESSION7 EPERM recurs in the full diagnostic job;
its eventual complete output is consumed, without any lifecycle/receipt claim.
