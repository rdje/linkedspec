---
id: dart-reading-next-engineering-history-capacity
title: Dart reading needs one additional engineering-history archive member after child 46
answers:
  - which engineering history limits block Dart reading after child 46
  - what exact capacity proposal does DART STARTUP READING 7 own
  - did Dart child 46 preserve every engineering history byte
  - does ADR0111 authorize another engineering history archive member
date: 2026-09-10
status: exact two-control proposal verified; director decision pending under DART-STARTUP-READING.7
tags: [dart, startup, continuity, history, capacity, approval]
evidence: "The required .1.46 engineering-notes draft is 461 lines / 40403 bytes. Governed rollover archives clean db762cd7 source lines 247-457, 211 lines / 24521 bytes, into 4980-b29e3bd321a1. The actual routing checker rejects only collection files 28/27 and manifest lines 27/26. All 62 prior history files are restored byte-exact; a complete 285-byte dated record permits the completed reading to land at 459 lines / 40321 bytes. No control is changed."
reverify: "Run the two pinned proposal blocks below; use roll_document_history.pl --check for current pressure. Remeasure live source before any approved implementation."
---

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
