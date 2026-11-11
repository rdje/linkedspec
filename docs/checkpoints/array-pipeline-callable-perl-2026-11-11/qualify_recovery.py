"""Retain setup failure; isolate imports and run the actual unchanged reader."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'qualified-recovery'
OUT.mkdir()
reader = BASE / 'review_intake.py'
assert reader.is_file() and not reader.is_symlink()
paths = [Path(__file__).relative_to(ROOT), reader, BASE / 'recovery_path_probe.py',
    BASE / 'run_review_intake.py', BASE / 'intake-sealed-identities.json',
    BASE / 'intake-review-command.json', BASE / 'intake-review-exit.txt',
    BASE / 'intake-review-stdout.log.gz', BASE / 'intake-review-stderr.log.gz',
    BASE / 'first-review-wrapper.log.gz', BASE / 'inspect.py',
    Path('tools/project_data_env.sh'), Path('tools/project_data_run.sh')]
records = {}
with tarfile.open(OUT / 'inputs.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert path.is_file() and not path.is_symlink()
        body = path.read_bytes()
        records[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=path, recursive=False)
(OUT / 'inputs.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')


def run(tag, arguments, expected):
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', *arguments]
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(cwd='.', argv=command), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    for name, row in records.items():
        path = Path(name)
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
    assert result.returncode == expected, 'Actual qualified attempt retained; no substitute PASS'
    return result


help_result = run('python-help', ['-h'], 0)
assert b'-P' in help_result.stdout
run('failure-unsafe', ['-v', str(BASE / 'recovery_path_probe.py'), 'fail'], 1)
run('failure-safe', ['-P', '-v', str(BASE / 'recovery_path_probe.py'), 'fail'], 1)
unsafe = run('import-unsafe', [str(BASE / 'recovery_path_probe.py'), 'inspect'], 1)
safe = run('import-safe', ['-P', str(BASE / 'recovery_path_probe.py'), 'inspect'], 0)
assert b'"inspect_is_stdlib": false' in unsafe.stdout and b'"inspect_is_stdlib": true' in safe.stdout
result = run('reader', ['-P', str(reader)], 0)
assert result.stderr == b''
summary = json.loads(result.stdout)
(OUT / 'result.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary, indent=2))
