"""Preserve the failed candidate; condense only this leaf's new task wording."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PART = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
FRONTIER = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
PLAN = json.loads((BASE / 'plan.json').read_bytes())
PARENT = PLAN['owner'].rsplit('.', 1)[0]
paths = [PART, FRONTIER, Path('MEMORY.md'), BASE / 'repair_pressure.py', BASE / 'review_pressure.py']
identities = {}
with tarfile.open(BASE / 'pressure-before.tar.gz', 'x:gz') as archive:
    for path in paths:
        body = path.read_bytes()
        identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
        archive.add(path, arcname=str(path), recursive=False)
(BASE / 'pressure-before-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + chr(10))
log = Path('.linkedspec-data/perl-literal-open-commit.log').read_bytes()
assert b'aggregate bytes 12584262/12582912' in log and b'routing-pressure doctrine FAILED' in log
with (BASE / 'pressure-failed-normal.log.gz').open('xb') as stream:
    stream.write(gzip.compress(log, mtime=0))
fields = {
    '.0': dict(Goal='Qualify literal open modes/paths over145.',
        Acceptance='Retain145 identities/sites/roles/bytes/modes and unmatched IO. No runtime/output-input/native/semantic admission.',
        **{'Focused checks': 'Reader/Git/specimens/REDs; book/memory/history/scope/hooks.',
           'Canonical trigger': 'Admission/push.', 'Outcome': 'Focused PASS; all limits in claim.'}),
    '.1': dict(Goal='Bind literal variables to IO.', Acceptance='Parent scope;145/support/readback.'),
    '.2': dict(Goal='Reconcile other literal/non-open IO.', Acceptance='Parent scope; support/dynamic/library follow-ups.')}
text = PART.read_text()
for suffix, replacements in fields.items():
    start = text.index('- ID: `' + PARENT + suffix + '`' + chr(10))
    end = text.index(chr(10) + '- ID:', start + 1)
    lines = []
    for line in text[start:end].splitlines():
        if suffix == '.0' and line.startswith(('  Evidence:', '  Book review:')):
            continue
        key = line.strip().split(':', 1)[0]
        lines.append('  ' + key + ': ' + replacements[key] if key in replacements else line)
    text = text[:start] + chr(10).join(lines) + chr(10) + text[end:]
start = text.index('- ID: `' + PARENT + '`' + chr(10))
end = text.index(chr(10) + '- ID:', start + 1)
node = chr(10).join(line for line in text[start:end].splitlines() if not line.startswith('  Children:')) + chr(10)
PART.write_text(text[:start] + node + text[end:])
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(PARENT + '.1') + r'`.*$',
    '| 1 | `' + PARENT + '.1' + '` | `pending` | Capacity, then variable1. |', FRONTIER.read_text())
assert count == 1
FRONTIER.write_text(text)
path = Path('MEMORY.md')
text = path.read_text()
text = re.sub(r'(?m)^- next_action:.*$', '- next_action: After clean landing and size measurement, renew task-text capacity with the existing closed-commentary epoch interface; then resume variable-bound literal1 and other IO/helper/generated/admission prerequisites.', text)
path.write_text(text)
with tarfile.open(BASE / 'pressure-after.tar.gz', 'x:gz') as archive:
    for path in (PART, FRONTIER, Path('MEMORY.md')):
        archive.add(path, arcname=str(path), recursive=False)
(BASE / 'pressure-repair.json').write_text(json.dumps(dict(result='prepared', observed_initial_commit_exit=143,
    stopped='Only the already-failed own commit tree was terminated; no complete hook PASS is claimed.',
    scope='Only new child wording/redundant child-list/frontier summary condensed. Existing parent Goal/Acceptance, all IDs/status and tier/claim bindings retained; full original detail survives.',
    next='A clean new existing-tool task-text epoch is required before further inventory growth. Limits/tools/policies unchanged.'), indent=2) + chr(10))
print('Preserved failed candidate and prepared bounded task-text repair')
