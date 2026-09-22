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
  - "what evidence capacity blocks remaining conformance reading"
  - "what exact fourteen limits are proposed for remaining conformance reading"
date: 2026-09-22
status: exact baseline decomposition preserved; physical reading 87/143, 120 files complete and 56 groups remain; one approved current-source delta
tags: [reading, conformance, tests, unicode, continuity, CONFORMANCE-SOURCE-READING]
evidence: "Startup .3.8.0 independently accounts for160 baseline-identical files,5,422,313 stored bytes and8,257,059 decoded bytes in167,606 line fragments/167,604 LF delimiters. Four gzip inputs contribute54,500 decoded lines. All143 groups/302 ranges are contiguous, disjoint and bounded at1500 fragments/65536 bytes. No source, registry or runtime behavior changes; no physical-reading credit from inventory."
reverify: "Run CONFORMANCE_SOURCE_READING_COVERAGE below through the project-data wrapper; it derives source identity from Git and range ownership from the task-tree rather than a parallel manifest. Use scripts/check_task_tree_metadata.sh for actual task collection limits."
evidence_capacity_proposal: "CONFORMANCE-SOURCE-READING.4.1 at 7b921a195: notes58,910 bytes leaves72 before required rollover; both history collections/manifests are full. Fifty exact reading commits bound a99-unit reserve. Independent and production models agree on eight rollovers each;187 production threshold/old-proposed checks pass. Fourteen exact scalar changes are proposed only; .4.2 requires explicit disposition and before-reading implementation authority, followed by ordinary canonical admission."
---

# Exact scope and decoding

`docs/tasks/CONFORMANCE-SOURCE-READING.md` owns every inclusive range under
startup `.3.8`. Baseline is `baeb984e36a94a15951cd23d4c52def5064cdaca`;
planning activation is `9833430954c3999769045abbcaa4d20389a7af4c`.
Ordered selectors are capability_conformance, cli_conformance, t, tests and
unicode_case. Git owns all path/mode/blob identities; task Scope fields own
reading progress. No separate tracked source manifest is introduced.

The 160-file baseline remains the authority for historical reading ranges. Current
Git differs only in `capability_conformance/rule_local_cursor_contract.json`:
integration commits `42490a9d9` and `fbb135d63` update ten current census markers,
one count and one path list on twelve existing lines. The two added guide paths
increase the file by 113 bytes without changing line coordinates or runtime
semantics. Its approved blob is `0efd2ef33198b9e0fa3a90e23308a402824e4c00`;
all other 159 files remain exact. Current stored/decoded totals are 5,422,426 /
8,257,172 bytes. These additional bytes are not added to historical reading credit.

Group 35 owns the audit-recipe correction: the old uniform-identity assertion
fails on this known integration delta. The current audit pins its exact identity
and rejects any other path, mode or content change; range reconstruction always
uses baseline bytes. Four pinned upstream
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
def parse_tree(data):
 return {p.decode():tuple(m.decode().split()) for m,p in (r.split(b'\t',1) for r in data.rstrip(b'\0').split(b'\0'))}
def validate_snapshot(original,current,approved):
 assert set(current)==set(original)
 for path,row in original.items():
  assert current[path][:2]==row[:2],path
  assert current[path][2]==approved.get(path,row[2]),path
 assert {p for p in original if current[p]!=original[p]}==set(approved)
approved={'capability_conformance/rule_local_cursor_contract.json':'0efd2ef33198b9e0fa3a90e23308a402824e4c00'}
current=parse_tree(git('ls-tree','-r','-z','HEAD','--',*selectors))
validate_snapshot(parse_tree(records),current,approved)
sources={};stored_total=0;current_total=0;decoded_inputs=[]
for record in records.rstrip(b'\0').split(b'\0'):
 meta,path=record.split(b'\t',1);path=path.decode();mode,kind,blob=meta.decode().split()
 assert kind=='blob' and mode in ['100644','100755']
 raw=git('cat-file','blob',blob);present=git('cat-file','blob',current[path][2])
 assert Path(path).read_bytes()==present,path
 assert len(present.splitlines(True))==len(raw.splitlines(True)),path
 current_total+=len(present)
 stored_total+=len(raw);decoded=gzip.decompress(raw) if path.endswith('.gz') else raw
 decoded.decode('utf-8');assert b'\0' not in decoded
 lines=decoded.splitlines(True);assert lines and b''.join(lines)==decoded
 sources[path]=lines
 if path.endswith('.gz'):decoded_inputs.append(dict(path=path,stored_bytes=len(raw),decoded_bytes=len(decoded),fragments=len(lines),sha256=hashlib.sha256(decoded).hexdigest()))
assert len(sources)==160 and stored_total==5422313 and len(decoded_inputs)==4
assert current_total==5422426 and current_total-stored_total==113
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
assert set(git('diff','--name-only',baseline,'--',*selectors).decode().splitlines())==set(approved)
assert not git('ls-files','--others','--exclude-standard','--',*selectors).strip()
report=dict(baseline=baseline,current_head=git('rev-parse','HEAD').decode().strip(),files=160,stored_bytes=stored_total,decoded_bytes=8257059,current_stored_bytes=current_total,current_decoded_bytes=8257172,approved_current_blobs=approved,line_fragments=167606,lf_delimiters=sum(b''.join(x).count(b'\n') for x in sources.values()),groups=143,ranges=count_ranges,group_statuses=dict(collections.Counter(g['status'] for g in groups)),tree_sha256=hashlib.sha256(records).hexdigest(),decoded_inputs=decoded_inputs)
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
Run the independent audit above separately to validate current source identities.

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
 a=int(a);b=int(b);raw=subprocess.check_output(['git','show','baeb984e36a94a15951cd23d4c52def5064cdaca:'+path])
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


## September 13 resolution, descriptor and progressive-prefix reading

`.1.7` reads12 complete windows, 1,500 fragments and60,106 baseline-identical bytes.
Validator cases, transport manifest, native resolution and outward descriptors
reach EOF; progressive dispatch1–540 stops inside the token-replacement case.
Cumulative reading is7/143, 7,790 fragments, 437,697 bytes and29 complete files.

[[native-spec-resolution-contract]] distinguishes exact paths from ordered named
roots and preserved UTF-8. [[lua-outward-function-descriptor-union]] qualifies the
fixed-v1 list in [[outward-compiled-descriptor-four-backend-contract]] with v2/v3;
this checkpoint adds that explicit qualification to the older general card.
[[progressive-span-dispatch-audit-plan]] and [[progressive-span-dispatch-recurring-gate]]
describe the admitted private contract, while [[perl-progressive-resource-ceiling-enforcement-gap]]
retains the known combined-boundary exception. Fresh native14/9/4 and progressive
9/9/116 plus public6/12/10/60 neutral checks pass without runtime repair or a matrix.
MCP and callable/signature proof remain dated unchanged-source evidence.


## September 13 progressive, recognition and repetition boundaries

`.1.8` reads15 complete windows, 1,500 fragments and65,525 baseline-identical bytes.
Progressive dispatch, punctuation aliases, recognition transactions and three
explicit-OR fixtures reach EOF. Repeated-result1–157 stops inside a bounded case.
Cumulative reading is8/143, 9,290 fragments, 503,222 bytes and35 complete files.

[[progressive-span-dispatch-public-no-drift]] preserves private carrier/admission
scope. [[recognition-transaction-neutral-contract]] distinguishes strict match
booleans, staged falsey payloads and invocation-owned terminals from actual cursor
progress. [[explicit-or-action-result-shape-parity-gap]] owns per-hit return
collection and the separate zero-width accept-once rule. Known token/restoration
and progressive resource/nesting defects remain open; these finite neutral fixtures
do not close their combined boundaries. Fresh punctuation6/4/6 and recognition
138/250/58/public3/26/45 proof passes. The punctuation card's historical no-emitter
sentence is qualified against [[lua-generated-source-accepted-subset]] and existing
Lua admission; its original dated evidence remains intact.


## September 13 repetition, root and cursor reading

`.1.9` reads11 complete windows, 1,445 fragments and65,519 baseline-identical bytes.
Repetition/root-selection reach EOF; cursor1–160 stops inside Rust admission roles.
Cumulative reading is9/143, 10,735 fragments, 568,741 bytes and37 complete files.

[[explicit-or-action-result-shape-parity-gap]] separates iteration values and
lifecycle exits. [[root-rule-selection-precedence]] separates dynamic selection
from authored marker bits and strict-unused references. [[rule-local-cursor-neutral-contract]]
owns intrinsic child policy, bare ownership, removed overrides and generated-v2
families. Fresh repetition8/10/8-complete/54, root8/3/3/7-complete/54 and cursor
36/18/8/74-files/8-complete/60 proof passes. Current root24/18 and cursor30/28
public inventories reconcile the dated README-routing/formal-grammar updates in
[[root-rule-selection-five-backend-admission]] and [[rule-local-cursor-public-no-drift]].
No native execution or runtime repair is inferred; all earlier obligations remain.


## September 13 scalar and semantic-query reading

`.1.10` reads18 windows,789 fragments and65,489 baseline-identical bytes.
Cursor, numeric/text and six semantic inputs reach EOF; semantic contract1–363
ends at Dart's admission consumer. Cumulative reading is10/143,11,524 fragments,
634,230 bytes and46 complete files. [[cross-backend-scalar-numeric-drift]] and
[[scalar-to-text-coercion-cross-backend-gap]] distinguish boolean rejection from
text conversion; their existing Unicode, unary-cat and large-number repair owners
remain. Fresh numeric55/18 and Perl text7 checks pass without broadening coverage.
[[semantic-introspection-neutral-contract]] owns stable IDs, ordered query results,
deterministic budget prefixes and native source ceilings. The six exact inputs,
twenty query cases and Perl/Rust roles are read; later model/rollout bytes remain
unread. Fresh semantic neutral proof passes; no native matrix or repair closes.


## September 13 semantic rollout and model reading

`.1.11` reads 12 windows, 554 fragments and 65,425 baseline-identical bytes.
The semantic contract reaches EOF; model1–201 completes graph, calls, failed,
runtime and privacy snapshots, then enters the identity-limited source reference.
Cumulative reading is11/143,12,078 fragments,699,655 bytes and47 complete files.
[[semantic-introspection-public-no-drift]] owns28 surfaces/nine examples; the
[[semantic-introspection-recurring-gate]] retains six twelve-role admissions and
the selected30-leg primary projection. [[semantic-introspection-staged-artifact-schema]]
now explicitly dates its private milestones against the existing9/9 public rollout.
Duplicate slots, staged versus generated provenance, failed compilation and
captured execution remain distinct. Unicode byte spans and scalar columns differ.
The identity-limited model suffix remains unread. Existing semantic proof is
retained and rechecked after governed public edits; no native matrix is claimed.


## September 13 staged scheduling and policy reading

`.1.12` reads 11 windows, 1,012 fragments and 65,472 baseline-identical bytes.
The semantic model reaches EOF; staged enrichment1–996 stops inside ownership.
Cumulative reading is 12/143, 13,090 fragments, 765,127 bytes and 48 complete files.
[[general-staged-ast-enrichment-neutral-contract]] separates declaration from
post-AST scheduling, exact typed provenance, complete-depth ordering, isolated
child state, shared limits and detached result/failure policies. The historical
milestones in [[general-staged-ast-current-boundary]] remain explicitly dated;
[[staged-parser-registry-dispatch-contract]] already qualifies resolve/load/compile
as caller preparation for general v2. [[staged-ast-enrichment-recurring-gate]] and
[[general-staged-ast-enrichment-recomposition]] own existing runtime admissions.
Focused neutral/public checks do not close known resource or backend defects.
The remaining ownership/public records belong to `.1.13`; no source changes.


## September 13 lifecycle and typed-source reading

`.1.13` reads 11 windows, 841 fragments and 65,510 baseline-identical bytes.
Staged enrichment and lifecycle contracts reach EOF; typed source1–452 stops
inside recursive-observation public assertions. Cumulative reading is13/143,
13,931 fragments,830,637 bytes and50 complete files. [[standalone-lifecycle-block-audit]]
owns normalization, duplicate order, earlier brace ownership and inert legacy
plain nodes; its Rust/Dart/Julia annotations limit emitted and malformed proof.
[[typed-source-location-neutral-contract-plan]] now labels its75-mutation envelope
and ordered admissions as historical; current14/0/231 and internal value boundaries
remain explicit. Positions/spans, invocation-local state, one-terminal transactions
and detached observations retain distinct roles. The92-helper/7-alias/2-internal-ID
map and33 diagnostics are read; the public assertion suffix remains `.1.14`-owned.
Existing lexical/resource/runtime repairs are unchanged; no native matrix is claimed.


## September 13 typed completion and Unicode prefix reading

`.1.14` reads six windows, 1,500 fragments and 33,332 baseline-identical bytes.
Typed source reaches EOF; Unicode-case1–1138 stops inside the01EE lowercase entry.
Cumulative reading is14/143,15,431 fragments,863,969 bytes and51 complete files.
Typed composition preserves six behavior owners and all14 completed rollout rows.
[[unicode-17-case-contract-data]] owns pinned offline generation and its12 fixtures;
[[six-variant-unicode-17-case-parity]] owns existing native admissions.
[[unicode-case-mapping-cross-backend-gap]] now labels its host probes as historical
and routes current verification through LinkedSpec's generated-data checker.
Read mappings include ASCII/Latin, dotted-I expansion and non-adjacent/titlecase
convergence. Offline byte equality grants no reading credit for later mappings,
properties, context rules, fixtures or decoded upstream inputs. All repairs remain.


## Conformance reading checkpoint

`CONFORMANCE-SOURCE-READING.1.87` reads 9 windows, 1,500 fragments and 54,923 baseline bytes.
Cumulative reading is 87/143 groups, 106,904 fragments / 4,673,539 baseline bytes and 120 complete files.
Staged enrichment is read through line 1504, inside payload identity; complete executable prefix ends at 1461. The suffix and carrier/admission reading remain .1.88-owned.
[[conformance-perl-consumer-reading]] records exact observation boundaries.
The exact complete prefix through 1461 passes 135 top-level/227 nested TAP results. Staged governance passes 9 rollout legs/123 base mutations and public 6/17/10/129; typed source passes 14/0/231; recognition passes 138 ActionIR rows/250 calls/58 mutations and 9/9 rollout.
Existing startup .44 identity-lifetime and .73 competing-target repairs remain open, along with all prior defects and required source/book/policy prerequisites. No suffix execution, new runtime defect, repair closure, production change, canonical run, dependency build or push is claimed.
The pinned 113-byte delta stays separate; these ranges total 4,673,652 current bytes.
Next .1.88: Read .1.88 (1,500 fragments / 57,180 baseline bytes): staged enrichment 1505–2108, standalone lifecycle consumers, trace lowerer/planning consumers and trace CLI through 47. All repair/source/book/policy prerequisites remain.

Lowercase table entries and Final Sigma context remain separate. Exact scalar
sequences, sparse ranges, fullwidth forms and ligature identities are preserved;
none of these imply normalization or reversible casing. Native admission proof
remains separately scoped by [[six-variant-unicode-17-case-parity]].
Earlier checkpoints retain exact task ownership in CONFORMANCE-SOURCE-READING.1.15-.1.19.
Their exact former card wording is available with
`git show 978ed9f903dee68026a35ce5885035dc9bc0541d:docs/knowledge/conformance-source-reading-coverage.md`.
Update this current checkpoint in place; do not append per-leaf reading chronology.

## Remaining-reading evidence capacity

At the proposal boundary reading was 50/143. `.4.1` owns the concrete fourteen-scalar proposal at
`docs/tasks/CONFORMANCE-SOURCE-READING.md`, section Remaining-reading capacity proposal.
Its five complete replay recipes pin the clean baseline, derive maxima from the first
fifty reading commits, verify immutable history, compare independent/production
rollover models and test detached limits with the actual production predicate.
The director granted the exact proposal and before-reading implementation.
ADR0122 and containment .15 complete ordinary canonical admission at ec10be6b; reading resumes under those controls.
Exact current admission proof: [[conformance-evidence-capacity-admission]].
The 99-unit reserve covers the 93 remaining children and six support allowances,
not later startup lanes or runtime repairs. Repairs `.2.5`–`.2.9` remain owned/open.
