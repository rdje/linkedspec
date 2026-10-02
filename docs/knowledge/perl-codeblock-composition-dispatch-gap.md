---
id: perl-codeblock-composition-dispatch-gap
title: Perl deferred bodies reject existing push and registered function composition
answers:
  - "does language_agnostic_action_ir_ready prove callable body execution coverage"
  - "why does push work directly but fail inside a Perl codeblock"
  - "can a Perl deferred codeblock invoke a registered pure function"
  - "which task owns Perl callback push and registered function dispatch repair"
  - "why is the composed normalization objective still blocked on Perl"
date: 2026-10-02
status: original dispatch gaps repaired; separate literal and normalization prerequisites remain
tags: [perl, callable, codeblock, composition, dispatch, partial, language-readiness]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1 public Get/descriptor controls from clean2a8c368159a6c9b927bc6cd7fc524fe0de7319a6: five direct/callback successes and two callback failures. Every descriptor is ready1/raw0/fallback0/unresolved0. CodeblockRuntime::_eval_call dispatches a narrow helper list then bound-codeblock lookup, without the selected push or registered-function routes. Repair owner SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0 precedes Perl execution .1.3.3.1."
reverify: "Run the inline public Get probe below through bash tools/project_data_run.sh; inspect perl/LinkedSpec/CodeblockRuntime.pm _eval_call and the owning task before advancing dependent claims."
---

The selected source/oracle requirements are
`docs/language-readiness/composed-objective-selection.md`. The actual Word-pair
pipeline reaches a bound deferred callback inside `map_leaves!`, then fails at
`push(seen,text)`. Its public error is retained in
`runtime_ctx_ref->{last_error}{detail}` as `LinkedSpec::CodeblockRuntime::Error`
with code `unknown_helper` and name `push`. No rich diagnostic event or result
is produced. This is execution failure, not raw host fallback or malformed syntax.

Minimal controls separate helper availability from callback execution:

| Control | October 2 public outcome |
| --- | --- |
| Direct `push(seen,"x")` | `["x"]`, no error. |
| Same push inside a deferred body | Null result; typed `unknown_helper` / `push`. |
| Direct registered `decorate("x","!")` using cat | `"!x"`, no error. |
| Same registered call inside a deferred body | Null result; typed `unknown_helper` / `decorate`. |
| Deferred cat plus nonparameter assignment | `["!x","before:x"]`, no error. |
| Direct uppercase | `"AB"`, no error. |
| Registered function using uppercase | `"!AB"`, no error. |

All seven sources report `language_agnostic_action_ir_ready=1` and zero canonical
fallback, raw Perl dependencies and unresolved helpers. Those fields describe
recognized/lowered source; they do not enumerate interpreted body execution routes.
The full corrected pipeline likewise reports28 canonical events/ready1 and zero
fallback/raw/unresolved counts, while callback execution fails.

`perl/LinkedSpec/CodeblockRuntime.pm::_eval_call` (lines116–191 at this review)
evaluates arguments, handles a small literal helper set and otherwise resolves a
caller binding as a callable codeblock. There is no push or registered-user-function
dispatch in that path. Existing [[perl-callable-codeblock-dynamic-invocation]]
retains dynamic slot/parameter behavior and typed unsupported-body errors;
[[perl-dynamic-codeblock-receiver-guard-gap]] retains the separate active-receiver
assignment defect. Startup87.2/.3 already own regex/numeric cases in this dispatcher.
These new cases do not close or replace those existing owners/prerequisites.

`SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0` owns the P1 repair before `.1.3.3.1`
executes the unchanged neutral objective. Preserve actual mutation target identity,
once-only arguments, copied/restored parameters, live caller nonparameters, static
precedence, pure-function fresh locals, recursion diagnostics and receiver guards.
Require native and independently emitted controls, including genuinely unknown calls.
This is a narrower implementation gap in composition of existing operations; it
selects no new parsing primitive, host escape, lexical closure or syntax extension.

```sh
bash tools/project_data_run.sh perl -Iperl -MLinkedSpec -MJSON::PP - <<'PL'
use strict; use warnings;
for my $body (
  'seen=[]; push(seen,"x"); return(seen)',
  'seen=[]; cb={|| push(seen,"x"); return(seen) }; return(cb())'
) {
  my $source = "Top:: I { $body }";
  my %ctx;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref=>\%ctx);
  die 'build failed' unless $parser;
  my $input = 'x';
  my $value = $parser->(\$input);
  my $error = $ctx{last_error};
  my $detail = ref($error) eq 'HASH' ? $error->{detail} : undef;
  print JSON::PP->new->canonical->encode({
    value=>$value, code=>$detail ? $detail->{code} : undef,
    name=>$detail ? $detail->{name} : undef
  }), "\n";
}
PL
```

Do not erase the retained typed object using JSON blessed-object conversion.
[[perl-typed-error-json-observation-boundary]] explains that observation hazard.
These controls are Perl-only fresh measurements; no other backend outcome,
whole-format readiness or general callable-body coverage is inferred.

October2 `.1.3.3.0.1` repairs the selected push route; [[perl-codeblock-push-composition]]
records seventeen native/fresh emitted sources and actual identity controls. The original
seven-control replay now has six successes and only callback_function still fails.
The unchanged normalization reaches unknown_helper/decorate rather than push, retaining
ready1/raw0/fallback0/unresolved0 and no result/events. Registered-function child
`.1.3.3.0.2` is next, followed by independent dispatcher closeout and neutral execution.
The original dated diagnostic and its immutable selection checkpoint stay exact;
startup19/32/35/87.2/.3 and other repair prerequisites remain open.

October2 `.1.3.3.0.2.1.1` implements the registered bridge through central compiled function bodies.
[[perl-deferred-function-bridge]] binds71 native/fresh emitted sources/605 tests and actual identities,
effects/error restoration. All seven original controls now succeed. The exact frozen normalization
source reaches an undefined count function: generated condition truthy(i < count(pieces)) and both
infix increments remain unlowered despite ready1/raw0/fallback0/unresolved0. P1 `.0.4` owns the precise
compiler-versus-admitted-source diagnosis and repair before dispatcher closeout. The x,y callback
literal reconstruction prerequisite `.0.2.1.3` also remains; full pipeline/neutral execution is not claimed.
Original dated failure evidence and frozen authorities remain exact.
