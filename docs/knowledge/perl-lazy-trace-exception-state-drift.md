---
id: perl-lazy-trace-exception-state-drift
title: "Direct lazy Perl trace detail callbacks overwrite the caller's exception state"
answers:
  - "why does a Perl trace detail callback clear dollar at"
  - "does a throwing lazy trace callback replace an existing Perl exception"
  - "which task preserves Perl exception state across lazy trace details"
  - "does OwnerDispatch protect the lazy Trace callback exception boundary"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","trace","exceptions"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.24. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/Trace.pm"
  - "sed -n '398,439p' perl/LinkedSpec/Trace.pm"
---

# Direct lazy Perl trace detail callbacks overwrite the caller's exception state

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.24](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

For a direct call to the Trace owner, an incoming $@ survives quiet trace and plain detail. A successful lazy detail callback changes it to empty; a throwing callback replaces it with its own detail error. Trace's callback eval at 423 is not localized.

The repair must preserve the incoming exception, including object identity, while retaining lazy/quiet behavior, callback failure handling, nested trace, and parser context. This is separate from JSON::PP displaying a retained blessed diagnostic as null; that display behavior does not establish exception loss.

Sources: `perl/LinkedSpec/Trace.pm`.

## September 6 direct and dispatched controls

`SESSION-STARTUP-READING.3.2.48` reads all 521 lines / 16,259 bytes of Trace and
verifies baseline SHA-256 `f8041e80c7f8342a0497710b130a14085c3dddd0d1ee67eeb04f51dd196ffe22`.
Twenty in-memory controls cross direct/OwnerDispatch routes, incoming string/object exceptions, and
quiet/plain/successful/throwing/nested details. Direct quiet/plain preserve the incoming value or exact
object identity; success/nested clear it, and a throwing callback installs its own error. All ten wrapped
controls preserve the original exception through `call_preserving_err`. No public facade function named
`trace_generated_handler_branch` is claimed: the wrapper control explicitly uses OwnerDispatch.

Every branch returns true; quiet evaluates zero callbacks and emits no output, plain evaluates zero,
and each active lazy case evaluates once. Throwing detail appears as `details_error`; nested detail
emits the nested branch. These controls capture raw exception state before JSON serialization.
`HandlerVariantEmitter.pm` 590–618 emits the direct qualified owner call. The existing helper test
wraps the call in an outer eval and checks non-escape, not preservation of an incoming exception.
The repair must retain that behavior and add the missing state assertions; wrappers already protect
their own successful return boundary. No parser-context failure or generated execution defect beyond
this measured helper state has been inferred.

Exact managed control (no disk fixture or trace sink):

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl - <<'STARTUP52_TRACE_CONTROL'
use strict;
use warnings;
use LinkedSpec::Trace ();
use LinkedSpec::OwnerDispatch ();
use JSON::PP ();
use Scalar::Util qw(refaddr);
my @rows;
for my $route (qw(direct dispatch)) {
 for my $incoming_kind (qw(string object)) {
  for my $kind (qw(quiet plain success throws nested)) {
   LinkedSpec::Trace::configure_trace(trace_level => ($kind eq 'quiet' ? 'none' : 'debug'), trace_log_file => '', trace_log_mode => 'stdout', trace_topic_spacing => 0);
   my ($calls, $captured) = (0, '');
   my $incoming = $incoming_kind eq 'object' ? bless({code => 'incoming'}, 'Startup52::Error') : "incoming exception\n";
   my $details = $kind eq 'plain' ? 'plain details' : sub {
    ++$calls;
    die "lazy detail failure\n" if $kind eq 'throws';
    LinkedSpec::Trace::trace_generated_handler_branch(rule_label => 'Nested', branch => 'plain', taken => 1, details => 'nested details') if $kind eq 'nested';
    return 'lazy details';
   };
   my ($after, $result);
   {
    open my $sink, '>', \$captured or die 'scalar sink';
    local *STDOUT = $sink;
    $@ = $incoming;
    my %args = (rule_label => 'Top', handler_kind => 'control', branch => $kind, taken => 1, details => $details);
    $result = $route eq 'direct'
     ? LinkedSpec::Trace::trace_generated_handler_branch(%args)
     : LinkedSpec::OwnerDispatch::dispatch_owner_call('Startup52', 'LinkedSpec::Trace', 'trace_generated_handler_branch', %args);
    $after = $@;
   }
   my $same = $incoming_kind eq 'object' ? (ref($after) && refaddr($after) == refaddr($incoming) ? 1 : 0) : (!ref($after) && $after eq $incoming ? 1 : 0);
   my $expected_preserved = $route eq 'dispatch' || $kind eq 'quiet' || $kind eq 'plain' ? 1 : 0;
   die "preservation mismatch $route/$incoming_kind/$kind" unless $same == $expected_preserved;
   die 'callback count' unless $calls == ($kind eq 'quiet' || $kind eq 'plain' ? 0 : 1);
   die 'branch result' unless $result == 1;
   die 'quiet output' if $kind eq 'quiet' && length($captured);
   die 'error detail missing' if $kind eq 'throws' && $captured !~ /details_error=lazy detail failure/;
   die 'nested output missing' if $kind eq 'nested' && $captured !~ /generated_handler_branch:Nested:plain/;
   push @rows, {route=>$route,incoming=>$incoming_kind,kind=>$kind,calls=>$calls,preserved=>$same,after_kind=>ref($after)||'string',after_text=>ref($after)?'<object>':$after,result=>$result,trace_present=>length($captured)?1:0};
  }
 }
}
print JSON::PP->new->canonical(1)->encode(\@rows),"\n";
STARTUP52_TRACE_CONTROL
```
