---
id: supporting-reading-closeout-audit
title: "Supporting reading is independently audited; the checker correction and focused parent closeout are authorized"
answers:
  - "is supporting source reading independently audited"
  - "which supporting source bytes were read or explicitly omitted"
  - "what commits complete the three current grammars"
  - "what remains before supporting reading parent closeout"
  - "what exact supporting closeout exception is proposed"
  - "why is more approval needed after the Lua reading waiver"
date: 2026-09-13
status: audit complete; checker repaired under .2.6, authorized parent closeout follows
tags: [startup, reading, audit, continuity, verification, capacity, SUPPORTING-SOURCE-READING]
evidence: "SUPPORTING-SOURCE-READING.3 independently reconstructs all 174 original ranges/158 unchanged sources, five required ranges/nineteen complete windows/three clean reading commits and seven open repair roots. Physical required coverage is 629 fragments/96781 bytes; historical reading 1500/61165, explicit omissions 23484/806310. No additional physical reading, runtime signoff, defect closure, gate change or new ceiling is claimed."
reverify: "The original SUPPORTING_READING_CLOSEOUT_AUDIT below retains its audit-time assumptions and pending-node counts. Use the applied checker replay in task-partition-capacity-registry-drift.md; the separate authorized parent closeout will reconcile current repair status. No canonical receipt is claimed."
---

# Current disposition

The director grants both actions proposed in audit commit
`693e11e48168aba753b179b88cdb6800d4b06513`; ADR0120 records the exact scope.
Supporting `.2.6` applies the approved checker correction with focused proof.
Formal supporting `.1`/startup `.3.7` closure follows in a separate commit under
the same grant. No further permission is needed for either authorized action.
Six grammar/literal repair roots remain; the checker repair closes only `.2.6`.
The original audit and proposed-disposition text below remain dated evidence.

# Independent coverage and continuity

Baseline `baeb984e36a94a15951cd23d4c52def5064cdaca` and reading HEAD
`51fa104fe3b8cff023bb9272e17e4f2a222f9ecf` contain the same 158 supporting paths.
All source bytes remain identical. Original 21 group Scope fields/digests reconstruct
174 nonoverlapping ranges and cover every original fragment exactly once.
The director's `.0/.4` dispositions remain explicit rather than silently granting
reading credit to retired application data or adapters.

| Disposition | Fragments | Bytes |
| --- | ---: | ---: |
| Required current grammar reading | 629 | 96,781 |
| Completed historical `.1.1` reading | 1,500 | 61,165 |
| Explicitly omitted historical scope | 23,484 | 806,310 |
| Original total | 25,613 | 964,256 |

Required reading covers complete pplugin/spec/user-function grammars in five
ranges and 19 complete windows. The committed reading records, parent commits and
current source identities agree exactly:

| Leaf | Commit | Windows | Fragments / bytes |
| --- | --- | ---: | ---: |
| `.1.17` | `cf36237dccb500dc8a39c21786c484f0a9ee679b` | 7 | 179 / 26,444 |
| `.1.18` | `7a3f0b8aa1e649d74be405e822eb462227eb26be` | 10 | 195 / 62,203 |
| `.1.19` | `51fa104fe3b8cff023bb9272e17e4f2a222f9ecf` | 2 | 255 / 8,134 |

Their activation chain starts at clean `.4` commit
`4f2508fd5695231cbae98ebef27c8223170a4149`. Each reading commit changes only its
owned documentation. Historical `.1.1` plus these three groups are done; the other
seventeen groups are explicitly superseded. Seven repair roots/ten pending nodes
remain, including eight concrete grammar/literal repair leaves and checker `.2.6`.
The audit does not close any of them or replace their implementation prerequisites.

The most recent dedicated fixture 44/signature 6/body-comparison 4 results remain
owned by `.1.19`; the `.1.18` AST/descriptor/literal probes remain dated there.
This audit verifies their source and committed evidence, not a new runtime matrix.

# Historical proposal, now granted

`COMMIT.md` and ADR0073 require canonical CI/receipt for parent closeout and for a
checker change. The startup instruction also keeps code changes behind full
roadmap/codebase/book reading. ADR0119's explicit waiver covered only Lua reading
closeout. It authorizes continuing read-only work but does not waive these two
new actions. No repeated dependency build is needed to perform this audit.

The proposed new disposition is limited to:

1. Apply the exact one-file checker correction owned by `.2.6`, before the remaining
   startup reading, using its verified focused proof plus all normal doctrines,
   registry/source/history preservation, memory/Knowledge/history and rendered-book
   checks. Its existing 92,000-line/10,485,760-byte registry ceilings remain fixed;
   permit their use for the authorized startup continuation, measuring each actual
   candidate. No unlimited reserve or additional capacity increase is proposed.
2. Close only supporting reading `.1` and startup `.3.7` using this independent
   audit and focused preservation/normal-hook proof, waiving the one canonical
   run/receipt for that reading-only parent closeout. Keep every defect and all
   later source, infrastructure, milestone and push requirements open.

This requests focused exceptions for exactly the checker correction and this
supporting parent closeout, not a full-CI pass, dependency rebuild, later blanket
waiver, runtime repair, or reading credit for remaining lanes. On approval, apply
and verify `.2.6` first, commit clean, then close startup `.3.7` and its supporting reading parent in a separate commit and continue
startup `.3.8`. The first repair needs the explicit before-reading exception;
normal source repairs remain gated. The patch, source hashes, syntax proof,
37 mutation self-tests and 50 detached registry cases are reviewable in
[[task-partition-capacity-registry-drift]].

The complete proposal task record fits the unchanged old guard at 87,995 lines.
A later task decomposition cannot fit the five remaining lines. Required unique
source/history evidence and repair criteria are preserved; no dense packing,
deleting unresolved tasks or hook bypass is proposed to evade that boundary.

# Exact independent audit

```bash
bash tools/project_data_run.sh python3 - <<'SUPPORTING_READING_CLOSEOUT_AUDIT'
from pathlib import Path
import hashlib,json,re,subprocess
baseline='baeb984e36a94a15951cd23d4c52def5064cdaca'
head='51fa104fe3b8cff023bb9272e17e4f2a222f9ecf'
assert subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()==head
node_pattern=r'^- ID: `([^`]+)`\n.*?(?=^- ID: |^## |\Z)'
def git(*args):return subprocess.check_output(['git',*args])
def nodes(text):return {m[1]:m[0] for m in re.finditer(node_pattern,text,re.M|re.S)}
def ranges(node,key):
 value=re.search(r'^  '+key+r': (.+)$',node,re.M)[1]
 return [(p,int(a),int(b)) for p,a,b in re.findall(r'`([^`]+)` lines (\d+)-(\d+)',value)]
def digest(rows):return hashlib.sha256(json.dumps(rows,separators=(',',':')).encode()).hexdigest()
tree=nodes(git('show',head+':docs/tasks/SUPPORTING-SOURCE-READING.md').decode())
paths=git('ls-tree','-r','--name-only',baseline,'--','conf/','tablescript/','noncore/','specs/','ebnf/').decode().splitlines()
assert len(paths)==158
assert git('ls-tree','-r','--name-only',head,'--','conf/','tablescript/','noncore/','specs/','ebnf/').decode().splitlines()==paths
parts={};classes={}
for p in paths:
 raw=Path(p).read_bytes();assert raw==git('show',baseline+':'+p),p
 parts[p]=raw.splitlines(keepends=True)
 classes[p]=['omitted']*len(parts[p])
assert sum(map(len,parts.values()))==25613
assert sum(sum(map(len,x)) for x in parts.values())==964256
original_coverage={p:[0]*len(lines) for p,lines in parts.items()};original_ranges=0
for i in range(1,22):
 node=tree['SUPPORTING-SOURCE-READING.1.'+str(i)];rows=[]
 for p,a,b in ranges(node,'Scope'):
  chunk=b''.join(parts[p][a-1:b]);rows.append(dict(path=p,start=a,end=b,bytes=len(chunk),sha256=hashlib.sha256(chunk).hexdigest()))
  for j in range(a-1,b):original_coverage[p][j]+=1
  original_ranges+=1
 evidence=re.search(r'^  Baseline evidence: (\d+) fragments / (\d+) bytes; ordered range SHA-256 `([0-9a-f]+)`',node,re.M)
 assert evidence and sum(x['end']-x['start']+1 for x in rows)==int(evidence[1]) and sum(x['bytes'] for x in rows)==int(evidence[2]) and digest(rows)==evidence[3],i
assert original_ranges==174 and all(all(n==1 for n in xs) for xs in original_coverage.values())
history=tree['SUPPORTING-SOURCE-READING.1.1']
assert 'Status: `done`' in history
for p,a,b in ranges(history,'Scope'):
 for i in range(a-1,b):assert classes[p][i]=='omitted';classes[p][i]='historical_read'
checkpoints=[
 ('17','4f2508fd5695231cbae98ebef27c8223170a4149','cf36237dccb500dc8a39c21786c484f0a9ee679b',179,26444,7,'910001b25a8dc5581ff6254cb39f5bc5888dbb3c1665af061fa8edc0205a6e39','254938dc997bd16d9511d0cbff833be5b7cc064b4225f09bab674aa03ef8a3e2'),
 ('18','cf36237dccb500dc8a39c21786c484f0a9ee679b','7a3f0b8aa1e649d74be405e822eb462227eb26be',195,62203,10,'3cd1f38e22645be4ebff171713b57588cd261e1b2c967c880d5f989cdb1092bb','30e95f636941d945b5b532854562a6c158b63e7a3401848a79cec593178f9dce'),
 ('19','7a3f0b8aa1e649d74be405e822eb462227eb26be','51fa104fe3b8cff023bb9272e17e4f2a222f9ecf',255,8134,2,'a580a5d7ae6ba32b9a19fa21a98203742090f7159cd47f131266a47d0b6eb2ae','e6bf546c68d82178106cac912714ae4e731e80555626372a832197e0c2504b71'),
]
proof=[]
for suffix,parent,commit,nfrag,nbytes,nwin,rsha,wsha in checkpoints:
 leaf='SUPPORTING-SOURCE-READING.1.'+suffix
 assert git('rev-parse',commit+'^').decode().strip()==parent
 assert git('log','-1','--format=%s',commit).decode().startswith(leaf+' - ')
 snapshot=nodes(git('show',commit+':docs/tasks/SUPPORTING-SOURCE-READING.md').decode())[leaf]
 assert snapshot==tree[leaf]
 assert 'Status: `done`' in snapshot and 'Activation commit: `'+parent+'`' in snapshot
 expected=ranges(snapshot,'Required reading scope');rows=[];windows=[]
 for p,a,b in expected:
  assert Path(p).read_bytes()==git('show',parent+':'+p)==git('show',commit+':'+p)
  chunk=b''.join(parts[p][a-1:b]);rows.append(dict(path=p,start=a,end=b,bytes=len(chunk),sha256=hashlib.sha256(chunk).hexdigest()))
  for i in range(a-1,b):assert classes[p][i]=='omitted';classes[p][i]='required_read'
  start=a;buffer=[]
  for number in range(a,b+1):
   line=parts[p][number-1]
   if buffer and sum(map(len,buffer))+len(line)>6500:
    data=b''.join(buffer);windows.append(dict(path=p,start=start,end=number-1,bytes=len(data),sha256=hashlib.sha256(data).hexdigest()));start=number;buffer=[]
   buffer.append(line)
  data=b''.join(buffer);windows.append(dict(path=p,start=start,end=b,bytes=len(data),sha256=hashlib.sha256(data).hexdigest()))
 assert sum(x['end']-x['start']+1 for x in rows)==nfrag
 assert sum(x['bytes'] for x in rows)==nbytes
 assert len(windows)==nwin and digest(rows)==rsha and digest(windows)==wsha
 changes=git('diff','--name-only',parent,commit).decode().splitlines()
 allowed={'CHANGES.md','DEVELOPMENT_NOTES.md','KNOWLEDGE_MAP.md','LIVE_ACHIEVEMENT_STATUS.md','MEMORY.md','ROADMAP.md','ROADMAP_V2.md'}
 assert all(p in allowed or p.startswith('docs/') for p in changes),changes
 proof.append(dict(leaf=leaf,activation=parent,commit=commit,fragments=nfrag,bytes=nbytes,windows=nwin,ranges=rows,range_sha256=rsha,window_sha256=wsha))
counts={name:dict(fragments=0,bytes=0) for name in ['required_read','historical_read','omitted']}
for p,lines in parts.items():
 for line,kind in zip(lines,classes[p]):counts[kind]['fragments']+=1;counts[kind]['bytes']+=len(line)
assert counts=={'required_read':{'fragments':629,'bytes':96781},'historical_read':{'fragments':1500,'bytes':61165},'omitted':{'fragments':23484,'bytes':806310}},counts
statuses={}
for i in range(1,22):
 status=re.search(r'^  Status: `([^`]+)`',tree['SUPPORTING-SOURCE-READING.1.'+str(i)],re.M)[1]
 statuses.setdefault(status,[]).append(i)
assert statuses=={'done':[1,17,18,19],'superseded':list(range(2,17))+[20,21]}
repairs={k:n for k,n in tree.items() if re.fullmatch(r'SUPPORTING-SOURCE-READING\.2\.\d+(?:\.\d+)*',k)}
assert len(repairs)==10 and all('Status: `pending`' in n for n in repairs.values())
assert all('SUPPORTING-SOURCE-READING.2.'+str(i) in repairs for i in range(1,8))
report=dict(baseline=baseline,reading_head=head,baseline_files=len(paths),original_ranges=original_ranges,coverage=counts,groups=statuses,current_windows=19,checkpoints=proof,open_repair_nodes=sorted(repairs))
scratch=Path('.linkedspec-data/scratch/support31');scratch.mkdir(parents=True,exist_ok=True);(scratch/'audit.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k!='checkpoints'},indent=2))
print('PASS independent committed coverage, activation chain, source identity, explicit omissions and repair preservation; no new physical reading credit or runtime signoff.')
SUPPORTING_READING_CLOSEOUT_AUDIT
```

Related: [[supporting-source-reading-coverage]],
[[current-supporting-grammar-dependencies]], [[self-hosted-grammar-ast-drift]],
[[task-partition-capacity-registry-drift]], and [[SUPPORTING-SOURCE-READING]].
