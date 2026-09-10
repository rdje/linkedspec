---
id: dart-reading-second-history-capacity-blocker
title: Dart reading needs one additional change-history member after the callable test checkpoint
answers:
  - "which history allowance blocks Dart reading after slice 36"
  - "what exact additional change-history limits are proposed after ADR0110"
  - "why can Dart reading not commit another slice after 1.36"
  - "did Dart slice 36 preserve the rejected rollover history"
date: 2026-09-10
status: awaiting director decision; no additional allowance implemented
tags: [dart, startup, continuity, history, capacity, approval]
evidence: DART-STARTUP-READING.1.36 and .6; actual governed rollover and routing rejection; clean 6cb42d87 CHANGES247-457; exact restored history; ADR0110
reverify: "Run the pinned proposal block below, perl tools/roll_document_history.pl --surface change_history --check, and bash scripts/check_readme_stability.sh. The historical routing rejection is bound in the .1.36 commit receipt; no current limit changes are authorized."
---

The normal .1.36 record reached 464 lines / 47,015 bytes. The governed
`tools/roll_document_history.pl` requires rollover at 90% of the 512-line or
65,536-byte root ceiling. The exact clean-source suffix selected by `--apply`
was `CHANGES.md` lines 247-457 at
`6cb42d876d605830bdb429236e08d553a541fd9d`: 211 lines / 31,668 bytes,
SHA-256 `55830675f67c5814a5457a3c2adabc054d918b62582312c52d791fe268b78ef4`.

The resulting draft has a 253-line / 15,347-byte root and one additional
immutable segment `4981`. Actual routing validation rejects exactly:

| Control | Existing | Measured proposal |
| --- | ---: | ---: |
| change_history maximum files | 31 | 32 |
| manifest maximum lines | 30 | 31 |
| manifest maximum bytes | 17,039 | 17,615 |

The draft collection is 48,767 lines / 3,543,340 bytes, within its existing
55,000-line / 4,194,304-byte ceilings. The segment fits 4,096 lines / 524,288
bytes; root ceilings, routes, ownership, history schema and all other controls
remain unchanged. This proposal admits exactly one member, with no future
member reserved.

ADR `0110` says: “Every further increase requires new authority.”
Its prior greenlight covers the thirty-first member only. The approved
engineering-notes exception in ADR `0111` is a different collection.
`DART-STARTUP-READING.6` owns this director decision. Stable infrastructure
responsibility remains `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3`; after approval,
a separate task-tree-owned canonical implementation must remeasure the actual
source and preserve every prior byte before changing the three approved limits.

The draft segment was verified against its clean Git source and copied to
repository-local scratch. The manifest and hot root were restored from exact
pre-rollover bytes; only the proven new, untracked draft segment was removed.
All prior immutable files and manifest records are unchanged. A complete concise
three-line .1.36 record preserves the finished work and leaves the root at
460 lines / 47,004 bytes, below the unchanged 90% boundary. Its heading and
paragraph remain separate CommonMark blocks. Another new record reaches at
least 461 lines and therefore requires rollover; .1.37 awaits the capacity decision.

All 38 selected callable/compiled/action/variadic tests and neutral callable
7/11/9/7/4/8/23 checks pass, including standalone offline emitted execution.
Physical reading is 36/55; no reading credit or repair completion follows from
a capacity increase. Source repairs, recovery/purge and parked authoring/format
work retain their existing prerequisites.

The pinned proposal is read-only and reproducible from the repository root:

```bash
bash tools/project_data_run.sh python3 - <<'DART136_HISTORY_PROPOSAL'
from pathlib import Path
import hashlib,json,re,subprocess
base='6cb42d876d605830bdb429236e08d553a541fd9d'
def git(*args):return subprocess.check_output(['git',*args])
source=git('show',base+':CHANGES.md')
old=git('show',base+':docs/history/changes/manifest.jsonl')
part=b''.join(source.splitlines(keepends=True)[246:457])
digest=hashlib.sha256(part).hexdigest()
assert len(part)==31668 and len(part.splitlines())==211
assert digest=='55830675f67c5814a5457a3c2adabc054d918b62582312c52d791fe268b78ef4'
rows=[json.loads(v) for v in old.splitlines()]
record={'byte_count':len(part),'current_path':'CHANGES.md','immutable':True,
 'line_count':211,'retrieval_command':'perl tools/read_document_history.pl --surface change_history --segment 4981',
 'segment_id':'4981','sha256':digest,'source_blob':git('rev-parse',base+':CHANGES.md').decode().strip(),
 'source_commit':base,'source_end_line':457,'source_path':'CHANGES.md','source_start_line':247,
 'surface':'change_history','target_path':'docs/history/changes/segment-4981-'+digest[:12]+'.md','type':'segment'}
assert record['source_blob']=='b926af22b5519973657dde5e155894fd1f5f1093'
rows[0]['segment_count']+=1;rows.insert(1,record)
proposed=('\n'.join(json.dumps(v,sort_keys=True,separators=(',',':')) for v in rows)+'\n').encode()
assert len(rows)==31 and len(proposed)==17615
assert rows[2:]==[json.loads(v) for v in old.splitlines()[1:]]
routes=[json.loads(v) for v in Path('doctrine/readme_stability/routes.jsonl').read_text().splitlines()]
route=next(v for v in routes if v.get('id')=='change_history')
assert route['limits']['max_files']==31
assert route['member_limits']['docs/history/changes/manifest.jsonl']=={'max_lines':30,'max_bytes':17039}
print(json.dumps({'base':base,'source_blob':record['source_blob'],'source_lines':[247,457],
 'segment_lines':211,'segment_bytes':len(part),'segment_sha256':digest,
 'proposed_files':32,'proposed_manifest_lines':len(rows),'proposed_manifest_bytes':len(proposed)},indent=2))
print('PASS pinned proposal, exact clean-source suffix and prior manifest records; current allowances remain unchanged')
DART136_HISTORY_PROPOSAL
```

Related: [[dart-reading-history-capacity-blocker]],
[[dart-reading-engineering-history-capacity-blocker]],
[[startup-task-chronology-compaction]], ADR `0110` and ADR `0111`.
