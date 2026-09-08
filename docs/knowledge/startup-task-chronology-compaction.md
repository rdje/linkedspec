---
id: startup-task-chronology-compaction
title: Task chronology retains exact Git and per-node evidence within the bounded collection
answers:
  - why did the expression block task point to the string comparison commit
  - where are the 264 consolidated historical task records
  - what owns capacity for the Dart reading decomposition
  - where is the completed startup batch chronology
  - why was the startup task commit table removed
  - how was startup task compaction checked without losing evidence
  - what owns current task collection pressure cleanup
date: 2026-09-08
status: .5 committed with canonical proof; .6 consolidation checked; .7 owns future Dart admission capacity
tags: [continuity, task-tree, history, containment]
evidence: "LIVE-DOCUMENT-PRESSURE-CONTAINMENT.5 checks all 100 batch ordinal/leaf/hash identities against first-parent Git history and all 102 duplicate commit subjects against canonical task nodes; every completion note is retained verbatim beside its node's Commit field. Other task-node fields and stable IDs are identical."
evidence_update_2026_09_08: "Containment .5 lands at d6f37492 with exact canonical proof. From e288c3af, .6 consolidates 264 rows into 260 nodes across four closed trees, retains six unmatched historical captions, preserves every prior node reference and completion note, and removes 251 lines/8210 bytes overall. A proven wrong-node commit pointer is corrected with its prior text retained. The final ordinary documentation slice uses focused proof; the parent remains open for later Dart capacity .7."
reverify:
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
