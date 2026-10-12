"""Replay the unchanged first408-input publisher from complete supplied candidate bytes."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-'
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
target = ROOT / (PREFIX + 'replay.json')
original_claim = (ROOT / (PREFIX + 'original-claim.json')).read_bytes()
capsule_raw = (ROOT / (PREFIX + 'original-inputs.json.gz')).read_bytes()
capsule = json.loads(gzip.decompress(capsule_raw))
assert len(capsule) == 408 and len(original_claim) == 94719
claim = json.loads(original_claim)
assert {item['path']: item['sha256'] for item in claim['claims'][0]['durability']['inputs']} == {p: item['sha256'] for p, item in capsule.items()}
assert all(sha(decode(item['bytes_base64'])) == item['sha256'] for item in capsule.values())
knowledge = json.loads(gzip.decompress(decode(capsule[OLD + 'knowledge-inputs.json.gz']['bytes_base64'])))
supplied_files = dict(capsule)
for path, item in knowledge['current'].items():
    if path in supplied_files:
        assert supplied_files[path] == item, 'exact overlapping supplied input bytes/modes'
    supplied_files[path] = item
claim_path = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.0.json'
supplied_files[claim_path] = {'bytes_base64': base64.b64encode(original_claim).decode(),
                            'sha256': sha(original_claim), 'mode': 0o644}
command = ['python3', OLD + 'publish-claim.py']
if sys.argv[1:]:
    assert not target.exists(), 'one-shot supplied first-candidate replay'
    rows = []
    for name in ['unchanged-first-publication', 'forged-whole-claim', 'missing-actual-fixture', 'restored-first-publication']:
        files = {p: decode(item['bytes_base64']) for p, item in supplied_files.items()}
        modes = {p: item['mode'] for p, item in supplied_files.items()}
        if name == 'forged-whole-claim':
            changed = json.loads(original_claim)
            changed['claims'][0]['statement'] += ' forged'
            files[claim_path] = (json.dumps(changed, indent=2) + '\n').encode()
        elif name == 'missing-actual-fixture':
            del files['t/actionir_flow_required_capture.t']
        with tempfile.TemporaryDirectory(prefix='flow-first-candidate-', dir=os.environ['TMPDIR']) as directory:
            supplied = Path(directory)
            assert supplied.stat().st_dev == ROOT.stat().st_dev
            for path, raw in files.items():
                destination = supplied / path
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_bytes(raw)
                destination.chmod(modes[path])
            environment = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(supplied), PYTHONDONTWRITEBYTECODE='1')
            process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
            actual = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()}
            actual_modes = {p: (supplied / p).stat().st_mode & 0o7777 for p in actual}
        row = {'name': name, 'returncode': process.returncode,
               'stdout_base64': base64.b64encode(process.stdout).decode(),
               'stderr_base64': base64.b64encode(process.stderr).decode(),
               'unchanged': actual == {p: sha(raw) for p, raw in files.items()} and actual_modes == {p: modes[p] for p in files}}
        rows.append(row)
        assert row['unchanged'], 'unchanged readonly supplied input bytes/modes'
        if name in ('unchanged-first-publication', 'restored-first-publication'):
            assert process.returncode == 0 and not process.stderr
            assert process.stdout == b'Required FlowExpr publication PASS: 408 live inputs; 94719 bytes\n'
        elif name == 'forged-whole-claim':
            assert process.returncode != 0 and b'exact current readonly publication' in process.stderr
        else:
            assert process.returncode != 0 and b'actionir_flow_required_capture.t' in process.stderr and b'No such file or directory' in process.stderr
    assert rows[0] == dict(rows[-1], name='unchanged-first-publication'), 'exact restored first-publisher result'
    inputs = {PREFIX + tail: sha((ROOT / (PREFIX + tail)).read_bytes()) for tail in ['original-claim.json', 'original-inputs.json.gz', 'preserve.py', 'preservation.json', 'replay.py']}
    report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()), 'command': command,
              'original_bindings': 408, 'original_claim_bytes': 94719, 'supplied_inputs': len(supplied_files),
              'inputs': inputs, 'rows': rows,
              'scope': 'Unchanged complete first publisher/reader/evidence/validation/book-reader and every408 declared byte/mode, plus the complete1485 current Knowledge population recovered from its original nested capsule, are supplied in project-volume plain roots. The owning repository Git objects/index are reused only by read-only Git commands through runtime-derived GIT_DIR/GIT_WORK_TREE; no .git is created and no accepted revision is invented for the uncommitted candidate. Two actual semantic corruptions reject and exact restoration passes. No first native observation, fixture, runtime or original producer is refreshed. Readonly default validates retained replay and current artifact identities.'}
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    report = json.loads(target.read_bytes())
assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
assert report['command'] == command and report['supplied_inputs'] == len(supplied_files)
assert all(sha((ROOT / p).read_bytes()) == h for p, h in report['inputs'].items())
assert [row['name'] for row in report['rows']] == ['unchanged-first-publication', 'forged-whole-claim', 'missing-actual-fixture', 'restored-first-publication']
assert all(row['unchanged'] for row in report['rows'])
assert [row['returncode'] == 0 for row in report['rows']] == [True, False, False, True]
assert report['rows'][0] == dict(report['rows'][-1], name='unchanged-first-publication')
assert b'exact current readonly publication' in decode(report['rows'][1]['stderr_base64'])
assert b'actionir_flow_required_capture.t' in decode(report['rows'][2]['stderr_base64'])
print('First FlowExpr supplied replay PASS:408 complete bindings/full94719;', len(supplied_files), 'supplied inputs;two actual corruption controls;exact restoration')
