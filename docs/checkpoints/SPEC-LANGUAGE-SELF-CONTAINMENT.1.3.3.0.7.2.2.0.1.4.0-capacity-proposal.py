"""Read-only exact finite engineering-note rollover proposal; no policy mutation."""
from pathlib import Path
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-'
revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip()
raw = subprocess.check_output(['git', 'show', revision+':DEVELOPMENT_NOTES.md'], cwd=ROOT)
starts = [m.start() for m in re.finditer(rb'^## ', raw, re.M)]
preamble = raw[:starts[0]]
records = [raw[a:b] for a, b in zip(starts, starts[1:]+[len(raw)])]
note = ('## 2026-10-05 — Original Legacy producer partition (.1.4.0)\n\n'
        'Original Legacy dispatch has112 internal contracts in six safe families: call/return/push8, '
        'anonymous capture26, named capture17, mark control14, cursor/input15 and entry/match32. '
        'Literal cumulative Unicode/CRLF fixtures distinguish repeated occurrences; only return_general '
        'has existing private origins. Public/internal contract IDs are not helper admission. '
        'Quoted boundary comma tokenization is separately owned before that producer family; preserve '
        'original scanner and lowering channels. See docs/knowledge/perl-legacy-source-producer-partition.md.\n\n').encode()
keep = len(records)
while keep > 0 and (len(preamble+note+b''.join(records[:keep])) > 32768 or
                   (preamble+note+b''.join(records[:keep])).count(b'\n') > 256):
    keep -= 1
assert keep > 0
archive = b''.join(records[keep:])
retained = preamble+note+b''.join(records[:keep])
assert raw.endswith(archive)
manifest_path = 'docs/history/development-notes/manifest.jsonl'
original_manifest = subprocess.check_output(['git', 'show', revision+':'+manifest_path], cwd=ROOT)
manifest = [json.loads(line) for line in original_manifest.splitlines()]
segment_id = f"{int(manifest[1]['segment_id'])-1:04d}"
digest = hashlib.sha256(archive).hexdigest()
target = 'docs/history/development-notes/segment-'+segment_id+'-'+digest[:12]+'.md'
prefix = raw[:-len(archive)]
record = {'byte_count': len(archive), 'current_path': 'DEVELOPMENT_NOTES.md', 'immutable': True,
          'line_count': archive.count(b'\n'),
          'retrieval_command': 'perl tools/read_document_history.pl --surface engineering_notes --segment '+segment_id,
          'segment_id': segment_id, 'sha256': digest,
          'source_blob': subprocess.check_output(['git', 'rev-parse', revision+':DEVELOPMENT_NOTES.md'], cwd=ROOT).decode().strip(),
          'source_commit': revision, 'source_end_line': raw.count(b'\n'),
          'source_path': 'DEVELOPMENT_NOTES.md', 'source_start_line': prefix.count(b'\n')+1,
          'surface': 'engineering_notes', 'target_path': target, 'type': 'segment'}
manifest[0]['segment_count'] += 1
proposed_manifest = b''.join((json.dumps(row, sort_keys=True, separators=(',', ':'))+'\n').encode()
                             for row in [manifest[0], record]+manifest[1:])
old = next(json.loads(line) for line in subprocess.check_output(['git', 'show', revision+':doctrine/readme_stability/routes.jsonl'], cwd=ROOT).splitlines()
           if json.loads(line).get('id') == 'engineering_notes')
new_limits = dict(old['limits'], max_files=old['limits']['max_files']+1)
new_members = json.loads(json.dumps(old['member_limits']))
new_members[manifest_path] = {'max_bytes': len(proposed_manifest), 'max_lines': 43}
result = {'revision': revision, 'status': 'proposal only; director approval and separate canonical infrastructure admission required',
          'old_limits': old['limits'], 'new_limits': new_limits,
          'old_member_limits': old['member_limits'], 'new_member_limits': new_members,
          'original_root_bytes': len(raw), 'original_root_lines': raw.count(b'\n'),
          'current_manifest_bytes': len(original_manifest), 'current_manifest_lines': len(manifest),
          'proposed_manifest_bytes': len(proposed_manifest), 'proposed_manifest_lines': len(manifest)+1,
          'retained_root_bytes': len(retained), 'retained_root_lines': retained.count(b'\n'),
          'archive_record': record, 'new_note_bytes': len(note), 'archive_sha256': digest,
          'scope': 'Exactly one additional archive member and one manifest row; three scalar transitions only. Hot-root budgets/90% rollover/50% retain, other fields/collections and all immutable history bytes stay exact. No reserve for unlimited PNT. Final source commit/manifest binding must be rederived at clean infrastructure activation.'}
(ROOT/(PREFIX+'capacity-proposal.json')).write_text(json.dumps(result, indent=2)+'\n')
(ROOT/(PREFIX+'proposed-note.md')).write_bytes(note[:-1])
print(json.dumps(result))
