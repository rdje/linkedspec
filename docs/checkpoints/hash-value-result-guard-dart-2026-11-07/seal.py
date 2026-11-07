"""Seal completed acquisitions/instruments once; SDK/test identities use archives."""
import hashlib,json
from pathlib import Path
ROOT=Path.cwd().resolve();BASE=Path(__file__).resolve().parent
assert not (BASE/'control-owner').exists()
output=BASE/'sealed-identities.json';assert not output.exists()
paths=[p for p in BASE.rglob('*') if p.is_file() and p.suffix!='.md']
paths += [ROOT/'tests/fixtures'/name for name in ('hash_value_result_guard_cases.json','hash_value_result_guard_dart_profiles.json')]
rows={}
for path in sorted(set(paths)):
    assert not path.is_symlink() and path.stat().st_dev==ROOT.stat().st_dev
    body=path.read_bytes();rows[path.relative_to(ROOT).as_posix()]=dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest())
output.write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
print('completed actual inputs/artifacts/channels/instruments sealed')
