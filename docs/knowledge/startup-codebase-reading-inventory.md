---
id: startup-codebase-reading-inventory
title: Startup reading uses an exhaustive Git baseline with bounded source ranges
answers:
  - how large is the required startup codebase reading
  - which code is excluded from startup reading
  - where is complete codebase reading coverage tracked
  - does startup reading include noncore and generated fixtures
  - how are startup reading ranges bounded
  - where is the complete Rust startup reading plan
date: 2026-09-06
status: inventory complete; codebase reading incomplete; physical mdBook reading complete, formal alignment pending
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
