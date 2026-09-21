---
id: perl-wrong-kind-collection-host-slot-drift
title: "Wrong-kind Perl collection helpers can read unrelated host slots"
answers:
  - "why does a wrong-kind Perl count depend on a host array"
  - "why do count_keys sorted_keys and has_key depend on unrelated host hashes"
  - "which task owns collection helper host-slot isolation"
  - "can an absent bare array receiver read an unrelated host array"
  - "why does missing sorted is empty depend on generated package state"
date: 2026-09-21
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","collections","lowering"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.17. No implementation repair or whole-project signoff is claimed."
evidence_update_2026_09_21: "Conformance .1.80 at a19e2588eeff6e4f06de889b4abdd165be5c06cf extends startup .17.1 to absent bare receivers. Exact Phase0 public capture reads undeclared @missing; independently loaded public source returns 1/0 under empty/populated isolated host arrays while an explicit empty binding returns 1/1. Four fresh controls pass; no repair or general live-route isolation proof is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/ActionIR/MethodLowering.pm"
  - "sed -n '5739,5860p' perl/LinkedSpec/ActionIR/MethodLowering.pm"
  - "sed -n '6110,6400p' perl/LinkedSpec/ActionIR/MethodLowering.pm"
---

# Wrong-kind Perl collection helpers can read unrelated host slots

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.17](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

Six public Get parsers were compiled once each and run against two isolated host-slot states. Wrong-kind count/first/last changed from 0/null/null to 2/first/last; count_keys/sorted_keys/has_key changed from 0/[]/0 to 1/[k]/1. Runtime contexts remained error-free and every localized seed was restored.

The lowerer falls back to helper-looking bare host-slot names before enforcing the evaluated DSL value kind. The repair separates array and hash consumers, preserves valid bindings, and requires once-only operand evaluation and carrier checks.

Sources: `perl/LinkedSpec/ActionIR/MethodLowering.pm`.

The following managed control was executed during intake; its output establishes the bounded observation above.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP -MData::Dumper - <<'PERL'
use strict; use warnings;
local @main::__ls_startup_probe_array;
local %main::__ls_startup_probe_hash;
my $json=JSON::PP->new->canonical->allow_nonref;
my @expressions=(q{count("main::__ls_startup_probe_array")},q{first("main::__ls_startup_probe_array")},q{last("main::__ls_startup_probe_array")},q{count_keys("main::__ls_startup_probe_hash")},q{sorted_keys("main::__ls_startup_probe_hash")},q{has_key("main::__ls_startup_probe_hash","k")});
for my $expr (@expressions) {
 my $spec="Top:\n /x/ -> Top { return($expr) }\n";
 my %ctx; my $parser=LinkedSpec::Get(\$spec,runtime_ctx_ref=>\%ctx);
 die Dumper(\%ctx) unless ref($parser) eq 'CODE';
 my @values;
 for my $seed (0,1) {
  @main::__ls_startup_probe_array=$seed ? ('seed-first','seed-last') : ();
  %main::__ls_startup_probe_hash=$seed ? (k=>'seed-value') : ();
  my $input='x'; my $value=eval { $parser->(\$input) };
  die $@ if length $@; die Dumper($ctx{last_error}) if defined $ctx{last_error};
  push @values,$value;
 }
 print $json->encode({expression=>$expr,empty_seed=>$values[0],populated_seed=>$values[1],context_error=>undef}),"\n";
}
PERL
```

## Absent receiver extension — September 21

Conformance group 80 reads `spec_format_terse_2_3_5_1_array_receiver_value_chains`.
Its twelve authored assertions pass in a fresh isolated replay. Public source
capture of the exact fixture is 18,837 bytes (a dated size, not a contract).
`missing.sorted().is_empty()` lowers to a sort over undeclared `@missing`;
there is no `my $missing` or `my @missing`. Thus its no-preamble observation is
true, but says nothing about isolation from ambient host storage.

The documented `emit_generated_source` plus independent package loading route
makes that dependency observable without changing compiler or test source.
The same generated parser returns 1 with an empty host array and 0 with an
unrelated host element. An explicit `set(missing, [])` control returns 1 for
both host states. Fresh live parsers also return 1 in the ordinary empty state;
this experiment does not establish their seeded-host behavior.

`SESSION-STARTUP-READING.17.1` now explicitly owns the absent-receiver case,
independent generated-source controls and preservation of legitimate implicit
rule accumulators. Required reading still precedes repair. The code below is a
diagnostic reproduction of the defect, not an expected post-repair regression.

```bash
bash tools/project_data_run.sh perl -Iperl - <<'ABSENT_RECEIVER_HOST_SLOT'
use strict; use warnings; use LinkedSpec; use JSON::PP; use Test::More;
my $j=JSON::PP->new->canonical->allow_nonref;
for my $case (['absent','','Probe::Conformance80Absent'], ['bound','set(missing, []); ','Probe::Conformance80Bound']) {
 my ($name,$prefix,$package)=@$case;
 my $spec="Top::\n /x/ -> Done { ${prefix}return(missing.sorted().is_empty()) }\n\nDone::\n /[a-z]+/\n";
 my $live=LinkedSpec::Get(\$spec); my $input='xhello';is($live->(\$input),1,"$name live empty-state control");
 my $src=LinkedSpec::emit_generated_source(\$spec,source_identity=>"conformance80-$name.spec");
 eval "package $package; $src; 1" or die $@;
 my @results;
 for my $seed (0,1) {
  no strict 'refs'; local @{$package.'::missing'}=$seed ? ('ambient-host-value') : ();
  my $in='xhello'; push @results, &{$package.'::Execute'}(\$in);
 }
 print $j->encode({case=>$name,empty_host=>$results[0],seeded_host=>$results[1]}),"\n";
 is_deeply(\@results,$name eq 'absent'?[1,0]:[1,1],"$name source-qualified host-slot sensitivity");
}
done_testing();
ABSENT_RECEIVER_HOST_SLOT
```
