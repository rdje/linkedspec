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
date: 2026-10-27
status: bounded target31 frozen; independent backend repairs follow
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
