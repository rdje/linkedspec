---
id: capture-reset-value-block-statement-gap
title: Perl ordinary value blocks lack a void anonymous capture-reset statement role
answers:
  - "why does start_capture_slice fail inside a cat operand block"
  - "can capture_slice_here run as a value-block statement"
  - "which task owns capture reset inside expression-valued blocks"
  - "does capture reset block ready1 mean generated source compiles"
date: 2026-10-28
status: Perl35.1 repaired/Rust35.2 compatible and targeted-checked; Dart35.3 next, peers/full admission open
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

## Current bounded Perl35.1

The six failing groups of the unchanged eight-group regression become8pass on
the first candidate. Contracts _anonymous_capture_reset_statement_expr provides
the exact original canonical/alias reset body to late contracts and new narrow
AST/text nonfinal ordinary statement paths after function guards. Both original
bodies/public standalone substitutions are byte-identical and readonly Number
owner is unchanged; no mutator value-source or deferred grant follows.

Final test appends six function/deferred groups, checked separately6pass with
byte-identical healthy core prefix; nearby Number7pass and syntax pass. Fresh
shared fixture/native/metadata/source confirm real execution/raw0/ready1. Packet
capture-reset-value-block-perl-intake.json.gz retains epochs and actual artifacts.
No full14 combined run/global admission is claimed. Pure function reset stays
blocked/unready with boundary2; excluded callback helpers stay typed unknown.
Their false-ready metadata is31.6.4.4; defined-parent native child error loss is
[[perl-collecting-parent-runtime-error-loss]], scheduled41 before admission.

Rust35.2 independently already supports all eight ordinary controls. New3 plus
nearby Number6 pass native/restored CompiledSpec/plan, runtime unchanged. Existing
literal callback reset is supported, while pure-function/pure-apply callbacks stay
blocked for both aliases. See [[capture-reset-value-block-rust-compatibility]].
No new vocabulary or full admission follows; independent Dart35.3 is next.
