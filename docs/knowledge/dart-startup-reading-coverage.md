---
id: dart-startup-reading-coverage
title: Bounded Dart startup reading covers every baseline byte through 55 owned children
answers:
  - how are the Dart startup reading children scoped
  - how do I verify exact Dart startup reading coverage
  - which baseline and digests govern Dart source reading
  - how are oversized Dart source lines split for reading
  - does Dart reading decomposition count as source comprehension
date: 2026-09-09
status: exact scopes frozen under DART-STARTUP-READING.0; current physical-reading progress lives in the owning tree
tags: [dart, startup, reading, task-tree, coverage, continuity]
evidence: "Clean canonical admission a67a18bf precedes decomposition. The 115 baseline paths / 80296 physical lines / 2471305 bytes remain current-identical. Fifty-five owned children declare 169 ranges with 80297 fragments, including two UTF-8-safe byte windows for one oversized physical line. Every child is at most 1500 fragments and 65536 bytes. Parsing the actual task scopes independently reconstructs each byte exactly once and checks per-child and aggregate digests. Decomposition grants no source-reading or repair-completion credit."
reverify:
  - "Run the repository-managed DART_READING_COVERAGE block below."
  - "bash scripts/check_task_tree_metadata.sh"
  - "bash tools/project_data_run.sh perl scripts/check_readme_routing_pressure.pl --report"
---

# Exact owned Dart reading scopes

`docs/tasks/DART-STARTUP-READING.md` owns `.1.1-.1.55` in numeric order.
The source baseline is `baeb984e36a94a15951cd23d4c52def5064cdaca`; decomposition
activates from the clean canonical admission `a67a18bf8222bbc0bc63748f598d3a12a8191850`.
Startup `.3.4` remains pending until the separate Dart reading closeout `.3`.

Every `Scope` uses one-based inclusive LF-line coordinates or absolute file-byte
coordinates. The two byte windows cover one oversized physical line, so the
80,297 per-window fragments exceed the 80,296 physical source lines by one.
Both byte windows decode as complete UTF-8; no source byte is lost or repeated.
No baseline entry is empty; the recipe explicitly handles an empty entry.

Inventory SHA-256 is `34ab5a05c63525c7c7537332e71ce8104c83b5efe2a7413714923a8745d35425`.
Ordered range SHA-256 is `68844356bf68df29531e689ff80fd06be16059621c678c4c8dbaa0b9adcb398f`.
Each child retains its own fragment/byte counts and ordered range digest.
The separately demonstrated 56-group control remains a conservative planning
allowance; the actual owned plan has 55 children.

Reading each child still requires physical source reading, comprehension,
current-delta review, Knowledge reconciliation, confirmed repair ownership,
focused proof and a clean commit. The decomposition audit establishes coverage
of the declared plan only. It does not establish source comprehension, feature
completeness or defect remediation.

The audit reuses the canonical inventory recipe in
`docs/knowledge/startup-task-chronology-compaction.md`, then independently parses
the actual task declarations, reconstructs their coordinates and checks disjoint
coverage through every EOF. Current Dart edits intentionally make the historical
identity assertion fail; record and reconcile a delta before granting new credit.
Capacity controls remain owned by `docs/knowledge/dart-reading-capacity-controls.md`.

```bash
bash tools/project_data_run.sh python3 - <<'DART_READING_COVERAGE'
from pathlib import Path
import contextlib,hashlib,io,json,re
card=Path('docs/knowledge/startup-task-chronology-compaction.md').read_text()
start="bash tools/project_data_run.sh python3 - <<'DART_CAPACITY_AUDIT'\n"
recipe=card.split(start,1)[1].split('\nDART_CAPACITY_AUDIT',1)[0]
ns={}
with contextlib.redirect_stdout(io.StringIO()):
    exec(compile(recipe,'DART_CAPACITY_AUDIT','exec'),ns)
source=ns['source']; q=chr(96)
text=Path('docs/tasks/DART-STARTUP-READING.md').read_text()
nodes=re.findall(r'^- ID: '+q+r'DART-STARTUP-READING\.1\.(\d+)'+q+r'\n(.*?)(?=^- ID: |^## |\Z)',text,re.M|re.S)
assert [int(i) for i,_ in nodes]==list(range(1,56))
covered={p:0 for p in source}; ordered=[]; totals=[]; read_count=0
for number,node in nodes:
    scope=re.search(r'^  Scope: (.+)$',node,re.M).group(1)
    expected=re.search(r'^  Baseline evidence: (\d+) fragments / (\d+) bytes; ordered range SHA-256 '+q+r'([0-9a-f]{64})'+q+r'\.$',node,re.M)
    assert expected is not None
    records=[]; fragments=0; size=0
    for field in scope.split('; '):
        match=re.fullmatch(q+r'([^'+q+r']+)'+q+r' (lines|bytes|empty) (\d+)-(\d+)',field)
        assert match is not None,field
        path,kind,start,end=match.groups(); start,end=int(start),int(end)
        assert path in source
        raw=source[path]
        if kind=='lines':
            lines=raw.splitlines(keepends=True)
            assert 1<=start<=end<=len(lines)
            begin=sum(map(len,lines[:start-1])); part=b''.join(lines[start-1:end])
        elif kind=='bytes':
            assert 1<=start<=end<=len(raw)
            begin=start-1; part=raw[begin:end]
        else:
            assert start==end==0 and raw==b''
            begin=0; part=b''
        part.decode('utf-8')
        assert begin==covered[path],(number,path,begin,covered[path])
        covered[path]+=len(part)
        fragments+=ns['line_count'](part); size+=len(part)
        records.append([path,kind,start,end,len(part),hashlib.sha256(part).hexdigest()])
    actual=(fragments,size,ns['digest'](records))
    assert actual==(int(expected[1]),int(expected[2]),expected[3]),number
    assert fragments<=1500 and size<=65536
    read_count+=bool(re.search(r'^  Status: '+q+r'done'+q,node,re.M))
    totals.append([int(number),fragments,size,len(records),actual[2]])
    ordered.extend(records)
assert all(covered[p]==len(source[p]) for p in source)
assert len(ordered)==169 and sum(r[1]=='bytes' for r in ordered)==2
assert sum(t[1] for t in totals)==80297 and sum(t[2] for t in totals)==2471305
assert ns['digest'](ordered)=='68844356bf68df29531e689ff80fd06be16059621c678c4c8dbaa0b9adcb398f'
assert ns['report']['inventory']['inventory_sha256']=='34ab5a05c63525c7c7537332e71ce8104c83b5efe2a7413714923a8745d35425'
print(json.dumps({'baseline':ns['BASE'],'paths':len(source),'physical_lines':80296,
    'bytes':2471305,'children':len(nodes),'ranges':len(ordered),'fragments':80297,
    'byte_ranges':2,'empty_paths':sum(not b for b in source.values()),
    'reading_children_done':read_count,'child_summary_sha256':ns['digest'](totals),
    'range_sha256':ns['digest'](ordered)},indent=2))
print('PASS independently reconstructed declared Dart scopes, exact current baseline identity and every child bound/digest')
DART_READING_COVERAGE
```
