---
id: task-partition-capacity-registry-drift
title: "Partition checker retains older task collection ceilings than the canonical registry"
answers:
  - "why does task tree metadata reject 88000 lines when the registry allows 92000"
  - "do all task collection gates use the approved capacity"
  - "why did supporting source reading 1.18 fail its first commit"
  - "where is the duplicate task capacity checker repair owned"
date: 2026-09-13
status: confirmed open; current reading candidate contained within both gates
tags: [tasks, capacity, doctrine, verification, continuity, SUPPORTING-SOURCE-READING]
evidence: "SUPPORTING-SOURCE-READING.1.18 normal hooks exit1: TASK-TREE-METADATA and README-STABILITY fail the older 88000-line cap, seven other doctrines pass. Exact production-function boundary probes expose line and byte disagreement with the approved registry. .2.6 owns repair after startup prerequisites. The revised reading task decomposition retains seven concrete grammar/literal repair slices with focused verification in each, removing nine redundant nodes; no source, registry, gate or prior history change."
reverify: "Run TASK_CAPACITY_CHECKER_DRIFT below through the project-data wrapper, then scripts/check_task_tree_metadata.sh for the actual current collection. The four boundary cases assert the dated discrepancy; update after .2.6 repair."
---

The registry's `task_evidence` row permits 92,000 total lines and 10,485,760
bytes; the partition checker instead hardcodes 88,000 lines and 9,437,184 bytes.
Its self-tests repeat those old constants, so all31 pass without detecting
registry disagreement. File128, member8,000 lines and member1,048,576 bytes remain
identical; this finding proposes no wider capacity.

The checker was last changed by `4489f5e9a3cf60fabf6c4f69d27aedfc87cbac6b`.
Lua admission `0bf9218e359fda81ff5a4ed412ebe014546f12ee` changed the registry's
aggregate limits from the older to newer values. Exact Git blobs prove that the
checker stayed byte-identical before/after that admission and through this audit.
ADR0118 explicitly constrained that admission to eleven registry scalars while
preserving source. Its threshold model exercised the routing validator, not this
second hardcoded partition guard; the discrepancy remained latent while actual
task volume fit the older limits. This qualifies the earlier capacity admission:
the registry allowance does not establish agreement of every enforcing consumer.

The first `.1.18` commit attempt lands nothing. Its code/AST evidence remains
valid, but the task decomposition crosses the old line cap. Keeping implementation
and focused verification in the same bounded repair slice preserves all seven
concrete repairs and acceptance criteria while removing nine redundant task
nodes. The revised census at diagnosis is104 files/87,966 lines/9,371,460 bytes,
within both controls; final landing still requires all normal hooks. Prior task
records, source, registry and immutable history are unchanged. No hook bypass or
dense packing/removal of unique evidence is used.

`SUPPORTING-SOURCE-READING.2.6` owns eventual enforcement alignment plus
registry-agreement recurrence and independent inclusive/overflow cases. It retains
startup code-reading/book/policy prerequisites and applicable verification tiers.
ADR0118's before-reading/focused exception applied only to containment `.14`;
this audit does not extend it or request another exception. Future candidates must
still be measured against both current controls until the owned repair lands.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl - <<'TASK_CAPACITY_CHECKER_DRIFT'
use strict;
use warnings;
use JSON::PP;
my $json=JSON::PP->new->canonical;
sub bytes {my($p)=@_;open my $f,'<:raw',$p or die "$p: $!";local $/;my $b=<$f>;close $f or die $!;return $b}
my $source=bytes('scripts/check_task_tree_partitions.pl');
my ($fn)=$source =~ /(^sub collection_total_errors \{.*?^\})/ms;
die 'function boundary missing' unless defined $fn;
eval $fn;die $@ if $@;
my ($row)=grep {($_->{id}//'') eq 'task_evidence'} map {$json->decode($_)} split /\n/,bytes('doctrine/readme_stability/routes.jsonl');
my $limits=$row->{limits};
die 'registry boundary changed' unless $limits->{max_files}==128 && $limits->{max_total_lines}==92000 && $limits->{max_total_bytes}==10485760;
my @cases=(
 ['old inclusive',128,88000,9437184,[]],
 ['line disagreement',128,88001,9437184,['task collection exceeds 88,000 lines']],
 ['byte disagreement',128,88000,9437185,['task collection exceeds 9,437,184 bytes']],
 ['canonical inclusive',128,92000,10485760,['task collection exceeds 88,000 lines','task collection exceeds 9,437,184 bytes']],
);
my @results;
for my $c(@cases) {
 my($name,$files,$lines,$bytes,$want)=@$c;
 my @got=collection_total_errors($files,$lines,$bytes);
 die "checker observation changed $name" unless $json->encode(\@got) eq $json->encode($want);
 die "canonical case unexpectedly over limit $name" unless $files<=$limits->{max_files} && $lines<=$limits->{max_total_lines} && $bytes<=$limits->{max_total_bytes};
 push @results,{case=>$name,checker=>\@got,registry_accepts=>JSON::PP::true};
}
my @paths=grep {-f $_ && !-l $_} glob('docs/tasks/*.md');my($lines,$size)=(0,0);
for my $p(@paths) {my $b=bytes($p);$size+=length($b);$lines+=($b=~tr/\n//)+((length($b)&&$b!~/\n\z/)?1:0)}
my @current=collection_total_errors(scalar(@paths),$lines,$size);
print $json->encode({cases=>\@results,current=>{files=>scalar(@paths),lines=>$lines,bytes=>$size,checker_errors=>\@current},registry_limits=>$limits}),"\n";
TASK_CAPACITY_CHECKER_DRIFT
```

Related: [[SUPPORTING-SOURCE-READING]], [[self-hosted-grammar-ast-drift]],
[[lua-reading-evidence-capacity-admission]], and
[[supporting-source-reading-coverage]].
