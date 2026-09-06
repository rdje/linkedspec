---
id: bootstrap-comparison-stale-result
title: Empty bootstrap comparison leaves a previous invocation's diagnostic result cached
answers:
  - why can spec_spec_result describe an earlier source
  - does bootstrap clear its diagnostic comparison result between invocations
  - where is stale bootstrap comparison state tracked for repair
date: 2026-09-06
status: confirmed defect; repair pending SESSION-STARTUP-READING.8
tags: [perl, bootstrap, diagnostics, cache, continuity]
evidence: "SESSION-STARTUP-READING.3.2.3 at source baseline baeb984e36a94a15951cd23d4c52def5064cdaca: Get(return_descriptor) on Top:: plus /x/ creates one comparison row; the cached spec.spec parser returns an empty array for 'not a rule'; run_bootstrap_parse on that text retains the old array identity; a later Other:: plus /y/ comparison replaces it. Public Get rejects malformed input at validate_spec_content."
reverify: "bash tools/project_data_run.sh perl -Iperl -MLinkedSpec -MLinkedSpec::BootstrapSpec -MScalar::Util=refaddr -e 'my $s=qq{Top::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$s,return_descriptor=>1); my $b=LinkedSpec::BootstrapSpec::cached_bootstrap_state(); my $old=$b->{spec_spec_result}; my $bad=q{not a rule}; my $p=LinkedSpec::BootstrapSpec::_build_spec_spec_parser(); my $r=$p->(\\$bad); die q{negative control changed} unless ref($r) eq q{ARRAY} && !@$r; LinkedSpec::BootstrapSpec::run_bootstrap_parse(\\$bad,$b); print refaddr($old)==refaddr($b->{spec_spec_result}) ? qq{stale-result reproduced\\n} : qq{old result cleared\\n};'"
---

`perl/LinkedSpec/BootstrapSpec.pm` caches one bootstrap state at lines 81–90. At lines 108–114,
`run_bootstrap_parse` writes `spec_spec_result` only for a nonempty array returned without an exception.
There is no per-invocation clear. Resetting the source cursor at lines 110/116 does not reset that diagnostic slot.

The controlled sequence starts with `Top::` and `/x/`: public `LinkedSpec::Get(..., return_descriptor => 1)`
succeeds and the comparison has one row. For `not a rule`, direct comparison returns an empty array. Calling
`run_bootstrap_parse` with the same shared state leaves the earlier nonempty array at the same `refaddr`.
A subsequent valid `Other::` and `/y/` comparison replaces the identity, providing a positive control.

Public `Get` on the malformed text still returns no descriptor and reports `validate_spec_content` with
`Spec file must start with a rule definition`. This finding proves stale internal diagnostic state, not a
malformed-input acceptance bug or changed primary parser output. A literal consumer census in Perl, tests,
and book finds the sole `spec_spec_result` occurrence at the assignment; public metadata exposure is not proved.

`SESSION-STARTUP-READING.8` owns repair and regressions after mandatory reading, following cleanup repair `.7`.
Cover empty/undefined/throwing/unavailable comparison paths, shared and injected state, successful capture,
and recursion protection while preserving primary bootstrap behavior. The probes changed no tracked source files.

Related: [[bootstrapspec-vs-spec-spec-dual-path]], [[spec-spec-self-hosted-grammar]].
