"""Retain read/construct rehearsal, bounded apply and scoped format evidence."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'repair-run'
OUT.mkdir()
OWNER = Path('rust/linkedspec-runtime/src/engine.rs')
NORMAL = Path('rust/linkedspec-runtime/tests/array_concat_open_arity_result_guard_composition.rs')
paths = [OWNER, NORMAL, BASE / 'repair.py', BASE / 'run_repair.py', BASE / 'owner-before.rs.gz',
    Path('tools/project_data_run.sh'), Path('tools/project_data_env.sh')]
rows = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        rows[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=path, recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')


def run(tag, argv):
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(cwd='.', argv=argv), indent=2) + '\n')
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, 'Actual rehearsal/apply/format failure retained'
    return result.stdout


argv = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / 'repair.py')]
rehearsal = json.loads(run('rehearsal', argv))
assert rehearsal['applied'] is False
assert hashlib.sha256(OWNER.read_bytes()).hexdigest() == rehearsal['before_sha256']
applied = json.loads(run('apply', argv + ['--apply']))
assert applied['applied'] is True
assert {key: value for key, value in applied.items() if key != 'applied'} == {
    key: value for key, value in rehearsal.items() if key != 'applied'}
assert hashlib.sha256(OWNER.read_bytes()).hexdigest() == applied['after_sha256']
(OUT / 'owner-after.rs.gz').write_bytes(gzip.compress(OWNER.read_bytes(), mtime=0))
run('format', ['bash', 'tools/project_data_run.sh', 'rustfmt', '--edition', '2024', '--check', str(OWNER), str(NORMAL)])
for name, row in rows.items():
    if name != str(OWNER):
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256'], name
assert hashlib.sha256(OWNER.read_bytes()).hexdigest() == applied['after_sha256']
(OUT / 'complete.txt').write_text('Actual rehearsal/apply/scoped format complete; only approved owner image changed.\n')
print(json.dumps(applied))
