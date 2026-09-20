---
id: julia-reading-commit-closeout-audit
title: Julia independent reading audit preserves source commits and open repairs
answers:
  - have all 52 Julia reading commits been independently verified
  - which commit is the complete physical Julia reading checkpoint
  - what verification blocks Julia reading parent closeout
  - does complete Julia reading close its runtime defects
date: 2026-09-12
status: Julia reading closed under explicit ADR0117 approval; all repairs remain open
tags: [julia, startup, reading, audit, continuity]
evidence: "JULIA-STARTUP-READING.3.1; physical checkpoint2c70957a26a4ae6066bc8d80f2aa7a6791a3f953; source baselinebaeb984e36a94a15951cd23d4c52def5064cdaca."
reverify: "Run JULIA_READING_COMMIT_AUDIT below; frozen checkpoint identities remain intentional and later legitimate changes require an explicit delta audit."
---

## Later director update — September13

The director has cancelled the RGX/PGEN no-rebuild/build-on-update-only
restriction recorded below. Normal Cargo dependency compilation is authorized;
startup .80 owns public RGX build observations, upstream reports and LinkedSpec
target retention. The September20 boundary excludes dependency implementation
inspection and repair. The dated reading evidence and CI exception below remain
unchanged; they do not authorize a private dependency procedure.


# Historical independent committed-reading audit

All52 bounded source-reading children are committed at checkpoint2c70957a2.
The independent audit below checks unique subjects, exact committed scope,
comprehension, verification and first-parent MEMORY activation for every child.
It reconstructs all95 source entries/75984 physical lines/2693170 bytes from the
frozen146 ranges and checks each committed Julia tree against the source baseline.
The result does not complete all-codebase reading or remediate runtime defects.

The first ad-hoc audit incorrectly stripped backticks without accepting the
optional final period on the earliest Commit fields. Exact quoted-subject parsing
handles both existing forms without rewriting any historical task record.

The audit passes all52 records,122 touched fact cards and27 repair roots/80
pending nodes. The complete unchanged Julia component gate also passes.
Reading parents .1/.3/startup .3.5 remain open; .3.2 owns their separate closeout.
The unchanged canonical drivers still include dependency-building routes from
startup .80.0. That conflicts with the director's build-on-update requirement;
.80.1-.4 own its implementation. Earlier ADR0114 and ADR0116 exceptions do not
waive this Julia closeout. No canonical CI or PGEN/RGX build is run here.

# Exact reproduction

The report is generated under repository-local scratch; its complete contents
are reproducible from these committed source and history identities.

```bash
bash tools/project_data_run.sh python3 - <<'JULIA_READING_COMMIT_AUDIT'
from pathlib import Path
import contextlib,hashlib,io,json,re,subprocess
BASE='baeb984e36a94a15951cd23d4c52def5064cdaca'
ACTIVATION='2c70957a26a4ae6066bc8d80f2aa7a6791a3f953'
TREE='docs/tasks/JULIA-STARTUP-READING.md';q=chr(96)
def git(*args):return subprocess.check_output(['git',*args])
def digest(v):return hashlib.sha256(json.dumps(v,ensure_ascii=False,separators=(',',':')).encode()).hexdigest()
def nodes(text):return dict(re.findall(r'^- ID: '+q+'([^'+q+']+)'+q+r'\n(.*?)(?=^- ID: |^## |\Z)',text,re.M|re.S))
def field(node,name):
 values=re.findall(r'^  '+re.escape(name)+r': (.+)$',node,re.M)
 assert len(values)==1,(name,len(values))
 return values[0]
text=Path(TREE).read_text();current=nodes(text)
card=Path('docs/knowledge/julia-startup-reading-coverage.md').read_text()
recipe=card.split("<<'JULIA_READING_COVERAGE'\n",1)[1].split('\nJULIA_READING_COVERAGE',1)[0]
ns={}
with contextlib.redirect_stdout(io.StringIO()):
 exec(compile(recipe,'JULIA_READING_COVERAGE','exec'),ns)
assert ns['done']==52
subjects={}
for row in git('log','--format=%H%x09%s',BASE+'..'+ACTIVATION).decode().splitlines():
 commit,subject=row.split('\t',1);subjects.setdefault(subject,[]).append(commit)
records=[];knowledge=set();prior=None
base_tree=git('ls-tree','-r','-z',BASE,'--','julia')
for i in range(1,53):
 leaf='JULIA-STARTUP-READING.1.'+str(i);node=current[leaf]
 assert field(node,'Status')==q+'done'+q,leaf
 match=re.fullmatch(q+'([^'+q+']+)'+q+r'\.?',field(node,'Commit'));assert match,leaf
 subject=match[1]
 assert subject.startswith(leaf+' - ') and len(subjects.get(subject,[]))==1,leaf
 commit=subjects[subject][0];parent=git('rev-parse',commit+'^').decode().strip()
 oldnode=nodes(git('show',commit+':'+TREE).decode())[leaf]
 assert field(oldnode,'Status')==q+'done'+q and field(oldnode,'Commit')==field(node,'Commit')
 for name in ['Scope','Baseline evidence','Comprehension','Verification tier','Focused checks','Canonical trigger','Verification']:
  assert field(oldnode,name)==field(node,name),(leaf,name)
  assert field(oldnode,name) not in [q+'pending'+q,q+'in progress'+q],(leaf,name)
 memory=git('show',commit+':MEMORY.md').decode()
 activation=re.search('activation_commit: '+q+'([0-9a-f]+)'+q,memory)[1]
 assert git('rev-parse',activation).decode().strip()==parent,(leaf,activation,parent)
 if prior:subprocess.run(['git','merge-base','--is-ancestor',prior,parent],check=True)
 assert git('ls-tree','-r','-z',commit,'--','julia')==base_tree,leaf
 touched=git('diff-tree','--no-commit-id','--name-only','-r',commit,'--','docs/knowledge/').decode().splitlines()
 assert touched,leaf
 knowledge.update(touched)
 records.append([leaf,commit,parent,subject,len(touched)])
 prior=commit
assert prior==ACTIVATION
for ref in [ACTIVATION,'HEAD']:
 assert git('ls-tree','-r','-z',ref,'--','julia')==base_tree
assert not git('diff','--name-only',BASE,'--','julia').strip()
assert not git('diff','--cached','--name-only','--','julia').strip()
assert not git('ls-files','--others','--exclude-standard','--','julia').strip()
knowledge_records=[]
for path in sorted(knowledge):
 raw=Path(path).read_bytes();content=raw.decode()
 assert content.startswith('---\n') and re.search(r'^answers:\n',content,re.M),path
 assert re.search(r'^id: .+',content,re.M) and re.search(r'^date: .+',content,re.M),path
 assert raw==git('show',ACTIVATION+':'+path),path
 knowledge_records.append([path,len(raw),hashlib.sha256(raw).hexdigest()])
old=nodes(git('show',ACTIVATION+':'+TREE).decode())
repairs=[]
for leaf in sorted(old):
 if re.fullmatch(r'JULIA-STARTUP-READING\.2\..+',leaf):
  assert current[leaf]==old[leaf],leaf
  assert field(current[leaf],'Status')==q+'pending'+q,leaf
  assert re.search(r'^  (?:Acceptance|Children): ',current[leaf],re.M),leaf
  repairs.append([leaf,hashlib.sha256(current[leaf].encode()).hexdigest()])
assert len({r[0].split('.')[2] for r in repairs})==27
report={'activation':ACTIVATION,'baseline':BASE,'source_paths':len(ns['source']),'physical_lines':75984,'fragments':75984,'source_bytes':2693170,'ranges':146,'children':52,'reading_commits':records,'ordered_commit_records_sha256':digest(records),'julia_git_tree_records_sha256':hashlib.sha256(base_tree).hexdigest(),'current_delta_paths':0,'knowledge_paths':len(knowledge_records),'knowledge_records_sha256':digest(knowledge_records),'knowledge_records':knowledge_records,'prior_pending_repair_roots':27,'prior_pending_repair_nodes':len(repairs),'prior_repair_records_sha256':digest(repairs),'prior_repair_records':repairs}
assert len(knowledge_records)==122 and len(repairs)==80
assert digest(records)=='f0651e43a2da2278f15b5e519ef51173aca195e1a75724fe3d517fcfcecc7eb3'
assert hashlib.sha256(base_tree).hexdigest()=='e0de6bebc06edf94aa8555db19ce9544141c84e81f1ff0ed47895c1ef619dead'
assert digest(knowledge_records)=='8414833a3303662c8f25e3b53f3022a3cba7a5d4150a33a08d6befe3e78f1151'
assert digest(repairs)=='4f8bd3153a9f03e298ec46db4d2f913ac2f38cb5a17dd40af4518fde9cfa3505'
Path('.linkedspec-data/scratch/julia31').mkdir(parents=True,exist_ok=True)
Path('.linkedspec-data/scratch/julia31/audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k not in ['reading_commits','knowledge_records','prior_repair_records']},indent=2))
print('PASS exact coverage; all 52 unique committed scopes/comprehension/proof/first-parent activation boundaries; all 52 Julia trees baseline-identical; current source and pending repair/Knowledge continuity.')
JULIA_READING_COMMIT_AUDIT
```

## September 12 audit and component results

| Ordered evidence | SHA-256 |
| --- | --- |
| 52 ordered commit/parent/subject/card-count records | `f0651e43a2da2278f15b5e519ef51173aca195e1a75724fe3d517fcfcecc7eb3` |
| Julia NUL-delimited Git mode/blob/path records | `e0de6bebc06edf94aa8555db19ce9544141c84e81f1ff0ed47895c1ef619dead` |
| 122 fact path/size/hash records | `8414833a3303662c8f25e3b53f3022a3cba7a5d4150a33a08d6befe3e78f1151` |
| 80 pending repair ID/body-hash records | `4f8bd3153a9f03e298ec46db4d2f913ac2f38cb5a17dd40af4518fde9cfa3505` |

All52 child records, every source mode/blob/current byte and all122 touched fact
cards retain exact physical-checkpoint identity. All27 repair roots/80 pending
nodes remain byte-identical; no source, test, contract, gate or dependency changes.
The recipe accepts the original optional final period after quoted Commit fields;
that local parser correction changes no historical record.

The unchanged `bash tools/run_julia_local.sh` completes successfully. Its128
nonoverlapping package summary rows contain12,903 passing assertions. The MCP
binding is byte-fresh at120030 bytes; storage passes22 Julia owners and5 locked
package trees. Primary CLI process conformance and the separate full corpus105/105
pass, followed by the exact local-gate success marker. No whole primary66x2 matrix
or canonical CI is claimed. Component completion was logged September11; this
resumed audit consumed its exit0 result on September12. The dormant authority210
proof remains the separately committed .1.52 result; ordinary discovery is unchanged.

Retained component log: `.linkedspec-data/scratch/julia31/component.log`,430 lines /
23526 bytes, SHA-256 `2ff8ae34256b33c78afa797a24a7b2a921ac4dc7ff10eb1f9b011f6cd77d4a28`.
Exact source and saved CI build-reuse evidence reverify unchanged under
[[rust-ci-pgen-missing-input-rebuilds]]. Relevant canonical/Cargo/recurring drivers
are byte-identical to startup .80.0 commit eaf4331e. The current build-on-update
requirement remains unimplemented; this audit runs no PGEN/RGX compilation.

### Concrete closeout proposal

Julia .3.2 proposes a one-time reading-only exception to the canonical CI/receipt
requirement: accept this committed independent audit and successful unchanged Julia
component gate, reverify their source/repair boundaries, then close only Julia
.1/.3 and startup .3.5 and route Lua .3.6 decomposition. Keep all80 repair nodes,
startup .3/.4/.5 prerequisites, normal hooks and later admission/push verification.
No runtime repair, dormant admission, capacity increase, standing policy or future
verification waiver is proposed. ADR0114 was Dart-only and ADR0116 containment-only;
a newly explicit director decision is required for this different closeout.
The alternative needs authorized CI build-reuse sequencing and compatible canonical
proof before Julia reading-parent closure. .3.1 itself closes no reading parent.

### Component log replay

```bash
bash tools/project_data_run.sh python3 - <<'JULIA_READING_COMPONENT_LOG'
from pathlib import Path
import hashlib,re
raw=Path('.linkedspec-data/scratch/julia31/component.log').read_bytes()
assert len(raw)==23526 and raw.count(b'\n')==430
assert hashlib.sha256(raw).hexdigest()=='2ff8ae34256b33c78afa797a24a7b2a921ac4dc7ff10eb1f9b011f6cd77d4a28'
s=raw.decode();rows=re.findall(r'^([^\n|]+)\|\s+(\d+)\s+(\d+)\s+[^\n]+$',s,re.M)
assert len(rows)==128 and all(a==b for _,a,b in rows)
assert sum(int(a) for _,a,b in rows)==12903
for marker in ['Julia MCP contract binding is byte-fresh (120030 bytes)',
 'Testing LinkedSpecJulia tests passed',
 '[julia-project-data-test] PASS: 22 Julia owners, 5 locked package trees',
 '[julia-primary] primary CLI process conformance passed',
 '105 passed, 0 failed','[julia-ci] Julia local gate passed']:
 assert marker in s,marker
print('PASS exact component log,12903 package assertions,22/5 storage,primary CLI,105 corpus and final marker')
JULIA_READING_COMPONENT_LOG
```

### September12 generated-artifact census

The scheduled read-only .bin/.log census covers .linkedspec-data, rust/target,
Dart, Julia, Lua and the rendered book, without following submodule or external
cache ownership. It records802 project-data files/121111938 bytes and757 Rust
target files/3026026115 bytes;801 and757 respectively are older than24 hours.
Filename and age establish no deletion eligibility. Retain current audit logs and
reusable caches under [[repo-generated-artifact-cleanup-boundary]]; startup .7
still owns stale-run liveness safety. No deletion, dead-process classification
or off-volume scan occurred. Detailed census: .linkedspec-data/scratch/julia31/artifact-census.json.

## September 12 explicit Julia reading closeout

The director answers Granted to the exact .3.2 proposal committed at d62999c12.
ADR0117 records that new one-time reading-only canonical CI/receipt exception.
Both committed audit recipes reexecute from the clean audit commit: all 52 child
records, 95 source trees, 122 fact cards and 80 pending repairs remain exact, with
repair-record SHA 4f8bd3153a9f03e298ec46db4d2f913ac2f38cb5a17dd40af4518fde9cfa3505.
The unchanged complete 12903/storage22-5/primary/105 proof is reused explicitly;
no new component/canonical gate, receipt, dependency build or repair closure.
Only Julia .1/.3/startup .3.5 close; Lua .3.6 decomposition follows.

The startup tree's current frontier still named completed Julia .1.6 and described
Dart reading as pending, despite correct MEMORY, index and child-tree pointers.
This closeout corrects that current view and verifies all three current tree
frontiers plus MEMORY/live status/index route to Lua .3.6. Historical node bodies
and logs remain unchanged. This is a continuity-doc correction under .3.2, not
new runtime behavior or a claim that existing gates detect every stale pointer.
