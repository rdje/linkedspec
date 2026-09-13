---
id: lua-reading-evidence-capacity-admission
title: Approved Lua reading capacity preserves evidence and verification boundaries
answers:
  - which Lua evidence capacity limits are approved
  - how do I reverify containment 14 admission
  - which verification exception applies to containment 14
  - does the complete Lua reading reserve fit the approved limits
  - were earlier source and history bytes preserved by Lua capacity admission
date: 2026-09-12
status: admitted under explicit ADR0118 approval; source reading remains pending
tags: [lua, capacity, history, knowledge, verification, continuity]
evidence: "The director answered Granted to all eleven controls and the .14-only focused/receipt exception, including this bounded implementation before full codebase reading. ADR0118 records exact authority; previous proposal bytes and every other control remain unchanged."
reverify:
  - "Save and run the three fenced recipes in order through tools/project_data_run.sh; outputs stay under repository-managed scratch."
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md for exact source identity."
---

# Approved capacity

ADR0118 accepts the complete proposal at `b4ec6d39f`. Exactly eleven scalars change:
Knowledge aggregate lines 79,000→93,000 and bytes 6,291,456→7,340,032;
task aggregate lines 88,000→92,000 and bytes 9,437,184→10,485,760;
change-history files 36→38, manifest lines 35→37 and bytes 19,919→21,071;
engineering-note files 32→34, aggregate lines 27,000→28,000, manifest lines
31→33 and bytes 18,678→19,902. All other controls and responsibility remain.

The explicit focused-verification exception applies only to containment .14,
including before-reading implementation. Normal hooks remain enabled; later
milestone, repair and push proof still apply. No PGEN/RGX build, canonical CI,
receipt, source reading or runtime repair is claimed by this admission.

The finite 57-unit envelope covers all 51 Lua reading children and six support
slots. Full admission overhead is counted before charging the entire reserve
again. Models are a forecast, not a guarantee about unknown findings or an
allowance for later supporting code and repairs. Check every actual candidate.

# Preservation and independent proof

The first replay selects this admission's unique commit after landing, so dated
preservation and reserve evidence do not mistake later legitimate reading work
for admission drift. It verifies exact eleven-scalar objects and untouched rows,
prior source/cards/decisions/task/history bytes, full ordered archive queries,
existing question rows and all resulting member limits. The proposal node and
card remain exact. No historical or public source is discarded to obtain room.

It independently simulates 57 new 14-line / 2,048-byte records starting from the
actual admission roots, reconstructing every byte at every step. Four rollovers
per collection fit the approved slots and manifest rows. The second replay uses
the unchanged production split/threshold/prefix/segment functions to compare all
boundaries and maximum manifest row widths against those actual-candidate models.

The third replay executes the unchanged production routing validator on detached
metrics and snapshots: 125 threshold cases and 54 authorization cases. Inclusive
limits, independent/simultaneous excesses, every existing member override, exact
new authority, missing/altered authority and unauthorized limits/contracts are
covered. Normal doctrines also validate the complete real staged candidate.
The initial harness total expected 70 and omitted 11 existing task-part overrides
from its arithmetic. Those 55 extra cases had executed successfully; the exact
count was corrected to 125 without changing a validator, limit or test predicate.

# Exact admission, history and reserve replay

Run each recipe from a repository-managed scratch file with
`bash tools/project_data_run.sh python3 <path>` or `perl <path>`. The first writes
`.linkedspec-data/scratch/lua14/history-model.json` for the second. All substantive
inputs are tracked; this scratch output can be regenerated after session loss.

```python
from pathlib import Path
import subprocess,json,re,copy,hashlib,fnmatch
BASE='b4ec6d39fb1e58bf3d8513f8c03d57b289ba15f6'
SUBJECT='LIVE-DOCUMENT-PRESSURE-CONTAINMENT.14 - admit approved Lua reading evidence capacity'
REGISTRY='doctrine/readme_stability/routes.jsonl'
def git(*args):return subprocess.check_output(['git',*args])
def sha(raw):return hashlib.sha256(raw).hexdigest()
def lc(raw):return raw.count(b'\n')+int(bool(raw) and not raw.endswith(b'\n'))
commits=[r.split('\t')[0] for r in git('log','--format=%H%x09%s','--fixed-strings','--grep='+SUBJECT).decode().splitlines() if r.split('\t',1)[1]==SUBJECT]
assert len(commits)<=1
SNAP=commits[0] if commits else None
assert SNAP or git('rev-parse','HEAD').decode().strip()==BASE
if SNAP:assert git('rev-parse',SNAP+'^').decode().strip()==BASE
def old(p):return git('show',BASE+':'+p)
def snap(p):return git('show',SNAP+':'+p) if SNAP else Path(p).read_bytes()
before=[json.loads(x) for x in old(REGISTRY).splitlines()]
after=[json.loads(x) for x in snap(REGISTRY).splitlines()];expected=copy.deepcopy(before)
for row in expected:
 name=row.get('id')
 if name=='knowledge_cards':row['limits'].update(max_total_lines=93000,max_total_bytes=7340032)
 if name=='task_evidence':row['limits'].update(max_total_lines=92000,max_total_bytes=10485760)
 if name in ['change_history','engineering_notes']:
  changes=name=='change_history';family='changes' if changes else 'development-notes'
  row['limits']['max_files']=38 if changes else 34
  if not changes:row['limits']['max_total_lines']=28000
  row['member_limits']['docs/history/'+family+'/manifest.jsonl'].update(max_lines=37 if changes else 33,max_bytes=21071 if changes else 19902)
assert after==expected
changed=[]
def differences(a,b,path=()):
 if isinstance(a,dict):
  assert a.keys()==b.keys()
  for key in a:differences(a[key],b[key],path+(key,))
 elif isinstance(a,list):
  assert len(a)==len(b)
  for i,(x,y) in enumerate(zip(a,b)):differences(x,y,path+(str(i),))
 elif a!=b:changed.append((path,a,b))
differences(before,after);assert len(changed)==11
for a,b in zip(old(REGISTRY).splitlines(True),snap(REGISTRY).splitlines(True)):
 if json.loads(a).get('id') not in ['knowledge_cards','task_evidence','change_history','engineering_notes']:assert a==b
# Batch-load immutable baseline inputs; after landing use the dated admission snapshot.
paths=git('ls-tree','-r','--name-only',BASE,'--','docs/tasks','docs/knowledge','docs/decisions','docs/history','lua','julia','dart','perl','rust','tools','scripts','.githooks').decode().splitlines()
paths=[p for p in paths if not Path(p).is_dir()]
raw=subprocess.check_output(['git','cat-file','--batch'],input=''.join(BASE+':'+p+'\n' for p in paths).encode());prior={};offset=0
for p in paths:
 end=raw.index(b'\n',offset);_,kind,size=raw[offset:end].split();size=int(size);assert kind==b'blob'
 prior[p]=raw[end+1:end+1+size];offset=end+size+2
assert offset==len(raw)
allowed={'LIVE-DOCUMENT-PRESSURE-CONTAINMENT','LIVE-DOCUMENT-PRESSURE-CONTAINMENT.14','LUA-STARTUP-READING.4','LUA-STARTUP-READING.4.2','SESSION-STARTUP-READING.3.6'}
def nodes(raw):return dict(re.findall(r'^- ID: `([^`]+)`\n(.*?)(?=^- ID: |^## |\Z)',raw.decode(),re.M|re.S))
kept_files=kept_nodes=0
for p,raw in prior.items():
 if p.startswith('docs/tasks/') and p.endswith('.md'):
  now=nodes(snap(p))
  for key,body in nodes(raw).items():
   if key not in allowed:assert now.get(key)==body,(p,key);kept_nodes+=1
 elif p!='docs/decisions/INDEX.md':assert snap(p)==raw,p;kept_files+=1
index='docs/decisions/INDEX.md';row=b'| [0118](0118-approved-lua-reading-evidence-capacity.md) | Admit eleven finite Lua reading evidence controls under explicit approval and a .14-only focused exception | 2026-09-12 | accepted | lua, capacity, knowledge, history, verification |\n\n'
assert snap(index).replace(row,b'',1)==old(index)
for p in ['CHANGES.md','DEVELOPMENT_NOTES.md']:
 raw=old(p);assert snap(p).endswith(raw[re.search(rb'^## ',raw,re.M).start():]),p
p='LIVE_ACHIEVEMENT_STATUS.md';assert snap(p).split(b'## History\n')[1]==old(p).split(b'## History\n')[1]
questions=lambda b:{r for r in b.splitlines() if r.startswith(b'- "')}
assert questions(old('KNOWLEDGE_MAP.md'))<=questions(snap('KNOWLEDGE_MAP.md'))
# Independent 57-record simulation from the actual candidate, preserving every byte.
models=[]
for name,root,family in [('change_history','CHANGES.md','changes'),('engineering_notes','DEVELOPMENT_NOTES.md','development-notes')]:
 source=snap(root);starts=[m.start() for m in re.finditer(rb'^## ',source,re.M)];pre=source[:starts[0]]
 records=[source[a:b] for a,b in zip(starts,starts[1:]+[len(source)])];original=b''.join(records);future=[];archived=b'';rollovers=[]
 for i in range(1,58):
  prefix=('## Projected Lua evidence record '+str(i)+'\n\n').encode();rows=[b'bounded evidence\n']*12;rows[0]=b'x'*(2048-len(prefix)-sum(map(len,rows)))+rows[0]
  added=prefix+b''.join(rows);assert lc(added)==14 and len(added)==2048
  previous=pre+b''.join(records);records.insert(0,added);future.insert(0,added);candidate=pre+b''.join(records)
  if lc(candidate)*100>=512*90 or len(candidate)*100>=65536*90:
   keep=len(records)
   while keep>1 and (lc(pre+b''.join(records[:keep]))*100>512*50 or len(pre+b''.join(records[:keep]))*100>65536*50):keep-=1
   retained=pre+b''.join(records[:keep]);part=b''.join(records[keep:]);assert part and previous.endswith(part)
   rollovers.append({'after_record':i,'candidate':[lc(candidate),len(candidate)],'retained':[lc(retained),len(retained)],'archived':[lc(part),len(part)]})
   archived=part+archived;records=records[:keep]
  assert pre+b''.join(future)+original==pre+b''.join(records)+archived
 assert len(rollovers)==4
 manifest='docs/history/'+family+'/manifest.jsonl';rows=[json.loads(x) for x in snap(manifest).splitlines()]
 archived_query=b''
 for row in rows[1:]:
  part=snap(row['target_path']);assert (lc(part),len(part),sha(part))==(row['line_count'],row['byte_count'],row['sha256']);archived_query+=part
 current_query=subprocess.check_output(['perl','tools/read_document_history.pl','--surface',name,'--all']);assert current_query.endswith(archived_query)
 model={'surface':name,'root':root,'source_hex':source.hex(),'rollovers':rollovers,'manifest_row_byte_bound':576 if name=='change_history' else 612}
 models.append(model);print(name,'rollovers',[r['after_record'] for r in rollovers],'archive',[lc(archived_query),len(archived_query),sha(archived_query)])
# Entire reserve is charged after actual admission overhead, including decisions and map.
reserve={'knowledge_cards':{'files':57,'lines':18012,'bytes':1007418},'task_evidence':{'files':2,'lines':5985,'bytes':603801},'knowledge_map':{'lines':912,'bytes':205542},'decisions':{'files':3,'lines':576,'bytes':49152},'change_history':{'files':4,'lines':802,'bytes':119040},'engineering_notes':{'files':4,'lines':802,'bytes':119184}}
all_paths=git('ls-tree','-r','--name-only',SNAP).decode().splitlines() if SNAP else None
for row in after:
 name=row.get('id')
 if name not in reserve:continue
 paths=sorted({p for p in all_paths if any(fnmatch.fnmatchcase(p,pat) for pat in row['members'])}) if SNAP else sorted({str(p) for pat in row['members'] for p in Path('.').glob(pat) if p.is_file()})
 values={p:snap(p) for p in paths};current={'files':len(paths),'lines':sum(map(lc,values.values())),'bytes':sum(map(len,values.values()))};limits=row['limits']
 projected={k:v+reserve[name].get(k,0) for k,v in current.items()}
 for key,n in projected.items():
  cap=limits.get('max_'+key,limits.get('max_total_'+key))
  if cap is not None:assert n<=cap,(name,key,n,cap)
 for p,raw in values.items():
  override=row['member_limits'].get(p,{})
  for metric,n in [('lines',lc(raw)),('bytes',len(raw))]:
   cap=override.get('max_'+metric,limits.get('max_'+metric+'_per_file',limits.get('max_'+metric)));assert n<=cap,(p,metric,n,cap)
  if name in ['change_history','engineering_notes'] and p.endswith('manifest.jsonl'):
   assert lc(raw)+4<=override['max_lines'];assert len(raw)+4*(576 if name=='change_history' else 612)<=override['max_bytes']
 print(name,json.dumps({'current':current,'reserve':reserve[name],'projected':projected},sort_keys=True))
out=Path('.linkedspec-data/scratch/lua14');out.mkdir(parents=True,exist_ok=True);(out/'history-model.json').write_text(json.dumps(models,indent=2)+'\n')
print('PASS exact eleven-scalar admission;',kept_files,'prior files;',kept_nodes,'prior task nodes; exact history/question/ADR evidence; actual-candidate history and full 57-unit reserve.')
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
my $expected;{open my $fh,'<:raw','.linkedspec-data/scratch/lua14/history-model.json' or die $!;local $/;$expected=JSON::PP->new->decode(<$fh>)}
my $json=JSON::PP->new->canonical->utf8;
for my $model (@$expected) {
 my $root=$model->{root};my $raw=pack('H*',$model->{source_hex});
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

```perl
use strict;use warnings;use JSON::PP ();
my $JSON=JSON::PP->new->canonical(1);my $REGISTRY_PATH='doctrine/readme_stability/routes.jsonl';
my $BASE='b4ec6d39fb1e58bf3d8513f8c03d57b289ba15f6';
my @ids=qw(knowledge_cards task_evidence change_history engineering_notes);
sub read_bytes {my($p)=@_;open my $f,'<:raw',$p or die "$p: $!";local $/;my $r=<$f>;close $f or die $!;return $r}
my $src=read_bytes('scripts/check_readme_routing_pressure.pl');my $code='';
for my $name(qw(exceeds_limits canonical_object numeric_increase limit_change_permitted debt_retirement_permitted adr_authorizes_limit_change adr_authorizes_contract_change validate_registry_governance)) {
 my($fn)=$src=~/(^sub \Q$name\E \{.*?^\})/ms;die "missing $name" unless defined $fn;$code.=$fn."\n";
}
open my $git,'-|','git','show',"$BASE:$REGISTRY_PATH" or die $!;
my $head=do {local $/;<$git>};close $git or die 'Git baseline';
my @registry=map {$JSON->decode($_)} split /\n/,$head;my %wanted=map {$_=>1} @ids;
my %old=map {$_->{id}=>$_} grep {$wanted{$_->{id}//''}} @registry;
my $new=$JSON->decode($JSON->encode(\%old));
$new->{knowledge_cards}{limits}{max_total_lines}=93000;$new->{knowledge_cards}{limits}{max_total_bytes}=7340032;
$new->{task_evidence}{limits}{max_total_lines}=92000;$new->{task_evidence}{limits}{max_total_bytes}=10485760;
for my $args(['change_history',38,37,21071,'changes'],['engineering_notes',34,33,19902,'development-notes']) {
 my($id,$files,$lines,$bytes,$family)=@$args;$new->{$id}{limits}{max_files}=$files;
 $new->{$id}{member_limits}{"docs/history/$family/manifest.jsonl"}={max_lines=>$lines,max_bytes=>$bytes};
}
$new->{engineering_notes}{limits}{max_total_lines}=28000;
my $adr='docs/decisions/0118-approved-lua-reading-evidence-capacity.md';
my %files=map {$_=>read_bytes($_)} ($adr,'docs/decisions/INDEX.md');my @new_adrs=($adr);
sub snapshot_content {return $files{$_[0]}}
sub staged_new_adrs {return @new_adrs}
sub head_content {die 'unexpected head path' unless $_[0] eq $REGISTRY_PATH;return $head}
sub decode_registry {return ([map {$JSON->decode($_)} split /\n/,$_[0]],[])}
eval($code."\n1;") or die $@;
my $thresholds=0;
for my $id(@ids) {
 my $r=$new->{$id};my $l=$r->{limits};my @labels=('files','aggregate lines','aggregate bytes','member.md lines','member.md bytes');
 for my $case(-2..5) {
  my $m={files=>$l->{max_files},lines=>$l->{max_total_lines},bytes=>$l->{max_total_bytes},members=>['member.md'],per_file=>{'member.md'=>{lines=>$l->{max_lines_per_file},bytes=>$l->{max_bytes_per_file}}}};
  my @slots=(\$m->{files},\$m->{lines},\$m->{bytes},\$m->{per_file}{'member.md'}{lines},\$m->{per_file}{'member.md'}{bytes});
  if($case==-2){--$$_ for @slots}elsif($case==5){++$$_ for @slots}elsif($case>=0){my $slot=$slots[$case];++$$slot}
  my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$l);my @want=$case==5?@labels:$case>=0?($labels[$case]):();
  die "$id collection $case: @got" unless $JSON->encode(\@got) eq $JSON->encode(\@want);++$thresholds;
 }
 my %metric=(max_files=>'files',max_total_lines=>'lines',max_total_bytes=>'bytes');
 for my $key(sort keys %metric) {
  next if $l->{$key}==$old{$id}{limits}{$key};
  my $m={files=>0,lines=>0,bytes=>0,members=>[],per_file=>{}};$m->{$metric{$key}}=$l->{$key};
  my @before=exceeds_limits($m,$old{$id}{limits});my @after=exceeds_limits($m,$l);
  die "$id old/new $key" unless @before==1 && !@after;$thresholds+=2;
 }
 for my $path(sort keys %{$r->{member_limits}}) {
  my $cap=$r->{member_limits}{$path};
  for my $case(-2..2) {
   my $m={lines=>$cap->{max_lines},bytes=>$cap->{max_bytes}};
   --$m->{$_} for $case==-2?qw(lines bytes):();
   ++$m->{lines} if $case==0||$case==2;++$m->{bytes} if $case==1||$case==2;
   my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$cap);
   my @want=$case==2?qw(lines bytes):$case==0?('lines'):$case==1?('bytes'):();
   die "$id $path $case: @got" unless $JSON->encode(\@got) eq $JSON->encode(\@want);++$thresholds;
  }
  next unless $path=~/manifest/;
  my $m={lines=>$cap->{max_lines},bytes=>$cap->{max_bytes}};
  my @before=exceeds_limits($m,$old{$id}{member_limits}{$path});my @after=exceeds_limits($m,$cap);
  die "$id old/new manifest" unless @before==2 && !@after;$thresholds+=2;
 }
}
die "threshold count $thresholds" unless $thresholds==125;
my $original=$JSON->decode($JSON->encode(\%files));my $authorizations=0;
sub auth_case {
 my($label,$mutate,$expected)=@_;%files=%$original;@new_adrs=($adr);
 my $surfaces=$JSON->decode($JSON->encode([map {$new->{$_}} @ids]));$mutate->($surfaces);
 my @errors=validate_registry_governance($surfaces);
 die "$label: @errors" unless @errors==$expected;++$authorizations;print "PASS $label ($expected rejects)\n";
}
auth_case('exact approved indexed ADR',sub {},0);
auth_case('no new ADR',sub {@new_adrs=()},6);
auth_case('missing ADR body',sub {delete $files{$adr}},6);
auth_case('missing index row',sub {$files{'docs/decisions/INDEX.md'}=''},6);
for my $id(@ids) {
 my $history=$id eq 'change_history'||$id eq 'engineering_notes';
 auth_case("$id wrong surface",sub {$files{$adr}=~s/^- Routed surface: \x60\Q$id\E\x60$/- Routed surface: \x60unapproved\x60/m},$history?2:1);
 for my $kind($history?qw(limits contract):('limits')) {
  for my $which(qw(Previous New)) {
   my $r=$which eq 'Previous'?$old{$id}:$new->{$id};my $value=$r->{limits};
   if($kind eq 'contract') {$value={map {$_=>$r->{$_}} qw(authority control lifecycle member_limits members owner route_targets state verifier)};$value->{transition_owners}=$r->{transition}{owners}}
   my $literal="- $which routed $kind: \x60".$JSON->encode($value)."\x60";
   auth_case("$id altered $which $kind",sub {die 'literal missing' unless index($files{$adr},$literal)>=0;$files{$adr}=~s/\Q$literal\E/$literal extra/},1);
  }
 }
 for my $key(qw(max_files max_lines_per_file max_bytes_per_file max_total_lines max_total_bytes)) {
  auth_case("$id unapproved $key",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;++$r->{limits}{$key}},1);
 }
 auth_case("$id unapproved owner",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;$r->{owner}='unapproved'},1);
 auth_case("$id unapproved member",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;$r->{member_limits}{'member.md'}={max_lines=>999,max_bytes=>99999}},1);
 if($history) {
  for my $key(qw(max_lines max_bytes)) {
   auth_case("$id unapproved manifest $key",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;my($path)=grep {/manifest/} keys %{$r->{member_limits}};++$r->{member_limits}{$path}{$key}},1);
  }
  auth_case("$id unapproved root",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;my($path)=grep {!/manifest/} keys %{$r->{member_limits}};++$r->{member_limits}{$path}{max_lines}},1);
 }
}
die "authorization count $authorizations" unless $authorizations==54;
print "PASS $thresholds actual threshold and $authorizations actual authorization executions; detached inputs only.\n";
```


# September 13 enforcement qualification

[[task-partition-capacity-registry-drift]] proves that the partition checker
retained its older aggregate task limits while this admission changed only the
registry. The routing-function threshold proof above does not establish agreement
of that second guard. `SUPPORTING-SOURCE-READING.2.6` owns correction; the original
approval, evidence and scoped verification exception remain unchanged.
