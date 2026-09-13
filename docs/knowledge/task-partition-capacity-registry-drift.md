---
id: task-partition-capacity-registry-drift
title: "Task partition checker now agrees with the approved registry and rejects duplicate-limit drift"
answers:
  - "why does task tree metadata reject 88000 lines when the registry allows 92000"
  - "do all task collection gates use the approved capacity"
  - "why did supporting source reading 1.18 fail its first commit"
  - "where is the duplicate task capacity checker repair owned"
date: 2026-09-13
status: repaired under SUPPORTING-SOURCE-READING.2.6; prior diagnosis and proposal retained below
tags: [tasks, capacity, doctrine, verification, continuity, SUPPORTING-SOURCE-READING]
evidence: "SUPPORTING-SOURCE-READING.1.18 normal hooks exit1: TASK-TREE-METADATA and README-STABILITY fail the older 88000-line cap, seven other doctrines pass. Exact production-function boundary probes expose line and byte disagreement with the approved registry. .2.6 owns repair after startup prerequisites. The revised reading task decomposition retains seven concrete grammar/literal repair slices with focused verification in each, removing nine redundant nodes; no source, registry, gate or prior history change."
reverify: "Run TASK_CHECKER_APPLIED_PROOF below and scripts/check_task_tree_metadata.sh. Earlier diagnosis/proposal recipes are historical pre-fix evidence; the current replay retrieves their exact original Git source and compares the applied checker."
---

Current disposition: the director granted the exact prepared correction and its
focused verification before remaining reading; ADR0120 records that authority.
The applied source matches the proposal digest, preserves all registry limits, and
passes the actual partition gate plus37 self-tests/50 detached registry cases.

# Historical diagnosis and proposal before the correction

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

# Concrete correction proposed by supporting .3

The independent audit reaches the current practical blocker: its readable task
record brings the collection to 87,995 lines, leaving five lines under the stale
guard. The next source-reading decomposition cannot fit. This is a measured
current constraint, not a request for an unlimited reserve.

Proposed `.2.6` correction changes one production file: align the two aggregate
constants and boundary tests to the existing registry ceilings, then compare all
five checker boundaries against the real registry on every run. Inclusive and
one-over probes detect either stricter or looser duplicate limits, including
member limits. Missing/duplicate rows and invalid limit shapes reject. Registry
ceilings, per-file safeguards, paths, ownership and historical evidence stay fixed.
Future reviewed registry changes must reconcile this enforcing consumer too;
the added check prevents a silent mismatch from surviving until data grows.

The draft passes Perl syntax checking, all 37 mutation self-tests and 50 detached
registry cases. The same agreement check reports four failures against the
unchanged original functions and none against the draft. This is proposal proof,
not an applied fix or canonical CI. Production source SHA-256 is
`bd1a52602dd2e6e82c8adf2fc8603c9602eb9c8bf610252c5627728ff51e9a0a`;
proposed source SHA-256 is
`9f4e5c1a3f268fc8364e6430583a8df58a522cd9c12bc24575d11181758a0206`.
The full current checker was physically read for this diagnosis; no aggregate
startup tooling-reading completion is claimed.

The new proposal explicitly requests permission to apply this bounded correction
before the remaining startup reading, using focused changed-surface proof and all
normal hooks for this correction. The prior `.14` exception did not authorize it.
Parent reading closeout has a separate proposed focused exception in
[[supporting-reading-closeout-audit]]. Both await new director disposition; no
source, registry or gate has changed and no approval is inferred from elapsed time.

```diff
--- a/scripts/check_task_tree_partitions.pl
+++ b/scripts/check_task_tree_partitions.pl
@@ -33,0 +34,2 @@
+my ($capacity_records) = decode_index('doctrine/readme_stability/routes.jsonl', \@errors);
+push @errors, collection_registry_errors($capacity_records);
@@ -222,2 +224,39 @@
-    push @errors, 'task collection exceeds 88,000 lines' if $lines > 88_000;
-    push @errors, 'task collection exceeds 9,437,184 bytes' if $bytes > 9_437_184;
+    push @errors, 'task collection exceeds 92,000 lines' if $lines > 92_000;
+    push @errors, 'task collection exceeds 10,485,760 bytes' if $bytes > 10_485_760;
+    return @errors;
+}
+
+sub collection_registry_errors {
+    my ($records) = @_;
+    return ('task capacity registry is not an array') if ref($records) ne 'ARRAY';
+    my @rows = grep { ref($_) eq 'HASH' && ($_->{id} // '') eq 'task_evidence' } @$records;
+    return ('task capacity registry needs exactly one task_evidence row') if @rows != 1;
+    my $limits = $rows[0]{limits};
+    my @keys = qw(max_files max_total_lines max_total_bytes max_lines_per_file max_bytes_per_file);
+    return ('task capacity limits do not have the exact five fields') if !exact_keys($limits, \@keys);
+    for my $key (@keys) {
+        return ("task capacity $key is not a positive integer")
+            if !defined($limits->{$key}) || ref($limits->{$key})
+                || $limits->{$key} !~ /\A[1-9][0-9]*\z/;
+    }
+    my @aggregate = @{$limits}{qw(max_files max_total_lines max_total_bytes)};
+    my @member = @{$limits}{qw(max_lines_per_file max_bytes_per_file)};
+    my @errors;
+    push @errors, 'task aggregate checker rejects the registry inclusive boundary'
+        if collection_total_errors(@aggregate);
+    push @errors, 'task member checker rejects the registry inclusive boundary'
+        if collection_member_errors('registry-boundary.md', @member);
+    for my $i (0 .. 2) {
+        my @over = @aggregate;
+        ++$over[$i];
+        my @got = collection_total_errors(@over);
+        push @errors, 'task aggregate checker does not reject exactly registry ' . $keys[$i] . '+1'
+            if @got != 1;
+    }
+    for my $i (0 .. 1) {
+        my @over = @member;
+        ++$over[$i];
+        my @got = collection_member_errors('registry-boundary.md', @over);
+        push @errors, 'task member checker does not reject exactly registry ' . $keys[$i + 3] . '+1'
+            if @got != 1;
+    }
@@ -389,0 +429,6 @@
+    my $registry_fixture = sub {
+        return [{id => 'task_evidence', limits => {
+            max_files => 128, max_total_lines => 92_000, max_total_bytes => 10_485_760,
+            max_lines_per_file => 8_000, max_bytes_per_file => 1_048_576,
+        }}];
+    };
@@ -390,0 +436,20 @@
+        ['registry_capacity_agrees', sub { !collection_registry_errors($registry_fixture->()) }],
+        ['registry_capacity_missing', sub { !!collection_registry_errors([]) }],
+        ['registry_capacity_duplicate', sub {
+            !!collection_registry_errors([@{$registry_fixture->()}, @{$registry_fixture->()}]);
+        }],
+        ['registry_capacity_invalid', sub {
+            my $records = $registry_fixture->();
+            $records->[0]{limits}{max_total_lines} = 0;
+            return !!collection_registry_errors($records);
+        }],
+        ['registry_capacity_line_drift', sub {
+            my $records = $registry_fixture->();
+            --$records->[0]{limits}{max_total_lines};
+            return !!collection_registry_errors($records);
+        }],
+        ['registry_capacity_byte_drift', sub {
+            my $records = $registry_fixture->();
+            ++$records->[0]{limits}{max_total_bytes};
+            return !!collection_registry_errors($records);
+        }],
@@ -403 +468 @@
-            return same_strings([collection_total_errors(128, 88_000, 9_437_184)], [])
+            return same_strings([collection_total_errors(128, 92_000, 10_485_760)], [])
@@ -407 +472 @@
-            return same_strings([collection_total_errors(129, 88_000, 9_437_184)],
+            return same_strings([collection_total_errors(129, 92_000, 10_485_760)],
@@ -411,2 +476,2 @@
-            return same_strings([collection_total_errors(128, 88_001, 9_437_184)],
-                ['task collection exceeds 88,000 lines']);
+            return same_strings([collection_total_errors(128, 92_001, 10_485_760)],
+                ['task collection exceeds 92,000 lines']);
@@ -415,2 +480,2 @@
-            return same_strings([collection_total_errors(128, 88_000, 9_437_185)],
-                ['task collection exceeds 9,437,184 bytes']);
+            return same_strings([collection_total_errors(128, 92_000, 10_485_761)],
+                ['task collection exceeds 10,485,760 bytes']);
@@ -427,3 +492,3 @@
-            return same_strings([collection_total_errors(129, 88_001, 9_437_185)],
-                ['task collection exceeds 128 files', 'task collection exceeds 88,000 lines',
-                 'task collection exceeds 9,437,184 bytes'])
+            return same_strings([collection_total_errors(129, 92_001, 10_485_761)],
+                ['task collection exceeds 128 files', 'task collection exceeds 92,000 lines',
+                 'task collection exceeds 10,485,760 bytes'])
```

The replay reconstructs only the draft in managed scratch and checks exact source
identity. The following Perl block executes isolated actual/proposed functions;
it does not run a substituted repository gate or create an acceptance receipt.

```bash
bash tools/project_data_run.sh python3 - <<'TASK_CHECKER_PROPOSAL_EXTRACT'
from pathlib import Path
import re,hashlib
card=Path('docs/knowledge/task-partition-capacity-registry-drift.md').read_text()
patch=card.split('```diff\n',1)[1].split('\n```',1)[0]+'\n'
path=Path('scripts/check_task_tree_partitions.pl');original=path.read_bytes()
assert hashlib.sha256(original).hexdigest()=='bd1a52602dd2e6e82c8adf2fc8603c9602eb9c8bf610252c5627728ff51e9a0a'
lines=original.decode().splitlines(True);out=[];cursor=0
for hunk in re.split(r'(?=^@@ )',patch,flags=re.M)[1:]:
 header,*body=hunk.splitlines(True)
 m=re.match(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@',header);assert m
 start=int(m[1])-(0 if m[2]=="0" else 1);assert start>=cursor;out.extend(lines[cursor:start]);cursor=start
 removed=added=0
 for line in body:
  tag,text=line[0],line[1:]
  if tag in [' ','-']:
   assert lines[cursor]==text;cursor+=1;removed+=1
  if tag in [' ','+']:out.append(text);added+=1
  assert tag in [' ','-','+'],tag
 assert removed==int(m[2] or 1) and added==int(m[4] or 1)
out.extend(lines[cursor:]);candidate=''.join(out)
assert hashlib.sha256(candidate.encode()).hexdigest()=='9f4e5c1a3f268fc8364e6430583a8df58a522cd9c12bc24575d11181758a0206'
scratch=Path('.linkedspec-data/scratch/support31');scratch.mkdir(parents=True,exist_ok=True)
(scratch/'check_task_tree_partitions.proposed.pl').write_text(candidate)
helper=re.search(r'^sub collection_registry_errors \{.*?^\}\n\n',candidate,re.M|re.S);assert helper
(scratch/'checker-helper.txt').write_text(helper[0])
assert path.read_bytes()==original
print('PASS exact proposed one-file diff reconstructed in managed scratch; production source unchanged.')
TASK_CHECKER_PROPOSAL_EXTRACT
bash tools/project_data_run.sh env PERL5LIB= perl -c .linkedspec-data/scratch/support31/check_task_tree_partitions.proposed.pl
```

```bash
bash tools/project_data_run.sh env PERL5LIB= perl - <<'TASK_CHECKER_PROPOSAL_PROOF'
use strict;
use warnings;
use JSON::PP;
use Digest::SHA qw(sha256_hex);
my $json=JSON::PP->new->canonical;
sub read_raw {my($p)=@_;open my $f,'<:raw',$p or die "$p: $!";local $/;my $b=<$f>;close $f or die $!;return $b}
my $old=read_raw('scripts/check_task_tree_partitions.pl');
my $new=read_raw('.linkedspec-data/scratch/support31/check_task_tree_partitions.proposed.pl');
my $helper=read_raw('.linkedspec-data/scratch/support31/checker-helper.txt');
my ($registry)=grep {($_->{id}//'') eq 'task_evidence'} map {$json->decode($_)} split /\n/,read_raw('doctrine/readme_stability/routes.jsonl');
my @report;
for my $pair(['Original',$old],['Proposed',$new]) {
 my($package,$source)=@$pair;
 my $prelude=substr($source,0,index($source,'chdir $ROOT'));
 my $subs=substr($source,index($source,'sub collection_member_errors {'));
 $subs.=$helper if $package eq 'Original';
 my $code="package $package;\n$prelude\n$subs\n1;";
 eval $code;die $@ if $@;
 no strict 'refs';
 if($package eq 'Proposed') { &{"${package}::run_self_tests"}() }
 my @errors=&{"${package}::collection_registry_errors"}([$registry]);
 die 'original discrepancy disappeared' if $package eq 'Original' && @errors!=4;
 die "proposal disagrees with registry: @errors" if $package eq 'Proposed' && @errors;
 push @report,{version=>$package,registry_errors=>\@errors};
}
my @keys=qw(max_files max_total_lines max_total_bytes max_lines_per_file max_bytes_per_file);
my $cases=0;
sub check_case {
 my($name,$mutate,$reject)=@_;
 my $records=$json->decode($json->encode([$registry]));$mutate->($records);
 my @errors=Proposed::collection_registry_errors($records);
 die "wrong disposition $name: @errors" unless (!!@errors)==!!$reject;
 ++$cases;
}
check_case('canonical authority',sub {},0);
for my $key(@keys) {
 for my $delta(-1,1) {check_case("$key delta $delta",sub {$_[0][0]{limits}{$key}+=$delta},1)}
 for my $bad(undef,0,-1,[],{},'invalid',JSON::PP::true) {
  check_case("$key invalid",sub {$_[0][0]{limits}{$key}=$bad},1);
 }
}
check_case('missing row',sub {@{$_[0]}=()},1);
check_case('duplicate row',sub {push @{$_[0]},$_[0][0]},1);
check_case('missing key',sub {delete $_[0][0]{limits}{max_files}},1);
check_case('extra key',sub {$_[0][0]{limits}{extra}=1},1);
die "case count $cases" unless $cases==50;
print $json->encode({production_sha256=>sha256_hex($old),proposed_sha256=>sha256_hex($new),red_green=>\@report,registry_cases=>$cases}),"\n";
TASK_CHECKER_PROPOSAL_PROOF
```

# Applied correction — 2026-09-13

Supporting `.2.6` applies the exact approved diff above. The real registry is checked
on every run: its inclusive boundaries must pass and each single-dimension
overflow must produce exactly one rejection. Missing/duplicate rows and malformed
limits fail. The same proof reports four original disagreements and zero applied
disagreements. This closes the checker defect; six grammar/literal repair roots
remain. Full CI is waived only for this correction and the separate supporting
reading closeout under `docs/decisions/0120-supporting-reading-unblock.md`.

The earlier embedded recipes remain dated evidence, with their original source
assumptions. This current replay uses Git to restore that exact original input in
managed scratch and exercises the applied production functions.

```bash
bash tools/project_data_run.sh env PERL5LIB= python3 - <<'TASK_CHECKER_APPLIED_PROOF'
from pathlib import Path
import re,hashlib,subprocess
card=Path('docs/knowledge/task-partition-capacity-registry-drift.md').read_text()
source=Path('scripts/check_task_tree_partitions.pl').read_bytes()
assert hashlib.sha256(source).hexdigest()=='9f4e5c1a3f268fc8364e6430583a8df58a522cd9c12bc24575d11181758a0206'
base='693e11e48168aba753b179b88cdb6800d4b06513'
old=subprocess.check_output(['git','show',base+':scripts/check_task_tree_partitions.pl'])
assert hashlib.sha256(old).hexdigest()=='bd1a52602dd2e6e82c8adf2fc8603c9602eb9c8bf610252c5627728ff51e9a0a'
s=Path('.linkedspec-data/scratch/support26');s.mkdir(parents=True,exist_ok=True)
(s/'original.pl').write_bytes(old)
helper=re.search(rb'^sub collection_registry_errors \{.*?^\}\n\n',source,re.M|re.S);assert helper
(s/'helper.txt').write_bytes(helper[0])
marker='TASK_CHECKER_PROPOSAL_PROOF'
body=card.split("<<'"+marker+"'\n",1)[1].split('\n'+marker,1)[0]+'\n'
body=body.replace("my $old=read_raw('scripts/check_task_tree_partitions.pl');", "my $old=read_raw('.linkedspec-data/scratch/support26/original.pl');")
body=body.replace("my $new=read_raw('.linkedspec-data/scratch/support31/check_task_tree_partitions.proposed.pl');", "my $new=read_raw('scripts/check_task_tree_partitions.pl');")
body=body.replace('.linkedspec-data/scratch/support31/checker-helper.txt','.linkedspec-data/scratch/support26/helper.txt')
(s/'applied_proof.pl').write_text(body)
subprocess.run(['perl',str(s/'applied_proof.pl')],check=True)
TASK_CHECKER_APPLIED_PROOF
```
