"""Compact only this uncommitted live note; preserve the rejected rollover exactly."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '770cffcccea44df8d0e578ed68ad6f9a4b5e0b0e'
NOTES = 'DEVELOPMENT_NOTES.md'
MANIFEST = 'docs/history/development-notes/manifest.jsonl'
SEGMENT = 'docs/history/development-notes/segment-4961-793ac42b8044.md'
TARGET = Path(__file__).with_name('notes-compaction.json')
assert sys.argv[1:] in ([], ['--apply'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()
blob = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
entry = '''
## 2026-10-11 — Caller-local hash kind selection preserves native match-slot behavior

Select the actual injected CODE once before trim, default missing/non-CODE to unknown,
and isolate its private emission capture. Map replacement cannot change that invocation.
Required hash resolver returns stay with .3.1.6.3; no public syntax or parent admission.

Native match aliases have readonly flag0 yet reject writes. The independent Perl5.34.1
slot/write oracle distinguishes lexical/literal/match/copied-match behavior; the argument-copy
fault has nine REDs. See docs/knowledge/perl-match-alias-writability.md for exact scope.

Complete487 TAP retains48 original REDs/439 controls/all487 GREEN. Five source faults,
supplied61/187, evidence6/original546 and book89/3 pass; supplemental public Phase0 passes1035.
Draft408/path-prefix and first-positive diagnostic-wrapper refusals remain exact; separate
corrections replay byte-identically. See docs/knowledge/perl-legacy-hash-kind-callback.md
and the owning task record for complete retained instruments, channels and claim limits.
'''
original = blob(NOTES)
position = original.index(b'\n## ')
expected = original[:position] + entry.encode() + original[position:]
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot compaction already retained'
    inputs = {path: (ROOT / path).read_bytes() for path in (NOTES, MANIFEST, SEGMENT)}
    manifest = json.loads(inputs[MANIFEST].splitlines()[1])
    assert manifest['target_path'] == SEGMENT and manifest['source_commit'] == BASE
    lines = original.splitlines(keepends=True)
    assert inputs[SEGMENT] == b''.join(lines[manifest['source_start_line']-1:manifest['source_end_line']])
    assert digest(inputs[SEGMENT]) == manifest['sha256']
    report = {'base': BASE, 'producer_sha256': digest(Path(__file__).read_bytes()),
              'rejected_inputs': {p: {'sha256': digest(raw), 'bytes_base64': base64.b64encode(raw).decode()}
                                  for p, raw in inputs.items()},
              'notes_after_sha256': digest(expected), 'manifest_after_sha256': digest(blob(MANIFEST)),
              'boundary': 'Normal hooks reported engineering_notes files47/46, manifest lines46/45 and bytes27857/27245. This is a transcription of tool output, not separately retained raw channels. Stop the obsolete hook group after that denial; actual outer commit exit1, HEAD unchanged. No successful commit inferred.',
              'scope': 'Only this new live note is compacted. Complete rejected rollover inputs remain recoverable here; original accepted history and manifest bytes stay exact. No routing limit object changes. The separate runtime322-input publication does not measure this documentation transaction.'}
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
    (ROOT / NOTES).write_bytes(expected)
    (ROOT / MANIFEST).write_bytes(blob(MANIFEST))
    (ROOT / SEGMENT).unlink()
else:
    report = json.loads(TARGET.read_bytes())
    assert report['producer_sha256'] == digest(Path(__file__).read_bytes())
    for row in report['rejected_inputs'].values():
        assert digest(base64.b64decode(row['bytes_base64'], validate=True)) == row['sha256']
assert (ROOT / NOTES).read_bytes() == expected
assert (ROOT / MANIFEST).read_bytes() == blob(MANIFEST)
assert not (ROOT / SEGMENT).exists()
assert digest(expected) == report['notes_after_sha256']
print('Notes compaction PASS: original accepted history exact; rejected rollover retained; existing limits unchanged')
