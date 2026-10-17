"""Complete original-project capture/replay while preserving the own-Git-root guard."""
import base64
import gzip
import hashlib
import json
import re
import stat
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '736c6a43efab526fe898ed5c72b061479955fc5c'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/'
TARGET = ROOT / (PREFIX + 'complete-inputs-root.json')
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
decode = lambda value: base64.b64decode(value, validate=True)
assert not TARGET.exists(), 'one-shot complete project-root replay'
first_raw = (ROOT / (PREFIX + 'measurement.json')).read_bytes()
first = json.loads(first_raw)
assert first['result'] == 'PASS' and first['base'] == BASE
failures = {}
for name, producer, count in (
    ('complete-inputs.json', 'complete_inputs.py', 1978),
    ('complete-inputs-final.json', 'complete_inputs_final.py', 1979),
):
    value = (ROOT / (PREFIX + name)).read_bytes()
    row = json.loads(value)
    assert row['result'] == 'pending' and row['unchanged'] and row['provided_inputs'] == count
    assert row['replay']['returncode'] == 1 and not decode(row['replay']['stdout_base64'])
    assert row['producer_sha256'] == sha((ROOT / (PREFIX + producer)).read_bytes())
    failures[name] = {'sha256': sha(value), 'producer': producer, 'producer_sha256': row['producer_sha256']}
second = json.loads((ROOT / (PREFIX + 'complete-inputs-final.json')).read_bytes())
assert b"this project's Git metadata only" in decode(second['replay']['stderr_base64'])
assert {'perl', 'specs', 't', 'tests'} <= set(second['directories'])
assert not any((ROOT / path).is_symlink() for path in ('.git', '.gitattributes'))
git_dir = Path(subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=ROOT, text=True).strip()).resolve()
assert git_dir.is_relative_to(ROOT), 'unchanged own-project metadata contract'
assert subprocess.run(['git', 'diff', '--cached', '--quiet', '--'], cwd=ROOT).returncode == 0

rows = [json.loads(line) for line in (ROOT / 'doctrine/readme_stability/routes.jsonl').read_bytes().splitlines()]
paths = {'.gitattributes', '.knowledge_map.conf', 'README.md', 'README_POLICY.md', PREFIX + 'complete_inputs_root.py'}
entries = subprocess.check_output(['git', 'ls-tree', '-r', '-z', BASE, '--', 'tools', 'scripts',
    'capability_conformance', 'doctrine', 'knowledge-map/scripts', '.gitattributes', '.knowledge_map.conf'], cwd=ROOT)
accepted_support = {}
for entry in filter(None, entries.split(b'\0')):
    metadata, spelling = entry.split(b'\t')
    mode, kind, identity = metadata.decode().split()
    path = spelling.decode()
    assert kind == 'blob' and mode in ('100644', '100755')
    value = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
    assert (ROOT / path).read_bytes() == value
    paths.add(path)
    accepted_support[path] = sha(value)
directories = set()
for row in rows:
    for pattern in row.get('members', []):
        for path in ROOT.glob(pattern):
            if path.is_file() and not path.is_symlink():
                paths.add(path.relative_to(ROOT).as_posix())
    for spelling in row.get('members', []) + row.get('route_targets', []):
        path = ROOT / spelling
        if path.is_dir():
            directories.add(path.relative_to(ROOT).as_posix())
        elif path.is_file() and not path.is_symlink():
            paths.add(spelling)
files = {}
for path in sorted(paths):
    source = ROOT / path
    value = source.read_bytes()
    files[path] = {'sha256': sha(value), 'mode': stat.S_IMODE(source.stat().st_mode), 'bytes_base64': encode(value)}
capsule = gzip.compress(json.dumps(files, sort_keys=True, separators=(',', ':')).encode(), mtime=0)
with (ROOT / (PREFIX + 'root-replay-inputs.json.gz')).open('xb') as output:
    output.write(capsule)
# The public history regression reads these original project Git artifacts.
source = (ROOT / 'tools/test_document_history_rollover.py').read_text()
revision = re.search(r'^SOURCE_REVISION = "([0-9a-f]{40})"$', source, re.M).group(1)
git_inputs = {}
for path in ('CHANGES.md', 'DEVELOPMENT_NOTES.md', 'docs/history/changes/manifest.jsonl',
             'docs/history/development-notes/manifest.jsonl'):
    value = subprocess.check_output(['git', 'show', revision + ':' + path], cwd=ROOT)
    git_inputs[revision + ':' + path] = {'sha256': sha(value), 'bytes_base64': encode(value)}
tracked = subprocess.check_output(['git', 'ls-files', '--cached', '-z'], cwd=ROOT)
others = subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '-z'], cwd=ROOT)
record = {'result': 'pending', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'original_measurement_sha256': sha(first_raw), 'first_supplied_failures': failures,
    'capsule_sha256': sha(capsule), 'input_count': len(files), 'accepted_support': accepted_support,
    'directories': sorted(directories), 'git_directory': git_dir.relative_to(ROOT).as_posix(),
    'git_inputs': git_inputs, 'tracked_namespace_base64': encode(tracked), 'untracked_namespace_base64': encode(others)}
TARGET.write_text(json.dumps(record, indent=2) + '\n')
command = ['perl', 'scripts/check_readme_routing_pressure.pl', '--report']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
record['replay'] = {'command': command, 'returncode': process.returncode,
    'stdout_base64': encode(process.stdout), 'stderr_base64': encode(process.stderr)}
record['unchanged'] = all(sha((ROOT / p).read_bytes()) == x['sha256'] and
    stat.S_IMODE((ROOT / p).stat().st_mode) == x['mode'] for p, x in files.items())
TARGET.write_text(json.dumps(record, indent=2) + '\n')
original = first['commands'][-1]
assert record['unchanged']
assert process.returncode == original['returncode'] != 0
assert process.stdout == decode(original['stdout_base64'])
assert process.stderr == decode(original['stderr_base64']), 'exact original three-denial channel in own project root'
record['result'] = 'PASS'
record['scope'] = ('Complete current registered data members, parent-owned helper/config/attribute source '
    'namespace, declared directory existence, actual Git path namespace and historical Git fixture '
    'inputs accompany this distinct original-project observation. The two supplied-root failures remain '
    'unaltered; no supplied whole-gate portability is claimed. The public history regression requires '
    'Git metadata within ROOT, so this capture obeys that guard without new/copied repositories, '
    'metadata mutations or weakened source. Full original old-cap channels recur exactly at this '
    'explicit input epoch. Numeric and authority falsification use unchanged production functions '
    'separately. System tools/Git availability remain environmental dependencies; canonical staged '
    'admission is still required.')
TARGET.write_text(json.dumps(record, indent=2) + '\n')
print('Complete original-project old-cap replay PASS:', len(files), 'inputs; exact original channels; own Git guard retained')
