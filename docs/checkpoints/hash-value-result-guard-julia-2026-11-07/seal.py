"""Seal completed finite acquisitions; mutable SDK/tests are historical archive inputs."""
import hashlib,json
from pathlib import Path
ROOT=Path.cwd().resolve();BASE=Path(__file__).resolve().parent
assert not (BASE/'control-owner').exists()
out=BASE/'sealed-identities.json';assert not out.exists()
paths=[p for p in BASE.rglob('*') if p.is_file() and p.suffix!='.md']
paths += [ROOT/'tests/fixtures'/name for name in ('hash_value_result_guard_cases.json','hash_value_result_guard_julia_cases.json','hash_value_result_guard_julia_profiles.json')]
rows={}
for p in sorted(set(paths)):
    assert not p.is_symlink() and p.stat().st_dev==ROOT.stat().st_dev
    body=p.read_bytes();rows[p.relative_to(ROOT).as_posix()]=dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest())
out.write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
print('actual Julia inputs/artifacts/instruments/full channels sealed')
