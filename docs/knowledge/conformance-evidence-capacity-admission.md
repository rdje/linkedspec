---
id: conformance-evidence-capacity-admission
title: Approved finite conformance evidence capacity preserves reading and repair ownership
answers:
  - which capacity changes did the director grant for remaining conformance reading
  - how are the fourteen conformance capacity controls verified
  - how does the conformance capacity admission preserve old history
  - why does the admitted conformance forecast have 98 remaining units
  - does conformance capacity admission close the MethodExpr Deps observation repair
  - why did the conformance capacity admission require a checker mirror correction
  - how is the granted task partition checker correction verified
date: 2026-09-21
status: current; exact .15.1 checker correction explicitly granted and applied; canonical landing required
tags: [conformance, reading, capacity, history, verification]
evidence: "LIVE-DOCUMENT-PRESSURE-CONTAINMENT.15 implements the explicit Granted disposition under accepted indexed ADR0122 from clean 5fab5aa6. Exactly fourteen scalars change. Independent and production history models agree on seven further rollovers per collection across 98 allowance units after actual admission overhead. Production routing functions pass 156 threshold and 61 authorization executions. A separately granted exact checker mirror/test correction passes37 self-tests/50 registry cases; all other implementation, prior questions, repair scopes and immutable history remain exact. Ordinary staged canonical receipt is mandatory for landing; source reading remains 50/143 and repairs .2.5/.2.6 remain open."
reverify: "Replay the three fenced recipes below against the admission snapshot, using the project-data wrapper for Python; run both roll_document_history.pl --check surfaces, scripts/check_memory_architecture.sh, Knowledge generation, normal doctrines and the canonical gate required by COMMIT.md."
---

ADR0122 records the director's **Granted** answer to the exact proposal in
CONFORMANCE-SOURCE-READING.4.1, including bounded implementation before required
reading finishes. There is no canonical, hook or later push exception. Stable
registry responsibilities, hot-file/member limits and all unrelated fields stay
unchanged. `.4.2` and its capacity parent close through containment `.15` only
after verified landing; unread `.1.51` then resumes. The MethodExpr assertion
blind spot `.2.5` and six misleading EmitContext descriptions `.2.6` retain their
original acceptance and prerequisites; this admission does not fix them.

The preserved proposal charged all 99 units after its actual overhead. This
admission consumes one, leaving 98 forecast units after all actual admission
edits. Each applied rollover consumes one of eight archive slots, leaving seven.
The new ADR consumes the reserved decision member. No future decision expansion
is assumed. The remaining envelope covers 93 reading children and five support
allowances, not unlimited PNT work. Each real slice must remeasure its growth.

Changes segment4973 preserves 117 lines / 29,044 bytes, SHA-256
`a9bf2b28f0abf55e10f7078989d83720ea315a5f8cb6fb9a59ee6622c4140a85`.
Notes segment4972 preserves 89 lines / 28,550 bytes, SHA-256
`0e0508fa8d0bb93dc4b1a5186215fe0c8e6703ef2da269ca97566e5cf368eaeb`.
Both come from exact clean 5fab5aa6 suffixes. Older segment bytes and manifest
rows remain exact; reconstruction includes the current root as well as archives.
The proof checks every unaffected blob and 528 prior task nodes,
including the complete historical proposal, all 143 reading scopes and repairs.

The required rollover leaves an existing record-separator blank line at each
hot root's new EOF. Ordinary `git diff --check` flags those two boundaries;
trimming them would lose preserved bytes. Check these two roots with
`git -c core.whitespace=-blank-at-eof diff --check -- CHANGES.md DEVELOPMENT_NOTES.md`
and run ordinary diff checking on all other paths. No whitespace policy changes;
all non-EOF checks remain, and exact reconstruction proves the retained bytes.

## Reproduction

The first three recipes below include the granted checker correction and current
admission. The later historical draft section preserves the initial failure;
its unchanged-source and pending-approval statements describe that earlier state.
Use the applied-correction replay at the end for the current checker.

Run on the admission snapshot before later reading updates. Save the three
fences in order as `proof.py`, `production.pl`, and `validators.pl` beneath
`.linkedspec-data/scratch/conformance-capacity-admission/`. The first writes only
project-local proof JSON. Execute with `bash tools/project_data_run.sh python3`
and `perl`, respectively. The detached Perl probes extract unchanged production
functions; they mutate only in-memory fixtures, never repository authority.
The ordinary checker/doctrine and exact staged canonical gate complement these
bounded function probes; they are not replaced by them. Historical proposal
recipes remain verbatim in the task-tree, including their original baseline.

```python
from pathlib import Path
import subprocess,json,re,hashlib,os,copy
BASE='5fab5aa6dfdf0f52f9a9018aba2dc5cb7449e537';W=Path('.linkedspec-data/scratch/conformance-capacity-admission');W.mkdir(parents=True,exist_ok=True)
def git(*a):return subprocess.check_output(['git',*a])
def old(p):return git('show',BASE+':'+str(p))
def enc(x):return (json.dumps(x,sort_keys=True,separators=(',',':'))+'\n').encode()
def lc(x):return x.count(b'\n')+int(bool(x) and not x.endswith(b'\n'))
def split(x):
 starts=[m.start() for m in re.finditer(rb'(?m)^## ',x)];assert starts
 return x[:starts[0]],[x[a:b] for a,b in zip(starts,starts[1:]+[len(x)])]
def sha(x):return hashlib.sha256(x).hexdigest()
reg='doctrine/readme_stability/routes.jsonl';a=[json.loads(x) for x in old(reg).splitlines()];b=[json.loads(x) for x in Path(reg).read_bytes().splitlines()]
expected=[('change_history','limits','max_files',39,47),('engineering_notes','limits','max_files',35,43),('engineering_notes','limits','max_total_lines',28000,29000),('engineering_notes','limits','max_total_bytes',3145728,3407872),('knowledge_cards','limits','max_files',1152,1350),('knowledge_cards','limits','max_total_lines',93000,108000),('knowledge_cards','limits','max_total_bytes',7340032,8388608),('knowledge_map','limits','max_lines',20000,22500),('task_evidence','limits','max_total_lines',92000,120000),('task_evidence','limits','max_total_bytes',10485760,12582912)]
for sid,family,ol,nl,ob,nb in [('change_history','changes',38,46,21647,26255),('engineering_notes','development-notes',34,42,20514,25410)]:
 path='docs/history/'+family+'/manifest.jsonl';expected.extend([(sid,path,'max_lines',ol,nl),(sid,path,'max_bytes',ob,nb)])
wanted=copy.deepcopy(a)
for sid,path,key,ov,nv in expected:
 row=next(r for r in wanted if r.get('id')==sid);obj=row['limits'] if path=='limits' else row['member_limits'][path];assert obj[key]==ov;obj[key]=nv
assert wanted==b and len(expected)==14
allow=set('scripts/check_task_tree_partitions.pl docs/knowledge/task-partition-capacity-registry-drift.md CHANGES.md DEVELOPMENT_NOTES.md KNOWLEDGE_MAP.md LIVE_ACHIEVEMENT_STATUS.md MEMORY.md ROADMAP.md ROADMAP_V2.md docs/TASK_TREE.md docs/tasks/CONFORMANCE-SOURCE-READING.md docs/tasks/SESSION-STARTUP-READING.md docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md docs/knowledge/conformance-source-reading-coverage.md docs/linkedspec-book/src/overview/project-status.md docs/decisions/INDEX.md doctrine/readme_stability/routes.jsonl docs/history/changes/manifest.jsonl docs/history/development-notes/manifest.jsonl'.split())
new_allow={'docs/decisions/0122-approved-conformance-evidence-capacity.md','docs/knowledge/conformance-evidence-capacity-admission.md'}
models=[];histories={}
for sid,root,family,rowbound in [('change_history','CHANGES.md','changes',576),('engineering_notes','DEVELOPMENT_NOTES.md','development-notes',612)]:
 mp='docs/history/'+family+'/manifest.jsonl';om=[json.loads(x) for x in old(mp).splitlines()];nm=[json.loads(x) for x in Path(mp).read_bytes().splitlines()]
 assert nm[2:]==om[1:] and nm[0]==dict(om[0],segment_count=om[0]['segment_count']+1)
 assert Path(mp).read_bytes().splitlines()[2:]==old(mp).splitlines()[1:]
 added=nm[1];assert added['source_commit']==BASE;new_allow.add(added['target_path'])
 archived=Path(added['target_path']).read_bytes();assert sha(archived)==added['sha256'] and lc(archived)==added['line_count'] and len(archived)==added['byte_count']
 oldroot=old(root);newroot=Path(root).read_bytes();op,orecs=split(oldroot);np,nrecs=split(newroot)
 assert op==np and oldroot==np+b''.join(nrecs[1:])+archived
 assert lc(nrecs[0])<=14 and len(nrecs[0])<=2048
 assert b''.join(oldroot.splitlines(keepends=True)[added['source_start_line']-1:added['source_end_line']])==archived
 assert git('rev-parse',BASE+':'+root).decode().strip()==added['source_blob']
 query=b''.join(Path(r['target_path']).read_bytes() for r in nm[1:]);actual=subprocess.check_output(['perl','tools/read_document_history.pl','--surface',sid,'--all']);assert actual.endswith(query)
 assert newroot+query==op+nrecs[0]+b''.join(orecs)+b''.join(Path(r['target_path']).read_bytes() for r in om[1:])
 records=list(nrecs);rolls=[];allnew=[];archive=b''
 for i in range(1,99):
  prefix=('## Projected conformance evidence record '+str(i)+'\n\n').encode();rows=[b'bounded evidence\n']*12;rows[0]=b'x'*(2048-len(prefix)-sum(map(len,rows)))+rows[0];entry=prefix+b''.join(rows);assert lc(entry)==14 and len(entry)==2048
  allnew.insert(0,entry);records.insert(0,entry);candidate=np+b''.join(records)
  if lc(candidate)*100>=512*90 or len(candidate)*100>=65536*90:
   keep=len(records)
   while keep>1 and (lc(np+b''.join(records[:keep]))*100>512*50 or len(np+b''.join(records[:keep]))*100>65536*50):keep-=1
   retained=np+b''.join(records[:keep]);chunk=b''.join(records[keep:]);archive=chunk+archive
   rolls.append(dict(after_record=i,candidate=[lc(candidate),len(candidate)],retained=[lc(retained),len(retained)],archived=[lc(chunk),len(chunk)]));records=records[:keep]
  assert np+b''.join(allnew)+b''.join(nrecs)==np+b''.join(records)+archive
 assert len(rolls)<=7,(sid,len(rolls));histories[sid]=dict(segment=added['segment_id'],lines=lc(archived),bytes=len(archived),sha256=sha(archived),future_rollovers=len(rolls))
 models.append(dict(surface=sid,root=root,source_hex=newroot.hex(),rollovers=rolls,manifest_row_byte_bound=rowbound,remaining_units=98))
# The separately granted source correction must be exactly the reviewed numeric mirror diff.
checker='scripts/check_task_tree_partitions.pl';original=old(checker);expected_source=original.decode()
for ov,nv,count in [('92_000','120_000',5),('92_001','120_001',2),('92,000','120,000',3),('10_485_760','12_582_912',5),('10_485_761','12_582_913',2),('10,485,760','12,582,912',3)]:
 assert expected_source.count(ov)==count;expected_source=expected_source.replace(ov,nv)
assert sha(original)=='9f4e5c1a3f268fc8364e6430583a8df58a522cd9c12bc24575d11181758a0206'
assert Path(checker).read_bytes()==expected_source.encode() and sha(expected_source.encode())=='cb9dd627bb5d657d0fc504b611cd25b377e2b9b3b6602f352680bf3c635cd9e9'
card='docs/knowledge/task-partition-capacity-registry-drift.md';before=old(card).decode();after=Path(card).read_text()
assert after.split('---\n',2)[2].endswith(before.split('---\n',2)[2])
assert before.split('answers:\n',1)[1].split('date:',1)[0]==after.split('answers:\n',1)[1].split('date:',1)[0]
# Census every unaffected tracked blob without entering the dependency gitlink.
count=size=0
for row in git('ls-tree','-rz',BASE).split(b'\0'):
 if not row:continue
 meta,path=row.split(b'\t',1);mode,kind,oid=meta.split();path=os.fsdecode(path)
 if kind!=b'blob' or path in allow:continue
 p=Path(path);assert p.lstat().st_dev==Path('.').stat().st_dev
 raw=os.fsencode(os.readlink(p)) if mode==b'120000' else p.read_bytes()
 assert hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()==oid.decode(),path
 if mode in [b'100644',b'100755']:assert bool(p.stat().st_mode&0o111)==(mode==b'100755'),path
 count+=1;size+=len(raw)
changed=set(git('diff',BASE,'--name-only').decode().splitlines())|set(git('ls-files','--others','--exclude-standard').decode().splitlines());assert changed<=allow|new_allow,changed-allow-new_allow
assert git('ls-tree',BASE,'--','rgx')==git('ls-tree','HEAD','--','rgx')
pat=r'^- ID: `([^`]+)`\n(.*?)(?=^- ID: |^## |\Z)';preserved=0
for tree,mutable,newids in [('CONFORMANCE-SOURCE-READING',{'CONFORMANCE-SOURCE-READING.4','CONFORMANCE-SOURCE-READING.4.2'},set()),('SESSION-STARTUP-READING',{'SESSION-STARTUP-READING.3.8'},set()),('LIVE-DOCUMENT-PRESSURE-CONTAINMENT',{'LIVE-DOCUMENT-PRESSURE-CONTAINMENT'},{'LIVE-DOCUMENT-PRESSURE-CONTAINMENT.15','LIVE-DOCUMENT-PRESSURE-CONTAINMENT.15.1'})]:
 path='docs/tasks/'+tree+'.md';before=dict(re.findall(pat,old(path).decode(),re.M|re.S));after=dict(re.findall(pat,Path(path).read_text(),re.M|re.S));assert set(after)-set(before)==newids and not set(before)-set(after)
 for sid,body in before.items():
  if sid not in mutable:assert after[sid]==body,sid;preserved+=1
path='docs/tasks/CONFORMANCE-SOURCE-READING.md';before=old(path).decode();after=Path(path).read_text();start='## Remaining-reading capacity proposal';end='## Current Frontier';assert before.split(start,1)[1].split(end,1)[0]==after.split(start,1)[1].split(end,1)[0]
path='docs/knowledge/conformance-source-reading-coverage.md';assert old(path).split(b'## Remaining-reading evidence capacity')[0]==Path(path).read_bytes().split(b'## Remaining-reading evidence capacity')[0]
path='LIVE_ACHIEVEMENT_STATUS.md';assert old(path).split(b'## History\n')[1]==Path(path).read_bytes().split(b'## History\n')[1]
# Actual resulting candidate plus remaining 98-unit allowance, no double-counted archive slot or ADR.
reserve={'knowledge_cards':dict(files=196,lines=98*158,bytes=98*11634),'knowledge_map':dict(lines=98*28,bytes=98*9624),'task_evidence':dict(files=8,lines=98*262,bytes=98*19416),'decisions':dict(files=0,lines=0,bytes=0)}
for m in models:reserve[m['surface']]=dict(files=7,lines=98*14+7,bytes=98*2048+7*m['manifest_row_byte_bound'])
report={}
for r in b:
 sid=r.get('id')
 if sid not in reserve:continue
 paths=sorted({p for pattern in r['members'] for p in Path('.').glob(pattern) if p.is_file()});assert all(not p.is_symlink() for p in paths)
 current=dict(files=len(paths),lines=sum(lc(p.read_bytes()) for p in paths),bytes=sum(p.stat().st_size for p in paths));projected={k:v+reserve[sid].get(k,0) for k,v in current.items()}
 for key,v in projected.items():
  cap=r['limits'].get('max_'+key,r['limits'].get('max_total_'+key));assert cap is None or v<=cap,(sid,key,v,cap)
 for p in paths:
  cap=r['member_limits'].get(str(p),{});raw=p.read_bytes()
  for key,v in [('lines',lc(raw)),('bytes',len(raw))]:
   maximum=cap.get('max_'+key,r['limits'].get('max_'+key+'_per_file',r['limits'].get('max_'+key)));assert maximum is None or v<=maximum,(str(p),key,v,maximum)
  if str(p).endswith('/manifest.jsonl'):
   m=next(x for x in models if x['surface']==sid);assert lc(raw)+7<=cap['max_lines'] and len(raw)+7*m['manifest_row_byte_bound']<=cap['max_bytes']
 report[sid]=dict(current=current,reserve=reserve[sid],projected=projected)
assert set(report)==set(reserve)
result=dict(status='PASS',base=BASE,scalars=14,unmodified_blobs=count,unmodified_bytes=size,preserved_prior_task_nodes=preserved,history=histories,forecast=report)
(W/'proof.json').write_text(json.dumps(result,indent=2)+'\n');(W/'models.json').write_text(json.dumps(models,indent=2)+'\n');print(json.dumps(result,indent=2))
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
my $expected;{open my $fh,'<:raw','.linkedspec-data/scratch/conformance-capacity-admission/models.json' or die $!;local $/;$expected=JSON::PP->new->decode(<$fh>)}
my $json=JSON::PP->new->canonical->utf8;
for my $model (@$expected) {
 my $root=$model->{root};my $raw=pack('H*',$model->{source_hex});
 my ($pre,$records)=split_current($raw,{boundary=>($root eq 'CHANGES.md'?qr/^## /m:qr/^(?:- 20[0-9]{2}-[0-9]{2}\b|## )/m),current=>$root});
 my @rolls;
 for my $i (1..98) {
  my $prefix="## Projected conformance evidence record $i\n\n";my @rows=("bounded evidence\n")x12;my $extra=2048-length($prefix)-length(join('',@rows));$rows[0]=('x'x$extra).$rows[0];my $new=$prefix.join('',@rows);
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
 print "PASS $id: 98 source-function simulations; ".scalar(@rolls)." exact rollovers; maximal future row $model->{manifest_row_byte_bound} bytes\n";
}
```

```perl
use strict;use warnings;use JSON::PP;
my $JSON=JSON::PP->new->canonical;my $REGISTRY_PATH='doctrine/readme_stability/routes.jsonl';
my $BASE='5fab5aa6dfdf0f52f9a9018aba2dc5cb7449e537';my @ids=qw(change_history engineering_notes knowledge_cards knowledge_map task_evidence);
sub read_bytes {my($p)=@_;open my $f,'<:raw',$p or die $!;local $/;return <$f>}
my $src=read_bytes('scripts/check_readme_routing_pressure.pl');my $code='';
for my $name(qw(exceeds_limits canonical_object numeric_increase limit_change_permitted debt_retirement_permitted adr_authorizes_limit_change adr_authorizes_contract_change validate_registry_governance)) {
 my($fn)=$src=~/(^sub \Q$name\E \{.*?^\})/ms;die "missing $name" unless defined $fn;$code.=$fn."\n";
}
open my $git,'-|','git','show',"$BASE:$REGISTRY_PATH" or die $!;my $head=do {local $/;<$git>};close $git or die 'Git baseline';
my %want=map {$_=>1} @ids;my %old=map {$_->{id}=>$_} grep {$want{$_->{id}//''}} map {$JSON->decode($_)} split /\n/,$head;
my %new=map {$_->{id}=>$_} grep {$want{$_->{id}//''}} map {$JSON->decode($_)} split /\n/,read_bytes($REGISTRY_PATH);
my $adr='docs/decisions/0122-approved-conformance-evidence-capacity.md';my %files=map {$_=>read_bytes($_)} ($adr,'docs/decisions/INDEX.md');my @new_adrs=($adr);
sub snapshot_content {return $files{$_[0]}}
sub staged_new_adrs {return @new_adrs}
sub head_content {die 'unexpected head path' unless $_[0] eq $REGISTRY_PATH;return $head}
sub decode_registry {return ([map {$JSON->decode($_)} split /\n/,$_[0]],[])}
eval($code."\n1;") or die $@;my $thresholds=0;
for my $id(@ids) {
 my $r=$new{$id};my @objects=([$r->{limits},'collection']);push @objects,map {[$r->{member_limits}{$_},$_]} sort keys %{$r->{member_limits}};
 for my $object(@objects) {my($limits,$label)=@$object;
  for my $key(sort keys %$limits) {for my $offset(-1,0,1) {
   my $m={files=>0,lines=>0,bytes=>0,members=>['member.md'],per_file=>{'member.md'=>{lines=>0,bytes=>0}}};my $value=$limits->{$key}+$offset;
   if($key=~/^max_(lines|bytes)_per_file$/){$m->{per_file}{'member.md'}{$1}=$value}
   elsif($key=~/^max_(?:total_)?(lines|bytes|files)$/){$m->{$1}=$value}else{die "unhandled $key"}
   my @errors=exceeds_limits($m,$limits);die "$id $label $key $offset: @errors" unless @errors==($offset==1?1:0);++$thresholds;
  }}
 }
}
my $original=$JSON->decode($JSON->encode(\%files));my $authorizations=0;
sub auth_case {
 my($label,$mutate,$expected)=@_;%files=%$original;@new_adrs=($adr);my $surfaces=$JSON->decode($JSON->encode([map {$new{$_}} @ids]));$mutate->($surfaces);
 my @errors=validate_registry_governance($surfaces);die "$label: @errors" unless @errors==$expected;++$authorizations;
}
auth_case('exact approved indexed ADR',sub {},0);
auth_case('no new ADR',sub {@new_adrs=()},7);
auth_case('missing ADR body',sub {delete $files{$adr}},7);
auth_case('missing index row',sub {$files{'docs/decisions/INDEX.md'}=''},7);
for my $id(@ids) {
 my $history=$id eq 'change_history'||$id eq 'engineering_notes';
 auth_case("$id wrong surface",sub {$files{$adr}=~s/^- Routed surface: \x60\Q$id\E\x60$/- Routed surface: \x60unapproved\x60/m},$history?2:1);
 for my $kind($history?qw(limits contract):('limits')) {for my $which(qw(Previous New)) {
  my $r=$which eq 'Previous'?$old{$id}:$new{$id};my $value=$r->{limits};
  if($kind eq 'contract') {$value={map {$_=>$r->{$_}} qw(authority control lifecycle member_limits members owner route_targets state verifier)};$value->{transition_owners}=$r->{transition}{owners}}
  my $literal="- $which routed $kind: \x60".$JSON->encode($value)."\x60";
  auth_case("$id altered $which $kind",sub {die 'literal missing' unless index($files{$adr},$literal)>=0;$files{$adr}=~s/\Q$literal\E/$literal extra/},1);
 }}
 for my $key(sort keys %{$new{$id}{limits}}) {auth_case("$id unapproved $key",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;++$r->{limits}{$key}},1)}
 auth_case("$id unapproved owner",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;$r->{owner}='unapproved'},1);
 auth_case("$id unapproved member",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;$r->{member_limits}{'member.md'}={max_lines=>999,max_bytes=>99999}},1);
 if($history) {for my $key(qw(max_lines max_bytes)) {auth_case("$id unapproved manifest $key",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;my($path)=grep {/manifest/} keys %{$r->{member_limits}};++$r->{member_limits}{$path}{$key}},1)}
  auth_case("$id unapproved root",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;my($path)=grep {!/manifest/} keys %{$r->{member_limits}};++$r->{member_limits}{$path}{max_lines}},1);
 }
}
print "PASS $thresholds actual threshold and $authorizations actual authorization executions; detached inputs only.\n";
```


## Historical admission blocker and prepared mirror correction — 2026-09-21

Canonical verification of staged fingerprint
`c8f6695f16fee2296f64b76952fc8c4d2ed44da474a91741e5f93d12db6ab575`
reports four task-registry boundary disagreements. The registry change is
approved, but the existing partition checker still deliberately mirrors 92,000
lines /10,485,760 bytes. Its agreement guard correctly rejects the candidate.
The original data-only proposal omitted this required enforcing-consumer update;
its routing-only proof did not establish agreement of every capacity consumer.
No admission is complete and no canonical pass or receipt is claimed.

Containment `.15.1` owns the correction. The concrete draft below changes only
the two mirrored aggregate limits, associated messages and boundary fixtures to
the already-approved 120,000 lines /12,582,912 bytes. The guard, 128-file and
all member controls remain. Production checker SHA-256 is
`9f4e5c1a3f268fc8364e6430583a8df58a522cd9c12bc24575d11181758a0206`;
draft SHA-256 is
`cb9dd627bb5d657d0fc504b611cd25b377e2b9b3b6602f352680bf3c635cd9e9`.
Syntax, all37 unchanged self-tests and50 detached registry malformed/drift cases
pass. Actual functions report four disagreements before and zero with the draft.
The production source is unchanged. Applying this source correction before full
reading needs explicit extension of the data-only grant; ordinary canonical CI
and normal hooks remain required after application. No further registry increase.

```diff
--- a/scripts/check_task_tree_partitions.pl
+++ b/scripts/check_task_tree_partitions.pl
@@ -224,2 +224,2 @@
-    push @errors, 'task collection exceeds 92,000 lines' if $lines > 92_000;
-    push @errors, 'task collection exceeds 10,485,760 bytes' if $bytes > 10_485_760;
+    push @errors, 'task collection exceeds 120,000 lines' if $lines > 120_000;
+    push @errors, 'task collection exceeds 12,582,912 bytes' if $bytes > 12_582_912;
@@ -431 +431 @@
-            max_files => 128, max_total_lines => 92_000, max_total_bytes => 10_485_760,
+            max_files => 128, max_total_lines => 120_000, max_total_bytes => 12_582_912,
@@ -468 +468 @@
-            return same_strings([collection_total_errors(128, 92_000, 10_485_760)], [])
+            return same_strings([collection_total_errors(128, 120_000, 12_582_912)], [])
@@ -472 +472 @@
-            return same_strings([collection_total_errors(129, 92_000, 10_485_760)],
+            return same_strings([collection_total_errors(129, 120_000, 12_582_912)],
@@ -476,2 +476,2 @@
-            return same_strings([collection_total_errors(128, 92_001, 10_485_760)],
-                ['task collection exceeds 92,000 lines']);
+            return same_strings([collection_total_errors(128, 120_001, 12_582_912)],
+                ['task collection exceeds 120,000 lines']);
@@ -480,2 +480,2 @@
-            return same_strings([collection_total_errors(128, 92_000, 10_485_761)],
-                ['task collection exceeds 10,485,760 bytes']);
+            return same_strings([collection_total_errors(128, 120_000, 12_582_913)],
+                ['task collection exceeds 12,582,912 bytes']);
@@ -492,3 +492,3 @@
-            return same_strings([collection_total_errors(129, 92_001, 10_485_761)],
-                ['task collection exceeds 128 files', 'task collection exceeds 92,000 lines',
-                 'task collection exceeds 10,485,760 bytes'])
+            return same_strings([collection_total_errors(129, 120_001, 12_582_913)],
+                ['task collection exceeds 128 files', 'task collection exceeds 120,000 lines',
+                 'task collection exceeds 12,582,912 bytes'])
```

Reproduce in managed scratch: replace the six exact numeric spellings in the
production checker (`92_000`, `92_001`, `92,000`, `10_485_760`, `10_485_761`,
`10,485,760`) with (`120_000`, `120_001`, `120,000`, `12_582_912`, `12_582_913`,
`12,582,912`). Require replacement counts5/2/3/5/2/3, verify both SHA-256 values
above, save as `partition-checker.proposed.pl` below the admission scratch root
and run `perl -c`. Then execute this detached production-function proof through
`bash tools/project_data_run.sh env PERL5LIB= perl`; it changes no tracked source.

```perl
use strict;
use warnings;
use JSON::PP;
use Digest::SHA qw(sha256_hex);
my $json=JSON::PP->new->canonical;
sub read_raw {my($p)=@_;open my $f,'<:raw',$p or die "$p: $!";local $/;my $b=<$f>;close $f or die $!;return $b}
my $old=read_raw('scripts/check_task_tree_partitions.pl');
my $new=read_raw('.linkedspec-data/scratch/conformance-capacity-admission/partition-checker.proposed.pl');
my $helper='';
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
```


## Granted and applied correction — 2026-09-21

The director answered **Granted** to the exact `.15.1` correction and its
before-reading execution. ADR0122 records this narrow extension; the fourteen
registry transitions stay unchanged. The applied checker matches the reviewed
`cb9dd627bb5d657d0fc504b611cd25b377e2b9b3b6602f352680bf3c635cd9e9`
bytes exactly. It passes syntax,37 self-tests,50 detached malformed/drift cases
and the actual partition gate. The guard and all member/file controls remain.
The correction is inseparable from this admission; it consumes no additional
history record or reserve unit. Preserve the failed candidate log as
`.linkedspec-data/scratch/conformance-capacity-admission/canonical-mirror-failure.log`;
its SHA-256 is22760a6cd522684e9ec9656268842efe06af2397aa44868376852120e3f6c748.
Fresh exact staged canonical proof is required before the atomic commit.

This replay reconstructs the old checker from clean Git and reuses the historical
37/50-case function probe with the actual applied source. It changes only scratch:

```python
from pathlib import Path
import subprocess,re,hashlib
w=Path('.linkedspec-data/scratch/conformance-capacity-admission');w.mkdir(parents=True,exist_ok=True)
original=subprocess.check_output(['git','show','5fab5aa6dfdf0f52f9a9018aba2dc5cb7449e537:scripts/check_task_tree_partitions.pl'])
assert hashlib.sha256(original).hexdigest()=='9f4e5c1a3f268fc8364e6430583a8df58a522cd9c12bc24575d11181758a0206'
assert hashlib.sha256(Path('scripts/check_task_tree_partitions.pl').read_bytes()).hexdigest()=='cb9dd627bb5d657d0fc504b611cd25b377e2b9b3b6602f352680bf3c635cd9e9'
(w/'partition-original.pl').write_bytes(original)
card=Path('docs/knowledge/conformance-evidence-capacity-admission.md').read_text()
blocks=re.findall(r'^```perl\n(.*?)^```',card,re.M|re.S);assert len(blocks)==3
proof=blocks[-1].replace("my $old=read_raw('scripts/check_task_tree_partitions.pl');", "my $old=read_raw('.linkedspec-data/scratch/conformance-capacity-admission/partition-original.pl');")
proof=proof.replace("my $new=read_raw('.linkedspec-data/scratch/conformance-capacity-admission/partition-checker.proposed.pl');", "my $new=read_raw('scripts/check_task_tree_partitions.pl');")
(w/'partition-applied-proof.pl').write_text(proof)
subprocess.run(['perl',str(w/'partition-applied-proof.pl')],check=True)
```
