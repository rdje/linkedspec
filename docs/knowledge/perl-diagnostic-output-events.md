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
date: 2026-07-16
status: current
tags: [Perl, runtime, ActionIR, diagnostic-output, events, sink, Unicode, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.1.2 adds LinkedSpec::RuntimeDiagnosticOutput, rewires ActionIR output and exit lowering, and installs an invocation-local sink in Compiler-generated live parsers. t/diagnostic_output_perl_contract.t consumes linkedspec-diagnostic-output-v1 and proves 11 render rows, ordered once-only events, quiet execution, wrong-kind behavior, sink-failure identity, typed exit, arity-before-effects, generated-source freedom from host output/exit, and quiet primary behavior. Phase 0 passes 1..1031."
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
host `print`, `say`, or `exit`. Independently emitted execution-entrypoint option propagation remains the separate
`.5.1.7` rollout leg.

Related facts: [[diagnostic-output-neutral-contract]], [[cross-backend-diagnostic-output-drift]],
[[lua-diagnostic-output-events]], [[perl-generated-handler-runtime-errors]].
