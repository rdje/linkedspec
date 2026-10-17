"""Retain missing delegated script/config inputs and replay the unchanged old-cap observation."""
import base64
import gzip
import hashlib
import json
import os
import stat
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '736c6a43efab526fe898ed5c72b061479955fc5c'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/'
TARGET = ROOT / (PREFIX + 'complete-inputs.json')
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
encode = lambda value: base64.b64encode(value).decode()
assert not TARGET.exists(), 'one-shot support/replay'
first_raw = (ROOT / (PREFIX + 'measurement.json')).read_bytes()
first = json.loads(first_raw)
assert first['result'] == 'PASS' and first['base'] == BASE
rolled_raw = (ROOT / (PREFIX + 'rolled-inputs.json.gz')).read_bytes()
assert sha(rolled_raw) == first['captures']['rolled']['sha256']
rolled = json.loads(gzip.decompress(rolled_raw))
entries = subprocess.check_output(['git', 'ls-tree', '-r', '-z', BASE, '--',
    'tools', 'scripts', 'capability_conformance', 'doctrine', 'knowledge-map/scripts', '.knowledge_map.conf'], cwd=ROOT)
support = {}
for entry in filter(None, entries.split(b'\0')):
    metadata, path_bytes = entry.split(b'\t')
    mode, kind, identity = metadata.decode().split()
    path = path_bytes.decode()
    assert kind == 'blob' and mode in ('100644', '100755'), 'parent-owned regular support input'
    value = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
    assert (ROOT / path).read_bytes() == value
    assert stat.S_IMODE((ROOT / path).stat().st_mode) == int(mode, 8) & 0o7777
    support[path] = {'sha256': sha(value), 'mode': int(mode, 8) & 0o7777, 'bytes_base64': encode(value)}
support[PREFIX + 'complete_inputs.py'] = {'sha256': sha(Path(__file__).read_bytes()),
    'mode': stat.S_IMODE(Path(__file__).stat().st_mode), 'bytes_base64': encode(Path(__file__).read_bytes())}
for path in set(support) & set(rolled):
    assert support[path] == rolled[path], ('unchanged common support identity', path)
support_raw = gzip.compress(json.dumps(support, sort_keys=True, separators=(',', ':')).encode(), mtime=0)
with (ROOT / (PREFIX + 'delegate-inputs.json.gz')).open('xb') as output:
    output.write(support_raw)
provided = dict(rolled)
provided.update(support)
record = {'result': 'pending', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'original_measurement_sha256': sha(first_raw), 'rolled_capsule_sha256': sha(rolled_raw),
    'support_capsule_sha256': sha(support_raw), 'support_inputs': len(support), 'provided_inputs': len(provided),
    'new_support_paths': sorted(set(support) - set(rolled))}
TARGET.write_text(json.dumps(record, indent=2) + '\n')
with tempfile.TemporaryDirectory(prefix='finite-history-old-cap-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, item in provided.items():
        value = decode(item['bytes_base64'])
        assert sha(value) == item['sha256']
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(value)
        target.chmod(item['mode'])
    command = ['perl', 'scripts/check_readme_routing_pressure.pl', '--report']
    environment = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(supplied))
    process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
    observed = {p.relative_to(supplied).as_posix(): {'sha256': sha(p.read_bytes()), 'mode': stat.S_IMODE(p.stat().st_mode)}
        for p in supplied.rglob('*') if p.is_file()}
    record['replay'] = {'command': command, 'returncode': process.returncode,
        'stdout_base64': encode(process.stdout), 'stderr_base64': encode(process.stderr)}
    record['unchanged'] = all(observed.get(p) == {'sha256': x['sha256'], 'mode': x['mode']} for p, x in provided.items())
    record['extras'] = sorted(set(observed) - set(provided))
    TARGET.write_text(json.dumps(record, indent=2) + '\n')
    original = first['commands'][-1]
    assert record['unchanged'] and all(p.startswith('.linkedspec-data/') for p in record['extras'])
    assert process.returncode == original['returncode'] != 0
    assert process.stdout == decode(original['stdout_base64'])
    assert process.stderr == decode(original['stderr_base64']), 'exact original old-cap rejection from supplied inputs'
record['result'] = 'PASS'
record['scope'] = ('Original1793/1794 registered-member captures stay frozen. The actual three delegated gates '
    'need their complete parent-owned tools/scripts/capability-consumer/config namespace. Every extra input '
    'is unchanged accepted Git at the measurement base, plus this distinct producer. Supplied replay reads '
    'only the owning Git metadata/objects through GIT_DIR/GIT_WORK_TREE; no repository is created or amended. '
    'Full original old-cap channels match exactly, and every provided byte/mode stays unchanged. Only '
    'managed same-volume wrapper outputs are allowed. Original measurement and producers are not refreshed.')
TARGET.write_text(json.dumps(record, indent=2) + '\n')
print('Complete delegated-input replay PASS:', len(support), 'support inputs;', len(provided), 'supplied inputs; exact old-cap RED')
