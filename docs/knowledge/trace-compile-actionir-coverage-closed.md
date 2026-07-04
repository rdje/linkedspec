---
id: trace-compile-actionir-coverage-closed
title: TRACE-OBSERVABILITY.3.4.6 closes compile/ActionIR trace coverage through MethodLowering
answers:
  - "is compile ActionIR trace coverage closed"
  - "what remains after MethodLowering trace coverage"
  - "does a normal compile emit all ActionIR trace namespaces"
  - "does TRACE-OBSERVABILITY.3.5 need more compile ActionIR instrumentation"
  - "what remains after TRACE-OBSERVABILITY.3.5"
  - "how do I reverify compile ActionIR trace closeout"
date: 2026-07-04
status: current
tags: [trace, observability, actionir, ruleir, emitcontext, method-lowering, task-tree, mdbook]
evidence: "TRACE-OBSERVABILITY.3.4.6 representative routed debug descriptor-compile probe; docs/tasks/TRACE-OBSERVABILITY.md; docs/linkedspec-book/src/public-api/trace-api.md"
reverify: "perl -Iperl -MFile::Temp=tempdir -MFile::Spec -MLinkedSpec -e 'my $tmp=tempdir(CLEANUP=>1); my $trace=File::Spec->catfile($tmp,\"trace.log\"); my $spec=q{Top::\\n /x/ -> Done { set(:name, \" a,b \"); set(items, [\"a\", :name]); set(:count, name.trim().split(\",\").count()); if(true) { set(:flag, \"yes\") }; return(array(copy(items), :count, :flag)) }\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1, trace_level=>\"debug\", trace_log_file=>$trace, trace_log_mode=>\"route\", trace_reset_log=>1); open my $fh,\"<\",$trace or die $!; my $log=do{local $/; <$fh>}; for my $re (qr/rule_ir:/, qr/emit_context:/, qr/actionir:scanner/, qr/actionir:rewrite_pipeline/, qr/actionir:control_flow/, qr/actionir:method_lowering/) { die \"missing $re\\n\" unless $log =~ /$re/; } die \"not ready\\n\" unless $d->{spec}{Top}{meta}{action_rewriter}{language_agnostic_action_ir_ready}; print \"compile/actionir trace closeout OK\\n\";'"
---

`TRACE-OBSERVABILITY.3.4.6` closes the planned Perl reference compile/ActionIR trace coverage split.

A representative normal descriptor compile now emits these trace namespaces together:

- `rule_ir:`;
- `emit_context:`;
- `actionir:scanner`;
- `actionir:rewrite_pipeline`;
- `actionir:control_flow`;
- `actionir:method_lowering`.

The same probe preserved ActionIR readiness (`ready=1 raw=0 unresolved=0`), so the closeout did not introduce raw
Perl fallback or unresolved-helper drift.

`TRACE-OBSERVABILITY.3.5` has since closed overall trace no-drift and split the Rust/future-variant trace parity
lane. The active follow-up is `TRACE-OBSERVABILITY.4.1`, not another known opaque compile/ActionIR owner.
