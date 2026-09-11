---
id: julia-evidence-capacity-admission
title: Approved finite Julia Knowledge and decision capacity
answers:
  - what Knowledge and decision limits did containment 13 approve
  - how can the Julia evidence capacity reserve be reverified
  - which verification exception applies to containment 13
  - how was the two-scalar Julia evidence admission preserved
date: 2026-09-11
status: approved under ADR0116; focused implementation verification
tags: [julia, knowledge, decisions, capacity, verification, continuity]
evidence: "The director answered Granted to Knowledge aggregate lines72000→79000, decisions12000→13000 and the .13-only focused exception. Only these two registry scalars change; existing card/source/history bytes and other controls remain unchanged."
reverify:
  - "Execute the two fenced recipes below through tools/project_data_run.sh; detached validator inputs never mutate project authority."
  - "bash scripts/check_readme_stability.sh"
  - "perl tools/roll_document_history.pl --surface change_history --check"
  - "perl tools/roll_document_history.pl --surface engineering_notes --check"
---

# Approved boundary

ADR0116 records explicit approval of exactly two aggregate line limits:
Knowledge72,000→79,000 and decisions12,000→13,000. All file-count, byte,
member, map, task, history and README controls retain their previous values.
The complete proposal remains in `docs/tasks/JULIA-STARTUP-READING.md`,
Capacity proposal .5.1, at clean `63523d44898f6831e7c450786d1ac5a3f0a64015`.

The explicit focused-verification exception applies only to containment .13,
including execution before full codebase reading. Normal hooks remain enabled;
future canonical and push requirements remain. No dependency build, canonical
CI, runtime repair or additional reading credit is part of this admission.

Thirty-six unconstrained reading commits provide two reserve models:6,320
Knowledge lines under per-unit maxima and4,472 under the recent-mean model.
Twenty units cover15 remaining reading children plus proposal, admission,
independent audit, closeout and one contingency. Decision reserve is486 lines
/30,000 bytes /three files. The exact candidate plus the entire reserve is
checked again, conservatively charging the admission overhead twice. Unknown
future findings remain subject to fresh per-leaf measurement.

# Census and preservation replay

Run the following through `bash tools/project_data_run.sh python3 -`. Before
landing it reads the worktree; after landing it selects the unique admission
commit for dated preservation and uses the current tree for reserve measurement.

```python
from pathlib import Path
import subprocess,json,glob,re,copy
BASE='63523d44898f6831e7c450786d1ac5a3f0a64015'
SUBJECT='LIVE-DOCUMENT-PRESSURE-CONTAINMENT.13 - admit approved Julia evidence capacity'
def git(*args): return subprocess.check_output(['git',*args])
def old(p): return git('show',BASE+':'+p)
head=git('rev-parse','HEAD').decode().strip()
matches=[l.split('\t')[0] for l in git('log','--format=%H%x09%s','--fixed-strings','--grep='+SUBJECT).decode().splitlines() if l.split('\t',1)[1]==SUBJECT]
assert len(matches)<=1
assert matches or head==BASE
def admitted(p): return git('show',matches[0]+':'+p) if matches else Path(p).read_bytes()
registry='doctrine/readme_stability/routes.jsonl'
before=[json.loads(x) for x in old(registry).splitlines()]
after=[json.loads(x) for x in admitted(registry).splitlines()]
expected=copy.deepcopy(before)
for r in expected:
 if r.get('id') in ('knowledge_cards','decisions'):
  r['limits']['max_total_lines']=79000 if r['id']=='knowledge_cards' else 13000
assert after==expected
for a,b in zip(old(registry).splitlines(True),admitted(registry).splitlines(True)):
 if json.loads(a).get('id') not in ('knowledge_cards','decisions'): assert a==b
paths=git('ls-tree','-r','--name-only',BASE,'--','julia','perl','rust','dart','lua','scripts','tools','.githooks','docs/history','docs/knowledge','docs/decisions').decode().splitlines()
kept=0
for p in paths:
 if p=='docs/decisions/INDEX.md': continue
 assert admitted(p)==old(p),p
 kept+=1
old_index=old('docs/decisions/INDEX.md')
new_index=admitted('docs/decisions/INDEX.md')
addition=b'| [0116](0116-approved-julia-evidence-capacity.md) | Admit finite Julia Knowledge and decision line capacity; exact two-scalar approval and .13-only focused exception | 2026-09-11 | accepted | documentation, knowledge, capacity, verification |\n\n'
assert new_index.replace(addition,b'',1)==old_index
for root in ('CHANGES.md','DEVELOPMENT_NOTES.md'):
 prior=old(root); now=admitted(root); start=re.search(rb'(?m)^## ',prior).start()
 assert now.endswith(prior[start:]),root
def nodes(b): return dict(re.findall(rb'^- ID: `([^`]+)`\n(.*?)(?=^- ID: |^## |\Z)',b,re.M|re.S))
allowed={b'LIVE-DOCUMENT-PRESSURE-CONTAINMENT',b'LIVE-DOCUMENT-PRESSURE-CONTAINMENT.13',b'JULIA-STARTUP-READING.5',b'SESSION-STARTUP-READING.3.5'}
count=0
for p in git('ls-tree','-r','--name-only',BASE,'--','docs/tasks').decode().splitlines():
 if not p.endswith('.md'): continue
 prior=nodes(old(p)); now=nodes(admitted(p))
 for id,body in prior.items():
  if id not in allowed: assert now.get(id)==body,(p,id)
  count+=1
questions=lambda b:{l for l in b.splitlines() if l.startswith(b'- "')}
assert questions(old('KNOWLEDGE_MAP.md'))<=questions(admitted('KNOWLEDGE_MAP.md'))
reserve={'knowledge_cards':{'files':20,'lines':6320,'bytes':353480},'task_evidence':{'files':2,'lines':1440,'bytes':197500},'knowledge_map':{'lines':320,'bytes':72120},'decisions':{'files':3,'lines':486,'bytes':30000}}
records=[json.loads(x) for x in Path(registry).read_text().splitlines()]
for name,extra in reserve.items():
 r=next(x for x in records if x.get('id')==name); limits=r['limits']
 paths=sorted({p for pattern in r['members'] for p in glob.glob(pattern)})
 assert all(Path(p).is_file() and not Path(p).is_symlink() for p in paths)
 values={p:Path(p).read_bytes() for p in paths}
 current={'files':len(paths),'lines':sum(v.count(b'\n') for v in values.values()),'bytes':sum(map(len,values.values()))}
 for p,v in values.items():
  override=r['member_limits'].get(p,{})
  assert v.count(b'\n')<=override.get('max_lines',limits.get('max_lines_per_file',limits.get('max_lines'))),p
  assert len(v)<=override.get('max_bytes',limits.get('max_bytes_per_file',limits.get('max_bytes'))),p
 projected={k:current[k]+n for k,n in extra.items()}
 for k,n in projected.items():
  key='max_'+k if name=='knowledge_map' else 'max_files' if k=='files' else 'max_total_'+k
  assert n<=limits[key],(name,k,n,limits[key])
 print(name,json.dumps({'current':current,'reserve':extra,'projected':projected},sort_keys=True))
print('PASS exact two-scalar admission;',kept,'prior source/guard/card/decision/history files;',count,'prior task nodes; old question rows; full actual-plus-reserve census.')
```

# Actual production-validator replay

Run through `bash tools/project_data_run.sh perl -`. The production functions
are extracted unchanged and receive detached metrics/snapshots. Their inclusive
thresholds and exact indexed-ADR authorization are tested independently of
the real candidate, which the normal routing doctrine also checks.

```perl
use strict;use warnings;use JSON::PP ();
my $JSON=JSON::PP->new->canonical(1);my $REGISTRY_PATH='doctrine/readme_stability/routes.jsonl';
sub read_bytes {my($p)=@_;open my $f,'<:raw',$p or die "$p: $!";local $/;my $r=<$f>;close $f or die $!;return $r}
my $src=read_bytes('scripts/check_readme_routing_pressure.pl');my $code='';
for my $name(qw(exceeds_limits canonical_object numeric_increase limit_change_permitted debt_retirement_permitted adr_authorizes_limit_change adr_authorizes_contract_change validate_registry_governance)) {
 my($fn)=$src=~/(^sub \Q$name\E \{.*?^\})/ms;die "missing $name" unless defined $fn;$code.=$fn."\n";
}
open my $source,'-|','git','show','63523d44898f6831e7c450786d1ac5a3f0a64015:'.$REGISTRY_PATH or die $!;
my $head=do {local $/;<$source>};close $source or die 'Git baseline';
my @records=map {$JSON->decode($_)} split /\n/,$head;
my %old=map {$_->{id}=>$_} grep {($_->{id}//'') eq 'knowledge_cards'||($_->{id}//'') eq 'decisions'} @records;
my $new=$JSON->decode($JSON->encode(\%old));$new->{knowledge_cards}{limits}{max_total_lines}=79000;$new->{decisions}{limits}{max_total_lines}=13000;
my $adr='docs/decisions/0116-approved-julia-evidence-capacity.md';
my %files=map {$_=>read_bytes($_)} ($adr,'docs/decisions/INDEX.md');my @new_adrs=($adr);
sub snapshot_content {return $files{$_[0]}}
sub staged_new_adrs {return @new_adrs}
sub head_content {die 'unexpected head path' unless $_[0] eq $REGISTRY_PATH;return $head}
sub decode_registry {return ([map {$JSON->decode($_)} split /\n/,$_[0]],[])}
eval($code."\n1;") or die $@;
my $thresholds=0;
for my $id(qw(knowledge_cards decisions)) {
 my $l=$new->{$id}{limits};my @labels=('files','aggregate lines','aggregate bytes','member.md lines','member.md bytes');
 for my $case(-2..5) {
  my $m={files=>$l->{max_files},lines=>$l->{max_total_lines},bytes=>$l->{max_total_bytes},members=>['member.md'],per_file=>{'member.md'=>{lines=>$l->{max_lines_per_file},bytes=>$l->{max_bytes_per_file}}}};
  my @slots=(\$m->{files},\$m->{lines},\$m->{bytes},\$m->{per_file}{'member.md'}{lines},\$m->{per_file}{'member.md'}{bytes});
  if($case==-2){--$$_ for @slots}elsif($case==5){++$$_ for @slots}elsif($case>=0){my $slot=$slots[$case];++$$slot}
  my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$l);
  my @want=$case==5?@labels:$case>=0?($labels[$case]):();
  die "$id threshold $case: @got" unless $JSON->encode(\@got) eq $JSON->encode(\@want);++$thresholds;
 }
 my $m={files=>0,lines=>$l->{max_total_lines},bytes=>0,members=>[],per_file=>{}};
 my @prior=exceeds_limits($m,$old{$id}{limits});my @approved=exceeds_limits($m,$l);
 die "$id old/new boundary" unless @prior==1 && $prior[0] eq "aggregate lines $l->{max_total_lines}/$old{$id}{limits}{max_total_lines}" && !@approved;
 $thresholds+=2;
}
my $original=$JSON->decode($JSON->encode(\%files));my $authorizations=0;
sub auth_case {
 my($label,$mutate,$expected)=@_;%files=%$original;@new_adrs=($adr);
 my $surfaces=$JSON->decode($JSON->encode([map {$new->{$_}} qw(knowledge_cards decisions)]));
 $mutate->($surfaces);my @errors=validate_registry_governance($surfaces);
 die "$label: @errors" unless @errors==$expected;++$authorizations;print "PASS $label ($expected rejects)\n";
}
auth_case('exact approved indexed ADR',sub {},0);
auth_case('no new ADR',sub {@new_adrs=()},2);
auth_case('missing ADR body',sub {delete $files{$adr}},2);
auth_case('missing index row',sub {$files{'docs/decisions/INDEX.md'}=''},2);
for my $id(qw(knowledge_cards decisions)) {
 auth_case("$id wrong surface",sub {$files{$adr}=~s/^- Routed surface: \x60\Q$id\E\x60$/- Routed surface: \x60unapproved\x60/m},1);
 for my $which(qw(Previous New)) {
  my $limits=$which eq 'Previous'?$old{$id}{limits}:$new->{$id}{limits};
  my $literal="- $which routed limits: \x60".$JSON->encode($limits)."\x60";
  auth_case("$id altered $which limits",sub {die 'literal missing' unless index($files{$adr},$literal)>=0;$files{$adr}=~s/\Q$literal\E/$literal extra/},1);
 }
 for my $field(qw(max_files max_lines_per_file max_bytes_per_file max_total_lines max_total_bytes)) {
  auth_case("$id unapproved $field",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;++$r->{limits}{$field}},1);
 }
 auth_case("$id unapproved owner",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;$r->{owner}='unapproved'},1);
 auth_case("$id unapproved member override",sub {my($s)=@_;my($r)=grep {$_->{id} eq $id} @$s;$r->{member_limits}{'member.md'}={max_lines=>999,max_bytes=>99999}},1);
}
die 'execution count' unless $thresholds==20 && $authorizations==24;
print "PASS $thresholds actual threshold and $authorizations actual authorization executions; detached inputs only.\n";
```
