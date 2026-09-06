---
id: perl-progressive-resource-ceiling-enforcement-gap
title: "Perl progressive dispatch calculates ceilings without enforcing all child boundaries"
answers:
  - "does Perl progressive dispatch enforce effective max_steps on dispatch cost"
  - "does Perl progressive dispatch bound detached results by max_result_nodes"
  - "can progressive child errors exceed diagnostic size and source-detail ceilings"
  - "which task owns progressive resource and diagnostic ceiling enforcement"
date: 2026-09-06
status: confirmed-open
tags: [perl, progressive, dispatch, resource, diagnostic, source-detail, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.2.39: six private-authority controls, exact callback effective metadata, ProgressiveSpanDispatch.pm 477–540 / 558–631 / 648–669 / 735–782. Existing authority/carrier suites pass 138 tests."
reverify: "Run the repository-managed six-case authority probe below; compare measured enforcement with ADR 0080 and the neutral ceiling contract."
---

# Calculated ceilings and observed enforcement

ADR 0080 requires stricter effective ceilings. The neutral progressive contract's `policy.ceilings`
also states that a child cannot request or observe detail above its effective ceiling. The audit Knowledge
record describes source-safe diagnostics and non-extensible child budgets.

The September 6 source checkpoint finds a narrower Perl enforcement boundary. `_effective_authority`
calculates every minimum and supplies them in callback metadata, but dispatch safe points compare cost only
with the invocation's remaining steps. `_detach_result` receives no result-node counter or effective ceiling.
The failure path copies raw non-typed callback error text into `child_diagnostic` without consulting the
effective diagnostic byte or source-detail fields.

Six controls use the existing private authority API, caller-owned text `owned-probe-text`, ten remaining
steps, and entry/caller ceilings of one step, one result node, eight diagnostic bytes, and source detail none.
Every entered callback receives exactly those computed effective values.

| Case | Observed result |
| --- | --- |
| Scalar zero, cost one | Accepted, remaining nine |
| Array [1,2,3], cost one | Accepted despite one-node ceiling, remaining nine |
| Scalar zero, cost two | Accepted despite one-step ceiling, remaining eight |
| Scalar zero, cost eleven | Rejected by existing shared remaining-budget check, remaining ten |
| Callback reads and returns its source view | Returns owned-probe-text at source detail none |
| Callback throws source text plus 40 x characters | Typed child failure retains 57-byte diagnostic, including source text |

The final two cases distinguish raw callback input visibility from outward error containment. A parser needs
authorized input to parse; authority review must resolve that relationship to the neutral detail wording.
The demonstrated raw diagnostic and numeric-limit results must not be hidden by assuming that calculated
metadata establishes enforcement. No host-preemption guarantee, other-runtime result, runtime repair, or
new public API is inferred.

The managed authority/carrier suites pass 138 top-level tests. The neutral checker passes 9/9/116 and
public 6/12/10/60. Its authority fixtures and the Perl authority consumer compare computed minima separately
from execution/budget fixtures; those passing rows do not exercise these combined limit cases.

[[SESSION-STARTUP-READING]] `.37.1` owns numeric/resource authority review, six-runtime census, and bounded
repair decomposition; `.37.2` owns diagnostic/source-detail containment and independently justified
expectations; `.37.3` owns decision/book/Knowledge and recurring closeout. Required reading and policy
review precede runtime changes.

## Reverify

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec::ProgressiveSpanDispatch -MJSON::PP - <<'PERL'
use strict;use warnings;
my $json=JSON::PP->new->canonical->allow_nonref;my $secret='owned-probe-text';
my $ceilings={source_detail=>'none',policy_modes=>['fail-only'],max_steps=>1,max_result_nodes=>1,max_diagnostic_bytes=>8};
my @cases=(
 ['bounded_scalar',sub {return 0},1],
 ['result_nodes',sub {return [1,2,3]},1],
 ['steps_above_ceiling',sub {return 0},2],
 ['steps_above_remaining',sub {return 0},11],
 ['source_view_above_detail',sub {return $_[0]{source_view}->text},1],
 ['diagnostic_above_limits',sub {die $_[0]{source_view}->text.":".('x'x40)."\n"},1]
);
for my $case (@cases){
 my $seen;
 my $registry=LinkedSpec::ProgressiveSpanDispatch->new(entries=>[{parser_id=>'probe-v1',compiled_authority=>sub{$seen=$_[0]{effective};return $case->[1]->(@_)},fingerprint=>'sha256:'.('0'x64),allowed_top_rules=>['Top'],capabilities=>['test'],ceilings=>$ceilings}]);
 my $inv=$registry->start_invocation(sources=>{source=>$secret},source_id=>'source',cancellation_token=>'token',cancelled=>sub{0},clock=>sub{0},deadline_tick=>10,remaining_steps=>10,max_depth=>3,max_calls=>3,total_calls=>0,active_chain=>[]);
 my $result;my $ok=eval{$result=$inv->dispatch(parser_id=>'probe-v1',top_rule=>'Top',span=>{source_id=>'source',start=>0,end=>length($secret),provenance=>'test'},caller_capabilities=>['test'],required_capabilities=>[],caller_ceilings=>$ceilings,required_source_detail=>'none',child_token=>'token',cost=>$case->[2]);1};my $error=$@;
 my %out=(case=>$case->[0],accepted=>$ok?JSON::PP::true:JSON::PP::false,remaining=>$inv->remaining_steps);
 $out{effective}=$seen if defined $seen;
 if($ok){$out{result}=$result}else{die $error unless LinkedSpec::ProgressiveSpanDispatch::is_error($error);$out{code}=$error->{code};$out{diagnostic}=$error->{child_diagnostic};$out{diagnostic_bytes}=length($error->{child_diagnostic}//'')}
 print $json->encode(\%out),"\n";
}
PERL
```
