---
id: cursor-compatibility-eager-block-return-escape
title: A compatibility cursor statement can leave an eager with return unscoped
answers:
  - "why does restore_cursor inside with return from the entire Perl handler"
  - "which task owns cursor statement eager block return scope"
  - "is cursor eager with return escape a deferred helper vocabulary grant"
date: 2026-10-30
status: bounded56.0 repaired/targeted-checked; rewind Number result56.1 separate
tags: [perl, cursor, eager-block, with, return, scope, lowering]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.56.0; cursor-statement-scope-perl-intake.json.gz retains actual3healthy/7RED to10GREEN, nearest14,16 exact rewrites and original/new owner/producers/normal/ABI. Original selection intake remains cursor-effect-result-selection-intake.json.gz."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/cursor_statement_scope.t t/input_mark_value_block_statements.t t/user_function_parser_state_boundary.t"
---

The bound-target candidate already uses a supported completed fluent source, yet
restore_cursor();return(value) inside its immediate with returns scalar2 from the
whole handler. The remaining add/order C/outer Array never executes. Native/fresh
agree and metadata incorrectly stays ready1/raw0. This is ordinary eager context,
not an authorized expansion of the deferred CodeblockRuntime helper vocabulary.

Public substitution shows raw {do{restore ABI};return value} inside the outer
with do block. MethodLowering::_lower_ast_block_side_effect_statement lacks the
compatibility cursor statement role; typed body lowering falls back to authored
block text, then lower_ast_with_trailing_block_call_node accepts nonempty raw text.
Later Contracts helper substitution preserves the host return escape.56.0 owns
reusing the original zero-argument statement ABI and keeping block-local return
scope before new rewind result methods56.1. Null save/restore versus numeric
rewind behavior, stack/anchors/context/function/arity/error/schema stay unchanged.

The first combined target is not healthy and earns no feature-target RED credit.
An attempted Reset control did not advance and its expected6 was withdrawn.
An initial named carrier used bare blocks (lifecycle I) and missed a bound snapshot
insertion; no calibration credit. The final descriptor-qualified explicit self
action edges and consuming Advance child supply the independent healthy twin.

## Verified bounded repair

56.0 shares the original four emitted bodies in Contracts::_cursor_compatibility_value_expr and adds only the canonical zero-argument eager statement role after
the pure-function fence. Existing block-local return lowering now stays typed.
Same10groups3healthy/7RED to10GREEN, nearest input-mark/block10 and function4 plus
syntax pass. Nine value/cursor/ready observations and four descriptor-only
function fences retain actual proof. Sixteen zero/surplus/keyword/trailing public
rewrites are byte-identical; this is not invalid-program execution/phase proof.
No runtime/state/anchor/stack/arity/deferred/source-value/schema changes. Actual
inputs/producers/normal/ABI/results retained in cursor-statement-scope-perl-intake.json.gz.
Regenerate previously emitted affected Perl parsers;56.1 source-result role next.
