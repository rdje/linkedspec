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
  - why do registered result selectors leak function local variables
  - how are contextual callback bodies kept outside registered computed reads
  - why does Rust reject brackets after a split result or array literal
  - how do Rust computed result guards preserve old bound call counts
  - why does Dart split result indexing become an invalid fluent chain
  - how does Dart avoid recursion when a fluent suffix is invalid
date: 2026-10-27
status: Perl/Rust/Dart bounded computed sources checked; Julia/Lua/full admission open
tags: [actionir, selection, fluent, arrays, hash, perl, composition]
evidence: "TYPE23.1.4 public Get/fresh probe and exact computed-selection-intake.json; normative computed-selection.md/shared fixture."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/computed_selection_noncall_contract.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/computed_selection_helper_calls.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/computed_selection_functions.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/computed_selection_deferred_boundary.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/computed_selection_callable_compat.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test computed_selection"
  - "cd dart && bash ../tools/run_dart_project_data.sh test test/computed_selection_test.dart"
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

24.1.2.2 completes bounded registered result sources through an explicitly scoped
Parser registry mirrored from EmitContext's compilation frame. Static helper
ownership remains first; pure definition lookup never parses a body. Staged
function ASTs precede the full registry: lowering alone reparsed a new read while
local/presence/mutation analyses saw raw source, leaking selector assignments.
A private contextual body view now feeds those analyses, emission and runtime
function-table private-name inventory without modifying stored definitions/jobs.
The original source/span is retained, including Unicode scalar offsets.

The new registry context also promoted final contextual callback reads to an
unsupported value_access with raw0/ready1. CallableContract's existing registered
signature/count contract now excludes new registered-name recognition only in
that deferred final-block role; explicit literals retain their fence, ordinary
argument/inline blocks retain composition. Attached and parenthesized callbacks
keep raw_perl errors/raw1/unready. Native/fresh full target and finite scope/kind/
snapshot/rest/private-name/registry/error controls pass76. No new deferred
operation, serialized field, bound-callable reader or metadata waiver. Full
source/context/portable admission remains23.4; independently assess Rust24.2 next.

Rust24.2 finds literal/fluent postfix parsing absent despite existing call/grouped
ValueAccess support. Expr::parse_postfix_value_access now composes at Array/Hash/
eager-block and completed fluent boundaries, then resumes fluent parsing. Existing
eval_access_value already preserves snapshots/ordered selectors. Continuations
reuse the copied-result kind guard, including with/traversal's persistent flag.
Static registered definitions and semantic data-method/numeric alias owners fence
ordinary direct calls; uninterrupted unknown bound-call paths keep their older
dispatcher. A broad candidate changed missing-entry counts0 to null; original
3808c4d94 engine replay (candidate parser, unchanged supported source) and candidate
RED establish that boundary. No full-checkout replay or runtime-value classifier.
Native/restored/generated-plan checks retain the full fixture, kinds/effects/
scopes/bridges/with/callable controls and Unicode regex composition. No new AST
field, evaluator operation or standalone emitted-source admission; Dart24.3 follows.

Dart24.3 likewise had only direct-call access and required each fluent segment to
be a complete call. Its existing delimiter/access-segment owners now parse supported
computed prefixes; maximal contiguous method suffixes retain preflight and recurse
into shorter receiver sources. Empty invalid suffixes must reject before recursion:
the initial candidate's Stack Overflow is reproduced and fixed. Named/grouped
owners, ordinary raw receiver ASTs and existing source/span modes remain. The nested
reader already owns snapshots/ordered selectors. Static registry/canonical receiver-
helper ownership extends copied-result kind guards to ordinary computed reads,
preserving unknown bound counts0/0. Full shared native/restored/plan and finite
scope/effect/with/kind/regex/parser controls pass; no new serialized/evaluator field
or standalone admission. Independent Julia24.4 is next; full admission remains23.4.
