---
id: julia-reading-history-capacity-admission
title: Approved finite Julia history capacity preserves evidence and proportionate governance
answers:
  - what exact Julia history limits are now approved
  - how was containment 12 history preservation verified
  - which verification exception applies to containment 12
  - how should governance limits support feature and product progress
  - should LinkedSpec replace Markdown source documents with HTML for agents
date: 2026-09-11
status: implemented under ADR0115; explicit one-time focused exception for containment .12
tags: [julia, history, capacity, verification, continuity, governance]
evidence: "The director explicitly answered YES to the six limits and .12-only exception. The admission changes exactly six registry scalars, preserves all old immutable history and clean 107170da7 CHANGES239-455 as 217 lines/13128 bytes. Actual production functions pass 44 threshold and 22 authorization executions."
reverify:
  - "Run the two repository-managed recipes below; the first selects the exact admission snapshot after landing."
  - "perl tools/roll_document_history.pl --surface change_history --check"
  - "perl tools/roll_document_history.pl --surface engineering_notes --check"
---

# Approved finite allowance

ADR0115 admits four archive slots per history: change_history files 32→36,
manifest lines 31→35 and bytes 17615→19919; engineering_notes files 28→32,
manifest lines 27→31 and bytes 16384→18678. All other registry values, root,
segment and aggregate ceilings, routes, owners and verifiers remain unchanged.

The director explicitly approves focused verification without canonical CI for
containment .12 only. Normal hooks and all nine doctrines remain enabled.
Future canonical/push requirements remain; PGEN/RGX build-on-update implementation
stays separately owned by startup .80. No runtime fix or dependency build occurs.
The original finite dual-axis forecast remains in [[julia-reading-history-capacity-proposal]].

# Actual preservation and admission

The .12 record raises the change hot root from 455 to 466 lines, requiring rollover.
The governed tool archives source lines 239–455 of clean
`107170da748f7f89d9cbdb26d4a6df888a067077`, blob
`5874d5cb391064543217d41e1d2ab5e5cf6bb686`, into segment 4980-f04b37b1dab6:
217 lines /13128 bytes, SHA-256
`f04b37b1dab6628be794d952afa082fec6ff5b244c999081267f882673cbd4fe`.
One terminal separator LF is removed only from the hot root and explicitly
restored by reconstruction; no archive byte is normalized.

| Surface | Root lines/bytes | Manifest lines/bytes | Collection files/lines/bytes |
| --- | ---: | ---: | ---: |
| change_history | 248/14891 | 32/18191 | 33/48987/3557028 |
| engineering_notes | 396/24673 | 27/16230 | 28/26220/2798551 |

Every previous manifest record and archive remains exact. The complete archived
queries are 48707 lines/3523946 bytes for changes, SHA-256
`f88d9e939d192df122b118482f5a67fa028289bc07785c712d225020d0c729cd`,
and 25797 lines/2757648 bytes for notes, SHA-256
`baa5c445280a246641a3a3a4cd5c2fb8ef8444ac901126152183f9c2d73069fd`.
Query counts exclude hot roots and manifest framing.

The actual production threshold function passes 44 executions: below/equal,
independent/simultaneous excesses for collection/segment/root/manifest ceilings,
and exact old-versus-approved capacity controls on detached metrics.
Actual production governance functions pass 22 executions using detached snapshot
inputs: exact new indexed ADR admission, missing authority/index, altered exact
old/new objects, wrong surfaces and unapproved limit/root increases. The normal
routing doctrine additionally validates the complete real staged candidate.
These tests do not mutate the registry, index, ADR or any historical source.

# Proportionate governance and representation

The director clarified that rules are necessary to prevent disorder and must
support feature/product implementation. ADR0115 records measured need, clear
ownership, bounded adjustments and proportionate checks as the operating principle.
Forecast capacity over a coherent activity; retain evidence and per-leaf checks.

The related HTML/Markdown discussion does not activate a format migration.
Our recommendation is Markdown for editable repository documentation and generated
HTML for human review, with structured data for mechanically validated fields.
This is an engineering choice for this repository, not a measured universal LLM
accuracy advantage. [HtmlRAG](https://arxiv.org/html/2411.02959v1) reports benefits
from cleaned HTML on web QA, including converted-Markdown comparisons; raw HTML
has substantial noise. [Cloudflare](https://blog.cloudflare.com/markdown-for-agents/)
reports one page's token reduction from 16180 to 3150 through Markdown conversion.
Neither study establishes a universal format rule for coding-agent memory.

The discussion also identifies a Karpathy post recommending HTML for output that
people view in browsers. Its [original X URL](https://x.com/karpathy/status/2053872850101285137)
could not be opened directly during this session; the wording was read through an
[archived reproduction](https://brianwong.com/Wiki/Raw/Post-by-%40karpathy-on-X).
That presentation recommendation supports useful visual/interactive review;
it is not evidence that agents require HTML as their editable memory format.
No implementation of interactive review is activated by this discussion.

# Exact admission replay

Save this recipe below the repository and run with
`bash tools/project_data_run.sh python3 <script>`. After landing, it selects the
unique admission commit for dated metrics. Current archive queries must retain
that admission's archive bytes as a suffix.

```python
from pathlib import Path
import subprocess,json,hashlib,re,copy
BASE='107170da748f7f89d9cbdb26d4a6df888a067077'
SUBJECT='LIVE-DOCUMENT-PRESSURE-CONTAINMENT.12 - admit approved Julia history capacity'
def git(*args):return subprocess.check_output(['git',*args])
def old(p):return git('show',BASE+':'+p)
def sha(x):return hashlib.sha256(x).hexdigest()
def lc(x):return x.count(b'\n')+int(bool(x) and not x.endswith(b'\n'))
# Replay the exact admission commit once landed; before landing use its worktree.
head=git('rev-parse','HEAD').decode().strip()
if head==BASE: candidate=None
else:
 matches=git('log','--format=%H%x09%s','--fixed-strings','--grep='+SUBJECT).decode().splitlines()
 exact=[line.split('\t')[0] for line in matches if line.split('\t',1)[1]==SUBJECT]
 assert len(exact)==1,exact
 candidate=exact[0]
def current(p):return Path(p).read_bytes() if candidate is None else git('show',candidate+':'+p)
registry='doctrine/readme_stability/routes.jsonl'
before=[json.loads(x) for x in old(registry).splitlines()]
after=[json.loads(x) for x in current(registry).splitlines()]
expected=copy.deepcopy(before)
values={'change_history':(36,35,19919,'changes','CHANGES.md'),'engineering_notes':(32,31,18678,'development-notes','DEVELOPMENT_NOTES.md')}
for row in expected:
 if row.get('id') not in values:continue
 files,lines,bytes_,family,root=values[row['id']]
 row['limits']['max_files']=files
 row['member_limits']['docs/history/'+family+'/manifest.jsonl'].update(max_lines=lines,max_bytes=bytes_)
assert after==expected
changed=[]
def differences(a,b,path=()):
 if isinstance(a,dict):
  assert a.keys()==b.keys()
  for k in a:differences(a[k],b[k],path+(k,))
 elif isinstance(a,list):
  assert len(a)==len(b)
  for i,(x,y) in enumerate(zip(a,b)):differences(x,y,path+(str(i),))
 elif a!=b:changed.append((path,a,b))
differences(before,after);assert len(changed)==6,changed
# All unaffected registry rows retain exact serialized bytes.
for a,b in zip(old(registry).splitlines(True),current(registry).splitlines(True)):
 if json.loads(a).get('id') not in values:assert a==b
results={}
for id,(_,_,_,family,root) in values.items():
 manifest='docs/history/'+family+'/manifest.jsonl'
 om=old(manifest);nm=current(manifest)
 rows=[json.loads(x) for x in nm.splitlines()]
 oldrows=[json.loads(x) for x in om.splitlines()]
 history_paths=git('ls-tree','-r','--name-only',BASE,'--','docs/history/'+family+'/').decode().splitlines()
 for p in history_paths:
  if p!=manifest:assert current(p)==old(p),p
 source=old(root);now=current(root)
 if id=='change_history':
  assert nm.splitlines(True)[2:]==om.splitlines(True)[1:]
  metadata=copy.deepcopy(oldrows[0]);metadata['segment_count']+=1;assert rows[0]==metadata
  row=rows[1];part=current(row['target_path'])
  assert row['source_commit']==BASE and row['source_blob']==git('rev-parse',BASE+':'+root).decode().strip()
  exact=b''.join(source.splitlines(True)[row['source_start_line']-1:row['source_end_line']])
  assert part==exact and source.endswith(part)
  assert (row['source_start_line'],row['source_end_line'],lc(part),len(part),sha(part))==(239,455,217,13128,'f04b37b1dab6628be794d952afa082fec6ff5b244c999081267f882673cbd4fe')
  starts=[m.start() for m in re.finditer(rb'(?m)^## ',now)]
  added=now[starts[0]:starts[1]]
  first=re.search(rb'(?m)^## ',source).start()
  assert now+b'\n'+part==source[:first]+added+source[first:]
  assert (lc(now),len(now))==(248,14891)
 else:
  assert nm==om
  first=re.search(rb'(?m)^## ',source).start()
  assert now.endswith(source[first:])
  assert (lc(now),len(now))==(396,24673)
 segments=[current(r['target_path']) for r in rows[1:]]
 for r,part in zip(rows[1:],segments):
  assert (lc(part),len(part),sha(part))==(r['line_count'],r['byte_count'],r['sha256'])
 archived=b''.join(segments)
 live_query=subprocess.check_output(['perl','tools/read_document_history.pl','--surface',id,'--all'])
 assert live_query.endswith(archived)
 population=[now,nm,*segments]
 results[id]={'root':[lc(now),len(now)],'manifest':[lc(nm),len(nm)],'collection':[len(population),sum(map(lc,population)),sum(map(len,population))],'archive':[lc(archived),len(archived),sha(archived)]}
 assert results[id]['collection'][0]<=values[id][0]
print(json.dumps(results,indent=2))
print('PASS exact six-scalar admission; every earlier registry/history byte; clean source/blob/239-455 suffix; full root and query reconstruction with explicit one-LF hot-root normalization.')
```

# Actual-validator boundary replay

Save this below the repository and run with `bash tools/project_data_run.sh perl <script>`.
It reads the frozen baseline and immutable ADR, uses the current production functions,
and changes detached inputs only. The approved objects are rebuilt without scratch dependencies.

```perl
use strict;use warnings;use JSON::PP ();
my $JSON=JSON::PP->new->canonical(1);my $REGISTRY_PATH='doctrine/readme_stability/routes.jsonl';
sub read_bytes {my($p)=@_;open my $f,'<:raw',$p or die "$p: $!";local $/;my $r=<$f>;close $f or die $!;return $r}
my $src=read_bytes('scripts/check_readme_routing_pressure.pl');
my @names=qw(exceeds_limits canonical_object numeric_increase limit_change_permitted debt_retirement_permitted adr_authorizes_limit_change adr_authorizes_contract_change validate_registry_governance);
my $code='';
for my $name(@names) {my($fn)=$src=~/(^sub \Q$name\E \{.*?^\})/ms;die "missing $name" unless defined $fn;$code.=$fn."\n"}
my $base='107170da748f7f89d9cbdb26d4a6df888a067077';
open my $source,'-|','git','show',"$base:$REGISTRY_PATH" or die $!;
my $head=do {local $/;<$source>};close $source or die 'Git baseline';
my @registry=map {$JSON->decode($_)} split /\n/,$head;
my %baseline=map {$_->{id}=>$_} grep {($_->{id}//'') eq 'change_history'||($_->{id}//'') eq 'engineering_notes'} @registry;
my $state={base=>$base,old=>\%baseline,new=>$JSON->decode($JSON->encode(\%baseline))};
for my $entry(['change_history',36,35,19919,'changes'],['engineering_notes',32,31,18678,'development-notes']) {
 my($id,$files,$lines,$bytes,$family)=@$entry;my $r=$state->{new}{$id};
 $r->{limits}{max_files}=$files;
 $r->{member_limits}{"docs/history/$family/manifest.jsonl"}{max_lines}=$lines;
 $r->{member_limits}{"docs/history/$family/manifest.jsonl"}{max_bytes}=$bytes;
}
my $adr='docs/decisions/0115-julia-reading-history-capacity.md';
my %files=map {$_=>read_bytes($_)} ($adr,'docs/decisions/INDEX.md');
my @new_adrs=($adr);
sub snapshot_content {return $files{$_[0]}}
sub staged_new_adrs {return @new_adrs}
sub head_content {die 'unexpected head path' unless $_[0] eq $REGISTRY_PATH;return $head}
sub decode_registry {return ([map {$JSON->decode($_)} split /\n/,$_[0]],[])}
eval($code."\n1;") or die $@;
my $limits_count=0;
for my $id(qw(change_history engineering_notes)) {
 my $r=$state->{new}{$id};my $prior=$state->{old}{$id};my $l=$r->{limits};
 my @labels=('files','aggregate lines','aggregate bytes','segment.md lines','segment.md bytes');
 for my $case(-2..5) {
  my $m={files=>$l->{max_files},lines=>$l->{max_total_lines},bytes=>$l->{max_total_bytes},members=>['segment.md'],per_file=>{'segment.md'=>{lines=>$l->{max_lines_per_file},bytes=>$l->{max_bytes_per_file}}}};
  my @slots=(\$m->{files},\$m->{lines},\$m->{bytes},\$m->{per_file}{'segment.md'}{lines},\$m->{per_file}{'segment.md'}{bytes});
  if($case==-2){--$$_ for @slots}elsif($case==5){++$$_ for @slots}elsif($case>=0){my $slot=$slots[$case];++$$slot}
  my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$l);
  my @want=$case==5?@labels:$case>=0?($labels[$case]):();
  die "$id collection $case: @got" unless $JSON->encode(\@got) eq $JSON->encode(\@want);++$limits_count;
 }
 for my $path(sort keys %{$r->{member_limits}}) {
  my $cap=$r->{member_limits}{$path};
  for my $case(-2..2) {
   my $m={lines=>$cap->{max_lines},bytes=>$cap->{max_bytes}};
   --$m->{$_} for $case==-2?qw(lines bytes):();
   ++$m->{lines} if $case==0||$case==2;++$m->{bytes} if $case==1||$case==2;
   my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$cap);
   my @want=$case==2?qw(lines bytes):$case==0?('lines'):$case==1?('bytes'):();
   die "$id $path $case: @got" unless $JSON->encode(\@got) eq $JSON->encode(\@want);++$limits_count;
  }
 }
 my $m={files=>$l->{max_files},lines=>0,bytes=>0,members=>[],per_file=>{}};
 my @old=exceeds_limits($m,$prior->{limits});my @new=exceeds_limits($m,$l);
 die "$id old/new file allowance" unless "@old" eq "files $l->{max_files}/$prior->{limits}{max_files}" && !@new;$limits_count+=2;
 my($manifest)=grep {/manifest/} keys %{$r->{member_limits}};
 my $cap=$r->{member_limits}{$manifest};$m={lines=>$cap->{max_lines},bytes=>$cap->{max_bytes}};
 @old=exceeds_limits($m,$prior->{member_limits}{$manifest});@new=exceeds_limits($m,$cap);
 die "$id old/new manifest allowance" unless @old==2 && $old[0]=~/^lines / && $old[1]=~/^bytes / && !@new;$limits_count+=2;
}
die "limit count $limits_count" unless $limits_count==44;
my $base_files=$JSON->decode($JSON->encode(\%files));my $auth_count=0;
sub authorization_case {
 my($name,$mutate,$expected)=@_;
 %files=%$base_files;@new_adrs=($adr);
 my $surfaces=$JSON->decode($JSON->encode([map {$state->{new}{$_}} qw(change_history engineering_notes)]));
 $mutate->($surfaces);
 my @errors=validate_registry_governance($surfaces);
 die "$name: ".join('; ',@errors) unless @errors==$expected;
 ++$auth_count;print "PASS authorization $name ($expected rejects)\n";
}
authorization_case('exact approved indexed new ADR',sub {},0);
authorization_case('no new ADR',sub {@new_adrs=()},4);
authorization_case('missing ADR body',sub {delete $files{$adr}},4);
authorization_case('missing index entry',sub {$files{'docs/decisions/INDEX.md'}=''},4);
for my $id(qw(change_history engineering_notes)) {
 authorization_case("$id wrong surface",sub {$files{$adr}=~s/^- Routed surface: \x60\Q$id\E\x60$/- Routed surface: \x60unapproved\x60/m},2);
 for my $kind(qw(limits contract)) {
  for my $which(qw(Previous New)) {
   my $value;
   if($kind eq 'limits') {$value=$state->{$which eq 'Previous'?'old':'new'}{$id}{limits}}
   else {
    my $r=$state->{$which eq 'Previous'?'old':'new'}{$id};
    $value={map {$_=>$r->{$_}} qw(authority control lifecycle member_limits members owner route_targets state verifier)};
    $value->{transition_owners}=$r->{transition}{owners};
   }
   my $literal="- $which routed $kind: \x60".$JSON->encode($value)."\x60";
   authorization_case("$id altered $which $kind",sub {die 'literal missing' unless index($files{$adr},$literal)>=0;$files{$adr}=~s/\Q$literal\E/$literal extra/},1);
  }
 }
 for my $field(qw(files manifest_lines manifest_bytes)) {
  authorization_case("$id unapproved $field increase",sub {
   my($surfaces)=@_;my($r)=grep {$_->{id} eq $id} @$surfaces;
   my($m)=grep {/manifest/} keys %{$r->{member_limits}};
   if($field eq 'files'){++$r->{limits}{max_files}}elsif($field eq 'manifest_lines'){++$r->{member_limits}{$m}{max_lines}}else{++$r->{member_limits}{$m}{max_bytes}}
  },1);
 }
 authorization_case("$id unapproved root ceiling",sub {
  my($surfaces)=@_;my($r)=grep {$_->{id} eq $id} @$surfaces;
  my($root)=grep {!/manifest/} keys %{$r->{member_limits}};++$r->{member_limits}{$root}{max_lines};
 },1);
}
die "authorization count $auth_count" unless $auth_count==22;
print "PASS $limits_count actual threshold executions and $auth_count actual governance executions; detached inputs only, no registry/index/ADR mutation.\n";
```

# Julia .1.41 governed engineering-notes rollover

The ordinary reading slice prepends seven lines: notes455→462, requiring the
existing tool to roll source244–455 of clean523c14ecb1b0e1cd20a7cf19481020e8161d48f7,
blob946da53fdf716210957ab20ab17b1806398e29b4. Segment4978-60c526ee0cd8 preserves
212 lines/13215 bytes, SHA60c526ee0cd898663095b552894a065ead05aa436aa815bd18813f75e073461c.
One final separator LF is removed only from the hot root and restored explicitly
for source reconstruction. Root is249 lines/14035 bytes; manifest29/17454. All
prior manifest records and archive bytes remain exact. The ordered archive query
is26222 lines/2783761 bytes, SHA2f8ae3451e12a0b57fab8effa7bdcdb74ec2854d26a398c8734ccf3490ab440d.
No policy limit or authority changes. This is a routine rollover within ADR0115,
not another capacity admission or verification exception.

Run the following through `bash tools/project_data_run.sh python3 <script>` from
the repository. It selects the dated .1.41 commit after landing; later archived
queries must preserve that snapshot's bytes as a suffix.

```python
from pathlib import Path
import subprocess,json,hashlib,re
BASE='523c14ecb1b0e1cd20a7cf19481020e8161d48f7'
SUBJECT='JULIA-STARTUP-READING.1.41 - read cursor and primary CLI test boundaries'
def git(*args): return subprocess.check_output(['git',*args])
commits=[l.split(' ',1)[0] for l in git('log','--format=%H %s','--fixed-strings','--grep='+SUBJECT).decode().splitlines() if l.split(' ',1)[1]==SUBJECT]
assert len(commits)<=1
SNAP=commits[0] if commits else None
if SNAP: assert git('rev-parse',SNAP+'^').decode().strip()==BASE
def old(p): return git('show',BASE+':'+p)
def snap(p): return git('show',SNAP+':'+p) if SNAP else Path(p).read_bytes()
mp='docs/history/development-notes/manifest.jsonl';root='DEVELOPMENT_NOTES.md'
a=old(mp).splitlines(keepends=True);b=snap(mp).splitlines(keepends=True)
assert b[2:]==a[1:]
x,y=json.loads(a[0]),json.loads(b[0])
assert y.pop('segment_count')==x.pop('segment_count')+1 and x==y
r=json.loads(b[1]);assert (r['source_start_line'],r['source_end_line'])==(244,455)
assert r['source_commit']==BASE and r['source_blob']==git('rev-parse',BASE+':'+root).decode().strip()
source=old(root);part=b''.join(source.splitlines(keepends=True)[243:455])
assert snap(r['target_path'])==part
assert (len(part.splitlines()),len(part),hashlib.sha256(part).hexdigest())==(212,13215,r['sha256'])
for row in a[1:]:
 p=json.loads(row)['target_path'];assert snap(p)==old(p)==Path(p).read_bytes()
current=snap(root);first=re.search(br'^## ',current,re.M).start()
second=re.search(br'^## ',current[first+3:],re.M).start()+first+3
assert current[:first]+current[second:]+b'\n'+part==source
assert (len(current.splitlines()),len(current),len(b),len(snap(mp)))==(249,14035,29,17454)
query=part+b''.join(old(json.loads(row)['target_path']) for row in a[1:])
assert (len(query.splitlines()),len(query),hashlib.sha256(query).hexdigest())==(26222,2783761,'2f8ae3451e12a0b57fab8effa7bdcdb74ec2854d26a398c8734ccf3490ab440d')
now=subprocess.check_output(['perl','tools/read_document_history.pl','--surface','engineering_notes','--all'])
assert now.endswith(query) and (SNAP is not None or now==query)
print('PASS .1.41 exact committed source, one restored separator LF, all prior manifest/archive bytes and ordered query')
```
