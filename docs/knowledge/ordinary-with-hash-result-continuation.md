---
id: ordinary-with-hash-result-continuation
title: Ordinary eager with Hash results need typed continuation dispatch
answers:
  - why does literal String with returned Hash sorted_values stay unsupported
  - why does helper with returned Hash sorted_values return null
  - does with Hash failure lose the block result or method dispatch
  - why does coalesce null repair a with Hash continuation
  - which task owns ordinary with returned Hash method composition
  - should generic with repair widen deferred or unknown call rights
  - why does signed selection after with still report unsupported with
  - why do Rust with scalar results evaluate incompatible container operands
  - why do Dart with scalar results evaluate incompatible container operands
date: 2026-10-27
status: Perl31.1 and Rust31.2.1/Dart31.3 guards repaired; nested identity31.6/full admission separate
tags: [perl, fluent, with, hash, scope, continuation]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.31.0; with-hash-intake.json.gz retains public source/AST/native/fresh/Value metadata/substitution distinctions at clean912c803435."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_with_hash_results.pl"
---

Five direct literal/bound/capture/helper/prefixed with-Hash sorted_values twins
return null on native/fresh with raw0/unresolved sorted_values/unready. Terminal
Hash return works, executes W and restores outer value; Array/Number/Bool/null
continuations work. Adding coalesce(null) yields false/raw0/unresolved0/ready1.
This distinguishes missing actual-result dispatch from a failing Hash producer,
with scoped execution or sorted_values primitive.

Public AST retains the fluent chain, contextual body and following calls.
MethodLowering lower_ast_fluent_chain_node folds typed receiver-with nodes only
for statically owned input/cursor origins; generic roots rebuild helper-with
source. Helper with is missing from its ordinary emitted-result predicate, so
Hash continuation takes the source-based fallback instead of existing actual-kind
value/default-result machinery.31.1 owns this precise repair; do not infer an
independent backend failure or a whole with-family defect from the Perl result.

Frozen with-hash-results.md/shared with_hash_result_values fixture require actual
Hash-to-Array-to-Bool/String and Hash-to-Number methods, source/body once, ABCDE
order and outer value restoration. Preserve immediate scalar/Array/null results,
nested scopes, specific parser-state diagnostics inside pure-function with bodies
and existing arity/error/root/copy/list-splice/mutation/deferred/callback/unknown
call rights. No new helper/type/signature/AST/schema field. Full source/domain/
context/backend admission stays23.4 after bounded independent children31.1-.5.

Perl31.1 retains normalized with helper AST and routes returned values through
existing default-result guards. The first candidate leaves only the frozen signed
selector failing: outer value_access unknown-call inspection treats its inner
immediate with as an unknown data method. Method-selection twin yields Y/ready;
signed twin reports with/unready. Metadata-normalizing that specific receiver
with before the unknown precheck leaves body/helper validation with its typed
owner, including a specific entry_len function diagnostic under indexed output.
Final frozen/native/fresh/metadata and strengthened fence checks pass; earlier
scalar/nested/pure/deferred11 and input-with10 controls are retained. No parser,
schema or deferred/unknown-call rights. Evidence packet discloses candidate/final
scope and no full suite, performance or context admission. Rust31.2 follows.

Rust31.2 independently already passes frozen Hash flow, pure-function scope and
specific indexed reader rejection. Generic helper/receiver with results miss the
existing actual-kind boundaries; scalar3/[] and SWKVANJLT distinguish that defect.
31.2.1 adds helper-with to guarded sources and marks returned receiver-with values
guarded. Four final native/restored/plan tests and direct input-with pass; scope
and callback machinery remain unchanged. Distinct nested with also fails through
active helper-name collision; [[rust-with-callback-name-collision]] and31.6.1 own
that P1 repair before unrelated selection/parent admission. No full/nested claim.

Dart31.3 independently exposes the same guard omission with first-native
3/[]/3/[]/SWKVANJLT, while frozen Hash/pure-function/indexed state fence already
pass. Current guarded-source/result flags gain with; four native/restored/plan
tests and direct input-with pass with format/fatal analysis clean. No frame/parser/
schema changes. Known [[dart-callback-helper-recursion-identity-gap]] remains its
existing owner under priority31.6; no new nested failure or admission inferred.
