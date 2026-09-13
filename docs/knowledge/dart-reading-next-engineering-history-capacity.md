---
id: dart-reading-next-engineering-history-capacity
title: Approved engineering-history member preserves Dart reading continuity after child 46
answers:
  - which engineering history limits block Dart reading after child 46
  - what exact capacity proposal does DART STARTUP READING 7 own
  - did Dart child 46 preserve every engineering history byte
  - does ADR0111 authorize another engineering history archive member
date: 2026-09-10
status: implemented under ADR0113; explicit one-time focused/receipt exception granted 2026-09-11
tags: [dart, startup, continuity, history, capacity, approval]
evidence: "The required .1.46 engineering-notes draft is 461 lines / 40403 bytes. Governed rollover archives clean db762cd7 source lines 247-457, 211 lines / 24521 bytes, into 4980-b29e3bd321a1. The actual routing checker rejects only collection files 28/27 and manifest lines 27/26. All 62 prior history files are restored byte-exact; a complete 285-byte dated record permits the completed reading to land at 459 lines / 40321 bytes. No control is changed."
reverify: "Historical draft: DART146_ENGINEERING_PROPOSAL. Approved implementation: ENGINEERING_HISTORY_11_ADMISSION and ENGINEERING_HISTORY_11_BOUNDARIES below. Use both roll_document_history.pl --check commands for later live pressure."
---

## Later director update — September13

The director has cancelled the RGX/PGEN no-rebuild/build-on-update-only
restriction recorded below. Normal Cargo dependency compilation is authorized;
startup .80 retains optional freshness/performance repair ownership. The dated
reading-only evidence and its separate CI exception below remain unchanged.


## Exact pending proposal

| Control | Current | Proposed |
| --- | ---: | ---: |
| engineering_notes collection max_files | 27 | 28 |
| development-notes manifest max_lines | 26 | 27 |

Manifest bytes are 16,230, within the unchanged 16,384 ceiling. The draft
collection is 28 files / 26,074 lines / 2,789,760 bytes, within the unchanged
27,000-line / 3,145,728-byte aggregate limits. Root 512 lines / 65,536 bytes
and segment 4,096 lines / 524,288 bytes also remain unchanged. No owner,
route, verifier, schema, other limit or accepted history is changed.

`COMMIT.md` requires a complete dated note and mandatory rollover at 90%.
The governed draft preserves the exact clean source suffix: blob
`e85923ff1e3b88da3b17c32f168368b7cda1b367`, lines 247-457, 211 lines /
24,521 bytes, SHA-256
`b29e3bd321a1357afe2e779c7e138986e96bef3258c4408d785fc06b11bb58f5`.
The retained root is 250 lines / 15,882 bytes. Every prior manifest row
remains byte-identical and ordered; full archive reconstruction hashes to
`baa5c445280a246641a3a3a4cd5c2fb8ef8444ac901126152183f9c2d73069fd`.
The actual resulting-tree validator rejects exactly the two count limits.
All 22 independent/combined boundary executions below pass on a detached
proposed object. These are proposal checks, not infrastructure admission.

After copying and verifying the draft in repository-local scratch, only the
new uncommitted segment was removed and its manifest/root edits restored.
All 62 prior history files match their pre-draft hashes. The new note uses the
existing complete dated-record format: 285 bytes, with full detail in the task,
Knowledge and book. The root is 459 lines / 40,321 bytes. One line remains
below the largest integer line count under the unchanged rollover threshold;
another meaningful complete dated record needs the .7 decision.

ADR0111 authorized only the preceding 26-to-27-file / 25-to-26-row increase;
ADR0112 covers change history alone. Neither grants this further member.
`README_POLICY.md` requires a new accepted indexed decision for any increase.
`DART-STARTUP-READING.7` owns the decision; after approval, activate a bounded
`LIVE-DOCUMENT-PRESSURE-CONTAINMENT` implementation from a clean repository,
remeasure the actual source, preserve all history, verify the real boundaries
and run receipt-bound canonical proof. Child .1.47 waits for that boundary.
The proposal grants no future slot, source repair, purge or parked feature.

## Pinned draft replay

This reads Git only and recreates no archive files. Later implementation must
remeasure its live source rather than treating these dated coordinates as current.

```bash
bash tools/project_data_run.sh python3 - <<'DART146_ENGINEERING_PROPOSAL'
from pathlib import Path
import subprocess,json,hashlib,re
BASE='db762cd7b35b83243467dd117e7e965072e1ddf6'
def git(*args):return subprocess.check_output(['git',*args])
source=git('show',BASE+':DEVELOPMENT_NOTES.md')
manifest='docs/history/development-notes/manifest.jsonl'
old=git('show',BASE+':'+manifest)
part=b''.join(source.splitlines(keepends=True)[246:457])
assert (len(part.splitlines()),len(part))==(211,24521)
assert hashlib.sha256(part).hexdigest()=='b29e3bd321a1357afe2e779c7e138986e96bef3258c4408d785fc06b11bb58f5'
assert source.endswith(part)
row={'byte_count': 24521, 'current_path': 'DEVELOPMENT_NOTES.md', 'immutable': True, 'line_count': 211, 'retrieval_command': 'perl tools/read_document_history.pl --surface engineering_notes --segment 4980', 'segment_id': '4980', 'sha256': 'b29e3bd321a1357afe2e779c7e138986e96bef3258c4408d785fc06b11bb58f5', 'source_blob': 'e85923ff1e3b88da3b17c32f168368b7cda1b367', 'source_commit': 'db762cd7b35b83243467dd117e7e965072e1ddf6', 'source_end_line': 457, 'source_path': 'DEVELOPMENT_NOTES.md', 'source_start_line': 247, 'surface': 'engineering_notes', 'target_path': 'docs/history/development-notes/segment-4980-b29e3bd321a1.md', 'type': 'segment'}
assert git('rev-parse',BASE+':DEVELOPMENT_NOTES.md').decode().strip()==row['source_blob']
rows=[json.loads(line) for line in old.splitlines()];rows[0]['segment_count']+=1;rows.insert(1,row)
new=('\n'.join(json.dumps(r,sort_keys=True,separators=(',',':')) for r in rows)+'\n').encode()
assert (len(rows),len(new))==(27,16230)
assert new.splitlines(keepends=True)[2:]==old.splitlines(keepends=True)[1:]
note='## 2026-09-10 — interpreter proof and Knowledge correction\n\nDart .1.46 completes interpreter tests and reads matching through 86. All 68 tests and write/numeric/mark neutral checks pass. The July core-helper fact predated September dense write semantics; corrected its current answer and retained exact historical prose. No runtime change or prior-defect closure.\n\n'.encode()
start=re.search(rb'^## ',source,re.M).start();draft=source[:start]+note+source[start:]
assert (len(draft.splitlines()),len(draft))==(461,40403)
retained=draft[:-len(part)]
assert (len(retained.splitlines()),len(retained))==(250,15882)
paths=git('ls-tree','-r','--name-only',BASE,'--','docs/history/development-notes/').decode().splitlines()
parts=[git('show',BASE+':'+p) for p in paths if p.endswith('.md')]
population=[retained,new,part,*parts]
metrics={'files':len(population),'lines':sum(len(p.splitlines()) for p in population),'bytes':sum(map(len,population))}
assert metrics=={'files':28,'lines':26074,'bytes':2789760}
archive=part+b''.join(git('show',BASE+':'+r['target_path']) for r in rows[2:])
assert hashlib.sha256(archive).hexdigest()=='baa5c445280a246641a3a3a4cd5c2fb8ef8444ac901126152183f9c2d73069fd'
print('PASS exact clean-source draft, source/manifest/history identity and finite proposal',metrics)
DART146_ENGINEERING_PROPOSAL
```

## Actual-validator boundaries

The exact production limit predicate runs against a detached proposal, with
below/equal, independent and simultaneous excesses, plus old/proposed draft
controls. No registry value is edited.

```bash
bash tools/project_data_run.sh perl - <<'DART146_ENGINEERING_BOUNDARIES'
use strict;use warnings;use JSON::PP ();
sub read_source {my($p)=@_;open my $f,'<:raw',$p or die "$p: $!";local $/;my $s=<$f>;close $f or die $!;return $s}
my $src=read_source('scripts/check_readme_routing_pressure.pl');
my($fn)=$src=~/(^sub exceeds_limits \{.*?^\})/ms;die 'missing validator' unless defined $fn;
eval($fn."\n1;") or die $@;
my $json=JSON::PP->new->canonical(1);
my @rs=map {$json->decode($_)} split /\n/,read_source('doctrine/readme_stability/routes.jsonl');
my($r)=grep {$_->{type} eq 'surface' && $_->{id} eq 'engineering_notes'} @rs;
my $manifest='docs/history/development-notes/manifest.jsonl';
die 'proposal baseline moved; remeasure' unless $r->{limits}{max_files}==27 && $r->{member_limits}{$manifest}{max_lines}==26;
my $proposal=$json->decode($json->encode($r));
$proposal->{limits}{max_files}=28;$proposal->{member_limits}{$manifest}{max_lines}=27;
my $l=$proposal->{limits};my $n=0;
my @labels=('files','aggregate lines','aggregate bytes','segment.md lines','segment.md bytes');
for my $case(-2..5) {
 my $m={files=>$l->{max_files},lines=>$l->{max_total_lines},bytes=>$l->{max_total_bytes},
  members=>['segment.md'],per_file=>{'segment.md'=>{lines=>$l->{max_lines_per_file},bytes=>$l->{max_bytes_per_file}}}};
 my @slots=(\$m->{files},\$m->{lines},\$m->{bytes},\$m->{per_file}{'segment.md'}{lines},\$m->{per_file}{'segment.md'}{bytes});
 if($case==-2){--$$_ for @slots}elsif($case==5){++$$_ for @slots}elsif($case>=0){++${$slots[$case]}}
 my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$l);
 my @want=$case==5?@labels:$case>=0?($labels[$case]):();
 die "collection case $case: @got" unless $json->encode(\@got) eq $json->encode(\@want);++$n;
}
for my $path ('DEVELOPMENT_NOTES.md',$manifest) {
 my $cap=$proposal->{member_limits}{$path};
 for my $case(-2..2){
  my $m={lines=>$cap->{max_lines},bytes=>$cap->{max_bytes}};
  --$m->{$_} for $case==-2?qw(lines bytes):();
  ++$m->{lines} if $case==0 || $case==2;++$m->{bytes} if $case==1 || $case==2;
  my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$cap);
  my @want=$case==2?qw(lines bytes):$case==0?('lines'):$case==1?('bytes'):();
  die "$path case $case: @got" unless $json->encode(\@got) eq $json->encode(\@want);++$n;
 }
}
my $m={files=>28,lines=>26074,bytes=>2789760,members=>[],per_file=>{}};
my @old=exceeds_limits($m,$r->{limits});my @new=exceeds_limits($m,$l);
die 'collection measured control' unless "@old" eq 'files 28/27' && !@new;
my $mm={lines=>27,bytes=>16230};
@old=exceeds_limits($mm,$r->{member_limits}{$manifest});@new=exceeds_limits($mm,$proposal->{member_limits}{$manifest});
die 'manifest measured control' unless "@old" eq 'lines 27/26' && !@new;
$n+=4;die "count $n" unless $n==22;
print "PASS 22 actual validator executions; proposed two-scalar controls fit measured draft and retain every independent boundary. No registry mutation.\n";
DART146_ENGINEERING_BOUNDARIES
```

Related: [[dart-reading-engineering-history-capacity-blocker]],
[[bounded-change-notes-history-contract]].

## Approved implementation — September 10

The director explicitly granted the .7 engineering-history proposal.
`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.11` and indexed ADR0113 implement exactly
collection files 27→28 and manifest lines 26→27, from clean
`01a2159c093c71d6cd15b9d1aceee5dfc3505008`. The earlier proposal and its
old-control boundary recipe above are historical; the current proofs follow.

The actual rollover starts at 466 lines / 40,687 bytes and preserves source
lines 249-459, blob `ebc30daf8dc84bdc1da5d60a67ff36007b14a70f`, as 211 lines /
24,521 bytes. The segment bytes and SHA-256 match the earlier proposal, while
the source commit, blob and coordinates are freshly verified. The live root
removes one terminal separator LF for whitespace hygiene; reconstruction
explicitly restores it. No immutable byte is normalized.

The resulting root is 254 lines / 16,165 bytes; manifest 27 lines / 16,230 bytes;
collection 28 files / 26,078 lines / 2,790,043 bytes. Every other ceiling stays
unchanged. All prior manifest records and 61 other history files remain exact;
full manifest-order reconstruction passes. All 22 production-validator boundary
executions pass, with the measured candidate failing exactly the two former
controls and fitting the approved ones. The September 11 director exception below
authorizes focused landing, followed by the per-leaf commit, empty brief and clean handoff.

The concurrent director requirement for PGEN/RGX build-on-submodule-update
reuse is routed to startup .80. This capacity change does not implement that
build lifecycle or waive any remaining startup prerequisite. Dart .1.47 is the
next reading leaf after the capacity boundary. No further archive is authorized.

```bash
bash tools/project_data_run.sh python3 - <<'ENGINEERING_HISTORY_11_ADMISSION'
from pathlib import Path
import subprocess,json,hashlib
BASE='01a2159c093c71d6cd15b9d1aceee5dfc3505008'
def git(*args):return subprocess.check_output(['git',*args])
registry='doctrine/readme_stability/routes.jsonl'
manifest='docs/history/development-notes/manifest.jsonl'
before=git('show',BASE+':'+registry).splitlines();after=Path(registry).read_bytes().splitlines()
assert len(before)==len(after);changed=0
for a,b in zip(before,after):
 if a==b:continue
 old=json.loads(a);new=json.loads(b);assert old['id']==new['id']=='engineering_notes'
 assert old['limits']['max_files']==27
 assert old['member_limits'][manifest]=={'max_lines':26,'max_bytes':16384}
 old['limits']['max_files']=28;old['member_limits'][manifest]['max_lines']=27
 assert old==new;changed+=1
assert changed==1
old=git('show',BASE+':'+manifest).splitlines(keepends=True)
current=Path(manifest).read_bytes();rows=current.splitlines(keepends=True)
assert rows[2:]==old[1:]
h=json.loads(old[0]);h['segment_count']+=1;assert json.loads(rows[0])==h
r=json.loads(rows[1]);assert r['source_commit']==BASE and r['segment_id']=='4980'
source=git('show',BASE+':DEVELOPMENT_NOTES.md')
assert r['source_blob']==git('rev-parse',BASE+':DEVELOPMENT_NOTES.md').decode().strip()=='ebc30daf8dc84bdc1da5d60a67ff36007b14a70f'
segment=Path(r['target_path']).read_bytes()
assert segment==b''.join(source.splitlines(keepends=True)[248:459])
assert (r['source_start_line'],r['source_end_line'],r['line_count'],r['byte_count'])==(249,459,211,24521)
assert hashlib.sha256(segment).hexdigest()==r['sha256']=='b29e3bd321a1357afe2e779c7e138986e96bef3258c4408d785fc06b11bb58f5'
assert (len(rows),len(current))==(27,16230)
root=Path('DEVELOPMENT_NOTES.md').read_bytes()
a=root.index(b'## 2026-09-10');b=root.index(b'- 2026-09-10: DART-STARTUP-READING.1.46',a)
assert root[:a]+root[b:]+b'\n'+segment==source
archive=subprocess.check_output(['perl','tools/read_document_history.pl','--surface','engineering_notes','--all'])
assert archive==b''.join(Path(json.loads(row)['target_path']).read_bytes() for row in rows[1:])
assert hashlib.sha256(archive).hexdigest()=='baa5c445280a246641a3a3a4cd5c2fb8ef8444ac901126152183f9c2d73069fd'
old_paths=git('ls-tree','-r','--name-only',BASE,'--','docs/history/').decode().splitlines()
requests=b''.join((BASE+':'+p+'\n').encode() for p in old_paths)
batch=subprocess.check_output(['git','cat-file','--batch'],input=requests);offset=0
for p in old_paths:
 end=batch.index(b'\n',offset);size=int(batch[offset:end].split()[2]);offset=end+1
 data=batch[offset:offset+size];offset+=size+1
 if p!=manifest:assert Path(p).read_bytes()==data,p
assert offset==len(batch) and len(old_paths)==62
paths=[Path('DEVELOPMENT_NOTES.md'),Path(manifest),*sorted(Path('docs/history/development-notes').glob('*.md'))]
metrics={'files':len(paths),'lines':sum(len(p.read_bytes().splitlines()) for p in paths),'bytes':sum(p.stat().st_size for p in paths)}
assert metrics=={'files':28,'lines':26078,'bytes':2790043}
assert (len(root.splitlines()),len(root))==(254,16165)
print(json.dumps({'source_commit':BASE,'source_blob':r['source_blob'],'source_lines':[249,459],
 'segment_bytes':len(segment),'segment_sha256':r['sha256'],'prior_history_files':len(old_paths),
 'root_lines':254,'root_bytes':16165,'manifest_lines':27,'manifest_bytes':16230,'collection':metrics}))
print('PASS two approved scalars, exact source/old manifest/history, full query and separator reconstruction')
ENGINEERING_HISTORY_11_ADMISSION
```

```bash
bash tools/project_data_run.sh perl - <<'ENGINEERING_HISTORY_11_BOUNDARIES'
use strict;use warnings;use JSON::PP ();
sub read_source {my($p)=@_;open my $f,'<:raw',$p or die "$p: $!";local $/;my $s=<$f>;close $f or die $!;return $s}
my $src=read_source('scripts/check_readme_routing_pressure.pl');
my($fn)=$src=~/(^sub exceeds_limits \{.*?^\})/ms;die 'missing validator' unless defined $fn;
eval($fn."\n1;") or die $@;
my $json=JSON::PP->new->canonical(1);
my @rs=map {$json->decode($_)} split /\n/,read_source('doctrine/readme_stability/routes.jsonl');
my($r)=grep {$_->{type} eq 'surface' && $_->{id} eq 'engineering_notes'} @rs;
my $manifest='docs/history/development-notes/manifest.jsonl';
die 'approved boundary moved; remeasure' unless $r->{limits}{max_files}==28 && $r->{member_limits}{$manifest}{max_lines}==27;
my $proposal=$json->decode($json->encode($r));
my $l=$proposal->{limits};my $n=0;
my @labels=('files','aggregate lines','aggregate bytes','segment.md lines','segment.md bytes');
for my $case(-2..5) {
 my $m={files=>$l->{max_files},lines=>$l->{max_total_lines},bytes=>$l->{max_total_bytes},
  members=>['segment.md'],per_file=>{'segment.md'=>{lines=>$l->{max_lines_per_file},bytes=>$l->{max_bytes_per_file}}}};
 my @slots=(\$m->{files},\$m->{lines},\$m->{bytes},\$m->{per_file}{'segment.md'}{lines},\$m->{per_file}{'segment.md'}{bytes});
 if($case==-2){--$$_ for @slots}elsif($case==5){++$$_ for @slots}elsif($case>=0){++${$slots[$case]}}
 my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$l);
 my @want=$case==5?@labels:$case>=0?($labels[$case]):();
 die "collection case $case: @got" unless $json->encode(\@got) eq $json->encode(\@want);++$n;
}
for my $path ('DEVELOPMENT_NOTES.md',$manifest) {
 my $cap=$proposal->{member_limits}{$path};
 for my $case(-2..2){
  my $m={lines=>$cap->{max_lines},bytes=>$cap->{max_bytes}};
  --$m->{$_} for $case==-2?qw(lines bytes):();
  ++$m->{lines} if $case==0 || $case==2;++$m->{bytes} if $case==1 || $case==2;
  my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$cap);
  my @want=$case==2?qw(lines bytes):$case==0?('lines'):$case==1?('bytes'):();
  die "$path case $case: @got" unless $json->encode(\@got) eq $json->encode(\@want);++$n;
 }
}
my $m={files=>28,lines=>26078,bytes=>2790043,members=>[],per_file=>{}};
my %old_limits=%{$r->{limits}};$old_limits{max_files}=27;
my @old=exceeds_limits($m,\%old_limits);my @new=exceeds_limits($m,$l);
die 'collection measured control' unless "@old" eq 'files 28/27' && !@new;
my $mm={lines=>27,bytes=>16230};
my %old_member=%{$r->{member_limits}{$manifest}};$old_member{max_lines}=26;
@old=exceeds_limits($mm,\%old_member);@new=exceeds_limits($mm,$proposal->{member_limits}{$manifest});
die 'manifest measured control' unless "@old" eq 'lines 27/26' && !@new;
$n+=4;die "count $n" unless $n==22;
print "PASS 22 actual validator executions; approved two-scalar controls fit measured candidate and retain every independent boundary. No registry mutation.\n";
ENGINEERING_HISTORY_11_BOUNDARIES
```

## September 11 execution boundary — historical request, now resolved

The exact approved capacity candidate is staged but uncommitted. Focused history,
22 boundary cases, task metadata, memory, rendered book and staged routing pass.
No full canonical gate or PGEN/RGX build has been started. `COMMIT.md` requires an
exact receipt for this infrastructure commit; the existing gate previously compiled
PGEN eleven times. The director now requires build-on-submodule-update reuse.
Containment .11 owns the decision on a one-time canonical-receipt exception before
this candidate can commit without that gate. Capacity approval is already granted;
no receipt bypass, changed limit beyond that approval, or task pivot is authorized.

## Granted resolution — September 11

On 2026-09-11 the director explicitly granted a one-time canonical-receipt exception for .11 using passing focused checks, to avoid the current gate’s repeated PGEN/RGX builds. Normal commit hooks and all nine doctrines remain enabled; no full CI, dependency build or canonical receipt is claimed. All future verification boundaries retain their existing requirements.

The preceding request is retained as historical evidence. The director answered
“Granted” to committing this capacity change with its passing focused checks.
Containment .11 closes Dart intake .7; .1.47 is the next reading leaf after the
normal commit, empty brief and clean proof. No further capacity is preapproved.
