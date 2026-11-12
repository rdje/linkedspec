"""Check the current monitor inputs at activation/pre-staging; no pack replay."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
report = json.loads((BASE / 'measurement/result.json').read_bytes())
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == report['head'] == '102ec3446407543c5ef64f3222bd0fffb5eb3064'
assert subprocess.check_output(['git', 'rev-parse', 'refs/remotes/origin/main'], cwd=ROOT, text=True).strip() == report['cached_origin_main']
assert subprocess.run(['git', 'diff', '--cached', '--quiet'], cwd=ROOT).returncode == 0
identities = json.loads((BASE / 'measurement/producer-input-identities.json').read_bytes())
for name, row in identities.items():
    path = ROOT / name
    assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    assert path.stat().st_mode & 0o777 == row['mode']
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'perl', 'rust', 'dart', 'julia', 'lua', 'specs', 'tools', 'scripts', '.githooks', '.github'], cwd=ROOT) == b''
command = json.loads((BASE / 'measurement/pack-config-command.json').read_bytes())
config = subprocess.run(command['argv'], cwd=ROOT, env=dict(os.environ, **command['environment']), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
assert config.returncode in (0, 1) and not config.stderr
assert config.stdout == gzip.decompress((BASE / 'measurement/pack-config-stdout.gz').read_bytes())
print(json.dumps(dict(current_monitor_inputs='PASS', producer_inputs=len(identities),
    head=report['head'], cached_origin_main=report['cached_origin_main'],
    scope='Activation/pre-staging producer/policy/wrapper/config/ref identities only; no raw pack or SDK replay and no future freshness claim.'), sort_keys=True))
