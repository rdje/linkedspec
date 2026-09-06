---
id: perl-staged-marker-retired-identity-risk
title: Recursive staged-marker processing assumes a retired host address is never reused
answers:
  - "can staged recursion confuse a new marker with a retired marker identity"
  - "what proves the Perl staged marker address-reuse risk"
  - "which task makes recursive staged marker identity lifetime safe"
date: 2026-09-06
status: latent risk demonstrated by isolated identity substitution; native address reuse not reproduced
tags: [perl, staged-parsing, recursion, marker-identity, lifecycle, startup-reading]
evidence: "SESSION-STARTUP-READING.3.2.46 at unchanged baseline baeb984e; 16 ordinary, four weak-reference, and four pooled native trials all finish 24 calls. Two isolated recycling trials stop at three calls with an inert marker; two held-marker controls finish 24. Repair owner SESSION-STARTUP-READING.44."
reverify: "Run the four repository-managed controls below; distinguish actual refaddr observations from the isolated substitution."
---

The public Get parent emits one legal assignment-form parse_job marker. Its caller-frozen child callback
returns a newly constructed marker with a strictly smaller direct payload until the final scalar done.
Every chain has budget/depth/call headroom for exactly 24 callbacks and preserves the same parser/top.

| Control | Trials | Calls per trial | Final value | Native address reuse |
| --- | ---: | ---: | --- | --- |
| Ordinary allocation, markers not retained | 8 | 24 | done | none observed |
| Ordinary allocation, markers retained | 8 | 24 | done | none observed |
| Weak-reference instrumentation, not retained / retained | 2 + 2 | 24 | done | none observed |
| Up to 128 candidate allocations per returned marker, not retained / retained | 2 + 2 | 24 | done | none observed |
| Isolated identity substitution, not retained | 2 | 3 | unprocessed Marker | not a native-reuse claim |
| Same substitution, markers retained | 2 | 24 | done | not a native-reuse claim |

All contexts remain error-free, including the incomplete modeled result. In the unretained native runs,
weak references show only the current child alive at each subsequent callback and zero remaining after
completion. Retained controls reach 23 live returned markers. The marker-retention leak hypothesis is
therefore not supported by these observations.

The isolated substitute changes only StagedASTEnrichment's imported refaddr for marker objects during
the parser call. Every live marker keeps a distinct stable numeric identity. A slot is reused only
after its weak reference clears; non-marker objects still use the real refaddr. The first such recycle
causes discovery to treat a new marker as already processed. This is a controlled identity-lifetime
counterexample, not an observed native allocator event or a changed installed implementation.

The source explains the model: enrich_recursively retains processed_marker and lineage_by_marker keyed
by refaddr (156–187); _collect_new_marker_lineage skips a returned address already in that set (793–806).
Obsolete marker objects can be released while these scalar keys remain. The marker side table and
destructor use actual object identity; neither gives the scheduler a separate generation identity.
No marker leak or actual native recycling was demonstrated. The warning about a symbol used only once
in the substitution harness is Perl's compile-time notice for intentional local symbol replacement,
not a runtime-parser diagnostic.

Startup .44 owns a bounded stable-identity repair and independent lifetime/recycling regression,
including intentional same-marker behavior, typed paths, source lineage, resource limits, and all
supported carriers. Other backends have not been inspected for this risk. Passing 143 existing Perl
checks and current 9/9 staged admission do not close this separately identified assumption.
See [[perl-staged-ast-enrichment-recursive-authority]] and
[[perl-staged-ast-enrichment-carriers-admission]].

## Exact controls

These programs only read the tracked contract and use in-memory fixtures. The local imported-function
substitution ends before the control returns; none edits a runtime, test, book, or contract file.

### Ordinary native allocation

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MLinkedSpec::StagedParseJob -MJSON::PP -MScalar::Util=refaddr - <<'STARTUP50_MARKER_LIFETIME'
use strict;use warnings;LinkedSpec::configure_trace(level=>'none');my $json=JSON::PP->new->canonical;
open my $fh,'<','capability_conformance/staged_ast_enrichment_contract.json' or die $!;my $contract=$json->decode(do{local $/;<$fh>});close $fh;
my $source=<<'SPEC';
Top::
 /([^;]+);/ -> Top { job_marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr", "top", "Expr", "result_policy", "replace_marker", "on_error", "fail")); return(hash("payload", job_marker)) }
SPEC
my %ctx;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);die 'parent compile' unless ref($parser) eq 'CODE' && !$ctx{last_error};
for my $hold(0,1) { for my $trial(1..8) {
 my($calls,$reused)=(0,0);my(@retained,@lengths);my %seen;
 my $marker=sub {my($n)=@_;my $text='a'x$n;my $info={match_span=>{start=>0,end=>$n},match_spans=>[{start=>0,end=>$n}]};
  my $m=LinkedSpec::StagedParseJob::construct_marker(\$text,$info,undef,'reading:marker-lifetime',$json->encode({text_plan=>{kind=>'direct_span',source=>'entry_text'},options=>{node_kind=>'expression',payload_kind=>'embedded_expression',spec=>'expr',top=>'Expr',result_policy=>'replace_marker',on_error=>'fail',required_capabilities=>['staged-parse-job-v2','typed-source-location-v1']}}));
  ++$reused if $seen{refaddr($m)}++;push @retained,$m if $hold;return $m;
 };
 my $snapshot=$json->decode($json->encode($contract->{resolution_snapshot}));
 for my $entry(@{$snapshot->{entries}}) {$entry->{compiled_authority}=sub {my($request)=@_;++$calls;my $n=length($request->{text});push @lengths,$n;return $n>1?$marker->($n-1):'done'};}
 my $config={snapshot=>$snapshot,declaring_spec_id=>'grammar/main.spec',caller_capabilities=>['caller-only','staged-parse-job-v2','structured-result-v1','typed-source-location-v1','xml-v1','yaml-v1'],caller_policy_modes=>['append_child','diagnostic_node','fail','keep_text','replace_field','replace_marker','sibling_field','trace'],caller_ceilings=>{source_detail=>'text',max_steps=>500,max_result_nodes=>256,max_diagnostic_bytes=>8192},required_source_detail=>'span',required_versions=>{spec_language_version=>2,helper_contract_version=>'actionir-v3',staged_contract_version=>2},cancellation_token=>'reading:marker-lifetime',cancelled=>sub{0},clock=>sub{0},deadline=>100,remaining_steps=>100,required_steps=>1,max_depth=>32,max_calls=>32};
 my $input=('a'x24).';';my $result=$parser->(\$input,{staged_ast_enrichment=>$config});
 my $e=$ctx{last_error};my $value=ref($result) eq 'HASH'?$result->{ast}{payload}:undef;
 print $json->encode({hold_markers=>$hold,trial=>$trial,calls=>$calls,expected_calls=>24,reused_addresses=>$reused,lengths=>\@lengths,result_kind=>ref($value)||'scalar',result=>ref($value)?undef:$value,error=>$e?{map{$_=>ref($e->{$_})?ref($e->{$_}):$e->{$_}}qw(type stage summary detail code)}:undef}),"\n";
}}
STARTUP50_MARKER_LIFETIME
```

### Native weak-reference lifetime

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MLinkedSpec::StagedParseJob -MJSON::PP -MScalar::Util=refaddr - <<'STARTUP50_WEAK_LIFETIME'
use strict;use warnings;LinkedSpec::configure_trace(level=>'none');my $json=JSON::PP->new->canonical;
open my $fh,'<','capability_conformance/staged_ast_enrichment_contract.json' or die $!;my $contract=$json->decode(do{local $/;<$fh>});close $fh;
my $source=<<'SPEC';
Top::
 /([^;]+);/ -> Top { job_marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr", "top", "Expr", "result_policy", "replace_marker", "on_error", "fail")); return(hash("payload", job_marker)) }
SPEC
my %ctx;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);die 'parent compile' unless ref($parser) eq 'CODE' && !$ctx{last_error};
for my $hold(0,1) { for my $trial(1..2) {
 my($calls,$reused)=(0,0);my(@retained,@lengths,@weak,@live_during);my %seen;
 my $marker=sub {my($n)=@_;my $text='a'x$n;my $info={match_span=>{start=>0,end=>$n},match_spans=>[{start=>0,end=>$n}]};
  my $m=LinkedSpec::StagedParseJob::construct_marker(\$text,$info,undef,'reading:marker-lifetime',$json->encode({text_plan=>{kind=>'direct_span',source=>'entry_text'},options=>{node_kind=>'expression',payload_kind=>'embedded_expression',spec=>'expr',top=>'Expr',result_policy=>'replace_marker',on_error=>'fail',required_capabilities=>['staged-parse-job-v2','typed-source-location-v1']}}));
  ++$reused if $seen{refaddr($m)}++;push @weak,$m;Scalar::Util::weaken($weak[-1]);push @retained,$m if $hold;return $m;
 };
 my $snapshot=$json->decode($json->encode($contract->{resolution_snapshot}));
 for my $entry(@{$snapshot->{entries}}) {$entry->{compiled_authority}=sub {my($request)=@_;++$calls;push @live_during,scalar(grep {defined} @weak);my $n=length($request->{text});push @lengths,$n;return $n>1?$marker->($n-1):'done'};}
 my $config={snapshot=>$snapshot,declaring_spec_id=>'grammar/main.spec',caller_capabilities=>['caller-only','staged-parse-job-v2','structured-result-v1','typed-source-location-v1','xml-v1','yaml-v1'],caller_policy_modes=>['append_child','diagnostic_node','fail','keep_text','replace_field','replace_marker','sibling_field','trace'],caller_ceilings=>{source_detail=>'text',max_steps=>500,max_result_nodes=>256,max_diagnostic_bytes=>8192},required_source_detail=>'span',required_versions=>{spec_language_version=>2,helper_contract_version=>'actionir-v3',staged_contract_version=>2},cancellation_token=>'reading:marker-lifetime',cancelled=>sub{0},clock=>sub{0},deadline=>100,remaining_steps=>100,required_steps=>1,max_depth=>32,max_calls=>32};
 my $input=('a'x24).';';my $result=$parser->(\$input,{staged_ast_enrichment=>$config});
 my $e=$ctx{last_error};my $value=ref($result) eq 'HASH'?$result->{ast}{payload}:undef;
 print $json->encode({hold_markers=>$hold,trial=>$trial,live_during=>\@live_during,live_after=>scalar(grep {defined} @weak),calls=>$calls,expected_calls=>24,reused_addresses=>$reused,lengths=>\@lengths,result_kind=>ref($value)||'scalar',result=>ref($value)?undef:$value,error=>$e?{map{$_=>ref($e->{$_})?ref($e->{$_}):$e->{$_}}qw(type stage summary detail code)}:undef}),"\n";
}}
STARTUP50_WEAK_LIFETIME
```

### Native bounded allocation pool

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MLinkedSpec::StagedParseJob -MJSON::PP -MScalar::Util=refaddr - <<'STARTUP50_POOL_LIFETIME'
use strict;use warnings;LinkedSpec::configure_trace(level=>'none');my $json=JSON::PP->new->canonical;
open my $fh,'<','capability_conformance/staged_ast_enrichment_contract.json' or die $!;my $contract=$json->decode(do{local $/;<$fh>});close $fh;
my $source=<<'SPEC';
Top::
 /([^;]+);/ -> Top { job_marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr", "top", "Expr", "result_policy", "replace_marker", "on_error", "fail")); return(hash("payload", job_marker)) }
SPEC
my %ctx;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);die 'parent compile' unless ref($parser) eq 'CODE' && !$ctx{last_error};
for my $hold(0,1) { for my $trial(1..2) {
 my($calls,$reused)=(0,0);my(@retained,@lengths,@weak,@live_during);my %seen;
 my $marker=sub {my($n)=@_;my $text='a'x$n;my $info={match_span=>{start=>0,end=>$n},match_spans=>[{start=>0,end=>$n}]};
  my @pool;my $m;for(1..128){my $candidate=LinkedSpec::StagedParseJob::construct_marker(\$text,$info,undef,'reading:marker-lifetime',$json->encode({text_plan=>{kind=>'direct_span',source=>'entry_text'},options=>{node_kind=>'expression',payload_kind=>'embedded_expression',spec=>'expr',top=>'Expr',result_policy=>'replace_marker',on_error=>'fail',required_capabilities=>['staged-parse-job-v2','typed-source-location-v1']}}));push @pool,$candidate;$m=$candidate unless defined $m;if($seen{refaddr($candidate)}){$m=$candidate;last}}
  ++$reused if $seen{refaddr($m)}++;push @weak,$m;Scalar::Util::weaken($weak[-1]);push @retained,$m if $hold;return $m;
 };
 my $snapshot=$json->decode($json->encode($contract->{resolution_snapshot}));
 for my $entry(@{$snapshot->{entries}}) {$entry->{compiled_authority}=sub {my($request)=@_;++$calls;push @live_during,scalar(grep {defined} @weak);my $n=length($request->{text});push @lengths,$n;return $n>1?$marker->($n-1):'done'};}
 my $config={snapshot=>$snapshot,declaring_spec_id=>'grammar/main.spec',caller_capabilities=>['caller-only','staged-parse-job-v2','structured-result-v1','typed-source-location-v1','xml-v1','yaml-v1'],caller_policy_modes=>['append_child','diagnostic_node','fail','keep_text','replace_field','replace_marker','sibling_field','trace'],caller_ceilings=>{source_detail=>'text',max_steps=>500,max_result_nodes=>256,max_diagnostic_bytes=>8192},required_source_detail=>'span',required_versions=>{spec_language_version=>2,helper_contract_version=>'actionir-v3',staged_contract_version=>2},cancellation_token=>'reading:marker-lifetime',cancelled=>sub{0},clock=>sub{0},deadline=>100,remaining_steps=>100,required_steps=>1,max_depth=>32,max_calls=>32};
 my $input=('a'x24).';';my $result=$parser->(\$input,{staged_ast_enrichment=>$config});
 my $e=$ctx{last_error};my $value=ref($result) eq 'HASH'?$result->{ast}{payload}:undef;
 print $json->encode({hold_markers=>$hold,trial=>$trial,live_during=>\@live_during,live_after=>scalar(grep {defined} @weak),calls=>$calls,expected_calls=>24,reused_addresses=>$reused,lengths=>\@lengths,result_kind=>ref($value)||'scalar',result=>ref($value)?undef:$value,error=>$e?{map{$_=>ref($e->{$_})?ref($e->{$_}):$e->{$_}}qw(type stage summary detail code)}:undef}),"\n";
}}
STARTUP50_POOL_LIFETIME
```

### Isolated identity recycling

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MLinkedSpec::StagedParseJob -MJSON::PP -MScalar::Util=refaddr - <<'STARTUP50_MODELED_RECYCLING'
use strict;use warnings;LinkedSpec::configure_trace(level=>'none');my $json=JSON::PP->new->canonical;
open my $fh,'<','capability_conformance/staged_ast_enrichment_contract.json' or die $!;my $contract=$json->decode(do{local $/;<$fh>});close $fh;
my $source=<<'SPEC';
Top::
 /([^;]+);/ -> Top { job_marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr", "top", "Expr", "result_policy", "replace_marker", "on_error", "fail")); return(hash("payload", job_marker)) }
SPEC
my %ctx;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);die 'parent compile' unless ref($parser) eq 'CODE' && !$ctx{last_error};
for my $hold(0,1) { for my $trial(1..2) {
 my($calls,$reused,$identity_recycles)=(0,0,0);my(@identity_slots,%assigned_slots);my $real_refaddr=\&Scalar::Util::refaddr;my(@retained,@lengths,@weak,@live_during);my %seen;
 my $marker=sub {my($n)=@_;my $text='a'x$n;my $info={match_span=>{start=>0,end=>$n},match_spans=>[{start=>0,end=>$n}]};
  my $m=LinkedSpec::StagedParseJob::construct_marker(\$text,$info,undef,'reading:marker-lifetime',$json->encode({text_plan=>{kind=>'direct_span',source=>'entry_text'},options=>{node_kind=>'expression',payload_kind=>'embedded_expression',spec=>'expr',top=>'Expr',result_policy=>'replace_marker',on_error=>'fail',required_capabilities=>['staged-parse-job-v2','typed-source-location-v1']}}));
  ++$reused if $seen{refaddr($m)}++;push @weak,$m;Scalar::Util::weaken($weak[-1]);push @retained,$m if $hold;return $m;
 };
 my $snapshot=$json->decode($json->encode($contract->{resolution_snapshot}));
 for my $entry(@{$snapshot->{entries}}) {$entry->{compiled_authority}=sub {my($request)=@_;++$calls;push @live_during,scalar(grep {defined} @weak);my $n=length($request->{text});push @lengths,$n;return $n>1?$marker->($n-1):'done'};}
 my $config={snapshot=>$snapshot,declaring_spec_id=>'grammar/main.spec',caller_capabilities=>['caller-only','staged-parse-job-v2','structured-result-v1','typed-source-location-v1','xml-v1','yaml-v1'],caller_policy_modes=>['append_child','diagnostic_node','fail','keep_text','replace_field','replace_marker','sibling_field','trace'],caller_ceilings=>{source_detail=>'text',max_steps=>500,max_result_nodes=>256,max_diagnostic_bytes=>8192},required_source_detail=>'span',required_versions=>{spec_language_version=>2,helper_contract_version=>'actionir-v3',staged_contract_version=>2},cancellation_token=>'reading:marker-lifetime',cancelled=>sub{0},clock=>sub{0},deadline=>100,remaining_steps=>100,required_steps=>1,max_depth=>32,max_calls=>32};
 my $input=('a'x24).';';my $result;{no warnings 'redefine';local *LinkedSpec::StagedASTEnrichment::refaddr=sub {my($object)=@_;return $real_refaddr->($object) unless ref($object) eq 'LinkedSpec::StagedParseJob::Marker';my $actual=$real_refaddr->($object);for my $i(0..$#identity_slots){return 1_000_000+$i if defined($identity_slots[$i]) && $real_refaddr->($identity_slots[$i])==$actual;}my $slot=0;++$slot while $slot<@identity_slots && defined $identity_slots[$slot];++$identity_recycles if $assigned_slots{$slot}++;$identity_slots[$slot]=$object;Scalar::Util::weaken($identity_slots[$slot]);return 1_000_000+$slot;};$result=$parser->(\$input,{staged_ast_enrichment=>$config});}
 my $e=$ctx{last_error};my $value=ref($result) eq 'HASH'?$result->{ast}{payload}:undef;
 print $json->encode({simulated_identity_recycles=>$identity_recycles,hold_markers=>$hold,trial=>$trial,live_during=>\@live_during,live_after=>scalar(grep {defined} @weak),calls=>$calls,expected_calls=>24,reused_addresses=>$reused,lengths=>\@lengths,result_kind=>ref($value)||'scalar',result=>ref($value)?undef:$value,error=>$e?{map{$_=>ref($e->{$_})?ref($e->{$_}):$e->{$_}}qw(type stage summary detail code)}:undef}),"\n";
}}
STARTUP50_MODELED_RECYCLING
```
