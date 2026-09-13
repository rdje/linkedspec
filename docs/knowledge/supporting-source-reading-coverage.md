---
id: supporting-source-reading-coverage
title: Supporting-source reading owns 158 unchanged files through 21 bounded groups
answers:
  - what source remains under startup supporting lane 3.7
  - where are the exact supporting-source reading ranges owned
  - do supporting configuration files count as TypeScript
  - how much prior supporting-source reading credit is established
  - does supporting-source reading require rebuilding RGX or PGEN
date: 2026-09-13
status: original inventory preserved; required reading and formal startup .3.7 closeout complete under ADR0120
tags: [startup, reading, supporting, inventory, continuity]
evidence: "SESSION-STARTUP-READING.3.7.0; clean Lua closeout 735f0337883baef5ac4422976879d09725e0e8ea; baseline baeb984e36a94a15951cd23d4c52def5064cdaca."
reverify: "Run SUPPORTING_SOURCE_INVENTORY, SUPPORTING_SOURCE_PLAN, SUPPORTING_SOURCE_TREE and SUPPORTING_CURRENT_GROUP17/18/19 below; these identity/range audits grant no additional physical reading credit."
---

# Exact supporting-source inventory

Startup .3.7 owns the five prefixes below. All 158 Git modes/blobs and present
bytes match the frozen startup baseline and clean Lua-closeout checkpoint.
There are 25,612 LF delimiters, 25,613 physical-line fragments and 964,256 bytes.
Every file is nonempty UTF-8 text; none requires binary decoding or an oversized
single-line split. The longest line is 11,763 bytes at `specs/spec.spec` line 167;
reading still needs small complete output windows.

| Prefix | Files | Fragments | Bytes |
| --- | ---: | ---: | ---: |
| conf | 58 | 6,652 | 237,642 |
| tablescript | 23 | 1,670 | 52,715 |
| noncore | 49 | 13,288 | 457,360 |
| specs | 21 | 2,077 | 153,214 |
| ebnf | 7 | 1,926 | 63,325 |
| Total | 158 | 25,613 | 964,256 |

`docs/tasks/SUPPORTING-SOURCE-READING.md` owns all 21 reading groups and 174
inclusive line ranges. Its first five groups cover configuration, two cover
TableScript data, nine legacy adapters/plugins, three authored specs and two EBNF.
Every group fits 1,500 fragments and 65,536 bytes. The independent task/Git replay
reconstructs every byte through each EOF exactly once; source identity and complete
range planning are distinct from actually reading and understanding the contents.

The existing exhaustive startup inventory already identifies `tablescript/*.ts`
as data for the legacy TableScript surface, not TypeScript source. This plan
preserves that scope and existing semantic owners; it makes no new runtime claim.
The existing startup Scope records contain no exact ranges for these five prefixes.
Prior isolated probes, filename mentions, source mirrors and Knowledge facts are
not converted into complete physical-file reading credit. All 21 children start
pending, with exact earlier facts retrieved before interpreting each source slice.

The source inventory is recoverable from Git and the prefix selectors, rather
than a second committed path manifest. The task's Scope fields own every range;
the JSON reports below are generated under repo-local scratch. A later legitimate
source change requires an explicit delta audit, not rewriting historical evidence.

| Identity | SHA-256 |
| --- | --- |
| NUL-delimited Git mode/blob/path records | `e7845e3f7fa04a9929b20834fd0b799092063930ecb921b195cfe972c6a252b8` |
| Ordered inventory path/mode/blob/count/hash records | `0bd5e398ef52c2de0f2389d8931b4543c112f43401842b74306310c80cdb9ec1` |
| Ordered 21-group plan with 174 ranges | `2a4bd96b87345719946abad085eb7b2b934dcacd063ab421a2447ea036a4903c` |

# Current reading disposition — 2026-09-13

`SUPPORTING-SOURCE-READING.1.1` retains its completed 1,500 fragments /61,165 bytes
through 29 windows. `.0` retired further conf/TableScript reading while retaining
the exact focused 53-conf/23-TableScript/seven-EBNF corpus smoke. The director then
clarified that whole historical spec/config/Perl application bundles are outside
the current path. `.4` reconciles current grammar roles and quarantined code.

Three current grammar files remain required: `specs/spec.spec`,
`specs/user_function_definition.spec` and the existing compatibility dependency
`specs/pplugin.spec`. Exact Required reading scope overlays in `.1.17-.1.19`
cover five ranges /629 fragments /96,781 bytes. Seventeen original groups are
superseded; other intervals of the mixed specs groups are also explicit omissions.
All original Scope/digests, completed historical reading, source/test bytes and
repair owners remain exact. No omitted-byte reading is credited.

Original inventory/plan/tree recipes below continue to reconstruct the frozen
158-file/174-range inventory. They do not equate inventory with current required
reading. Current dependency evidence and scope replay live in
[[current-supporting-grammar-dependencies]]. The earlier .0 evidence remains in
[[legacy-configuration-source-contracts]], with its task input pinned to its dated
commit for honest historical replay.

# Current grammar group .1.17 — 2026-09-13

All seven complete windows of the Required reading scope are physically read:
`specs/pplugin.spec`1–33 and `specs/spec.spec`1–146, totaling 179 fragments/26,444
bytes. The pplugin file reaches EOF; the self-hosted grammar suffix remains .1.18.
The original wider Scope stays inventory only. Current required reading is 1/3;
450 fragments/70,337 bytes remain, distinct from completed historical .1.1 and
seventeen superseded groups. No new defect or repair closure is established.

| Window | File | Inclusive lines | Bytes |
| --- | --- | --- | ---: |
| 1 | specs/pplugin.spec | 1–33 | 650 |
| 2 | specs/spec.spec | 1–108 | 6,468 |
| 3 | specs/spec.spec | 109–126 | 775 |
| 4 | specs/spec.spec | 127–139 | 6,471 |
| 5 | specs/spec.spec | 140–142 | 143 |
| 6 | specs/spec.spec | 143 | 11,758 |
| 7 | specs/spec.spec | 144–146 | 179 |

Window2 was displayed in adjacent complete excerpts1–94 and95–108; all windows
are completely consumed. The long Unicode action pattern is one complete line,
not a truncated or omitted interval. Ordered range SHA-256 is
`910001b25a8dc5581ff6254cb39f5bc5888dbb3c1665af061fa8edc0205a6e39`;
ordered window SHA-256 is
`254938dc997bd16d9511d0cbff833be5b7cc064b4225f09bab674aa03ef8a3e2`.
The independent replay verifies baseline identity and reconstructs these bounds;
it does not create physical reading credit by itself.

Comprehension and exact paragraph/body-text probe:
[[spec-spec-self-hosted-grammar]] and
[[pplugin-descriptor-ready-legacy-runtime-boundary]]. The Unicode/mirror check
passes 806 ranges, nine positive labels, eight negatives and two distinct pairs.
No adapter callback, dependency build or complete native matrix is executed.

```bash
bash tools/project_data_run.sh python3 - <<'SUPPORTING_CURRENT_GROUP17'
from pathlib import Path
import hashlib, json, re, subprocess

baseline = 'baeb984e36a94a15951cd23d4c52def5064cdaca'
tree = Path('docs/tasks/SUPPORTING-SOURCE-READING.md').read_text()
node = re.search(r'^- ID: `SUPPORTING-SOURCE-READING\.1\.17`\n.*?(?=^- ID: |^## |\Z)', tree, re.M | re.S)[0]
scope = re.search(r'^  Required reading scope: (.+)$', node, re.M)[1]
found = [(p, int(a), int(b)) for p, a, b in re.findall(r'`([^`]+)` lines (\d+)-(\d+)', scope)]
assert found == [('specs/pplugin.spec', 1, 33), ('specs/spec.spec', 1, 146)]
ranges, windows = [], []
for path, first, last in found:
    raw = Path(path).read_bytes()
    assert raw == subprocess.check_output(['git', 'show', baseline + ':' + path])
    lines = raw.splitlines(keepends=True)
    chunk = b''.join(lines[first-1:last])
    ranges.append({'path': path, 'start': first, 'end': last,
                   'bytes': len(chunk), 'sha256': hashlib.sha256(chunk).hexdigest()})
    start, current = first, []
    for number in range(first, last+1):
        line = lines[number-1]
        if current and sum(map(len,current)) + len(line) > 6500:
            data = b''.join(current)
            windows.append({'path': path, 'start': start, 'end': number-1,
                            'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
            start, current = number, []
        current.append(line)
    if current:
        data = b''.join(current)
        windows.append({'path': path, 'start': start, 'end': last,
                        'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
digest = lambda rows: hashlib.sha256(json.dumps(rows,separators=(',',':')).encode()).hexdigest()
assert digest(ranges) == '910001b25a8dc5581ff6254cb39f5bc5888dbb3c1665af061fa8edc0205a6e39'
assert digest(windows) == '254938dc997bd16d9511d0cbff833be5b7cc064b4225f09bab674aa03ef8a3e2'
assert len(windows) == 7
assert sum(r['end']-r['start']+1 for r in ranges) == 179
assert sum(r['bytes'] for r in ranges) == sum(w['bytes'] for w in windows) == 26444
scratch = Path('.linkedspec-data/scratch/support117')
scratch.mkdir(parents=True, exist_ok=True)
(scratch/'audit.json').write_text(json.dumps({'ranges':ranges,'windows':windows},indent=2)+'\n')
print('PASS exact required range/window reconstruction: seven windows/two ranges/179 fragments/26444 bytes; pplugin EOF and spec.spec1–146 only. Identity verification does not create reading credit.')
SUPPORTING_CURRENT_GROUP17
```

# Current grammar group .1.18 — 2026-09-13

Ten complete windows physically cover `specs/spec.spec`147–226 (EOF) and
`specs/user_function_definition.spec`1–115: 195 fragments/62,203 bytes. Cumulative
required coverage is 374 fragments/88,647 bytes across two of three groups;
255 fragments/8,134 bytes remain in `.1.19`. The long Unicode patterns are read
completely. Historical `.1.1` and seventeen superseded groups remain separate;
original Scope fields do not create reading credit for omitted applications.

| Window | File | Inclusive lines | Bytes |
| --- | --- | --- | ---: |
| 1 | specs/spec.spec | 147–150 | 6,204 |
| 2 | specs/spec.spec | 151–154 | 6,031 |
| 3 | specs/spec.spec | 155–158 | 6,048 |
| 4 | specs/spec.spec | 159–162 | 6,161 |
| 5 | specs/spec.spec | 163–166 | 5,973 |
| 6 | specs/spec.spec | 167–167 | 11,763 |
| 7 | specs/spec.spec | 168–174 | 6,457 |
| 8 | specs/spec.spec | 175–182 | 6,406 |
| 9 | specs/spec.spec | 183–226 | 2,615 |
| 10 | specs/user_function_definition.spec | 1–115 | 4,545 |

Ordered range SHA-256:
`3cd1f38e22645be4ebff171713b57588cd261e1b2c967c880d5f989cdb1092bb`.
Ordered window SHA-256:
`30e95f636941d945b5b532854562a6c158b63e7a3401848a79cec593178f9dce`.
The following independent reconstruction checks exact baseline bytes and bounds;
it does not itself establish physical reading.

Comprehension follows complete fluent/block/marker productions and the dedicated
typed-function prefix, including staged body payload, source/body spans and parse
job provenance. The dedicated malformed-definition error continues past115 and
remains `.1.19`-owned. [[self-hosted-grammar-ast-drift]] records six function,
fourteen edge AST, ten mechanism AST, three selection and three literal controls.
Five confirmed grammar/literal defects have seven concrete implementation-and-verification leaves under
`SUPPORTING-SOURCE-READING.2.1-.2.5`; all remain open behind startup prerequisites.
The primary typed-function registration path remains supported. No native matrix,
dependency build, canonical CI or repair closure is claimed.

```bash
bash tools/project_data_run.sh python3 - <<'SUPPORTING_CURRENT_GROUP18'
from pathlib import Path
import hashlib, json, re, subprocess

baseline = 'baeb984e36a94a15951cd23d4c52def5064cdaca'
tree = Path('docs/tasks/SUPPORTING-SOURCE-READING.md').read_text()
node = re.search(r'^- ID: `SUPPORTING-SOURCE-READING\.1\.18`\n.*?(?=^- ID: |^## |\Z)', tree, re.M | re.S)[0]
scope = re.search(r'^  Required reading scope: (.+)$', node, re.M)[1]
found = [(p, int(a), int(b)) for p, a, b in re.findall(r'`([^`]+)` lines (\d+)-(\d+)', scope)]
assert found == [('specs/spec.spec', 147, 226), ('specs/user_function_definition.spec', 1, 115)]
ranges, windows = [], []
for path, first, last in found:
    raw = Path(path).read_bytes()
    assert raw == subprocess.check_output(['git', 'show', baseline + ':' + path])
    lines = raw.splitlines(keepends=True)
    chunk = b''.join(lines[first-1:last])
    ranges.append({'path': path, 'start': first, 'end': last,
                   'bytes': len(chunk), 'sha256': hashlib.sha256(chunk).hexdigest()})
    start, current = first, []
    for number in range(first, last+1):
        line = lines[number-1]
        if current and sum(map(len,current)) + len(line) > 6500:
            data = b''.join(current)
            windows.append({'path': path, 'start': start, 'end': number-1,
                            'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
            start, current = number, []
        current.append(line)
    if current:
        data = b''.join(current)
        windows.append({'path': path, 'start': start, 'end': last,
                        'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
digest = lambda rows: hashlib.sha256(json.dumps(rows,separators=(',',':')).encode()).hexdigest()
assert digest(ranges) == '3cd1f38e22645be4ebff171713b57588cd261e1b2c967c880d5f989cdb1092bb'
assert digest(windows) == '30e95f636941d945b5b532854562a6c158b63e7a3401848a79cec593178f9dce'
assert len(windows) == 10
assert sum(r['end']-r['start']+1 for r in ranges) == 195
assert sum(r['bytes'] for r in ranges) == sum(w['bytes'] for w in windows) == 62203
scratch = Path('.linkedspec-data/scratch/support118')
scratch.mkdir(parents=True, exist_ok=True)
(scratch/'audit.json').write_text(json.dumps({'ranges':ranges,'windows':windows},indent=2)+'\n')
print('PASS exact required range/window reconstruction: ten windows/two ranges/195 fragments/62203 bytes; spec.spec147–226 EOF and user_function_definition.spec1–115 only. Identity verification does not create reading credit.')
SUPPORTING_CURRENT_GROUP18
```

# Current grammar group .1.19 — 2026-09-13

Two complete windows cover `specs/user_function_definition.spec`116–370 (EOF):
255 fragments/8,134 bytes. Window 1 (116–306) is 6,465 bytes; window 2 (307–370)
is 1,669 bytes. Physical excerpts116–240 and241–370 cover both completely.
All three required grammar groups are now read: five ranges/629 fragments/96,781
bytes. Independent `.3` reconciliation remains; this is not aggregate signoff,
full-codebase completion, historical omitted-byte credit or defect closure.

Range SHA-256 `a580a5d7ae6ba32b9a19fa21a98203742090f7159cd47f131266a47d0b6eb2ae`;
window SHA-256 `e6bf546c68d82178106cac912714ae4e731e80555626372a832197e0c2504b71`.
The replay below checks exact baseline bytes and bounds without creating reading
credit. [[spec-defined-user-function-definition-parser]] publishes the unchanged
44-assertion AST fixture extraction and six exact signature/payload/job controls.
[[function-definition-staged-ast-audit]] preserves the earlier July findings and
four current body comparisons; self-hosted regex-body repair `.2.7` remains open,
and prior zero-argument evidence maps to `.2.3.2`. All seven repair roots remain.

```bash
bash tools/project_data_run.sh python3 - <<'SUPPORTING_CURRENT_GROUP19'
from pathlib import Path
import hashlib, json, re, subprocess

baseline = 'baeb984e36a94a15951cd23d4c52def5064cdaca'
tree = Path('docs/tasks/SUPPORTING-SOURCE-READING.md').read_text()
node = re.search(r'^- ID: `SUPPORTING-SOURCE-READING\.1\.19`\n.*?(?=^- ID: |^## |\Z)', tree, re.M | re.S)[0]
scope = re.search(r'^  Required reading scope: (.+)$', node, re.M)[1]
found = [(p, int(a), int(b)) for p, a, b in re.findall(r'`([^`]+)` lines (\d+)-(\d+)', scope)]
assert found == [('specs/user_function_definition.spec', 116, 370)]
ranges, windows = [], []
for path, first, last in found:
    raw = Path(path).read_bytes()
    assert raw == subprocess.check_output(['git', 'show', baseline + ':' + path])
    lines = raw.splitlines(keepends=True)
    chunk = b''.join(lines[first-1:last])
    ranges.append({'path': path, 'start': first, 'end': last,
                   'bytes': len(chunk), 'sha256': hashlib.sha256(chunk).hexdigest()})
    start, current = first, []
    for number in range(first, last+1):
        line = lines[number-1]
        if current and sum(map(len,current)) + len(line) > 6500:
            data = b''.join(current)
            windows.append({'path': path, 'start': start, 'end': number-1,
                            'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
            start, current = number, []
        current.append(line)
    if current:
        data = b''.join(current)
        windows.append({'path': path, 'start': start, 'end': last,
                        'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
digest = lambda rows: hashlib.sha256(json.dumps(rows,separators=(',',':')).encode()).hexdigest()
assert digest(ranges) == 'a580a5d7ae6ba32b9a19fa21a98203742090f7159cd47f131266a47d0b6eb2ae'
assert digest(windows) == 'e6bf546c68d82178106cac912714ae4e731e80555626372a832197e0c2504b71'
assert len(windows) == 2
assert sum(r['end']-r['start']+1 for r in ranges) == 255
assert sum(r['bytes'] for r in ranges) == sum(w['bytes'] for w in windows) == 8134
scratch = Path('.linkedspec-data/scratch/support119')
scratch.mkdir(parents=True, exist_ok=True)
(scratch/'audit.json').write_text(json.dumps({'ranges':ranges,'windows':windows},indent=2)+'\n')
print('PASS exact required range/window reconstruction: two windows/one range/255 fragments/8134 bytes; user_function_definition.spec116–370 EOF. Identity verification does not create reading credit.')
SUPPORTING_CURRENT_GROUP19
```

# Verification and continuity boundaries

This is read-only source inventory and task decomposition. It changes no source,
runtime, dependency, gate, evidence limit or feature state. ADR0119 resolves Lua
reading closeout; the director explicitly authorizes continuing reading and rejects
unnecessary rebuilds. No RGX/PGEN build is needed for these audits. Later runtime,
infrastructure, admission and push verification retain their separate requirements.

The new task member is 301 lines /23,353 bytes before any reading evidence is added.
At the initial census, the task collection has 87,462 lines /9,305,590 bytes and
104 members; Knowledge has 1,139 files /85,245 lines /6,814,610 bytes (including its
non-card member). These are dated measurements, not a capacity increase or a
promise about future findings. The actual completed candidate is checked by the
normal resulting-tree pressure doctrine before landing. Each later leaf rechecks
its own candidate. Coherent facts use their canonical homes; a new card is not
required merely because a new reading slice begins.

Every previously owned defect stays open. Findings encountered during reading
must first be reconciled with existing owners; new defects receive bounded repair
and verification ownership. Historical adapters/configuration must not be executed
for side effects merely to establish source comprehension. Use LinkedSpec Toolbox
probes before diagnosing `.spec` behavior, and preserve legacy versus supported
scope. Named arguments and other parked work stay parked.

# Reproduction

Run the recipes in order. They write only repository-derived scratch reports;
source reading is counted only in completed, committed task-tree children.

```bash
bash tools/project_data_run.sh python3 - <<'SUPPORTING_SOURCE_INVENTORY'
from pathlib import Path
import hashlib,json,subprocess,collections
BASE='baeb984e36a94a15951cd23d4c52def5064cdaca'
CHECKPOINT='735f0337883baef5ac4422976879d09725e0e8ea'
ROOTS=['conf','tablescript','noncore','specs','ebnf']
git=lambda *args:subprocess.check_output(['git',*args])
tree=git('ls-tree','-r','-z',BASE,'--',*ROOTS)
entries=[]
for item in tree.split(b'\0'):
 if not item:continue
 meta,path=item.split(b'\t',1);mode,kind,oid=meta.decode().split()
 assert kind=='blob',(kind,path)
 entries.append(dict(path=path.decode(),mode=mode,oid=oid))
assert len(entries)==158
assert git('ls-tree','-r','-z',CHECKPOINT,'--',*ROOTS)==tree
assert git('ls-tree','-r','-z','HEAD','--',*ROOTS)==tree
assert not git('diff','--name-only',BASE,'--',*ROOTS).strip()
assert not git('diff','--cached','--name-only','--',*ROOTS).strip()
assert not git('ls-files','--others','--exclude-standard','--',*ROOTS).strip()
body=subprocess.check_output(['git','cat-file','--batch'],input=''.join(e['oid']+'\n' for e in entries).encode())
pos=0;blobs={};inventory=[];categories=collections.defaultdict(lambda:[0,0,0])
for e in entries:
 end=body.index(b'\n',pos);oid,kind,length=body[pos:end].split();length=int(length)
 raw=body[end+1:end+1+length];pos=end+length+2
 assert oid.decode()==e['oid'] and kind==b'blob'
 assert raw==Path(e['path']).read_bytes(),e['path']
 assert b'\0' not in raw,e['path'];raw.decode('utf-8')
 lines=raw.splitlines(keepends=True);assert b''.join(lines)==raw
 assert all(line.endswith(b'\n') for line in lines[:-1]),e['path']
 row={**e,'bytes':len(raw),'physical_lf':raw.count(b'\n'),'fragments':len(lines),'sha256':hashlib.sha256(raw).hexdigest()}
 inventory.append(row);blobs[e['path']]=raw
 c=categories[e['path'].split('/')[0]];c[0]+=1;c[1]+=len(lines);c[2]+=len(raw)
assert pos==len(body) and sum(e['bytes'] for e in inventory)==964256
result={'baseline':BASE,'checkpoint':CHECKPOINT,'entries':len(entries),'physical_lf':sum(e['physical_lf'] for e in inventory),'fragments':sum(e['fragments'] for e in inventory),'bytes':sum(e['bytes'] for e in inventory),'source_tree_sha256':hashlib.sha256(tree).hexdigest(),'inventory':inventory,'categories':dict(categories),'empty':[e['path'] for e in inventory if not e['bytes']],'largest_lines':sorted([[len(line),path,i] for path,raw in blobs.items() for i,line in enumerate(raw.splitlines(keepends=True),1)],reverse=True)[:6],'current_delta_paths':0}
assert result['physical_lf']==25612 and result['fragments']==25613
assert result['source_tree_sha256']=='e7845e3f7fa04a9929b20834fd0b799092063930ecb921b195cfe972c6a252b8'
assert hashlib.sha256(json.dumps(inventory,separators=(',',':')).encode()).hexdigest()=='0bd5e398ef52c2de0f2389d8931b4543c112f43401842b74306310c80cdb9ec1'
p=Path('.linkedspec-data/scratch/support370');p.mkdir(parents=True,exist_ok=True)
(p/'inventory.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='inventory'},indent=2))
SUPPORTING_SOURCE_INVENTORY
```

```bash
bash tools/project_data_run.sh python3 - <<'SUPPORTING_SOURCE_PLAN'
from pathlib import Path
import collections,hashlib,json
p=Path('.linkedspec-data/scratch/support370')
inventory=json.loads((p/'inventory.json').read_text())
roots=['conf','tablescript','noncore','specs','ebnf']
groups=[]
for root in roots:
 ranges=[];count=size=0
 for row in inventory['inventory']:
  if not row['path'].startswith(root+'/'):continue
  path=row['path'];lines=Path(path).read_bytes().splitlines(keepends=True)
  start=1
  while start<=len(lines):
   end=start-1;selected=[]
   while end<len(lines) and count+len(selected)<1500:
    line=lines[end]
    if size+sum(map(len,selected))+len(line)>65536:break
    selected.append(line);end+=1
   if not selected:
    assert ranges,(path,start,'oversized line requires separately owned byte windows')
    groups.append(dict(root=root,ranges=ranges,fragments=count,bytes=size));ranges=[];count=size=0;continue
   data=b''.join(selected)
   ranges.append(dict(path=path,start=start,end=end,bytes=len(data),sha256=hashlib.sha256(data).hexdigest()))
   count+=len(selected);size+=len(data);start=end+1
   if count==1500 or (start<=len(lines) and size+len(lines[start-1])>65536):
    groups.append(dict(root=root,ranges=ranges,fragments=count,bytes=size));ranges=[];count=size=0
 if ranges:groups.append(dict(root=root,ranges=ranges,fragments=count,bytes=size))
coverage=collections.defaultdict(list)
for i,group in enumerate(groups,1):
 group['id']='SUPPORTING-SOURCE-READING.1.'+str(i)
 group['range_sha256']=hashlib.sha256(json.dumps(group['ranges'],separators=(',',':')).encode()).hexdigest()
 assert group['fragments']<=1500 and group['bytes']<=65536
 for row in group['ranges']:
  lines=Path(row['path']).read_bytes().splitlines(keepends=True)
  lo=sum(map(len,lines[:row['start']-1]));hi=lo+row['bytes']
  assert b''.join(lines[row['start']-1:row['end']])==Path(row['path']).read_bytes()[lo:hi]
  coverage[row['path']].append((lo,hi))
assert set(coverage)=={r['path'] for r in inventory['inventory']}
for path,ranges in coverage.items():
 cursor=0
 for lo,hi in sorted(ranges):assert lo==cursor,(path,lo,cursor);cursor=hi
 assert cursor==Path(path).stat().st_size,path
assert sum(g['fragments'] for g in groups)==inventory['fragments']
assert sum(g['bytes'] for g in groups)==inventory['bytes']
assert len(groups)==21 and sum(len(g['ranges']) for g in groups)==174
assert hashlib.sha256(json.dumps(groups,separators=(',',':')).encode()).hexdigest()=='2a4bd96b87345719946abad085eb7b2b934dcacd063ab421a2447ea036a4903c'
(p/'plan.json').write_text(json.dumps(groups,indent=2)+'\n')
print('PASS complete disjoint owned-range plan:',len(groups),'groups;',sum(len(g['ranges']) for g in groups),'ranges; no physical reading credit.')
for g in groups:print(g['id'],g['root'],g['fragments'],g['bytes'],g['ranges'][0]['path'],g['ranges'][0]['start'],'through',g['ranges'][-1]['path'],g['ranges'][-1]['end'])
SUPPORTING_SOURCE_PLAN
```

```bash
bash tools/project_data_run.sh python3 - <<'SUPPORTING_SOURCE_TREE'
from pathlib import Path
import hashlib,json,re,subprocess
p=Path('.linkedspec-data/scratch/support370')
base='baeb984e36a94a15951cd23d4c52def5064cdaca'
plan=json.loads((p/'plan.json').read_text())
tree=Path('docs/tasks/SUPPORTING-SOURCE-READING.md').read_text()
nodes=dict(re.findall(r'^- ID: `([^`]+)`\n(.*?)(?=^- ID: |^## |\Z)',tree,re.M|re.S))
coverage={};complete=0
for g in plan:
 n=nodes[g['id']]
 scope=re.search(r'^  Scope: (.+)$',n,re.M)[1]
 found=re.findall(r'`([^`]+)` lines (\d+)-(\d+)',scope)
 assert [(path,int(a),int(b)) for path,a,b in found]==[(r['path'],r['start'],r['end']) for r in g['ranges']]
 fragments=size=0
 for path,a,b in found:
  a=int(a);b=int(b)
  raw=subprocess.check_output(['git','show',base+':'+path])
  lines=raw.splitlines(keepends=True)
  assert 1<=a<=b<=len(lines)
  lo=sum(len(line) for line in lines[:a-1]);hi=sum(len(line) for line in lines[:b])
  coverage.setdefault(path,[]).append((lo,hi));fragments+=b-a+1;size+=hi-lo
 assert (fragments,size)==(g['fragments'],g['bytes'])
 assert g['range_sha256'] in n and fragments<=1500 and size<=65536
 status=re.search(r'^  Status: `([^`]+)`$',n,re.M)[1]
 assert status in ['pending','active','done','superseded'];complete+=status=='done'
for path,ranges in coverage.items():
 cursor=0
 for lo,hi in sorted(ranges):assert lo==cursor,(path,lo,cursor);cursor=hi
 assert cursor==Path(path).stat().st_size
assert len(coverage)==158
startup=Path('docs/tasks/SESSION-STARTUP-READING.md').read_text()
old=subprocess.check_output(['git','show','735f0337883baef5ac4422976879d09725e0e8ea:docs/tasks/SESSION-STARTUP-READING.md'],text=True)
prior_scopes=re.findall(r'^  Scope: (.+)$',old,re.M)
prior_matches=[line for line in prior_scopes if re.search(r'`(?:conf|tablescript|noncore|specs|ebnf)/',line)]
assert not prior_matches,prior_matches
print('PASS independent published-tree/Git-byte coverage: 21 groups,174 ranges,158 complete files; all budgets/digests; completed historical-or-required reading children='+str(complete)+'. No exact prior startup Scope coverage is credited.')
SUPPORTING_SOURCE_TREE
```

Related facts: [[startup-codebase-reading-inventory]], [[lua-reading-commit-closeout-audit]],
[[rust-ci-pgen-missing-input-rebuilds]].

# Independent reconciliation — 2026-09-13

[[supporting-reading-closeout-audit]] independently verifies all 174 original
ranges/158 unchanged sources, three reading commits/five required ranges/nineteen
windows and all seven repair roots. Required reading is 629 fragments/96,781 bytes;
historical reading is 1,500/61,165; explicit omissions are 23,484/806,310. No extra
reading credit or defect closure is granted. The audit and separate focused parent closeout are complete under ADR0120.
Checker `.2.6` is repaired; six grammar/literal repair roots remain open. Current
closeout replay preserves all nine pending nodes and routes startup `.3.8`.
