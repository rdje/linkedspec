---
id: startup-codebase-reading-inventory
title: Startup reading uses an exhaustive Git baseline with bounded source ranges
answers:
  - is Rust startup reading fully reconciled and committed
  - how large is the required startup codebase reading
  - which code is excluded from startup reading
  - where is complete codebase reading coverage tracked
  - does startup reading include noncore and generated fixtures
  - how are startup reading ranges bounded
  - where is the complete Rust startup reading plan
date: 2026-09-08
status: Perl and Rust reading complete; full codebase reading incomplete; physical mdBook read, formal alignment pending
tags: [continuity, reading, codebase, inventory, task-tree]
evidence: "SESSION-STARTUP-READING.3.1 inventories exact Git blobs at baeb984e36a94a15951cd23d4c52def5064cdaca: 2,547 entries / 52,084,744 stored bytes, including one excluded rgx gitlink, 50 book entries, 1,197 durable-memory entries, 28 root Markdown files, and 1,271 source/tool/fixture entries. Source lanes contain 22,332,523 bytes; 1,267 text entries have 565,122 LF delimiters and four pinned gzip inputs add 54,500 decoded LFs. Enumeration/decompression is not reading credit."
reverify:
  - "git ls-tree -r -l --full-tree baeb984e36a94a15951cd23d4c52def5064cdaca"
  - "git diff --name-only baeb984e36a94a15951cd23d4c52def5064cdaca HEAD"
---

# Recover the reading plan from Git and its task owner

`docs/tasks/SESSION-STARTUP-READING.md` owns the exact ordered, disjoint path selectors, baseline counts,
completed coverage, and executable frontier. The only director-excluded source tree is the `rgx` gitlink and its
nested dependencies. First-party Rust, generated modules, corpus JSON, legacy `noncore`, authored `.spec`,
`conf`, `ebnf`, `tablescript`, test suites, repository tooling, and pinned reference data remain accounted for.

Book files belong to `.4`; root guidance belongs to `.3.10` and the already completed roadmap/bootstrap owners.
Durable task/decision/Knowledge/history records retain their indexed retrieval lifecycle. They are not a second
source tree to read wholesale, and loading the generated Knowledge Map is not codebase comprehension.

Every reading child must name exact files and inclusive ranges before execution. Bound each at 1,500 decoded
text lines and 65,536 bytes, use smaller output chunks, and retain unread suffixes. A single over-limit line
needs explicit byte ranges. The first child `.3.2.1` owns the five facade/invocation/context files at 1,430
lines / 56,706 bytes. The overall codebase answer stays No until complete reading and final delta review.
The physical mdBook answer is now Yes: `.31` and `.3.2.42` preserve complete 50-file coverage; formal
`.4` alignment remains pending. `.3.2.50` reconciles this status wording without granting unread source credit.

Do not copy this inventory into an unbounded parallel manifest. Git stores the exact population and object
identities; the task-tree stores the selectors, ownership, range progress, and completion evidence.

Related: [[linkedspec-pm-is-thin-facade]], [[project-data-liveness-permission-denial]].

## September 6 planning pressure census

Before the native reading split, `.3.2.51` records the slice `.3.2.50` candidate's read-only task
collection census: 100 files / 76,699 lines / 7,789,885 bytes against 128 / 80,000 / 8,388,608.
The general task member limit is 8,000 lines / 1,048,576 bytes; the 5,000-line limits apply only to
explicitly listed future-parity parts. Recompute the resulting collection before adding native children
or their evidence. This measurement neither increases a limit nor requires a partition by itself.
The current route authority is `doctrine/readme_stability/routes.jsonl` surface `task_evidence`.

## Perl closeout and complete Rust ownership

`SESSION-STARTUP-READING.3.2.55` reconciles all 89 Perl files / 2,133,690 bytes across 53 source-reading
leaves and one decomposition checkpoint. All 54 preceding checkpoint subjects exist in Git; their exact
ranges are contiguous and disjoint through every EOF, and all Perl bytes remain baseline-identical.
The parent closeout requires exact staged canonical CI before landing; it closes reading only, with existing
repair owners still pending. The overall codebase answer remains No.

The same leaf owns 66 bounded Rust reading children `.3.3.1`–`.3.3.66` plus `.3.3.67` closeout. Their
412 paths / 3,533,382 bytes include two explicitly owned empty corpus inputs and all generated payloads,
fixtures, manifests and lockfile. The 89,242 per-window lines/fragments include a split logical MCP line;
this is not a distinct full-line count. Both range budgets and exact current baseline identity pass.
Boundary context inspection does not grant full-file reading credit; methods and embedded fixtures crossing
windows retain their explicit suffix owners. The source of truth remains the task's Scope fields and Git.

Reverify Perl coverage and durable checkpoint identities:

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'PERL_READING_AUDIT'
from pathlib import Path
import subprocess,re,json,collections
base='baeb984e36a94a15951cd23d4c52def5064cdaca';q=chr(96)
tree=Path('docs/tasks/SESSION-STARTUP-READING.md').read_text()
nodes=dict(re.findall(r'^- ID: '+q+'([^'+q+']+)'+q+r'\n(.*?)(?=^- ID:|^## Current Frontier)',tree,re.M|re.S))
pop=subprocess.check_output(['git','ls-tree','-r','--name-only',base,'--','perl'],text=True).splitlines()
blobs={p:subprocess.check_output(['git','show',base+':'+p]) for p in pop}
coverage=collections.defaultdict(list);budgets=[]
def add(p,kind,a,b,leaf):
 raw=blobs[p]
 if kind=='lines':
  lines=raw.splitlines(keepends=True);assert 1<=a<=b<=len(lines),(p,a,b,len(lines))
  lo=sum(map(len,lines[:a-1]));hi=lo+sum(map(len,lines[a-1:b]));n=b-a+1
 else:
  assert 1<=a<=b<=len(raw);lo=a-1;hi=b;n=len(raw[lo:hi].splitlines())
 coverage[p].append((lo,hi,leaf));return hi-lo,n
for i in range(1,55):
 leaf='SESSION-STARTUP-READING.3.2.'+str(i);node=nodes[leaf]
 assert '  Status: '+q+'done'+q in node,leaf
 subject=re.search(r'^  Commit: '+q+'([^'+q+']+)'+q,node,re.M).group(1)
 matches=subprocess.check_output(['git','log','--format=%H%x09%s','--fixed-strings','--grep='+subject],text=True).splitlines()
 assert any(x.split('\t',1)[1]==subject for x in matches),leaf
 if i==2:continue
 scope=node.split('  Acceptance: ')[1].split('  Verification tier:')[0] if i==1 else re.search(r'^  Scope: (.+)$',node,re.M).group(1)
 ranges=re.findall(q+'(perl/[^'+q+']+)'+q+r' (?:((?:lines)|(?:bytes)) )?(\d+)–(\d+)',scope)
 assert ranges,leaf
 total_bytes=total_lines=0
 for p,k,a,b in ranges:
  nb,nl=add(p,k or 'lines',int(a),int(b),leaf);total_bytes+=nb;total_lines+=nl
 assert total_bytes<=65536 and total_lines<=1500,(leaf,total_bytes,total_lines)
 budgets.append((leaf,total_bytes,total_lines))
assert set(coverage)==set(pop)
for p,spans in coverage.items():
 spans.sort();cursor=0
 for lo,hi,leaf in spans:assert lo==cursor,(p,cursor,lo,leaf);cursor=hi
 assert cursor==len(blobs[p]),p
 assert Path(p).read_bytes()==blobs[p],p
assert subprocess.check_output(['git','ls-files','--','perl'],text=True).splitlines()==pop
print(json.dumps({'baseline':base,'paths':len(pop),'bytes':sum(map(len,blobs.values())),'reading_leaves':len(budgets),'decomposition_leaves':1,'committed_done_checkpoints':54,'coverage':'exact contiguous, disjoint, through EOF','current_delta':'none','max_leaf_bytes':max(x[1] for x in budgets),'max_leaf_lines_or_fragments':max(x[2] for x in budgets)}))

PERL_READING_AUDIT
```

Reverify the Rust plan directly from its owned Scope fields:

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'RUST_READING_AUDIT'
from pathlib import Path
import subprocess,re,collections,json
base='baeb984e36a94a15951cd23d4c52def5064cdaca';q=chr(96)
text=Path('docs/tasks/SESSION-STARTUP-READING.md').read_text()
paths=subprocess.check_output(['git','ls-tree','-r','--name-only',base,'--','rust'],text=True).splitlines()
blobs={p:subprocess.check_output(['git','show',base+':'+p]) for p in paths}
coverage=collections.defaultdict(list);zero=[];total=0;line_fragments=0
for i in range(1,67):
 pattern=r'^- ID: '+q+r'SESSION-STARTUP-READING\.3\.3\.'+str(i)+q+r'\n(.*?)(?=^- ID:)'
 node=re.search(pattern,text,re.M|re.S).group(1)
 scope=node.split('  Scope: ',1)[1].split('\n  Acceptance:',1)[0]
 declared=re.search(r'group \d+: ([\d,]+) lines/fragments, ([\d,]+) bytes',node)
 expected_lines,expected_bytes=[int(x.replace(',','')) for x in declared.groups()]
 count=size=0
 for p,kind,a,b,empty in re.findall(q+'([^'+q+']+)'+q+r' (?:(lines|bytes) (\d+)–(\d+)|(empty file \(0 bytes\)))',scope):
  raw=blobs[p]
  if empty:assert not raw;zero.append(p);coverage[p].append((0,0));continue
  a=int(a);b=int(b)
  if kind=='lines':
   ll=raw.splitlines(keepends=True);assert 1<=a<=b<=len(ll)
   lo=sum(map(len,ll[:a-1]));hi=lo+sum(map(len,ll[a-1:b]));n=b-a+1
  else:
   assert 1<=a<=b<=len(raw);lo=a-1;hi=b;n=len(raw[lo:hi].splitlines())
  coverage[p].append((lo,hi));size+=hi-lo;count+=n
 assert (count,size)==(expected_lines,expected_bytes),(i,count,size)
 assert count<=1500 and size<=65536
 total+=size;line_fragments+=count
assert set(coverage)==set(paths) and len(zero)==len(set(zero))
for p,spans in coverage.items():
 cursor=0
 for lo,hi in sorted(spans):assert lo==cursor,(p,lo,cursor);cursor=hi
 assert cursor==len(blobs[p]) and Path(p).read_bytes()==blobs[p],p
assert subprocess.check_output(['git','ls-files','--','rust'],text=True).splitlines()==paths
print(json.dumps({'groups':66,'paths':len(paths),'bytes':total,'empty_files':len(zero),'line_fragments':line_fragments,'coverage':'exact; current baseline unchanged'}))

RUST_READING_AUDIT
```

The final `.3.2.55` task candidate measures 100 files / 77,867 lines / 7,874,864
bytes. Its 2,133-line / 513,744-byte aggregate headroom is a dated result, not a growth
allowance. Keep evidence concise, route durable causes to Knowledge, and remeasure before adding later tasks.

## September 8 Rust reading closeout

`SESSION-STARTUP-READING.3.3.67` closes the Rust reading lane after all sixty-six
reading children landed. Reverification accounts for all 412 baseline paths /
3,533,382 bytes, both empty files and 89,242 per-window lines/fragments, with exact
contiguous disjoint coverage. File modes, Git blobs and present bytes are unchanged;
there are no current Rust additions, deletions or nonignored untracked inputs.

All sixty-six exact reading subjects resolve to unique commits from `08149577`
through `b8806f9a`; their verification metadata is complete. The 141 Knowledge
paths changed by those commits still exist with fact metadata. This is continuity
and source-reading reconciliation, not a fresh claim that every runtime route passes.

The 34 post-Perl repair owners `.45`–`.47` and `.49`–`.79` retain 90 pending
nodes and 73 pending leaves. Earlier and cross-cutting repair owners also remain
open. Exact source/behavior findings and emitted-versus-helper proof limits remain
in those task nodes and their canonical Knowledge cards; no repair is closed by
reading completion. Receipt-bound canonical CI is required for this parent
closeout, with the actual run outcome retained in its commit and local receipt.

The next action is `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7`, before Dart child
decomposition or source reading. The full-codebase answer stays No. The required
PGEN → RGX → LinkedSpec Rust build chain and its expected nested generated state
are unchanged and are not a blocker.

Run the existing Rust scope audit above, then independently verify durable
checkpoint, mode/delta, repair and Knowledge-path continuity:

```bash
bash tools/project_data_run.sh python3 - <<'RUST_READING_CLOSEOUT_AUDIT'
from pathlib import Path
import subprocess,re,json,hashlib
base='baeb984e36a94a15951cd23d4c52def5064cdaca';q=chr(96)
tree=Path('docs/tasks/SESSION-STARTUP-READING.md').read_text()
nodes=dict(re.findall(r'^- ID: '+q+'([^'+q+']+)'+q+r'\n(.*?)(?=^- ID:|^## Current Frontier)',tree,re.M|re.S))
rows=subprocess.check_output(['git','log','--format=%H%x09%s',base+'..HEAD'],text=True).splitlines()
subjects={}
for row in rows:
 commit,subject=row.split('\t',1);subjects.setdefault(subject,[]).append(commit)
done=[]
for i in range(1,67):
 leaf='SESSION-STARTUP-READING.3.3.'+str(i);node=nodes[leaf]
 assert re.search(r'^  Status: '+q+'done'+q+'$',node,re.M),leaf
 assert not re.search(r'^  Verification: '+q+'pending'+q,node,re.M),leaf
 subject=re.search(r'^  Commit: '+q+'([^'+q+']+)'+q,node,re.M).group(1)
 assert len(subjects.get(subject,[]))==1,(leaf,subjects.get(subject))
 done.append([leaf,subjects[subject][0],subject])
 assert re.search(r'^  Verification tier: '+q+'(focused|canonical)'+q+'$',node,re.M),leaf
 assert len(re.findall(r'^  Focused checks:',node,re.M))==1,leaf
 assert len(re.findall(r'^  Canonical trigger:',node,re.M))==1,leaf
baseline_tree=subprocess.check_output(['git','ls-tree','-r','-z',base,'--','rust'])
current_tree=subprocess.check_output(['git','ls-tree','-r','-z','HEAD','--','rust'])
assert baseline_tree==current_tree
assert not subprocess.check_output(['git','diff',base,'HEAD','--name-status','--','rust']).strip()
assert not subprocess.check_output(['git','diff','--name-status','--','rust']).strip()
assert not subprocess.check_output(['git','diff','--cached','--name-status','--','rust']).strip()
assert not subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','rust']).strip()
repairs=[];repair_nodes=set();repair_leaves=set()
def audit_repair(leaf):
 assert leaf not in repair_nodes,leaf
 repair_nodes.add(leaf);node=nodes[leaf]
 assert re.search(r'^  Status: '+q+'pending'+q+'$',node,re.M),leaf
 children=re.search(r'^  Children: (.+)',node,re.M)
 if children:
  for child in re.findall(q+'([^'+q+']+)'+q,children.group(1)):
   audit_repair('SESSION-STARTUP-READING'+child if child.startswith('.') else child)
 else:
  assert re.search(r'^  Acceptance:',node,re.M),leaf
  assert re.search(r'^  (?:Evidence|Verification):',node,re.M),leaf
  repair_leaves.add(leaf)
for i in [45,46,47,*range(49,80)]:
 leaf='SESSION-STARTUP-READING.'+str(i);node=nodes[leaf]
 audit_repair(leaf)
 goal=re.search(r'^  Goal: (.+)',node,re.M).group(1)
 repairs.append([leaf,goal])
root=nodes['SESSION-STARTUP-READING']
assert all(q+leaf+q in root for leaf,_ in repairs)
body=json.dumps(done,ensure_ascii=False,separators=(',',':')).encode()
repair_payload=json.dumps([[leaf,nodes[leaf]] for leaf in sorted(repair_nodes)],ensure_ascii=False,separators=(',',':')).encode()
knowledge_paths=set()
for _,commit,_ in done:
 knowledge_paths.update(subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r',commit,'--','docs/knowledge'],text=True).splitlines())
for path in knowledge_paths:
 assert Path(path).is_file(),path
 content=Path(path).read_text()
 assert content.startswith('---'+chr(10)),path
 assert re.search(r'^id: ',content,re.M) and re.search(r'^answers:',content,re.M),path
print(json.dumps({'baseline':base,'reading_children_done_and_uniquely_committed':len(done),
'reading_commit_subject_audit_sha256':hashlib.sha256(body).hexdigest(),
'baseline_current_tree_sha256':hashlib.sha256(baseline_tree).hexdigest(),
'current_rust_additions_deletions_modes_or_blob_changes':0,
'current_rust_uncommitted_or_nonignored_untracked':0,
'pending_post_Perl_repair_owners':len(repairs),'pending_owned_repair_nodes':len(repair_nodes),
'pending_owned_repair_leaves':len(repair_leaves),'pending_repair_node_bytes_sha256':hashlib.sha256(repair_payload).hexdigest(),
'knowledge_paths_touched_by_reading_commits_and_still_present':len(knowledge_paths),
'first_reading_commit':done[0][1],'last_reading_commit':done[-1][1]}))
RUST_READING_CLOSEOUT_AUDIT
```

The reading-commit tuple digest is
`312b1b4c03b2ad3897765e283c9772a7536122b39ee6d5740dff90874b860815`;
the unchanged Rust tree-record digest is
`53e7795d9405342897bd3990e8fd55ee3a8cfdddb6e67dc977fefcb72dd3b68b`.
The 90 pending repair-node bodies hash to
`3664cc76bff42040631d688fee5fa75bd4410f6588e1fd9eb45a882532ea967b`.
These dated digests are comparison evidence, not constraints against future
task-owned repair progress.

## September 13 conformance/test/Unicode decomposition

Supporting reading and its exact checker correction are complete under ADR0120.
Startup `.3.8.0` now owns all160 conformance/test/Unicode baseline inputs in
`docs/tasks/CONFORMANCE-SOURCE-READING.md`:143 groups/302 exact ranges,8,257,059
decoded bytes and167,606 fragments. The four pinned gzip inputs contribute54,500
decoded lines. No new physical-reading credit is granted by enumeration or hashes.
Exact current source/decoding/range replay: [[conformance-source-reading-coverage]].
