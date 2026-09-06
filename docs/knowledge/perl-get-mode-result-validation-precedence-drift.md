---
id: perl-get-mode-result-validation-precedence-drift
title: "Perl mode-only compilation acquires a false error when descriptor output is also requested"
answers:
  - "why does parse_only with return_descriptor report a runtime compile error"
  - "why does generate_only with return_descriptor report a runtime compile error"
  - "which task fixes combined Perl compiler option result validation"
  - "does ParserFactory independently reject successful combined mode-only results"
date: 2026-09-06
status: confirmed-open
tags: [perl, compiler, modes, diagnostics, parser-factory, startup-reading]
evidence: "SESSION-STARTUP-READING.3.2.42 preserves nine public Get controls and eight isolated ParserFactory controls at unchanged reading baseline baeb984e. Runtime.pm 99–104 and ParserFactory.pm 316–318 choose descriptor validation before mode-only validation; Compiler.pm 1402/1783/1789 chooses mode-only stops first. Full Runtime change 86d6511c7 was read."
reverify: "Run both managed matrices below; retain source-capture and genuine invalid-source controls."
---

The compiler successfully returns undef for `parse_only`, or after generation for `generate_only`,
even if `return_descriptor` is also true. The runtime result validator instead requires a descriptor
hash whenever descriptor output is requested. It records a false `runtime_owner/run_get_pipeline`
error for every descriptor-plus-mode combination. The diagnostic says that the pipeline returned
undef without structured context; absence of an error is expected at this successful stop.

| parse_only | generate_only | return_descriptor | Return | Generated capture | Public last_error |
| --- | --- | --- | --- | --- | --- |
| false | false | false | CODE | 8,806 bytes | absent |
| true | false | false | undef | empty | absent |
| false | true | false | undef | 8,806 bytes | absent |
| true | true | false | undef | empty | absent |
| false | false | true | HASH | 8,806 bytes | absent |
| true | false | true | undef | empty | false runtime error |
| false | true | true | undef | 8,806 bytes | false runtime error |
| true | true | true | undef | empty | false runtime error |

These byte counts belong to the exact small source below. They are observations, not a generated-format
length contract. A ninth control passes invalid source with generate_only and retains
`compiler_pipeline/validate_spec_content`, proving that generation still parses and validates source.
The parse-only bootstrap dump is deliberately captured in memory; its forced output does not mean a parser
or compiled-state object was returned.

ParserFactory independently has the same priority mismatch. Eight injected, side-effect-free compiler
result controls isolate it from Runtime: the same three combinations acquire
`parser_factory/compile_spec` with `compile_spec returned invalid descriptor value: undef; expected HASH`
and a failed compilation trace decision. The five other combinations remain error-free. This isolated
matrix is not yet the named-source public `get_parser` matrix.

The Runtime predicate was introduced in `86d6511c76aa37aa966c11e64c4116966e7ce966`
(`Phase 5: tighten runtime compile result diagnostics`, April 4). April 9 commit `c5ba9fe57` renamed the checked
option key from `return_descr` to `return_descriptor` in both the diagnostic and predicate, without changing
this priority. April 4 is the predicate's structural origin; no earlier public reachability date is inferred. Existing mode-only regression subtests
cover single flags and malformed defined results; they do not establish combined-option correctness.

[[SESSION-STARTUP-READING]] `.42` owns repair of both validators, complete public Get/get_parser
matrices, genuine-failure preservation, trace classification, and direct-dependent proof. Book repair
`.41.5` owns the related API teaching. No runtime or public-book repair is claimed here.
The compiler's source-level ordering remains correctly recorded in
[[perl-compiler-pipeline-stage-and-mode-boundaries]].

## Reverify the public compiler boundary

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;my $j=JSON::PP->new->canonical;
LinkedSpec::configure_trace(level=>'none');
my $spec="Top::\n I { return(1) }\n";
for my $mask (0..7) {
 my %options=(parse_only=>($mask&1)?1:0,generate_only=>($mask&2)?1:0,return_descriptor=>($mask&4)?1:0);
 my(%ctx,$ret);my($source,$dump)=('','');open my $capture,'>',\$dump or die $!;
 my $ok;my $err;{local *STDOUT=$capture;$ok=eval{$ret=LinkedSpec::Get(\$spec,%options,dump_parser_source=>1,parser_source_ref=>\$source,runtime_ctx_ref=>\%ctx);1};$err=$@}close $capture;
 die "mask $mask threw: $err" unless $ok;
 my $kind=defined($ret)?ref($ret)||'scalar':'undef';
 my $expected=($mask&3)?'undef':($mask&4)?'HASH':'CODE';die "kind $mask" unless $kind eq $expected;
 my $false_error=(($mask&4)&&($mask&3))?1:0;die "error presence $mask" unless (!!$ctx{last_error})==$false_error;
 die "capture $mask" unless (!!length($source))==(($mask&1)?0:1);
 my $diag=$ctx{last_error};die "wrong diagnostic" if $diag && (($diag->{type}//'') ne 'runtime_owner'||($diag->{stage}//'') ne 'run_get_pipeline'||($diag->{detail}//'') ne 'run_get_pipeline returned undef without structured runtime context');
 print $j->encode({options=>\%options,returned=>$kind,source_bytes=>length($source),forced_dump_bytes=>length($dump),error=>$diag?{map{$_=>$diag->{$_}}qw(type stage summary detail)}:undef}),"\n";
}
my $bad="not a spec\n";my %ctx;my $r=LinkedSpec::Get(\$bad,generate_only=>1,runtime_ctx_ref=>\%ctx);
die 'invalid source accepted' if defined($r)||!$ctx{last_error};
print $j->encode({case=>'generate_only_invalid_source',returned=>'undef',error_type=>$ctx{last_error}{type},stage=>$ctx{last_error}{stage}}),"\n";
PERL
```

## Reverify the isolated factory boundary

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MLinkedSpec::ParserFactory -MJSON::PP - <<'PERL'
use strict;use warnings;LinkedSpec::configure_trace(level=>'none');my $j=JSON::PP->new->canonical;
for my $mask(0..7) {
 my %opt=(parse_only=>($mask&1)?1:0,generate_only=>($mask&2)?1:0,return_descriptor=>($mask&4)?1:0);
 my $ctx;my $value=($mask&3)?undef:($mask&4)?{}:sub {1};
 my @decisions;
 my $r=LinkedSpec::ParserFactory::run_get_parser('mode_probe',{%opt,top_rule=>'Top',runtime_ctx_ref=>\$ctx},{
  apply_trace_options=>sub{1},trace_enter=>sub{{scope=>'probe'}},trace_exit=>sub{1},trace_decision=>sub{push @decisions,[@_];1},
  validate_spec_name=>sub{1},resolve_spec_path=>sub{'.linkedspec-data/scratch/mode-probe.spec'},
  load_spec_content=>sub{"Top::\n I { return(1) }\n"},compile_spec=>sub{$value},dump_low=>100,dump_medium=>200,
 });
 my $want=($mask&3)?'undef':($mask&4)?'HASH':'CODE';my $kind=defined($r)?ref($r)||'scalar':'undef';
 die "return kind $mask" unless $kind eq $want;
 my $false=(($mask&4)&&($mask&3))?1:0;die "error presence $mask" unless (!!$ctx->{last_error})==$false;
 my($decision)=grep{$_->[0] eq 'get_parser_compilation_result'}@decisions;die "trace $mask" unless $decision && !!$decision->[1]==!$false;
 my $e=$ctx->{last_error};die "type $mask" if $e && (($e->{type}//'') ne 'parser_factory'||($e->{stage}//'') ne 'compile_spec');
 print $j->encode({mask=>$mask,returned=>$kind,error=>$e?{map{$_=>$e->{$_}}qw(type stage detail)}:undef,trace_success=>$decision->[1]?1:0}),"\n";
}
PERL
```
