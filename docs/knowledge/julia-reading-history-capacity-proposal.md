---
id: julia-reading-history-capacity-proposal
title: A finite two-axis history allowance covers the remaining Julia reading plan
answers:
  - which history capacity does remaining Julia reading need
  - why take Julia capacity intake before the next reading child
  - what exact history limits are proposed for Julia reading
  - does the Julia capacity proposal change aggregate or live-document limits
  - what verification decision blocks Julia history-capacity implementation
date: 2026-09-11
status: historical proposal; implemented under ADR0115 and containment .12 with explicit director approval
tags: [julia, history, capacity, continuity, proposal, verification]
evidence: "JULIA-STARTUP-READING.4.1 starts from clean 6308ff4e2 after three committed reading children. Both archive collections are full. Independent Python and extracted production-Perl function simulations agree on four rollovers each for 55 future records of 14 lines/2048 bytes. All prior manifest/archive bytes and whole-history query hashes are verified. Six exact limit changes are proposed under pending containment .12; no registry/history/CI/source mutation."
reverify:
  - "Run the two repository-managed model recipes below from the frozen source commit."
  - "perl tools/roll_document_history.pl --surface change_history --check"
  - "perl tools/roll_document_history.pl --surface engineering_notes --check"
---

## Later director update — September13

The director has cancelled the RGX/PGEN no-rebuild/build-on-update-only
restriction recorded below. Normal Cargo dependency compilation is authorized;
startup .80 retains optional freshness/performance repair ownership. The dated
reading-only evidence and its separate CI exception below remain unchanged.


# Historical proposal — resolved by approved admission

The director answered YES to the six controls and one-time focused exception.
Containment .12 implements ADR0115; evidence: [[julia-reading-history-capacity-admission]].
The proposal below retains its dated models; its pending-decision wording is historical.

Recommend four additional archive slots in each history collection, with only
their manifest line/byte limits enlarged enough to index those slots. This is a
finite allowance for remaining Julia reading and its closeout, not runtime repairs,
Lua reading or unlimited future chronology. Implementation is owned by pending
`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.12`. Julia .4.1 is proposal-only.

| Control | Current | Proposed |
| --- | ---: | ---: |
| change_history collection files | 32 | 36 |
| changes manifest lines | 31 | 35 |
| changes manifest bytes | 17,615 | 19,919 |
| engineering_notes collection files | 28 | 32 |
| development-notes manifest lines | 27 | 31 |
| development-notes manifest bytes | 16,384 | 18,678 |

The root limits remain 512 lines /65,536 bytes; segment limits remain 4,096 lines /
524,288 bytes. Change-history aggregate limits stay 55,000 lines /4,194,304 bytes;
engineering-notes aggregates stay 27,000 lines /3,145,728 bytes. Owners, routes,
schema, lifecycle, verifiers and every prior immutable record remain unchanged.

No archive is rewritten or deleted. Existing storage is already partitioned;
moving the current suffix alone cannot create a missing permitted file slot.
Routing away or discarding required complete commit records would violate
`COMMIT.md` and the history preservation contract. Source repairs, PGEN/RGX
changes and parked authoring ideas are outside this proposal.

# Exact measured need

Baseline `6308ff4e2426de216cf702b86107e4ebda33a026` has:

| Surface | Hot root lines / bytes | Collection files / lines / bytes | Manifest lines / bytes |
| --- | --- | --- | --- |
| change_history | 443 /26,500 | 32 /48,964 /3,554,933 | 31 /17,615 |
| engineering_notes | 378 /23,613 | 28 /26,202 /2,797,491 | 27 /16,230 |

Both collections use all admitted archive slots. The change root has only 17
additional complete lines below the mandatory 461-line rollover threshold.
The concrete intake record uses 12 lines, leaving five. Another ordinary
seven-line reading record would therefore require a currently disallowed archive.
Taking this checkpoint now preserves a committed proposal before that deadlock.

The 55 actual Dart reading commits added 390 change lines /25,380 bytes and
450 note lines /33,346 bytes. The largest records added 10 change lines /669 bytes
and 13 note lines /1,411 bytes. The proposal models 55 future records at a more
conservative 14 lines /2,048 bytes each: 49 remaining Julia reading children,
three reading-closeout records and three capacity/admission records. These latter
counts are a planning envelope, not already-created mandatory leaves. Unknown
growth still requires per-leaf measurement; do not delete or compress unique
evidence to fit a forecast.

Both line and byte pressure trigger rollover at 90%, retaining at most 50% on
both axes. Modeling only lines would miss later byte-triggered rollovers here.
Python's independent record model and the actual Perl `split_current`, threshold,
prefix, line-count and `segment_record` functions agree on every boundary:

| Surface | Rollover after projected record | Final hot lines / bytes | Aggregate forecast lines / bytes |
| --- | --- | --- | --- |
| change_history | 2, 17, 31, 45 | 362 /52,026 | 49,738 /3,669,877 |
| engineering_notes | 6, 22, 36, 50 | 292 /41,838 | 26,976 /2,912,579 |

The engineering worst-case line forecast leaves only 24 aggregate lines; this
allowance cannot fund unrelated history. Each synthetic record and simulated
archive is reconstructed byte-for-byte after every step. Maximal new manifest
rows are 576 /612 bytes respectively, using the fixed schema and maximum current
root coordinate/byte widths. Existing metadata remains two-digit segment counts.
Thus 17,615 +4×576 =19,919 and 16,230 +4×612 =18,678 are exact manifest bounds.

Archived-history queries at the baseline are independently retained as:

- changes: 48,490 lines /3,510,818 bytes, SHA-256 `2f2638b7937ab9f3f12391dff412b1503e5a0e6bbddabe236702a274b774fdbc`;
- notes: 25,797 lines /2,757,648 bytes, SHA-256 `baa5c445280a246641a3a3a4cd5c2fb8ef8444ac901126152183f9c2d73069fd`.

These query counts exclude hot roots and manifest/index framing; they are not collection totals.
Every current segment's declared count/size/hash and every existing manifest byte
are checked separately.

# Verification decision

`README_POLICY.md` requires a new accepted indexed ADR containing exact old/new
canonical limit objects before any increase. `COMMIT.md` and ADR0073 classify the
implementation as canonical infrastructure. ADR0113 and ADR0114 grant no future
receipt exception; this proposal claims none.

The director requires PGEN/RGX compilation only following submodule updates.
Startup .80 still owns the CI implementation of that requirement, behind remaining
reading prerequisites. The prior expensive dependency-build evidence is already
retained there; this intake does not rerun CI to rediscover it.

The proposed implementation boundary is one explicit exception for containment
.12: use exact six-scalar registry proof, source/history preservation, actual
routing-validator threshold/authorization mutations, all nine normal doctrines,
both histories, Knowledge and rendered book, without canonical CI or dependency
builds. It changes no standing gate and grants no later or push exception.
The director's decision is required before taking that proposed boundary.
All implementation inputs and this bounded plan are reviewable in the committed
intake; the parent remains open and Julia .1.4 waits behind it.

# Independent model

Save the following as a repository-managed scratch Python file and run through
`bash tools/project_data_run.sh python3 <script>`. Its output is diagnostic data
below the repository; it reads historical roots from the exact baseline.
For replay after later history changes, compare the dated result with that
baseline. Later current archive queries must retain the complete baseline archive as an exact suffix.

```python
from pathlib import Path
import subprocess,re,json,hashlib,math
BASE='6308ff4e2426de216cf702b86107e4ebda33a026'
def enc(x):return (json.dumps(x,sort_keys=True,separators=(',',':'))+'\n').encode()
def digest(x):return hashlib.sha256(x).hexdigest()
def lc(x):return x.count(b'\n')+int(bool(x) and not x.endswith(b'\n'))
def reached(x,pct):return lc(x)*100>=512*pct or len(x)*100>=65536*pct
def exceeded(x,pct):return lc(x)*100>512*pct or len(x)*100>65536*pct
def split(x):
 starts=[m.start() for m in re.finditer(rb'(?m)^## ',x)]
 assert starts
 return x[:starts[0]],[x[a:b] for a,b in zip(starts,starts[1:]+[len(x)])]
def future(i):
 prefix=('## Projected Julia evidence record '+str(i)+'\n\n').encode()
 rows=[b'bounded evidence\n']*12
 extra=2048-len(prefix)-sum(map(len,rows));assert extra>0
 rows[0]=b'x'*extra+rows[0]
 raw=prefix+b''.join(rows);assert lc(raw)==14 and len(raw)==2048
 return raw
registry=[json.loads(x) for x in subprocess.check_output(['git','show',BASE+':doctrine/readme_stability/routes.jsonl']).decode().splitlines()]
results=[]
for id,root,family in [('change_history','CHANGES.md','changes'),('engineering_notes','DEVELOPMENT_NOTES.md','development-notes')]:
 surface=next(x for x in registry if x.get('id')==id)
 source=subprocess.check_output(['git','show',BASE+':'+root])
 preamble,records=split(source);assert b''.join([preamble,*records])==source
 original_records=list(records)
 manifest_path='docs/history/'+family+'/manifest.jsonl'
 manifest=subprocess.check_output(['git','show',BASE+':'+manifest_path]);parsed=[json.loads(x) for x in manifest.splitlines()];metadata,history=parsed[0],parsed[1:]
 assert b''.join(enc(x) for x in parsed)==manifest
 for row in history:
  raw=Path(row['target_path']).read_bytes();assert digest(raw)==row['sha256'] and len(raw)==row['byte_count'] and lc(raw)==row['line_count']
 query=b''.join(Path(row['target_path']).read_bytes() for row in history)
 actual_query=subprocess.check_output(['perl','tools/read_document_history.pl','--surface',id,'--all']);assert actual_query.endswith(query)
 old_paths={Path(root),Path(manifest_path),*(Path(row['target_path']) for row in history)}
 baseline_bytes=[source,manifest]+[Path(row['target_path']).read_bytes() for row in history]
 old_total_lines=sum(map(lc,baseline_bytes));old_total_bytes=sum(map(len,baseline_bytes))
 rollovers=[]
 current=source;archived_total=b'';all_future=[]
 for i in range(1,56):
  added=future(i);all_future.insert(0,added);before=current
  records.insert(0,added);candidate=preamble+b''.join(records)
  if reached(candidate,90):
   keep=len(records)
   while keep>1 and exceeded(preamble+b''.join(records[:keep]),50):keep-=1
   retained=preamble+b''.join(records[:keep]);assert keep>=1 and not exceeded(retained,50)
   archive=b''.join(records[keep:]);assert archive and before.endswith(archive)
   # Runtime source range points into this simulated prior clean root, never a real commit.
   start=lc(before[:-len(archive)])+1;end=lc(before)
   nr=int(history[0]['segment_id'])-1;sid=f'{nr:04d}';sha=digest(archive)
   row=dict(byte_count=len(archive),current_path=root,immutable=True,line_count=lc(archive),
    retrieval_command='perl tools/read_document_history.pl --surface '+id+' --segment '+sid,
    segment_id=sid,sha256=sha,source_blob='0'*40,source_commit='0'*40,
    source_end_line=end,source_path=root,source_start_line=start,surface=id,
    target_path='docs/history/'+family+'/segment-'+sid+'-'+sha[:12]+'.md',type='segment')
   history.insert(0,row);metadata['segment_count']=len(history)
   rollovers.append(dict(after_record=i,candidate=[lc(candidate),len(candidate)],retained=[lc(retained),len(retained)],archived=[lc(archive),len(archive)],manifest_row_bytes=len(enc(row))))
   archived_total=archive+archived_total
   records=records[:keep];current=retained
  else:current=candidate
  assert preamble+b''.join(all_future)+b''.join(original_records)==current+archived_total
 new_manifest=enc(metadata)+b''.join(enc(row) for row in history)
 # Bound every potential new record by actual schema widths, not favorable model coordinates.
 template=dict(history[0]);template.update(byte_count=65536,line_count=512,source_start_line=512,source_end_line=512,source_blob='f'*40,source_commit='f'*40,sha256='f'*64)
 template['target_path']='docs/history/'+family+'/segment-0001-'+'f'*12+'.md';template['segment_id']='0001';template['retrieval_command']='perl tools/read_document_history.pl --surface '+id+' --segment 0001'
 per_row_bound=len(enc(template))
 allowance=len(rollovers)
 new_limits=dict(surface['limits'],max_files=surface['limits']['max_files']+allowance)
 new_member=dict(surface['member_limits'][manifest_path],max_lines=surface['member_limits'][manifest_path]['max_lines']+allowance,max_bytes=max(surface['member_limits'][manifest_path]['max_bytes'],len(manifest)+allowance*per_row_bound))
 forecast_lines=old_total_lines+55*14+allowance;forecast_bytes=old_total_bytes+55*2048+allowance*per_row_bound
 assert forecast_lines<=new_limits['max_total_lines'] and forecast_bytes<=new_limits['max_total_bytes']
 assert len(new_manifest)<=new_member['max_bytes']
 result=dict(surface=id,root=root,baseline=BASE,source_blob=subprocess.check_output(['git','rev-parse',BASE+':'+root]).decode().strip(),current=[lc(source),len(source)],collection=[len(old_paths),old_total_lines,old_total_bytes],manifest=[lc(manifest),len(manifest),digest(manifest)],query=[lc(query),len(query),digest(query)],record_budget=[55,14,2048],rollovers=rollovers,new_limits=new_limits,old_limits=surface['limits'],old_manifest_limit=surface['member_limits'][manifest_path],new_manifest_limit=new_member,manifest_row_byte_bound=per_row_bound,forecast=[forecast_lines,forecast_bytes],modeled_final=[lc(current),len(current)])
 results.append(result)
 print(json.dumps(result,indent=2))
Path('.linkedspec-data/scratch/julia41').mkdir(parents=True,exist_ok=True)
Path('.linkedspec-data/scratch/julia41/model.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS 55-record dual-axis simulation per surface, all prefix/suffix byte reconstruction, current manifests/archives, full history queries, aggregate forecasts; no history or registry mutation.')
```

# Production-function cross-check

Save this as a repository-managed scratch Perl file after the Python model and
run with `bash tools/project_data_run.sh perl <script>`. It evaluates only the
named actual read-only functions, not the tool's mutation entrypoint.

```perl
use strict;use warnings;use JSON::PP;use Digest::SHA qw(sha256_hex);
my $MAX_LINES=512;my $MAX_BYTES=65536;my $code;
{open my $fh,'<:raw','tools/roll_document_history.pl' or die $!;local $/;$code=<$fh>}
my $extracted='';
for my $bounds (['sub split_current {','sub validate_preamble {'],['sub threshold_reached {','sub read_manifest {'],['sub segment_record {','sub usage {']) {
 my ($a,$b)=map {index($code,$_)} @$bounds;die 'subroutine source boundary' if $a<0||$b<$a;$extracted.=substr($code,$a,$b-$a)."\n";
}
eval $extracted;die $@ if $@;
my $expected;{open my $fh,'<:raw','.linkedspec-data/scratch/julia41/model.json' or die $!;local $/;$expected=JSON::PP->new->decode(<$fh>)}
my $json=JSON::PP->new->canonical->utf8;
for my $model (@$expected) {
 my $root=$model->{root};open my $git,'-|','git','show',"$model->{baseline}:$root" or die $!;binmode $git;my $raw=do {local $/;<$git>};close $git or die 'git source';
 my ($pre,$records)=split_current($raw,{boundary=>($root eq 'CHANGES.md'?qr/^## /m:qr/^(?:- 20[0-9]{2}-[0-9]{2}\b|## )/m),current=>$root});
 my @rolls;
 for my $i (1..55) {
  my $prefix="## Projected Julia evidence record $i\n\n";my @rows=("bounded evidence\n")x12;my $extra=2048-length($prefix)-length(join('',@rows));$rows[0]=('x'x$extra).$rows[0];my $new=$prefix.join('',@rows);
  die 'synthetic bound' unless line_count($new)==14 && length($new)==2048;
  unshift @$records,$new;my $candidate=$pre.join_prefix($records,scalar @$records);
  if(threshold_reached(line_count($candidate),length($candidate),90)) {
   my $keep=scalar @$records;
   while($keep>1 && threshold_exceeded(line_count($pre.join_prefix($records,$keep)),length($pre.join_prefix($records,$keep)),50)) {--$keep}
   my $retained=$pre.join_prefix($records,$keep);my $archived=join('',@$records[$keep..$#$records]);
   push @rolls,{after_record=>$i,candidate=>[line_count($candidate),length($candidate)],retained=>[line_count($retained),length($retained)],archived=>[line_count($archived),length($archived)]};
   @$records=@$records[0..$keep-1];
  }
 }
 die 'rollover count' unless @rolls==@{$model->{rollovers}};
 for my $i (0..$#rolls) {
  my %expected=%{$model->{rollovers}[$i]};delete $expected{manifest_row_bytes};
  die 'actual function model mismatch' unless $json->encode($rolls[$i]) eq $json->encode(\%expected);
 }
 my $family=$root eq 'CHANGES.md'?'changes':'development-notes';my $id=$model->{surface};
 my $record=segment_record($id,{current=>$root},'0001',"docs/history/$family/segment-0001-".('f'x12).'.md','f'x64,'f'x40,'f'x40,512,512,512,65536);
 die 'row byte-bound mismatch' unless length($json->encode($record)."\n")==$model->{manifest_row_byte_bound};
 print "PASS $id: 55 source-function simulations; ".scalar(@rolls)." exact rollovers; maximal future row $model->{manifest_row_byte_bound} bytes\n";
}
```
