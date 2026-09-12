---
id: lua-reading-evidence-capacity-proposal
title: Finite Lua reading evidence capacity and scoped verification proposal
answers:
  - what exact capacity does Lua startup reading need
  - which limits are proposed before Lua source reading
  - how do I reverify the Lua evidence reserve
  - how many history rollovers does the complete Lua reading plan need
  - does Julia capacity approval extend to Lua
  - why does Lua capacity implementation need a director decision
date: 2026-09-12
status: proposal only; director decision required before implementation
tags: [lua, capacity, history, knowledge, task-tree, verification, proposal]
evidence: "LUA-STARTUP-READING.4.1 activates from clean 7f97cb630e7f5a64915df8febdab078b9d5be38e. The exact 51-child plan remains unread. A finite 57-unit reserve uses actual Julia per-child maxima; independent and actual-function history models agree on four rollovers per collection. Eleven exact scalar changes are proposed under containment .14; no control or source changes occur here."
reverify:
  - "Run the three fenced models below in order through repository-managed scratch."
  - "Run both recipes in docs/knowledge/lua-startup-reading-coverage.md for source identity and exact comparable growth."
---

# Reviewable proposal

Approve the following eleven scalar changes for the complete Lua source-reading
activity, plus a containment .14-only focused-verification exception before full
codebase reading. No standing gate or policy changes are proposed. The exact old
and new canonical objects are retained under Capacity proposal .4.1 in
`docs/tasks/LUA-STARTUP-READING.md`; implementation belongs to
`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.14` after explicit approval.

| Control | Current | Proposed |
| --- | ---: | ---: |
| Knowledge aggregate lines | 79,000 | 93,000 |
| Knowledge aggregate bytes | 6,291,456 | 7,340,032 |
| Task aggregate lines | 88,000 | 92,000 |
| Task aggregate bytes | 9,437,184 | 10,485,760 |
| Change-history files | 36 | 38 |
| Changes manifest lines | 35 | 37 |
| Changes manifest bytes | 19,919 | 21,071 |
| Engineering-note aggregate lines | 27,000 | 28,000 |
| Engineering-note files | 32 | 34 |
| Notes manifest lines | 31 | 33 |
| Notes manifest bytes | 18,678 | 19,902 |

Knowledge/task file counts and member limits remain unchanged. Both history roots
remain capped at 512 lines / 65,536 bytes and segments at 4,096 lines / 524,288
bytes. All remaining aggregate, map, decision, public-reference and README limits,
responsibilities, routing, schema, lifecycle, verifiers and immutable bytes remain.

# Finite reserve and alternatives

The envelope is 57 units: 51 reading children, this proposal, capacity admission,
independent capacity review, independent reading audit, reading closeout and one
contingency. These support slots are a planning allowance; do not create redundant
commits merely to consume them. The exact comparable 52 Julia commits are retrieved
through [[lua-startup-reading-coverage]], not inferred from hot-root net diffs.

| Surface | Per-unit maximum or fixed reserve | Total future reserve |
| --- | --- | --- |
| Knowledge | 316 lines / 17,674 bytes / one file | 18,012 lines / 1,007,418 bytes / 57 files |
| Tasks | 105 lines / 10,593 bytes; two extra members | 5,985 lines / 603,801 bytes / two files |
| Derived map | 16 lines / 3,606 bytes | 912 lines / 205,542 bytes |
| Decisions | Three records including index rows, at 192 lines / 16,384 bytes each | 576 lines / 49,152 bytes / three files |
| Each history | 57 complete records, 14 lines / 2,048 bytes each | 798 content lines / 116,736 content bytes, plus manifest rows |

The decision reserve is explicit planning slack; the reading reference added no
ADRs. History budgets exceed observed Julia maxima (seven change lines / 437 bytes;
eight note lines / 454 bytes). Unknown findings still require a fresh per-leaf
census. This is no runtime-repair or supporting-code allowance and no guarantee
that every possible future discovery will fit.

At activation, Knowledge is 73,927 lines / 5,854,640 bytes; tasks are 85,296 lines /
8,954,197 bytes. Before proposal overhead, the maximum model projects Knowledge
91,939 lines / 6,862,058 bytes and tasks 91,281 lines / 9,557,998 bytes. The
resulting-candidate replay additionally charges all 57 units after this proposal,
conservatively counting its overhead twice. Knowledge/task maxima determine the
proposed rounded ceilings. Map, decision, file-count and member limits need no
increase; their complete current-plus-reserve projections must still pass.

A lower reference model scales the full Julia totals to 57 units and rounds up:
Knowledge 7,252 lines / 441,053 bytes; tasks 1,599 lines / 298,504 bytes. Even
that Knowledge model exceeds current line capacity. The maximum model avoids
planning repeated administrative stops when findings require more evidence.

Existing histories are already partitioned and immutable. Splitting Knowledge or
task members cannot reduce aggregate lines/bytes. Routing required records outside
their canonical owners or densely packing unique information would weaken retrieval
and violate the preservation contract. No sufficient removable duplication is
established. Any later exact duplicate removal remains separately evidence-owned;
this proposal preserves all current unique and historical content.

# Exact history models

Both models start at `7f97cb630e7f5a64915df8febdab078b9d5be38e` and retain the
actual complete records. The independent Python model and extracted production
Perl functions agree on line- and byte-triggered rollover boundaries:

| Surface | Rollovers after projected record | Final hot lines / bytes | Collection forecast lines / bytes |
| --- | --- | --- | --- |
| Changes | 4, 20, 34, 48 | 348 / 49,978 | 50,167 / 3,699,039 |
| Notes | 9, 25, 39, 53 | 278 / 39,790 | 27,400 / 2,940,096 |

Two available archive slots in each collection cover only half the four-rollover
need. Maximum manifest rows are 576 changes bytes and 612 notes bytes. Thus the
actual manifests need 18,767 + 4×576 = 21,071 and 17,454 + 4×612 = 19,902 bytes.
History query hashes, source blobs and byte reconstruction are printed by replay.
The notes aggregate rises because its forecast exceeds 27,000 even though both
root and segment limits remain unchanged. No rollover is currently required or
performed by this proposal.

# Verification decision and implementation boundary

README_POLICY.md requires a new accepted indexed ADR with exact old/new objects.
COMMIT.md / ADR0073 classify capacity infrastructure as canonical. Current canonical
CI retains dependency-building routes whose required build-on-update lifecycle is
still startup .80-owned behind remaining reading prerequisites. The unchanged
mechanism and retained evidence are in [[rust-ci-pgen-missing-input-rebuilds]].
No PGEN/RGX build is repeated to rediscover this already verified conflict.

Request one explicit exception for containment .14: perform this bounded capacity
implementation before full codebase reading, using exact eleven-scalar preservation,
full current-plus-reserve census, actual production-validator threshold and
unauthorized-change controls, history reconstruction, all nine normal doctrines,
Knowledge/memory, both histories and rendered book, without canonical CI/receipt.
No source repair, dependency build, future milestone exception or push waiver
follows. Earlier ADR0115/0116/0117 approvals do not extend to this proposal.

All authorized inventory, models and preservation proof are committed first.
Lua .4.2 owns the director's explicit disposition. If approval is denied, retain
the plan and decide another governed capacity/verification route before activation;
never infer permission from elapsed time or an earlier unrelated Granted.

# Reproduction

Save each fenced model under repository-managed scratch and run it with
`bash tools/project_data_run.sh python3 <path>` or `perl <path>` as appropriate.
The model output is ignored diagnostic data; all identities and algorithms needed
for replay are tracked here. The third model uses the current resulting candidate
and checks the full reserve against the proposed objects, without applying them.

```python
from pathlib import Path
import subprocess,re,json,hashlib,math
BASE='7f97cb630e7f5a64915df8febdab078b9d5be38e'
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
 prefix=('## Projected Lua evidence record '+str(i)+'\n\n').encode()
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
 for i in range(1,58):
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
 new_limits=dict(surface['limits'],max_files=max(surface['limits']['max_files'],len(old_paths)+allowance))
 if id=='engineering_notes':new_limits['max_total_lines']=28000
 new_member=dict(surface['member_limits'][manifest_path],max_lines=max(surface['member_limits'][manifest_path]['max_lines'],lc(manifest)+allowance),max_bytes=max(surface['member_limits'][manifest_path]['max_bytes'],len(manifest)+allowance*per_row_bound))
 forecast_lines=old_total_lines+57*14+allowance;forecast_bytes=old_total_bytes+57*2048+allowance*per_row_bound
 assert forecast_lines<=new_limits['max_total_lines'] and forecast_bytes<=new_limits['max_total_bytes']
 assert len(new_manifest)<=new_member['max_bytes']
 result=dict(surface=id,root=root,baseline=BASE,source_blob=subprocess.check_output(['git','rev-parse',BASE+':'+root]).decode().strip(),current=[lc(source),len(source)],collection=[len(old_paths),old_total_lines,old_total_bytes],manifest=[lc(manifest),len(manifest),digest(manifest)],query=[lc(query),len(query),digest(query)],record_budget=[57,14,2048],rollovers=rollovers,new_limits=new_limits,old_limits=surface['limits'],old_manifest_limit=surface['member_limits'][manifest_path],new_manifest_limit=new_member,manifest_row_byte_bound=per_row_bound,forecast=[forecast_lines,forecast_bytes],modeled_final=[lc(current),len(current)])
 results.append(result)
 print(json.dumps(result,indent=2))
Path('.linkedspec-data/scratch/lua41').mkdir(parents=True,exist_ok=True)
Path('.linkedspec-data/scratch/lua41/model.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS 57-record dual-axis simulation per surface, all prefix/suffix byte reconstruction, current manifests/archives, full history queries, aggregate forecasts; no history or registry mutation.')
```

```perl
use strict;use warnings;use JSON::PP;use Digest::SHA qw(sha256_hex);
my $MAX_LINES=512;my $MAX_BYTES=65536;my $code;
{open my $fh,'<:raw','tools/roll_document_history.pl' or die $!;local $/;$code=<$fh>}
my $extracted='';
for my $bounds (['sub split_current {','sub validate_preamble {'],['sub threshold_reached {','sub read_manifest {'],['sub segment_record {','sub usage {']) {
 my ($a,$b)=map {index($code,$_)} @$bounds;die 'subroutine source boundary' if $a<0||$b<$a;$extracted.=substr($code,$a,$b-$a)."\n";
}
eval $extracted;die $@ if $@;
my $expected;{open my $fh,'<:raw','.linkedspec-data/scratch/lua41/model.json' or die $!;local $/;$expected=JSON::PP->new->decode(<$fh>)}
my $json=JSON::PP->new->canonical->utf8;
for my $model (@$expected) {
 my $root=$model->{root};open my $git,'-|','git','show',"$model->{baseline}:$root" or die $!;binmode $git;my $raw=do {local $/;<$git>};close $git or die 'git source';
 my ($pre,$records)=split_current($raw,{boundary=>($root eq 'CHANGES.md'?qr/^## /m:qr/^(?:- 20[0-9]{2}-[0-9]{2}\b|## )/m),current=>$root});
 my @rolls;
 for my $i (1..57) {
  my $prefix="## Projected Lua evidence record $i\n\n";my @rows=("bounded evidence\n")x12;my $extra=2048-length($prefix)-length(join('',@rows));$rows[0]=('x'x$extra).$rows[0];my $new=$prefix.join('',@rows);
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
 print "PASS $id: 57 source-function simulations; ".scalar(@rolls)." exact rollovers; maximal future row $model->{manifest_row_byte_bound} bytes\n";
}
```

```python
from pathlib import Path
import json,contextlib,io,math,subprocess
# Reuse the exact committed-growth recipe; it verifies its fixed 52-commit digest.
card=Path('docs/knowledge/lua-startup-reading-coverage.md').read_text()
source=card.split("<<'LUA_COMPARABLE_READING_GROWTH'\n",1)[1].split('\nLUA_COMPARABLE_READING_GROWTH',1)[0]
ns={}
with contextlib.redirect_stdout(io.StringIO()):exec(compile(source,'LUA_COMPARABLE_READING_GROWTH','exec'),ns)
reference=ns['records'];units=57
reserve={}
for name,category in [('knowledge_cards','knowledge'),('task_evidence','tasks'),('knowledge_map','map')]:
 reserve[name]={metric:units*max(r['growth'][category][metric] for r in reference) for metric in ['lines','bytes']}
reserve['knowledge_cards']['files']=57;reserve['task_evidence']['files']=2
reserve['decisions']={'files':3,'lines':576,'bytes':49152}
models=json.loads(Path('.linkedspec-data/scratch/lua41/model.json').read_text());assert len(models)==2
for model in models:
 assert model['baseline']=='7f97cb630e7f5a64915df8febdab078b9d5be38e' and model['record_budget']==[57,14,2048]
 count=len(model['rollovers']);assert count==4
 reserve[model['surface']]={'files':count,'lines':57*14+count,'bytes':57*2048+count*model['manifest_row_byte_bound']}
registry=Path('doctrine/readme_stability/routes.jsonl')
assert registry.read_bytes()==subprocess.check_output(['git','show','7f97cb630e7f5a64915df8febdab078b9d5be38e:'+str(registry)])
rows=[json.loads(x) for x in registry.read_text().splitlines()]
report={}
for row in rows:
 name=row.get('id')
 if name not in reserve:continue
 limits=dict(row['limits']);overrides=dict(row['member_limits'])
 if name=='knowledge_cards':limits.update(max_total_lines=93000,max_total_bytes=7340032)
 if name=='task_evidence':limits.update(max_total_lines=92000,max_total_bytes=10485760)
 if name in ['change_history','engineering_notes']:
  model=next(m for m in models if m['surface']==name);limits=model['new_limits']
  manifest='docs/history/'+('changes' if name=='change_history' else 'development-notes')+'/manifest.jsonl'
  overrides[manifest]=model['new_manifest_limit'];raw=Path(manifest).read_bytes()
  assert raw.count(b'\n')+4<=overrides[manifest]['max_lines']
  assert len(raw)+4*model['manifest_row_byte_bound']<=overrides[manifest]['max_bytes']
 paths=sorted({p for pat in row['members'] for p in Path('.').glob(pat) if p.is_file()})
 assert all(not p.is_symlink() for p in paths)
 current={'files':len(paths),'lines':sum(p.read_bytes().count(b'\n') for p in paths),'bytes':sum(p.stat().st_size for p in paths)}
 projected={key:value+reserve[name].get(key,0) for key,value in current.items()}
 for key,value in projected.items():
  maximum=limits.get('max_'+key,limits.get('max_total_'+key))
  if maximum is not None:assert value<=maximum,(name,key,value,maximum)
 for p in paths:
  override=overrides.get(str(p),{});raw=p.read_bytes()
  for metric,value in [('lines',raw.count(b'\n')),('bytes',len(raw))]:
   maximum=override.get('max_'+metric,limits.get('max_'+metric+'_per_file',limits.get('max_'+metric)))
   assert value<=maximum,(str(p),metric,value,maximum)
 report[name]={'current':current,'reserve':reserve[name],'projected':projected,'proposed_limits':limits}
 print(name,json.dumps(report[name],sort_keys=True))
assert set(report)==set(reserve)
Path('.linkedspec-data/scratch/lua41/reserve.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS complete current-plus-57-unit reserve, both manifest projections and unchanged member controls; proposed objects only, registry unchanged.')
```
