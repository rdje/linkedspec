---
id: perl-function-array-constructor-bare-values
title: "Perl function array constructors lower parameters and locals as values"
answers:
  - "why does array(value,value) inside a Perl function return the word value"
  - "do Perl array constructors and array literals agree inside user functions"
  - "which task fixes function array constructor bare arguments"
date: 2026-09-25
status: repaired and verified under SESSION-STARTUP-READING.90, including complete Phase0
tags: [perl, functions, arrays, constructor, lowering, SESSION-STARTUP-READING]
evidence: "The clean 83ab2ff44 MethodLowering fails the final constructor regression; the .90 candidate passes native and fresh emitted values. Excluding multi-argument array constructors from the aggregate-name bridge lets the existing AST value lowerer emit lexical reads. Parameters, locals, null/false/container values, nested calls, variadic rest, ordered assignment values, repeated invocation and actual aggregate-helper controls pass. The included LF/CRLF book source executes exactly. Intake and current proof are retained in docs/checkpoints/SESSION-STARTUP-READING.90-function-array-constructor.json and docs/checkpoints/SESSION-STARTUP-READING.90-verification.json."
reverify: "env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/generated_source_contract.t t/uniform_binding_contract.t t/variadic_user_function_contract.t t/actionir_ast_parser.t t/trace_actionir_method_lowering.t t/trace_emit_context_bridge.t; env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/phase0_regression.t"
---

Before `.90`, the following function returned `["value","value"]` through Perl Get:

```text
fn pack(value) { return(array(value,value)) }
Top::
 -> Done { return(pack(7)) }
Done:
 /x/
```

Changing only the body to `return([value,value])` yielded `[7,7]`. Both compiled
and executed without a context error. This control has no indexed read, so the
direct-read repair did not account for the constructor failure.

The original cause is `perl/LinkedSpec/ActionIR/MethodLowering.pm`, closure
`lower_ast_aggregate_call_node`. Its early function-local-variable branch keeps
the spec-level name for aggregate helpers' runtime typed-value interpretation.
That nonempty value preempted the later multi-argument `array` branch which would
lower a bare scalar read. The constructor then emitted `[value, value]` as host
Perl; the generated source's relaxed strictness permitted these barewords.
Using a legal DSL local named `local` additionally produced a host syntax error.

Startup `.90` excludes multi-argument `array` constructors from that name-preserving
branch. The existing typed value lowerer then emits `$value` or `$local` reads;
actual aggregate helpers still use the existing compatibility bridge. Empty,
quoted and computed constructors remain valid, and structural validation still
rejects the exact one-bare-identifier selector shape before lowering.

`examples/function-array-values.spec` is included by the public book and executed
twice through native and fresh emitted parsers with LF and CRLF. Its multiline
function uses newline statement separation; a line-ending semicolon is optional
and valid, while adjacent same-line statements require one between them.

The separate numeric reducer failure inside a function parameter is baseline-
verified and owned by `.91`, which follows `.90` before `.51`; see
[[perl-numeric-reducer-direct-read-rejection]]. No numeric lowering changes are
part of this constructor repair.
