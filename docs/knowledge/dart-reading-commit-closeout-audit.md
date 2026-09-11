---
id: dart-reading-commit-closeout-audit
title: Every Dart reading child has exact committed coverage and activation evidence
answers:
  - have all 55 Dart reading commits been independently verified
  - which commit is the complete physical Dart reading checkpoint
  - does completed Dart reading mean the component gate passes
  - how are Dart reading repairs preserved at closeout
date: 2026-09-11
status: preparatory audit complete; formal reading closeout requires a separate verification decision
tags: [dart, startup, reading, audit, continuity]
evidence: "DART-STARTUP-READING.3.1 independently checks all 55 child commits at physical checkpoint 1f8f226f: exact scopes, comprehension, verification metadata, first-parent activation and unchanged Dart trees. All115 baseline paths/ 80296 physical lines/ 80297 fragments/ 2471305 bytes, 100 touched Knowledge cards and 62 prior pending repair nodes remain accounted for. Component formatting and strict analysis fail separately; this audit does not close reading parents or repair defects."
reverify: "Run DART_READING_COMMIT_AUDIT below; the frozen checkpoint is intentional, and later source or repair deltas must be reconciled explicitly."
---

# Independent committed-reading evidence

The physical reading checkpoint is `1f8f226f0c34d77e21886ccfc3163c2992359deb`.
The source baseline remains `baeb984e36a94a15951cd23d4c52def5064cdaca`.
The separate [.3.1 audit](../tasks/DART-STARTUP-READING.md) verifies, for each of the
55 children, its unique committed subject, done status, exact scope/baseline evidence,
comprehension, verification tier/checks/trigger and recorded result. Each committed
`MEMORY.md` activation resolves to that commit's actual first parent; ordered reading
commits are ancestors across intervening capacity commits. Every child has exactly
the baseline Dart modes and blobs. Current tracked, staged and untracked source deltas
are empty. The canonical coverage recipe independently reconstructs every byte once.

All 100 Knowledge paths touched by those commits still exist with fact-card metadata
and exact checkpoint bytes. All 23 earlier repair roots / 62 pending nodes retain their
exact bodies. New component-gate repairs `.2.24` and `.2.25` are additional owners;
no previous finding is closed or replaced. The source/reading audit is passing evidence,
not a claim that the full codebase has been read or Dart has zero defects.

| Ordered evidence | SHA-256 |
| --- | --- |
| 55 commit/parent/subject/path-count records | `3ae5b68b24f76a126691bccc6ec72c2c54cb3a04690d141c5353505e2df9636e` |
| Git Dart mode/blob/path records, NUL-delimited | `91abbc7adc036b6a6b244c35925de6b935de66e6275cc1d68f887462d163f1df` |
| 100 Knowledge path/size/hash records | `57e6b394938f06094db490ee6962dbf9c7de086f1a7c0cfd6c189b408ac357bc` |
| 62 prior repair ID/body-hash records | `24bfefe28a06bd6bc0b7bba14c6893965a5a12c314cfe8ab59b1d5372e2c0af5` |

[[dart-component-gate-sdk-compatibility]] records the failed format/strict-analysis
stages and separate remaining-stage diagnostics. Dart `.1`, `.3` and startup `.3.4`
stay open. `.3.2` requires canonical milestone proof or a newly explicit exception;
containment `.11`/ADR0113 waived only that earlier capacity commit. Canonical CI's
current dependency builds conflict with the director's build-on-update requirement,
whose implementation stays owned by startup `.80.1-.4`. No PGEN/RGX build or canonical
CI was run for this audit. A decision to close source reading on this audit must retain
both new repair owners and all existing startup implementation gates.

# Reproduction

This recipe deliberately verifies the immutable physical checkpoint and compares current
source/prior repair evidence against it. Later legitimate source or repair changes require
an explicit delta audit, not silently updating the expected hashes. It writes only a
repository-local report, including the complete ordered commit and evidence tables.

```bash
bash tools/project_data_run.sh python3 - <<'DART_READING_COMMIT_AUDIT'
from pathlib import Path
import contextlib,hashlib,io,json,re,subprocess
BASE='baeb984e36a94a15951cd23d4c52def5064cdaca'
ACTIVATION='1f8f226f0c34d77e21886ccfc3163c2992359deb'
TREE='docs/tasks/DART-STARTUP-READING.md';q=chr(96)
def git(*args):return subprocess.check_output(['git',*args])
def digest(v):return hashlib.sha256(json.dumps(v,ensure_ascii=False,separators=(',',':')).encode()).hexdigest()
def nodes(text):return dict(re.findall(r'^- ID: '+q+'([^'+q+']+)'+q+r'\n(.*?)(?=^- ID: |^## |\Z)',text,re.M|re.S))
def field(node,name):
 values=re.findall(r'^  '+re.escape(name)+r': (.+)$',node,re.M)
 assert len(values)==1,(name,len(values))
 return values[0]
text=Path(TREE).read_text();current=nodes(text)
card=Path('docs/knowledge/dart-startup-reading-coverage.md').read_text()
recipe=card.split("<<'DART_READING_COVERAGE'\n",1)[1].split('\nDART_READING_COVERAGE',1)[0]
ns={}
with contextlib.redirect_stdout(io.StringIO()):
 exec(compile(recipe,'DART_READING_COVERAGE','exec'),ns)
assert ns['read_count']==55
subjects={}
for row in git('log','--format=%H%x09%s',BASE+'..'+ACTIVATION).decode().splitlines():
 commit,subject=row.split('\t',1);subjects.setdefault(subject,[]).append(commit)
records=[];knowledge=set();prior=None
base_tree=git('ls-tree','-r','-z',BASE,'--','dart')
for i in range(1,56):
 leaf='DART-STARTUP-READING.1.'+str(i);node=current[leaf]
 assert field(node,'Status')==q+'done'+q,leaf
 subject=field(node,'Commit').strip(q)
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
 assert git('ls-tree','-r','-z',commit,'--','dart')==base_tree,leaf
 touched=git('diff-tree','--no-commit-id','--name-only','-r',commit,'--','docs/knowledge/').decode().splitlines()
 assert touched,leaf
 knowledge.update(touched)
 records.append([leaf,commit,parent,subject,len(touched)])
 prior=commit
assert prior==ACTIVATION
for ref in [ACTIVATION,'HEAD']:
 assert git('ls-tree','-r','-z',ref,'--','dart')==base_tree
assert not git('diff','--name-only',BASE,'--','dart').strip()
assert not git('diff','--cached','--name-only','--','dart').strip()
assert not git('ls-files','--others','--exclude-standard','--','dart').strip()
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
 if re.fullmatch(r'DART-STARTUP-READING\.2\..+',leaf):
  assert current[leaf]==old[leaf],leaf
  assert field(current[leaf],'Status')==q+'pending'+q,leaf
  assert re.search(r'^  (?:Acceptance|Children): ',current[leaf],re.M),leaf
  repairs.append([leaf,hashlib.sha256(current[leaf].encode()).hexdigest()])
assert len({r[0].split('.')[2] for r in repairs})==23
report={'activation':ACTIVATION,'baseline':BASE,'source_paths':len(ns['source']),'physical_lines':80296,'fragments':80297,'source_bytes':2471305,'ranges':169,'children':55,'reading_commits':records,'ordered_commit_records_sha256':digest(records),'dart_git_tree_records_sha256':hashlib.sha256(base_tree).hexdigest(),'current_delta_paths':0,'knowledge_paths':len(knowledge_records),'knowledge_records_sha256':digest(knowledge_records),'knowledge_records':knowledge_records,'prior_pending_repair_roots':23,'prior_pending_repair_nodes':len(repairs),'prior_repair_records_sha256':digest(repairs),'prior_repair_records':repairs}
Path('.linkedspec-data/scratch/dart31').mkdir(parents=True,exist_ok=True)
Path('.linkedspec-data/scratch/dart31/audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k not in ['reading_commits','knowledge_records','prior_repair_records']},indent=2))
print('PASS exact coverage; all 55 unique committed scopes/comprehension/proof/first-parent activation boundaries; all 55 Dart trees baseline-identical; current source and pending repair/Knowledge continuity.')
DART_READING_COMMIT_AUDIT
```
