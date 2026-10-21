"""Preserve accepted pipeline9 custody before sorted/copy kind13 writes."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).decode().strip())
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-array-pipelines'))
import common as c
import publish

BASE = 'eff23e4894727205dc12b209baab7065180a08e5'


def write_new(name, value):
    raw = (json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode()
    with (ROOT / '.linkedspec-data/verification' / name).open('xb') as output:
        output.write(gzip.compress(raw, mtime=0))


def main():
    producer = c.read(Path(__file__).resolve().relative_to(ROOT).as_posix())
    head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip()
    status = c.run(['git', 'status', '--porcelain'])
    assert head == BASE and status['returncode'] == 0 and not c.decode(status['stdout_base64'])
    baseline = c.run(['bash', 'tools/run_python_project_data.sh', c.PREFIX + 'publish.py'])
    preliminary = dict(base=BASE, producer=producer, baseline=baseline, status=status)
    write_new('type-sort-kind-prior-baseline.json.gz', preliminary)
    assert baseline['returncode'] == 0 and not c.decode(baseline['stderr_base64'])
    inputs = {path: c.identity(path) for path in publish.input_paths()}
    declared = c.load(publish.MANIFEST_NAME)
    publish.validate_inputs(declared['inputs'], inputs)
    logical = c.load('prior.json.gz')['logical_inputs']
    for path, item in logical.items():
        assert c.identity(path) == {key: item[key] for key in ('sha256', 'mode')}
        assert (ROOT / path).stat().st_size == item['size']
    entries = {}
    for row in subprocess.check_output(['git', 'ls-tree', '-rz', BASE], cwd=ROOT).split(b'\0'):
        if row:
            metadata, name = row.split(b'\t', 1)
            mode, kind, oid = metadata.decode().split()
            entries[name.decode()] = dict(mode=mode, kind=kind, oid=oid)
    images, excluded = {}, []
    for row in subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=ROOT).split(b'\0'):
        if not row:
            continue
        metadata, name = row.split(b'\t', 1)
        mode, oid, stage = metadata.decode().split()
        assert stage == '0'
        path = name.decode()
        if mode not in ('100644', '100755'):
            excluded.append(dict(path=path, git_mode=mode, reason='Uninspected Gitlink/symlink boundary'))
            continue
        entry = dict(mode=mode, kind='blob', oid=oid)
        assert entries[path] == entry
        images[path] = dict(**c.identity(path), git=entry)
    assert len(images) == len(inputs) + 3
    assert all({key: images[path][key] for key in ('sha256', 'mode')} == item for path, item in inputs.items())
    verified = c.run(['git', 'hash-object', '--stdin-paths'], input=('\n'.join(sorted(images)) + '\n').encode())
    assert verified['returncode'] == 0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines() == [images[path]['git']['oid'] for path in sorted(images)]
    assert c.run(['git', 'status', '--porcelain']) == status
    assert inputs == {path: c.identity(path) for path in publish.input_paths()}
    value = dict(**preliminary, inputs=inputs, logical_inputs=logical, images=images, excluded=excluded,
        git_verification=verified, claim=c.read(publish.CLAIM), publication=c.read(publish.PUBLICATION),
        manifest=c.read(publish.MANIFEST), gateway=c.read(c.PREFIX + 'publish.py'),
        scope='Complete accepted pipeline9 claim/publication/physical inputs/full modes and independently verified committed Git images, plus three exact prior logical aliases, precede kind13 changes. Actual clean source-readonly0 is retained. All physical sources recover from real accepted eff23e489; tracked chunks recover logical aliases. Immutable data is not recursively copied; Gitlinks and other repositories remain uninspected read-only black boxes.')
    write_new('type-sort-kind-prior.json.gz', value)
    assert c.read(Path(__file__).resolve().relative_to(ROOT).as_posix()) == producer
    print('Accepted9 preserved:', len(inputs), 'physical /', len(logical), 'logical /', len(images), 'Git-verified full-mode images; actual clean readonly0')


if __name__ == '__main__':
    main()
