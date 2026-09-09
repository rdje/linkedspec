---
id: dart-reading-history-capacity-blocker
title: Dart reading additional change-history member is approved and preserved
answers:
  - why does Dart reading await another history capacity exception
  - which exact history limits block the next Dart reading rollover
  - did the Dart reading checkpoint preserve all prior change history
date: 2026-09-09
status: director approved; ADR0110 implemented by containment .8 with exact canonical landing proof
tags: [dart, startup, continuity, history, capacity, approval]
evidence: "The .1.7 draft rollover archived exact c2682cf9 CHANGES lines 217-389 as 4982, 173 lines / 26767 bytes with SHA-256 c00b7a2471b553ab83c98d104a731ac521966e5219be58daa289cd012c754aa7. Routing rejected 31/30 files, manifest 30/29 lines and 17039/16463 bytes. Only the uncommitted rollover was undone after source/hash verification; every prior history byte remains identical. A concise 339-byte new record leaves CHANGES at 58814 bytes under unchanged controls."
reverify: "Historical proposal: HISTORY_CAPACITY_PROPOSAL. Exact .8 admission candidate/commit: HISTORY_CAPACITY_ADMISSION and HISTORY_CAPACITY_BOUNDARIES below. For later current-tree pressure use perl tools/roll_document_history.pl --surface change_history --check and bash scripts/check_readme_stability.sh."
---

# Historical exact proposal

| Control | Current | Proposed |
| --- | ---: | ---: |
| `change_history.limits.max_files` | 30 | 31 |
| Manifest `max_lines` | 29 | 30 |
| Manifest `max_bytes` | 16,463 | 17,039 |

This grants exactly one immutable member and its measured manifest record.
Root 512-line / 65,536-byte, segment 4,096-line / 524,288-byte and aggregate
55,000-line / 4,194,304-byte ceilings stay unchanged. Owners, routes, lifecycle,
verifier and every prior immutable byte remain unchanged. There is no allowance
for another member beyond this proposal.

At proposal time, ADR 0106 admitted those limits. ADR 0109 explicitly states:
“No further capacity increase, cleanup/purge or parked feature activation is
authorized here.” Its approved task/Knowledge exception therefore does not
authorize this additional history capacity. `DART-STARTUP-READING.4` owned the
director decision. The subsequent “Greenlighted !” explicitly authorizes only this
additional exception; containment .8 and ADR0110 implement it from clean f8b626f0.
The original proposal below changed no limit and remains reproducible.

The governed rollover was attempted as required by COMMIT.md. Exact source
copying succeeded, then the resulting-tree routing check rejected the three
axes above. A concise current record lets verified .1.7 work land within the
existing controls; full findings remain in its task/fact/book records.
Restoration touched only the uncommitted manifest and newly generated segment,
after proving its bytes equal the pinned clean-source suffix. Earlier history
was neither shortened nor rewritten. The final hot root has only 168 bytes of
room below the largest integer size under the 90% rollover threshold.

The proposed metadata is pinned to the measured clean source. Implementation
must remeasure its actual candidate before applying the accepted limits.

```bash
bash tools/project_data_run.sh python3 - <<'HISTORY_CAPACITY_PROPOSAL'
from pathlib import Path
import hashlib,json,subprocess
base='c2682cf90b1be39f65dff15bf0d54acf91076753'
def git(*args): return subprocess.check_output(['git',*args])
source=git('show',base+':CHANGES.md')
old=git('show',base+':docs/history/changes/manifest.jsonl')
rows=[json.loads(line) for line in old.splitlines()]
part=b''.join(source.splitlines(keepends=True)[216:389])
digest=hashlib.sha256(part).hexdigest()
assert len(part)==26767 and len(part.splitlines())==173
assert digest=='c00b7a2471b553ab83c98d104a731ac521966e5219be58daa289cd012c754aa7'
row={'byte_count':len(part),'current_path':'CHANGES.md','immutable':True,
 'line_count':173,'retrieval_command':'perl tools/read_document_history.pl --surface change_history --segment 4982',
 'segment_id':'4982','sha256':digest,'source_blob':git('rev-parse',base+':CHANGES.md').decode().strip(),
 'source_commit':base,'source_end_line':389,'source_path':'CHANGES.md','source_start_line':217,
 'surface':'change_history','target_path':'docs/history/changes/segment-4982-'+digest[:12]+'.md','type':'segment'}
rows[0]['segment_count']+=1
rows.insert(1,row)
proposed=('\n'.join(json.dumps(r,sort_keys=True,separators=(',',':')) for r in rows)+'\n').encode()
assert len(proposed)==17039 and len(rows)==30 and rows[0]['segment_count']==29
print(json.dumps({'files':31,'manifest_lines':len(rows),'manifest_bytes':len(proposed),
 'segment_bytes':len(part),'segment_sha256':digest,'prior_records_preserved':rows[2:]==[json.loads(x) for x in old.splitlines()[1:]]}))
HISTORY_CAPACITY_PROPOSAL
```

## Approved admission — 2026-09-09

The director greenlight is implemented under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.8`
and indexed ADR0110. Actual provenance is clean f8b626f0, CHANGES lines 221-393,
blob 8e1f556504159c8042676a9c49efbeb448de2bfe. The suffix matches the earlier
proposal's 173 lines / 26,767 bytes and SHA-256 exactly; source coordinates/identity
are remeasured. Manifest: 30 lines / 17,039 bytes; collection: 31 files /
48,525 lines / 3,528,243 bytes. All prior manifest records and other history files
are byte-identical; the live root plus new segment exactly reconstruct the prior
root after removing .8's new record and restoring the single rollover-boundary separator LF normalized at current-root EOF. Complete archived output matches all
manifest-ordered bytes. Twenty-two actual validator executions preserve equality,
independent and combined overflow behavior and reject precisely the old three axes.
Canonical results and exact receipt belong to the .8 commit. Reading resumes at
Dart .1.8; no further capacity or repair/cleanup/feature activation is authorized.

The next blocks verify the exact .8 candidate/commit. Later appends or another
admitted rollover need their own current measurements; these pinned admission
expectations are historical evidence, not a promise that counts never change.


```bash
bash tools/project_data_run.sh python3 - <<'HISTORY_CAPACITY_ADMISSION'
from pathlib import Path
import subprocess,json,hashlib,glob,re
BASE='f8b626f0c0f16fd6168aa9a4633b1179fe09acc2'
def git(*args):return subprocess.check_output(['git',*args])
registry='doctrine/readme_stability/routes.jsonl';manifest='docs/history/changes/manifest.jsonl'
before=git('show',BASE+':'+registry).splitlines();after=Path(registry).read_bytes().splitlines()
assert len(before)==len(after)
changed=0
for a,b in zip(before,after):
    if a==b:continue
    old=json.loads(a);new=json.loads(b);assert old['id']==new['id']=='change_history'
    assert old['limits']['max_files']==30
    assert old['member_limits'][manifest]=={'max_lines':29,'max_bytes':16463}
    old['limits']['max_files']=31;old['member_limits'][manifest]={'max_lines':30,'max_bytes':17039}
    assert old==new;changed+=1
assert changed==1
old=git('show',BASE+':'+manifest).splitlines(keepends=True)
current=Path(manifest).read_bytes();rows=current.splitlines(keepends=True)
assert rows[2:]==old[1:]
h=json.loads(old[0]);h['segment_count']+=1;assert json.loads(rows[0])==h
r=json.loads(rows[1]);assert r['source_commit']==BASE and r['segment_id']=='4982'
source=git('show',BASE+':CHANGES.md')
assert r['source_blob']==git('rev-parse',BASE+':CHANGES.md').decode().strip()=='8e1f556504159c8042676a9c49efbeb448de2bfe'
segment=Path(r['target_path']).read_bytes()
assert segment==b''.join(source.splitlines(keepends=True)[220:393])
assert (r['source_start_line'],r['source_end_line'],r['line_count'],r['byte_count'])==(221,393,173,26767)
assert hashlib.sha256(segment).hexdigest()==r['sha256']=='c00b7a2471b553ab83c98d104a731ac521966e5219be58daa289cd012c754aa7'
assert len(rows)==30 and len(current)==17039
paths=sorted(glob.glob('docs/history/changes/*.md'))+['CHANGES.md',manifest]
assert len(paths)==31
root=Path('CHANGES.md').read_bytes()
# Drop only .8's new record; restore the one rollover-boundary separator LF
# normalized at current-root EOF, then reconstruct the prior hot root.
marks=list(re.finditer(rb'^## ',root,re.M));assert len(marks)>=2
assert root[marks[0].start():].startswith(b'## 2026-09-09 \xe2\x80\x94 LIVE-DOCUMENT-PRESSURE-CONTAINMENT.8')
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
print(json.dumps({'source_commit':BASE,'source_blob':r['source_blob'],'source_lines':[221,393],
'segment_bytes':len(segment),'segment_sha256':r['sha256'],'prior_history_files':len(old_paths),
'manifest_lines':len(rows),'manifest_bytes':len(current),'collection':metrics,'archive_reconstruction_sha256':hashlib.sha256(all_archived).hexdigest()}))
print('PASS three-scalar-only controls, exact source and prior manifest retention, full-byte chronology reconstruction')
HISTORY_CAPACITY_ADMISSION
```

```bash
bash tools/project_data_run.sh perl - <<'HISTORY_CAPACITY_BOUNDARIES'
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
my $m={files=>31,lines=>48525,bytes=>3528243,members=>[],per_file=>{}};
my %old=%$l;$old{max_files}=30;
my @old=exceeds_limits($m,\%old);my @new=exceeds_limits($m,$l);
die "collection measured control" unless "@old" eq 'files 31/30' && !@new;
my $manifest={lines=>30,bytes=>17039};
@old=exceeds_limits($manifest,{max_lines=>29,max_bytes=>16463});
@new=exceeds_limits($manifest,$r->{member_limits}{'docs/history/changes/manifest.jsonl'});
die "manifest measured control" unless "@old" eq 'lines 30/29 bytes 17039/16463' && !@new;
$n+=4;die "count $n" unless $n==22;
print "PASS 22 actual validator executions: equality/below/independent/combined overflow; prior controls reject exactly three measured axes, approved controls accept.\n";
HISTORY_CAPACITY_BOUNDARIES
```
