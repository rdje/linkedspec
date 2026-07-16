---
id: perl-diagnostic-output-events
title: Perl native diagnostic helpers use a parse-scoped typed event sink
answers:
  - how do I capture Perl print say and print_each diagnostic output
  - what is LinkedSpec RuntimeDiagnosticOutputEvent
  - is Perl diagnostic output quiet without a sink
  - does Perl print_each evaluate prefix and suffix once
  - how do Perl diagnostic sink failures propagate
  - what does Perl exit_now throw
  - do Perl generated handlers call host print say or exit
  - what do Perl print say and print_each lower to
date: 2026-07-16
status: current
tags: [Perl, runtime, ActionIR, diagnostic-output, events, sink, Unicode, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.1.2 adds LinkedSpec::RuntimeDiagnosticOutput, rewires ActionIR output and exit lowering, and installs an invocation-local sink in Compiler-generated live parsers. FUTURE-PARITY-BACKLOG.5.1.7 extends independently emitted Execute/ExecuteWithTrace/Get while preserving generated failure attribution. t/diagnostic_output_perl_contract.t consumes linkedspec-diagnostic-output-v1 and proves native/generated ordered events, quietness, sink-failure identity, typed exit, and arity-before-effects."
reverify: "prove -Iperl t/diagnostic_output_perl_contract.t t/uniform_binding_contract.t && rg -n 'RuntimeDiagnosticOutput::(emit|terminate)|diagnostic_sink' perl/LinkedSpec t/diagnostic_output_perl_contract.t"
---

The parser coderef returned by `LinkedSpec::Get` accepts optional invocation options after its input reference:

```perl
my @events;
my $input = "xx";
my $value = $parser->(
  \$input,
  { diagnostic_sink => sub { push @events, $_[0] } },
);
```

Each callback argument is a blessed `LinkedSpec::RuntimeDiagnosticOutputEvent` hash with exactly
`helper_name`, `rule_label`, and `message`. Delivery is synchronous and Unicode-preserving. Without a sink, helper
arguments still evaluate but no host stdout or stderr is written.

ActionIR validates `print`/`say` one-plus and `print_each` two-or-three arities before emitting argument evaluation.
For valid calls it snapshots arguments left-to-right exactly once, then emits one event per `print`/`say` call or
one per array item. Empty and wrong-kind `print_each` targets are eventless. Scalar rendering and structural null
results follow `linkedspec-diagnostic-output-v1`.

If the sink throws, the same exception object escapes the parser immediately and is not rewritten into
`runtime_ctx->{last_error}`. `exit_now(status)` similarly raises `LinkedSpec::RuntimeExitNow` after any preceding
event and prevents later actions. Generated live handlers call `RuntimeDiagnosticOutput::emit`/`terminate`, not
host `print`, `say`, or `exit`. Independently emitted `Execute($input_ref, $invocation_options)`,
`ExecuteWithTrace($input_ref, $trace_config, $invocation_options)`, and `Get(...)` now expose the same sink and
preserve these outcomes while ordinary failures retain generated-source attribution.

`LinkedSpec::call_spec_handler_subst(...)` confirms the exact current lowering seam: all valid output helpers first
snapshot evaluated values into an array, then call `LinkedSpec::RuntimeDiagnosticOutput::emit($descr, $rule,
$helper, $values)`. `print_each` passes one snapshotted array plus prefix/suffix to that owner; no host `foreach`
controls argument evaluation or delivery.

Related facts: [[diagnostic-output-neutral-contract]], [[cross-backend-diagnostic-output-drift]],
[[lua-diagnostic-output-events]], [[perl-generated-handler-runtime-errors]].
