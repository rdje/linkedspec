---
id: startup-task-chronology-compaction
title: Task chronology retains exact Git and per-node evidence within the bounded collection
answers:
  - why did the expression block task point to the string comparison commit
  - where are the 264 consolidated historical task records
  - what owns capacity for the Dart reading decomposition
  - how much task and Knowledge capacity remained after Rust reading
  - why does deterministic Dart packing use 55 groups instead of the earlier 56
  - how much space does complete Dart reading ownership need
  - which leaf designs the Dart reading capacity solution
  - where is the completed startup batch chronology
  - why was the startup task commit table removed
  - how was startup task compaction checked without losing evidence
  - what owns current task collection pressure cleanup
date: 2026-09-08
status: .5/.6 complete; .7.0 measures Dart capacity; .7.1 owns the pending design
tags: [continuity, task-tree, history, containment]
evidence: "LIVE-DOCUMENT-PRESSURE-CONTAINMENT.5 checks all 100 batch ordinal/leaf/hash identities against first-parent Git history and all 102 duplicate commit subjects against canonical task nodes; every completion note is retained verbatim beside its node's Commit field. Other task-node fields and stable IDs are identical."
evidence_update_2026_09_08: "Containment .5 lands at d6f37492 with exact canonical proof. From e288c3af, .6 consolidates 264 rows into 260 nodes across four closed trees, retains six unmatched historical captions, preserves every prior node reference and completion note, and removes 251 lines/8210 bytes overall. A proven wrong-node commit pointer is corrected with its prior text retained. The final ordinary documentation slice uses focused proof; the parent remains open for later Dart capacity .7."
evidence_update_capacity_2026_09_08: "From clean 3132596c, all 115 Dart paths and 2471305 bytes remain baseline-identical. Explicit greedy packing proves 55 bounded groups and 169 exact ranges; a separate 56-group control preserves the historical conservative allowance without claiming to reconstruct historical grouping. A 605-line minimal template exceeds the 60-line aggregate and 562-line startup headroom. Knowledge has six file slots. Capacity design .7.1 precedes admission; limits and unique evidence remain unchanged."
reverify:
  - 'Run the repository-managed DART_CAPACITY_AUDIT block below for inventory, grouping, projection and pressure.'
  - 'Run the repository-managed TASK_CHRONOLOGY_AUDIT block below for the complete four-tree proof.'
  - 'git log --reverse --first-parent --format="%h %s" a5d5dcd2955aaaa41166bd87de6bdc39a4502bc4..fb307dae35d0ecfdcbb4b29e65bec36855d6971b'
---

# Exact retained owners

Canonical leaf nodes in `docs/tasks/SESSION-STARTUP-READING.md` retain the exact commit subjects and
all 102 completion notes. Their other fields, stable IDs, and source-reading scope remain unchanged.
Git is the complete immutable commit authority; the removed table duplicated subjects already in those nodes.
The 100-item enumeration is exactly reproducible through the command above. The earlier `.1` checkpoint
is outside that batch. Current execution state remains in `MEMORY.md` and each task's frontier.

Comparison source: clean `e455be6a3c85cb7a75bc7ccd36c579efe74bcc97:docs/tasks/SESSION-STARTUP-READING.md`;
whole-file SHA-256 `fff0d54a37685f8b3792be8a4c221627a3b3efcd35ccbe08c259ce00f6b0ab43`.
The removed batch is source lines 6917–7003, 4361 bytes,
SHA-256 `343b4e562a42fa056b1105c9a5c898ff5620c3dfb6b1592ee3716bbacbea51da`. All listed ordinal/leaf/hash triples
agree with the 100 first-parent commits ending at `fb307dae35d0ecfdcbb4b29e65bec36855d6971b`.

Exact source retrieval: `git show e455be6a3c85cb7a75bc7ccd36c579efe74bcc97:docs/tasks/SESSION-STARTUP-READING.md`.
No immutable task part, history segment, route registry, limit or implementation file changes in this cleanup.
The separately retained verification and changelog sections remain available for their additional context.

## Four-tree consolidation under `.6`

Clean source: `e288c3af1def3bcf1fb039d3c50de6a689cb337f`. No acceptance, verification, status, stable ID,
decision, changelog, immutable part, registry, limit or implementation changes in the four consolidated trees.
Every source table row is either retained exactly in its table or represented by its exact owner, reference and
verbatim completion note in that node's `Commit` field. Abbreviated/pending prior references remain explicitly
recorded when a verified Git subject becomes the primary reference. Historical captions are not silently rewritten.

| Tree | Consolidated rows / nodes | Table rows retained | Lines removed | Bytes removed |
| --- | ---: | ---: | ---: | ---: |
| `SPEC-FORMAT-TERSE` | 146 / 142 | 4 | 139 | 6,944 |
| `DART-BACKEND-PARITY` | 44 / 44 | 0 | 43 | 2,898 |
| `RUST-PARITY` | 38 / 38 | 0 | 38 | 1,054 |
| `SPEC-LANG-REFERENCE` | 36 / 36 | 2 | 31 | -2,686 |

The aggregate saving is 251 lines and 8,210 bytes. The language-reference file grows in bytes because its
abbreviated references and differing historical captions remain alongside exact Git subjects; its line count falls.
Six captions that do not meet the strict identity match stay in the original table form. This does not classify
them as missing work or grant new completion credit.

The source audit found one definite wrong-node update: Git `b4217c37279f3f22ad8973749331b45dd5bdefeb` changed
`SPEC-FORMAT-TERSE.2.1.1`'s placeholder to the unrelated `.3.2.3.2` string-comparison subject. Its own actual
commit is `c5f2204b` (`SPEC-FORMAT-TERSE.2.1.1 — split expression-valued blocks`). `.6` corrects the primary
reference and labels the retained old value as incorrect. This repairs historical documentation, not parser behavior.

Consumer census across `tools/`, `scripts/` and `.githooks/` finds the four tree names only in oracle-generator
comments. The generic metadata checker reads node `Commit` fields for pending-node consistency and deliberately
excludes broad historical backfill; it does not parse these Commit Log tables. Its partition/current-ID/frontier/
closed-marker proof passes after consolidation. The table heading remains a stable navigation point.

`.6` restores capacity for the remaining Rust checkpoints. The preserved Dart estimate in d6f37492 is 115 files,
56 bounded groups and 169 range rows; the full decomposition needs a later admission review under `.7` after
Rust `.3.3.67`, before Dart ownership/reading. The capacity parent therefore remains open. This ordinary documentation
consolidation uses focused proof under ADR `0073`; later designated and push boundaries retain canonical CI.

Reverify the complete row/node/Git retention proof from the repository root:

```bash
bash tools/project_data_run.sh python3 - <<'TASK_CHRONOLOGY_AUDIT'
from pathlib import Path
import re, subprocess, hashlib, json
base = 'e288c3af1def3bcf1fb039d3c50de6a689cb337f'
sources = {
 'SPEC-FORMAT-TERSE': ('5510265583cd930434a550460227bbe423ac44a0ba2ec8eafaf1bc4d2634ef98', 146, 142, 4),
 'DART-BACKEND-PARITY': ('fdfb267b80482ea6d218e861da79384744fcc32eb4c2673279ccfca26f4c11c7', 44, 44, 0),
 'RUST-PARITY': ('bec2a0e8e83de81fd17de8da003c609a169e6bfa023e31c6bca17ae61b8c7b52', 38, 38, 0),
 'SPEC-LANG-REFERENCE': ('0949d02f58411f53288beb76a8a0ba14c8396be0cccb202fa0e414a3d448e25a', 36, 36, 2),
}
subjects = set(subprocess.check_output(['git', 'log', '--format=%s'], text=True).splitlines())
node_pattern = r'^- ID: `([^`]+)`\n(.*?)(?=^- ID:|^## Current Frontier|\Z)'
table_pattern = r'^## Commit Log\n(.*?)(?=^## |\Z)'
def nodes(text): return dict(re.findall(node_pattern, text, re.M | re.S))
def table(text): return re.search(table_pattern, text, re.M | re.S).group(1)
def without_commit(body): return re.sub(r'^  Commit: .*\n', '', body, flags=re.M).strip('\n')
def outside(text):
 text = re.sub(node_pattern, lambda m: '- ID: `' + m[1] + '`\n<NODE>\n', text, flags=re.M | re.S)
 return re.sub(table_pattern, '## Commit Log\n<TABLE>\n', text, flags=re.M | re.S)
reports = []
for tree, (digest, expected_rows, expected_nodes, expected_kept) in sources.items():
 path = 'docs/tasks/' + tree + '.md'
 raw = subprocess.check_output(['git', 'show', base + ':' + path])
 assert hashlib.sha256(raw).hexdigest() == digest
 old, new = raw.decode(), Path(path).read_text()
 before, after = nodes(old), nodes(new)
 assert set(before) == set(after) and outside(old) == outside(new), tree
 for leaf in before:
  assert without_commit(before[leaf]) == without_commit(after[leaf]), leaf
  prior = re.search(r'^  Commit: (.*)$', before[leaf], re.M)
  if prior: assert prior[1] in after[leaf], (leaf, 'prior node reference')
 count = kept = 0; affected = set()
 for row in table(old).splitlines():
  if not row.startswith('| `'): continue
  label, reference, note = row[2:-2].split(' | ', 2)
  leaf = re.match(r'`([A-Z][A-Z0-9-]*(?:\.\d+)*)', label)[1]
  ref = reference.strip('`')
  variants = [ref, ref.replace(' — ', ' - ', 1), ref.replace(' — ', ' - ', 1).replace('\\"', '"')]
  matches = list(dict.fromkeys(v for v in variants if v in subjects))
  eligible = leaf in before and len(matches) == 1 and (matches[0].startswith(leaf + ' ') or leaf == tree)
  if not eligible:
   assert row in table(new), (leaf, 'retained caption'); kept += 1; continue
  value = re.search(r'^  Commit: (.*)$', after[leaf], re.M)[1]
  assert note in value and reference in value and matches[0] in value, (leaf, 'note/reference')
  assert label == '`' + leaf + '`' or label in value, (leaf, 'label')
  count += 1; affected.add(leaf)
 assert (count, len(affected), kept) == (expected_rows, expected_nodes, expected_kept), tree
 reports.append({'tree': tree, 'rows': count, 'nodes': len(affected), 'retained': kept,
  'lines_removed': len(old.splitlines()) - len(new.splitlines()), 'bytes_removed': len(raw) - len(new.encode())})
fixed = nodes(Path('docs/tasks/SPEC-FORMAT-TERSE.md').read_text())['SPEC-FORMAT-TERSE.2.1.1']
assert re.search(r'^  Commit: `SPEC-FORMAT-TERSE.2.1.1 — split expression-valued blocks`', fixed, re.M)
assert 'prior node reference (incorrect; corrected by containment .6)' in fixed
print(json.dumps(reports))
TASK_CHRONOLOGY_AUDIT
```

## Dart capacity admission measurement — `.7.0`

Clean activation `3132596cc5d1d4244d7247908c5b4701ecaa20a8` closes the Rust reading parent.
The Dart baseline remains `baeb984e36a94a15951cd23d4c52def5064cdaca`: 115 unchanged paths,
80,296 physical lines and 2,471,305 bytes. This is inventory and projection, with no Dart source-reading credit.

The executable audit below fixes the previously implicit packing choices: sorted Git paths, complete LF lines,
greedy 1,500-fragment / 65,536-byte groups, and UTF-8-safe fragments only for an oversized logical line.
It produces 55 groups, 169 source-coordinate rows and 80,297 fragments, including two byte-coordinate rows.
Each declared range is independently reconstructed from baseline coordinates, checked for contiguous disjoint
coverage through EOF, and digest-verified. Current tracked/working Dart inputs match that baseline.

The earlier d6f37492 estimate records 56 groups / 169 rows and those same source totals, without an executable
packing recipe or exact group membership. Group count is not uniquely fixed by the two ceilings: the audit also
proves a valid 56-group control by splitting one existing group at a file boundary. It preserves the same ordered
source units and 169 rows. This control does not claim to reconstruct the historical packing. Retain 56 groups
as the conservative planning allowance until the actual Dart decomposition chooses and records its boundaries.

| Governed store at activation | Measured | Unused capacity under unchanged limits |
| --- | --- | --- |
| Task evidence | 101 files / 79,940 lines / 8,191,204 bytes | 27 files / 60 lines / 197,404 bytes |
| Startup task file | 7,438 lines / 757,154 bytes | 562 lines / 291,422 bytes |
| Knowledge Markdown | 1,018 files / 58,812 lines / 4,884,238 bytes | 6 files / 5,188 lines / 1,407,218 bytes |
| Derived Knowledge Map | 17,408 lines / 5,421,822 bytes | 2,592 lines / 2,966,786 bytes |

The 55 scoped-leaf template alone needs 605 lines / 37,785 bytes; a 56-group allowance needs 616 lines.
Adding the 55-leaf template to the activation snapshot would produce 80,545 aggregate task lines and an
8,043-line startup file. Both exceed their respective 80,000/8,000 limits. The template excludes decomposition
and parent closeout, this capacity work, later verification detail, repair ownership and Knowledge growth.
These are explicit minimum template costs, not a sufficient reserve for the complete reading activity.

The inventory digest is `34ab5a05c63525c7c7537332e71ce8104c83b5efe2a7413714923a8745d35425`;
the ordered range digest is `68844356bf68df29531e689ff80fd06be16059621c678c4c8dbaa0b9adcb398f`.
The 55-leaf projection digest is `3c925b16b8e928ccd1e9c7a2021b39f75aacc13b8d625dc54ff15b4044a62b18`.
Activation store records are reproduced below; current measurements are deliberately recomputed rather than
treated as an immutable future ceiling. Metadata/code examples are not live task definitions.

`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.1` owns the capacity design, including semantic retrieval, unique evidence,
existing limits, bounded future growth and implementation/verification ownership. This measurement grants no
limit increase, migration, Dart decomposition or source-reading admission.

Reverify from the repository root. The source inventory remains exact while Dart is unchanged; after later
Dart edits, its current-input assertion intentionally requires a new delta audit.

```bash
bash tools/project_data_run.sh python3 - <<'DART_CAPACITY_AUDIT'
from pathlib import Path
import subprocess, json, hashlib, fnmatch
BASE='baeb984e36a94a15951cd23d4c52def5064cdaca'
ACTIVATION='3132596cc5d1d4244d7247908c5b4701ecaa20a8'
MAX_LINES,MAX_BYTES=1500,65536
def git(*args): return subprocess.check_output(['git',*args])
def tree(ref):
    out={}
    for row in git('ls-tree','-rz',ref).split(b'\0'):
        if row:
            meta,path=row.split(b'\t',1); mode,kind,oid=meta.decode().split()
            out[path.decode()]=(mode,kind,oid)
    return out
def blobs(entries,paths):
    request=b''.join((entries[p][2]+'\n').encode() for p in paths)
    raw=subprocess.run(['git','cat-file','--batch'],input=request,stdout=subprocess.PIPE,check=True).stdout
    out={}; offset=0
    for p in paths:
        end=raw.index(b'\n',offset); oid,kind,n=raw[offset:end].split()
        assert kind==b'blob' and oid.decode()==entries[p][2]
        n=int(n); start=end+1; out[p]=raw[start:start+n]
        assert raw[start+n:start+n+1]==b'\n'; offset=start+n+1
    assert offset==len(raw)
    return out
def digest(value):
    return hashlib.sha256(json.dumps(value,ensure_ascii=False,separators=(',',':')).encode()).hexdigest()
def line_count(b): return b.count(b'\n')+int(bool(b) and not b.endswith(b'\n'))
baseline,activation=tree(BASE),tree(ACTIVATION)
paths=sorted(p for p in baseline if p.startswith('dart/'))
assert paths==sorted(p for p in activation if p.startswith('dart/'))
assert all(baseline[p]==activation[p] for p in paths)
source=blobs(baseline,paths)
assert all(Path(p).read_bytes()==source[p] for p in paths)
assert not git('diff','--name-only',ACTIVATION,'--','dart/')
assert not git('ls-files','--others','--exclude-standard','--','dart/').strip()
groups=[]; group=[]; group_bytes=0; units_by_path={}
for p in paths:
    b=source[p]; b.decode('utf-8'); units=[]; offset=0
    lines=b.splitlines(keepends=True)
    assert len(lines)==line_count(b),(p,'non-LF physical line convention')
    if not b: units=[(p,'empty',0,0,b'')]
    for number,line in enumerate(lines,1):
        if len(line)<=MAX_BYTES:
            units.append((p,'lines',number,number,line))
        else:
            start=0
            while start<len(line):
                end=min(start+MAX_BYTES,len(line))
                while end<len(line) and line[end]&0xc0==0x80: end-=1
                assert end>start
                fragment=line[start:end]; fragment.decode('utf-8')
                units.append((p,'bytes',offset+start+1,offset+end,fragment))
                start=end
        offset+=len(line)
    assert b''.join(u[4] for u in units)==b
    units_by_path[p]=units
    for u in units:
        size=len(u[4]); lines_used=int(bool(size))
        if group and (sum(bool(x[4]) for x in group)+lines_used>MAX_LINES or group_bytes+size>MAX_BYTES):
            groups.append(group); group=[]; group_bytes=0
        group.append(u); group_bytes+=size
if group: groups.append(group)
# A distinct valid 56-group control splits one group at an existing file boundary.
conservative=None
for i,g in enumerate(groups):
    boundary=next((j for j in range(1,len(g)) if g[j-1][0]!=g[j][0]),None)
    if boundary is not None:
        conservative=groups[:i]+[g[:boundary],g[boundary:]]+groups[i+1:]
        break
assert conservative is not None and len(conservative)==56
assert [u for g in conservative for u in g]==[u for g in groups for u in g]
assert all(sum(bool(u[4]) for u in g)<=MAX_LINES and sum(len(u[4]) for u in g)<=MAX_BYTES for g in conservative)
def row_count(gs):
    return sum(i==0 or u[1]=='empty' or (g[i-1][0],g[i-1][1],g[i-1][3]+1)!=(u[0],u[1],u[2]) for g in gs for i,u in enumerate(g))
assert row_count(conservative)==169
ranges=[]; projection=[]; q=chr(96)
for number,units in enumerate(groups,1):
    rows=[]
    for p,kind,start,end,b in units:
        if rows and kind!='empty' and rows[-1][0]==p and rows[-1][1]==kind and rows[-1][3]+1==start:
            rows[-1][3]=end; rows[-1][4]+=b
        else: rows.append([p,kind,start,end,b])
    assert sum(bool(u[4]) for u in units)<=MAX_LINES
    assert sum(len(u[4]) for u in units)<=MAX_BYTES
    records=[[p,kind,start,end,len(b),hashlib.sha256(b).hexdigest()] for p,kind,start,end,b in rows]
    ranges.extend(records)
    scope='; '.join(q+p+q+' '+kind+' '+str(start)+'-'+str(end) for p,kind,start,end,*_ in records)
    projection.append('\n'.join([
      '- ID: '+q+'DART-READING-ESTIMATE.'+str(number)+q,
      '  Status: '+q+'pending'+q,
      '  Goal: Read bounded Dart group '+str(number)+' and reconcile its source evidence.',
      '  Scope: '+scope,
      '  Acceptance: Read every byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs.',
      '  Verification tier: '+q+'focused'+q,
      '  Focused checks: Exact range/byte coverage, relevant diagnostic proof, Knowledge and continuity checks.',
      '  Canonical trigger: '+q+'none'+q+' unless this leaf establishes systemic uncertainty.',
      '  Verification: '+q+'pending'+q,
      '  Commit: '+q+'pending'+q,'','']))
assert len(paths)==115 and sum(map(len,source.values()))==2471305
assert sum(line_count(b) for b in source.values())==80296
assert len(groups)==55 and len(ranges)==169
assert sum(sum(bool(u[4]) for u in g) for g in groups)==80297
assert sum(r[1]=='bytes' for r in ranges)==2
# Independently reconstruct each range from its declared source coordinates.
covered={p:0 for p in paths}
for p,kind,start,end,size,sha in ranges:
    b=source[p]
    if kind=='lines':
        lines=b.splitlines(keepends=True)
        begin=sum(len(x) for x in lines[:start-1])
        part=b''.join(lines[start-1:end])
    elif kind=='bytes': begin=start-1; part=b[begin:end]
    else: begin=0; part=b''
    assert begin==covered[p] and len(part)==size
    assert hashlib.sha256(part).hexdigest()==sha
    covered[p]+=len(part)
assert all(covered[p]==len(source[p]) for p in paths)
registry=json.loads(git('show',ACTIVATION+':doctrine/readme_stability/routes.jsonl').splitlines()[0])
surfaces=[json.loads(line) for line in git('show',ACTIVATION+':doctrine/readme_stability/routes.jsonl').splitlines()[1:]]
pressure=[]
for r in surfaces:
    if r.get('id') not in ('task_evidence','knowledge_cards','knowledge_map'): continue
    members=sorted(p for p,v in activation.items() if v[1]=='blob' and any(len(p.split('/'))==len(pat.split('/')) and all(fnmatch.fnmatchcase(a,b) for a,b in zip(p.split('/'),pat.split('/'))) for pat in r['members']))
    initial=blobs(activation,members)
    def measure(files):
        records=[(p,line_count(b),len(b),hashlib.sha256(b).hexdigest()) for p,b in sorted(files.items())]
        return {'files':len(records),'lines':sum(x[1] for x in records),'bytes':sum(x[2] for x in records),'record_sha256':digest(records)}
    pressure.append({'surface':r['id'],'activation':measure(initial),'current':measure({p:Path(p).read_bytes() for p in members}),'limits':r['limits']})
draft=''.join(projection).encode()
report={'activation':ACTIVATION,'baseline':BASE,'inventory':{'paths':len(paths),'lines':80296,'bytes':2471305,'groups':len(groups),'range_rows':len(ranges),'fragments':80297,'byte_ranges':2,'range_sha256':digest(ranges),'inventory_sha256':digest([(p,*baseline[p],len(source[p]),hashlib.sha256(source[p]).hexdigest()) for p in paths])},'projection':{'scope_leaf_count':len(groups),'retained_planning_group_allowance':len(conservative),'56_group_control':'one additional existing file-boundary split; same source units and 169 range rows; not reconstruction of historical packing','conservative_scope_leaf_lines':line_count(draft)+11,'scope_leaf_lines':line_count(draft),'scope_leaf_bytes':len(draft),'sha256':hashlib.sha256(draft).hexdigest(),'boundary':'minimum scoped-leaf template only; excludes decomposition, parent closeout, live updates and later repair/evidence growth; no task ownership or reading credit'},'pressure':pressure}
print(json.dumps(report,indent=2))
DART_CAPACITY_AUDIT
```
