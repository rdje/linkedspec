---
id: capture-reset-value-block-statement-gap
title: Perl ordinary value blocks lack a void anonymous capture-reset statement role
answers:
  - "why does start_capture_slice fail inside a cat operand block"
  - "can capture_slice_here run as a value-block statement"
  - "which task owns capture reset inside expression-valued blocks"
  - "does capture reset block ready1 mean generated source compiles"
date: 2026-10-28
status: bounded target35.0 frozen; independent implementation35.1-.5 next; no runtime change
tags: [perl, blocks, capture, void, source, readiness, statement]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.35.0 at clean0d0382338; seven public native/fresh/metadata/substitution sources and emitted bytes retained in capture-reset-value-block-authority.json.gz."
reverify: "Recover probe_capture_reset_value_block.pl from the packet and run through tools/project_data_run.sh env PERL5LIB= perl -Iperl; require completed output before the strict consumer."
---

The seven explicit Value[2] controls separate healthy block without reset and
standalone reset from five failing inside/alias/local-return/lazy sources. Native
null is not success: fresh emitted source cannot load despite raw0/unresolved0/
ready1. Public substitution retains assignment/cat DSL inside the operand, with
only the reset rewritten late. MethodLowering _lower_ast_block_side_effect_statement
and text _lower_block_side_effect_statement fall through to value-component
lowering, which lacks this void statement source; the whole block is abandoned.

Existing expression-block and source-boundary authority supports the narrow repair:
zero-argument start_capture_slice/capture_slice_here as nonfinal ordinary statement
effects, through the existing boundary-write owner. Preserve operation/alias names,
frame/cursor/registers, source-before-effects snapshot, lazy skip and local returns.
No mutator-as-data or new callback/function/helper/AST/schema rights follow.
Target/fixture and backend owners35.1-.5 are frozen in capture-reset-value-block.md;
other backend failures are not inferred and healthy implementations need no patch.
See [[terse-expression-valued-block-early-return]] and
[[capture-boundary-number-result-lowering-gap]].
