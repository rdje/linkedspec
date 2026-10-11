"""Retain fixed claim namespaces and replay the accepted maintenance publication."""
import base64
import copy
import gzip
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10-'
BASE = '16c70eaab688a877053b1addde8f07bc548e1cbf'
ACCEPTED = 'fc96936fb64d27e692e66377b2e332641c2674fd'
ORIGIN = '61cca1cccff6027461e120e4236431d1bc7d20b1'
CLAIM = 'docs/claims/REPO-HYGIENE.16.json'
OLD_KIND = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2.json'
ARCHIVE = ROOT / (PREFIX + 'namespaces.json')
TARGET = ROOT / (PREFIX + 'hygiene-recovery.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
b64 = lambda raw: base64.b64encode(raw).decode()
old = lambda rev, p: subprocess.check_output(['git', 'show', rev + ':' + p], cwd=ROOT)
assert sys.argv[1:] in ([], ['--capture'])
snapshots = {}
for revision in (ORIGIN, ACCEPTED, BASE):
    paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', revision, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
    snapshots[revision] = {p: b64(old(revision, p)) for p in sorted(paths)}
packed_raw = (json.dumps(snapshots, sort_keys=True) + '\n').encode()
envelope = {'producer_sha256': sha(Path(__file__).read_bytes()), 'encoding': 'gzip-base64',
            'bytes': len(packed_raw), 'sha256': sha(packed_raw), 'data': b64(gzip.compress(packed_raw, mtime=0))}
if sys.argv[1:]:
    assert not ARCHIVE.exists() and not TARGET.exists()
    ARCHIVE.write_text(json.dumps(envelope, indent=2) + '\n')
else:
    assert json.loads(ARCHIVE.read_bytes()) == envelope, 'complete fixed-Git claim namespaces'
raw_claim = old(BASE, CLAIM)
entries = json.loads(raw_claim)['claims'][0]['durability']['inputs']
assert len(entries) == 24 and len(raw_claim) == 9306
files = {entry['path']: old(BASE, entry['path']) for entry in entries}
assert all(sha(files[entry['path']]) == entry['sha256'] for entry in entries)
files[CLAIM] = raw_claim
changed = json.loads(files[OLD_KIND])
changed['claims'][0]['durability'].update(mode='historical', revision=BASE)
changed_raw = (json.dumps(changed, indent=2) + '\n').encode()
assert (ROOT / OLD_KIND).read_bytes() == changed_raw
mode_lines = subprocess.check_output(['git', 'ls-tree', '-r', BASE], cwd=ROOT, text=True).splitlines()
all_modes = {line.split('\t')[1]: int(line.split()[0], 8) & 0o777 for line in mode_lines if line.split()[0] != '160000'}
rows = []
for name in ('accepted', 'changed-bound-claim', 'restored'):
    selected = dict(files)
    if name == 'changed-bound-claim':
        selected[OLD_KIND] = changed_raw
    inputs = {p: sha(raw) for p, raw in selected.items()}
    modes = {p: all_modes[p] for p in selected}
    command = ['python3', 'docs/checkpoints/REPO-HYGIENE.16-claim.py']
    if sys.argv[1:]:
        with tempfile.TemporaryDirectory(prefix='accepted-hygiene-', dir=os.environ['TMPDIR']) as directory:
            supplied = Path(directory)
            assert supplied.stat().st_dev == ROOT.stat().st_dev
            for path, raw in selected.items():
                target = supplied / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(raw)
                target.chmod(modes[path])
            result = subprocess.run(command, cwd=supplied, capture_output=True)
            unchanged = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()} == inputs
        rows.append({'name': name, 'command': command, 'inputs': inputs, 'modes': modes, 'unchanged': unchanged,
                     'returncode': result.returncode, 'stdout_base64': b64(result.stdout), 'stderr_base64': b64(result.stderr)})
        (ROOT / (PREFIX + 'hygiene-recovery-reached.json')).write_text(json.dumps({'rows': rows}, indent=2) + '\n')
    else:
        row = json.loads(TARGET.read_bytes())['rows'][len(rows)]
        assert row['name'] == name and row['command'] == command and row['inputs'] == inputs and row['modes'] == modes
        rows.append(row)
    row = rows[-1]
    assert row['unchanged']
    out, err = (base64.b64decode(row[key], validate=True) for key in ('stdout_base64', 'stderr_base64'))
    if name == 'changed-bound-claim':
        assert row['returncode'] != 0 and b'assert all(hashlib.sha256' in err, 'actual original maintenance binding RED'
    else:
        assert row['returncode'] == 0 and not err and b'24 inputs; 9306 bytes' in out, 'accepted maintenance publication PASS'
assert rows[0]['stdout_base64'] == rows[2]['stdout_base64']
report = {'producer_sha256': sha(Path(__file__).read_bytes()), 'rows': rows, 'namespace_counts': {revision: len(data) for revision, data in snapshots.items()},
          'scope': 'Complete exact fixed-Git claim file populations retained as compressed raw bytes, independently compared with each original Git boundary. Actual unchanged25-input maintenance publication PASS, bound predecessor mode-change RED and exact restoration PASS. Original24-input9306-byte claim and every input remain unchanged in accepted cases. No old snapshot/producer refreshed and no current runtime admission inferred.'}
if sys.argv[1:]:
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(TARGET.read_bytes()) == report
assert json.loads((ROOT / (PREFIX + 'hygiene-recovery-reached.json')).read_bytes()) == {'rows': rows}
print('Fixed claim namespaces and accepted25-input maintenance recovery/RED/restoration PASS')
