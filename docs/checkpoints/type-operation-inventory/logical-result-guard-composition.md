# Eager logical Boolean source and prefix guard composition

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.26; implementation family23.3.65.
Authority: logical-results.md17, logical-receiver-methods.md23, ADR0043,
logical-helper-v1, selected-values and current scalar/null copy authority.

Canonical ordinary positional and/or require at least one value; not exactly
one. Ordinary .and/.or require at least one right-hand value; .not no arguments.
Valid arity precedes operands, then all operands run eagerly once left-to-right,
even after decisive false/true values. Results remain actual Bool. Bool is not
numeric and does not acquire numeric Array-index authority. False stays present
for defined/nonempty defaults, copies preserve it, scalar text renders 0/1.

Retain actual-kind checks through explicit Array bridges and rejection state
before later immediate with bodies. Incompatible consumers skip operands and
later bodies; legitimate false/null/empty results still enter with. A valid with
returning an Array may continue with Array methods. Keep existing malformed
source/receiver preflight, unknown helpers, aliases, traversal, codeblock truth
without invocation, deferred/callback/context vocabulary, copy/function/parser/
schema and named aggregate fallback separate. No producer/truth/signature change.

```text
and(false).cat("!")                         # "0!"
false.and(true).take(1).with(){return("ran")} # null target; body skipped
not(false).split(",").set_key("k",1)          # null
and(false).with(){return(value)}             # false; body runs
and(false).add(1).with(){return("null")}      # "null"; numeric domain gives valid null
and(false).with(){return(["ok"])}.first()     # "ok"
```

Selection26 freezes logical Boolean source/prefix guard composition65. Public22 native/fresh/descriptor/substitution/emission controls qualify thirteen ready healthy values/five ready wrong values/two matching nulls actually unsupported-with unready/two qualified needed errors; raw0/fallback0. Direct guards already skip operands; rejected take enters later with W on both free and receiver paths, all six true-false free and receiver variants do so, and function continuations enter WX. Public substitution shows with wrapping an already rejected ordinary null, while bridge tails emit unsupported with. MethodLowering early scoped with admission omits logical sources; logical scalar_result also lacks intermediate actual-kind reset. Original eager logical producer works: typed truth/real Bool/false presence/copies/once-order/snapshots/decisive operands/compatible Array bridges/valid false-true-null-empty with and returned Array stay. Needed source failure and typed not arity-before-operands remain exact. Freeze canonical positional and-or1+/not1 and ordinary and-or1+ RHS/not0 prefixes under existing shape policy; no Boolean numeric/index coercion, lazy/truth/deferred/copy/function/parser/schema or host-isolation expansion. All five65 backend owners before production; independent baselines, no peer defect inferred. Actual producers/all inputs/results in logical-guard-selection-intake.json.gz. Perl65.1 next; full23.4/pressure20.1/registration/progress/declared-host/general isolation separate.

## Bounded Perl65.1 implementation

Perl65.1 repairs eager logical source/folded ordinary prefix guard composition: unchanged22 groups15PASS7RED to22PASS native/fresh/metadata; fifteen includes thirteen healthy values/two qualified needed errors. Seven failures comprise five wrong values/two unsupported-with contexts, not seven wrong value programs. All twenty values ready/raw0/fallback0/unresolved0/warning-free; thirteen healthy observations/two source errors exact. Rejected direct/Array-bridge/function continuations skip operands/later with bodies while source SO/eager order persists; all six true-false free and short method variants protected. Original real Bool/truth/false presence/copies/once-order/snapshots/compatible split-select/valid false-true-null-empty with/with-returned Array and typed not arity-before-operands stay. Existing eager producer and method folding unchanged; a narrow logical source predicate joins current scoped rejection state and intermediate actual-kind reset. Initial candidate22 passed but excluded snapshots caught two unknown-tail lowering differences; admission narrowed with existing unknown-call classifier, unchanged final22/fences16 pass. Traversal/non-with trailing/named/deferred/unknown/error/copy/function/parser/schema roles stay; 447 other inputs exact. Nearest logical-result12/logical-method20/numeric-source19=51 and owner-normal syntax pass. Actual producers/all inputs/results in logical-guard-perl-intake.json.gz. Book/card/map/target/task/roadmap/live/resume/history align; explicit new22/fence16/shared22/AST16 canonical registration23.4.1-owned. Regenerate emitted Perl; independent Rust65.2 next. No peer defect/fix/exhaustive excluded-runtime/Boolean numeric-index authority/general isolation/full23.4 admission.

## Bounded Rust65.2 implementation

Rust65.2 repairs canonical free logical source guard composition: unchanged23 tests19PASS4RED to23PASS native/restored CompiledSpec/in-process generated plan; nineteen includes sixteen healthy values/two exact needed source errors/sixteen-shape scaffold. All twenty values/sixteen healthy observations/two errors/sixteen public syntax observations exact. Ordinary receiver-prefix/direct guards/source SO/all six short true-false variants already work and stay; four failures are free-with/free Array bridge/all six free variants/function first-half body execution. A pure exact-arity recognized positional logical source predicate feeds only the existing trailing-with kind guard, excluding traversal and unsupported argument kinds. Original eager producer/typed truth/real Bool/direct logical source dispatch/receiver-prefix guard/with evaluator/preflight/unknown/deferred/copy/function/parser/schema/remaining engine unchanged; 523 other inputs exact. Rejected operands/later bodies skip; eager source SO/once-order/snapshots/false presence/copies/compatible split-select/valid false-true-null-empty with/returned Array/typed not arity-before-operands stay. Nearest logical-result4/logical-method7/numeric-source20=31 and owned core/runtime fmt pass; no owner formatter mutation, exact two source deltas only. Actual producers/all inputs/results in logical-guard-rust-intake.json.gz. Book/card/map/target/task/roadmap/live/resume/history align; rebuild Rust apps/runtime. Independent Dart65.3 next. No peer fix/isolated emitted package/exhaustive excluded-runtime/Boolean numeric-index authority/general isolation/full23.4 admission; opaque dependency warnings retained.
