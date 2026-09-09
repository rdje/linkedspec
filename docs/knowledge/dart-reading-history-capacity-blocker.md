---
id: dart-reading-history-capacity-blocker
title: Continued Dart reading needs one additional immutable change-history member
answers:
  - why does Dart reading await another history capacity exception
  - which exact history limits block the next Dart reading rollover
  - did the Dart reading checkpoint preserve all prior change history
date: 2026-09-09
status: proposed exception; director decision pending under DART-STARTUP-READING.4
tags: [dart, startup, continuity, history, capacity, approval]
evidence: "The .1.7 draft rollover archived exact c2682cf9 CHANGES lines 217-389 as 4982, 173 lines / 26767 bytes with SHA-256 c00b7a2471b553ab83c98d104a731ac521966e5219be58daa289cd012c754aa7. Routing rejected 31/30 files, manifest 30/29 lines and 17039/16463 bytes. Only the uncommitted rollover was undone after source/hash verification; every prior history byte remains identical. A concise 339-byte new record leaves CHANGES at 58814 bytes under unchanged controls."
reverify: "Run HISTORY_CAPACITY_PROPOSAL below; current-root pressure is separately checked by perl tools/roll_document_history.pl --surface change_history --check."
---

# Exact proposed exception

| Control | Current | Proposed |
| --- | ---: | ---: |
| `change_history.limits.max_files` | 30 | 31 |
| Manifest `max_lines` | 29 | 30 |
| Manifest `max_bytes` | 16,463 | 17,039 |

This grants exactly one immutable member and its measured manifest record.
Root 512-line / 65,536-byte, segment 4,096-line / 524,288-byte and aggregate
55,000-line / 4,194,304-byte ceilings stay unchanged. Owners, routes, lifecycle,
verifier and every prior immutable byte remain unchanged. There is no allowance
for another member beyond this proposal.

ADR 0106 admits the current limits. ADR 0109 explicitly states:
“No further capacity increase, cleanup/purge or parked feature activation is
authorized here.” Its approved task/Knowledge exception therefore does not
authorize this additional history capacity. `DART-STARTUP-READING.4` owns the
director decision; after approval, a clean-tree implementation leaf under
`LIVE-DOCUMENT-PRESSURE-CONTAINMENT` must own an indexed exact-limit ADR,
registry changes and canonical proof. This proposal itself changes no limit.

The governed rollover was attempted as required by COMMIT.md. Exact source
copying succeeded, then the resulting-tree routing check rejected the three
axes above. A concise current record lets verified .1.7 work land within the
existing controls; full findings remain in its task/fact/book records.
Restoration touched only the uncommitted manifest and newly generated segment,
after proving its bytes equal the pinned clean-source suffix. Earlier history
was neither shortened nor rewritten. The final hot root has only 168 bytes of
room below the largest integer size under the 90% rollover threshold.

The proposed metadata is pinned to the measured clean source. Implementation
must remeasure its actual candidate before applying the accepted limits.

```bash
bash tools/project_data_run.sh python3 - <<'HISTORY_CAPACITY_PROPOSAL'
from pathlib import Path
import hashlib,json,subprocess
base='c2682cf90b1be39f65dff15bf0d54acf91076753'
def git(*args): return subprocess.check_output(['git',*args])
source=git('show',base+':CHANGES.md')
old=git('show',base+':docs/history/changes/manifest.jsonl')
rows=[json.loads(line) for line in old.splitlines()]
part=b''.join(source.splitlines(keepends=True)[216:389])
digest=hashlib.sha256(part).hexdigest()
assert len(part)==26767 and len(part.splitlines())==173
assert digest=='c00b7a2471b553ab83c98d104a731ac521966e5219be58daa289cd012c754aa7'
row={'byte_count':len(part),'current_path':'CHANGES.md','immutable':True,
 'line_count':173,'retrieval_command':'perl tools/read_document_history.pl --surface change_history --segment 4982',
 'segment_id':'4982','sha256':digest,'source_blob':git('rev-parse',base+':CHANGES.md').decode().strip(),
 'source_commit':base,'source_end_line':389,'source_path':'CHANGES.md','source_start_line':217,
 'surface':'change_history','target_path':'docs/history/changes/segment-4982-'+digest[:12]+'.md','type':'segment'}
rows[0]['segment_count']+=1
rows.insert(1,row)
proposed=('\n'.join(json.dumps(r,sort_keys=True,separators=(',',':')) for r in rows)+'\n').encode()
assert len(proposed)==17039 and len(rows)==30 and rows[0]['segment_count']==29
print(json.dumps({'files':31,'manifest_lines':len(rows),'manifest_bytes':len(proposed),
 'segment_bytes':len(part),'segment_sha256':digest,'prior_records_preserved':rows[2:]==[json.loads(x) for x in old.splitlines()[1:]]}))
HISTORY_CAPACITY_PROPOSAL
```
