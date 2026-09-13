---
id: bounded-change-notes-history-contract
title: Changes and engineering notes use bounded hot shards with complete-record rollover
answers:
  - does document history --all include the current hot shard
  - how do I verify exact history preservation across rollover
  - where is old CHANGES.md history
  - where are old development notes
  - how do I search archived changes
  - how do I search archived engineering notes
  - how do I check change history rollover pressure
  - when must CHANGES.md roll over
  - when must DEVELOPMENT_NOTES.md roll over
  - what boundaries may document history rollover use
  - why do changes and notes archive ids start at 5000
  - why are trailing spaces allowed in document history segments
  - what clean commit owns the initial changes and notes archives
date: 2026-08-10
status: accepted and implemented under LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 at 921f0507
tags: [documentation, history, retrieval, rollover, changes, engineering-notes, continuity]
evidence: "Clean 61a52dbd owns CHANGES.md at 44,270 lines / 3,104,131 bytes (blob 2e951cab..., SHA-256 c8ba1b7...) and DEVELOPMENT_NOTES.md at 21,308 lines / 2,291,424 bytes (blob 0522cdf5..., SHA-256 ca9ad5c3...). Eleven change segments and six note segments reconstruct those sources exactly. The stable roots are 512 lines / 65,536 bytes maximum; tools/roll_document_history.pl warns at 80%, requires action at 90%, and retains <=50%. It archives only complete clean-HEAD suffix records: ^## for changes and dated entries or ^## for notes. Initial IDs 5000 upward reserve lower IDs for newer rollovers without renaming immutable targets. Publication is segment, manifest, root; rerun recovers exact orphan/pending generations. Exact legacy note whitespace is exempt only in docs/history/**/segment-*.md."
evidence_update_2026_08_14: "INTER-MATCH-GAP-CAPTURE.3.2 triggers the required engineering-notes rollover at 472/512 lines. It publishes content-addressed segment 4996 from clean activation commit 95127e1d, leaving the final root at 250/512 lines and the exact collection at 12 files, 22,441 lines, and 2,410,497 bytes. ADR 0071 reviews only max_files 11->12 and manifest max_lines 10->11; all byte, root, per-history-file, aggregate, owner, lifecycle, verifier, and storage controls remain unchanged."
evidence_update_2026_08_15: "INTER-MATCH-GAP-CAPTURE.4.5 triggers the required engineering-notes rollover at 477/512 lines. It publishes content-addressed segment 4995 from clean activation commit 6a554312, leaving the signoff-complete root at 238/512 lines and the collection at 13 files, 22,672 lines, and 2,433,456 bytes. The canonical doctrine precursor rejects the prior finite 12-file/11-manifest-row cap exactly. ADR 0075 reviews only max_files 12->13 and manifest max_lines 11->12; all byte, root, per-history-file, aggregate, owner, lifecycle, verifier, and storage controls remain unchanged."
evidence_update_2026_08_15_change_history: "INTER-MATCH-GAP-CAPTURE.5.1 triggers the required change-history rollover at 468/512 lines. It publishes content-addressed segment 4995 from clean activation commit 12a14ed0, leaving the signoff-complete root at 237/512 lines and the collection at 18 files, 45,656 lines, and 3,240,997 bytes. The doctrine gate rejects the prior finite 17-file/16-manifest-row cap exactly. ADR 0076 reviews only max_files 17->18 and manifest max_lines 16->17; all byte, root, per-history-file, aggregate, owner, lifecycle, verifier, and storage controls remain unchanged."
evidence_update_2026_08_16: "INTER-MATCH-GAP-CAPTURE.6.3 triggers the required engineering-notes rollover at 462/512 lines. It publishes content-addressed segment 4994 from clean activation commit 4e625a9f, leaving the final root at 237/512 lines and the collection at 14 files, 22,898 lines, and 2,456,251 bytes. The doctrine gate rejects the prior finite 13-file/12-manifest-row cap exactly. ADR 0077 reviews only max_files 13->14 and manifest max_lines 12->13; all byte, root, per-history-file, aggregate, owner, lifecycle, verifier, and storage controls remain unchanged."
evidence_update_2026_08_17_change_history: "FUTURE-PARITY-BACKLOG.14.6.2.3 triggers the required change-history rollover at 477/512 lines. It publishes content-addressed segment 4993, leaving the final root at 238/512 lines and the collection at 20 files, 46,130 lines, and 3,286,198 bytes. The doctrine gate rejects the prior finite 19-file/18-manifest-row cap exactly. ADR 0082 reviews only max_files 19->20 and manifest max_lines 18->19; all byte, root, per-history-file, aggregate, owner, lifecycle, verifier, and storage controls remain unchanged."
evidence_update_2026_08_24_change_history: "FUTURE-PARITY-BACKLOG.14.6.5.2 triggers the required change-history rollover at 472/512 lines. It publishes content-addressed segment 4992 from clean activation bb34a85e and leaves the final hot root at 252/512 lines. The collection is 21 files / 46,371 lines / 3,308,828 bytes with a 20-line manifest. The doctrine gate rejects the prior finite 20-file/19-manifest-line cap exactly; ADR 0086 reviews only max_files 20->21 and manifest max_lines 19->20, retaining every other control."
evidence_update_2026_08_25_engineering_notes: "FUTURE-PARITY-BACKLOG.14.6.7 triggers the required engineering-notes rollover at 464/512 lines. It publishes content-addressed segment 4991, leaves the hot root at 250/512 lines, and produces 17 files / 23,604 lines / 2,528,467 bytes with a 16-line manifest. ADR 0087 reviews only max_files 16->17 and manifest max_lines 15->16, retaining every other control."
last_verified: 2026-08-25
reverify:
  - "bash scripts/check_document_history.sh"
  - "perl tools/roll_document_history.pl --self-test"
  - "perl tools/roll_document_history.pl --surface change_history --check"
  - "perl tools/roll_document_history.pl --surface engineering_notes --check"
  - "perl tools/read_document_history.pl --surface change_history --grep 'README-STABILITY-POLICY.4.2'"
  - "perl tools/read_document_history.pl --surface engineering_notes --grep 'README-STABILITY-POLICY.4.2'"
  - "sed -n '1,260p' docs/decisions/0069-bounded-change-and-notes-history.md"
---

# Bounded author history is a checked workflow

`CHANGES.md` and `DEVELOPMENT_NOTES.md` remain the stable current author/reader paths, but older records live in
strict repository-local manifests and immutable content-addressed segments. Use the literal query first, a bounded
segment when raw context is needed, and `--all` only for complete reconstruction.

Authors prepend complete records and run both pressure checks before staging. At either 90% limit,
`--apply` may move only the oldest complete records that are already an exact suffix of the clean HEAD root; it
refuses to archive new uncommitted entries or rewritten/reordered committed records. The retained root must be at
or below both 256 lines and 32,768 bytes.

Publication is recoverable rather than relying on an impossible cross-file rename: segment first, manifest
second, root last. A rerun reuses an exact content-addressed orphan or completes an exact pending manifest
generation; conflicting bytes or metadata fail closed.

Initial legacy history uses IDs `5000` upward. Future generations consume lower IDs (`4999`, `4998`, ...), which
keeps manifest order ascending and newest-to-oldest without renaming immutable targets. The route file-count caps
require reviewed evolution long before the numeric reserve is exhausted.


## Archive-only query and September 13 rollover verification

`tools/read_document_history.pl --all` concatenates the immutable manifest
segments only; it does not include the current hot root. The reader removes
manifest metadata before iterating the segment records at lines30–35. Comparing
archive-only output before and after rollover must therefore differ by the new
segment. Compare `hot_root_bytes + archived_bytes` across that same candidate
instead. Manifest metadata advances its segment count; older segment record bytes
and target bytes remain unchanged. This clarifies query scope, not a product defect.

`CONFORMANCE-SOURCE-READING.1.4` initially made that archive-only comparison,
then verified the actual reader and exact combined reconstruction:3,613,557 bytes,
SHA-256 `9c8ea4a6eee5f1e5b5a23383a5ee1103a2236cd2a9b40dfdad610f6a0b0a5e98`.
The required463-line candidate became247 lines/32,290 bytes by archiving precisely
216 clean-HEAD lines/18,973 bytes. Its new segment is4976-6d1dd54d605a; all34 older
records remain exact. The resulting37-file collection and36-line/20,495-byte
manifest fit ADR0118's unchanged limits. No reader or rollover implementation changes.

The immutable source/segment proof remains independently replayable:

```bash
bash tools/project_data_run.sh python3 - <<'CONFORMANCE_CHANGE_HISTORY_ROLLOVER'
from pathlib import Path
import hashlib,json,subprocess
base='baaebc8ef62baf84447767c2b361458c3ac57d9e'
path='docs/history/changes/manifest.jsonl'
old=subprocess.check_output(['git','show',base+':'+path]).splitlines(True)
current=Path(path).read_bytes().splitlines(True)
index=next(i for i,line in enumerate(current) if json.loads(line).get('segment_id')=='4976')
row=json.loads(current[index]);assert current[index+1:]==old[1:]
assert row['source_commit']==base and row['source_start_line']==242 and row['source_end_line']==457
segment=Path(row['target_path']).read_bytes()
source=subprocess.check_output(['git','show',base+':CHANGES.md'])
assert subprocess.check_output(['git','rev-parse',base+':CHANGES.md'],text=True).strip()==row['source_blob']
assert segment==b''.join(source.splitlines(True)[241:457])
assert len(segment)==row['byte_count']==18973 and segment.count(b'\n')==row['line_count']==216
assert hashlib.sha256(segment).hexdigest()==row['sha256']=='6d1dd54d605a5363a60cfc39d7918f91cd6d3934f8df6e3d57c00f14c1d0d026'
assert source.endswith(segment)
print('PASS exact clean source suffix, immutable segment identity and all34 older manifest records.')
CONFORMANCE_CHANGE_HISTORY_ROLLOVER
```
