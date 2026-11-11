"""Readonly identity of declared current source inputs; retain actual channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
if sys.argv[1:] == ['--check']:
    rows = {}
    for phase in ('intake', 'qualified'):
        observed = json.loads((BASE / phase / 'input-identities.json').read_bytes())
        for name, row in observed.items():
            if name in rows: assert rows[name] == row
            rows[name] = row
    selected = {name: row for name, row in rows.items() if name.startswith('perl/')
                or name.startswith('specs/') or name.startswith(str(REL) + '/')}
    for name, row in selected.items():
        path = ROOT / name
        assert path.is_file() and not path.is_symlink()
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], name
        assert path.stat().st_mode & 0o777 == row['mode'], name
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == '7955c16ca0a98c373dd437284d578e80432b1321'
    assert not subprocess.check_output(['git', 'diff', '--name-only', '--', 'perl', 'specs'], cwd=ROOT).strip()
    print(json.dumps(dict(source='PASS', checked_inputs=list(selected),
        scope='Declared Perl/grammar/original instrument inputs acquisition-exact; production unchanged.')))
else:
    assert not sys.argv[1:]
    target = BASE / 'qualified-current-command.json'
    assert not target.exists()
    script = Path(__file__).read_bytes()
    metadata = b''.join((BASE / phase / 'input-identities.json').read_bytes() for phase in ('intake', 'qualified'))
    command = dict(cwd='.', argv=['bash', 'tools/run_python_project_data.sh', str(REL / 'check_current.py'), '--check'],
        producer_sha256=hashlib.sha256(script).hexdigest(), input_metadata_sha256=hashlib.sha256(metadata).hexdigest())
    target.write_text(json.dumps(command, indent=2) + '\n')
    result = subprocess.run(command['argv'], cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (BASE / ('qualified-current-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (BASE / 'qualified-current-exit.txt').write_text(str(result.returncode) + '\n')
    assert result.returncode == 0 and result.stderr == b''
    assert Path(__file__).read_bytes() == script
    assert b''.join((BASE / phase / 'input-identities.json').read_bytes() for phase in ('intake', 'qualified')) == metadata
    (BASE / 'qualified-current-result.json').write_bytes(result.stdout)
    print('Qualified current-input identity PASS; actual producer/command/channels/exit retained')
