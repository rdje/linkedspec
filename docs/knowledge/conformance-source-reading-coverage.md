---
id: conformance-source-reading-coverage
title: Conformance and Unicode reading has exact baseline ownership in 143 bounded groups
answers:
  - "where is conformance test and Unicode source reading tracked"
  - "how many conformance source reading groups remain"
  - "does source reading include decompressed pinned Unicode inputs"
  - "how do I verify conformance reading source and range coverage"
  - "which conformance source reading file has the longest line"
date: 2026-09-13
status: exact decomposition; physical reading 0/143
tags: [reading, conformance, tests, unicode, continuity, CONFORMANCE-SOURCE-READING]
evidence: "Startup .3.8.0 independently accounts for160 baseline-identical files,5,422,313 stored bytes and8,257,059 decoded bytes in167,606 line fragments/167,604 LF delimiters. Four gzip inputs contribute54,500 decoded lines. All143 groups/302 ranges are contiguous, disjoint and bounded at1500 fragments/65536 bytes. No source, registry or runtime behavior changes; no physical-reading credit from inventory."
reverify: "Run CONFORMANCE_SOURCE_READING_COVERAGE below through the project-data wrapper; it derives source identity from Git and range ownership from the task-tree rather than a parallel manifest. Use scripts/check_task_tree_metadata.sh for actual task collection limits."
---

# Exact scope and decoding

`docs/tasks/CONFORMANCE-SOURCE-READING.md` owns every inclusive range under
startup `.3.8`. Baseline is `baeb984e36a94a15951cd23d4c52def5064cdaca`;
planning activation is `9833430954c3999769045abbcaa4d20389a7af4c`.
Ordered selectors are capability_conformance, cli_conformance, t, tests and
unicode_case. Git owns all path/mode/blob identities; task Scope fields own
reading progress. No separate tracked source manifest is introduced.

All160 baseline files match current Git and present bytes. Four pinned upstream
`.gz` inputs are decompressed losslessly in memory, then decoded strictly as UTF-8.
Their Scope fields explicitly say `decoded lines`, so compressed bytes cannot be
mistaken for source-reading coordinates. Exact decoded hashes remain pinned below.
There are no empty inputs or binary decoded files. Line fragments count the final
unterminated lines as well as LF-terminated lines.

| Decoded pinned input | Stored bytes | Decoded bytes | Lines |
| --- | ---: | ---: | ---: |
| `DerivedCoreProperties.txt.gz` | 207,289 | 1,134,783 | 13,601 |
| `LICENSE.txt.gz` | 1,063 | 1,995 | 39 |
| `SpecialCasing.txt.gz` | 4,309 | 17,049 | 285 |
| `UnicodeData.txt.gz` | 304,629 | 2,198,209 | 40,575 |

The143 groups preserve the existing maximum1500 fragments/65536 bytes each.
Their302 ranges cover every decoded byte exactly once. The longest logical line
is14,687 bytes in `capability_conformance/mcp_semantic_transport/canonical_frames.jsonl`;
use complete small byte windows if needed to avoid output truncation. This is a
reading-presentation constraint, not a runtime defect or a reason to omit data.

The first group is `capability_conformance/README.md` lines1–770:770 fragments/
65,485 bytes. Later groups own the exact suffixes, all neutral contracts, fixtures,
regression sources, Unicode generators and upstream data. Earlier dated tests or
isolated source probes do not establish complete coverage of these pending groups.

No capacity limit changes. Measure each actual candidate under the existing
registry and corrected partition guard. The two ADR0120 exceptions already close
the checker fix and supporting reading; they do not waive this lane's later
parent/infrastructure/push requirements. Source repairs retain startup prerequisites.

# Independent source and range audit

```bash
bash tools/project_data_run.sh python3 - <<'CONFORMANCE_SOURCE_READING_COVERAGE'
from pathlib import Path
import collections,gzip,hashlib,json,re,subprocess
baseline='baeb984e36a94a15951cd23d4c52def5064cdaca'
selectors=['capability_conformance/','cli_conformance/','t/','tests/','unicode_case/']
def git(*args):return subprocess.check_output(['git',*args])
records=git('ls-tree','-r','-z',baseline,'--',*selectors)
assert records==git('ls-tree','-r','-z','HEAD','--',*selectors)
sources={};stored_total=0;decoded_inputs=[]
for record in records.rstrip(b'\0').split(b'\0'):
 meta,path=record.split(b'\t',1);path=path.decode();mode,kind,blob=meta.decode().split()
 assert kind=='blob' and mode in ['100644','100755']
 raw=git('cat-file','blob',blob);assert Path(path).read_bytes()==raw,path
 stored_total+=len(raw);decoded=gzip.decompress(raw) if path.endswith('.gz') else raw
 decoded.decode('utf-8');assert b'\0' not in decoded
 lines=decoded.splitlines(True);assert lines and b''.join(lines)==decoded
 sources[path]=lines
 if path.endswith('.gz'):decoded_inputs.append(dict(path=path,stored_bytes=len(raw),decoded_bytes=len(decoded),fragments=len(lines),sha256=hashlib.sha256(decoded).hexdigest()))
assert len(sources)==160 and stored_total==5422313 and len(decoded_inputs)==4
text=Path('docs/tasks/CONFORMANCE-SOURCE-READING.md').read_text()
nodes={m[1]:m[0] for m in re.finditer(r'^- ID: `([^`]+)`\n.*?(?=^- ID: |^## |\Z)',text,re.M|re.S)}
coverage={p:[0]*len(lines) for p,lines in sources.items()};groups=[];count_ranges=0
for i in range(1,144):
 key='CONFORMANCE-SOURCE-READING.1.'+str(i);node=nodes[key]
 scope=re.search(r'^  Scope: (.+)$',node,re.M)[1]
 rows=[]
 for p,kind,a,b in re.findall(r'`([^`]+)` (decoded lines|lines) (\d+)-(\d+)',scope):
  a=int(a);b=int(b);assert 1<=a<=b<=len(sources[p])
  assert (kind=='decoded lines')==p.endswith('.gz')
  chunk=b''.join(sources[p][a-1:b]);rows.append(dict(path=p,start=a,end=b,bytes=len(chunk),sha256=hashlib.sha256(chunk).hexdigest(),encoding='gzip-utf8' if p.endswith('.gz') else 'utf8'))
  for j in range(a-1,b):coverage[p][j]+=1
  count_ranges+=1
 assert rows,key
 n=sum(r['end']-r['start']+1 for r in rows);size=sum(r['bytes'] for r in rows)
 digest=hashlib.sha256(json.dumps(rows,separators=(',',':')).encode()).hexdigest()
 evidence=re.search(r'^  Baseline evidence: (\d+) fragments / (\d+) decoded bytes; ordered range SHA-256 `([0-9a-f]+)`',node,re.M)
 assert evidence and (n,size,digest)==(int(evidence[1]),int(evidence[2]),evidence[3]),key
 assert n<=1500 and size<=65536,key
 status=re.search(r'^  Status: `([^`]+)`',node,re.M)[1]
 groups.append(dict(leaf=key,fragments=n,bytes=size,ranges=len(rows),status=status))
assert count_ranges==302 and all(all(x==1 for x in spans) for spans in coverage.values())
assert sum(g['fragments'] for g in groups)==167606 and sum(g['bytes'] for g in groups)==8257059
expected={
'DerivedCoreProperties.txt.gz':'24c7fed1195c482faaefd5c1e7eb821c5ee1fb6de07ecdbaa64b56a99da22c08',
'LICENSE.txt.gz':'e7a93b009565cfce55919a381437ac4db883e9da2126fa28b91d12732bc53d96',
'SpecialCasing.txt.gz':'efc25faf19de21b92c1194c111c932e03d2a5eaf18194e33f1156e96de4c9588',
'UnicodeData.txt.gz':'2e1efc1dcb59c575eedf5ccae60f95229f706ee6d031835247d843c11d96470c'}
assert {Path(x['path']).name:x['sha256'] for x in decoded_inputs}==expected
assert not git('diff','--name-only',baseline,'--',*selectors).strip()
assert not git('ls-files','--others','--exclude-standard','--',*selectors).strip()
report=dict(baseline=baseline,current_head=git('rev-parse','HEAD').decode().strip(),files=160,stored_bytes=stored_total,decoded_bytes=8257059,line_fragments=167606,lf_delimiters=sum(b''.join(x).count(b'\n') for x in sources.values()),groups=143,ranges=count_ranges,group_statuses=dict(collections.Counter(g['status'] for g in groups)),tree_sha256=hashlib.sha256(records).hexdigest(),decoded_inputs=decoded_inputs)
s=Path('.linkedspec-data/scratch/conformance_plan');s.mkdir(parents=True,exist_ok=True);(s/'audit.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
print('PASS exact complete source/range/budget/decoded-input inventory; this audit grants no physical-reading credit.')
CONFORMANCE_SOURCE_READING_COVERAGE
```

Related: [[startup-codebase-reading-inventory]], [[unicode-17-case-contract-data]],
[[supporting-reading-closeout-audit]], [[task-partition-capacity-registry-drift]],
and [[CONFORMANCE-SOURCE-READING]].
