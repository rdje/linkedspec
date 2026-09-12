---
id: lua-startup-reading-coverage
title: Lua startup reading owns every baseline byte in 51 bounded children
answers:
  - how is Lua startup reading decomposed
  - how do I verify exact Lua reading coverage
  - which baseline and digests govern Lua source reading
  - how are oversized Lua source lines split for reading
  - which owner handles Lua reading evidence capacity
  - how much evidence did the comparable Julia reading run add
date: 2026-09-12
status: exact plan frozen; physical reading pending; capacity disposition next
tags: [lua, startup, reading, coverage, capacity, continuity]
evidence: "Startup .3.6.0 owns 99 baseline-identical files / 71268 physical lines / 2732450 bytes in 51 children and 149 ranges. Two byte windows split one generated MCP line, producing 71269 fragments without overlap. Lua .4.1 owns activity-sized capacity disposition before source reading."
reverify:
  - "Run LUA_READING_COVERAGE and LUA_COMPARABLE_READING_GROWTH below through the repository-managed wrappers."
  - "bash tools/project_data_run.sh perl scripts/check_readme_routing_pressure.pl --report"
---

# Exact Lua reading ownership

Startup `SESSION-STARTUP-READING.3.6.0` activates from clean Julia reading closeout
`9824c097148235268964acbdf47984d9933753a8`. The execution tree is
`docs/tasks/LUA-STARTUP-READING.md`: 51 pending reading children under .1,
repair intake .2, independent closeout .3 and coherent capacity assessment .4.1.
Startup .3.6 remains the prerequisite owner. ADR0117 closes only Julia reading.

All 99 baseline entries, modes, blobs and current bytes match
`baeb984e36a94a15951cd23d4c52def5064cdaca`. There are 71,268 LF physical lines and
2,732,450 bytes. Generated tables, native adapters, both-ABI consumers and the
9,517-line test runner all remain in scope. Enumeration grants no comprehension.

Ordered greedy packing bounds each child to 1,500 fragments / 65,536 bytes.
The 82,904-byte generated line in `lua/src/linkedspec/mcp_contract.lua` is
isolated into absolute byte ranges 261–65,796 and 65,797–83,164. Both decode as
UTF-8; their concatenation reproduces the original line exactly. The preceding
and following physical lines retain line coordinates. Splitting adds one
fragment: 71,269 per-window fragments still cover exactly 71,268 physical lines.
No file is empty. Actual viewing must use smaller untruncated windows and retain
continuation context across the generated line; hashes do not replace reading.

Inventory SHA-256: `6906b93bb89cf5c03764ad0cd0d934f107f0e6d6c9a85f9529d22fcccbbde304`.
Range SHA-256: `81c58b8319def28af518fb134a3787513fe746f0f0f73bcacb0e20b9ede1c9d6`.
Child-summary SHA-256: `f56ecac262800bd3cc1e6bba0cc25bfe22f095c3dfee41f1c6595d4200145290`.

# Capacity finding and next owner

The new bounded tree is 638 lines / 43,517 bytes. It fits the task collection's
unchanged 88,000-line ceiling, while retaining startup member space. Capacity is
measured on the entire resulting candidate before commit, including this card.
No root README, registry, verifier, source, historical decision or archive changes.

At activation, Knowledge uses 73,733 / 79,000 lines. The exact 52 Julia reading
commits add 6,615 Knowledge lines / 402,364 bytes / 27 files, excluding separate
capacity and audit commits. This comparable workload exceeds the available
5,267 lines even before adding Lua decomposition and support work. It is a
forecast of future pressure, not a claim that the current candidate is over cap.
Lua .4.1 therefore prepares a complete activity-sized disposition before reading
activation, following ADR0115's proportionate planning principle.

| Surface | Comparable 52-child growth: lines | Bytes | New files |
| --- | ---: | ---: | ---: |
| Knowledge cards | 6615 | 402364 | 27 |
| Task evidence | 1458 | 272319 | 0 |
| Derived map | 378 | 68286 | 0 |
| New change-history records | 364 | 21462 | 0 |
| New engineering-note records | 365 | 20301 | 0 |

History rows measure each newly prepended complete record. Net hot-root diffs
would incorrectly subtract rollover history, so they are not a growth forecast.
The replay below derives these values from committed bytes, not saved scratch.
Per-child maxima and exact commit identities are also reproduced for .4.1.
Reference-record SHA-256: `5443fea728d96f58f3d647128e53d80ca3711c527b9389dfaced81f77a79ba1d`.

The complete future plan must consider cards, task evidence, decisions, map and
history membership/rollover limits together. Existing Julia allowances are finite
and grant no Lua capacity or canonical exception. Preserve unique readable
information; splitting members cannot lower aggregate volume. No Lua runtime gate,
new source-reading credit, repair completion or dependency build is claimed here.

# Independent reconstruction of declared scopes

This reader parses the actual task declarations independently of the packing
algorithm. Later legitimate source changes require an explicit delta audit.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_READING_COVERAGE'
from pathlib import Path
import subprocess,re,hashlib,json
BASE='baeb984e36a94a15951cd23d4c52def5064cdaca'
q=chr(96)
def git(*args):return subprocess.check_output(['git',*args])
def digest(value):return hashlib.sha256(json.dumps(value,ensure_ascii=False,separators=(',',':')).encode()).hexdigest()
def entries(ref):
 result={}
 for row in git('ls-tree','-rz',ref,'--','lua').split(b'\0'):
  if not row:continue
  meta,path=row.split(b'\t',1);result[path.decode()]=tuple(meta.decode().split())
 return result
baseline=entries(BASE);assert len(baseline)==99 and entries('HEAD')==baseline
paths=sorted(baseline);source={}
request=b''.join((baseline[p][2]+'\n').encode() for p in paths)
batch=subprocess.check_output(['git','cat-file','--batch'],input=request);offset=0
for p in paths:
 end=batch.index(b'\n',offset);oid,kind,size=batch[offset:end].split();size=int(size)
 assert kind==b'blob' and oid.decode()==baseline[p][2]
 raw=batch[end+1:end+1+size];offset=end+1+size+1
 assert batch[offset-1:offset]==b'\n' and raw==Path(p).read_bytes(),p
 raw.decode('utf-8');source[p]=raw
assert offset==len(batch)
assert not git('diff','--name-only',BASE,'--','lua')
assert not git('ls-files','--others','--exclude-standard','--','lua').strip()
def count(raw):return raw.count(b'\n')+int(bool(raw) and not raw.endswith(b'\n'))
assert sum(map(len,source.values()))==2732450
assert sum(count(v) for v in source.values())==71268
inventory=[(p,*baseline[p],len(source[p]),hashlib.sha256(source[p]).hexdigest()) for p in paths]
assert digest(inventory)=='6906b93bb89cf5c03764ad0cd0d934f107f0e6d6c9a85f9529d22fcccbbde304'
tree=Path('docs/tasks/LUA-STARTUP-READING.md').read_text()
nodes=re.findall(r'^- ID: '+q+r'LUA-STARTUP-READING\.1\.(\d+)'+q+r'\n(.*?)(?=^- ID: |^## |\Z)',tree,re.M|re.S)
assert [int(n) for n,_ in nodes]==list(range(1,52))
covered={p:0 for p in paths};ranges=[];totals=[];done=0
for number,node in nodes:
 scope=re.search(r'^  Scope: (.+)$',node,re.M)[1]
 expected=re.search(r'^  Baseline evidence: (\d+) fragments / (\d+) bytes; ordered range SHA-256 '+q+'([0-9a-f]{64})'+q+r'\.$',node,re.M)
 assert expected is not None
 rows=[];fragments=size=0
 for field in scope.split('; '):
  m=re.fullmatch(q+'([^'+q+']+)'+q+r' (lines|bytes|empty) (\d+)-(\d+)',field);assert m,field
  p,kind,a,b=m.groups();a,b=int(a),int(b);raw=source[p]
  if kind=='lines':
   lines=raw.splitlines(keepends=True);assert len(lines)==count(raw)
   assert 1<=a<=b<=len(lines);begin=sum(map(len,lines[:a-1]));part=b''.join(lines[a-1:b])
  elif kind=='bytes':
   assert 1<=a<=b<=len(raw);begin=a-1;part=raw[begin:b]
  else:
   assert a==b==0 and not raw;begin=0;part=b''
  part.decode('utf-8');assert begin==covered[p],(number,p,begin,covered[p])
  covered[p]+=len(part);fragments+=count(part);size+=len(part)
  rows.append([p,kind,a,b,len(part),hashlib.sha256(part).hexdigest()])
 assert (fragments,size,digest(rows))==(int(expected[1]),int(expected[2]),expected[3]),number
 assert fragments<=1500 and size<=65536
 ranges.extend(rows);totals.append([int(number),fragments,size,len(rows),digest(rows)])
 done+=bool(re.search(r'^  Status: '+q+'done'+q+r'$',node,re.M))
assert all(covered[p]==len(source[p]) for p in paths)
assert len(ranges)==149 and sum(row[1]=='bytes' for row in ranges)==2
assert sum(t[1] for t in totals)==71269 and sum(t[2] for t in totals)==2732450
assert digest(ranges)=='81c58b8319def28af518fb134a3787513fe746f0f0f73bcacb0e20b9ede1c9d6'
assert digest(totals)=='f56ecac262800bd3cc1e6bba0cc25bfe22f095c3dfee41f1c6595d4200145290'
print(json.dumps({'baseline':BASE,'paths':99,'physical_lines':71268,'bytes':2732450,'groups':51,'ranges':149,'fragments':71269,'done':done,'inventory_sha256':digest(inventory),'range_sha256':digest(ranges),'child_summary_sha256':digest(totals)},indent=2))
print('PASS exact current Lua baseline identity, independent owned-range reconstruction and every child bound/digest; reading credit stays in child records.')
LUA_READING_COVERAGE
```

# Comparable committed reading growth

```bash
bash tools/project_data_run.sh python3 - <<'LUA_COMPARABLE_READING_GROWTH'
from pathlib import Path
import subprocess,json,re,hashlib
CHECKPOINT='2c70957a26a4ae6066bc8d80f2aa7a6791a3f953'
def git(*args):return subprocess.check_output(['git',*args])
def digest(value):return hashlib.sha256(json.dumps(value,ensure_ascii=False,separators=(',',':')).encode()).hexdigest()
commits={}
for line in git('log',CHECKPOINT,'--format=%H%x09%s','--fixed-strings','--grep=JULIA-STARTUP-READING.1.').decode().splitlines():
 m=re.fullmatch(r'([0-9a-f]+)\tJULIA-STARTUP-READING\.1\.(\d+) - .+',line)
 if m:
  number=int(m[2]);assert number not in commits;commits[number]=m[1]
assert sorted(commits)==list(range(1,53))
records=[]
for number,commit in sorted(commits.items()):
 growth={k:{'lines':0,'bytes':0,'new_files':0} for k in ['knowledge','tasks','map','changes','notes']}
 for line in git('diff','--numstat',commit+'^',commit).decode().splitlines():
  added,removed,path=line.split('\t')
  category='knowledge' if path.startswith('docs/knowledge/') else 'tasks' if path.startswith('docs/tasks/') else {'KNOWLEDGE_MAP.md':'map'}.get(path)
  if category is None:continue
  before=subprocess.run(['git','cat-file','blob',commit+'^:'+path],capture_output=True)
  after=git('cat-file','blob',commit+':'+path)
  growth[category]['lines']+=int(added)-int(removed)
  growth[category]['bytes']+=len(after)-len(before.stdout)
  growth[category]['new_files']+=int(before.returncode!=0)
 for key,path in [('changes','CHANGES.md'),('notes','DEVELOPMENT_NOTES.md')]:
  raw=git('show',commit+':'+path);heads=list(re.finditer(rb'^## ',raw,re.M))
  record=raw[heads[0].start():heads[1].start()]
  assert b'2026-09-11' in record.splitlines()[0]
  growth[key]={'lines':record.count(b'\n'),'bytes':len(record),'new_files':0}
 records.append({'number':number,'commit':commit,'growth':growth})
assert digest(records)=='5443fea728d96f58f3d647128e53d80ca3711c527b9389dfaced81f77a79ba1d'
for name in records[0]['growth']:
 total={k:sum(r['growth'][name][k] for r in records) for k in ['lines','bytes','new_files']}
 maximum={k:max(r['growth'][name][k] for r in records) for k in ['lines','bytes','new_files']}
 print(name,json.dumps({'total':total,'maximum_per_child':maximum},sort_keys=True))
print('PASS exact 52-commit comparable growth; first new history records exclude rollover subtraction; SHA',digest(records))
LUA_COMPARABLE_READING_GROWTH
```
