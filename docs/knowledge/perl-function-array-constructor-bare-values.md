---
id: perl-function-array-constructor-bare-values
title: "Perl function array constructors can emit identifier spellings instead of values"
answers:
  - "why does array(value,value) inside a Perl function return the word value"
  - "do Perl array constructors and array literals agree inside user functions"
  - "which task fixes function array constructor bare arguments"
date: 2026-09-24
status: confirmed defect; immediate repair SESSION-STARTUP-READING.90 after .89
tags: [perl, functions, arrays, constructor, lowering, SESSION-STARTUP-READING]
evidence: "Public Get returns [value,value] as literal strings for fn pack(value) { return(array(value,value)) } called with7; the array-literal twin returns[7,7]. The .89 native and fresh emitted function fixture likewise returns identifier strings. MethodLowering's lower_ast_aggregate_call_node preserves function-local bare names before its multi-argument array-value lowering and emits those names directly. Exact no-read sources/results are in docs/checkpoints/SESSION-STARTUP-READING.90-function-array-constructor.json."
reverify: "Replay the two checkpoint source/input pairs through LinkedSpec::Get with runtime_ctx_ref and emit_generated_source; compare complete typed values and generated array members."
---

The following function returns `["value","value"]` through Perl Get:

```text
fn pack(value) { return(array(value,value)) }
Top::
 -> Done { return(pack(7)) }
Done:
 /x/
```

Changing only the body to `return([value,value])` yields `[7,7]`. Both compile
and execute without a context error. This control has no indexed read, so the
direct-read repair does not account for the constructor failure.

The immediate source is `perl/LinkedSpec/ActionIR/MethodLowering.pm`, closure
`lower_ast_aggregate_call_node`. Its early function-local-variable branch keeps
the spec-level name for aggregate helpers' runtime typed-value interpretation.
That nonempty value preempts the later multi-argument `array` branch which would
lower a bare scalar read. The constructor then emits `[value, value]` as host
Perl; the generated source's relaxed strictness permits these barewords.

Startup `.90` owns the bounded fix, including native/function/fresh emitted
recurrence, parameter/local/mixed/nested cases, and preservation of actual
aggregate-helper interpretation and one-argument selector retirement. It follows
`.89` immediately, before `.51`. The `.89` function read test uses the array
literal twin to isolate read semantics; the constructor failure remains owned
and must be fixed in its own slice.
