---
id: dart-reading-second-history-capacity-blocker
title: Dart reading second change-history member approval and exact preservation
answers:
  - "which history allowance blocks Dart reading after slice 36"
  - "what exact additional change-history limits are proposed after ADR0110"
  - "why can Dart reading not commit another slice after 1.36"
  - "did Dart slice 36 preserve the rejected rollover history"
date: 2026-09-10
status: director approved; ADR0112 implemented by containment .10 with exact canonical landing proof
tags: [dart, startup, continuity, history, capacity, approval]
evidence: DART-STARTUP-READING.1.36 and .6; actual governed rollover and routing rejection; clean 6cb42d87 CHANGES247-457; exact restored history; ADR0110
reverify: "Historical draft: DART136_HISTORY_PROPOSAL. Exact .10 candidate/commit: SECOND_HISTORY_ADMISSION and SECOND_HISTORY_BOUNDARIES below. Later current pressure uses both roll_document_history.pl --check commands and scripts/check_readme_stability.sh."
---

## Historical proposal and restoration

The normal .1.36 record reached 464 lines / 47,015 bytes. The governed
`tools/roll_document_history.pl` requires rollover at 90% of the 512-line or
65,536-byte root ceiling. The exact clean-source suffix selected by `--apply`
was `CHANGES.md` lines 247-457 at
`6cb42d876d605830bdb429236e08d553a541fd9d`: 211 lines / 31,668 bytes,
SHA-256 `55830675f67c5814a5457a3c2adabc054d918b62582312c52d791fe268b78ef4`.

The resulting draft has a 253-line / 15,347-byte root and one additional
immutable segment `4981`. Actual routing validation rejects exactly:

| Control | Existing | Measured proposal |
| --- | ---: | ---: |
| change_history maximum files | 31 | 32 |
| manifest maximum lines | 30 | 31 |
| manifest maximum bytes | 17,039 | 17,615 |

The draft collection is 48,767 lines / 3,543,340 bytes, within its existing
55,000-line / 4,194,304-byte ceilings. The segment fits 4,096 lines / 524,288
bytes; root ceilings, routes, ownership, history schema and all other controls
remain unchanged. This proposal admits exactly one member, with no future
member reserved.

ADR `0110` says: “Every further increase requires new authority.”
Its prior greenlight covers the thirty-first member only. The approved
engineering-notes exception in ADR `0111` is a different collection.
`DART-STARTUP-READING.6` owns this director decision. Stable infrastructure
responsibility remains `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3`; after approval,
a separate task-tree-owned canonical implementation must remeasure the actual
source and preserve every prior byte before changing the three approved limits.

The draft segment was verified against its clean Git source and copied to
repository-local scratch. The manifest and hot root were restored from exact
pre-rollover bytes; only the proven new, untracked draft segment was removed.
All prior immutable files and manifest records are unchanged. A complete concise
three-line .1.36 record preserves the finished work and leaves the root at
460 lines / 47,004 bytes, below the unchanged 90% boundary. Its heading and
paragraph remain separate CommonMark blocks. Another new record reaches at
least 461 lines and therefore requires rollover; .1.37 awaits the capacity decision.

All 38 selected callable/compiled/action/variadic tests and neutral callable
7/11/9/7/4/8/23 checks pass, including standalone offline emitted execution.
Physical reading is 36/55; no reading credit or repair completion follows from
a capacity increase. Source repairs, recovery/purge and parked authoring/format
work retain their existing prerequisites.

The pinned proposal is read-only and reproducible from the repository root:

```bash
bash tools/project_data_run.sh python3 - <<'DART136_HISTORY_PROPOSAL'
from pathlib import Path
import hashlib,json,re,subprocess
base='6cb42d876d605830bdb429236e08d553a541fd9d'
def git(*args):return subprocess.check_output(['git',*args])
source=git('show',base+':CHANGES.md')
old=git('show',base+':docs/history/changes/manifest.jsonl')
part=b''.join(source.splitlines(keepends=True)[246:457])
digest=hashlib.sha256(part).hexdigest()
assert len(part)==31668 and len(part.splitlines())==211
assert digest=='55830675f67c5814a5457a3c2adabc054d918b62582312c52d791fe268b78ef4'
rows=[json.loads(v) for v in old.splitlines()]
record={'byte_count':len(part),'current_path':'CHANGES.md','immutable':True,
 'line_count':211,'retrieval_command':'perl tools/read_document_history.pl --surface change_history --segment 4981',
 'segment_id':'4981','sha256':digest,'source_blob':git('rev-parse',base+':CHANGES.md').decode().strip(),
 'source_commit':base,'source_end_line':457,'source_path':'CHANGES.md','source_start_line':247,
 'surface':'change_history','target_path':'docs/history/changes/segment-4981-'+digest[:12]+'.md','type':'segment'}
assert record['source_blob']=='b926af22b5519973657dde5e155894fd1f5f1093'
rows[0]['segment_count']+=1;rows.insert(1,record)
proposed=('\n'.join(json.dumps(v,sort_keys=True,separators=(',',':')) for v in rows)+'\n').encode()
assert len(rows)==31 and len(proposed)==17615
assert rows[2:]==[json.loads(v) for v in old.splitlines()[1:]]
routes=[json.loads(v) for v in git('show',base+':doctrine/readme_stability/routes.jsonl').splitlines()]
route=next(v for v in routes if v.get('id')=='change_history')
assert route['limits']['max_files']==31
assert route['member_limits']['docs/history/changes/manifest.jsonl']=={'max_lines':30,'max_bytes':17039}
print(json.dumps({'base':base,'source_blob':record['source_blob'],'source_lines':[247,457],
 'segment_lines':211,'segment_bytes':len(part),'segment_sha256':digest,
 'proposed_files':32,'proposed_manifest_lines':len(rows),'proposed_manifest_bytes':len(proposed)},indent=2))
print('PASS pinned proposal, exact clean-source suffix and prior manifest records; proposal-base allowances unchanged')
DART136_HISTORY_PROPOSAL
```

Related: [[dart-reading-history-capacity-blocker]],
[[dart-reading-engineering-history-capacity-blocker]],
[[startup-task-chronology-compaction]], ADR `0110` and ADR `0111`.


## Approved admission — 2026-09-10

The director answered “Granted”. Containment `.10` implements exactly the three
proposed controls under indexed ADR0112. The preceding proposal is historical;
its read-only replay now reads its pinned Git registry, retaining the old limits.

The actual governed rollover uses clean `e55f7703ebc42ef6a66c385bec884b8d3692fc66`,
CHANGES lines 243-460, blob `5380069ab4de95503ce30b1f64a6730e5f545fe1`.
Segment `4981-5a6450db0974` preserves 218 lines / 32,108 bytes, SHA-256
`5a6450db09742fc1ac54486af8ac47eec95afbf9e7d52901dbe3912937d30de8`.
The changed complete new record makes these coordinates differ from .1.36's
proposal; current provenance is independently measured, never inferred from it.

Root: 249 lines / 15,374 bytes. Manifest: 31 lines / 17,615 bytes. Collection:
32 files / 48,770 lines / 3,543,807 bytes. All other limits, routes and owners
remain unchanged. Every old manifest record and other history file is exact.
The generated root initially retained both boundary separator LFs; direct
concatenation reconstructed all source bytes. The final diff check rejected a
new blank EOF line. The live root therefore drops exactly that trailing LF;
reconstruction restores it after dropping only .10's new record. No immutable
archive byte or earlier complete record changes. Full manifest-ordered archive
retrieval is byte-identical. Twenty-two executions of the actual validator test
below/equal/independent/combined overflow; old limits reject exactly three axes.

The blocks below verify the exact .10 candidate/commit. Later appends need fresh
measurements; these pinned results are historical admission evidence. Exact
canonical results and receipt belong to the .10 commit. Dart `.6` closes and
`.1.37` resumes after clean landing; reading remains 36/55. Every pending repair,
startup gate and parked feature retains its prior ownership. No future member
or additional limit is authorized.

```bash
bash tools/project_data_run.sh python3 - <<'SECOND_HISTORY_ADMISSION'
from pathlib import Path
import subprocess,json,hashlib,glob,re
BASE='e55f7703ebc42ef6a66c385bec884b8d3692fc66'
def git(*args):return subprocess.check_output(['git',*args])
registry='doctrine/readme_stability/routes.jsonl';manifest='docs/history/changes/manifest.jsonl'
before=git('show',BASE+':'+registry).splitlines();after=Path(registry).read_bytes().splitlines()
assert len(before)==len(after)
changed=0
for a,b in zip(before,after):
    if a==b:continue
    old=json.loads(a);new=json.loads(b);assert old['id']==new['id']=='change_history'
    assert old['limits']['max_files']==31
    assert old['member_limits'][manifest]=={'max_lines':30,'max_bytes':17039}
    old['limits']['max_files']=32;old['member_limits'][manifest]={'max_lines':31,'max_bytes':17615}
    assert old==new;changed+=1
assert changed==1
old=git('show',BASE+':'+manifest).splitlines(keepends=True)
current=Path(manifest).read_bytes();rows=current.splitlines(keepends=True)
assert rows[2:]==old[1:]
h=json.loads(old[0]);h['segment_count']+=1;assert json.loads(rows[0])==h
r=json.loads(rows[1]);assert r['source_commit']==BASE and r['segment_id']=='4981'
source=git('show',BASE+':CHANGES.md')
assert r['source_blob']==git('rev-parse',BASE+':CHANGES.md').decode().strip()=='5380069ab4de95503ce30b1f64a6730e5f545fe1'
segment=Path(r['target_path']).read_bytes()
assert segment==b''.join(source.splitlines(keepends=True)[242:460])
assert (r['source_start_line'],r['source_end_line'],r['line_count'],r['byte_count'])==(243,460,218,32108)
assert hashlib.sha256(segment).hexdigest()==r['sha256']=='5a6450db09742fc1ac54486af8ac47eec95afbf9e7d52901dbe3912937d30de8'
assert len(rows)==31 and len(current)==17615
paths=sorted(glob.glob('docs/history/changes/*.md'))+['CHANGES.md',manifest]
assert len(paths)==32
root=Path('CHANGES.md').read_bytes()
# Drop only .10's new record; restore the one live-root EOF separator LF
# removed for diff hygiene, then concatenate the exact clean-source suffix.
marks=list(re.finditer(rb'^## ',root,re.M));assert len(marks)>=2
assert root[marks[0].start():].startswith(b'## 2026-09-10 \xe2\x80\x94 LIVE-DOCUMENT-PRESSURE-CONTAINMENT.10')
assert root[:marks[0].start()]+root[marks[1].start():]+b'\n'+segment==source
all_archived=subprocess.check_output(['perl','tools/read_document_history.pl','--surface','change_history','--all'])
expected=b''.join(Path(json.loads(row)['target_path']).read_bytes() for row in rows[1:])
assert all_archived==expected and all_archived.startswith(segment)
# Every older segment and unrelated history manifest remains byte-identical.
old_paths=git('ls-tree','-r','--name-only',BASE,'--','docs/history/').decode().splitlines()
requests=b''.join((BASE+':'+p+'\n').encode() for p in old_paths)
batch=subprocess.check_output(['git','cat-file','--batch'],input=requests);offset=0
for p in old_paths:
    end=batch.index(b'\n',offset);size=int(batch[offset:end].split()[2]);offset=end+1
    data=batch[offset:offset+size];offset+=size+1
    if p!=manifest:assert Path(p).read_bytes()==data,p
assert offset==len(batch)
metrics={'files':len(paths),'lines':sum(Path(p).read_bytes().count(b'\n') for p in paths),'bytes':sum(Path(p).stat().st_size for p in paths)}
assert metrics['lines']<=55000 and metrics['bytes']<=4194304
print(json.dumps({'source_commit':BASE,'source_blob':r['source_blob'],'source_lines':[243,460],
'segment_bytes':len(segment),'segment_sha256':r['sha256'],'prior_history_files':len(old_paths),
'manifest_lines':len(rows),'manifest_bytes':len(current),'collection':metrics,'archive_reconstruction_sha256':hashlib.sha256(all_archived).hexdigest()}))
print('PASS three-scalar-only controls, exact source and prior manifest retention, full-byte chronology reconstruction')
SECOND_HISTORY_ADMISSION
```

```bash
bash tools/project_data_run.sh perl - <<'SECOND_HISTORY_BOUNDARIES'
use strict;use warnings;use JSON::PP ();
sub read_source { my($p)=@_;open my $f,'<:raw',$p or die "$p: $!";local $/;my $s=<$f>;close $f or die $!;return $s }
my $src=read_source('scripts/check_readme_routing_pressure.pl');
my($fn)=$src=~/(^sub exceeds_limits \{.*?^\})/ms;die 'missing validator' unless defined $fn;
eval($fn."\n1;") or die $@;
my $json=JSON::PP->new->canonical(1);
my @rs=map {$json->decode($_)} split /\n/,read_source('doctrine/readme_stability/routes.jsonl');
my($r)=grep {$_->{type} eq 'surface' && $_->{id} eq 'change_history'} @rs;
my $l=$r->{limits};my $n=0;
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
for my $path ('CHANGES.md','docs/history/changes/manifest.jsonl') {
    my $cap=$r->{member_limits}{$path};
    for my $case(-2..2){
        my $m={lines=>$cap->{max_lines},bytes=>$cap->{max_bytes}};
        --$m->{$_} for $case==-2?qw(lines bytes):();
        ++$m->{lines} if $case==0 || $case==2; ++$m->{bytes} if $case==1 || $case==2;
        my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$cap);
        my @want=$case==2?qw(lines bytes):$case==0?('lines'):$case==1?('bytes'):();
        die "$path case $case: @got" unless $json->encode(\@got) eq $json->encode(\@want);++$n;
    }
}
my $m={files=>32,lines=>48770,bytes=>3543807,members=>[],per_file=>{}};
my %old=%$l;$old{max_files}=31;
my @old=exceeds_limits($m,\%old);my @new=exceeds_limits($m,$l);
die "collection measured control" unless "@old" eq 'files 32/31' && !@new;
my $manifest={lines=>31,bytes=>17615};
@old=exceeds_limits($manifest,{max_lines=>30,max_bytes=>17039});
@new=exceeds_limits($manifest,$r->{member_limits}{'docs/history/changes/manifest.jsonl'});
die "manifest measured control" unless "@old" eq 'lines 31/30 bytes 17615/17039' && !@new;
$n+=4;die "count $n" unless $n==22;
print "PASS 22 actual validator executions: equality/below/independent/combined overflow; prior controls reject exactly three measured axes, approved controls accept.\n";
SECOND_HISTORY_BOUNDARIES
```
