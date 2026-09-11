---
id: perl-semantic-compile-failure-diagnostic-drift
title: "Perl retains the compile diagnostic but can fabricate a blank dependency explanation"
answers:
  - "why does recognition_token_escape appear as dependency_target_missing in Perl semantics"
  - "why is a failed Perl semantic dependency diagnostic target blank"
  - "which task preserves actual compilation failures in semantic projection"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","semantic","diagnostics"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.23. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/SemanticStaticProjection.pm"
  - "sed -n '314,345p' perl/LinkedSpec/SemanticStaticProjection.pm"
  - "sed -n '392,432p' perl/LinkedSpec/SemanticStaticProjection.pm"
---

# Perl retains the compile diagnostic but can fabricate a blank dependency explanation

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.23](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

Two exact public Get/query controls at `SESSION-STARTUP-READING.3.2.44` refine the initial intake.
For the recognition-token escape, Get reports `recognition_token_escape`; the semantic diagnostic keeps
that same code and the same message. Its separate decision falsely says `dependency_resolution`, and
its `explanation_step` claims `dependency_target_missing` with a blank target. Construction emits an
uninitialized-target warning at SemanticStaticProjection line 418. The earlier title and intake wording
could imply that the diagnostic itself was replaced; this narrower measured description supersedes that
interpretation without erasing the original failure evidence.

The bare `Top:\n Missing\n` control correctly maps `bare_edge_target_undefined` to
`unknown_rule_reference`, with rule:Missing, the exact Missing source bytes 6–13, a truthful dependency
explanation, and no warning. The two Get failures also emit their existing forced compile log output,
captured in memory by the control below; this observation does not classify a new trace defect.

Two initial minimal controls selected different failures: a checkpoint plus immediate return without
an attempt reaches `recognition_attempt_count`, and an explicit arrow to Missing reaches final descriptor
failure rather than the bare-edge normalization. Both preserve their diagnostic code/fallback while
acquiring the same false dependency classification and undefined-target warning. The final fixtures below
reach exactly the escape and valid missing-rule normalization requested by the original audit.

`_build_failed` retains the supplied code/summary except the intentional bare-edge portable mapping
(lines 381–391), then unconditionally constructs dependency decision/explanation rows (402–421).
The repair must preserve honest causal evidence for every supported failure class or an explicitly
unclassified fallback, retain the valid missing-rule path, and cover source/privacy/generated/MCP routes.
Existing .23 owns this work; passing the five-test static fixture suite does not close it.
No runtime, public-book, or protocol implementation changes occur in this checkpoint.

## Exact public reverify

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP -MCwd=getcwd - <<'STARTUP48_EXACT_FAILURES'
use strict;use warnings;
LinkedSpec::configure_trace(level=>'none');my $json=JSON::PP->new->canonical;my $root=getcwd();
my $escape="Top::\n I {\n tx = recognition_checkpoint()\n matched = recognize_once(tx, call(Child))\n recognition_rollback(tx)\n return(tx)\n }\n /never/\nChild::\n /c/\n";
for my $case (['token_escape',$escape,'recognition_token_escape'],['missing_rule',"Top:\n Missing\n",'unknown_rule_reference']) {
 my($name,$source,$expected)=@$case;my(%ctx,@warnings,$parser,$index);my $forced='';
 {local $SIG{__WARN__}=sub{my $w=$_[0];$w=~s{\Q$root/\E}{}g;push @warnings,$w};local *STDOUT;open STDOUT,'>',\$forced or die $!;
  $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);
  $index=LinkedSpec::semantic_index(\$source,logical_name=>'failure-control.spec',source_detail_ceiling=>'text');
 }
 die "$name compiled unexpectedly" if defined($parser) || !$ctx{last_error};
 my $r=$index->query({contract=>'linkedspec-semantic-query-v1',operation=>'list',subjects=>[],record_kinds=>[],relation_kinds=>[],direction=>'outgoing',page=>{after_id=>undef,limit=>100},budget=>{max_records=>1000,max_relations=>2000,max_depth=>4},source=>{detail=>'text',include_content_digest=>JSON::PP::false}});
 die "$name failed query" unless $r->{ok};my $e=$ctx{last_error};
 my @rows=grep {$_->{kind}=~/\A(?:diagnostic|decision|explanation_step)\z/} @{$r->{records}};
 my($d)=grep{$_->{kind} eq 'diagnostic'}@rows;die "$name diagnostic" unless $d->{facts}{code} eq $expected;
 print $json->encode({case=>$name,get_error=>{map {$_=>ref($e->{$_})?ref($e->{$_}):$e->{$_}} qw(type stage summary detail code target rule_label)},forced_stdout_bytes=>length($forced),warnings=>\@warnings,records=>\@rows}),"\n";
}
STARTUP48_EXACT_FAILURES
```

## September 11 Julia failure-class controls

Julia .1.28 adds the exact bare Missing and existing Child[9] controls in
[[julia-semantic-static-correlation-gaps]]. Missing preserves native
bare_edge_target_undefined and the intended unknown_rule_reference record, exact
source and truthful dependency explanation. Child[9] instead preserves
regex_slot_index_out_of_range/resolve_selector in native/projected diagnostics,
with exact authored source and no decision/explanation rows. Its selector guard
precedes the broader normalization branch. These are positive Julia controls
under startup .23, not a Perl repair or complete failure-class census.
