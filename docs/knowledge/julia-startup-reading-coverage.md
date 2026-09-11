---
id: julia-startup-reading-coverage
title: Julia startup reading owns every baseline byte in 52 bounded children
answers:
  - how is Julia startup reading decomposed
  - how do I verify exact Julia reading coverage
  - which baseline and digests govern Julia source reading
  - does Julia reading need a separate task-tree member
  - which owner handles Julia reading capacity and history pressure
date: 2026-09-11
status: exact plan frozen; physical reading credit lives in the owning children
tags: [julia, startup, reading, coverage, capacity, continuity]
evidence: "Startup .3.5.0 verifies 95 baseline-identical Julia files /75984 physical lines /2693170 bytes and freezes 52 children /146 ranges. Every byte is independently reconstructed exactly once; no oversized or empty source entry requires special coordinates. Source reading remains 0/52 at decomposition. Current evidence fits unchanged limits; future history pressure has an explicit owner and no preapproved capacity increase."
reverify:
  - "Run the repository-managed JULIA_READING_COVERAGE block below."
  - "bash tools/project_data_run.sh perl scripts/check_readme_routing_pressure.pl --report"
  - "perl tools/roll_document_history.pl --surface change_history --check && perl tools/roll_document_history.pl --surface engineering_notes --check"
---

# Exact Julia source ownership

Startup `SESSION-STARTUP-READING.3.5.0` starts from clean Dart reading closure
`a2788b95369964880534d4d7b1d0e31b106bc023`. The separate execution tree is
`docs/tasks/JULIA-STARTUP-READING.md`, with 52 pending children under `.1`, repair
intake `.2`, independent closeout `.3` and capacity intake `.4`. Startup `.3.5`
retains its original reading-prerequisite role. ADR0114 grants no Julia closeout waiver.

The source baseline is `baeb984e36a94a15951cd23d4c52def5064cdaca`.
All 95 paths, modes/blobs and current bytes match it exactly: 75,984 LF physical
lines and 2,693,170 bytes. Greedy ordered packing uses the existing 1,500-fragment /
65,536-byte reading bounds. No source entry is empty and no physical line needs an
oversized-line byte split. The 52 groups produce 146 inclusive source ranges.

Inventory SHA-256: `ca3cff4fe4c0e162448d6dbac82d89898673023951afaeced17d5b9a838ccd10`.
Ordered range SHA-256: `fde325f80ae7b56c5890d149fbc965c09890890e963a1fa9aab08e8c9d962337`.
Child-summary SHA-256: `b579d885897e935c843d8720b5b2540ca9f2d53f35d0ade481ce4019b3c78f0c`.
Each child retains its own counts and digest. Physical reading, comprehension,
relevant diagnostics and a clean commit are still required before that child is done.
This audit grants no source-reading or parser correctness credit.

# Evidence capacity and future history pressure

The minimal 52-child estimate needs 572 lines /34,666 bytes, exceeding the startup
file's remaining member space at activation. A separate bounded Julia member holds
the complete concrete plan in 639 lines /48,991 bytes without changing any limit.
The current task/Knowledge/routing checks include this new member and the actual
resulting documentation. Future unknown findings remain subject to every leaf's gates.

As a comparable-run reference, the 55 actual Dart reading commits add net 1,144 task
lines /245,095 bytes and 5,490 Knowledge lines /377,493 bytes. Their derived map grows
387 lines /77,475 bytes. Those figures come from summing each exact child commit's
parent-to-child diff; capacity/intake commits between them are excluded. Applying this
whole 55-child reference to the 52-child Julia plan is a forecast, not a reserved or
guaranteed allowance. Knowledge line capacity is tight and must be remeasured.

Those same commits add 390 change-history lines and 450 engineering-note lines.
Both history collections currently use every admitted member slot. Their current hot
roots can hold the decomposition and initial reading, while comparable-run volume
will require later rollovers and additional disposition. Julia `.4` owns that work
before a required rollover exceeds capacity. It must preserve immutable history,
measure exact controls and obtain any required capacity authorization; no archive
slot or future ceiling increase is preapproved by this reading plan.

Do not rewrite old evidence or compress unique findings away to force a leaf through
a gate. Assess the complete next candidate before activating it; use a clean capacity
checkpoint when its required commit no longer fits. Source repairs retain startup
`.3/.4/.5`, and the existing Dart gate failures remain open under their original owners.

# Independent reconstruction from the actual task scopes

The following recipe parses the frozen task scopes independently of the packing
algorithm, compares mode/blob/current membership and bytes, verifies every child
bound/digest and requires disjoint coverage through every EOF. Later legitimate
source edits require an explicit delta audit rather than replacing expected hashes.

```bash
bash tools/project_data_run.sh python3 - <<'JULIA_READING_COVERAGE'
from pathlib import Path
import subprocess,re,hashlib,json
BASE='baeb984e36a94a15951cd23d4c52def5064cdaca'
q=chr(96)
def git(*args):return subprocess.check_output(['git',*args])
def digest(value):return hashlib.sha256(json.dumps(value,ensure_ascii=False,separators=(',',':')).encode()).hexdigest()
def entries(ref):
 result={}
 for row in git('ls-tree','-rz',ref,'--','julia').split(b'\0'):
  if not row:continue
  meta,path=row.split(b'\t',1);result[path.decode()]=tuple(meta.decode().split())
 return result
baseline=entries(BASE);assert len(baseline)==95 and entries('HEAD')==baseline
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
assert not git('diff','--name-only',BASE,'--','julia')
assert not git('ls-files','--others','--exclude-standard','--','julia').strip()
def count(raw):return raw.count(b'\n')+int(bool(raw) and not raw.endswith(b'\n'))
assert sum(map(len,source.values()))==2693170
assert sum(count(v) for v in source.values())==75984
inventory=[(p,*baseline[p],len(source[p]),hashlib.sha256(source[p]).hexdigest()) for p in paths]
assert digest(inventory)=='ca3cff4fe4c0e162448d6dbac82d89898673023951afaeced17d5b9a838ccd10'
tree=Path('docs/tasks/JULIA-STARTUP-READING.md').read_text()
nodes=re.findall(r'^- ID: '+q+r'JULIA-STARTUP-READING\.1\.(\d+)'+q+r'\n(.*?)(?=^- ID: |^## |\Z)',tree,re.M|re.S)
assert [int(n) for n,_ in nodes]==list(range(1,53))
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
assert len(ranges)==146 and all(row[1]=='lines' for row in ranges)
assert sum(t[1] for t in totals)==75984 and sum(t[2] for t in totals)==2693170
assert digest(ranges)=='fde325f80ae7b56c5890d149fbc965c09890890e963a1fa9aab08e8c9d962337'
print(json.dumps({'baseline':BASE,'paths':95,'physical_lines':75984,'bytes':2693170,'groups':52,'ranges':146,'fragments':75984,'done':done,'inventory_sha256':digest(inventory),'range_sha256':digest(ranges),'child_summary_sha256':digest(totals)},indent=2))
print('PASS exact current Julia baseline identity, independent owned-range reconstruction and every child bound/digest; reading credit stays in child records.')
JULIA_READING_COVERAGE
```
