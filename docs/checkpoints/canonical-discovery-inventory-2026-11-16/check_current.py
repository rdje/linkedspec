"""Check current source bytes/modes against the preparation; no SDK execution."""
import gzip
import hashlib
import json
from pathlib import Path
import stat
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
report = json.loads(gzip.decompress((BASE / 'inventory.json.gz').read_bytes()))
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == report['activation']
expected = {name: dict(sha256=row['sha256'], git_mode=row['mode'])
            for name, row in report['sources'].items() if name not in report['task_parts']}
producers = json.loads((BASE / 'steps/epoch-check/source-identities.json').read_bytes())


def verify(values):
    for name, row in values.items():
        path = ROOT / name
        assert not path.is_symlink() and path.resolve().is_relative_to(ROOT), 'current source boundary'
        info = path.stat()
        assert stat.S_ISREG(info.st_mode) and info.st_dev == ROOT.stat().st_dev
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], 'current source bytes'
        mode = '100755' if info.st_mode & 0o111 else '100644'
        assert mode == row['git_mode'], 'current source mode'


verify(expected)
for name, row in producers.items():
    path = ROOT / name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
    assert path.stat().st_mode & 0o777 == row['mode']
changed = dict(expected)
name = next(iter(changed))
changed[name] = dict(changed[name], sha256='0' * 64)
try:
    verify(changed)
except AssertionError as error:
    assert str(error) == 'current source bytes'
else:
    raise AssertionError('current-source negative control ineffective')
print(json.dumps(dict(result='PASS', source_files=len(expected), producer_files=len(producers),
    rejected='changed expected source byte', scope='Actual pre-landing logical source identity only; no native origin, physical custody or future freshness promise.'), sort_keys=True))
