"""Reproduce accepted kind13 failures through existing public tools before owner inspection."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).decode().strip())
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-array-pipelines'))
import common as c

BASE = 'eff23e4894727205dc12b209baab7065180a08e5'


def main():
    status = c.run(['git', 'status', '--porcelain'])
    assert status['returncode'] == 0 and not c.decode(status['stdout_base64'])
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
    prior_path = ROOT / '.linkedspec-data/verification/type-sort-kind-prior.json.gz'
    prior = json.loads(gzip.decompress(prior_path.read_bytes()))
    inputs = {path: c.identity(path) for path in prior['images']}
    assert all(inputs[path] == {key: item[key] for key in ('sha256', 'mode')} for path, item in prior['images'].items())
    producer = c.read(Path(__file__).resolve().relative_to(ROOT).as_posix())
    plan = c.load('kind-investigation2.json.gz')['plan']
    supplied = json.dumps(plan).encode()
    flags = c.run(['perl', '-Iperl', c.PREFIX + 'kinds.pl'], input=supplied)
    public = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=supplied)
    stable = inputs == {path: c.identity(path) for path in inputs}
    value = dict(base=BASE, inputs=inputs, producer=producer, plan=plan,
        flags=flags, public=public, inputs_unchanged=stable, status=status,
        scope='Exact accepted9 source context precedes current native/fresh B-flag/JSON/clone observations and separate descriptor/Get/dump/emitted index diagnostics. Every regular source/input recovers from accepted Git; original producers and plan are tracked there. The older flag instrument stringifies generated exceptions; the separate public observer retains structured causes. No runtime owner is changed or inspected by these probes.')
    target = ROOT / '.linkedspec-data/verification/type-sort-kind-baseline.json.gz'
    with target.open('xb') as output:
        output.write(gzip.compress((json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode(), mtime=0))
    assert stable and c.run(['git', 'status', '--porcelain']) == status
    assert c.read(Path(__file__).resolve().relative_to(ROOT).as_posix()) == producer
    for run in (flags, public):
        assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    rows = json.loads(c.decode(flags['stdout_base64']))['rows']
    assert len(rows) == 16
    for row in rows:
        assert not row['warnings']
        if row['id'].endswith('/sort'):
            assert row['value'] == [1, 10, 2] and row['cloned_value'] == ['1', '10', '2']
            assert all(item['iOK'] == item['pOK'] == 1 for item in row['flags'])
        if row['id'].endswith('/control'):
            assert row['value'] == row['cloned_value'] == [1, 10, 2]
            assert all(item['iOK'] == 1 and item['pOK'] == 0 for item in row['flags'])
    public_rows = json.loads(c.decode(public['stdout_base64']))['rows']
    assert len(public_rows) == 8
    for row in public_rows:
        assert row['descriptor']['completed'] and not row['descriptor']['warnings']
    print('Accepted9 kind RED reproduced:16 flag/value routes;8 descriptor/Get/dump/emitted cases; numeric literal controls retained; all', len(inputs), 'inputs unchanged')


if __name__ == '__main__':
    main()
