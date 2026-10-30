---
id: perl-push-aggregate-value-abi
title: Perl aggregate push values reuse the complete typed statement owner
answers:
  - "why did saving push with a Hash payload leave raw Perl syntax"
  - "why did AST-only push reuse fail for Hash value blocks"
  - "does the ActionIR argument source projector support block_value"
  - "which Perl owner preserves push payload local returns"
  - "why was the uniform assigned transform expectation corrected"
date: 2026-10-30
status: bounded P1 producer58.0 repaired/targeted-checked; direct result roles pending
tags: [perl, push, hash, array, values, source, scope]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.58.0; push-payload-perl-intake.json.gz retains unchanged calibrated8groups4RED to8GREEN, nearest13 TAP items/syntax, original-owner counterfactual, source/projector/emitter distinction and actual producers/inputs."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -v -Iperl t/push_payload_values.t t/uniform_binding_contract.t"
---

At396be4d4275a ordinary saved push Hash/Array-containing-Hash values retain DSL
colon syntax, unresolved push and handler/fresh-source compile failures. The AST
correctly carries Hash/Array nodes and the existing complete _lower_push_statement
emits BindingRuntime::push_value. Value paths fail to reuse that owner.

_lower_aggregate_push_value_call now guards canonical two-argument/plain-target/
no-trailing aggregate literals and reuses the complete owner in semantic value
and compatibility paths. _actionir_ast_call_arg_sources uses a partial source
projector with no block_value case; AST-only _lower_ast_call_statement reuse
returns undef for Hash value blocks. Scoped trace shows raw assignment followed
by an unmatched nested-return rewrite/source-span miss. The complete statement
owner's existing fallback instead preserves original payload blocks/local returns.
Original statement/runtime/parser/function/arity/copy/mutation/schema and all
remaining MethodLowering bytes stay exact. No read/fluent/child/ambiguous-source
rights are added. Regenerate affected previously emitted Perl parsers.

Same calibrated8groups4RED/4healthy to8GREEN native/fresh/metadata; three healthy
value observations/original error observation byte-equal. Initial borrowed child
cursor1 expectation corrected to actual0 before production, original epoch kept.
Nearest uniform13 TAP items (12 subtests plus one flat assertion) passes after
correcting one pre-existing assigned trim_each/filter_nonempty expectation to
the existing pure-value contract. Exact activation MethodLowering-only replay
reproduces original failure, verified by SHA and failing Hash-payload falsifier;
independent public native/fresh no-push source yields trimmed copy, untrimmed
filtered copy and unchanged original. First replay FindBin setup2 is not product
RED; corrected setup then observes1. No whole-checkout/canonical proof follows.

New normal canonical registration remains23.4.1. Readers58.1.1/fluent58.1.2 and
independent peers remain separate, with full23.4/admission prerequisites open.
