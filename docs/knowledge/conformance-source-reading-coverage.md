---
id: conformance-source-reading-coverage
title: Conformance and Unicode reading has exact baseline ownership in 143 bounded groups
answers:
  - "how are oversized source lines read without truncation"
  - "where is conformance test and Unicode source reading tracked"
  - "how many conformance source reading groups remain"
  - "does source reading include decompressed pinned Unicode inputs"
  - "how do I verify conformance reading source and range coverage"
  - "which conformance source reading file has the longest line"
date: 2026-09-13
status: exact decomposition preserved; physical reading 6/143, twenty-five files complete and137 groups remain
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

# Recorded reading-window reconstruction

Group `.1.1` completes11 windows/770 fragments/65,485 bytes. Its comprehension
and confirmed guide-claim repair ownership live in [[conformance-capability-guide-reading]].
The task Reading evidence field pins its ordered windows. This reusable replay
checks a completed group against baseline source; it does not replace physical
reading or grant a second reading credit. Pass the desired completed leaf as the
argument. A long logical line may need smaller complete presentation chunks while
its source-window identity remains exact.

```bash
bash tools/project_data_run.sh python3 - CONFORMANCE-SOURCE-READING.1.1 <<'CONFORMANCE_READING_WINDOWS'
from pathlib import Path
import gzip,hashlib,json,re,subprocess,sys
leaf=sys.argv[1] if len(sys.argv)>1 else 'CONFORMANCE-SOURCE-READING.1.1'
text=Path('docs/tasks/CONFORMANCE-SOURCE-READING.md').read_text()
node=re.search(r'^- ID: `'+re.escape(leaf)+r'`\n.*?(?=^- ID: |^## |\Z)',text,re.M|re.S)
assert node and 'Status: `done`' in node[0]
scope=re.search(r'^  Scope: (.+)$',node[0],re.M)[1];windows=[];fragments=size=0
for path,kind,a,b in re.findall(r'`([^`]+)` (decoded lines|lines) (\d+)-(\d+)',scope):
 a=int(a);b=int(b);raw=Path(path).read_bytes()
 assert raw==subprocess.check_output(['git','show','baeb984e36a94a15951cd23d4c52def5064cdaca:'+path])
 decoded=gzip.decompress(raw) if kind=='decoded lines' else raw
 lines=decoded.splitlines(True);start=a;buffer=[]
 for number in range(a,b+1):
  line=lines[number-1]
  if buffer and sum(map(len,buffer))+len(line)>6500:
   chunk=b''.join(buffer);windows.append(dict(path=path,start=start,end=number-1,bytes=len(chunk),sha256=hashlib.sha256(chunk).hexdigest()));start=number;buffer=[]
  buffer.append(line)
 if buffer:
  chunk=b''.join(buffer);windows.append(dict(path=path,start=start,end=b,bytes=len(chunk),sha256=hashlib.sha256(chunk).hexdigest()))
 fragments+=b-a+1;size+=sum(map(len,lines[a-1:b]))
digest=hashlib.sha256(json.dumps(windows,separators=(',',':')).encode()).hexdigest()
evidence=re.search(r'^  Reading evidence: (\d+) complete windows / (\d+) fragments / (\d+) bytes; ordered window SHA-256 `([0-9a-f]+)`',node[0],re.M)
assert evidence and (len(windows),fragments,size,digest)==(int(evidence[1]),int(evidence[2]),int(evidence[3]),evidence[4])
print(json.dumps(dict(leaf=leaf,windows=len(windows),fragments=fragments,bytes=size,window_sha256=digest)))
print('PASS reconstruction of recorded complete reading windows; hashes are continuity evidence, not new reading credit.')
CONFORMANCE_READING_WINDOWS
```


# September 13 identity, fixture and gap-prefix comprehension

`CONFORMANCE-SOURCE-READING.1.3` reads all 19 recorded windows, 1,500 fragments
and 52,668 bytes. Diagnostic and duplicate-slot contracts, six capability fixtures,
three generated behavior fixture files and the generated-source contract are now
complete; gap reading stops at805. Cumulative reading is 3,078 fragments/183,655
bytes and16 complete files. The next leaf owns gap806–1213, including the remaining
mutation list, admission and public sections. The generic recorded-window recipe
above reconstructs this leaf with its exact task Scope and reading evidence.

Canonical comprehension remains with [[duplicate-regex-slot-identity-contract]],
[[generated-source-contract-v1]], [[inter-match-gap-recurring-public-closeout-plan]]
and [[typed-lossless-gap-composition]]. Authored identity cannot be recovered from
duplicate pattern text. Generated v1 is the semantic baseline, distinct from the
current v2 format; fixture inventory and source markers alone do not prove fresh
independent host execution. Gap state commits accepted match presence, including
falsey payloads, and is suspended/restored per invocation. Gap rollback does not
promise rollback of user variables, AST/output, diagnostics or host effects.

Fresh structural/neutral checks pass duplicate identity5 fixtures/59 mutations,
generated roles10 families/one behavior fixture, language250 names/105 corpus plus
one named-mark fixture/126 public contracts, and gap63 semantic/34 public mutations
with current9-complete rollout. Older246-name and neutral-only gap milestone cards
are dated evidence; the later gap public-admission card records current250/126.
These checks do not execute backend matrices, rebuild dependencies or close repairs.

```bash
bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py
bash tools/project_data_run.sh env PERL5LIB= perl tools/check_generated_source_contract.pl
bash tools/project_data_run.sh env PERL5LIB= perl tools/check_language_capability_coverage.pl
bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py
```


The subsequent `.1.4` reads all 13 windows of gap806–1213, logical1–303,
manifest1–278 and map-leaves1–33: 1,022 fragments/65,375 bytes. This completes the
first three sources, bringing cumulative reading to4,100 fragments/249,030 bytes
and19 complete files; map34–461 remains `.1.5`-owned. Fresh logical26,
capability20/100/one legacy exclusion and mutation167+592 neutral proof pass.
[[logical-helper-neutral-contract]] and [[mutation-capability-admission]] explain
why historical fixture boundaries/frozen status must be reconciled with later
admission; passing metadata does not close the current runtime repair backlog.


# Complete presentation of an oversized source line

`.1.5` reads11 source windows in13 complete presentations:690 fragments/65,516
bytes, bringing cumulative reading to4,790 fragments/314,546 bytes and21 complete
files. The14,687-byte canonical frame at line8 is consumed in three exact UTF-8
byte intervals: [0,6500), [6500,13000), [13000,14687). The task's `Long-line evidence`
retains each chunk hash and the whole-line identity. Presentation boundaries are
not source-line boundaries and do not omit or duplicate bytes. Frames13–35 remain
`.1.6`-owned; full-file materialization/validation is not reading credit for them.

Fresh MCP proof is35 canonical frames/10 raw inputs/10 lifecycle cases/76 transport
mutations and5/5 implementations plus6/6 runtimes/141 admission mutations. The
current contract and its historical rollout remain in [[mcp-2026-07-28-stdio-contract]];
completed map-leaves reading reconciles [[map-leaves-mutation-neutral-contract]]
and [[write-map-leaves-neutral-composition]] without closing known runtime repairs.

```bash
bash tools/project_data_run.sh python3 - <<'CONFORMANCE_LONG_LINE_WINDOWS'
from pathlib import Path
import hashlib,json,re,subprocess,sys
leaf=sys.argv[1] if len(sys.argv)>1 else 'CONFORMANCE-SOURCE-READING.1.5'
text=Path('docs/tasks/CONFORMANCE-SOURCE-READING.md').read_text()
node=re.search(r'^- ID: `'+re.escape(leaf)+r'`\n.*?(?=^- ID: |^## |\Z)',text,re.M|re.S)
assert node and 'Status: `done`' in node[0]
records=json.loads(re.search(r'^  Long-line evidence: (.+)$',node[0],re.M)[1])
assert records
for record in records:
 path=record['path'];raw=Path(path).read_bytes()
 assert raw==subprocess.check_output(['git','show','baeb984e36a94a15951cd23d4c52def5064cdaca:'+path])
 line=raw.splitlines(True)[record['line']-1]
 assert len(line)==record['bytes'] and hashlib.sha256(line).hexdigest()==record['sha256']
 chunks=[];position=0
 for chunk in record['chunks']:
  assert chunk['start']==position and position<chunk['end']<=len(line)
  value=line[position:chunk['end']];value.decode('utf-8')
  assert len(value)==chunk['bytes']<=6500 and hashlib.sha256(value).hexdigest()==chunk['sha256']
  chunks.append(value);position=chunk['end']
 assert position==len(line) and b''.join(chunks)==line
print('PASS exact recorded UTF-8 byte chunks; reconstruction grants no new physical-reading credit.')
CONFORMANCE_LONG_LINE_WINDOWS
```


## September 13 complete transport-input reading

`.1.6` reads 12 complete windows: 1,500 fragments and 63,045 baseline-identical
bytes. Canonical frames, corpus, schema and semantic payloads are now physically
complete; validator cases1–51 are read and the definition list continues in `.1.7`.
Cumulative coverage is6/143, 6,290 fragments, 377,591 bytes and25 complete files.

The schema and corpus preserve three outcome layers: JSON-RPC errors, tool execution
errors, and native semantic `ok:false` inside `isError:false`. The four payloads are
three native responses plus a restricted capability projection. Canonical owners
[[perl-mcp-decoded-server]], [[mcp-2026-07-28-stdio-contract]] and
[[mcp-all-twenty-transport-blocker]] already explain these distinctions and the
corrected fact-key/query-contract boundary. The `.1.5` transport/admission checks
remain dated proof over identical sources. No native execution is repeated or
inferred. [[rust-mcp-final-eof-byte-limit-gap]] remains open; separate raw and
lifecycle cases do not establish its combined boundary. Startup `.36` competing
validation precedence and `.5` historical ADR qualification also retain their owners.
